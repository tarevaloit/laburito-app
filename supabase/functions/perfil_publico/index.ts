// ============================================================================
// Laburito — Edge Function `perfil_publico`
// Sprint 5 · CU-27 Acceder a Perfil por Link
// ============================================================================
//
// La abre la Web en `/p/:slug`, sin sesión: el Buscador llega desde un enlace
// de WhatsApp y no tiene cuenta (modelo «Frictionless»). Se despliega con
// `--no-verify-jwt`.
//
// Es una función y no una RPC para `anon` porque el bucket `portafolios` es
// privado: firmar las fotos exige la clave de servicio. Los datos y el registro
// de la visita (CU-45) salen de `perfil_publico_datos`, que solo esta función
// puede ejecutar. Si devuelve `null`, es el 404 del flujo alterno.
// ============================================================================

import { campo, CORS, json, servicio } from '../_shared/http.ts';

/** Una hora: alcanza para mirar el perfil sin dejar URLs vivas para siempre. */
const VIGENCIA_FIRMA_SEGUNDOS = 60 * 60;

interface Foto {
  storage_path: string;
  descripcion: string | null;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS });
  }
  if (req.method !== 'POST') return json({ error: 'Usá POST' }, 405);

  const slug = await campo(req, 'slug');
  if (slug instanceof Response) return slug;
  if (!/^[a-z0-9-]{3,80}$/i.test(slug)) {
    return json({ error: 'Perfil no disponible', codigo: 'no_encontrado' }, 404);
  }

  const cliente = servicio();
  const { data, error } = await cliente.rpc('perfil_publico_datos', { p_slug: slug });

  if (error) {
    console.error(`[perfil_publico] ${error.message}`);
    return json({ error: 'No pudimos cargar el perfil.' }, 500);
  }
  if (!data) {
    return json({ error: 'Perfil no disponible', codigo: 'no_encontrado' }, 404);
  }

  const fotos = (data.portafolio ?? []) as Foto[];
  let portafolio: { url: string; descripcion: string | null }[] = [];

  if (fotos.length > 0) {
    const { data: firmadas, error: errorFirma } = await cliente.storage
      .from('portafolios')
      .createSignedUrls(fotos.map((f) => f.storage_path), VIGENCIA_FIRMA_SEGUNDOS);

    if (errorFirma) {
      // Sin fotos el perfil se sigue viendo: nombre, oficios y reseñas son lo
      // que el Buscador vino a corroborar.
      console.error(`[perfil_publico] firma: ${errorFirma.message}`);
    } else {
      portafolio = (firmadas ?? [])
        .map((f, i) => ({ url: f.signedUrl, descripcion: fotos[i]?.descripcion ?? null }))
        .filter((f) => !!f.url);
    }
  }

  return json({ ...data, portafolio });
});
