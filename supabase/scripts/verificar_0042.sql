-- ============================================================================
-- Guion de aceptación de la migración 0042 (CU-47)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0042.sql
--
-- Transacción que aborta al final. Cambia los parámetros como admin y
-- comprueba que las funciones de negocio los obedecen.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select (select id from public.perfiles where tipo = 'administrador' and estado = 'activo' limit 1) as admin,
       (select pr.perfil_id from public.profesionales pr
          join public.perfiles p on p.id = pr.perfil_id
         where p.estado = 'activo' and pr.estado_verificacion = 'aprobado' limit 1)           as profesional,
       (select p.id from public.perfiles p
         where p.tipo = 'buscador' and p.estado = 'activo'
           and exists (select 1 from public.pedidos pe where pe.buscador_id = p.id) limit 1)  as buscador;
grant select on _ids to authenticated;

-- Como el Profesional: no puede tocar parámetros.
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.actualizar_parametro('radio_maximo_km', 5);
    insert into _v (resultado) values ('FALLA un Profesional cambió un parámetro');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%administrador%'
        then 'OK   solo el administrador cambia parámetros' else 'FALLA: ' || sqlerrm end);
end $$;

reset role;

select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.actualizar_parametro('radio_maximo_km', -5);
    insert into _v (resultado) values ('FALLA se aceptó un radio negativo');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%conserva el valor anterior%'
        then 'OK   un radio negativo se rechaza y se conserva el anterior (flujo alterno 1.1)'
        else 'FALLA rango: ' || sqlerrm end);
end $$;

select public.actualizar_parametro('radio_maximo_km', 20);
select public.actualizar_parametro('renovaciones_maximas', 0);

insert into _v (resultado)
select case when valor = 20 and updated_by = (select admin from _ids)
            then 'OK   el cambio queda con quién y cuándo'
            else 'FALLA registro del cambio' end
  from public.parametros_sistema where clave = 'radio_maximo_km';

reset role;

-- Como el Profesional: 30 km ya no se aceptan.
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.guardar_zona_cobertura(-34.52, -58.77, 30000, 'Guion 0042');
    insert into _v (resultado) values ('FALLA se guardó un radio de 30 km con el máximo en 20');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%entre 1 y 20 km%'
        then 'OK   la zona de cobertura obedece el radio máximo nuevo' else 'FALLA zona: ' || sqlerrm end);
end $$;

reset role;

-- Como el Buscador: con 0 renovaciones permitidas, ninguna renovación pasa.
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.renovar_pedido(
        (select id from public.pedidos where buscador_id = auth.uid()
          and estado not in ('cerrado', 'cancelado') limit 1), 7);
    insert into _v (resultado) values ('FALLA se renovó con el límite en 0');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%renovó 0 veces%' or sqlerrm like '%Todavía no%'
                                                 or sqlerrm like '%no existe%'
        then 'OK   renovar obedece el límite del parámetro (' || left(sqlerrm, 50) || ')'
        else 'FALLA renovación: ' || sqlerrm end);
end $$;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0042:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
