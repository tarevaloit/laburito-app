-- ============================================================================
-- Laburito — Migración 0041
-- Sprint 6 · CU-46 Moderar Reseñas
-- ============================================================================
--
-- Paso 2: «las reseñas reportadas por los usuarios o detectadas por filtros
-- automáticos». Las dos vías (decisión 7 del plan):
--
--   reportar_resena(id, motivo)    el Profesional reporta una reseña suya
--                                  desde «Mis reseñas»
--   calificaciones_filtro          disparador que marca para revisión las que
--                                  contienen términos de una lista corta
--
-- Y la moderación:
--
--   resenas_a_moderar()            la cola del panel, con autor y destinatario
--   moderar_resena(id, eliminar)   eliminar oculta la reseña (no la borra: la
--                                  columna `oculta` de la 0027), recalcula el
--                                  promedio y avisa al autor; desestimar la
--                                  deja como estaba (flujo alterno 1.2)
-- ============================================================================


-- ============================================================================
-- 1. Filtro automático
-- ============================================================================
--
-- Una lista corta y explícita, no un modelo: el objetivo es que una reseña
-- con insultos no espere a que alguien la reporte. Marca, no oculta: decide
-- el administrador.
-- ============================================================================

create or replace function public.texto_ofensivo(p_texto text)
returns boolean
language sql
immutable
as $$
    select coalesce(public.normalizar_nombre(p_texto), '') ~
        '(^|[^a-z])(idiota|imbecil|estafador|ladron|chorro|boludo|pelotudo|forro|hdp|hijo de puta|mierda|basura|inutil)([^a-z]|$)';
$$;

comment on function public.texto_ofensivo(text) is
    'CU-46. Filtro automático: true si el texto contiene un término de la lista.';

create or replace function public.calificaciones_filtro()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_admin uuid;
begin
    if public.texto_ofensivo(new.comentario) then
        new.revision_automatica := true;
        for v_admin in
            select id from public.perfiles
             where tipo = 'administrador' and estado = 'activo' and deleted_at is null
        loop
            perform public.notificar(v_admin, 'resena_reportada',
                'Reseña marcada por el filtro automático',
                'Contiene términos que conviene revisar.', '/admin/resenas');
        end loop;
    end if;
    return new;
end;
$$;

drop trigger if exists calificaciones_filtro on public.calificaciones;
create trigger calificaciones_filtro
    before insert on public.calificaciones
    for each row execute function public.calificaciones_filtro();

revoke execute on function public.calificaciones_filtro() from public, anon, authenticated;


-- ============================================================================
-- 2. reportar_resena — el Profesional
-- ============================================================================

