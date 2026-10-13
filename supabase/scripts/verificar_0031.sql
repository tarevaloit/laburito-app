-- ============================================================================
-- Guion de aceptación de la migración 0031 (CU-48)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0031.sql
--
-- Transacción que aborta al final; el resultado sale como el mensaje del error.
-- Provoca cada evento como dueño de las tablas y mira el aviso que dejó.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select
    (select pr.perfil_id from public.profesionales pr
       join public.perfiles p on p.id = pr.perfil_id
      where p.estado = 'activo' order by pr.created_at limit 1) as profesional,
    (select p.id from public.pedidos p
      where not exists (select 1 from public.contactos_desbloqueados c
                         where c.pedido_id = p.id
                           and c.profesional_id = (select pr.perfil_id from public.profesionales pr
                                                     join public.perfiles pe on pe.id = pr.perfil_id
                                                    where pe.estado = 'activo'
                                                    order by pr.created_at limit 1))
      order by p.created_at desc limit 1) as pedido,
    (select id from public.movimientos_tokens limit 1) as movimiento,
    (select id from public.paquetes_tokens where nombre = 'Plata') as plata;
grant select on _ids to authenticated;

insert into _v (resultado)
select case when not has_function_privilege('authenticated',
                'public.notificar(uuid, public.notificacion_tipo, text, text, text)', 'execute')
             and not has_function_privilege('anon',
                'public.notificar(uuid, public.notificacion_tipo, text, text, text)', 'execute')
            then 'OK   notificar no la ejecuta ningún cliente'
            else 'FALLA notificar es ejecutable por un cliente' end;

-- 1. Nuevo interesado.
insert into public.contactos_desbloqueados (profesional_id, pedido_id, movimiento_id)
select profesional, pedido, movimiento from _ids;

insert into _v (resultado)
select case when count(*) = 1 and bool_and(n.ruta = '/pedidos/' || i.pedido)
            then 'OK   desbloquear un contacto avisa al Buscador del pedido'
            else 'FALLA aviso de interesado: ' || count(*) end
  from _ids i
  join public.pedidos p on p.id = i.pedido
  join public.notificaciones n on n.destinatario_id = p.buscador_id
 where n.tipo = 'nuevo_interesado' and n.created_at = now();

-- 2. Calificación.
insert into public.enlaces_calificacion (profesional_id, pedido_id, token_hash)
select profesional, pedido, public.hash_token('token-del-guion-0031') from _ids;

select public.registrar_calificacion('token-del-guion-0031', 5, 'Impecable');

insert into _v (resultado)
select case when count(*) = 1 and bool_and(n.titulo like '% te calificó con 5 estrellas'
                                           and n.cuerpo = '«Impecable»')
            then 'OK   una calificación avisa al Profesional con las estrellas y el comentario'
            else 'FALLA aviso de calificación: ' || count(*) end
  from _ids i
  join public.notificaciones n on n.destinatario_id = i.profesional
 where n.tipo = 'calificacion_recibida' and n.created_at = now();

-- 3. Verificación rechazada y vuelta a aprobada.
create temp table _estado on commit drop as
select estado_verificacion from public.profesionales where perfil_id = (select profesional from _ids);

update public.profesionales set estado_verificacion = 'rechazado'
 where perfil_id = (select profesional from _ids);
update public.profesionales set estado_verificacion = 'aprobado'
 where perfil_id = (select profesional from _ids);

insert into _v (resultado)
select case when count(*) filter (where n.tipo = 'verificacion_rechazada' and n.ruta = '/verificacion') = 1
             and count(*) filter (where n.tipo = 'verificacion_aprobada') = 1
            then 'OK   rechazar y aprobar la documentación avisan cada uno una vez'
            else 'FALLA avisos de verificación: ' || count(*) end
  from _ids i
  join public.notificaciones n on n.destinatario_id = i.profesional
 where n.tipo in ('verificacion_rechazada', 'verificacion_aprobada') and n.created_at = now();

-- 4. Pago aprobado.
insert into public.pagos (id, profesional_id, paquete_id, paquete_nombre, cantidad_tokens, monto_ars)
select '00000000-0000-4000-8000-000000000031', profesional, plata, 'Plata', 10, 8000 from _ids;

update public.pagos
   set estado = 'aprobado', aprobado_at = now(),
       mp_payment_id = 'guion-0031', numero_comprobante = 999000031
 where id = '00000000-0000-4000-8000-000000000031';

insert into _v (resultado)
select case when count(*) = 1 and bool_and(n.titulo = 'Se acreditaron 10 tokens')
            then 'OK   un pago aprobado avisa la acreditación'
            else 'FALLA aviso de pago: ' || count(*) end
  from _ids i
  join public.notificaciones n on n.destinatario_id = i.profesional
 where n.tipo = 'pago_acreditado' and n.created_at = now();

-- 5. Denuncia.
insert into public.denuncias (denunciante_id, denunciado_id, motivo, descripcion)
select p.buscador_id, i.profesional, 'incumplimiento', 'No vino el día que acordamos.'
  from _ids i join public.pedidos p on p.id = i.pedido;

insert into _v (resultado)
select case when count(*) = (select count(*) from public.perfiles
                              where tipo = 'administrador' and estado = 'activo' and deleted_at is null)
            then 'OK   una denuncia avisa a cada administrador activo (' || count(*) || ')'
            else 'FALLA avisos de denuncia: ' || count(*) end
  from public.notificaciones n
 where n.tipo = 'denuncia_recibida' and n.created_at = now();

-- Visibilidad: como el Profesional, no ve el aviso del Buscador.
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) filter (where tipo = 'nuevo_interesado') = 0
             and count(*) filter (where tipo = 'pago_acreditado') >= 1
            then 'OK   cada uno ve solo sus avisos'
            else 'FALLA visibilidad de avisos' end
  from public.notificaciones
 where created_at = now();

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0031:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
