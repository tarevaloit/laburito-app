-- ============================================================================
-- Laburito — Migración 0015
-- Sprint 3 · CU-12: editar las categorías de oficio en una sola transacción
-- ============================================================================
--
-- Qué resuelve:
--
-- `CategoriasRepository.reemplazar` cambia los oficios del Profesional con dos
-- escrituras sueltas: un DELETE de todas sus filas y un INSERT de las nuevas.
-- Entre una y otra no hay transacción común, así que si el INSERT falla —red
-- cortada, sesión vencida, un slug que ya no existe— **el Profesional queda sin
-- ningún oficio**. Y sin oficios no hay emparejamiento: el CU-21 filtra
-- justamente por categoría, de modo que un guardado a medias lo deja sin
-- recibir una sola alerta, en silencio y sin que él se entere.
--
-- Es la misma familia de problemas que el alta del pedido de la 0009: una
-- operación que el usuario piensa como una sola tiene que ser una sola del lado
-- del servidor.
--
-- Qué NO cambia: la tabla `profesional_categorias` y su política `for all` del
-- dueño existen desde la 0001 y alcanzan. Acá no se crea ni se abre nada; la
-- función corre con los permisos de quien llama (`security invoker`), así que
-- las RLS siguen mandando.
--
-- De paso, tres reglas que hasta hoy vivían solo en el cliente:
--
--   * al menos un oficio —la pantalla ya lo pedía, el servidor no—;
--   * como máximo 5, que es el tope que muestra `SelectorOficios`;
--   * los slugs tienen que existir y estar activos. Antes, un slug inventado
--     se ignoraba en silencio (el `in` del cliente simplemente no lo traía) y
--     el Profesional creía haber guardado algo que no se guardó.
--
-- Es idempotente.
-- ============================================================================

create or replace function public.reemplazar_categorias_oficio(p_slugs text[])
returns setof text
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_slugs      text[];
    v_faltantes  text[];
    v_maximo     constant integer := 5;
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa puede editar sus oficios'
              using hint = 'sin_permiso';
    end if;

    -- Normalizado: sin espacios, sin vacíos y sin repetidos. Mandar dos veces
    -- el mismo slug no es un error del usuario, es una lista mal armada.
    select coalesce(array_agg(distinct trim(s)), '{}')
      into v_slugs
      from unnest(coalesce(p_slugs, '{}')) as s
     where nullif(trim(s), '') is not null;

    if array_length(v_slugs, 1) is null then
        raise exception 'Elegí al menos un oficio: es lo que define qué pedidos te llegan'
              using hint = 'sin_categorias';
    end if;

    if array_length(v_slugs, 1) > v_maximo then
        raise exception 'Podés elegir hasta % oficios', v_maximo
              using hint = 'limite_categorias';
    end if;

    -- Los que no están en el catálogo activo. Se nombran en el mensaje: un
    -- «alguno no existe» no le sirve a nadie para corregir.
    select coalesce(array_agg(s), '{}')
      into v_faltantes
      from unnest(v_slugs) as s
     where not exists (
         select 1 from public.categorias_oficio c
          where c.slug = s and c.activa = true
     );

    if array_length(v_faltantes, 1) is not null then
        raise exception 'Estos oficios ya no están disponibles: %',
              array_to_string(v_faltantes, ', ')
              using hint = 'categoria_inexistente';
    end if;

    -- A partir de acá, todo o nada: las dos escrituras son de la misma
    -- transacción, la de la llamada a la función.
    delete from public.profesional_categorias
     where profesional_id = auth.uid()
       and categoria_id not in (
           select c.id from public.categorias_oficio c
            where c.slug = any (v_slugs)
       );

    insert into public.profesional_categorias (profesional_id, categoria_id)
    select auth.uid(), c.id
      from public.categorias_oficio c
     where c.slug = any (v_slugs)
    on conflict do nothing;

    -- Devuelve lo que quedó guardado, leído de la base y no del argumento: es
    -- lo que la pantalla muestra después de guardar.
    return query
    select c.slug
      from public.profesional_categorias pc
      join public.categorias_oficio c on c.id = pc.categoria_id
     where pc.profesional_id = auth.uid()
     order by c.orden;
