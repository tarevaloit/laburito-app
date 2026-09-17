// ============================================================================
// Laburito — Edge Function `emparejar_pedido`
// Sprint 3 · CU-21: avisarle del pedido nuevo a quien corresponde
// ============================================================================
//
// Recibe el id de un pedido y le manda una notificación a cada Profesional
// cuya zona lo contiene y cuyo oficio coincide.
//
// **A quién se le avisa lo decide el servidor, no el cliente.** Esta función
// no acepta una lista de destinatarios: recibe un id de pedido y nada más. Un
// cliente que eligiera a quién notificar es un cliente que puede decidir no
// notificar a nadie, o notificarle a todos. La lista sale de
// `public.profesionales_para_pedido()` (migración 0016), que corre con
// `service_role` y lee la **ubicación exacta** del pedido y no la vista
// pública: el redondeo a tres decimales de `pedidos_publicos` mete un error de
// unos cien metros, y a alguien con una zona de 1 km eso lo deja afuera o lo
// mete adentro por nada.
//
// Quién puede llamarla: el Buscador dueño del pedido, con su sesión. Se
// comprueba contra `buscador_id` y no alcanza con «poder ver el pedido»: desde
// la 0006 cualquier autenticado ve los publicados vigentes.
//
// Qué pasa sin credenciales de FCM: la función empareja igual y contesta con
// la cuenta de destinatarios y `enviadas: 0`. Es a propósito —el proyecto de
// Firebase es un trámite externo— y permite probar el circuito entero sin él.
// ============================================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';

interface Destinatario {
  profesional_id: string;
  distancia_m: number;
  tokens: string[];
}

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

// Credenciales de FCM (HTTP v1). Se cargan con
// `supabase secrets set FCM_PROJECT_ID=... FCM_CLIENT_EMAIL=... FCM_PRIVATE_KEY=...`
const FCM_PROJECT_ID = Deno.env.get('FCM_PROJECT_ID');
const FCM_CLIENT_EMAIL = Deno.env.get('FCM_CLIENT_EMAIL');
const FCM_PRIVATE_KEY = Deno.env.get('FCM_PRIVATE_KEY');

// CORS. Desde la web —donde publica el Buscador— `functions.invoke` es un
// `fetch` del navegador con cabeceras propias (`authorization`, `apikey`,
// `x-client-info`), así que antes del POST el navegador manda un `OPTIONS` de
// verificación. Si ese `OPTIONS` no vuelve con estas cabeceras, el POST no sale
// nunca: la primera versión contestaba 405 a todo lo que no fuera POST y la
// alerta no se disparaba desde la web, en silencio, porque la app no hace
// fallar la publicación por esto.
//
// El origen es `*` a propósito: la función no usa cookies —la identidad viaja
// en el `Authorization`, que el navegador no manda solo— y lo que la protege es
// la verificación del dueño del pedido, no el origen.
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Max-Age': '86400',
};

const json = (cuerpo: unknown, status = 200) =>
  new Response(JSON.stringify(cuerpo), {
    status,
    headers: { ...CORS, 'content-type': 'application/json' },
  });

