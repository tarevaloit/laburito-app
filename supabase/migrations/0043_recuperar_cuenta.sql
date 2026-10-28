-- ============================================================================
-- Laburito — Migración 0043
-- Sprint 6 · CU-49 Recuperar Cuenta Bloqueada
-- ============================================================================
--
--   apelar_sancion(descargo)        pasos 3 a 6: adjunta el descargo al
--                                   historial y devuelve el número de trámite
--   revisar_mi_suspension()         se amplía: devuelve también la apelación
--                                   en curso, para no ofrecer apelar dos veces
--   apelaciones_admin()             la bandeja del panel (punto de extensión
--                                   CU-39: vive en la sección Denuncias)
--   resolver_apelacion(...)         aceptar levanta la sanción (0039);
--                                   rechazar la mantiene; los dos avisan
--
-- Flujo alterno 1.1: una sanción inapelable no acepta descargo y la app
-- muestra el correo de soporte legal.
-- ============================================================================


create or replace function public.apelar_sancion(p_descargo text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid      uuid := auth.uid();
    v_descargo text := trim(coalesce(p_descargo, ''));
    v_sancion  public.sanciones;
    v_numero   bigint;
    v_admin    uuid;
begin
    select * into v_sancion from public.sanciones
     where perfil_id = v_uid and levantada_at is null;
    if not found then
        raise exception 'Tu cuenta no tiene una suspensión vigente.'
              using hint = 'sin_sancion';
    end if;

    if not v_sancion.apelable then
        raise exception 'Esta sanción no admite apelación. Escribinos a legales@laburito.com.ar.'
              using hint = 'inapelable';
    end if;

    if length(v_descargo) not between 20 and 1000 then
        raise exception 'Contanos tu descargo en al menos 20 caracteres.'
              using hint = 'descargo_corto';
    end if;

    begin
        insert into public.apelaciones (sancion_id, perfil_id, descargo)
        values (v_sancion.id, v_uid, v_descargo)
        returning numero into v_numero;
    exception when unique_violation then
        raise exception 'Ya tenés una apelación en revisión para esta sanción.'
              using hint = 'apelacion_abierta';
    end;

    for v_admin in
        select id from public.perfiles
         where tipo = 'administrador' and estado = 'activo' and deleted_at is null
    loop
        perform public.notificar(v_admin, 'apelacion_recibida',
            'Nueva apelación #' || v_numero,
            left(v_descargo, 200), '/admin/denuncias?vista=apelaciones');
    end loop;

    return v_numero;
end;
$$;

comment on function public.apelar_sancion(text) is
    'CU-49. Registra el descargo de un usuario suspendido y devuelve el número de trámite.';


-- La 0039 devolvía la sanción; ahora también la apelación en curso o la última
-- resuelta, para que la pantalla muestre el trámite en vez del botón.
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
    v_apel     public.apelaciones;
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

    select * into v_apel from public.apelaciones
     where sancion_id = v_sancion.id
     order by created_at desc
     limit 1;

    return jsonb_build_object(
        'estado', 'suspendido',
        'sancion', case when v_sancion.id is null then null else jsonb_build_object(
            'id', v_sancion.id,
            'motivo', v_sancion.motivo,
            'permanente', v_sancion.permanente,
            'hasta', v_sancion.hasta,
            'apelable', v_sancion.apelable,
            'fecha', v_sancion.created_at) end,
        'apelacion', case when v_apel.id is null then null else jsonb_build_object(
            'numero', v_apel.numero,
            'estado', v_apel.estado,
            'respuesta', v_apel.respuesta,
            'fecha', v_apel.created_at) end
    );
end;
$$;


create or replace function public.apelaciones_admin()
returns table (
    id                uuid,
    numero            bigint,
    usuario_id        uuid,
    usuario           text,
    usuario_tipo      public.tipo_perfil,
    sancion_motivo    text,
    permanente        boolean,
    hasta             timestamptz,
    descargo          text,
    estado            text,
    respuesta         text,
    created_at        timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador ve las apelaciones.'
              using hint = 'sin_permiso';
    end if;

    return query
    select a.id, a.numero, p.id, p.nombre || ' ' || p.apellido, p.tipo,
           s.motivo, s.permanente, s.hasta, a.descargo, a.estado, a.respuesta, a.created_at
      from public.apelaciones a
      join public.sanciones s on s.id = a.sancion_id
      join public.perfiles p on p.id = a.perfil_id
     order by (a.estado = 'pendiente') desc, a.created_at desc;
end;
$$;


create or replace function public.resolver_apelacion(p_id uuid, p_aceptar boolean, p_respuesta text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_apel      public.apelaciones;
    v_respuesta text := trim(coalesce(p_respuesta, ''));
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador resuelve apelaciones.'
              using hint = 'sin_permiso';
    end if;

    select * into v_apel from public.apelaciones where id = p_id for update;
    if not found then
        raise exception 'Esa apelación no existe.' using hint = 'no_encontrada';
    end if;

    if v_apel.estado <> 'pendiente' then
        raise exception 'Esa apelación ya fue resuelta.' using hint = 'ya_resuelta';
    end if;

    if length(v_respuesta) not between 10 and 500 then
        raise exception 'Escribí la respuesta en al menos 10 caracteres: la lee el usuario.'
              using hint = 'respuesta_requerida';
    end if;

    update public.apelaciones
       set estado       = case when p_aceptar then 'aceptada' else 'rechazada' end,
           respuesta    = v_respuesta,
           resuelta_por = auth.uid(),
           resuelta_at  = now()
     where id = p_id;

    if p_aceptar then
        -- Reactiva la cuenta y deja su propio aviso de «cuenta activa».
        perform public.levantar_sancion_interna(
            v_apel.sancion_id, 'Apelación #' || v_apel.numero || ' aceptada: ' || v_respuesta);
    else
        perform public.notificar(v_apel.perfil_id, 'apelacion_resuelta',
            'Revisamos tu apelación #' || v_apel.numero,
            'La sanción se mantiene. ' || v_respuesta, '/cuenta-suspendida');
    end if;
end;
$$;

comment on function public.resolver_apelacion(uuid, boolean, text) is
    'CU-49. Acepta (levanta la sanción) o rechaza una apelación con su respuesta.';


revoke execute on function public.apelar_sancion(text)                       from public, anon;
revoke execute on function public.apelaciones_admin()                        from public, anon;
revoke execute on function public.resolver_apelacion(uuid, boolean, text)    from public, anon;
grant  execute on function public.apelar_sancion(text)                       to authenticated;
grant  execute on function public.apelaciones_admin()                        to authenticated;
grant  execute on function public.resolver_apelacion(uuid, boolean, text)    to authenticated;
