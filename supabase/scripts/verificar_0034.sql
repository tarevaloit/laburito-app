-- ============================================================================
-- Guion de aceptación de la migración 0034 (T-12, T-13)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0034.sql
--
-- Transacción que aborta al final; el resultado sale como el mensaje del error.
-- Necesita un Buscador activo.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select id as usuario
  from public.perfiles
 where tipo = 'buscador' and estado = 'activo' and deleted_at is null
 order by created_at
 limit 1;
grant select on _ids to authenticated;

insert into _v (resultado)
select case when count(*) = 5 then 'OK   RLS activa en las cinco tablas nuevas'
            else 'FALLA RLS activa solo en ' || count(*) || ' de 5' end
  from pg_class
 where relnamespace = 'public'::regnamespace and relrowsecurity
   and relname in ('accesos_admin', 'sanciones', 'apelaciones',
                   'parametros_sistema', 'preguntas_frecuentes');

insert into _v (resultado)
select case when count(*) = 0 then 'OK   ninguna tabla nueva tiene políticas de escritura'
            else 'FALLA políticas de escritura: ' || string_agg(tablename || '/' || cmd, ', ') end
  from pg_policies
 where schemaname = 'public'
   and tablename in ('accesos_admin', 'sanciones', 'apelaciones',
                     'parametros_sistema', 'preguntas_frecuentes')
   and cmd <> 'SELECT';

insert into _v (resultado)
select case when count(*) = 3 then 'OK   tres parámetros globales cargados'
            else 'FALLA parámetros: ' || count(*) end
  from public.parametros_sistema;

do $$
begin
    update public.parametros_sistema set valor = 500 where clave = 'radio_maximo_km';
    insert into _v (resultado) values ('FALLA se aceptó un radio de 500 km');
exception when check_violation then
    insert into _v (resultado) values ('OK   un parámetro fuera de rango lo rechaza el check');
end $$;

-- Como el Buscador, por la API.
select set_config('request.jwt.claims',
                  json_build_object('sub', usuario, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    update public.perfiles set tipo = 'administrador' where id = auth.uid();
    insert into _v (resultado) values ('FALLA un usuario se dio el rol de administrador');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%CAMPO_NO_MODIFICABLE%'
        then 'OK   T-13: nadie se da el rol de administrador por PATCH' else 'FALLA tipo: ' || sqlerrm end);
end $$;

do $$
begin
    update public.perfiles set estado = 'activo' where id = auth.uid() and estado = 'activo';
    update public.perfiles set estado = 'suspendido' where id = auth.uid();
    insert into _v (resultado) values ('FALLA un usuario se cambió el estado');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%CAMPO_NO_MODIFICABLE%'
        then 'OK   T-13: el estado de la cuenta no se escribe por PATCH' else 'FALLA estado: ' || sqlerrm end);
end $$;

do $$
declare
    v_n integer;
begin
    update public.perfiles set telefono = telefono where id = auth.uid();
    get diagnostics v_n = row_count;
    insert into _v (resultado) values (case when v_n = 1
        then 'OK   el dueño sigue editando sus datos de contacto (CU-05)'
        else 'FALLA CU-05 actualizó ' || v_n || ' filas' end);
end $$;

insert into _v (resultado)
select case when count(*) = 0 then 'OK   un usuario común no ve los accesos al panel'
            else 'FALLA ve ' || count(*) || ' accesos' end
  from public.accesos_admin;

insert into _v (resultado)
select case when count(*) = 3 then 'OK   los parámetros se leen con sesión'
            else 'FALLA lectura de parámetros: ' || count(*) end
  from public.parametros_sistema;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0034:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
