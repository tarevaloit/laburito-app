// ============================================================================
// Laburito — Edge Function `webhook_mercadopago`
// Sprint 4 · CU-32 Procesar Pago
// ============================================================================
//
// Mercado Pago llama acá cada vez que un pago cambia de estado. Llegan dos
// formatos a la `notification_url` de la preferencia:
//
//   * **Webhook**: `?data.id=123&type=payment`, firmado con `x-signature`.
//   * **IPN**, el formato viejo: `?id=123&topic=payment`, **sin firma**.
//
// Para el webhook se valida la firma: un HMAC-SHA256 con la clave secreta del
// webhook sobre `id:{data.id};request-id:{x-request-id};ts:{ts};`. El IPN no
// trae firma, y se acepta igual, porque **lo que da autenticidad al resultado
// no es el aviso sino la consulta**: en los dos casos se le pregunta el pago a
// la API de Mercado Pago con nuestro Access Token y se aplica lo que conteste.
// Alguien que conozca esta URL puede, como mucho, hacer que consultemos un
// pago; no puede inventar uno aprobado.
//
// El resultado lo aplica `registrar_resultado_pago` (migración 0022), que es
// idempotente y acredita solo si el monto coincide. La conciliación desde la
// app (`verificar_pago`) usa el mismo camino: si el aviso no llega, el pago se
// resuelve igual.
//
// Cada aviso deja una línea `[webhook]` en los logs de la función, con qué se
// hizo y por qué: es lo que hay que mirar si un pago queda pendiente.
//
// Se despliega con `--no-verify-jwt`: quien llama es Mercado Pago.
// ============================================================================

import { json } from '../_shared/http.ts';
import { aplicar, consultarPago, MP_ACCESS_TOKEN } from '../_shared/mercadopago.ts';

const MP_WEBHOOK_SECRET = Deno.env.get('MP_WEBHOOK_SECRET');

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'Usá POST' }, 405);

  if (!MP_ACCESS_TOKEN) {
    console.error('[webhook] falta MP_ACCESS_TOKEN');
    return json({ error: 'Webhook sin configurar' }, 503);
  }

  const url = new URL(req.url);
  let cuerpo: Record<string, unknown> = {};
  try {
    cuerpo = await req.json();
  } catch {
    // El IPN puede venir sin cuerpo: se sigue con la URL.
  }

  const tipo = url.searchParams.get('type')
    ?? url.searchParams.get('topic')
    ?? (cuerpo.type as string | undefined)
    ?? (cuerpo.topic as string | undefined);
  const dataId = url.searchParams.get('data.id')
    ?? ((cuerpo.data as { id?: string | number } | undefined)?.id?.toString())
    ?? url.searchParams.get('id');
  const firmado = req.headers.has('x-signature');

  console.log(`[webhook] recibido tipo=${tipo} id=${dataId} firmado=${firmado}`);

  if (tipo !== 'payment' || !dataId) {
    return json({ ignorada: true, motivo: 'No es una notificación de pago' });
  }

  // 1. Firma, si la trae. Una firma presente e inválida se rechaza: o el
  //    secreto cargado no es el de esta aplicación, o el aviso no es de
  //    Mercado Pago.
  if (firmado) {
    if (!MP_WEBHOOK_SECRET) {
      console.error('[webhook] llegó un aviso firmado y falta MP_WEBHOOK_SECRET');
      return json({ error: 'Webhook sin configurar' }, 503);
    }
    if (!(await firmaValida(req, dataId))) {
      console.warn(`[webhook] FIRMA INVÁLIDA para el pago ${dataId}: revisar que `
        + 'MP_WEBHOOK_SECRET sea la clave del webhook de la aplicación del vendedor');
      return json({ error: 'Firma inválida' }, 401);
    }
  }

  // 2. Lo que dice Mercado Pago del pago
  let pagoMp;
  try {
    pagoMp = await consultarPago(dataId);
  } catch (e) {
    console.error(`[webhook] no se pudo consultar el pago ${dataId}: ${e}`);
    return json({ error: `${e}` }, 502);
  }
  if (!pagoMp) {
    console.warn(`[webhook] Mercado Pago no conoce el pago ${dataId}`);
    return json({ ignorada: true, motivo: 'Pago desconocido' });
  }

  // 3. Aplicar el resultado
  const resultado = await aplicar(pagoMp);
  console.log(`[webhook] pago ${dataId} (${pagoMp.status}) → ${JSON.stringify(resultado)}`);

  switch (resultado.tipo) {
    case 'aplicado':
      return json({ ok: true, pago: pagoMp.external_reference, estado: resultado.estado });
    case 'ajeno':
      return json({ ignorada: true, motivo: resultado.motivo });
    case 'error':
      return json({ error: resultado.motivo }, 500);
  }
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
