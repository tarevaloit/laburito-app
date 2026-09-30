// ============================================================================
// Laburito — piezas comunes de las Edge Functions del Sprint 4
// ============================================================================
//
// CORS, respuestas JSON y «quién llama». Es lo mismo que `emparejar_pedido`
// escribe adentro (Sprint 3); las funciones de la billetera lo comparten
// desde acá para que la lección del 16/09 —sin responder el OPTIONS, la web no
// llama nunca— no se tenga que recordar cuatro veces.
// ============================================================================

import {
  createClient,
  type SupabaseClient,
  type User,
} from 'https://esm.sh/@supabase/supabase-js@2.45.0';

export const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
export const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
export const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

export const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Max-Age': '86400',
};

export const json = (cuerpo: unknown, status = 200) =>
  new Response(JSON.stringify(cuerpo), {
    status,
    headers: { ...CORS, 'content-type': 'application/json' },
  });

/** Cliente con permisos totales. Solo después de saber quién llama. */
export const servicio = (): SupabaseClient =>
  createClient(SUPABASE_URL, SERVICE_KEY, {
    auth: { persistSession: false },
  });

export interface Llamante {
  usuario: User;
  /** Cliente que actúa **como** el usuario: pasa por RLS y `auth.uid()`. */
  comoUsuario: SupabaseClient;
}

/**
 * Valida la sesión del `Authorization`. Devuelve la respuesta de error lista
 * para contestar si no hay una sesión válida.
 */
export async function llamante(req: Request): Promise<Llamante | Response> {
  const autorizacion = req.headers.get('Authorization') ?? '';
  if (!autorizacion.startsWith('Bearer ')) {
    return json({ error: 'Falta la sesión' }, 401);
  }

  const comoUsuario = createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: autorizacion } },
    auth: { persistSession: false },
  });

  const { data: { user }, error } = await comoUsuario.auth.getUser();
  if (error || !user) return json({ error: 'Sesión inválida' }, 401);

  return { usuario: user, comoUsuario };
}

/** Lee un campo del cuerpo JSON, o devuelve la respuesta de error. */
export async function campo(
  req: Request,
  nombre: string,
): Promise<string | Response> {
  let valor: unknown;
  try {
    valor = (await req.json())?.[nombre];
  } catch {
    return json({ error: 'El cuerpo tiene que ser JSON' }, 400);
  }
  if (typeof valor !== 'string' || valor.length === 0) {
    return json({ error: `Falta ${nombre}` }, 400);
  }
  return valor;
}

/**
 * Los `raise exception` de nuestras funciones llegan como P0001 con el mensaje
 * redactado para el usuario y un `hint` para la app. Se pasan tal cual, igual
 * que hace `MensajesError` del lado de Flutter.
 */
export const errorDeBase = (
  error: { code?: string; message: string; hint?: string | null },
) =>
  error.code === 'P0001'
    ? json({ error: error.message, codigo: error.hint ?? null }, 400)
    : json({ error: 'No pudimos completar la operación.', detalle: error.message }, 500);
