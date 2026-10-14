-- ============================================================================
-- Guion de aceptación de la migración 0033 (CU-41)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0033.sql
--
-- Transacción que aborta al final; el resultado sale como el mensaje del error.
-- Necesita un Profesional con slug público (0028) y un contacto desbloqueado.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select c.profesional_id as profesional,
       c.pedido_id      as pedido,
       p.buscador_id    as buscador,
       (select slug from public.perfiles_publicos where profesional_id = c.profesional_id) as slug,
       (select id from public.perfiles where tipo = 'administrador' and estado = 'activo' limit 1) as admin
  from public.contactos_desbloqueados c
  join public.pedidos p on p.id = c.pedido_id
 order by c.created_at desc
 limit 1;
grant select on _ids to authenticated;

-- Si el Profesional todavía no compartió su perfil, se le crea el slug acá.
insert into public.perfiles_publicos (profesional_id, slug)
select profesional, 'guion-0033-000000' from _ids where slug is null;
update _ids set slug = coalesce(slug, 'guion-0033-000000');

-- Como el Buscador: denuncia al Profesional por el slug.
select set_config('request.jwt.claims',
                  json_build_object('sub', buscador, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.reportar_usuario(null, 'No vino el día acordado.', (select slug from _ids));
    insert into _v (resultado) values ('FALLA se aceptó un reporte sin motivo');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%motivo%'
        then 'OK   sin motivo da motivo_requerido' else 'FALLA sin motivo: ' || sqlerrm end);
end $$;

do $$
begin
    perform public.reportar_usuario('incumplimiento', 'corto', (select slug from _ids));
    insert into _v (resultado) values ('FALLA se aceptó una descripción de 5 caracteres');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%10 caracteres%'
        then 'OK   una descripción corta da descripcion_corta' else 'FALLA corta: ' || sqlerrm end);
end $$;

do $$
declare
    v_id uuid;
begin
    v_id := public.reportar_usuario('incumplimiento', '  No vino el día acordado.  ', (select slug from _ids));
    insert into _v (resultado) values (case when exists (
            select 1 from public.denuncias d, _ids i
             where d.id = v_id and d.denunciante_id = i.buscador
               and d.denunciado_id = i.profesional and d.descripcion = 'No vino el día acordado.')
        then 'OK   el Buscador denuncia al Profesional por el slug'
        else 'FALLA la denuncia no quedó como se esperaba' end);
end $$;

do $$
begin
    perform public.reportar_usuario('otro', 'Insisto con lo mismo de antes.', (select slug from _ids));
    insert into _v (resultado) values ('FALLA dos denuncias abiertas para el mismo par');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%reporte abierto%'
        then 'OK   una segunda denuncia abierta da denuncia_abierta' else 'FALLA repetida: ' || sqlerrm end);
end $$;

do $$
begin
    perform public.denuncias_admin();
    insert into _v (resultado) values ('FALLA un Buscador listó las denuncias');
exception when others then
    insert into _v (resultado) values ('OK   denuncias_admin rechaza a quien no es admin');
end $$;

reset role;

-- Como el Profesional: denuncia al Buscador por el pedido desbloqueado.
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

do $$
begin
    perform public.reportar_usuario('comportamiento_inapropiado',
                                    'Me trató mal por teléfono.', null, (select pedido from _ids));
    insert into _v (resultado) values ('OK   el Profesional denuncia al Buscador por el pedido');
exception when others then
    insert into _v (resultado) values ('FALLA denuncia por pedido: ' || sqlerrm);
end $$;

do $$
begin
    perform public.reportar_usuario('otro', 'Me reporto a mí mismo.', (select slug from _ids));
    insert into _v (resultado) values ('FALLA se aceptó una autodenuncia');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%vos mismo%'
        then 'OK   reportarse a uno mismo da autodenuncia' else 'FALLA autodenuncia: ' || sqlerrm end);
end $$;

do $$
begin
    perform public.reportar_usuario('otro', 'Un pedido que no existe.', null, gen_random_uuid());
    insert into _v (resultado) values ('FALLA se denunció por un pedido inexistente');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%No encontramos%'
        then 'OK   un pedido inexistente da no_encontrado' else 'FALLA inexistente: ' || sqlerrm end);
end $$;

reset role;

-- Como admin.
select set_config('request.jwt.claims',
                  json_build_object('sub', admin, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) >= 2 and bool_or(motivo = 'incumplimiento' and estado = 'pendiente')
            then 'OK   el admin ve las denuncias con nombres y motivo (' || count(*) || ')'
            else 'FALLA denuncias_admin: ' || count(*) end
  from public.denuncias_admin();

reset role;

insert into _v (resultado)
select case when count(*) >= 2
            then 'OK   cada denuncia avisó a los administradores'
            else 'FALLA avisos de denuncia: ' || count(*) end
  from public.notificaciones
 where tipo = 'denuncia_recibida' and created_at = now();

do $$
begin
    raise exception E'Resultado del guion de la 0033:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
