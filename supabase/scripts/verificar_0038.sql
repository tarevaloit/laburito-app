-- ============================================================================
-- Guion de aceptación de la migración 0038 (CU-37)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0038.sql
--
-- Transacción que aborta al final. Necesita un administrador y un Buscador.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select (select id from public.perfiles where tipo = 'administrador' and estado = 'activo' limit 1) as admin,
       (select id from public.perfiles where tipo = 'buscador' and estado = 'activo' limit 1)      as buscador,
       (select id from public.categorias_oficio where slug = 'plomeria')                           as plomeria,
       null::uuid as nueva;
grant select, update on _ids to authenticated;

select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.crear_categoria('Plomería industrial');
    insert into _v (resultado) values ('FALLA un Buscador creó una categoría');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%administrador%'
        then 'OK   un Buscador no gestiona categorías' else 'FALLA: ' || sqlerrm end);
end $$;

reset role;

select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) >= 22 and bool_and(icono is not null)
            then 'OK   el admin ve el catálogo con sus íconos (' || count(*) || ')'
            else 'FALLA catálogo: ' || count(*) || ' sin ícono ' || count(*) filter (where icono is null) end
  from public.categorias_admin();

do $$
begin
    perform public.crear_categoria('  plomeria ', '🔧');
    insert into _v (resultado) values ('FALLA se repitió Plomería sin tilde');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%Ya existe%'
        then 'OK   «plomeria» repite «Plomería» (paso 4)' else 'FALLA duplicado: ' || sqlerrm end);
end $$;

update _ids set nueva = public.crear_categoria('Pileteros', '🏊');

insert into _v (resultado)
select case when c.slug = 'pileteros' and c.activa
            then 'OK   la categoría nueva queda activa con slug legible'
            else 'FALLA alta: ' || coalesce(c.slug, 'sin fila') end
  from public.categorias_oficio c where c.id = (select nueva from _ids);

select public.editar_categoria((select nueva from _ids), 'Piletas y piscinas', '🏊');
select public.cambiar_visibilidad_categoria((select nueva from _ids), false);

reset role;

-- Un usuario común ya no la ve.
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when not exists (select 1 from public.categorias_oficio where id = (select nueva from _ids))
            then 'OK   una categoría oculta desaparece del catálogo público'
            else 'FALLA la oculta se sigue viendo' end;

reset role;

select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.eliminar_categoria((select plomeria from _ids));
    insert into _v (resultado) values ('FALLA se borró Plomería con datos asociados');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%Ocultala%'
        then 'OK   con datos asociados sugiere ocultar (flujo alterno 1.2)' else 'FALLA borrado: ' || sqlerrm end);
end $$;

select public.eliminar_categoria((select nueva from _ids));

insert into _v (resultado)
select case when not exists (select 1 from public.categorias_oficio where id = (select nueva from _ids))
            then 'OK   una categoría sin uso se elimina'
            else 'FALLA no se eliminó' end;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0038:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
