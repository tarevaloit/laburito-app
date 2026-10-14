// ============================================================================
// Laburito — Edge Function `reenviar_enlace_gestion`
// Sprint 5 · CU-18 Solicitar Reenvío de Enlace de Gestión
// ============================================================================
//
// La ERS supone un Buscador sin cuenta que gestiona su pedido con un enlace
// único por correo. En Laburito el Buscador está registrado (CU-01), así que
// el «enlace de gestión» es un **enlace mágico de Supabase Auth**: de un solo
// uso, abre la sesión y lleva directo a sus pedidos (decisión del 13/10).
//
//   1. Busca un Buscador activo con ese correo y al menos un pedido publicado
//      o pausado (paso 4).
//   2. Si lo hay, pide a Supabase Auth el envío del enlace (paso 6). Cada
//      pedido nuevo invalida el anterior: es el comportamiento del enlace
//      mágico, que guarda un solo token vivo por usuario.
//   3. Conteste lo que conteste, la respuesta es la misma (flujo alterno
//      1.2): no se puede usar para averiguar quién tiene cuenta.
//
// Se despliega con `--no-verify-jwt`: quien la usa perdió el acceso.
// ============================================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';
import { ANON_KEY, campo, CORS, json, servicio, SUPABASE_URL } from '../_shared/http.ts';

/** La Web publicada (decisión del 13/10). Se puede cambiar con el secreto WEB_URL. */
const WEB_URL = (Deno.env.get('WEB_URL') ?? 'https://laburito.web.app')
  .replace(/\/+$/, '');

const MENSAJE = 'Si tenés un pedido activo, vas a recibir un correo en breve.';

const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS });
  }
  if (req.method !== 'POST') return json({ error: 'Usá POST' }, 405);

  const crudo = await campo(req, 'email');
  if (crudo instanceof Response) return crudo;

  const email = crudo.trim().toLowerCase();
  if (!EMAIL.test(email) || email.length > 254) {
    return json({ error: 'Ingresá un correo electrónico válido.', codigo: 'email_invalido' }, 400);
  }

  const cliente = servicio();

  const { data: perfil } = await cliente
    .from('perfiles')
    .select('id')
    .eq('tipo', 'buscador')
    .eq('estado', 'activo')
    .is('deleted_at', null)
    .ilike('email', email)
    .maybeSingle();

  if (!perfil) {
    console.log('[reenvio] sin Buscador activo para el correo');
    return json({ mensaje: MENSAJE });
  }

  const { data: pedidos } = await cliente
    .from('pedidos')
    .select('id')
    .eq('buscador_id', perfil.id)
    .in('estado', ['publicado', 'pausado'])
    .limit(2);

  if (!pedidos || pedidos.length === 0) {
    console.log('[reenvio] el Buscador no tiene pedidos activos');
    return json({ mensaje: MENSAJE });
  }

  // Con un solo pedido activo, directo a su panel; con más, a la lista.
  const destino = pedidos.length === 1
    ? `${WEB_URL}/pedidos/${pedidos[0].id}`
    : `${WEB_URL}/pedidos`;

  // Cliente público y flujo implícito: el enlace trae la sesión en el
  // fragmento y la Web la toma al cargar. Con PKCE haría falta un verificador
  // guardado en el navegador del Buscador, que acá no existe.
  const auth = createClient(SUPABASE_URL, ANON_KEY, {
    auth: { persistSession: false, flowType: 'implicit' },
  }).auth;

  const { error } = await auth.signInWithOtp({
    email,
    options: { shouldCreateUser: false, emailRedirectTo: destino },
  });

  if (error) {
    // Límite de envíos o correo mal configurado: se registra, pero la
    // respuesta no cambia (flujo alterno).
    console.error(`[reenvio] Supabase Auth: ${error.message}`);
  } else {
    console.log('[reenvio] enlace enviado');
  }

  return json({ mensaje: MENSAJE });
});
