-- ============================================================================
-- Guion de aceptación de la migración 0041 (CU-46)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0041.sql
--
-- Transacción que aborta al final. Simula dos reseñas sobre el Profesional de
-- un contacto desbloqueado: una con insultos (filtro) y una que él reporta.
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
       null::uuid as ofensiva,
       null::uuid as reportada
  from public.contactos_desbloqueados c
  join public.pedidos p on p.id = c.pedido_id
 order by c.created_at desc
 limit 1;
grant select, update on _ids to authenticated;

-- Dos reseñas, cada una con su enlace (la tabla exige uno por reseña).
delete from public.calificaciones
 where profesional_id = (select profesional from _ids) and pedido_id = (select pedido from _ids);

with e as (
    insert into public.enlaces_calificacion (profesional_id, pedido_id, token_hash, usado_at)
    select profesional, pedido, public.hash_token('guion-0041-a'), now() from _ids
    returning id),
c as (
    insert into public.calificaciones (profesional_id, pedido_id, enlace_id, puntaje, comentario, autor_nombre)
    select profesional, pedido, (select id from e), 1, 'Un estafador, no lo contraten.', 'Laura' from _ids
    returning id)
update _ids set ofensiva = (select id from c);

insert into _v (resultado)
select case when revision_automatica then 'OK   el filtro automático marca la reseña con insultos'
            else 'FALLA el filtro no la marcó' end
  from public.calificaciones where id = (select ofensiva from _ids);

-- La segunda: sin insultos, para que la reporte el Profesional. Otro pedido
-- no hay, así que se reusa el mismo con la primera ya ocultada a mano.
update public.calificaciones set oculta = true where id = (select ofensiva from _ids);
alter table public.calificaciones drop constraint calificaciones_una_por_contacto_uq;

with e as (
    insert into public.enlaces_calificacion (profesional_id, pedido_id, token_hash, usado_at)
    select profesional, pedido, public.hash_token('guion-0041-b'), now() from _ids
    returning id),
c as (
    insert into public.calificaciones (profesional_id, pedido_id, enlace_id, puntaje, comentario, autor_nombre)
    select profesional, pedido, (select id from e), 1, 'No vino nunca y no avisó.', 'Laura' from _ids
    returning id)
update _ids set reportada = (select id from c);
update public.calificaciones set oculta = false where id = (select ofensiva from _ids);

-- Como el Profesional.
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.reportar_resena((select reportada from _ids), 'mal');
    insert into _v (resultado) values ('FALLA se reportó sin motivo');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%10 caracteres%'
        then 'OK   reportar exige el motivo' else 'FALLA motivo: ' || sqlerrm end);
end $$;

select public.reportar_resena((select reportada from _ids), 'El pedido se canceló antes de que yo fuera.');

do $$
begin
    perform public.reportar_resena((select reportada from _ids), 'Lo reporto otra vez por las dudas.');
    insert into _v (resultado) values ('FALLA se reportó dos veces');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%Ya reportaste%'
        then 'OK   una reseña se reporta una sola vez' else 'FALLA doble: ' || sqlerrm end);
end $$;

reset role;

-- Como admin.
select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) filter (where id = (select ofensiva from _ids)) = 1
             and count(*) filter (where id = (select reportada from _ids)) = 1
            then 'OK   la cola trae la reportada y la del filtro (paso 2)'
            else 'FALLA cola: ' || count(*) end
  from public.resenas_a_moderar();

select public.moderar_resena((select ofensiva from _ids), true);
select public.moderar_resena((select reportada from _ids), false);

reset role;

insert into _v (resultado)
select case when c.oculta and c.moderacion = 'eliminada'
             and pr.total_calificaciones = (select count(*) from public.calificaciones
                                             where profesional_id = pr.perfil_id and not oculta)
            then 'OK   eliminada: oculta y el promedio recalculado sin ella'
            else 'FALLA eliminación' end
  from public.calificaciones c
  join public.profesionales pr on pr.perfil_id = c.profesional_id
 where c.id = (select ofensiva from _ids);

insert into _v (resultado)
select case when not oculta and moderacion = 'mantenida'
            then 'OK   desestimar mantiene la reseña intacta (flujo alterno 1.2)'
            else 'FALLA mantenida' end
  from public.calificaciones where id = (select reportada from _ids);

insert into _v (resultado)
select case when exists (select 1 from public.notificaciones
                          where destinatario_id = (select buscador from _ids) and tipo = 'resena_eliminada')
             and exists (select 1 from public.notificaciones
                          where destinatario_id = (select profesional from _ids)
                            and tipo = 'denuncia_resuelta' and titulo like 'Revisamos%')
            then 'OK   se avisa al autor y al Profesional que reportó'
            else 'FALLA avisos de moderación' end;

do $$
begin
    raise exception E'Resultado del guion de la 0041:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
