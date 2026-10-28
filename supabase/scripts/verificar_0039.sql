-- ============================================================================
-- Guion de aceptación de la migración 0039 (CU-36)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0039.sql
--
-- Transacción que aborta al final. Necesita un administrador y un Buscador
-- con al menos un pedido.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select (select id from public.perfiles where tipo = 'administrador' and estado = 'activo' limit 1) as admin,
       (select p.id from public.perfiles p
         where p.tipo = 'buscador' and p.estado = 'activo' and p.deleted_at is null
           and exists (select 1 from public.pedidos pe where pe.buscador_id = p.id)
         limit 1) as buscador,
       null::uuid as sancion;
grant select, update on _ids to authenticated;

-- Un pedido publicado del Buscador, para ver que se pausa.
select set_config('app.transicion_estado', 'on', true);
update public.pedidos set estado = 'publicado', fecha_vencimiento = now() + interval '5 days'
 where id = (select id from public.pedidos where buscador_id = (select buscador from _ids) limit 1);
select set_config('app.transicion_estado', 'off', true);

select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) >= 1 then 'OK   el buscador general encuentra al usuario por su correo'
            else 'FALLA búsqueda' end
  from public.buscar_usuarios_admin((select email from public.perfiles where id = (select buscador from _ids)));

insert into _v (resultado)
select case when d ? 'pedidos' and d ? 'denuncias_recibidas' and d ? 'sanciones'
            then 'OK   el detalle trae pedidos, denuncias y sanciones (paso 2)'
            else 'FALLA detalle: ' || d::text end
  from public.detalle_usuario_admin((select buscador from _ids)) d;

do $$
begin
    perform public.suspender_cuenta((select admin from _ids), 'Prueba de sanción a un par.', 7);
    insert into _v (resultado) values ('FALLA se sancionó a un administrador');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%SuperAdmin%'
        then 'OK   sancionar a otro administrador se bloquea (flujo alterno 1.1)' else 'FALLA par: ' || sqlerrm end);
end $$;

do $$
begin
    perform public.suspender_cuenta((select buscador from _ids), 'corto', 7);
    insert into _v (resultado) values ('FALLA se suspendió sin motivo formal');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%motivo%'
        then 'OK   la suspensión exige el motivo formal' else 'FALLA motivo: ' || sqlerrm end);
end $$;

update _ids set sancion = public.suspender_cuenta(
    (select buscador from _ids), 'No se presentó a tres trabajos acordados.', 7, true);

reset role;

insert into _v (resultado)
select case when p.estado = 'suspendido'
             and not exists (select 1 from public.pedidos where buscador_id = p.id and estado = 'publicado')
             and not exists (select 1 from auth.sessions where user_id = p.id)
            then 'OK   cuenta suspendida, pedidos pausados y sesiones cerradas (paso 6)'
            else 'FALLA suspensión: ' || p.estado end
  from public.perfiles p where p.id = (select buscador from _ids);

insert into _v (resultado)
select case when count(*) = 1 then 'OK   el usuario recibe el aviso con el motivo'
            else 'FALLA aviso: ' || count(*) end
  from public.notificaciones
 where destinatario_id = (select buscador from _ids) and tipo = 'cuenta_suspendida'
   and cuerpo like '%tres trabajos%';

-- Como el Buscador suspendido: ve su sanción.
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when r ->> 'estado' = 'suspendido' and (r -> 'sancion' ->> 'apelable')::boolean
            then 'OK   el login ve la sanción vigente con su motivo'
            else 'FALLA revisar: ' || r::text end
  from public.revisar_mi_suspension() r;

reset role;

-- La sanción vence: el próximo login la levanta sola.
update public.sanciones set hasta = now() - interval '1 minute' where id = (select sancion from _ids);

set local role authenticated;
insert into _v (resultado)
select case when r ->> 'estado' = 'activo'
            then 'OK   una suspensión temporal vencida se levanta sola al entrar'
            else 'FALLA vencimiento: ' || r::text end
  from public.revisar_mi_suspension() r;
reset role;

insert into _v (resultado)
select case when p.estado = 'activo' and s.levantada_at is not null
            then 'OK   cuenta activa y sanción con fecha de levantamiento'
            else 'FALLA reactivación' end
  from public.perfiles p, public.sanciones s
 where p.id = (select buscador from _ids) and s.id = (select sancion from _ids);

do $$
begin
    raise exception E'Resultado del guion de la 0039:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
