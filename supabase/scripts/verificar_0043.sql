-- ============================================================================
-- Guion de aceptación de la migración 0043 (CU-49)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0043.sql
--
-- Transacción que aborta al final. Suspende a un Buscador, apela, el admin
-- rechaza; se vuelve a apelar y el admin acepta. Prueba también una sanción
-- inapelable.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select (select id from public.perfiles where tipo = 'administrador' and estado = 'activo' limit 1) as admin,
       (select id from public.perfiles where tipo = 'buscador' and estado = 'activo'
           and deleted_at is null limit 1)                                                     as usuario,
       null::uuid as apelacion,
       null::bigint as numero;
grant select, update on _ids to authenticated;

select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;
select public.suspender_cuenta((select usuario from _ids), 'Trato inadecuado con un Profesional.', 30, true);
reset role;

-- Como el usuario suspendido.
select set_config('request.jwt.claims',
                  json_build_object('sub', usuario, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.apelar_sancion('Fue un error.');
    insert into _v (resultado) values ('FALLA se aceptó un descargo de 13 caracteres');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%20 caracteres%'
        then 'OK   el descargo tiene que tener al menos 20 caracteres' else 'FALLA: ' || sqlerrm end);
end $$;

update _ids set numero = public.apelar_sancion('Nunca falté el respeto: tengo los mensajes de WhatsApp.');

insert into _v (resultado)
select case when (select numero from _ids) >= 1001
            then 'OK   la apelación devuelve un número de trámite (#' || (select numero from _ids) || ')'
            else 'FALLA número de trámite' end;

insert into _v (resultado)
select case when r -> 'apelacion' ->> 'estado' = 'pendiente'
            then 'OK   la pantalla de la cuenta suspendida ve el trámite en curso'
            else 'FALLA revisar: ' || r::text end
  from public.revisar_mi_suspension() r;

do $$
begin
    perform public.apelar_sancion('Apelo otra vez por las dudas, con más detalle.');
    insert into _v (resultado) values ('FALLA se apeló dos veces la misma sanción');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%Ya tenés%'
        then 'OK   una sola apelación en revisión por sanción' else 'FALLA doble: ' || sqlerrm end);
end $$;

reset role;

-- Como admin: rechaza.
select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

update _ids set apelacion = (select id from public.apelaciones_admin()
                              where numero = (select numero from _ids));

insert into _v (resultado)
select case when (select apelacion from _ids) is not null
            then 'OK   la apelación llega a la bandeja del panel'
            else 'FALLA bandeja de apelaciones' end;

select public.resolver_apelacion((select apelacion from _ids), false,
                                 'Los mensajes no muestran lo que decís.');
reset role;

insert into _v (resultado)
select case when (select estado from public.perfiles where id = (select usuario from _ids)) = 'suspendido'
             and exists (select 1 from public.notificaciones
                          where destinatario_id = (select usuario from _ids) and tipo = 'apelacion_resuelta')
            then 'OK   rechazada: la sanción se mantiene y se avisa'
            else 'FALLA rechazo' end;

-- Apela de nuevo y el admin acepta.
select set_config('request.jwt.claims',
                  json_build_object('sub', usuario, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;
update _ids set numero = public.apelar_sancion('Adjunto el audio donde se ve que el Profesional me insultó primero.');
reset role;

select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;
select public.resolver_apelacion(
    (select id from public.apelaciones_admin() where numero = (select numero from _ids)),
    true, 'Revisamos el audio y la sanción no corresponde.');
reset role;

insert into _v (resultado)
select case when (select estado from public.perfiles where id = (select usuario from _ids)) = 'activo'
            then 'OK   aceptada: la cuenta queda activa otra vez'
            else 'FALLA aceptación' end;

-- Sanción inapelable.
select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;
select public.suspender_cuenta((select usuario from _ids), 'Estafa comprobada a tres Profesionales.', null, false);
reset role;

select set_config('request.jwt.claims',
                  json_build_object('sub', usuario, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.apelar_sancion('Quiero apelar esta sanción permanente por favor.');
    insert into _v (resultado) values ('FALLA se apeló una sanción inapelable');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%legales@%'
        then 'OK   una sanción inapelable da el correo de soporte legal (flujo alterno 1.1)'
        else 'FALLA inapelable: ' || sqlerrm end);
end $$;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0043:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
