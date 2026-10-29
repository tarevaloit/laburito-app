-- ============================================================================
-- Laburito — Migración 0045
-- CU-02 Registrar Profesional · el DNI repetido traba el alta
-- ============================================================================
--
-- Hasta acá, `handle_new_user` (0011) dejaba entrar al Profesional con el DNI
-- en null si el documento ya lo tenía otra cuenta: se prefería no abortar el
-- alta. El efecto era una cuenta sin DNI y sin aviso, que el administrador
-- veía con «—» en Validaciones (CU-35) y no podía cotejar contra las fotos.
--
-- Ahora el DNI repetido frena el registro, en dos lugares:
--
--   dni_disponible(dni)   la app lo consulta al pasar del paso 1 al 2 del
--                         registro y muestra «Ese DNI ya está en uso»
--   handle_new_user       si igual llega un DNI repetido (dos altas a la vez,
--                         o un cliente que salteó la consulta), aborta el alta
--
-- `dni_disponible` la puede llamar anon: el registro todavía no tiene sesión.
-- Revela si un DNI está registrado, no de quién; es el mismo criterio que el
-- alta ya sigue con el correo («Ya existe una cuenta con ese correo»).
-- ============================================================================


-- ============================================================================
-- 1. dni_disponible
-- ============================================================================

create or replace function public.dni_disponible(p_dni text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select not exists (
        select 1 from public.profesionales
         where dni = regexp_replace(coalesce(p_dni, ''), '[.\s]', '', 'g')
    );
$$;

comment on function public.dni_disponible(text) is
    'CU-02. true si ningún Profesional tiene ese DNI. Acepta puntos y espacios.';

revoke execute on function public.dni_disponible(text) from public;
grant  execute on function public.dni_disponible(text) to anon, authenticated;


-- ============================================================================
-- 2. handle_new_user — el DNI repetido aborta el alta
-- ============================================================================
--
-- Igual a la 0011 salvo el bloque del DNI. La excepción deshace también el
-- insert en `auth.users`: no queda una cuenta a medias.
-- ============================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_tipo  public.tipo_perfil;
    v_slug  text;
    v_dni   text;
begin
    v_tipo := coalesce(
        (new.raw_user_meta_data ->> 'tipo')::public.tipo_perfil,
        'buscador'
    );

    insert into public.perfiles (id, tipo, nombre, apellido, email, telefono)
    values (
        new.id,
        v_tipo,
        coalesce(new.raw_user_meta_data ->> 'nombre',   'Sin nombre'),
        coalesce(new.raw_user_meta_data ->> 'apellido', 'Sin apellido'),
        new.email,
        new.raw_user_meta_data ->> 'telefono'
    )
    on conflict (id) do nothing;

    if v_tipo = 'profesional' then
        v_dni := nullif(regexp_replace(coalesce(new.raw_user_meta_data ->> 'dni', ''),
                                       '[.\s]', '', 'g'), '');

        if v_dni is not null and not public.dni_disponible(v_dni) then
            raise exception 'Ese DNI ya está en uso.'
                  using hint = 'dni_en_uso', errcode = 'unique_violation';
        end if;

        insert into public.profesionales (perfil_id, dni, descripcion)
        values (
            new.id,
            v_dni,
            nullif(new.raw_user_meta_data ->> 'descripcion', '')
        )
        on conflict (perfil_id) do nothing;

        if new.raw_user_meta_data ? 'categorias' then
            for v_slug in
                select jsonb_array_elements_text(new.raw_user_meta_data -> 'categorias')
            loop
                insert into public.profesional_categorias (profesional_id, categoria_id)
                select new.id, c.id
                  from public.categorias_oficio c
                 where c.slug = v_slug
                on conflict do nothing;
            end loop;
        end if;
    end if;

    return new;
end;
$$;
