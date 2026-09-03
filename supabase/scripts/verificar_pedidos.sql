-- ============================================================================
-- Laburito — Diagnóstico del estado de las migraciones de pedidos
-- ============================================================================
--
-- Pegá esto entero en el SQL Editor de Supabase. No modifica nada: solo mira.
-- Cada bloque devuelve su propio resultado; en el editor de Supabase se ve el
-- de la última consulta, así que conviene correrlos de a uno (seleccionás el
-- bloque y Ctrl+Enter) o mirar las pestañas de resultados.
--
-- Sirve para saber qué migraciones están realmente aplicadas cuando se
-- perdió la cuenta, que es lo habitual trabajando desde el SQL Editor.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. ¿Está la 0005? (tablas, enums, trigger de auditoría)
-- ----------------------------------------------------------------------------
select
    to_regclass('public.pedidos')        is not null as tabla_pedidos,
    to_regclass('public.pedido_fotos')   is not null as tabla_fotos,
    to_regclass('public.pedido_eventos') is not null as tabla_eventos,
    exists (select 1 from pg_type where typname = 'pedido_estado')   as enum_estado,
    exists (select 1 from pg_type where typname = 'pedido_urgencia') as enum_urgencia,
    exists (select 1 from pg_trigger  where tgname = 'pedidos_registrar_evento') as trigger_auditoria,
    exists (select 1 from pg_trigger  where tgname = 'pedido_fotos_limite')      as trigger_5_fotos;
-- Se espera: todo true.


-- ----------------------------------------------------------------------------
-- 2. ¿Está la 0006? (columna renovaciones, RPC, bucket)
-- ----------------------------------------------------------------------------
select
    exists (
        select 1 from information_schema.columns
         where table_schema = 'public'
           and table_name   = 'pedidos'
           and column_name  = 'renovaciones'
    ) as columna_renovaciones,
    to_regprocedure('public.cambiar_estado_pedido(uuid, public.pedido_estado, text)')
        is not null as rpc_cambiar_estado,
    to_regprocedure('public.renovar_pedido(uuid, integer)')
        is not null as rpc_renovar,
    to_regprocedure('public.marcar_pedidos_vencidos()')
        is not null as rpc_vencimientos,
    exists (select 1 from storage.buckets where id = 'pedidos') as bucket_pedidos;
-- Se espera: todo true.


-- ----------------------------------------------------------------------------
-- 3. ¿Es la 0006 **con** los hints, o la versión vieja?
-- ----------------------------------------------------------------------------
--
-- Este es el punto que importa. Las excepciones de plpgsql llegan todas como
-- `P0001`; el `hint` es lo que le permite a PedidoException distinguir una
-- transición inválida de un límite de renovaciones. Sin hints la app anda,
-- pero pierde los casos tipados y todo cae en CasoPedido.desconocido.
-- ----------------------------------------------------------------------------
select
    p.proname,
    prosrc like '%using hint%' as tiene_hints
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public'
   and p.proname in ('cambiar_estado_pedido', 'renovar_pedido')
 order by p.proname;
-- Se espera: tiene_hints = true en las dos.
-- Si alguna da false → volvé a correr 0006_pedidos_rls.sql entera.


-- ----------------------------------------------------------------------------
-- 4. ¿Está la 0007? (computed fields lat/lng y la vista corregida)
-- ----------------------------------------------------------------------------
--
-- Sin esto la app no consulta nada: el repositorio pide `lat` y `lng` en el
-- select y PostgREST responde 42703 «column pedidos.lat does not exist».
-- ----------------------------------------------------------------------------
select
    to_regprocedure('public.lat(public.pedidos)') is not null as computed_lat,
    to_regprocedure('public.lng(public.pedidos)') is not null as computed_lng,
    to_regprocedure('public.punto(double precision, double precision)')
        is not null as constructor_punto,
    exists (
        select 1 from information_schema.columns
         where table_schema = 'public'
           and table_name   = 'pedidos_publicos'
           and column_name  = 'lat'
    ) as vista_con_lat;
-- Se espera: todo true.
-- Si `vista_con_lat` es false pero la vista existe, quedó la de la 0005, que
-- devuelve `ubicacion_aproximada` en WKB hexadecimal y no sirve desde Dart.


-- ----------------------------------------------------------------------------
-- 5. Políticas vigentes sobre las tablas de pedidos
-- ----------------------------------------------------------------------------
select tablename, policyname, cmd, roles
  from pg_policies
 where schemaname = 'public'
   and tablename in ('pedidos', 'pedido_fotos', 'pedido_eventos')
 order by tablename, cmd, policyname;
