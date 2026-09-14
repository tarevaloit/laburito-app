-- ============================================================================
-- Laburito — Migración 0007
-- Sprint 2 · Pedidos: coordenadas legibles desde el cliente
-- ============================================================================
--
-- Problema que resuelve:
--
-- `pedidos.ubicacion` es `geography(Point,4326)`. PostgREST la serializa como
-- WKB hexadecimal —«0101000020E6100000...»— y en Dart eso no es una
-- coordenada: es una cadena que habría que parsear a mano. La vista
-- `pedidos_publicos` de la 0005 devolvía justamente eso en
-- `ubicacion_aproximada`, así que era inservible para la app.
--
-- Tampoco alcanza con pedir la expresión desde el cliente: PostgREST **no
-- acepta expresiones SQL en el `select`**, así que
-- `.select('st_y(ubicacion::geometry) as lat')` no es una opción.
--
-- La forma idiomática son los *computed fields*: funciones que reciben la fila
-- como argumento y que PostgREST expone como si fueran columnas más. Con esto
-- el cliente escribe `.select('*, lat, lng')` y recibe dos números.
--
-- Se declaran `stable` (no `immutable`): no van a un índice, y `stable` es lo
-- que PostgREST necesita para poder invocarlas en un SELECT.
-- ============================================================================

-- ============================================================================
-- 1. Computed fields sobre public.pedidos
-- ============================================================================

create or replace function public.lat(p public.pedidos)
returns double precision
language sql
stable
as $$
    select extensions.st_y(p.ubicacion::extensions.geometry);
$$;

create or replace function public.lng(p public.pedidos)
returns double precision
language sql
stable
as $$
    select extensions.st_x(p.ubicacion::extensions.geometry);
$$;

comment on function public.lat(public.pedidos) is
    'Computed field de PostgREST: latitud de `ubicacion`. Se pide con .select(''*, lat, lng'').';
comment on function public.lng(public.pedidos) is
    'Computed field de PostgREST: longitud de `ubicacion`.';

grant execute on function public.lat(public.pedidos) to anon, authenticated;
grant execute on function public.lng(public.pedidos) to anon, authenticated;

-- ============================================================================
-- 2. Constructor de punto
-- ============================================================================
--
-- Para armar la ubicación desde SQL sin repetir el `st_setsrid(st_makepoint(
-- lng, lat), 4326)` —y sobre todo sin volver a equivocar el orden— en scripts,
-- seeds y en las RPC que vengan.
--
-- El cliente NO la usa: PostgREST no admite llamar funciones dentro de un
-- INSERT, así que el alta manda la ubicación como EWKT
-- («SRID=4326;POINT(lng lat)»), que la función de entrada de geography acepta
-- tal cual. Esa cadena la arma `Ubicacion.aEwkt()` en Dart.
-- ============================================================================

create or replace function public.punto(p_lat double precision, p_lng double precision)
returns extensions.geography
language sql
immutable
as $$
    select extensions.st_setsrid(
               extensions.st_makepoint(p_lng, p_lat),
               4326
           )::extensions.geography;
$$;

comment on function public.punto(double precision, double precision) is
    'Arma un Point 4326 a partir de lat/lng. Ojo con el orden: PostGIS toma (x, y) = (lng, lat).';

-- ============================================================================
-- 3. Vista pública corregida
-- ============================================================================
--
-- Cambia respecto de la 0005: donde había un `geography` ilegible ahora van
-- `lat` y `lng` numéricos, ya redondeados a 3 decimales (~100 m). El redondeo
-- sigue siendo el mismo criterio: alcanza para ubicar el pedido en el mapa y no
-- publica el domicilio. Se suma `renovaciones`, que agregó la 0006.
-- ============================================================================

drop view if exists public.pedidos_publicos;

create view public.pedidos_publicos
with (security_invoker = true)
as
select
    p.id,
    p.categoria_id,
    c.nombre  as categoria_nombre,
    c.slug    as categoria_slug,
    p.titulo,
    p.descripcion,
    p.urgencia,
    round(extensions.st_y(p.ubicacion::extensions.geometry)::numeric, 3) as lat,
    round(extensions.st_x(p.ubicacion::extensions.geometry)::numeric, 3) as lng,
    p.direccion_texto,
    p.presupuesto_estimado,
    p.fecha_publicacion,
    p.fecha_vencimiento,
    p.renovaciones,
    (select count(*) from public.pedido_fotos f where f.pedido_id = p.id) as cantidad_fotos
from public.pedidos p
join public.categorias_oficio c on c.id = p.categoria_id
where p.estado = 'publicado'
  and p.fecha_vencimiento > now();

comment on view public.pedidos_publicos is
    'Pedidos vigentes tal como los ve un Profesional (CU-16). Sin datos de contacto, sin referencia_ubicacion y con la coordenada redondeada a ~100 m.';

grant select on public.pedidos_publicos to anon, authenticated;

-- ============================================================================
-- 4. Prueba de aceptación (SQL Editor)
-- ============================================================================
--
--   -- lat/lng como números, no como WKB:
--   select id, titulo, public.lat(p), public.lng(p)
--     from public.pedidos p limit 5;
--
--   -- y la vista, ya redondeada:
--   select id, titulo, lat, lng, cantidad_fotos from public.pedidos_publicos;
--
--   -- el constructor respeta el orden (x, y) = (lng, lat):
--   select extensions.st_astext(
--              public.punto(-34.6037, -58.3816)::extensions.geometry);
--   -- → POINT(-58.3816 -34.6037)
--
--   -- y el EWKT que manda el cliente entra igual:
--   select extensions.st_astext(
--              'SRID=4326;POINT(-58.3816 -34.6037)'::extensions.geography
--              ::extensions.geometry);
--   -- → POINT(-58.3816 -34.6037)
--
-- ============================================================================
-- FIN
-- ============================================================================
