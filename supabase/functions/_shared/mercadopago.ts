// ============================================================================
// Laburito — lo que el webhook y la conciliación comparten con Mercado Pago
// ============================================================================
//
// Las dos formas de enterarse del resultado de un pago terminan en el mismo
// lugar: se le **pregunta a Mercado Pago** por el pago y se aplica lo que
// conteste con `registrar_resultado_pago` (migración 0022), que es idempotente.
// Por eso pueden convivir sin pisarse: si el webhook y la conciliación llegan a
// la vez, el segundo encuentra el pago ya aprobado y no hace nada.
// ============================================================================

import { servicio } from './http.ts';

export const MP_ACCESS_TOKEN = Deno.env.get('MP_ACCESS_TOKEN');

export type PagoMp = Record<string, unknown>;

async function api(ruta: string): Promise<Response> {
  return await fetch(`https://api.mercadopago.com${ruta}`, {
    headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` },
    signal: AbortSignal.timeout(15000),
  });
}

/** Un pago por su id de Mercado Pago. `null` si Mercado Pago no lo conoce. */
export async function consultarPago(id: string): Promise<PagoMp | null> {
  const r = await api(`/v1/payments/${encodeURIComponent(id)}`);
  if (r.status === 404) return null;
  if (!r.ok) throw new Error(`Mercado Pago contestó ${r.status} al consultar el pago ${id}`);
  return await r.json();
}

/**
 * Los pagos de Mercado Pago de una compra nuestra, buscados por el
 * `external_reference` (el id de `pagos`). Si hay uno aprobado, ese; si no, el
 * más reciente: un rechazo seguido de un reintento aprobado tiene que terminar
 * aprobado. `null` si todavía no hay ninguno (no se terminó de pagar).
 */
export async function buscarPorReferencia(referencia: string): Promise<PagoMp | null> {
  const r = await api(
    `/v1/payments/search?external_reference=${encodeURIComponent(referencia)}`
      + '&sort=date_created&criteria=desc&limit=10',
  );
  if (!r.ok) throw new Error(`Mercado Pago contestó ${r.status} a la búsqueda de ${referencia}`);

  const resultados = ((await r.json()).results ?? []) as PagoMp[];
  return resultados.find((p) => p.status === 'approved') ?? resultados[0] ?? null;
}

export type Aplicado =
  | { tipo: 'aplicado'; estado: string }
  | { tipo: 'ajeno'; motivo: string }
  | { tipo: 'error'; motivo: string };

/** Aplica en la base lo que Mercado Pago dijo del pago. */
export async function aplicar(pagoMp: PagoMp): Promise<Aplicado> {
  const referencia = pagoMp.external_reference as string | null;
  if (!referencia) {
    return { tipo: 'ajeno', motivo: 'Pago sin external_reference: no es de Laburito' };
  }

  const { data, error } = await servicio().rpc('registrar_resultado_pago', {
    p_pago: referencia,
    p_mp_payment_id: String(pagoMp.id),
    p_estado_mp: pagoMp.status,
    p_estado_detalle: pagoMp.status_detail ?? null,
    p_monto: pagoMp.transaction_amount,
    p_metodo: pagoMp.payment_method_id ?? pagoMp.payment_type_id ?? null,
  });

  if (error) {
    // Un external_reference que no es nuestro: reintentar no lo arregla.
    if (error.hint === 'pago_inexistente' || error.code === '22P02') {
      return { tipo: 'ajeno', motivo: error.message };
    }
    return { tipo: 'error', motivo: error.message };
  }

  return { tipo: 'aplicado', estado: (data as { estado: string }).estado };
}
