-- ============================================================================
-- Aprobar a un Profesional a mano (reemplaza al CU-35 hasta el Sprint 6)
-- ============================================================================
--
-- Esto NO es una migración: vive fuera de `supabase/migrations/` porque es una
-- tarea de operación, no un cambio de esquema.
--
-- **Por qué hace falta.** El CU-09 deja al Profesional en «En Revisión» y el
-- CU-35 —la pantalla del Admin que resuelve esa revisión— recién está en el
-- Sprint 6. Hasta entonces, aprobar es correr el UPDATE de acá.
--
-- **El error fácil.** Poner en `aprobado` las tres filas de
-- `documentos_verificacion` no aprueba a nadie: esa columna dice qué pasó con
-- *cada documento*, y la app no la lee. Lo que la app muestra sale de
-- `profesionales.estado_verificacion`, que es la que hay que mover. Son dos
-- cosas distintas a propósito: un día el Admin va a poder rechazar la selfie
-- y aceptar el DNI, y el estado del Profesional es la conclusión, no la suma.
--
-- Valores posibles del enum `estado_verificacion`:
--   'sin_documentacion' · 'en_revision' · 'aprobado' · 'rechazado'
-- ============================================================================


-- ----------------------------------------------------------------------------
-- PASO 1 · Ver quién está esperando. Corré esto solo.
-- ----------------------------------------------------------------------------

select p.email,
       p.nombre || ' ' || p.apellido        as nombre,
       pr.estado_verificacion               as estado_del_profesional,
       count(d.id) filter (where d.estado = 'aprobado') as docs_aprobados,
       count(d.id)                          as docs_subidos
  from public.profesionales pr
  join public.perfiles p on p.id = pr.perfil_id
  left join public.documentos_verificacion d on d.profesional_id = pr.perfil_id
 group by p.email, p.nombre, p.apellido, pr.estado_verificacion
 order by p.email;

-- Los tres documentos del CU-09 son dni_frente, dni_dorso y selfie: con
-- `docs_subidos = 3` está completo. `docs_aprobados` es informativo — lo que
-- decide es el UPDATE del paso 2.


-- ----------------------------------------------------------------------------
-- PASO 2 · Aprobarlo. Cambiá el correo y ejecutá.
-- ----------------------------------------------------------------------------

update public.profesionales pr
   set estado_verificacion = 'aprobado'
  from public.perfiles p
 where p.id = pr.perfil_id
   and p.email = 'PEGAR_EL_CORREO_DEL_PROFESIONAL';

-- Rechazarlo es lo mismo con 'rechazado'. Y para devolverlo a revisión,
-- 'en_revision'.


-- ----------------------------------------------------------------------------
-- PASO 3 · Comprobar, y refrescar la app
-- ----------------------------------------------------------------------------

select p.email, pr.estado_verificacion
  from public.profesionales pr
  join public.perfiles p on p.id = pr.perfil_id
 where p.email = 'PEGAR_EL_CORREO_DEL_PROFESIONAL';
-- → aprobado

-- **En la app hay que recargar.** `perfilCompletoProvider` es `keepAlive`: se
-- carga una vez por sesión y no vuelve a preguntar solo. Refrescar la pestaña
-- —o cerrar sesión y volver a entrar— alcanza. Si no, el aviso de
-- «Documentación en revisión» sigue ahí aunque la base ya diga otra cosa.


-- ----------------------------------------------------------------------------
-- Opcional · Aprobar también cada documento
-- ----------------------------------------------------------------------------
--
-- No cambia nada de lo que se ve hoy en la app, pero deja la fila coherente
-- para cuando exista el CU-35 y para que la demo se lea bien en el panel.

-- update public.documentos_verificacion d
--    set estado = 'aprobado', revisado_at = now()
--   from public.perfiles p
--  where p.id = d.profesional_id
--    and p.email = 'PEGAR_EL_CORREO_DEL_PROFESIONAL';
--
-- `revisado_por` queda en null a propósito: apunta al Admin que revisó, y en
-- este atajo no hay ninguno. Cuando exista el CU-35 lo va a llenar la app.
