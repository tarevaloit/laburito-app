-- ============================================================================
-- Guion de aceptación de la migración 0032 (CU-45)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0032.sql
--
-- Transacción que aborta al final; el resultado sale como el mensaje del error.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select
    (select pr.perfil_id from public.profesionales pr
       join public.perfiles p on p.id = pr.perfil_id
      where p.estado = 'activo' and pr.estado_verificacion = 'aprobado'
      order by pr.created_at limit 1) as profesional,
    (select id from public.perfiles where tipo = 'buscador' and estado = 'activo' limit 1) as buscador;
grant select on _ids to authenticated;

create temp table _m on commit drop as select null::jsonb as antes, null::jsonb as despues, null::jsonb as mes;
grant all on _m to authenticated;

select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;
update _m set antes = public.metricas_perfil('semana');
reset role;

-- Tres visitas hoy y una hace 10 días.
insert into public.perfil_visitas (profesional_id, created_at)
select profesional, now() from _ids, generate_series(1, 3);
insert into public.perfil_visitas (profesional_id, created_at)
select profesional, now() - interval '10 days' from _ids;

set local role authenticated;
update _m set despues = public.metricas_perfil('semana'),
              mes     = public.metricas_perfil('mes');
reset role;

insert into _v (resultado)
select case when (despues->>'vistas')::int = (antes->>'vistas')::int + 3
             and jsonb_array_length(despues->'serie') = 7
             and ((despues->'serie'->6)->>'vistas')::int >= 3
            then 'OK   semana: las 3 visitas de hoy suman y caen en la última barra de 7'
            else 'FALLA semana: ' || despues::text end
  from _m;

insert into _v (resultado)
select case when jsonb_array_length(mes->'serie') = 4
             and (mes->>'vistas')::int >= (despues->>'vistas')::int + 1
            then 'OK   mes: 4 barras semanales e incluye la visita de hace 10 días'
            else 'FALLA mes: ' || mes::text end
  from _m;

insert into _v (resultado)
select case when (despues->>'contactos')::int = 0 and despues->'efectividad' = 'null'::jsonb
              or (despues->>'contactos')::int > 0 and (despues->>'efectividad')::int between 0 and 100
            then 'OK   efectividad: null sin contactos, porcentaje con contactos'
            else 'FALLA efectividad: ' || despues::text end
  from _m;

-- Un Buscador no tiene estadísticas.
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.metricas_perfil('semana');
    insert into _v (resultado) values ('FALLA un Buscador obtuvo estadísticas');
exception when others then
    insert into _v (resultado) values ('OK   un Buscador recibe: ' || sqlerrm);
end $$;

reset role;

-- Un Profesional sin aprobar tampoco.
update public.profesionales set estado_verificacion = 'en_revision'
 where perfil_id = (select profesional from _ids);

select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.metricas_perfil('semana');
    insert into _v (resultado) values ('FALLA un Profesional sin aprobar obtuvo estadísticas');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%aprobada%'
        then 'OK   un Profesional sin aprobar recibe sin_verificar'
        else 'FALLA sin aprobar: ' || sqlerrm end);
end $$;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0032:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
