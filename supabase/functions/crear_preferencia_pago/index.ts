// ============================================================================
// Laburito — Edge Function `crear_preferencia_pago`
// Sprint 4 · CU-31 Cargar Tokens
// ============================================================================
//
// Recibe el id de un paquete y devuelve la URL del checkout de Mercado Pago.
//
// **El precio no viaja desde la app.** `iniciar_compra_tokens` (migración 0022)
// crea el pago pendiente copiando cantidad y monto del paquete, y la
// preferencia se arma con esos valores. El `external_reference` es el id del
// pago: es lo único que el webhook (CU-32) necesita para saber qué acreditar,
// y lo que hace que no tenga que confiar en ningún otro dato de la
// notificación.
//
// El Access Token de Mercado Pago vive solo acá, como secreto de la función
// (`MP_ACCESS_TOKEN`, ver docs/MERCADOPAGO.md). Sin él la función contesta
// «pagos no disponibles» antes de crear nada: es el flujo alterno del CU-31.
// ============================================================================

import {
  campo,
  CORS,
  errorDeBase,
  json,
  llamante,
  servicio,
  SUPABASE_URL,
} from '../_shared/http.ts';

const MP_ACCESS_TOKEN = Deno.env.get('MP_ACCESS_TOKEN');

const NO_DISPONIBLE = {
  error: 'Los pagos no están disponibles en este momento. Probá de nuevo más tarde.',
  codigo: 'pagos_no_disponibles',
};

interface Pago {
  id: string;
  paquete_id: string;
  paquete_nombre: string;
  cantidad_tokens: number;
  monto_ars: number;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS });
  }
  if (req.method !== 'POST') return json({ error: 'Usá POST' }, 405);

  const quien = await llamante(req);
  if (quien instanceof Response) return quien;

  const paqueteId = await campo(req, 'paquete_id');
  if (paqueteId instanceof Response) return paqueteId;

  if (!MP_ACCESS_TOKEN) return json(NO_DISPONIBLE, 503);

  // 1. El pago pendiente, con la sesión del Profesional: la función comprueba
  //    que la cuenta esté activa y que el paquete siga a la venta.
  const { data: filas, error: errorPago } = await quien.comoUsuario.rpc(
    'iniciar_compra_tokens',
    { p_paquete: paqueteId },
  );
  if (errorPago) return errorDeBase(errorPago);

  const pago = (filas as Pago[])[0];

  // 2. La preferencia. A la vuelta del checkout, Mercado Pago manda a
  //    `retorno_pago`, que devuelve a la app.
  const retorno = `${SUPABASE_URL}/functions/v1/retorno_pago`;

  let respuesta: Response;
  try {
    respuesta = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
        // Un reintento de la misma llamada no crea dos preferencias.
        'X-Idempotency-Key': pago.id,
      },
      body: JSON.stringify({
        items: [{
          id: pago.paquete_id,
          title: `Laburito · Pack ${pago.paquete_nombre} (${pago.cantidad_tokens} tokens)`,
          quantity: 1,
          unit_price: pago.monto_ars,
          currency_id: 'ARS',
        }],
        external_reference: pago.id,
        notification_url: `${SUPABASE_URL}/functions/v1/webhook_mercadopago`,
        back_urls: {
          success: `${retorno}?resultado=aprobado`,
          pending: `${retorno}?resultado=pendiente`,
          failure: `${retorno}?resultado=rechazado`,
        },
        auto_return: 'approved',
        statement_descriptor: 'LABURITO',
        metadata: { pago_id: pago.id },
      }),
      signal: AbortSignal.timeout(15000),
    });
  } catch (e) {
    await descartar(pago.id, `preferencia_fallida: ${e}`);
    return json(NO_DISPONIBLE, 502);
  }

  if (!respuesta.ok) {
    await descartar(pago.id, `preferencia_fallida: HTTP ${respuesta.status}`);
    console.error('Mercado Pago rechazó la preferencia', await respuesta.text());
    return json(NO_DISPONIBLE, 502);
  }

  const preferencia = await respuesta.json();

  await servicio()
    .from('pagos')
    .update({ mp_preference_id: preferencia.id })
    .eq('id', pago.id);

  // Con credenciales `TEST-` el checkout es el de sandbox; con las de una
  // cuenta vendedora de prueba (`APP_USR-`, lo que recomienda Mercado Pago hoy)
  // es el `init_point` común, y se paga con el comprador de prueba.
  const url = MP_ACCESS_TOKEN.startsWith('TEST-')
    ? preferencia.sandbox_init_point
    : preferencia.init_point;

  return json({ pago_id: pago.id, url });
});

/**
 * Si la preferencia no se pudo crear, el pago no va a llegar nunca: se cierra
 * como cancelado para que no quede un «pendiente» eterno en el historial.
 */
async function descartar(pagoId: string, motivo: string) {
  await servicio()
    .from('pagos')
    .update({ estado: 'cancelado', mp_estado_detalle: motivo })
    .eq('id', pagoId);
}
