-- ============================================================================
-- Guion de aceptación de la migración 0027 (T-11)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0027.sql
--
-- Todo dentro de una transacción que aborta al final: el resultado sale como
-- el mensaje del error, una línea por regla con OK o FALLA.
--
-- Necesita al menos un contacto desbloqueado (CU-25) en la base.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select c.profesional_id as profesional,
       c.pedido_id      as pedido,
       p.buscador_id    as buscador
  from public.contactos_desbloqueados c
  join public.pedidos p on p.id = c.pedido_id
 order by c.created_at desc
 limit 1;
grant select on _ids to authenticated;

insert into _v (resultado)
select case when count(*) = 6 then 'OK   RLS activa en las seis tablas'
            else 'FALLA RLS activa solo en ' || count(*) || ' de 6' end
  from pg_class
 where relnamespace = 'public'::regnamespace and relrowsecurity
   and relname in ('perfiles_publicos', 'perfil_visitas', 'enlaces_calificacion',
                   'calificaciones', 'notificaciones', 'denuncias');

insert into _v (resultado)
select case when count(*) = 2
             and bool_and(tablename = 'notificaciones')
            then 'OK   solo notificaciones tiene políticas de escritura (marcar y borrar)'
            else 'FALLA políticas de escritura: ' || coalesce(string_agg(tablename || '.' || cmd, ', '), 'ninguna') end
  from pg_policies
 where schemaname = 'public'
   and tablename in ('perfiles_publicos', 'perfil_visitas', 'enlaces_calificacion',
                     'calificaciones', 'notificaciones', 'denuncias')
   and cmd <> 'SELECT';

insert into _v (resultado)
select case when exists (select 1 from pg_publication_tables
                          where pubname = 'supabase_realtime' and tablename = 'notificaciones')
            then 'OK   notificaciones publicada en Realtime'
            else 'FALLA notificaciones no está en supabase_realtime' end;

insert into _v (resultado)
select case when (select count(*) from _ids) = 1
            then 'OK   hay un contacto desbloqueado para probar'
            else 'FALLA no hay contactos desbloqueados: el resto del guion no prueba nada' end;

-- Un enlace sin contacto desbloqueado no se puede crear.
do $$
begin
    insert into public.enlaces_calificacion (profesional_id, pedido_id, token_hash)
    select profesional, gen_random_uuid(), repeat('a', 64) from _ids;
    insert into _v (resultado) values ('FALLA se creó un enlace sin contacto desbloqueado');
exception when foreign_key_violation then
    insert into _v (resultado) values ('OK   un enlace sin contacto desbloqueado da 23503');
end $$;

-- Un enlace vivo por contacto.
insert into public.enlaces_calificacion (profesional_id, pedido_id, token_hash)
select profesional, pedido, repeat('b', 64) from _ids;

do $$
begin
    insert into public.enlaces_calificacion (profesional_id, pedido_id, token_hash)
    select profesional, pedido, repeat('c', 64) from _ids;
    insert into _v (resultado) values ('FALLA dos enlaces vivos para el mismo contacto');
exception when unique_violation then
    insert into _v (resultado) values ('OK   un segundo enlace vivo para el mismo contacto da 23505');
end $$;

-- Puntaje fuera de rango.
do $$
begin
    insert into public.calificaciones (profesional_id, pedido_id, enlace_id, puntaje, autor_nombre)
    select i.profesional, i.pedido, e.id, 6, 'Prueba'
      from _ids i join public.enlaces_calificacion e
        on e.profesional_id = i.profesional and e.pedido_id = i.pedido;
    insert into _v (resultado) values ('FALLA se guardó un puntaje de 6');
exception when check_violation then
    insert into _v (resultado) values ('OK   un puntaje de 6 da 23514');
end $$;

-- Una notificación para el Buscador, y el Buscador intentando reescribirla.
insert into public.notificaciones (destinatario_id, tipo, titulo, ruta)
select buscador, 'nuevo_interesado', 'Prueba del guion', '/pedidos/' || pedido from _ids;

-- Autodenuncia.
do $$
begin
    insert into public.denuncias (denunciante_id, denunciado_id, motivo, descripcion)
    select buscador, buscador, 'otro', 'Descripción de prueba del guion' from _ids;
    insert into _v (resultado) values ('FALLA se guardó una autodenuncia');
exception when check_violation then
    insert into _v (resultado) values ('OK   una autodenuncia da 23514');
end $$;

-- Desde acá, como el Buscador del contacto.
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
declare
    v_filas int;
begin
    update public.notificaciones set leida_at = now()
     where titulo = 'Prueba del guion';
    get diagnostics v_filas = row_count;
    insert into _v (resultado) values (case when v_filas = 1
        then 'OK   el destinatario marca su notificación como leída'
        else 'FALLA marcar leída actualizó ' || v_filas || ' filas' end);
end $$;

do $$
begin
    update public.notificaciones set titulo = 'Reescrita'
     where titulo = 'Prueba del guion';
    insert into _v (resultado) values ('FALLA el destinatario reescribió el título');
exception when others then
    insert into _v (resultado) values ('OK   reescribir el título da ' || sqlstate);
end $$;

do $$
begin
    insert into public.notificaciones (destinatario_id, tipo, titulo)
    values (auth.uid(), 'pago_acreditado', 'Inventada');
    insert into _v (resultado) values ('FALLA un cliente insertó una notificación');
exception when others then
    insert into _v (resultado) values ('OK   insertar una notificación por la API da ' || sqlstate);
end $$;

do $$
begin
    insert into public.denuncias (denunciante_id, denunciado_id, motivo, descripcion)
    select auth.uid(), profesional, 'otro', 'Descripción de prueba del guion' from _ids;
    insert into _v (resultado) values ('FALLA un cliente insertó una denuncia sin la función');
exception when others then
    insert into _v (resultado) values ('OK   insertar una denuncia por la API da ' || sqlstate);
end $$;

insert into _v (resultado)
select case when count(*) = 0
            then 'OK   el Buscador no ve los enlaces de calificación del Profesional'
            else 'FALLA el Buscador ve ' || count(*) || ' enlaces ajenos' end
  from public.enlaces_calificacion;

do $$
declare
    v_filas int;
begin
    delete from public.notificaciones where titulo = 'Prueba del guion';
    get diagnostics v_filas = row_count;
    insert into _v (resultado) values (case when v_filas = 1
        then 'OK   el destinatario borra su notificación'
        else 'FALLA borrar la notificación afectó ' || v_filas || ' filas' end);
end $$;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0027:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
