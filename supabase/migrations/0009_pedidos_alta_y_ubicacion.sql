-- ============================================================================
-- Laburito — Migración 0009
-- Sprint 2 · Pedidos: alta y cambio de ubicación del lado del servidor
-- ============================================================================
--
-- Qué resuelve:
--
-- La 0007 dejó resuelta la **lectura** de la coordenada con los computed fields
-- `lat` y `lng`. Esta migración resuelve la **escritura**, que es la mitad
-- incómoda: `pedidos.ubicacion` es `geography(Point,4326)` y PostgREST no
-- construye geometrías. El cliente venía mandando la coordenada como EWKT
-- —«SRID=4326;POINT(lng lat)»—, que la función de entrada de `geography`
-- acepta y que **funciona**. No se cambia porque estuviera roto, sino por tres
-- cosas que el EWKT no puede dar:
--
--   1. **El orden vive en un solo lado.** Con EWKT, la regla «PostGIS toma
--      (x, y) = (lng, lat)» está escrita en Dart, en `Ubicacion.aEwkt()`.
--      Invertirla no falla: guarda el pedido en el hemisferio equivocado y no
--      lo nota nadie hasta que el mapa del CU-16 aparece vacío. Acá el punto lo
--      arma `public.punto(lat, lng)` de la 0007, que ya tiene el orden adentro
--      y es el único lugar donde se escribe.
--   2. **Validación de rango del lado del servidor.** Una latitud de 190 entra
--      como EWKT sin chistar; PostGIS la acepta y la normaliza en silencio.
--   3. **El estado inicial deja de ser elegible.** La política de alta de la
--      0006 no mira `estado`, así que un INSERT directo puede pisar el
--      `default 'publicado'` y crear un pedido que nazca `cerrado`. El guard de
--      la 0008 es solo de UPDATE y no lo ve. Se cierra abajo, en la sección 1.
--
-- Las dos funciones son SECURITY INVOKER a propósito: el INSERT y el UPDATE
-- pasan por las políticas «pedidos: alta del buscador» y «pedidos: edición
-- propia» de la 0006, así que ninguna puede tocar el pedido de otro ni aunque
-- tuviera un bug en la validación de dueño. La RPC agrega reglas, no permisos.
--
-- Las dos devuelven `setof public.pedidos` y no `public.pedidos`. No es
-- cosmético: con `setof`, PostgREST trata el resultado como un recurso y admite
-- `select=*,lat,lng,categorias_oficio(nombre),pedido_fotos(...)` sobre la
-- llamada. Con el tipo compuesto a secas devuelve la fila cruda, sin computed
-- fields ni embeds, y el cliente tiene que releer el pedido en un segundo
-- viaje —que es exactamente lo que hoy hacen `cambiar_estado_pedido` y
-- `renovar_pedido`, y que conviene corregir cuando se las toque de nuevo.
-- ============================================================================

-- ============================================================================
-- 1. Un pedido nace publicado
-- ============================================================================
--
-- Contraparte de INSERT del guard de la 0008, en función y trigger aparte para
-- no reescribir los de aquella migración.
--
-- Respeta la misma compuerta: si `app.transicion_estado` está en 'on', el alta
-- puede elegir el estado. Hoy nadie la usa para insertar —`crear_pedido()` deja
-- que actúe el `default`— pero deja la puerta abierta para un seed o para la
-- carga de datos de prueba, sin necesidad de tocar el trigger.
-- ============================================================================

create or replace function public.pedidos_guard_alta()
returns trigger
language plpgsql
as $$
begin
    if new.estado is distinct from 'publicado'::public.pedido_estado
       and current_setting('app.transicion_estado', true) is distinct from 'on'
    then
        raise exception 'ESTADO_NO_MODIFICABLE_DIRECTAMENTE'
              using hint   = 'estado_no_modificable',
                    detail = format(
                        'Un pedido no puede nacer en estado «%s»: se crea '
                        'publicado y se mueve con cambiar_estado_pedido().',
                        new.estado
                    );
    end if;

    return new;
end;
$$;

comment on function public.pedidos_guard_alta() is
    'Impide que un INSERT elija el estado inicial del pedido. Misma compuerta que el guard de UPDATE de la 0008.';

drop trigger if exists pedidos_guard_alta on public.pedidos;
create trigger pedidos_guard_alta
    before insert on public.pedidos
    for each row execute function public.pedidos_guard_alta();

-- ============================================================================
-- 2. crear_pedido — CU-13
-- ============================================================================
--
-- `p_fecha_vencimiento` llega calculada por el cliente y no como una cantidad
-- de días, para no cambiarle la forma al repositorio que ya existe. Se valida
-- contra `now()` del servidor, así que un reloj adelantado en el navegador no
-- alcanza para publicar un pedido con vigencia infinita.
-- ============================================================================

