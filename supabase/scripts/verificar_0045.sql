-- ============================================================================
-- Guion de aceptación de la migración 0045 (CU-02)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0045.sql
--
-- Transacción que aborta al final. Simula dos altas de Profesional
-- insertando en auth.users, como hace Supabase Auth: una con un DNI ya
-- registrado y otra con uno libre.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to anon;
grant usage, select on sequence _v_orden_seq to anon;

create temp table _ids on commit drop as
select (select dni from public.profesionales where dni is not null limit 1) as dni_usado,
       '00000017'::text as dni_libre;
grant select on _ids to anon;

-- Como anon: la pantalla de registro todavía no tiene sesión.
set local role anon;

insert into _v (resultado)
select case when not public.dni_disponible(left(dni_usado, 2) || '.' || substr(dni_usado, 3))
             and public.dni_disponible(dni_libre)
            then 'OK   dni_disponible distingue un DNI usado (con puntos) de uno libre, sin sesión'
            else 'FALLA dni_disponible' end
  from _ids;

reset role;

do $$
begin
    insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
    values (gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
            'guion0045.repetido@laburito.test',
            jsonb_build_object('tipo', 'profesional', 'nombre', 'Guion', 'apellido', 'Repetido',
                               'dni', (select dni_usado from _ids)),
            now(), now());
    insert into _v (resultado) values ('FALLA se registró un Profesional con un DNI repetido');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like '%ya está en uso%'
        then 'OK   el alta con un DNI repetido se aborta entera'
        else 'FALLA repetido: ' || sqlerrm end);
end $$;

insert into _v (resultado)
select case when not exists (select 1 from auth.users where email = 'guion0045.repetido@laburito.test')
             and not exists (select 1 from public.perfiles where email = 'guion0045.repetido@laburito.test')
            then 'OK   no queda una cuenta a medias'
            else 'FALLA quedó la cuenta del alta abortada' end;

insert into auth.users (id, instance_id, aud, role, email, raw_user_meta_data, created_at, updated_at)
values (gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
        'guion0045.nuevo@laburito.test',
        jsonb_build_object('tipo', 'profesional', 'nombre', 'Guion', 'apellido', 'Nuevo',
                           'dni', (select dni_libre from _ids)),
        now(), now());

insert into _v (resultado)
select case when pr.dni = (select dni_libre from _ids)
            then 'OK   con un DNI libre el alta guarda el DNI'
            else 'FALLA alta normal: ' || coalesce(pr.dni, 'null') end
  from public.profesionales pr
  join public.perfiles p on p.id = pr.perfil_id
 where p.email = 'guion0045.nuevo@laburito.test';

do $$
begin
    raise exception E'Resultado del guion de la 0045:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
