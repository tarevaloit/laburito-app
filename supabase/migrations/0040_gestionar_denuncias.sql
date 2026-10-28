-- ============================================================================
-- Laburito — Migración 0040
-- Sprint 6 · CU-39 Gestionar Denuncias
-- ============================================================================
--
-- El CU-41 (0033) dejó la bandeja con las denuncias que llegan. Acá se
-- resuelven (Figura 3.22):
--
--   gravedad_denuncia(motivo)   decisión 6 del plan: la gravedad sale del
--                               motivo (estafa y perfil falso, graves)
--   denuncias_admin()           ahora ordena por gravedad y fecha (paso 2) y
--                               trae la reputación del denunciado y sus
--                               denuncias previas
--   detalle_denuncia_admin(id)  paso 4: la trazabilidad del pedido asociado
--   resolver_denuncia(...)      pasos 5 y 6, con la sanción del CU-36 en la
--                               misma transacción (punto de extensión), o el
--                               flujo alterno: desestimar y avisar
-- ============================================================================

create or replace function public.gravedad_denuncia(p_motivo public.denuncia_motivo)
returns smallint
language sql
immutable
as $$
    select case p_motivo
               when 'estafa'                     then 3
               when 'perfil_falso'               then 3
               when 'incumplimiento'             then 2
               when 'comportamiento_inapropiado' then 2
               else 1
           end::smallint;
$$;

comment on function public.gravedad_denuncia(public.denuncia_motivo) is
    'CU-39. 3 grave, 2 media, 1 baja. Ordena la bandeja del panel.';


-- Cambia la forma del resultado: hay que borrarla antes de recrearla.
drop function if exists public.denuncias_admin();

