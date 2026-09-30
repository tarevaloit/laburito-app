-- ============================================================================
-- Guion de aceptación de la migración 0021 (T-10)
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0021.sql
--
-- Todo dentro de una transacción que aborta al final: el resultado sale como
-- el mensaje del error, una línea por regla con OK o FALLA.
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
      order by pr.created_at desc limit 1) as profesional,
    (select pr.perfil_id from public.profesionales pr
      order by pr.created_at asc limit 1)  as otro,
    (select id from public.paquetes_tokens where nombre = 'Plata') as plata,
    gen_random_uuid() as pago;
grant select on _ids to authenticated;

insert into _v (resultado)
select case when count(*) = 7 then 'OK   RLS activa en las siete tablas'
            else 'FALLA RLS activa solo en ' || count(*) || ' de 7' end
  from pg_class
 where relnamespace = 'public'::regnamespace and relrowsecurity
   and relname in ('paquetes_tokens', 'pagos', 'cupones', 'movimientos_tokens',
                   'contactos_desbloqueados', 'cupon_canjes', 'cupon_intentos');

insert into _v (resultado)
select case when string_agg(nombre || ' ' || cantidad || ' $' || precio_ars, ', ' order by orden)
                 = 'Bronce 5 $4500, Plata 10 $8000, Oro 20 $14000'
            then 'OK   semilla de la Figura 3.13'
            else 'FALLA semilla: ' || string_agg(nombre || ' ' || cantidad || ' $' || precio_ars, ', ' order by orden) end
  from public.paquetes_tokens;

insert into _v (resultado)
select case when not has_function_privilege('authenticated',
                'public.aplicar_movimiento_tokens(uuid, public.movimiento_tipo, integer, text, uuid, uuid, uuid)', 'execute')
             and not has_function_privilege('anon',
                'public.aplicar_movimiento_tokens(uuid, public.movimiento_tipo, integer, text, uuid, uuid, uuid)', 'execute')
            then 'OK   aplicar_movimiento_tokens no la ejecuta ningún cliente'
            else 'FALLA aplicar_movimiento_tokens es ejecutable por un cliente' end;

-- Un pago aprobado y su acreditación, como dueño de las funciones.
insert into public.pagos (id, profesional_id, paquete_id, paquete_nombre, cantidad_tokens, monto_ars)
select pago, profesional, plata, 'Plata', 10, 8000 from _ids;

do $$
declare
    v_antes int;
    v_mov   public.movimientos_tokens;
    v_despues int;
begin
    select saldo_tokens into v_antes from public.profesionales
     where perfil_id = (select profesional from _ids);
    v_mov := public.aplicar_movimiento_tokens(
        (select profesional from _ids), 'compra', 10, 'Compra pack Plata',
        p_pago => (select pago from _ids));
    select saldo_tokens into v_despues from public.profesionales
     where perfil_id = (select profesional from _ids);
    insert into _v (resultado) values (case
        when v_despues = v_antes + 10 and v_mov.saldo_resultante = v_despues
        then 'OK   acreditar deja saldo y movimiento coincidiendo (' || v_antes || ' → ' || v_despues || ')'
        else 'FALLA acreditación: saldo ' || v_despues || ', movimiento ' || v_mov.saldo_resultante end);
end $$;

do $$
begin
    perform public.aplicar_movimiento_tokens(
        (select profesional from _ids), 'compra', 10, 'Compra repetida',
        p_pago => (select pago from _ids));
    insert into _v (resultado) values ('FALLA el mismo pago acreditó dos veces');
exception when unique_violation then
    insert into _v (resultado) values ('OK   el mismo pago no acredita dos veces');
end $$;

do $$
begin
    perform public.aplicar_movimiento_tokens(
        (select profesional from _ids), 'consumo', -100000, 'Débito imposible',
        p_pedido => (select id from public.pedidos limit 1));
    insert into _v (resultado) values ('FALLA se debitó más que el saldo');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like 'No te alcanzan%'
        then 'OK   débito mayor al saldo da saldo_insuficiente'
        else 'FALLA débito imposible dio: ' || sqlerrm end);
end $$;

-- Como el Profesional
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

insert into _v (resultado)
select case when count(*) = 3 then 'OK   el Profesional ve los tres paquetes'
            else 'FALLA el Profesional ve ' || count(*) || ' paquetes' end
  from public.paquetes_tokens;

insert into _v (resultado)
select case when count(*) = 1 then 'OK   el Profesional ve su pago'
            else 'FALLA el Profesional ve ' || count(*) || ' pagos propios' end
  from public.pagos where id = (select pago from _ids);

insert into _v (resultado)
select case when count(*) = 0 then 'OK   el Profesional no ve cupones'
            else 'FALLA el Profesional ve ' || count(*) || ' cupones' end
  from public.cupones;

do $$
begin
    insert into public.pagos (profesional_id, paquete_id, paquete_nombre, cantidad_tokens, monto_ars)
    select profesional, plata, 'Plata', 10, 1 from _ids;
    insert into _v (resultado) values ('FALLA el Profesional insertó un pago');
exception when others then
    insert into _v (resultado) values ('OK   insertar un pago da ' || sqlstate);
end $$;

do $$
begin
    insert into public.movimientos_tokens (profesional_id, tipo, cantidad, saldo_resultante, descripcion, pago_id)
    select profesional, 'compra', 100, 100, 'trampa', pago from _ids;
    insert into _v (resultado) values ('FALLA el Profesional insertó un movimiento');
exception when others then
    insert into _v (resultado) values ('OK   insertar un movimiento da ' || sqlstate);
end $$;

do $$
begin
    perform public.aplicar_movimiento_tokens(auth.uid(), 'compra', 100, 'trampa',
                                             p_pago => (select pago from _ids));
    insert into _v (resultado) values ('FALLA el Profesional ejecutó aplicar_movimiento_tokens');
exception when others then
    insert into _v (resultado) values ('OK   ejecutar aplicar_movimiento_tokens da ' || sqlstate);
end $$;

reset role;

do $$
begin
    raise exception E'Resultado del guion de la 0021:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
