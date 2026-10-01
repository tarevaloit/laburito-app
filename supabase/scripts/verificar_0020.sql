-- ============================================================================
-- Guion de aceptación de la migración 0020 (T-09)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0020.sql
--
-- Corre entero dentro de una transacción que termina en ROLLBACK: arma un
-- pedido vigente y uno cerrado de prueba, baja a `authenticated` con los
-- claims de un Profesional y de un Buscador, y comprueba cada regla. No deja
-- ninguna fila. El resultado sale como el mensaje del error final, una línea
-- por regla con OK o FALLA.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select
    (select p.id from public.perfiles p
      where p.tipo = 'buscador' and p.estado = 'activo' and p.deleted_at is null
      order by p.created_at desc limit 1)                            as buscador,
    (select pr.perfil_id from public.profesionales pr
       join public.perfiles p on p.id = pr.perfil_id
      where p.estado = 'activo' and p.deleted_at is null
      order by pr.created_at desc limit 1)                           as profesional,
    (select id from public.categorias_oficio where activa order by orden limit 1) as categoria,
    gen_random_uuid()                                                as vigente,
    gen_random_uuid()                                                as cerrado;
grant select on _ids to authenticated;

insert into public.pedidos (id, buscador_id, categoria_id, titulo, descripcion,
                            ubicacion, direccion_texto, referencia_ubicacion,
                            fecha_vencimiento)
select vigente, buscador, categoria, 'Prueba T-09 vigente',
       'Pedido de prueba del guion de la 0020, se revierte al final.',
       public.punto(-34.52, -58.75), 'Calle falsa 123', 'Piso 3 B',
       now() + interval '7 days'
  from _ids;

insert into public.pedidos (id, buscador_id, categoria_id, titulo, descripcion,
                            ubicacion, direccion_texto, fecha_vencimiento)
select cerrado, buscador, categoria, 'Prueba T-09 cerrado',
       'Pedido de prueba del guion de la 0020, se revierte al final.',
       public.punto(-34.52, -58.75), 'Calle falsa 123', now() + interval '7 days'
  from _ids;

select set_config('app.transicion_estado', 'on', true);
update public.pedidos set estado = 'cerrado', fecha_cierre = now()
 where id = (select cerrado from _ids);
select set_config('app.transicion_estado', 'off', true);

-- Estado de verificación conocido para las pruebas del guard.
update public.profesionales set estado_verificacion = 'sin_documentacion'
 where perfil_id = (select profesional from _ids);

-- ---------------------------------------------------------------------------
-- Como el Profesional
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) = 0 then 'OK   la fila ajena de pedidos no se lee'
            else 'FALLA se leen ' || count(*) || ' filas ajenas de pedidos' end
  from public.pedidos where id = (select vigente from _ids);

insert into _v (resultado)
select case when count(*) = 1 then 'OK   pedidos_publicos trae el vigente'
            else 'FALLA pedidos_publicos no trae el vigente' end
  from public.pedidos_publicos where id = (select vigente from _ids);

insert into _v (resultado)
select case when count(*) = 0 then 'OK   pedidos_publicos no trae el cerrado'
            else 'FALLA pedidos_publicos trae el cerrado' end
  from public.pedidos_publicos where id = (select cerrado from _ids);

insert into _v (resultado)
select case when public.es_pedido_visible((select vigente from _ids))
             and not public.es_pedido_visible((select cerrado from _ids))
            then 'OK   es_pedido_visible distingue vigente de cerrado'
            else 'FALLA es_pedido_visible' end;

do $$
begin
    insert into public.pedido_favorito (profesional_id, pedido_id)
    select profesional, vigente from _ids;
    insert into _v (resultado) values ('OK   guardar un pedido vigente pasa');
exception when others then
    insert into _v (resultado) values ('FALLA guardar un pedido vigente: ' || sqlerrm
        || ' (¿el Profesional está aprobado y activo?)');
end $$;

do $$
begin
    insert into public.pedido_favorito (profesional_id, pedido_id)
    select profesional, cerrado from _ids;
    insert into _v (resultado) values ('FALLA se pudo guardar un pedido cerrado');