create function public.denuncias_admin()
returns table (
    id                  uuid,
    numero              bigint,
    gravedad            smallint,
    denunciante         text,
    denunciante_tipo    public.tipo_perfil,
    denunciado_id       uuid,
    denunciado          text,
    denunciado_tipo     public.tipo_perfil,
    denunciado_estado   public.estado_cuenta,
    reputacion          numeric,
    denuncias_previas   bigint,
    pedido_id           uuid,
    pedido_titulo       text,
    motivo              public.denuncia_motivo,
    descripcion         text,
    estado              public.denuncia_estado,
    resolucion          text,
    resuelta_at         timestamptz,
    created_at          timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador ve las denuncias.'
              using hint = 'sin_permiso';
    end if;

    return query
    select d.id,
           row_number() over (order by d.created_at) + 1000,
           public.gravedad_denuncia(d.motivo),
           a.nombre || ' ' || a.apellido, a.tipo,
           b.id, b.nombre || ' ' || b.apellido, b.tipo, b.estado,
           pr.calificacion_promedio,
           (select count(*) from public.denuncias o
             where o.denunciado_id = d.denunciado_id and o.id <> d.id
               and o.created_at < d.created_at),
           p.id, p.titulo,
           d.motivo, d.descripcion, d.estado, d.resolucion, d.resuelta_at, d.created_at
      from public.denuncias d
      join public.perfiles a on a.id = d.denunciante_id
      join public.perfiles b on b.id = d.denunciado_id
      left join public.profesionales pr on pr.perfil_id = b.id
      left join public.pedidos p on p.id = d.pedido_id
     order by (d.estado in ('pendiente', 'en_revision')) desc,
              public.gravedad_denuncia(d.motivo) desc,
              d.created_at desc;
end;
$$;

comment on function public.denuncias_admin() is
    'CU-39. Bandeja del panel: abiertas primero, por gravedad y fecha, con la reputación y las denuncias previas del denunciado.';


create or replace function public.detalle_denuncia_admin(p_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_pedido uuid;
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador ve las denuncias.'
              using hint = 'sin_permiso';
    end if;

    select pedido_id into v_pedido from public.denuncias where id = p_id;
    if not found then
        raise exception 'Esa denuncia no existe.' using hint = 'no_encontrada';
    end if;

    if v_pedido is null then
        return jsonb_build_object('pedido', null, 'eventos', '[]'::jsonb);
    end if;

    return jsonb_build_object(
        'pedido', (select jsonb_build_object(
                       'titulo', pe.titulo, 'estado', pe.estado,
                       'publicado', pe.fecha_publicacion, 'vence', pe.fecha_vencimiento)
                     from public.pedidos pe where pe.id = v_pedido),
        'contactos', (select count(*) from public.contactos_desbloqueados c where c.pedido_id = v_pedido),
        'eventos', (select coalesce(jsonb_agg(jsonb_build_object(
                        'de', e.estado_anterior, 'a', e.estado_nuevo,
                        'motivo', e.motivo, 'fecha', e.created_at) order by e.created_at), '[]'::jsonb)
                      from public.pedido_eventos e where e.pedido_id = v_pedido)
    );
end;
$$;

comment on function public.detalle_denuncia_admin(uuid) is
    'CU-39, paso 4. La trazabilidad del pedido asociado: estado, contactos y cada cambio de estado.';


create or replace function public.resolver_denuncia(
    p_id              uuid,
    p_desestimar      boolean,
    p_resolucion      text,
    p_suspender       boolean default false,
    p_dias            integer default null,
    p_apelable        boolean default true
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_den         public.denuncias;
    v_resolucion  text := trim(coalesce(p_resolucion, ''));
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador resuelve denuncias.'
              using hint = 'sin_permiso';
    end if;

    select * into v_den from public.denuncias where id = p_id for update;
    if not found then
        raise exception 'Esa denuncia no existe.' using hint = 'no_encontrada';
    end if;

    if v_den.estado not in ('pendiente', 'en_revision') then
        raise exception 'Esa denuncia ya fue %.', v_den.estado
              using hint = 'ya_resuelta';
    end if;

    if length(v_resolucion) not between 10 and 1000 then
        raise exception 'Documentá la resolución en al menos 10 caracteres.'
              using hint = 'resolucion_requerida';
    end if;

    if coalesce(p_desestimar, false) and coalesce(p_suspender, false) then
        raise exception 'Una denuncia desestimada no lleva sanción.'
              using hint = 'decision_invalida';
    end if;

    -- Punto de extensión: CU-36, en la misma transacción.
    if coalesce(p_suspender, false) then
        perform public.suspender_cuenta(v_den.denunciado_id, v_resolucion, p_dias, p_apelable, v_den.id);
    end if;

    update public.denuncias
       set estado       = case when p_desestimar then 'desestimada' else 'resuelta' end
                          ::public.denuncia_estado,
           resolucion   = v_resolucion,
           resuelta_por = auth.uid(),
           resuelta_at  = now()
     where id = p_id;

    perform public.notificar(
        v_den.denunciante_id,
        'denuncia_resuelta',
        case when p_desestimar then 'Revisamos tu reporte'
             else 'Tomamos medidas sobre tu reporte' end,
        case when p_desestimar
             then 'Después de investigar, no encontramos pruebas suficientes para sancionar. Gracias por avisarnos.'
             else 'Gracias por avisarnos: el reporte se resolvió y aplicamos las medidas que correspondían.' end,
        '/notificaciones'
    );
end;
$$;

comment on function public.resolver_denuncia(uuid, boolean, text, boolean, integer, boolean) is
    'CU-39. Resuelve (con sanción opcional del CU-36) o desestima una denuncia, archiva la resolución y avisa al denunciante.';


revoke execute on function public.denuncias_admin()                                              from public, anon;
revoke execute on function public.detalle_denuncia_admin(uuid)                                   from public, anon;
revoke execute on function public.resolver_denuncia(uuid, boolean, text, boolean, integer, boolean) from public, anon;
grant  execute on function public.denuncias_admin()                                              to authenticated;
grant  execute on function public.detalle_denuncia_admin(uuid)                                   to authenticated;
grant  execute on function public.resolver_denuncia(uuid, boolean, text, boolean, integer, boolean) to authenticated;
