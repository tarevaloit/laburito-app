-- ============================================================================
-- Guion de aceptación de la migración 0037 (CU-35)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0037.sql
--
-- Transacción que aborta al final. Toma un Profesional cualquiera, le simula
-- la documentación en revisión y la resuelve como administrador.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select (select perfil_id from public.profesionales pr
          join public.perfiles p on p.id = pr.perfil_id
         where p.deleted_at is null order by pr.created_at limit 1)                            as profesional,
       (select id from public.perfiles where tipo = 'administrador' and estado = 'activo' limit 1) as admin;
grant select on _ids to authenticated;

-- La documentación del CU-09, simulada.
delete from public.documentos_verificacion where profesional_id = (select profesional from _ids);
insert into public.documentos_verificacion (profesional_id, tipo, storage_path)
select profesional, t::public.tipo_documento, profesional || '/' || t || '.jpg'
  from _ids, unnest(array['dni_frente', 'dni_dorso', 'selfie']) t;
update public.profesionales set estado_verificacion = 'en_revision'
 where perfil_id = (select profesional from _ids);

-- Como el Profesional: no puede aprobarse solo.
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.resolver_verificacion(auth.uid(), true);
    insert into _v (resultado) values ('FALLA el Profesional se aprobó solo');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%administrador%'
        then 'OK   el Profesional no resuelve su propia verificación' else 'FALLA: ' || sqlerrm end);
end $$;

reset role;

-- Como admin.
select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) = 1 and bool_and(documentos ? 'dni_frente' and documentos ? 'selfie')
            then 'OK   el admin ve al Profesional con las rutas de sus fotos'
            else 'FALLA en revisión: ' || count(*) end
  from public.profesionales_en_revision()
 where profesional_id = (select profesional from _ids);

do $$
begin
    perform public.resolver_verificacion((select profesional from _ids), false, 'mal');
    insert into _v (resultado) values ('FALLA se rechazó sin motivo');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%motivo%'
        then 'OK   rechazar exige un motivo (flujo alterno 1.2)' else 'FALLA motivo: ' || sqlerrm end);
end $$;

select public.resolver_verificacion((select profesional from _ids), false,
                                    'La foto del frente del DNI está borrosa');

reset role;

insert into _v (resultado)
select case when pr.estado_verificacion = 'rechazado'
             and not exists (select 1 from public.documentos_verificacion d where d.profesional_id = pr.perfil_id)
            then 'OK   rechazado y sin filas de documentos'
            else 'FALLA rechazo: ' || pr.estado_verificacion end
  from public.profesionales pr where pr.perfil_id = (select profesional from _ids);

insert into _v (resultado)
select case when count(*) = 1 and bool_and(cuerpo like '%borrosa%')
            then 'OK   el aviso de rechazo lleva el motivo'
            else 'FALLA aviso de rechazo: ' || count(*) end
  from public.notificaciones
 where destinatario_id = (select profesional from _ids)
   and tipo = 'verificacion_rechazada' and created_at = now();

-- El Profesional vuelve a cargar (CU-09) y se aprueba.
insert into public.documentos_verificacion (profesional_id, tipo, storage_path)
select profesional, 'dni_frente', profesional || '/dni_frente.jpg' from _ids;
update public.profesionales set estado_verificacion = 'en_revision'
 where perfil_id = (select profesional from _ids);

set local role authenticated;
select public.resolver_verificacion((select profesional from _ids), true);

do $$
begin
    perform public.resolver_verificacion((select profesional from _ids), true);
    insert into _v (resultado) values ('FALLA se resolvió dos veces');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%revisión%'
        then 'OK   una verificación ya resuelta no se vuelve a resolver' else 'FALLA doble: ' || sqlerrm end);
end $$;

reset role;

insert into _v (resultado)
select case when pr.estado_verificacion = 'aprobado'
             and (select count(*) from public.verificaciones_resueltas v
                   where v.profesional_id = pr.perfil_id and v.created_at = now()) = 2
            then 'OK   aprobado, con las dos decisiones asentadas'
            else 'FALLA aprobación: ' || pr.estado_verificacion end
  from public.profesionales pr where pr.perfil_id = (select profesional from _ids);

do $$
begin
    raise exception E'Resultado del guion de la 0037:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
