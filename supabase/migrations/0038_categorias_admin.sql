-- ============================================================================
-- Laburito — Migración 0038
-- Sprint 6 · CU-37 Gestionar Categorías de Oficios
-- ============================================================================
--
-- El catálogo se cargaba por seed desde la T-02 (Sprint 1). Desde acá lo
-- administra el panel (Figura 3.23):
--
--   categorias_admin()                 todas, con cuántos Profesionales tiene
--   crear_categoria(nombre, icono)     paso 4: el nombre no puede repetirse
--   editar_categoria(id, nombre, icono)
--   cambiar_visibilidad_categoria(id, activa)
--   eliminar_categoria(id)             flujo alterno: con Profesionales o
--                                      pedidos asociados no se borra, se oculta
--
-- La comparación de nombres ignora mayúsculas y tildes: «Plomeria» repite
-- «Plomería». El slug sale del nombre y es el que usan la app y los filtros;
-- editar el nombre no cambia el slug, para no romper lo que ya lo guardó.
-- ============================================================================

create or replace function public.normalizar_nombre(p_texto text)
returns text
language sql
immutable
as $$
    select lower(translate(trim(regexp_replace(coalesce(p_texto, ''), '\s+', ' ', 'g')),
                           'ÁÉÍÓÚÜÑáéíóúüñ', 'AEIOUUNaeiouun'));
$$;

comment on function public.normalizar_nombre(text) is
    'CU-37. Minúsculas, sin tildes y con un solo espacio: la clave para no repetir oficios.';


create or replace function public.categorias_admin()
returns table (
    id              uuid,
    nombre          text,
    slug            text,
    icono           text,
    activa          boolean,
    orden           integer,
    profesionales   bigint,
    pedidos         bigint
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador gestiona las categorías.'
              using hint = 'sin_permiso';
    end if;

    return query
    select c.id, c.nombre, c.slug, c.icono, c.activa, c.orden,
           (select count(*) from public.profesional_categorias pc
              join public.perfiles p on p.id = pc.profesional_id
             where pc.categoria_id = c.id and p.estado = 'activo' and p.deleted_at is null),
           (select count(*) from public.pedidos pe where pe.categoria_id = c.id)
      from public.categorias_oficio c
     order by c.orden, c.nombre;
end;
$$;


create or replace function public.crear_categoria(p_nombre text, p_icono text default null)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
    v_nombre text := trim(regexp_replace(coalesce(p_nombre, ''), '\s+', ' ', 'g'));
    v_slug   text;
    v_id     uuid;
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador gestiona las categorías.'
              using hint = 'sin_permiso';
    end if;

    if length(v_nombre) not between 2 and 40 then
        raise exception 'El nombre del oficio tiene que tener entre 2 y 40 caracteres.'
              using hint = 'nombre_invalido';
    end if;

    if exists (select 1 from public.categorias_oficio
                where public.normalizar_nombre(nombre) = public.normalizar_nombre(v_nombre)) then
        raise exception 'Ya existe una categoría llamada «%».', v_nombre
              using hint = 'categoria_duplicada';
    end if;

    v_slug := trim(both '-' from regexp_replace(public.normalizar_nombre(v_nombre), '[^a-z0-9]+', '-', 'g'));
    if v_slug = '' or exists (select 1 from public.categorias_oficio where slug = v_slug) then
        v_slug := v_slug || '-' || substr(md5(random()::text), 1, 4);
    end if;

    insert into public.categorias_oficio (nombre, slug, icono, orden)
    values (v_nombre, v_slug, nullif(trim(coalesce(p_icono, '')), ''),
            coalesce((select max(orden) from public.categorias_oficio), 0) + 10)
    returning id into v_id;

    return v_id;
end;
$$;


create or replace function public.editar_categoria(p_id uuid, p_nombre text, p_icono text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_nombre text := trim(regexp_replace(coalesce(p_nombre, ''), '\s+', ' ', 'g'));
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador gestiona las categorías.'
              using hint = 'sin_permiso';
    end if;

    if length(v_nombre) not between 2 and 40 then
        raise exception 'El nombre del oficio tiene que tener entre 2 y 40 caracteres.'
              using hint = 'nombre_invalido';
    end if;

    if exists (select 1 from public.categorias_oficio
                where id <> p_id
                  and public.normalizar_nombre(nombre) = public.normalizar_nombre(v_nombre)) then
        raise exception 'Ya existe una categoría llamada «%».', v_nombre
              using hint = 'categoria_duplicada';
    end if;

    update public.categorias_oficio
       set nombre = v_nombre,
           icono  = nullif(trim(coalesce(p_icono, '')), '')
     where id = p_id;

    if not found then
        raise exception 'Esa categoría no existe.' using hint = 'no_encontrada';
    end if;
end;
$$;


create or replace function public.cambiar_visibilidad_categoria(p_id uuid, p_activa boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador gestiona las categorías.'
              using hint = 'sin_permiso';
    end if;

    update public.categorias_oficio set activa = coalesce(p_activa, activa) where id = p_id;

    if not found then
        raise exception 'Esa categoría no existe.' using hint = 'no_encontrada';
    end if;
end;
$$;


create or replace function public.eliminar_categoria(p_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador gestiona las categorías.'
              using hint = 'sin_permiso';
    end if;

    -- Flujo alterno 1.2: con datos asociados se impide el borrado físico.
    if exists (select 1 from public.profesional_categorias where categoria_id = p_id)
       or exists (select 1 from public.pedidos where categoria_id = p_id) then
        raise exception 'Esta categoría tiene profesionales o pedidos asociados. Ocultala en lugar de eliminarla.'
              using hint = 'categoria_en_uso';
    end if;

    delete from public.categorias_oficio where id = p_id;

    if not found then
        raise exception 'Esa categoría no existe.' using hint = 'no_encontrada';
    end if;
end;
$$;


-- Íconos del catálogo inicial, como los de la Figura 3.23.
update public.categorias_oficio c
   set icono = v.icono
  from (values
        ('plomeria', '🔧'), ('electricidad', '⚡'), ('gas', '🔥'), ('albanileria', '🧱'),
        ('pintura', '🎨'), ('carpinteria', '🪚'), ('herreria', '⚒️'), ('cerrajeria', '🔑'),
        ('aire-acondicionado', '❄️'), ('techista', '🏠'), ('durlock', '📐'),
        ('jardineria', '🌿'), ('limpieza', '🧽'), ('fletes-y-mudanzas', '🚚'),
        ('service-de-electrodomesticos', '🔌'), ('redes-e-internet', '📶'),
        ('camaras-de-seguridad', '📹'), ('colocacion-de-pisos', '🪵'), ('vidrieria', '🪟'),
        ('destapaciones', '🚿'), ('impermeabilizacion', '💧'), ('tapiceria', '🛋️')
       ) as v(slug, icono)
 where c.slug = v.slug and c.icono is null;


revoke execute on function public.categorias_admin()                          from public, anon;
revoke execute on function public.crear_categoria(text, text)                 from public, anon;
revoke execute on function public.editar_categoria(uuid, text, text)          from public, anon;
revoke execute on function public.cambiar_visibilidad_categoria(uuid, boolean) from public, anon;
revoke execute on function public.eliminar_categoria(uuid)                    from public, anon;
grant  execute on function public.categorias_admin()                          to authenticated;
grant  execute on function public.crear_categoria(text, text)                 to authenticated;
grant  execute on function public.editar_categoria(uuid, text, text)          to authenticated;
grant  execute on function public.cambiar_visibilidad_categoria(uuid, boolean) to authenticated;
grant  execute on function public.eliminar_categoria(uuid)                    to authenticated;