--
-- Se esperan 9 políticas y NINGUNA de DELETE sobre `pedidos`:
--
--   pedidos         SELECT  pedidos: lectura propia
--   pedidos         SELECT  pedidos: lectura de publicados vigentes
--   pedidos         INSERT  pedidos: alta del buscador
--   pedidos         UPDATE  pedidos: edición propia
--   pedido_fotos    SELECT  fotos: lectura si se ve el pedido
--   pedido_fotos    INSERT  fotos: alta del dueño del pedido
--   pedido_fotos    UPDATE  fotos: edición del dueño del pedido
--   pedido_fotos    DELETE  fotos: baja del dueño del pedido
--   pedido_eventos  SELECT  eventos: lectura del dueño del pedido
--
-- Si aparecen nombres como «buscador propio: sus pedidos» o «admin: gestión de
-- pedidos», quedaron las de la 0005: volvé a correr la 0006, que las dropea.


-- ----------------------------------------------------------------------------
-- 6. Políticas de Storage del bucket `pedidos`
-- ----------------------------------------------------------------------------
select policyname, cmd
  from pg_policies
 where schemaname = 'storage'
   and tablename  = 'objects'
   and policyname like 'pedidos:%'
 order by cmd;
-- Se esperan 3: subida (INSERT), lectura (SELECT) y baja (DELETE) del dueño.


-- ----------------------------------------------------------------------------
-- 7. RLS realmente activo en las tres tablas
-- ----------------------------------------------------------------------------
select relname, relrowsecurity as rls_activo
  from pg_class
 where relname in ('pedidos', 'pedido_fotos', 'pedido_eventos')
 order by relname;
-- Se espera: true en las tres.


-- ----------------------------------------------------------------------------
-- 8. ¿Está la 0008? (guard de la máquina de estados)
-- ----------------------------------------------------------------------------
--
-- Sin esto, un PATCH directo sobre `pedidos.estado` saltea
-- `cambiar_estado_pedido` y su tabla de transiciones. La app no se rompe: se
-- rompe la regla.
--
-- `abre_compuerta` es el punto fino. Si el trigger está pero las tres RPC son
-- todavía las de la 0006 —sin el `set_config`—, entonces **nada** puede mover
-- el estado y la app queda muerta: pausar, cerrar y renovar fallan todos con
-- ESTADO_NO_MODIFICABLE_DIRECTAMENTE. Es el único orden de aplicación que deja
-- el sistema peor que antes, así que se mira junto.
-- ----------------------------------------------------------------------------
select
    exists (
        select 1 from pg_trigger
         where tgname = 'pedidos_guard_estado'
           and tgrelid = 'public.pedidos'::regclass
    ) as trigger_guard,
    p.proname,
    prosrc like '%app.transicion_estado%' as abre_compuerta
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public'
   and p.proname in ('cambiar_estado_pedido', 'renovar_pedido',
                     'marcar_pedidos_vencidos')
 order by p.proname;
-- Se espera: trigger_guard = true y abre_compuerta = true en las tres.
-- Si trigger_guard es true y alguna abre_compuerta es false → volvé a correr
-- 0008_pedidos_guard_estado.sql entera.


-- ----------------------------------------------------------------------------
-- 9. ¿Está la 0009? (alta y cambio de ubicación por RPC)
-- ----------------------------------------------------------------------------
--
-- Sin esto el alta del CU-13 falla con PGRST202 «function not found»: el
-- repositorio ya no hace INSERT directo.
-- ----------------------------------------------------------------------------
select
    to_regprocedure(
        'public.crear_pedido(uuid, text, text, double precision, '
        'double precision, text, timestamptz, text, public.pedido_urgencia, '
        'numeric)'
    ) is not null as rpc_crear_pedido,
    to_regprocedure(
        'public.actualizar_ubicacion_pedido(uuid, double precision, '
        'double precision, text, text)'
    ) is not null as rpc_mover_ubicacion,
    exists (
        select 1 from pg_trigger
         where tgname = 'pedidos_guard_alta'
           and tgrelid = 'public.pedidos'::regclass
    ) as trigger_guard_alta;
-- Se espera: todo true.


-- ----------------------------------------------------------------------------
-- 10. Orden de los triggers sobre `pedidos`
-- ----------------------------------------------------------------------------
--
-- Los BEFORE de una misma tabla se disparan en orden alfabético. El guard tiene
-- que correr antes que `pedidos_set_updated_at`, para que un update rechazado
-- no llegue a tocar la fila.
-- ----------------------------------------------------------------------------
select tgname,
       case tgtype & 2 when 2 then 'BEFORE' else 'AFTER' end as momento,
       case when tgtype &  4 > 0 then 'INSERT'
            when tgtype & 16 > 0 then 'UPDATE'
            else '?' end as evento
  from pg_trigger
 where tgrelid = 'public.pedidos'::regclass
   and not tgisinternal
 order by tgname;
--
-- Se esperan cuatro, en este orden:
--
--   pedidos_guard_alta        BEFORE  INSERT
--   pedidos_guard_estado      BEFORE  UPDATE
--   pedidos_registrar_evento  AFTER   UPDATE
--   pedidos_set_updated_at    BEFORE  UPDATE