create or replace function public.crear_pedido(
    p_categoria_id       uuid,
    p_titulo             text,
    p_descripcion        text,
    p_lat                double precision,
    p_lng                double precision,
    p_direccion_texto    text,
    p_fecha_vencimiento  timestamptz,
    p_referencia         text                   default null,
    p_urgencia           public.pedido_urgencia default 'media',
    p_presupuesto        numeric                default null
)
returns setof public.pedidos
language plpgsql
security invoker
set search_path = public
as $$
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    -- Rango de la coordenada. Sin esto, PostGIS normaliza en silencio: una
    -- latitud de 190 no falla, se convierte en otra cosa.
    if p_lat is null or p_lng is null
       or p_lat not between  -90 and  90
       or p_lng not between -180 and 180
    then
        raise exception 'La ubicación del pedido no es válida. Marcala de nuevo en el mapa'
              using hint = 'ubicacion_invalida';
    end if;

    if nullif(trim(coalesce(p_direccion_texto, '')), '') is null then
        raise exception 'Falta la dirección del pedido'
              using hint = 'ubicacion_invalida';
    end if;

    if p_fecha_vencimiento is null or p_fecha_vencimiento <= now() then
        raise exception 'La fecha de vencimiento tiene que ser posterior a hoy'
              using hint = 'datos_invalidos';
    end if;

    -- `estado` no se pasa: lo pone el default y lo custodia pedidos_guard_alta.
    --
    -- El INSERT va adentro de un CTE y no como `return query insert ...`:
    -- envuelto en un `with ... select` es una consulta común y no depende de
    -- que la versión de plpgsql acepte una sentencia que escribe detrás de un
    -- RETURN QUERY. Cuesta nada y no hay forma de probarlo acá.
    return query
    with nuevo as (
        insert into public.pedidos (
            buscador_id,
            categoria_id,
            titulo,
            descripcion,
            urgencia,
            ubicacion,
            direccion_texto,
            referencia_ubicacion,
            presupuesto_estimado,
            fecha_vencimiento
        )
        values (
            auth.uid(),
            p_categoria_id,
            trim(p_titulo),
            trim(p_descripcion),
            coalesce(p_urgencia, 'media'),
            public.punto(p_lat, p_lng),
            trim(p_direccion_texto),
            nullif(trim(coalesce(p_referencia, '')), ''),
            p_presupuesto,
            p_fecha_vencimiento
        )
        returning *
    )
    select * from nuevo;
end;
$$;

comment on function public.crear_pedido(uuid, text, text, double precision, double precision, text, timestamptz, text, public.pedido_urgencia, numeric) is
    'CU-13. Único alta de pedidos: arma el Point 4326 con public.punto(lat, lng) y valida el rango de la coordenada. SECURITY INVOKER: el INSERT sigue pasando por la política de alta de la 0006.';

revoke all on function public.crear_pedido(uuid, text, text, double precision, double precision, text, timestamptz, text, public.pedido_urgencia, numeric) from public;
grant execute on function public.crear_pedido(uuid, text, text, double precision, double precision, text, timestamptz, text, public.pedido_urgencia, numeric) to authenticated;

-- ============================================================================
-- 3. actualizar_ubicacion_pedido — CU-15
-- ============================================================================
--
-- Mover el pedido de lugar es lo mismo que crearlo, en lo que a la geografía
-- respecta: hay que volver a armar el punto. El resto de la edición —título,
-- descripción, categoría, urgencia, presupuesto, vencimiento— sigue yendo por
-- un UPDATE común de PostgREST, que la RLS ya cubre y el guard de la 0008
-- también.
--
-- La restricción de estado es la del CU-15: solo se edita lo que está en la
-- calle o pausado. Un pedido cerrado, cancelado o vencido es historia.
-- ============================================================================

create or replace function public.actualizar_ubicacion_pedido(
    p_pedido_id        uuid,
    p_lat              double precision,
    p_lng              double precision,
    p_direccion_texto  text,
    p_referencia       text default null
)
returns setof public.pedidos
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_estado public.pedido_estado;
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    if p_lat is null or p_lng is null
       or p_lat not between  -90 and  90
       or p_lng not between -180 and 180
    then
        raise exception 'La ubicación del pedido no es válida. Marcala de nuevo en el mapa'
              using hint = 'ubicacion_invalida';
    end if;

    if nullif(trim(coalesce(p_direccion_texto, '')), '') is null then
        raise exception 'Falta la dirección del pedido'
              using hint = 'ubicacion_invalida';
    end if;

    select estado into v_estado
      from public.pedidos
     where id = p_pedido_id
       and buscador_id = auth.uid()
     for update;

    if not found then
        raise exception 'El pedido no existe o no es tuyo'
              using hint = 'sin_permiso';
    end if;

    if v_estado not in ('publicado', 'pausado') then
        raise exception 'Un pedido % no se puede editar', v_estado
              using hint = 'transicion_invalida';
    end if;

    -- Mismo motivo que en crear_pedido para el CTE: `with ... select` es una
    -- consulta común y no depende de qué acepte RETURN QUERY.
    return query
    with movido as (
        update public.pedidos
           set ubicacion            = public.punto(p_lat, p_lng),
               direccion_texto      = trim(p_direccion_texto),
               referencia_ubicacion = nullif(trim(coalesce(p_referencia, '')), '')
         where id = p_pedido_id
        returning *
    )
    select * from movido;
