-- ============================================================================
-- Laburito — Migración 0011
-- CU-09 · Reparar los Profesionales sin fila en `profesionales`
-- ============================================================================
--
-- El síntoma:
--
--   PostgrestException · code=23503
--   insert or update on table "documentos_verificacion" violates foreign key
--   constraint "documentos_verificacion_profesional_id_fkey"
--   details=Key is not present in table "profesionales".
--
-- Qué significa. `documentos_verificacion.profesional_id` apunta a
-- `profesionales.perfil_id`, así que subir el DNI exige que la fila del
-- Profesional exista. Esa fila la crea **una sola cosa**: el trigger
-- `handle_new_user` de la 0001/0002, cuando el metadata del signUp trae
-- `tipo = 'profesional'`. Si por lo que sea no llegó a crearse —una cuenta
-- creada a mano desde el panel de Supabase, una registrada antes de que el
-- trigger existiera, un borrado parcial de la tabla en desarrollo— el perfil
-- queda como Profesional pero sin su fila, y la carga de documentación falla
-- con el 23503 de arriba.
--
-- Importa que lo arregle una migración y no la app: sobre `profesionales` no
-- hay política de INSERT para el usuario, **a propósito**. Solo hay SELECT y
-- UPDATE (0001, sección de RLS). Es el trigger, que es SECURITY DEFINER, el
-- único que puede crear la fila; darle al cliente permiso de INSERT para que
-- se repare solo abriría la puerta a que cualquiera se cree filas de
-- Profesional.
--
-- Esta migración hace dos cosas: repara lo que ya está roto (sección 1) y
-- evita que el trigger vuelva a dejar el hueco (sección 2).
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Reparación de los datos existentes
-- ----------------------------------------------------------------------------
--
-- Una fila por cada perfil de tipo 'profesional' que no la tenga. El DNI y la
-- descripción se recuperan del metadata del alta, que es de donde salieron la
-- primera vez.
--
-- El `case` del DNI no es paranoia: la columna es `unique`, y si el documento
-- ya figura en otra fila el insert entero fallaría y la reparación no se haría
-- para nadie. Se prefiere una fila con el DNI en null —que la persona puede
-- completar desde su perfil (CU-05)— antes que dejarla sin fila y sin poder
-- validarse.
-- ----------------------------------------------------------------------------

insert into public.profesionales (perfil_id, dni, descripcion)
select p.id,
       case
           when nullif(u.raw_user_meta_data ->> 'dni', '') is null then null
           when exists (
               select 1 from public.profesionales x
                where x.dni = u.raw_user_meta_data ->> 'dni'
           ) then null
           else u.raw_user_meta_data ->> 'dni'
       end,
       nullif(u.raw_user_meta_data ->> 'descripcion', '')
  from public.perfiles p
  join auth.users u on u.id = p.id
 where p.tipo = 'profesional'
   and not exists (
       select 1 from public.profesionales pr where pr.perfil_id = p.id
   )
on conflict (perfil_id) do nothing;


-- ----------------------------------------------------------------------------
-- 2. El trigger deja de poder dejar el hueco
-- ----------------------------------------------------------------------------
--
-- Es la misma función de la 0002 —incluidas las categorías del CU-02— con los
-- `on conflict do nothing` agregados.
--
-- Por qué importan: `handle_new_user` corre en la transacción del signUp, así
-- que si alguno de sus inserts falla, **falla el alta entera**. Un DNI
-- repetido, o un reintento del alta sobre un id que ya tenía perfil, tumbaba
-- el registro con un error de base de datos en la cara del usuario. Con los
-- `on conflict`, el alta sigue adelante y lo que falte se completa después
-- desde el perfil.
-- ----------------------------------------------------------------------------

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
        v_dni := nullif(new.raw_user_meta_data ->> 'dni', '');

        -- Mismo criterio que la sección 1: antes que abortar el alta por un
        -- DNI repetido, entra la fila sin DNI.
        if exists (select 1 from public.profesionales x where x.dni = v_dni)
        then
            v_dni := null;
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

comment on function public.handle_new_user() is
    'CU-01 y CU-02. Crea el perfil al registrarse y, si es Profesional, su fila en profesionales y sus categorías. Idempotente desde la 0011: un conflicto no puede tumbar el alta.';


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
--   -- 1. Diagnóstico: ¿queda algún Profesional sin fila? Tiene que dar 0.
--   select p.id, p.email, p.tipo
--     from public.perfiles p
--    where p.tipo = 'profesional'
--      and not exists (
--          select 1 from public.profesionales pr where pr.perfil_id = p.id
--      );
--   -- → 0 filas
--
--   -- 2. La contracara, por las dudas: ningún Buscador tiene fila de
--   --    Profesional (eso sería otro problema, no este).
--   select pr.perfil_id
--     from public.profesionales pr
--     join public.perfiles p on p.id = pr.perfil_id
--    where p.tipo <> 'profesional';
--   -- → 0 filas
--
--   -- 3. Qué estado quedó para cada Profesional. Los reparados arrancan en
--   --    'sin_documentacion', que es el default y lo que corresponde:
--   select p.email, pr.dni, pr.estado_verificacion
--     from public.profesionales pr
--     join public.perfiles p on p.id = pr.perfil_id
--    order by p.email;
--
--   -- 4. Ahora sí, desde la app: entrar como ese Profesional y subir el DNI.
--   --    Antes de esta migración devolvía 23503; ahora tiene que entrar.
--   select profesional_id, tipo, estado
--     from public.documentos_verificacion
--    order by created_at desc
--    limit 3;
--
-- ============================================================================
-- FIN
-- ============================================================================
