-- ============================================================================
-- Laburito — Migración 0014
-- Sprint 3 · CU-07: leer y guardar la zona de cobertura desde la app
-- ============================================================================
--
-- La tabla `profesional_zona_cobertura` la creó la 0012, con sus políticas.
-- Lo que falta es lo mismo que los pedidos necesitaron en la 0007 y la 0009,
-- por los mismos dos motivos:
--
--   1. **Leerla.** PostgREST serializa `geography` como WKB hexadecimal
--      («0101000020E6100000...»), que en Dart no es una coordenada, y no
--      acepta expresiones SQL en el `select`. La forma idiomática son los
--      *computed fields*: funciones que reciben la fila y se piden como si
--      fueran columnas.
--
--   2. **Escribirla.** Un `geography` no se arma desde un INSERT de PostgREST.
--      Va por RPC, que además es donde vive el orden `(x, y) = (lng, lat)` de
--      PostGIS —una sola vez, en `public.punto()` de la 0007— y donde se
--      valida el rango de la coordenada, que PostGIS normaliza en silencio.
--
-- Es idempotente.
-- ============================================================================


-- ============================================================================
-- 1. Computed fields
-- ============================================================================
--
-- Mismos nombres que los de `pedidos` (0007): son sobrecargas por tipo de
-- argumento, y PostgREST elige la que corresponde a la tabla consultada. El
-- cliente escribe `.select('*, lat, lng')` en los dos casos.
--
-- `stable`, no `immutable`: es lo que PostgREST necesita para invocarlas en un
-- SELECT, y no van a ningún índice.
-- ============================================================================

create or replace function public.lat(z public.profesional_zona_cobertura)
returns double precision
language sql
stable
as $$
    select extensions.st_y(z.centro::extensions.geometry);
$$;

create or replace function public.lng(z public.profesional_zona_cobertura)
returns double precision
language sql
stable
as $$
    select extensions.st_x(z.centro::extensions.geometry);
$$;

comment on function public.lat(public.profesional_zona_cobertura) is
    'Computed field de PostgREST: latitud del centro de la zona (CU-07).';
comment on function public.lng(public.profesional_zona_cobertura) is
    'Computed field de PostgREST: longitud del centro de la zona (CU-07).';

grant execute on function public.lat(public.profesional_zona_cobertura) to authenticated;
grant execute on function public.lng(public.profesional_zona_cobertura) to authenticated;


-- ============================================================================
-- 2. guardar_zona_cobertura
-- ============================================================================
--
-- Una sola función para el alta y para el cambio: la zona es una por
-- Profesional (la clave primaria es `profesional_id`), así que la operación
-- natural es un upsert y la pantalla no tiene que saber si ya había una.
--
-- `security invoker`: las políticas de la 0012 son las que deciden. El
-- `with check` de «zona: gestión propia» ya exige que la fila sea propia y que
-- la cuenta sea de un Profesional activo; la comprobación explícita de
-- `es_profesional_activo()` está para que el error sea una frase en castellano
-- y no un 42501 que no se le muestra a nadie.
--
-- `returns setof` y no el tipo compuesto, por la decisión del 02/09: con
-- `setof`, PostgREST trata el resultado como un recurso y admite
-- `select=*,lat,lng` sobre la llamada, así que guardar y releer son un solo
-- viaje.
--
-- El radio se valida acá además del `check` de la tabla para poder explicarlo:
-- el 23514 de la restricción no dice cuál es el rango.
-- ============================================================================

