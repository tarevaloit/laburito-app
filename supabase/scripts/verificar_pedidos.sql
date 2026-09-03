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
