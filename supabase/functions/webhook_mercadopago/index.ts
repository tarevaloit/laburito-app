// ============================================================================
// Laburito — Edge Function `webhook_mercadopago`
// Sprint 4 · CU-32 Procesar Pago
// ============================================================================
//
// Mercado Pago llama acá cada vez que un pago cambia de estado. La función:
//
//   1. **Valida la firma** (`x-signature`): un HMAC-SHA256 con la clave secreta
//      del webhook sobre `id:{data.id};request-id:{x-request-id};ts:{ts};`.
//      Sin firma válida no se hace nada. Sin esto, cualquiera que conozca la
//      URL podría avisar «pago aprobado».
//   2. **Consulta el pago a la API** de Mercado Pago con el Access Token. El
//      cuerpo de la notificación trae solo un id y no se le cree nada más: el
//      estado, el monto y el `external_reference` salen de la respuesta de
//      Mercado Pago.
//   3. Llama a `registrar_resultado_pago` (migración 0022), que es idempotente
//      y acredita solo si el monto coincide.
//
// Contesta 200 cuando terminó de procesar —aunque sea para ignorar la
// notificación— y 5xx cuando conviene que Mercado Pago reintente (la API o la
// base no respondieron). Mercado Pago reintenta con espera creciente.
//
// Se despliega con `--no-verify-jwt`: quien llama es Mercado Pago, no un
// usuario de Supabase. La autenticación es la firma.
// ============================================================================

import { json, servicio } from '../_shared/http.ts';

const MP_ACCESS_TOKEN = Deno.env.get('MP_ACCESS_TOKEN');
const MP_WEBHOOK_SECRET = Deno.env.get('MP_WEBHOOK_SECRET');

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'Usá POST' }, 405);

  if (!MP_ACCESS_TOKEN || !MP_WEBHOOK_SECRET) {
    console.error('Faltan MP_ACCESS_TOKEN o MP_WEBHOOK_SECRET');
    return json({ error: 'Webhook sin configurar' }, 503);
  }

  const url = new URL(req.url);
  let cuerpo: Record<string, unknown> = {};
  try {
    cuerpo = await req.json();
  } catch {
    // Algunas notificaciones viejas (IPN) no traen cuerpo: se sigue con la URL.
  }

  const tipo = url.searchParams.get('type') ?? (cuerpo.type as string | undefined);
  const dataId = url.searchParams.get('data.id')
    ?? ((cuerpo.data as { id?: string | number } | undefined)?.id?.toString());

  if (tipo !== 'payment' || !dataId) {
    return json({ ignorada: true, motivo: 'No es una notificación de pago' });
  }

  // 1. Firma
  if (!(await firmaValida(req, dataId))) {
    console.warn('Firma inválida para la notificación del pago', dataId);
    return json({ error: 'Firma inválida' }, 401);
  }

  // 2. Lo que dice Mercado Pago del pago
  let pagoMp: Record<string, unknown>;
  try {
    const r = await fetch(`https://api.mercadopago.com/v1/payments/${encodeURIComponent(dataId)}`, {
      headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` },
      signal: AbortSignal.timeout(15000),
    });
    if (r.status === 404) return json({ ignorada: true, motivo: 'Pago desconocido' });
    if (!r.ok) return json({ error: `Mercado Pago contestó ${r.status}` }, 502);
    pagoMp = await r.json();
  } catch (e) {
    return json({ error: `No se pudo consultar el pago: ${e}` }, 502);
  }

  const externalReference = pagoMp.external_reference as string | null;
  if (!externalReference) {
    return json({ ignorada: true, motivo: 'Pago sin external_reference: no es de Laburito' });
  }

  // 3. Aplicar el resultado
  const { data, error } = await servicio().rpc('registrar_resultado_pago', {
    p_pago: externalReference,
    p_mp_payment_id: String(pagoMp.id),
    p_estado_mp: pagoMp.status,
    p_estado_detalle: pagoMp.status_detail ?? null,
    p_monto: pagoMp.transaction_amount,
    p_metodo: pagoMp.payment_method_id ?? pagoMp.payment_type_id ?? null,
  });

  if (error) {
    if (error.hint === 'pago_inexistente' || error.code === '22P02') {
      // Un external_reference que no es nuestro: reintentar no lo arregla.
      return json({ ignorada: true, motivo: error.message });
    }
    console.error('registrar_resultado_pago falló', error);
    return json({ error: error.message }, 500);
  }

  return json({ ok: true, pago: externalReference, estado: data?.estado });
});

/**
 * Firma de los webhooks de Mercado Pago.
 *
 * `x-signature: ts=1704908010,v1=618c85345248dd820d5fd456117c2ab2ef8eda45a0282ff693eac24131a5e839`
 * El manifiesto es `id:{data.id};request-id:{x-request-id};ts:{ts};`, con el id
 * en minúsculas si es alfanumérico. Cada parte que no venga se omite entera.
 */
async function firmaValida(req: Request, dataId: string): Promise<boolean> {
  const firma = req.headers.get('x-signature') ?? '';
  const requestId = req.headers.get('x-request-id');

  const partes = Object.fromEntries(
    firma.split(',').map((p) => p.trim().split('=', 2) as [string, string]),
  );
  const ts = partes['ts'];
  const v1 = partes['v1'];
  if (!ts || !v1) return false;

  let manifiesto = `id:${dataId.toLowerCase()};`;
  if (requestId) manifiesto += `request-id:${requestId};`;
  manifiesto += `ts:${ts};`;

  const clave = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(MP_WEBHOOK_SECRET),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const bytes = new Uint8Array(
    await crypto.subtle.sign('HMAC', clave, new TextEncoder().encode(manifiesto)),
  );
  const esperado = Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');

  return compararSinFiltrarTiempo(esperado, v1.toLowerCase());
}

/** Comparación de tiempo constante: no revela cuántos caracteres coinciden. */
function compararSinFiltrarTiempo(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diferencia = 0;
  for (let i = 0; i < a.length; i++) diferencia |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diferencia === 0;
}
