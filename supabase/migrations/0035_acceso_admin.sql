-- ============================================================================
-- Laburito — Migración 0035
-- Sprint 6 · CU-34 Iniciar Sesión Administrador
-- ============================================================================
--
-- Supabase Auth valida la contraseña; esta función valida el **rol** (paso 4:
-- «que el rol asignado sea estrictamente Admin») y deja el registro que pide
-- el requerimiento especial: IP y hora de cada intento, aceptado o denegado.
--
-- La IP sale de los encabezados que PostgREST expone en `request.headers`: el
-- cliente no la manda, así que no la puede inventar. El navegador, del
-- `user-agent` del mismo pedido.
--
-- La llama el panel después de iniciar sesión. Si devuelve `false`, la app
-- cierra la sesión (flujo alterno 1.2).
-- ============================================================================

create or replace function public.registrar_acceso_admin()
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid       uuid := auth.uid();
    v_headers   json := coalesce(nullif(current_setting('request.headers', true), ''), '{}')::json;
    v_ip        text;
    v_es_admin  boolean := public.es_admin();
begin
    if v_uid is null then
        raise exception 'No hay sesión activa.'
              using hint = 'sin_permiso';
    end if;

    v_ip := coalesce(
        v_headers ->> 'cf-connecting-ip',
        nullif(trim(split_part(v_headers ->> 'x-forwarded-for', ',', 1)), ''),
        v_headers ->> 'x-real-ip'
    );

    insert into public.accesos_admin (perfil_id, email, resultado, ip, navegador)
    select v_uid, p.email,
           case when v_es_admin then 'aceptado' else 'denegado' end,
           left(v_ip, 100),
           left(v_headers ->> 'user-agent', 300)
      from public.perfiles p
     where p.id = v_uid;

    return v_es_admin;
end;
$$;

comment on function public.registrar_acceso_admin() is
    'CU-34. Registra el intento de ingreso al panel con IP, navegador y hora, y devuelve si la cuenta es de un administrador activo.';


create or replace function public.accesos_admin_recientes(p_limite integer default 10)
returns table (
    email       text,
    resultado   text,
    ip          text,
    navegador   text,
    created_at  timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador ve los accesos al panel.'
              using hint = 'sin_permiso';
    end if;

    return query
    select a.email, a.resultado, a.ip, a.navegador, a.created_at
      from public.accesos_admin a
     order by a.created_at desc
     limit least(greatest(coalesce(p_limite, 10), 1), 100);
end;
$$;

comment on function public.accesos_admin_recientes(integer) is
    'CU-34. Últimos intentos de ingreso al panel, para el Dashboard.';

revoke execute on function public.registrar_acceso_admin()          from public, anon;
revoke execute on function public.accesos_admin_recientes(integer)  from public, anon;
grant  execute on function public.registrar_acceso_admin()          to authenticated;
grant  execute on function public.accesos_admin_recientes(integer)  to authenticated;
