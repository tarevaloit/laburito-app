// ============================================================================
// Laburito — Edge Function `retorno_pago`
// Sprint 4 · CU-32, paso 3: «vuelve a la aplicación presionando Volver al sitio»
// ============================================================================
//
// Es la `back_url` de la preferencia. Mercado Pago manda acá el navegador al
// terminar el checkout, con `external_reference` y `status` en la URL, y esta
// función lo redirige a la app con el esquema `laburito://`, que la app
// declara en Android e iOS. Go Router recibe la ruta y abre la billetera con el
// resultado del pago.
//
// **No acredita nada ni lo decide**: lo que diga esta URL lo puede escribir
// cualquiera. Los tokens los acredita el webhook, que consulta el pago a
// Mercado Pago. La billetera, al abrir, relee el pago de la base.
//
// Redirige en vez de devolver una página porque Supabase sirve como texto
// plano el HTML de las Edge Functions en su dominio. Si el navegador no sabe
// abrir `laburito://` —la web, una compu—, no pasa nada: la app, al volver a
// primer plano, relee el pago igual.
//
// Se despliega con `--no-verify-jwt`: quien llega acá es el navegador después
// de pagar, sin sesión de Supabase.
// ============================================================================

const RESULTADOS = new Set(['aprobado', 'pendiente', 'rechazado']);
const UUID = /^[0-9a-f-]{36}$/i;

Deno.serve((req) => {
  const url = new URL(req.url);

  const pago = url.searchParams.get('external_reference') ?? '';
  const resultado = url.searchParams.get('resultado') ?? '';

  const destino = new URL('laburito://laburito/profesional/billetera');
  if (UUID.test(pago)) destino.searchParams.set('pago', pago);
  if (RESULTADOS.has(resultado)) destino.searchParams.set('resultado', resultado);

  return new Response(null, {
    status: 302,
    headers: { Location: destino.toString(), 'Cache-Control': 'no-store' },
  });
});