create or replace function public.guardar_zona_cobertura(
    p_lat           double precision,
    p_lng           double precision,
    p_radio_metros  integer,
    p_direccion     text default null
)
returns setof public.profesional_zona_cobertura
language plpgsql
security invoker
set search_path = public
as $$
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa puede configurar su zona de cobertura'
              using hint = 'sin_permiso';
    end if;

    if p_lat is null or p_lng is null
       or p_lat not between  -90 and  90
       or p_lng not between -180 and 180
    then
        raise exception 'El centro de la zona no es válido. Marcalo de nuevo en el mapa'
              using hint = 'ubicacion_invalida';
    end if;

    if p_radio_metros is null or p_radio_metros not between 1000 and 100000 then
        raise exception 'El radio tiene que estar entre 1 y 100 km'
              using hint = 'radio_invalido';
    end if;

    -- Mismo motivo que en `crear_pedido` para el CTE: `with ... select` es una
    -- consulta común y no depende de qué acepte RETURN QUERY.
    return query
    with guardada as (
        insert into public.profesional_zona_cobertura as z (
            profesional_id, centro, radio_metros, direccion_texto
        )
        values (
            auth.uid(),
            public.punto(p_lat, p_lng),
            p_radio_metros,
            nullif(trim(coalesce(p_direccion, '')), '')
        )
        on conflict (profesional_id) do update
           set centro          = excluded.centro,
               radio_metros    = excluded.radio_metros,
               direccion_texto = excluded.direccion_texto
        returning z.*
    )
    select * from guardada;
end;
$$;

comment on function public.guardar_zona_cobertura(double precision, double precision, integer, text) is
    'CU-07. Alta o cambio de la zona de cobertura del Profesional que llama. Arma el punto con public.punto(lat, lng) y valida rango y radio.';

revoke all on function public.guardar_zona_cobertura(double precision, double precision, integer, text) from public;
grant execute on function public.guardar_zona_cobertura(double precision, double precision, integer, text) to authenticated;


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
-- Cada bloque se envía solo y termina en rollback.
-- PEGAR_PROFESIONAL = Profesional activo · PEGAR_BUSCADOR = un Buscador.
--
--   -- 1. Ida y vuelta de la coordenada, que es el contrato con Dart.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select public.lat(z), public.lng(z), z.radio_metros, z.direccion_texto
--     from public.guardar_zona_cobertura(-34.5136, -58.7645, 5000,
--                                        'José C. Paz') z;
--   -- → -34.5136 | -58.7645 | 5000 | José C. Paz
--   --   Si saliera al revés, la zona estaría en el Índico.
--   rollback;
--
--   -- 2. Guardar dos veces no crea dos zonas: la pisa.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) from public.guardar_zona_cobertura(-34.5136, -58.7645, 5000, 'Una');
--   select radio_metros, direccion_texto
--     from public.guardar_zona_cobertura(-34.6037, -58.3816, 25000, 'Otra');
--   select count(*) from public.profesional_zona_cobertura;   -- → 1
--   rollback;
--
--   -- 3. Los rangos se validan con mensaje propio, no con un 23514.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.guardar_zona_cobertura(190, 400, 5000, null);
--   -- → ERROR: El centro de la zona no es válido  (HINT: ubicacion_invalida)
--   rollback;
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.guardar_zona_cobertura(-34.5136, -58.7645, 300, null);
--   -- → ERROR: El radio tiene que estar entre 1 y 100 km  (HINT: radio_invalido)
--   rollback;
--
--   -- 4. Un Buscador no tiene zona que configurar.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_BUSCADOR","role":"authenticated"}', true);
--   select * from public.guardar_zona_cobertura(-34.5136, -58.7645, 5000, null);
--   -- → ERROR: Solo un Profesional con la cuenta activa...  (HINT: sin_permiso)
--   rollback;
--
--   -- 5. La zona de otro no se lee (RLS de la 0012).
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) from public.guardar_zona_cobertura(-34.5136, -58.7645, 5000, null);
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_BUSCADOR","role":"authenticated"}', true);
--   select count(*) from public.profesional_zona_cobertura;   -- → 0
--   rollback;
--
--   -- 6. El emparejamiento del CU-21 encuentra al Profesional por su zona:
--   --    filtro por el radio máximo (usa el índice) y después exacto.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) from public.guardar_zona_cobertura(-34.5136, -58.7645, 5000, null);
--   reset role;
--   select z.profesional_id,
--          round(extensions.st_distance(z.centro,
--                public.punto(-34.5200, -58.7700))::numeric) as metros
--     from public.profesional_zona_cobertura z
--    where extensions.st_dwithin(z.centro, public.punto(-34.5200, -58.7700), 100000)
--      and extensions.st_dwithin(z.centro, public.punto(-34.5200, -58.7700), z.radio_metros);
--   -- → una fila, con la distancia en metros (menos de 5000)
--   rollback;
--
-- ============================================================================
-- FIN
-- ============================================================================
