-- ============================================================================
-- Dar el rol de administrador a una cuenta existente (Sprint 4)
-- ============================================================================
--
-- Esto NO es una migración: es operación, como `aprobar_profesional.sql`.
--
-- **Por qué hace falta.** El alta de la app crea Buscadores (web) y
-- Profesionales (app). El administrador no se registra: la ERS (CU-34) dice
-- que tiene «credenciales preasignadas». Hasta que exista el alta de
-- administradores (Sprint 6), se crea una cuenta común desde la web y se le
-- cambia el tipo acá.
--
-- Usá una cuenta **aparte**, no la del Buscador ni la del Profesional de las
-- pruebas: un administrador no publica pedidos ni compra tokens.
--
-- Con el rol puesto, al iniciar sesión el home muestra «Panel de
-- administración» → /admin/precios (CU-40) y /admin/cupones (CU-52).
-- ============================================================================

-- PASO 1 · Ver la cuenta. Tiene que existir y estar activa (correo validado).
select id, email, tipo, estado
  from public.perfiles
 where email = 'PEGAR_EL_CORREO_DEL_ADMIN';

-- PASO 2 · Darle el rol.
update public.perfiles
   set tipo = 'administrador'
 where email = 'PEGAR_EL_CORREO_DEL_ADMIN'
   and deleted_at is null;

-- PASO 3 · Comprobar que `es_admin()` lo reconoce.
select p.email, p.tipo,
       exists (select 1 from public.perfiles a
                where a.id = p.id and a.tipo = 'administrador'
                  and a.deleted_at is null)           as es_admin
  from public.perfiles p
 where p.email = 'PEGAR_EL_CORREO_DEL_ADMIN';

-- Si la app ya estaba abierta con esa cuenta, cerrá sesión y volvé a entrar:
-- el perfil se lee al iniciar.
