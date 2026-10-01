// ============================================================================
// Laburito — Edge Function `verificar_pago`
// Sprint 4 · CU-32 Procesar Pago: conciliación desde la app
// ============================================================================
//
// El webhook es la vía principal para enterarse de un pago, pero no la única:
// Mercado Pago puede demorar el aviso, reintentarlo horas después o no
// mandarlo si la aplicación quedó mal configurada. Esta función es el camino
// de respaldo que Mercado Pago recomienda: la app, al volver del checkout, pide
// verificar su pago; acá se lo busca en Mercado Pago por el
// `external_reference` y se aplica lo que conteste.
//
// Solo para el dueño del pago y solo si sigue pendiente. Lo que se aplica sale
// de la API de Mercado Pago, nunca del cliente, y pasa por la misma función
// idempotente que usa el webhook: si los dos llegan a la vez, no se acredita
// dos veces.
// ============================================================================

import { campo, CORS, json, llamante, servicio } from '../_shared/http.ts';
import { aplicar, buscarPorReferencia, MP_ACCESS_TOKEN } from '../_shared/mercadopago.ts';

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS });
  }
  if (req.method !== 'POST') return json({ error: 'Usá POST' }, 405);

  const quien = await llamante(req);
  if (quien instanceof Response) return quien;

  const pagoId = await campo(req, 'pago_id');
  if (pagoId instanceof Response) return pagoId;

  const { data: pago } = await servicio()
    .from('pagos')
    .select('id, profesional_id, estado')
    .eq('id', pagoId)
    .maybeSingle();

  if (!pago || pago.profesional_id !== quien.usuario.id) {
    return json({ error: 'Ese pago no existe.', codigo: 'sin_permiso' }, 404);
  }
  if (pago.estado !== 'pendiente') return json({ estado: pago.estado });
  if (!MP_ACCESS_TOKEN) {
    return json({ error: 'Los pagos no están disponibles.', codigo: 'pagos_no_disponibles' }, 503);
  }

  let pagoMp;
  try {
    pagoMp = await buscarPorReferencia(pago.id);
  } catch (e) {
    console.error(`[verificar] ${e}`);
    return json({ estado: 'pendiente', detalle: 'Mercado Pago no respondió' });
  }

  if (!pagoMp) {
    // Todavía no se pagó (o se abandonó el checkout).
    return json({ estado: 'pendiente', detalle: 'Sin pago en Mercado Pago' });
  }

  const resultado = await aplicar(pagoMp);
  console.log(`[verificar] pago ${pago.id} (${pagoMp.status}) → ${JSON.stringify(resultado)}`);

  return resultado.tipo === 'aplicado'
    ? json({ estado: resultado.estado })
    : json({ estado: 'pendiente', detalle: resultado.motivo });
});
