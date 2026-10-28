-- ============================================================================
-- Laburito — Migración 0039
-- Sprint 6 · CU-36 Suspender Cuenta
-- ============================================================================
--
--   buscar_usuarios_admin(texto, tipo)   paso 1: el buscador general del panel
--   detalle_usuario_admin(id)            paso 2: pedidos, denuncias,
--                                        calificaciones y sanciones previas
--   suspender_cuenta(...)                pasos 3 a 6
--   levantar_sancion(sancion, motivo)    la reactivación (la usa el CU-49)
--   revisar_mi_suspension()              la consulta el login: levanta sola
--                                        una sanción temporal vencida
--
-- **Qué hace la suspensión** (paso 6 y poscondición): cambia el estado de la
-- cuenta, cierra las sesiones activas (borra las de `auth.sessions`, con lo
-- que el refresh token deja de servir), pausa los pedidos publicados del
-- usuario para que «deje de figurar en búsquedas» y le deja el aviso. Un
-- Profesional suspendido ya queda afuera del tablero, de las alertas y del
-- perfil público, porque todas esas funciones exigen `estado = 'activo'`.
--
-- Flujo alterno 1.1: no hay rol «SuperAdmin» (decisión 2 del plan), así que
-- sancionar a otro administrador se bloquea siempre.
-- ============================================================================


-- ============================================================================
-- 1. buscar_usuarios_admin
-- ============================================================================

