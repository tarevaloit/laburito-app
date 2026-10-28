-- ============================================================================
-- Guion de aceptación de la migración 0040 (CU-39)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0040.sql
--
-- Transacción que aborta al final. Arma dos denuncias contra el Profesional
-- de un contacto desbloqueado: una se resuelve con suspensión y la otra se
-- desestima.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select c.profesional_id as profesional,
       c.pedido_id      as pedido,
       p.buscador_id    as buscador,
       (select id from public.perfiles where tipo = 'administrador' and estado = 'activo' limit 1) as admin,
       null::uuid as grave,
       null::uuid as baja
  from public.contactos_desbloqueados c
  join public.pedidos p on p.id = c.pedido_id
 order by c.created_at desc
 limit 1;
grant select, update on _ids to authenticated;

-- Las denuncias se escriben como postgres: la 0033 ya probó reportar_usuario.
delete from public.denuncias
 where denunciante_id = (select buscador from _ids) and estado in ('pendiente', 'en_revision');
with n as (
    insert into public.denuncias (denunciante_id, denunciado_id, pedido_id, motivo, descripcion)
    select buscador, profesional, pedido, 'estafa', 'Me cobró el trabajo y no vino nunca.' from _ids
    returning id)
update _ids set grave = (select id from n);
with n as (
    insert into public.denuncias (denunciante_id, denunciado_id, pedido_id, motivo, descripcion)
    select profesional, buscador, pedido, 'otro', 'El buscador cambió la dirección sin avisar.' from _ids
    returning id)
update _ids set baja = (select id from n);

select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when (array_agg(id order by ord))[1] = (select grave from _ids)
            then 'OK   la denuncia grave encabeza la bandeja (paso 2)'
            else 'FALLA orden de la bandeja' end
  from (select id, row_number() over () as ord from public.denuncias_admin()) x
 where id in ((select grave from _ids), (select baja from _ids));

insert into _v (resultado)
select case when jsonb_typeof(d -> 'eventos') = 'array' and d -> 'pedido' ? 'titulo'
            then 'OK   el detalle trae la trazabilidad del pedido (paso 4)'
            else 'FALLA detalle: ' || d::text end
  from public.detalle_denuncia_admin((select grave from _ids)) d;

do $$
begin
    perform public.resolver_denuncia((select baja from _ids), true, 'corto');
    insert into _v (resultado) values ('FALLA se resolvió sin documentar');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%Documentá%'
        then 'OK   resolver exige documentar la resolución' else 'FALLA: ' || sqlerrm end);
end $$;

select public.resolver_denuncia((select baja from _ids), true,
                                'No hay pruebas de que haya cambiado la dirección.');
select public.resolver_denuncia((select grave from _ids), false,
                                'Se comprobó el cobro sin trabajo: suspensión de 30 días.', true, 30, true);

do $$
begin
    perform public.resolver_denuncia((select grave from _ids), true, 'Intento de resolverla dos veces.');
    insert into _v (resultado) values ('FALLA se resolvió dos veces');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%ya fue%'
        then 'OK   una denuncia resuelta no se vuelve a resolver' else 'FALLA doble: ' || sqlerrm end);
end $$;

reset role;

insert into _v (resultado)
select case when (select estado from public.denuncias where id = (select grave from _ids)) = 'resuelta'
             and (select estado from public.perfiles where id = (select profesional from _ids)) = 'suspendido'
             and exists (select 1 from public.sanciones where denuncia_id = (select grave from _ids))
            then 'OK   resuelta con la sanción del CU-36 vinculada a la denuncia'
            else 'FALLA resolución con sanción' end;

insert into _v (resultado)
select case when (select estado from public.denuncias where id = (select baja from _ids)) = 'desestimada'
             and exists (select 1 from public.notificaciones
                          where destinatario_id = (select profesional from _ids)
                            and tipo = 'denuncia_resuelta' and cuerpo like '%no encontramos pruebas%')
            then 'OK   desestimada y el denunciante recibe el aviso (flujo alterno 1.2)'
            else 'FALLA desestimación' end;

do $$
begin
    raise exception E'Resultado del guion de la 0040:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
