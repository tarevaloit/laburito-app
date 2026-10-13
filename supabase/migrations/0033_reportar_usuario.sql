-- ============================================================================
-- Laburito — Migración 0033
-- Sprint 5 · CU-41 Reportar Usuario
-- ============================================================================
--
-- `reportar_usuario(...)` registra la denuncia; el disparador de la 0031
-- avisa a los administradores (paso 6: «genera una alerta en el Panel del
-- Administrador»). `denuncias_admin()` es la lista de esa sección; resolverlas
-- es el CU-39 del Sprint 6.
--
-- **A quién se denuncia sin exponer ids.** La app no conoce el uuid de la
-- otra persona, y no tiene por qué:
--
--   * el Buscador denuncia a un Profesional desde su perfil público, por el
--     **slug** del enlace (el CU-25 decidió que no ve a los interesados);
--   * el Profesional denuncia al Buscador desde el detalle de un **pedido**
--     que puede ver o cuyo contacto desbloqueó.
--
-- Reglas: cuenta activa; motivo obligatorio (flujo alterno 1.1); descripción
-- de 10 a 1000 caracteres; no a uno mismo; una denuncia abierta por par.
-- ============================================================================

create or replace function public.reportar_usuario(
    p_motivo      public.denuncia_motivo,
    p_descripcion text,
    p_slug        text default null,
    p_pedido      uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid         uuid := auth.uid();
    v_denunciado  uuid;
    v_pedido      uuid;
    v_descripcion text := trim(coalesce(p_descripcion, ''));
    v_id          uuid;
begin
    if not exists (select 1 from public.perfiles
                    where id = v_uid and estado = 'activo' and deleted_at is null) then
        raise exception 'Necesitás una cuenta activa para reportar a un usuario.'
              using hint = 'sin_permiso';
    end if;

    if p_motivo is null then
        raise exception 'Elegí el motivo del reporte.'
              using hint = 'motivo_requerido';
    end if;

    if length(v_descripcion) < 10 then
        raise exception 'Contanos qué pasó en al menos 10 caracteres.'
              using hint = 'descripcion_corta';
    end if;

    if length(v_descripcion) > 1000 then
        raise exception 'La descripción puede tener hasta 1000 caracteres.'
              using hint = 'descripcion_larga';
    end if;

    if p_slug is not null then
        select profesional_id into v_denunciado
          from public.perfiles_publicos where slug = lower(trim(p_slug));
    elsif p_pedido is not null then
        select p.buscador_id, p.id into v_denunciado, v_pedido
          from public.pedidos p
         where p.id = p_pedido
           and (public.es_pedido_visible(p.id)
                or exists (select 1 from public.contactos_desbloqueados c
                            where c.pedido_id = p.id and c.profesional_id = v_uid));
    end if;

    if v_denunciado is null then
        raise exception 'No encontramos al usuario que querés reportar.'
              using hint = 'no_encontrado';
    end if;

    if v_denunciado = v_uid then
        raise exception 'No podés reportarte a vos mismo.'
              using hint = 'autodenuncia';
    end if;

    begin
        insert into public.denuncias (denunciante_id, denunciado_id, pedido_id, motivo, descripcion)
        values (v_uid, v_denunciado, v_pedido, p_motivo, v_descripcion)
        returning id into v_id;
    exception when unique_violation then
        raise exception 'Ya tenés un reporte abierto sobre este usuario. Lo estamos revisando.'
              using hint = 'denuncia_abierta';
    end;

    return v_id;
end;
$$;

comment on function public.reportar_usuario(public.denuncia_motivo, text, text, uuid) is
    'CU-41. Registra una denuncia contra el Profesional de un slug o el Buscador de un pedido. Avisa a los administradores (0031).';


create or replace function public.denuncias_admin()
returns table (
    id                uuid,
    denunciante       text,
    denunciante_tipo  public.tipo_perfil,
    denunciado        text,
    denunciado_tipo   public.tipo_perfil,
    pedido_titulo     text,
    motivo            public.denuncia_motivo,
    descripcion       text,
    estado            public.denuncia_estado,
    created_at        timestamptz
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
           a.nombre || ' ' || a.apellido, a.tipo,
           b.nombre || ' ' || b.apellido, b.tipo,
           p.titulo,
           d.motivo, d.descripcion, d.estado, d.created_at
      from public.denuncias d
      join public.perfiles a on a.id = d.denunciante_id
      join public.perfiles b on b.id = d.denunciado_id
      left join public.pedidos p on p.id = d.pedido_id
     order by (d.estado = 'pendiente') desc, d.created_at desc;
end;
$$;

comment on function public.denuncias_admin() is
    'CU-41. Denuncias para el panel del administrador, las pendientes primero. La resolución es del CU-39.';

revoke execute on function public.reportar_usuario(public.denuncia_motivo, text, text, uuid) from public, anon;
revoke execute on function public.denuncias_admin()                                          from public, anon;
grant  execute on function public.reportar_usuario(public.denuncia_motivo, text, text, uuid) to authenticated;
grant  execute on function public.denuncias_admin()                                          to authenticated;
