-- ============================================================================
-- Guion de aceptación de las migraciones 0028 y 0029 (CU-26, CU-27)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0028_0029.sql
--
-- Transacción que aborta al final; el resultado sale como el mensaje del error.
-- Necesita un Profesional activo y aprobado, y un Buscador.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select
    (select pr.perfil_id from public.profesionales pr
       join public.perfiles p on p.id = pr.perfil_id
      where p.estado = 'activo' and p.deleted_at is null
        and pr.estado_verificacion = 'aprobado'
      order by pr.created_at limit 1) as profesional,
    (select id from public.perfiles
      where tipo = 'buscador' and estado = 'activo' limit 1) as buscador,
    null::text as slug;
grant all on _ids to authenticated;

insert into _v (resultado)
select case when public.slug_de_nombre('Marcelo', 'Gómez') = 'marcelo-gomez'
             and public.slug_de_nombre('  José María ', 'Núñez-Peña') = 'jose-maria-nunez-pena'
            then 'OK   slug_de_nombre: sin tildes ni símbolos'
            else 'FALLA slug_de_nombre: ' || public.slug_de_nombre('Marcelo', 'Gómez') end;

insert into _v (resultado)
select case when not has_function_privilege('anon', 'public.perfil_publico_datos(text)', 'execute')
             and not has_function_privilege('authenticated', 'public.perfil_publico_datos(text)', 'execute')
             and has_function_privilege('service_role', 'public.perfil_publico_datos(text)', 'execute')
            then 'OK   perfil_publico_datos solo la ejecuta service_role'
            else 'FALLA perfil_publico_datos es ejecutable por un cliente' end;

insert into _v (resultado)
select case when not has_function_privilege('anon', 'public.obtener_enlace_perfil()', 'execute')
            then 'OK   obtener_enlace_perfil no la ejecuta anon'
            else 'FALLA anon ejecuta obtener_enlace_perfil' end;

-- Como el Profesional aprobado.
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
declare
    v_uno text;
    v_dos text;
begin
    v_uno := public.obtener_enlace_perfil();
    v_dos := public.obtener_enlace_perfil();
    update _ids set slug = v_uno;
    insert into _v (resultado) values (case
        when v_uno ~ '^[a-z0-9-]+-[0-9a-f]{6}$' and v_uno = v_dos
        then 'OK   el Profesional aprobado obtiene su slug, siempre el mismo (' || v_uno || ')'
        else 'FALLA slug: ' || coalesce(v_uno, 'null') || ' / ' || coalesce(v_dos, 'null') end);
end $$;

reset role;

-- Como un Buscador.
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.obtener_enlace_perfil();
    insert into _v (resultado) values ('FALLA un Buscador obtuvo un perfil público');
exception when others then
    insert into _v (resultado) values ('OK   un Buscador recibe ' || sqlerrm);
end $$;

reset role;

-- La función de la Edge Function, como dueña.
do $$
declare
    v_antes int;
    v_datos jsonb;
    v_despues int;
begin
    select count(*) into v_antes from public.perfil_visitas
     where profesional_id = (select profesional from _ids);
    v_datos := public.perfil_publico_datos((select slug from _ids));
    select count(*) into v_despues from public.perfil_visitas
     where profesional_id = (select profesional from _ids);
    insert into _v (resultado) values (case
        when v_datos ? 'nombre' and v_datos ? 'oficios' and v_datos ? 'resenas'
             and not v_datos ? 'telefono' and not v_datos ? 'email'
             and v_despues = v_antes + 1
        then 'OK   perfil_publico_datos devuelve el perfil sin contacto y registra la visita'
        else 'FALLA perfil_publico_datos: ' || coalesce(v_datos::text, 'null')
             || ' visitas ' || v_antes || ' → ' || v_despues end);

    v_datos := public.perfil_publico_datos('no-existe-000000');
    insert into _v (resultado) values (case when v_datos is null
        then 'OK   un slug inexistente devuelve null'
        else 'FALLA un slug inexistente devolvió datos' end);
end $$;

-- Flujo alterno: cuenta suspendida.
update public.perfiles set estado = 'suspendido'
 where id = (select profesional from _ids);

do $$
begin
    insert into _v (resultado) values (case
        when public.perfil_publico_datos((select slug from _ids)) is null
        then 'OK   el perfil de una cuenta suspendida no se muestra'
        else 'FALLA el perfil suspendido se sigue mostrando' end);
end $$;

select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.obtener_enlace_perfil();
    insert into _v (resultado) values ('FALLA una cuenta suspendida compartió su perfil');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%inhabilitada%'
        then 'OK   una cuenta suspendida recibe cuenta_suspendida'
        else 'FALLA suspendida: ' || sqlerrm end);
end $$;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0028 y la 0029:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