Deno.serve(async (req) => {
  // La verificación de CORS va antes que todo lo demás: no trae cuerpo ni
  // sesión, y no tiene que tenerlos.
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS });
  }

  if (req.method !== 'POST') return json({ error: 'Usá POST' }, 405);

  const autorizacion = req.headers.get('Authorization') ?? '';
  if (!autorizacion.startsWith('Bearer ')) {
    return json({ error: 'Falta la sesión' }, 401);
  }

  let pedidoId: string | undefined;
  try {
    pedidoId = (await req.json())?.pedido_id;
  } catch {
    return json({ error: 'El cuerpo tiene que ser JSON' }, 400);
  }
  if (!pedidoId) return json({ error: 'Falta pedido_id' }, 400);

  // 1. Quién llama. Con la clave anónima + su token: `getUser` valida la firma.
  const comoUsuario = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: autorizacion } },
  });

  const { data: { user }, error: errorUsuario } = await comoUsuario.auth.getUser();
  if (errorUsuario || !user) return json({ error: 'Sesión inválida' }, 401);

  const servicio = createClient(SUPABASE_URL, SERVICE_KEY);

  // 2. El pedido tiene que ser suyo. Se pregunta con `service_role` y se
  //    compara a mano: con la sesión del usuario, «ver el pedido» no prueba
  //    nada, porque todo autenticado ve los publicados vigentes.
  const { data: pedido, error: errorPedido } = await servicio
    .from('pedidos')
    .select('id, buscador_id, titulo, estado, categoria_id, direccion_texto')
    .eq('id', pedidoId)
    .maybeSingle();

  if (errorPedido) return json({ error: errorPedido.message }, 500);
  if (!pedido) return json({ error: 'El pedido no existe' }, 404);
  if (pedido.buscador_id !== user.id) {
    return json({ error: 'El pedido no es tuyo' }, 403);
  }

  // 3. A quién le corresponde. La regla vive en la base (migración 0016).
  const { data: destinatarios, error: errorMatch } = await servicio.rpc(
    'profesionales_para_pedido',
    { p_pedido_id: pedidoId },
  );

  if (errorMatch) return json({ error: errorMatch.message }, 500);

  const lista = (destinatarios ?? []) as Destinatario[];
  const tokens = lista.flatMap((d) => d.tokens ?? []);

  if (tokens.length === 0) {
    return json({
      profesionales: lista.length,
      dispositivos: 0,
      enviadas: 0,
      detalle: 'No hay dispositivos registrados para esos Profesionales',
    });
  }

  if (!FCM_PROJECT_ID || !FCM_CLIENT_EMAIL || !FCM_PRIVATE_KEY) {
    // Sin Firebase configurado el emparejamiento igual sirve: es lo que
    // permite probar el circuito antes de tener el proyecto.
    return json({
      profesionales: lista.length,
      dispositivos: tokens.length,
      enviadas: 0,
      detalle: 'Faltan las credenciales de FCM (FCM_PROJECT_ID, '
        + 'FCM_CLIENT_EMAIL, FCM_PRIVATE_KEY)',
    });
  }

  const accessToken = await tokenDeGoogle();

  const resultados = await Promise.allSettled(
    tokens.map((token) =>
      enviarFcm(accessToken, token, {
        titulo: 'Nuevo pedido cerca tuyo',
        cuerpo: `${pedido.titulo} · ${pedido.direccion_texto}`,
        pedidoId: pedido.id,
      })
    ),
  );

  const enviadas = resultados.filter((r) => r.status === 'fulfilled').length;
  const fallidas = resultados.length - enviadas;

  // Un token que FCM ya no reconoce se da de baja: si no, cada pedido nuevo
  // vuelve a intentar contra un teléfono que no existe.
  const muertos = resultados.flatMap((r, i) =>
    r.status === 'rejected' && `${r.reason}`.includes('UNREGISTERED')
      ? [tokens[i]]
      : []
  );
  if (muertos.length > 0) {
    await servicio
      .from('profesional_dispositivos')
      .delete()
      .in('token_fcm', muertos);
  }

  return json({
    profesionales: lista.length,
    dispositivos: tokens.length,
    enviadas,
    fallidas,
    dadosDeBaja: muertos.length,
  });
});

// ---------------------------------------------------------------------------
// FCM HTTP v1
// ---------------------------------------------------------------------------
//
// La API v1 pide un access token de Google, que se saca firmando un JWT con la
// clave privada de la cuenta de servicio. Se hace a mano con Web Crypto en vez
// de sumar una dependencia: son treinta líneas y evita arrastrar una librería
// entera adentro de la función.

async function tokenDeGoogle(): Promise<string> {
  const ahora = Math.floor(Date.now() / 1000);
  const encabezado = { alg: 'RS256', typ: 'JWT' };
  const cuerpo = {
    iss: FCM_CLIENT_EMAIL,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: ahora,
    exp: ahora + 3600,
  };

  const sinFirma = `${base64url(JSON.stringify(encabezado))}.${
    base64url(JSON.stringify(cuerpo))
  }`;

  const clave = await crypto.subtle.importKey(
    'pkcs8',
    pemADer(FCM_PRIVATE_KEY!),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const firma = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    clave,
    new TextEncoder().encode(sinFirma),
  );

  const jwt = `${sinFirma}.${base64url(new Uint8Array(firma))}`;

  const respuesta = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  if (!respuesta.ok) {
    throw new Error(`Google rechazó la cuenta de servicio: ${await respuesta.text()}`);
  }

  return (await respuesta.json()).access_token as string;
}

async function enviarFcm(
  accessToken: string,
  token: string,
  aviso: { titulo: string; cuerpo: string; pedidoId: string },
): Promise<void> {
  const respuesta = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
    {
      method: 'POST',
      headers: {
        authorization: `Bearer ${accessToken}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title: aviso.titulo, body: aviso.cuerpo },
          // El id viaja en `data` para que tocar la notificación abra
          // `/pedidos/:id`. `data` solo admite strings.
          data: { pedido_id: aviso.pedidoId, tipo: 'pedido_nuevo' },
          android: { priority: 'high' },
          apns: { payload: { aps: { sound: 'default' } } },
        },
      }),
    },
  );

  if (!respuesta.ok) throw new Error(await respuesta.text());
}

function base64url(dato: string | Uint8Array): string {
  const bytes = typeof dato === 'string'
    ? new TextEncoder().encode(dato)
    : dato;
  return btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

/// La clave de la cuenta de servicio viene en PEM, con `\n` escapados si se
/// cargó por `supabase secrets set`.
function pemADer(pem: string): ArrayBuffer {
  const limpio = pem
    .replace(/\\n/g, '\n')
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '');
  const binario = atob(limpio);
  const bytes = new Uint8Array(binario.length);
  for (let i = 0; i < binario.length; i++) bytes[i] = binario.charCodeAt(i);
  return bytes.buffer;
}
