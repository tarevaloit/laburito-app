-- ============================================================================
-- Guion de aceptación de las migraciones 0035 (CU-34) y 0036 (CU-38)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0035_0036.sql
--
-- Transacción que aborta al final. Necesita un administrador y un Buscador.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select (select id from public.perfiles where tipo = 'administrador' and estado = 'activo' limit 1) as admin,
       (select id from public.perfiles where tipo = 'buscador' and estado = 'activo' limit 1)      as buscador;
grant select on _ids to authenticated;

-- Como el Buscador, con encabezados de un navegador.
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true),
       set_config('request.headers',
                  '{"x-forwarded-for": "190.2.3.4, 10.0.0.1", "user-agent": "Guion/1.0"}', true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when not public.registrar_acceso_admin()
            then 'OK   un Buscador no entra al panel (flujo alterno 1.2)'
            else 'FALLA el Buscador entró al panel' end;

do $$
begin
    perform public.dashboard_admin(current_date - 30, current_date);
    insert into _v (resultado) values ('FALLA un Buscador vio el dashboard');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%administrador%'
        then 'OK   un Buscador no ve el dashboard' else 'FALLA dashboard: ' || sqlerrm end);
end $$;

reset role;

insert into _v (resultado)
select case when count(*) = 1 and bool_and(ip = '190.2.3.4' and navegador = 'Guion/1.0')
            then 'OK   el intento denegado quedó con IP y navegador'
            else 'FALLA registro denegado: ' || count(*) end
  from public.accesos_admin
 where resultado = 'denegado' and created_at = now();

-- Como admin.
select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when public.registrar_acceso_admin()
            then 'OK   el administrador entra al panel'
            else 'FALLA el administrador no entró' end;

insert into _v (resultado)
select case when count(*) >= 2 then 'OK   el admin ve los últimos accesos (' || count(*) || ')'
            else 'FALLA accesos recientes: ' || count(*) end
  from public.accesos_admin_recientes(10);

insert into _v (resultado)
select case when jsonb_array_length(d -> 'altas_por_mes') = 12
             and d ? 'ingresos_ars' and d ? 'denuncias_abiertas'
            then 'OK   el dashboard trae las tarjetas y doce meses de altas'
            else 'FALLA dashboard: ' || d::text end
  from public.dashboard_admin(current_date - 30, current_date) d;

insert into _v (resultado)
select case when (d -> 'pedidos_publicados' ->> 'actual')::int = 0
             and (d -> 'ingresos_ars' ->> 'actual')::int = 0
             and jsonb_array_length(d -> 'ingresos_por_pack') = 0
            then 'OK   un rango anterior al lanzamiento da ceros sin error (flujo alterno 1.1)'
            else 'FALLA rango histórico: ' || d::text end
  from public.dashboard_admin(date '2024-01-01', date '2024-01-31') d;

do $$
begin
    perform public.dashboard_admin(current_date, current_date - 1);
    insert into _v (resultado) values ('FALLA se aceptó un rango invertido');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%rango%'
        then 'OK   un rango invertido se rechaza' else 'FALLA rango: ' || sqlerrm end);
end $$;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0035 y la 0036:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
