-- ============================================================================
-- Laburito — Migración 0017
-- Sprint 3 · CU-21 b: registrar y dar de baja el dispositivo
-- ============================================================================
--
-- La tabla `profesional_dispositivos` y su RLS son de la 0012, que dejó
-- anotada esta deuda: **el token de FCM es de la instalación, no del usuario**.
-- Si en el mismo teléfono cierra sesión un Profesional y entra otro, FCM
-- devuelve el mismo token, y la fila vieja —invisible para el nuevo dueño, por
-- RLS— haría fallar el INSERT con un 23505 que el cliente no puede resolver.
-- Peor todavía si no fallara: el Profesional anterior seguiría recibiendo las
-- alertas del nuevo en su propio teléfono, que ya no tiene.
--
-- Por eso el traspaso lo hace una función SECURITY DEFINER: es el único lugar
-- donde tiene sentido decidir que un token cambia de manos, y el único que
-- puede ver la fila del dueño anterior.
--
-- Es idempotente.
-- ============================================================================


-- ============================================================================
-- 1. registrar_dispositivo
-- ============================================================================

create or replace function public.registrar_dispositivo(
    p_token      text,
    p_plataforma text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_token text := nullif(trim(coalesce(p_token, '')), '');
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    -- Solo los Profesionales reciben alertas del CU-21. Un Buscador que
    -- llegara acá no tiene fila en `profesionales` y la FK fallaría igual;
    -- se corta antes para que el mensaje sea entendible.
    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa registra dispositivos'
              using hint = 'sin_permiso';
    end if;

    if v_token is null or length(v_token) not between 20 and 4096 then
        raise exception 'El token del dispositivo no es válido'
              using hint = 'token_invalido';
    end if;

    if p_plataforma not in ('android', 'ios', 'web') then
        raise exception 'Plataforma desconocida: %', p_plataforma
              using hint = 'plataforma_invalida';
    end if;

    -- El traspaso: si el token estaba a nombre de otra cuenta, deja de estarlo.
    delete from public.profesional_dispositivos
     where token_fcm = v_token
       and profesional_id <> auth.uid();

    insert into public.profesional_dispositivos (profesional_id, token_fcm, plataforma)
    values (auth.uid(), v_token, p_plataforma)
    on conflict (token_fcm) do update
       set profesional_id = excluded.profesional_id,
           plataforma     = excluded.plataforma,
           updated_at     = now();
end;
$$;

comment on function public.registrar_dispositivo(text, text) is
    'CU-21. Registra el token de FCM del dispositivo a nombre de quien llama, quitándoselo a la cuenta que lo tuviera antes. El token es de la instalación, no del usuario.';

revoke all on function public.registrar_dispositivo(text, text)
    from public, anon;
grant execute on function public.registrar_dispositivo(text, text) to authenticated;


-- ============================================================================
-- 2. dar_de_baja_dispositivo
-- ============================================================================
--
-- Se llama al cerrar sesión. **No** es SECURITY DEFINER: borrar solo lo
-- propio ya lo garantiza la política de la 0012, y no hay ninguna razón para
-- que alguien pueda borrar el dispositivo de otro. Existe como función, y no
-- como un DELETE de PostgREST, para que el cliente no tenga que conocer el
-- nombre de la tabla ni armar el filtro.
-- ============================================================================

create or replace function public.dar_de_baja_dispositivo(p_token text)
returns void
language sql
security invoker
set search_path = public
as $$
    delete from public.profesional_dispositivos
     where token_fcm      = nullif(trim(coalesce(p_token, '')), '')
       and profesional_id = auth.uid();
$$;

comment on function public.dar_de_baja_dispositivo(text) is
    'CU-21. Baja del token al cerrar sesión. SECURITY INVOKER: la RLS de la 0012 ya limita el borrado a lo propio.';

revoke all on function public.dar_de_baja_dispositivo(text) from public, anon;
grant execute on function public.dar_de_baja_dispositivo(text) to authenticated;


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
-- PEGAR_PROFESIONAL y PEGAR_OTRO_PROFESIONAL = dos Profesionales activos ·
-- PEGAR_BUSCADOR = un Buscador. Cada bloque termina en rollback.
--
--   -- 1. Alta y reintento: registrar dos veces el mismo token no duplica.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select public.registrar_dispositivo(repeat('t', 40), 'android');
--   select public.registrar_dispositivo(repeat('t', 40), 'android');
--   select count(*) from public.profesional_dispositivos
--    where profesional_id = 'PEGAR_PROFESIONAL';                  -- → 1
--   rollback;
--
--   -- 2. El traspaso, que es el motivo de la migración: el mismo teléfono
--   --    cambia de cuenta y el token cambia de dueño, sin 23505 y sin que el
--   --    anterior siga recibiendo alertas.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select public.registrar_dispositivo(repeat('t', 40), 'android');
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_OTRO_PROFESIONAL","role":"authenticated"}', true);
--   select public.registrar_dispositivo(repeat('t', 40), 'android');
--   reset role;
--   select profesional_id from public.profesional_dispositivos
--    where token_fcm = repeat('t', 40);
--   -- → una sola fila, la de PEGAR_OTRO_PROFESIONAL
--   rollback;
--
--   -- 3. La baja borra lo propio y **no** lo ajeno.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select public.registrar_dispositivo(repeat('t', 40), 'android');
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_OTRO_PROFESIONAL","role":"authenticated"}', true);
--   select public.dar_de_baja_dispositivo(repeat('t', 40));   -- no es suyo
--   reset role;
--   select count(*) from public.profesional_dispositivos
--    where token_fcm = repeat('t', 40);                            -- → 1
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select public.dar_de_baja_dispositivo(repeat('t', 40));   -- sí es suyo
--   reset role;
--   select count(*) from public.profesional_dispositivos
--    where token_fcm = repeat('t', 40);                            -- → 0
--   rollback;
--
--   -- 4. Lo que no entra: token corto, plataforma inventada, y un Buscador.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select public.registrar_dispositivo('corto', 'android');
--   -- → ERROR: El token del dispositivo no es válido  (HINT: token_invalido)
--   rollback;
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select public.registrar_dispositivo(repeat('t', 40), 'blackberry');
--   -- → ERROR: Plataforma desconocida: blackberry  (HINT: plataforma_invalida)
--   rollback;
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_BUSCADOR","role":"authenticated"}', true);
--   select public.registrar_dispositivo(repeat('t', 40), 'android');
--   -- → ERROR: Solo un Profesional con la cuenta activa...  (HINT: sin_permiso)
--   rollback;
--
-- ============================================================================
-- FIN
-- ============================================================================