end;
$$;

comment on function public.actualizar_ubicacion_pedido(uuid, double precision, double precision, text, text) is
    'CU-15. Mueve el pedido de lugar rearmando el Point con public.punto(lat, lng). Solo sobre pedidos publicados o pausados.';

revoke all on function public.actualizar_ubicacion_pedido(uuid, double precision, double precision, text, text) from public;
grant execute on function public.actualizar_ubicacion_pedido(uuid, double precision, double precision, text, text) to authenticated;

-- ============================================================================
-- 4. Prueba de aceptación (SQL Editor)
-- ============================================================================
--
-- Las RPC dependen de `auth.uid()`, así que desde el SQL Editor —que corre con
-- un rol que ignora las RLS y sin usuario— no se pueden probar tal cual. Lo que
-- sí se puede probar acá, y es lo que de verdad importa, es **que la coordenada
-- entra y sale igual**. El resto se verifica desde la app.
--
--   -- 4.1 El orden (x, y) = (lng, lat), sobre José C. Paz:
--   select extensions.st_astext(
--              public.punto(-34.5136, -58.7645)::extensions.geometry);
--   -- → POINT(-58.7645 -34.5136)
--   --   Si saliera POINT(-34.5136 -58.7645), el pedido estaría en el Índico.
--
--   -- 4.2 Ida y vuelta completa, que es el contrato con Dart:
--   with p as (select public.punto(-34.5136, -58.7645) as g)
--   select extensions.st_y(g::extensions.geometry) as lat,
--          extensions.st_x(g::extensions.geometry) as lng,
--          abs(extensions.st_y(g::extensions.geometry) - (-34.5136)) < 1e-6 as lat_ok,
--          abs(extensions.st_x(g::extensions.geometry) - (-58.7645)) < 1e-6 as lng_ok
--     from p;
--   -- → -34.5136 | -58.7645 | true | true
--
--   -- 4.3 El EWKT que manda `Ubicacion.aEwkt()` da el mismo punto que la RPC.
--   --     Es la prueba de que el cambio de camino no movió nada de lugar:
--   select extensions.st_equals(
--              ('SRID=4326;POINT(-58.7645000 -34.5136000)'::extensions.geography)::extensions.geometry,
--              (public.punto(-34.5136, -58.7645))::extensions.geometry
--          ) as mismo_punto;
--   -- → true
--
--   -- 4.4 El rango se valida (esto lo hace la RPC, no PostGIS). Sin la
--   --     validación, esto no falla: normaliza y sigue.
--   select extensions.st_astext(public.punto(190, 400)::extensions.geometry);
--   -- → POINT(400 190)  ← basura aceptada. Por eso la RPC valida antes.
--
--   -- 4.5 Un pedido no puede nacer en un estado terminal:
--   insert into public.pedidos (
--       buscador_id, categoria_id, titulo, descripcion, estado,
--       ubicacion, direccion_texto, fecha_vencimiento
--   ) values (
--       'PEGAR_BUSCADOR', 'PEGAR_CATEGORIA',
--       'Pedido de prueba del guard',
--       'Descripción larga para pasar el check de 20 caracteres.',
--       'cerrado',
--       public.punto(-34.5136, -58.7645), 'José C. Paz', now() + interval '7 days'
--   );
--   -- → ERROR: ESTADO_NO_MODIFICABLE_DIRECTAMENTE
--   --   Sacando `estado` de la lista, entra y queda 'publicado'.
--
--   -- 4.6 Las funciones quedaron con la firma esperada:
--   select p.proname, pg_get_function_identity_arguments(p.oid) as args
--     from pg_proc p join pg_namespace n on n.oid = p.pronamespace
--    where n.nspname = 'public'
--      and p.proname in ('crear_pedido', 'actualizar_ubicacion_pedido', 'punto');
--
--   -- 4.7 Desde la app (con sesión de Buscador), la ida y vuelta de verdad:
--   --   crearPedido(...) con lat -34.5136 / lng -58.7645
--   --   → releer el pedido y comprobar que ubicacion.lat y ubicacion.lng
--   --     coinciden con tolerancia 1e-6. Es el mismo caso que cubre
--   --     test/pedidos_geografia_test.dart del lado del cliente.
--
-- ============================================================================
-- FIN
-- ============================================================================