end;
$$;

comment on function public.reemplazar_categorias_oficio(text[]) is
    'CU-12. Reemplaza los oficios del Profesional que llama, en una sola transacción. Exige entre 1 y 5 slugs existentes y activos. Devuelve los que quedaron.';

revoke all on function public.reemplazar_categorias_oficio(text[]) from public;
grant execute on function public.reemplazar_categorias_oficio(text[]) to authenticated;


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
-- Cada bloque se envía solo y termina en rollback. Los conteos filtran por
-- profesional a propósito: la política «público: lectura de categorías del
-- profesional» de la 0001 deja ver las de todos, así que un count() pelado
-- suma las de los demás.
-- PEGAR_PROFESIONAL = Profesional activo · PEGAR_BUSCADOR = un Buscador.
--
--   -- 1. Reemplaza de verdad: lo que no está en la lista se va, y el orden
--   --    sale del catálogo.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.reemplazar_categorias_oficio(
--       array['plomeria', 'gas', 'electricidad']);
--   -- → electricidad, gas, plomeria (en el orden del catálogo)
--   select count(*) from public.profesional_categorias
--    where profesional_id = 'PEGAR_PROFESIONAL';                 -- → 3
--   select * from public.reemplazar_categorias_oficio(array['pintura']);
--   -- → pintura
--   select count(*) from public.profesional_categorias
--    where profesional_id = 'PEGAR_PROFESIONAL';                 -- → 1
--   rollback;
--
--   -- 2. Repetidos y espacios no son un error: se normalizan.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) from public.reemplazar_categorias_oficio(
--       array['plomeria', ' plomeria ', 'gas']);
--   -- → 2
--   rollback;
--
--   -- 3. Las tres reglas que antes vivían solo en el cliente.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.reemplazar_categorias_oficio(array[]::text[]);
--   -- → ERROR: Elegí al menos un oficio  (HINT: sin_categorias)
--   rollback;
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.reemplazar_categorias_oficio(
--       array['plomeria','gas','electricidad','pintura','herreria','durlock']);
--   -- → ERROR: Podés elegir hasta 5 oficios  (HINT: limite_categorias)
--   rollback;
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.reemplazar_categorias_oficio(
--       array['plomeria', 'brujeria']);
--   -- → ERROR: Estos oficios ya no están disponibles: brujeria
--   --   (HINT: categoria_inexistente)
--   rollback;
--
--   -- 4. Un error no deja al Profesional sin oficios: es una transacción.
--   --    Esta es la prueba que justifica la migración entera. El `exception`
--   --    del bloque es lo que revierte la llamada fallida sin cortar el resto
--   --    del guion: sin transacción, el DELETE de adentro ya se habría hecho.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) from public.reemplazar_categorias_oficio(
--       array['plomeria', 'gas']);                        -- → 2
--   do $$
--   begin
--       perform public.reemplazar_categorias_oficio(array['brujeria']);
--   exception when others then
--       raise notice 'la llamada falló, como se espera: %', sqlerrm;
--   end;
--   $$;
--   select count(*) from public.profesional_categorias
--    where profesional_id = 'PEGAR_PROFESIONAL';                 -- → 2, intactos
--   rollback;
--
--   -- 5. Un Buscador no tiene oficios que editar.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_BUSCADOR","role":"authenticated"}', true);
--   select * from public.reemplazar_categorias_oficio(array['plomeria']);
--   -- → ERROR: Solo un Profesional con la cuenta activa...  (HINT: sin_permiso)
--   rollback;
--
-- ============================================================================
-- FIN
-- ============================================================================