create or replace function public.buscar_usuarios_admin(
    p_texto  text default null,
    p_tipo   public.tipo_perfil default null
)
returns table (
    id          uuid,
    nombre      text,
    apellido    text,
    email       text,
    tipo        public.tipo_perfil,
    estado      public.estado_cuenta,
    created_at  timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_texto text := nullif(trim(coalesce(p_texto, '')), '');
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador busca usuarios.'
              using hint = 'sin_permiso';
    end if;

    return query
    select p.id, p.nombre, p.apellido, p.email, p.tipo, p.estado, p.created_at
      from public.perfiles p
     where p.deleted_at is null
       and (p_tipo is null or p.tipo = p_tipo)
       and (v_texto is null
            or public.normalizar_nombre(p.nombre || ' ' || p.apellido)
                   like '%' || public.normalizar_nombre(v_texto) || '%'
            or p.email ilike '%' || v_texto || '%')
     order by (p.estado = 'suspendido') desc, p.created_at desc
     limit 50;
end;
$$;


-- ============================================================================
-- 2. detalle_usuario_admin
-- ============================================================================

create or replace function public.detalle_usuario_admin(p_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_perfil public.perfiles;
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador ve el detalle de un usuario.'
              using hint = 'sin_permiso';
    end if;

    select * into v_perfil from public.perfiles where id = p_id;
    if not found then
        raise exception 'Ese usuario no existe.' using hint = 'no_encontrado';
    end if;

    return jsonb_build_object(
        'id', v_perfil.id,
        'nombre', v_perfil.nombre,
        'apellido', v_perfil.apellido,
        'email', v_perfil.email,
        'telefono', v_perfil.telefono,
        'tipo', v_perfil.tipo,
        'estado', v_perfil.estado,
        'created_at', v_perfil.created_at,
        'profesional', (
            select jsonb_build_object(
                       'estado_verificacion', pr.estado_verificacion,
                       'calificacion_promedio', pr.calificacion_promedio,
                       'total_calificaciones', pr.total_calificaciones,
                       'contactos', (select count(*) from public.contactos_desbloqueados c
                                      where c.profesional_id = pr.perfil_id))
              from public.profesionales pr where pr.perfil_id = p_id
        ),
        'pedidos', (
            select coalesce(jsonb_agg(jsonb_build_object(
                       'titulo', x.titulo, 'estado', x.estado,
                       'fecha', x.fecha_publicacion) order by x.fecha_publicacion desc), '[]'::jsonb)
              from (select titulo, estado, fecha_publicacion from public.pedidos
                     where buscador_id = p_id order by fecha_publicacion desc limit 5) x
        ),
        'total_pedidos', (select count(*) from public.pedidos where buscador_id = p_id),
        'denuncias_recibidas', (
            select coalesce(jsonb_agg(jsonb_build_object(
                       'motivo', d.motivo, 'estado', d.estado,
                       'descripcion', d.descripcion, 'fecha', d.created_at) order by d.created_at desc), '[]'::jsonb)
              from public.denuncias d where d.denunciado_id = p_id
        ),
        'denuncias_hechas', (select count(*) from public.denuncias where denunciante_id = p_id),
        'calificaciones', (
            select coalesce(jsonb_agg(jsonb_build_object(
                       'puntaje', x.puntaje, 'comentario', x.comentario,
                       'autor', x.autor_nombre, 'fecha', x.created_at) order by x.created_at desc), '[]'::jsonb)
              from (select puntaje, comentario, autor_nombre, created_at from public.calificaciones
                     where profesional_id = p_id and not oculta
                     order by created_at desc limit 5) x
        ),
        'sanciones', (
            select coalesce(jsonb_agg(jsonb_build_object(
                       'id', s.id, 'motivo', s.motivo, 'permanente', s.permanente,
                       'hasta', s.hasta, 'apelable', s.apelable,
                       'levantada_at', s.levantada_at, 'fecha', s.created_at) order by s.created_at desc), '[]'::jsonb)
              from public.sanciones s where s.perfil_id = p_id
        )
    );
end;
$$;


-- ============================================================================
-- 3. suspender_cuenta
-- ============================================================================

create or replace function public.suspender_cuenta(
    p_perfil    uuid,
    p_motivo    text,
    p_dias      integer default null,
    p_apelable  boolean default true,
    p_denuncia  uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
    v_motivo  text := trim(coalesce(p_motivo, ''));
    v_perfil  public.perfiles;
    v_hasta   timestamptz;
    v_id      uuid;
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador suspende cuentas.'
              using hint = 'sin_permiso';
    end if;

    select * into v_perfil from public.perfiles where id = p_perfil for update;
    if not found or v_perfil.deleted_at is not null then
        raise exception 'Ese usuario no existe o está dado de baja.'
              using hint = 'no_encontrado';
    end if;

    if v_perfil.tipo = 'administrador' then
        raise exception 'Se requieren permisos de SuperAdmin para sancionar a otro administrador.'
              using hint = 'sancion_a_par';
    end if;

    if v_perfil.estado = 'suspendido' then
        raise exception 'La cuenta ya está suspendida.'
              using hint = 'ya_suspendida';
    end if;

    if length(v_motivo) not between 10 and 500 then
        raise exception 'Redactá el motivo formal de la sanción en al menos 10 caracteres.'
              using hint = 'motivo_requerido';
    end if;

    if p_dias is not null and p_dias not between 1 and 365 then
        raise exception 'Una suspensión temporal dura entre 1 y 365 días.'
              using hint = 'plazo_invalido';
    end if;

    v_hasta := case when p_dias is null then null else now() + p_dias * interval '1 day' end;

    insert into public.sanciones (perfil_id, admin_id, denuncia_id, motivo, permanente, hasta, apelable)
    values (p_perfil, auth.uid(), p_denuncia, v_motivo, p_dias is null, v_hasta, coalesce(p_apelable, true))
    returning id into v_id;

    update public.perfiles set estado = 'suspendido' where id = p_perfil;

    -- «Deja de figurar en búsquedas»: los pedidos publicados pasan a pausados,
    -- con la compuerta del guard de la 0008. El disparador de la 0005 deja el
    -- evento con el administrador como actor. El Buscador los reanuda si se
    -- levanta la sanción.
    perform set_config('app.transicion_estado', 'on', true);
    update public.pedidos set estado = 'pausado'
     where buscador_id = p_perfil and estado = 'publicado';
    perform set_config('app.transicion_estado', 'off', true);

    -- Paso 6: «cierra las sesiones activas». Sin sesión no hay refresh token
    -- que renovar; el token de acceso vigente vence solo y, mientras tanto, la
    -- RLS ya ve la cuenta suspendida.
    delete from auth.sessions where user_id = p_perfil;

    perform public.notificar(
        p_perfil,
        'cuenta_suspendida',
        'Tu cuenta fue suspendida',
        'Motivo: ' || v_motivo || '.'
            || case when v_hasta is null then ' Es una suspensión permanente.'
                    else ' Vence el ' || to_char(v_hasta at time zone 'America/Argentina/Buenos_Aires', 'DD/MM/YYYY') || '.' end,
        '/cuenta-suspendida'
    );

    return v_id;
end;
$$;

comment on function public.suspender_cuenta(uuid, text, integer, boolean, uuid) is
    'CU-36. Suspende la cuenta (temporal con p_dias, permanente sin), cierra sus sesiones y pausa sus pedidos publicados.';


-- ============================================================================
-- 4. levantar_sancion
-- ============================================================================

create or replace function public.levantar_sancion_interna(p_sancion uuid, p_motivo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_perfil uuid;
begin
    update public.sanciones
       set levantada_at = now(), levantada_motivo = left(p_motivo, 500)
     where id = p_sancion and levantada_at is null
    returning perfil_id into v_perfil;

    if v_perfil is null then
        raise exception 'Esa sanción no existe o ya se levantó.'
              using hint = 'no_encontrada';
    end if;

    update public.perfiles set estado = 'activo'
     where id = v_perfil and estado = 'suspendido' and deleted_at is null;

    perform public.notificar(
        v_perfil,
        'cuenta_reactivada',
        'Tu cuenta está activa otra vez',
        'Si tenías pedidos publicados, quedaron pausados: reanudalos desde Mis pedidos.',
        '/home'
    );
end;
$$;

comment on function public.levantar_sancion_interna(uuid, text) is
    'CU-36 / CU-49. Levanta una sanción y reactiva la cuenta. Solo la llaman otras funciones.';

revoke execute on function public.levantar_sancion_interna(uuid, text) from public, anon, authenticated;


create or replace function public.levantar_sancion(p_sancion uuid, p_motivo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador levanta sanciones.'
              using hint = 'sin_permiso';
    end if;

    if length(trim(coalesce(p_motivo, ''))) < 10 then
        raise exception 'Explicá por qué se levanta la sanción en al menos 10 caracteres.'
              using hint = 'motivo_requerido';
    end if;

    perform public.levantar_sancion_interna(p_sancion, trim(p_motivo));
end;
$$;


-- ============================================================================
-- 5. revisar_mi_suspension — el login de una cuenta suspendida
-- ============================================================================
--
-- La llama la app al iniciar sesión con una cuenta suspendida. Si la sanción
-- era temporal y ya venció, la levanta y devuelve `activo`: la persona entra
-- como siempre. Si sigue vigente, devuelve el motivo, la fecha de fin y si se
-- puede apelar (CU-49).
-- ============================================================================

create or replace function public.revisar_mi_suspension()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid      uuid := auth.uid();
    v_estado   public.estado_cuenta;
    v_sancion  public.sanciones;
begin
    select estado into v_estado from public.perfiles where id = v_uid;
    if v_estado is distinct from 'suspendido' then
        return jsonb_build_object('estado', v_estado);
    end if;

    select * into v_sancion from public.sanciones
     where perfil_id = v_uid and levantada_at is null;

    if found and not v_sancion.permanente and v_sancion.hasta <= now() then
        perform public.levantar_sancion_interna(v_sancion.id, 'Venció el plazo de la suspensión.');
        return jsonb_build_object('estado', 'activo');
    end if;

    return jsonb_build_object(
        'estado', 'suspendido',
        'sancion', case when v_sancion.id is null then null else jsonb_build_object(
            'id', v_sancion.id,
            'motivo', v_sancion.motivo,
            'permanente', v_sancion.permanente,
            'hasta', v_sancion.hasta,
            'apelable', v_sancion.apelable,
            'fecha', v_sancion.created_at) end
    );
end;
$$;

comment on function public.revisar_mi_suspension() is
    'CU-36 / CU-49. Estado de la cuenta propia: levanta una suspensión temporal vencida o devuelve la sanción vigente.';


revoke execute on function public.buscar_usuarios_admin(text, public.tipo_perfil)              from public, anon;
revoke execute on function public.detalle_usuario_admin(uuid)                                  from public, anon;
revoke execute on function public.suspender_cuenta(uuid, text, integer, boolean, uuid)         from public, anon;
revoke execute on function public.levantar_sancion(uuid, text)                                 from public, anon;
revoke execute on function public.revisar_mi_suspension()                                      from public, anon;
grant  execute on function public.buscar_usuarios_admin(text, public.tipo_perfil)              to authenticated;
grant  execute on function public.detalle_usuario_admin(uuid)                                  to authenticated;
grant  execute on function public.suspender_cuenta(uuid, text, integer, boolean, uuid)         to authenticated;
grant  execute on function public.levantar_sancion(uuid, text)                                 to authenticated;
grant  execute on function public.revisar_mi_suspension()                                      to authenticated;
