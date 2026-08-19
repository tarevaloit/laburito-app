-- ============================================================================
-- ⚠️  BORRA TODAS LAS CUENTAS Y SUS DATOS. SOLO PARA DESARROLLO.
-- ============================================================================
--
-- Esto NO es una migración: vive fuera de `supabase/migrations/` a propósito,
-- para que nunca se ejecute sola al levantar un entorno.
--
-- Sirve para dejar la base limpia después de probar los circuitos: elimina los
-- usuarios de prueba, sus perfiles, su documentación y sus archivos.
--
-- NO se puede deshacer. Antes de correrlo, confirmá dos cosas:
--   1. Que estás en el proyecto de desarrollo y no en otro.
--   2. Que ninguna de esas cuentas le importa a nadie más que a vos.
--
-- Qué NO toca: las categorías de oficio (el seed de T-02), los buckets, las
-- políticas RLS, los triggers ni las funciones. Después de correrlo la app
-- funciona igual, solo que sin usuarios.
--
-- ============================================================================


-- ----------------------------------------------------------------------------
-- PASO 1 · Mirar antes de tocar. Corré esto solo y leé los números.
-- ----------------------------------------------------------------------------
select 'auth.users'               as tabla, count(*) as filas from auth.users
union all
select 'perfiles',                count(*) from public.perfiles
union all
select 'profesionales',           count(*) from public.profesionales
union all
select 'profesional_categorias',  count(*) from public.profesional_categorias
union all
select 'documentos_verificacion', count(*) from public.documentos_verificacion
union all
select 'bajas_cuenta',            count(*) from public.bajas_cuenta
union all
select 'archivos en Storage',     count(*) from storage.objects
 where bucket_id in ('avatares', 'documentos', 'portafolios')
union all
select 'categorias_oficio (NO se borra)', count(*) from public.categorias_oficio
order by tabla;


-- ----------------------------------------------------------------------------
-- PASO 2 · El borrado. Seleccioná desde `begin;` hasta `commit;` y ejecutá.
--
-- El orden no es decorativo: se borra de la hoja hacia la raíz. Aunque las FK
-- están en cascada, `documentos_verificacion.revisado_por` apunta a `perfiles`
-- sin cascada, y borrar en cascada desde `auth.users` puede chocar contra esa
-- restricción. Explícito y en orden, no falla.
-- ----------------------------------------------------------------------------
begin;

-- Primero los archivos, mientras las filas todavía existen.
delete from storage.objects
 where bucket_id in ('avatares', 'documentos', 'portafolios');

delete from public.documentos_verificacion;
delete from public.profesional_categorias;
delete from public.bajas_cuenta;
delete from public.profesionales;
delete from public.perfiles;

-- Esto arrastra identidades, sesiones, refresh tokens y factores MFA.
delete from auth.users;

commit;


-- ----------------------------------------------------------------------------
-- PASO 3 · Verificar. Todo en 0 menos las categorías, que tienen que dar 22.
-- ----------------------------------------------------------------------------
select 'auth.users'               as tabla, count(*) as filas from auth.users
union all
select 'perfiles',                count(*) from public.perfiles
union all
select 'profesionales',           count(*) from public.profesionales
union all
select 'documentos_verificacion', count(*) from public.documentos_verificacion
union all
select 'archivos en Storage',     count(*) from storage.objects
 where bucket_id in ('avatares', 'documentos', 'portafolios')
union all
select 'categorias_oficio (esperado 22)', count(*) from public.categorias_oficio
order by tabla;


-- ============================================================================
-- VARIANTE · Conservar tu cuenta y borrar el resto
--
-- Reemplazá el bloque del PASO 2 por este, poniendo tu correo. Útil cuando ya
-- te creaste un usuario administrador y no querés rehacerlo.
--
--   begin;
--
--   create temp table conservar as
--     select id from auth.users where email = 'TU@CORREO.COM';
--
--   delete from storage.objects
--    where bucket_id in ('avatares', 'documentos', 'portafolios')
--      and (storage.foldername(name))[1] not in
--          (select id::text from conservar);
--
--   delete from public.documentos_verificacion
--    where profesional_id not in (select id from conservar);
--   delete from public.profesional_categorias
--    where profesional_id not in (select id from conservar);
--   delete from public.bajas_cuenta
--    where perfil_id not in (select id from conservar);
--   delete from public.profesionales
--    where perfil_id not in (select id from conservar);
--   delete from public.perfiles
--    where id not in (select id from conservar);
--   delete from auth.users
--    where id not in (select id from conservar);
--
--   commit;
--
-- ============================================================================
-- NOTA SOBRE LOS ARCHIVOS
--
-- Borrar filas de `storage.objects` por SQL elimina la referencia, pero el
-- archivo puede quedar huérfano en el backend de Storage. Con cuatro pruebas no
-- importa; si querés dejarlo impecable, entrá a Storage en el panel y vaciá los
-- buckets `avatares`, `documentos` y `portafolios` desde la interfaz.
-- ============================================================================
