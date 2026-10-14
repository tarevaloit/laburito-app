-- ============================================================================
-- Guion de aceptación de la migración 0030 (CU-28)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0030.sql
--
-- Transacción que aborta al final; el resultado sale como el mensaje del error.
-- Necesita al menos un contacto desbloqueado (CU-25).
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated, anon;
grant usage, select on sequence _v_orden_seq to authenticated, anon;

create temp table _ids on commit drop as
select c.profesional_id as profesional,
       c.pedido_id      as pedido,
       null::text       as token1,
       null::text       as token2
  from public.contactos_desbloqueados c
  join public.perfiles p on p.id = c.profesional_id
 where p.estado = 'activo'
   and not exists (select 1 from public.calificaciones cal
                    where cal.profesional_id = c.profesional_id
                      and cal.pedido_id = c.pedido_id)
 order by c.created_at desc
 limit 1;
grant all on _ids to authenticated, anon;

insert into _v (resultado)
select case when (select count(*) from _ids) = 1
            then 'OK   hay un contacto sin calificar para probar'
            else 'FALLA no hay contactos sin calificar: el resto no prueba nada' end;

insert into _v (resultado)
select case when has_function_privilege('anon', 'public.registrar_calificacion(text, integer, text)', 'execute')
             and has_function_privilege('anon', 'public.enlace_calificacion_info(text)', 'execute')
             and not has_function_privilege('anon', 'public.generar_enlace_calificacion(uuid)', 'execute')
             and not has_function_privilege('anon', 'public.mis_contactos()', 'execute')
            then 'OK   anon califica y consulta; no genera enlaces ni lista contactos'
            else 'FALLA permisos de anon sobre las funciones del CU-28' end;

-- Como el Profesional del contacto.
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.generar_enlace_calificacion(gen_random_uuid());
    insert into _v (resultado) values ('FALLA se generó un enlace sin contacto');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%desbloqueado el contacto%'
        then 'OK   sin contacto desbloqueado da sin_contacto'
        else 'FALLA sin contacto: ' || sqlerrm end);
end $$;

do $$
declare
    v_t1 text;
    v_t2 text;
    v_contactos int;
begin
    v_t1 := public.generar_enlace_calificacion((select pedido from _ids));
    v_t2 := public.generar_enlace_calificacion((select pedido from _ids));
    update _ids set token1 = v_t1, token2 = v_t2;
    insert into _v (resultado) values (case
        when v_t1 ~ '^[0-9a-f]{32}$' and v_t1 <> v_t2
        then 'OK   cada pedido de enlace da un token nuevo de 32 caracteres'
        else 'FALLA tokens: ' || v_t1 || ' / ' || v_t2 end);

    select count(*) into v_contactos from public.mis_contactos()
     where pedido_id = (select pedido from _ids) and not calificado;
    insert into _v (resultado) values (case when v_contactos = 1
        then 'OK   mis_contactos muestra el contacto sin calificar'
        else 'FALLA mis_contactos: ' || v_contactos end);
end $$;

reset role;

insert into _v (resultado)
select case when not exists (select 1 from public.enlaces_calificacion
                              where token_hash in (token1, token2))
             and exists (select 1 from public.enlaces_calificacion
                          where token_hash = public.hash_token(token2) and anulado_at is null)
             and exists (select 1 from public.enlaces_calificacion
                          where token_hash = public.hash_token(token1) and anulado_at is not null)
            then 'OK   se guarda el hash, no el token; el segundo enlace anula el primero'
            else 'FALLA almacenamiento o anulación de los enlaces' end
  from _ids;

create temp table _antes on commit drop as
select calificacion_promedio, total_calificaciones
  from public.profesionales where perfil_id = (select profesional from _ids);
grant select on _antes to anon;

-- Como el Buscador, sin sesión.
select set_config('request.jwt.claims', json_build_object('role', 'anon')::text, true);
set local role anon;

insert into _v (resultado)
select case when public.enlace_calificacion_info(token2)->>'estado' = 'disponible'
             and public.enlace_calificacion_info(token2) ? 'nombre'
             and public.enlace_calificacion_info(token1)->>'estado' = 'invalido'
             and public.enlace_calificacion_info('cualquiera')->>'estado' = 'invalido'
            then 'OK   info: el vigente está disponible; el anulado y uno inventado, inválidos'
            else 'FALLA info: ' || public.enlace_calificacion_info(token2)::text end
  from _ids;

do $$
begin
    perform public.registrar_calificacion((select token2 from _ids), 0, null);
    insert into _v (resultado) values ('FALLA se aceptó un puntaje de 0');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%1 a 5%'
        then 'OK   un puntaje de 0 da puntaje_invalido'
        else 'FALLA puntaje 0: ' || sqlerrm end);
end $$;

do $$
begin
    perform public.registrar_calificacion((select token1 from _ids), 5, null);
    insert into _v (resultado) values ('FALLA se calificó con un enlace anulado');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%no es válido%'
        then 'OK   el enlace anulado da enlace_invalido'
        else 'FALLA anulado: ' || sqlerrm end);
end $$;

do $$
declare
    v_res jsonb;
begin
    v_res := public.registrar_calificacion((select token2 from _ids), 4, '  Muy prolijo.  ');
    insert into _v (resultado) values (case when v_res ? 'nombre'
        then 'OK   anon califica con el enlace vigente'
        else 'FALLA registrar: ' || v_res::text end);
end $$;

do $$
begin
    perform public.registrar_calificacion((select token2 from _ids), 5, null);
    insert into _v (resultado) values ('FALLA el mismo enlace calificó dos veces');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%ya se usó%'
        then 'OK   el segundo uso del enlace da enlace_usado'
        else 'FALLA segundo uso: ' || sqlerrm end);
end $$;

insert into _v (resultado)
select case when public.enlace_calificacion_info(token2)->>'estado' = 'usado'
            then 'OK   info del enlace usado: usado'
            else 'FALLA info usado: ' || public.enlace_calificacion_info(token2)::text end
  from _ids;

reset role;

insert into _v (resultado)
select case when c.comentario = 'Muy prolijo.' and c.puntaje = 4
             and pr.total_calificaciones = a.total_calificaciones + 1
             and pr.calificacion_promedio = (select round(avg(puntaje)::numeric, 2)
                                               from public.calificaciones
                                              where profesional_id = i.profesional and not oculta)
            then 'OK   la reseña queda recortada y el promedio y el total se recalculan ('
                 || coalesce(a.calificacion_promedio::text, 'sin') || ' → ' || pr.calificacion_promedio || ')'
            else 'FALLA reseña o promedio: ' || coalesce(pr.calificacion_promedio::text, 'null') end
  from _ids i
  join public.calificaciones c on c.profesional_id = i.profesional and c.pedido_id = i.pedido
  join public.profesionales pr on pr.perfil_id = i.profesional
  cross join _antes a;

select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.generar_enlace_calificacion((select pedido from _ids));
    insert into _v (resultado) values ('FALLA un contacto calificado generó otro enlace');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%ya te calificó%'
        then 'OK   un contacto ya calificado da ya_calificado'
        else 'FALLA ya calificado: ' || sqlerrm end);
end $$;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0030:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