exception when others then
    insert into _v (resultado) values ('OK   guardar un pedido cerrado da ' || sqlstate);
end $$;

do $$
begin
    update public.profesionales set saldo_tokens = saldo_tokens + 100
     where perfil_id = auth.uid();
    insert into _v (resultado) values ('FALLA el dueño se cargó tokens');
exception when others then
    insert into _v (resultado) values ('OK   cargarse tokens da ' || sqlerrm);
end $$;

do $$
begin
    update public.profesionales set estado_verificacion = 'aprobado'
     where perfil_id = auth.uid();
    insert into _v (resultado) values ('FALLA el dueño se aprobó solo');
exception when others then
    insert into _v (resultado) values ('OK   aprobarse solo da ' || sqlerrm);
end $$;

do $$
begin
    update public.profesionales set estado_verificacion = 'en_revision'
     where perfil_id = auth.uid();
    insert into _v (resultado) values ('OK   pasar a en_revision (CU-09) pasa');
exception when others then
    insert into _v (resultado) values ('FALLA pasar a en_revision: ' || sqlerrm);
end $$;

do $$
declare v_filas int;
begin
    update public.profesionales set disponible = not disponible
     where perfil_id = auth.uid();
    get diagnostics v_filas = row_count;
    insert into _v (resultado) values (case when v_filas = 1
        then 'OK   cambiar disponible pasa' else 'FALLA cambiar disponible no tocó filas' end);
exception when others then
    insert into _v (resultado) values ('FALLA cambiar disponible: ' || sqlerrm);
end $$;

reset role;

-- ---------------------------------------------------------------------------
-- Como el Buscador dueño
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) = 2 then 'OK   el dueño sigue leyendo sus dos pedidos'
            else 'FALLA el dueño lee ' || count(*) || ' de sus 2 pedidos' end
  from public.pedidos where id in ((select vigente from _ids), (select cerrado from _ids));

do $$
begin
    insert into public.pedido_fotos (pedido_id, storage_path, orden)
    select cerrado, cerrado::text || '/x.jpg', 1 from _ids;
    insert into _v (resultado) values ('FALLA se agregó una foto a un pedido cerrado');
exception when others then
    insert into _v (resultado) values ('OK   foto en pedido cerrado da ' || sqlstate);
end $$;

do $$
begin
    insert into public.pedido_fotos (pedido_id, storage_path, orden)
    select vigente, vigente::text || '/x.jpg', 1 from _ids;
    insert into _v (resultado) values ('OK   foto en pedido vigente pasa');
exception when others then
    insert into _v (resultado) values ('FALLA foto en pedido vigente: ' || sqlerrm);
end $$;

reset role;

-- ---------------------------------------------------------------------------
-- Como anon
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims', '{"role":"anon"}', true);
do $$
begin
    execute 'set local role anon';
    perform count(*) from public.pedidos_publicos;
    reset role;
    insert into _v (resultado) values ('FALLA anon lee pedidos_publicos');
exception when others then
    reset role;
    insert into _v (resultado) values ('OK   anon no lee pedidos_publicos (' || sqlstate || ')');
end $$;

-- ---------------------------------------------------------------------------
-- Catálogo
-- ---------------------------------------------------------------------------
insert into _v (resultado)
select case when not exists (
           select 1 from pg_policy p join pg_class c on c.oid = p.polrelid
            where c.relname = 'pedidos' and p.polname = 'pedidos: lectura de publicados vigentes')
            then 'OK   la política de lectura pública de pedidos ya no existe'
            else 'FALLA la política de lectura pública sigue' end;

insert into _v (resultado)
select case when not has_table_privilege('anon', 'public.pedidos_publicos', 'select')
            then 'OK   anon no tiene SELECT sobre la vista'
            else 'FALLA anon tiene SELECT sobre la vista' end;

-- El resultado sale como el texto de un error a propósito: así la transacción
-- aborta sí o sí y no hay forma de que el guion deje algo escrito, aunque la
-- herramienta con que se corra ignore el ROLLBACK final.
do $$
begin
    raise exception E'Resultado del guion de la 0020:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