create or replace function public.reportar_resena(p_calificacion uuid, p_motivo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_motivo text := trim(coalesce(p_motivo, ''));
    v_cal    public.calificaciones;
    v_admin  uuid;
begin
    select * into v_cal from public.calificaciones
     where id = p_calificacion and profesional_id = auth.uid()
       for update;
    if not found then
        raise exception 'Esa reseña no existe o no es tuya.'
              using hint = 'no_encontrada';
    end if;

    if v_cal.oculta or v_cal.moderacion is not null then
        raise exception 'Esa reseña ya fue revisada por el equipo de Laburito.'
              using hint = 'ya_moderada';
    end if;

    if v_cal.reportada_at is not null then
        raise exception 'Ya reportaste esta reseña. La estamos revisando.'
              using hint = 'ya_reportada';
    end if;

    if length(v_motivo) not between 10 and 500 then
        raise exception 'Contanos por qué la reportás en al menos 10 caracteres.'
              using hint = 'motivo_requerido';
    end if;

    update public.calificaciones
       set reportada_at = now(), reporte_motivo = v_motivo
     where id = p_calificacion;

    for v_admin in
        select id from public.perfiles
         where tipo = 'administrador' and estado = 'activo' and deleted_at is null
    loop
        perform public.notificar(v_admin, 'resena_reportada',
            'Un Profesional reportó una reseña', left(v_motivo, 200), '/admin/resenas');
    end loop;
end;
$$;

comment on function public.reportar_resena(uuid, text) is
    'CU-46. El Profesional reporta una reseña recibida para que la revise el administrador.';


-- ============================================================================
-- 3. resenas_a_moderar
-- ============================================================================

create or replace function public.resenas_a_moderar(p_incluir_resueltas boolean default false)
returns table (
    id                   uuid,
    puntaje              smallint,
    comentario           text,
    autor_nombre         text,
    profesional          text,
    pedido_titulo        text,
    reporte_motivo       text,
    reportada_at         timestamptz,
    revision_automatica  boolean,
    moderacion           text,
    created_at           timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador modera reseñas.'
              using hint = 'sin_permiso';
    end if;

    return query
    select c.id, c.puntaje, c.comentario, c.autor_nombre,
           p.nombre || ' ' || p.apellido, pe.titulo,
           c.reporte_motivo, c.reportada_at, c.revision_automatica, c.moderacion, c.created_at
      from public.calificaciones c
      join public.perfiles p on p.id = c.profesional_id
      left join public.pedidos pe on pe.id = c.pedido_id
     where (c.reportada_at is not null or c.revision_automatica)
       and (p_incluir_resueltas or c.moderacion is null)
     order by (c.moderacion is null) desc, coalesce(c.reportada_at, c.created_at) desc;
end;
$$;


-- ============================================================================
-- 4. moderar_resena
-- ============================================================================

create or replace function public.moderar_resena(p_id uuid, p_eliminar boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_cal      public.calificaciones;
    v_buscador uuid;
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador modera reseñas.'
              using hint = 'sin_permiso';
    end if;

    select * into v_cal from public.calificaciones where id = p_id for update;
    if not found then
        raise exception 'Esa reseña no existe.' using hint = 'no_encontrada';
    end if;

    if v_cal.moderacion is not null then
        raise exception 'Esa reseña ya fue moderada.' using hint = 'ya_moderada';
    end if;

    update public.calificaciones
       set moderacion   = case when p_eliminar then 'eliminada' else 'mantenida' end,
           oculta       = oculta or coalesce(p_eliminar, false),
           moderada_por = auth.uid(),
           moderada_at  = now()
     where id = p_id;

    if p_eliminar then
        -- Paso 6: «ajusta el promedio del profesional». Mismo cálculo que
        -- registrar_calificacion (0030): sobre las reseñas no ocultas.
        update public.profesionales pr
           set calificacion_promedio = r.promedio,
               total_calificaciones  = r.total
          from (select round(avg(puntaje)::numeric, 2) as promedio, count(*)::integer as total
                  from public.calificaciones
                 where profesional_id = v_cal.profesional_id and not oculta) r
         where pr.perfil_id = v_cal.profesional_id;

        -- «Notifica al autor»: el Buscador del pedido calificado.
        select buscador_id into v_buscador from public.pedidos where id = v_cal.pedido_id;
        if v_buscador is not null then
            perform public.notificar(v_buscador, 'resena_eliminada',
                'Eliminamos una reseña tuya',
                'Tu reseña no cumplía las normas de la comunidad de Laburito y dejó de mostrarse.',
                '/notificaciones');
        end if;
    end if;

    -- Si la reportó el Profesional, se entera del resultado.
    if v_cal.reportada_at is not null then
        perform public.notificar(v_cal.profesional_id, 'denuncia_resuelta',
            case when p_eliminar then 'Eliminamos la reseña que reportaste'
                 else 'Revisamos la reseña que reportaste' end,
            case when p_eliminar then 'Ya no se muestra y tu promedio se recalculó.'
                 else 'No infringe las normas de la comunidad, así que sigue publicada.' end,
            '/profesional/resenas');
    end if;
end;
$$;

comment on function public.moderar_resena(uuid, boolean) is
    'CU-46. Elimina (oculta y recalcula el promedio) o mantiene una reseña reportada, y avisa a las partes.';


revoke execute on function public.reportar_resena(uuid, text)      from public, anon;
revoke execute on function public.resenas_a_moderar(boolean)       from public, anon;
revoke execute on function public.moderar_resena(uuid, boolean)    from public, anon;
grant  execute on function public.reportar_resena(uuid, text)      to authenticated;
grant  execute on function public.resenas_a_moderar(boolean)       to authenticated;
grant  execute on function public.moderar_resena(uuid, boolean)    to authenticated;
