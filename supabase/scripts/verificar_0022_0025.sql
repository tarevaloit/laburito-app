-- ============================================================================
-- Guion de aceptación de las migraciones 0022 a 0025 (Sprint 4)
-- CU-31/32 pagos · CU-25 desbloqueo · CU-40/52 admin · CU-53 canje
-- ============================================================================
--
--   supabase db query --linked -f supabase/scripts/verificar_0022_0025.sql
--
-- Todo dentro de una transacción que aborta al final: el resultado sale como
-- el mensaje del error, una línea por regla con OK o FALLA. Arma sus propios
-- datos (un pedido vigente, un pedido cerrado, un cupón) y usa el Profesional
-- activo más reciente, que queda aprobado y con saldo cero **solo dentro de
-- la transacción**.
-- ============================================================================

begin;

create temp table _v (orden serial, resultado text) on commit drop;
grant all on _v to authenticated;
grant usage, select on sequence _v_orden_seq to authenticated;

create temp table _ids on commit drop as
select
    (select p.id from public.perfiles p
      where p.tipo = 'buscador' and p.estado = 'activo' and p.deleted_at is null
      order by p.created_at desc limit 1)                     as buscador,
    (select pr.perfil_id from public.profesionales pr
       join public.perfiles p on p.id = pr.perfil_id
      where p.estado = 'activo' and p.deleted_at is null
      order by pr.created_at desc limit 1)                    as profesional,
    (select id from public.categorias_oficio where activa order by orden limit 1) as categoria,
    (select id from public.paquetes_tokens where nombre = 'Plata') as plata,
    gen_random_uuid() as vigente,
    gen_random_uuid() as cerrado,
    gen_random_uuid() as pago;
grant select on _ids to authenticated;

-- Datos de prueba (como dueño de las tablas)
update public.perfiles set telefono = '11 2345-6789'
 where id = (select buscador from _ids);

select set_config('app.movimiento_tokens', 'on', true);
update public.profesionales
   set estado_verificacion = 'aprobado', saldo_tokens = 0
 where perfil_id = (select profesional from _ids);
select set_config('app.movimiento_tokens', 'off', true);

insert into public.pedidos (id, buscador_id, categoria_id, titulo, descripcion,
                            ubicacion, direccion_texto, fecha_vencimiento)
select vigente, buscador, categoria, 'Prueba S4 vigente',
       'Pedido de prueba del guion del Sprint 4, se revierte al final.',
       public.punto(-34.52, -58.75), 'Calle falsa 123', now() + interval '7 days'
  from _ids
union all
select cerrado, buscador, categoria, 'Prueba S4 cerrado',
       'Pedido de prueba del guion del Sprint 4, se revierte al final.',
       public.punto(-34.52, -58.75), 'Calle falsa 123', now() + interval '7 days'
  from _ids;

select set_config('app.transicion_estado', 'on', true);
update public.pedidos set estado = 'cerrado', fecha_cierre = now()
 where id = (select cerrado from _ids);
select set_config('app.transicion_estado', 'off', true);

insert into public.cupones (codigo, tokens, vence_at, limite_usos)
values ('GUIONS4', 5, now() + interval '1 day', null),
       ('VENCIDOS4', 5, now() - interval '1 day', null),
       ('UNOSOLOS4', 5, now() + interval '1 day', 1);
update public.cupones set usos = 1 where codigo = 'UNOSOLOS4';

-- ---------------------------------------------------------------------------
-- Como el Profesional
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

-- CU-25 sin saldo
do $$
begin
    perform public.desbloquear_contacto((select vigente from _ids));
    insert into _v (resultado) values ('FALLA se desbloqueó sin saldo');
exception when others then
    insert into _v (resultado) values (case when sqlerrm like 'No te alcanzan%'
        then 'OK   sin saldo da saldo_insuficiente'
        else 'FALLA sin saldo dio: ' || sqlerrm end);
end $$;

insert into _v (resultado)
select case when telefono is null and telefono_enmascarado like '1123%••••••'
             and not desbloqueado and nombre_corto <> ''
            then 'OK   contacto_pedido enmascara antes de pagar (' || telefono_enmascarado || ')'
            else 'FALLA contacto_pedido antes de pagar: ' || coalesce(telefono, '∅') end
  from public.contacto_pedido((select vigente from _ids));

-- CU-53 canje
insert into _v (resultado)
select case when resultado = 'ok' and tokens = 5 and saldo = 5
            then 'OK   canjear GUIONS4 (en minúsculas y con espacios) acredita 5'
            else 'FALLA canje: ' || resultado end
  from public.canjear_cupon(' guions4 ');

insert into _v (resultado)
select case when resultado = 'ya_usado' then 'OK   el segundo canje da ya_usado'
            else 'FALLA segundo canje: ' || resultado end
  from public.canjear_cupon('GUIONS4');

insert into _v (resultado)
select case when resultado = 'vencido' then 'OK   un cupón vencido da vencido'
            else 'FALLA vencido: ' || resultado end
  from public.canjear_cupon('VENCIDOS4');

insert into _v (resultado)
select case when resultado = 'agotado' then 'OK   un cupón agotado da agotado'
            else 'FALLA agotado: ' || resultado end
  from public.canjear_cupon('UNOSOLOS4');

-- CU-25 con saldo
insert into _v (resultado)
select case when cobrado and saldo = 4 and telefono = '11 2345-6789'
            then 'OK   desbloquear cobra 1 y revela el teléfono'
            else 'FALLA desbloqueo: saldo ' || saldo || ', cobrado ' || cobrado end
  from public.desbloquear_contacto((select vigente from _ids));

insert into _v (resultado)
select case when not cobrado and saldo = 4
            then 'OK   desbloquear de nuevo no cobra'
            else 'FALLA segundo desbloqueo cobró' end
  from public.desbloquear_contacto((select vigente from _ids));

insert into _v (resultado)
select case when desbloqueado and telefono = '11 2345-6789'
            then 'OK   contacto_pedido revela el teléfono después'
            else 'FALLA contacto_pedido después' end
  from public.contacto_pedido((select vigente from _ids));

do $$
begin
    perform public.desbloquear_contacto((select cerrado from _ids));
    insert into _v (resultado) values ('FALLA se desbloqueó un pedido cerrado');
exception when others then
    insert into _v (resultado) values ('OK   un pedido cerrado da: ' || sqlerrm);
end $$;

insert into _v (resultado)
select case when (select saldo_tokens from public.profesionales where perfil_id = auth.uid())
               = (select saldo_resultante from public.movimientos_tokens
                   where profesional_id = auth.uid() order by created_at desc, id limit 1)
            then 'OK   el saldo coincide con el último movimiento del libro'
            else 'FALLA el saldo no coincide con el libro' end;

insert into _v (resultado)
select case when public.interesados_pedido((select vigente from _ids)) = 0
            then 'OK   interesados_pedido le da 0 a quien no es el dueño'
            else 'FALLA interesados_pedido le da datos a un tercero' end;

-- CU-31 iniciar compra
insert into _v (resultado)
select case when estado = 'pendiente' and cantidad_tokens = 10 and monto_ars = 8000
            then 'OK   iniciar_compra_tokens copia cantidad y monto del paquete'
            else 'FALLA iniciar compra' end
  from public.iniciar_compra_tokens((select plata from _ids));

do $$
begin
    perform public.registrar_resultado_pago(gen_random_uuid(), '1', 'approved', 'accredited', 8000, 'visa');
    insert into _v (resultado) values ('FALLA un cliente ejecutó registrar_resultado_pago');
exception when insufficient_privilege then
    insert into _v (resultado) values ('OK   registrar_resultado_pago no la ejecuta un cliente');
end $$;

-- CU-40 / CU-52 como no admin
do $$
begin
    perform public.actualizar_precio_paquete((select plata from _ids), 1);
    insert into _v (resultado) values ('FALLA un Profesional cambió un precio');
exception when others then
    insert into _v (resultado) values ('OK   un Profesional no cambia precios');
end $$;

do $$
begin
    perform public.crear_cupon('TRAMPA99', 100, current_date + 5, null);
    insert into _v (resultado) values ('FALLA un Profesional creó un cupón');
exception when others then
    insert into _v (resultado) values ('OK   un Profesional no crea cupones');
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
select case when public.interesados_pedido((select vigente from _ids)) = 1
            then 'OK   el dueño ve 1 interesado'
            else 'FALLA el dueño ve ' || public.interesados_pedido((select vigente from _ids)) end;

reset role;

-- ---------------------------------------------------------------------------
-- CU-32 webhook, como service_role (la Edge Function)
-- ---------------------------------------------------------------------------
insert into public.pagos (id, profesional_id, paquete_id, paquete_nombre, cantidad_tokens, monto_ars)
select pago, profesional, plata, 'Plata', 10, 8000 from _ids;

insert into _v (resultado)
select case when estado = 'pendiente' and mp_estado_detalle like 'monto_no_coincide%'
            then 'OK   un monto distinto no acredita'
            else 'FALLA monto distinto: ' || estado end
  from public.registrar_resultado_pago((select pago from _ids), '900', 'approved', 'accredited', 1, 'visa');

insert into _v (resultado)
select case when estado = 'rechazado' and mp_estado_detalle = 'cc_rejected_insufficient_amount'
            then 'OK   un rechazo queda registrado con su motivo'
            else 'FALLA rechazo: ' || estado end
  from public.registrar_resultado_pago((select pago from _ids), '901', 'rejected',
                                       'cc_rejected_insufficient_amount', 8000, 'visa');

do $$
declare
    v_antes   int;
    v_pago    public.pagos;
    v_despues int;
begin
    select saldo_tokens into v_antes from public.profesionales
     where perfil_id = (select profesional from _ids);

    v_pago := public.registrar_resultado_pago((select pago from _ids), '902', 'approved', 'accredited', 8000, 'master');
    v_pago := public.registrar_resultado_pago((select pago from _ids), '902', 'approved', 'accredited', 8000, 'master');
    v_pago := public.registrar_resultado_pago((select pago from _ids), '903', 'rejected', 'cc_rejected_other_reason', 8000, 'master');

    select saldo_tokens into v_despues from public.profesionales
     where perfil_id = (select profesional from _ids);

    insert into _v (resultado) values (case
        when v_pago.estado = 'aprobado' and v_pago.numero_comprobante is not null
             and v_despues = v_antes + 10
        then 'OK   aprobado acredita 10 una sola vez y no vuelve a rechazado (comprobante '
             || v_pago.numero_comprobante || ')'
        else 'FALLA webhook: estado ' || v_pago.estado || ', saldo ' || v_antes || ' → ' || v_despues end);
end $$;

do $$
begin
    perform public.registrar_resultado_pago(gen_random_uuid(), '904', 'approved', 'accredited', 8000, 'visa');
    insert into _v (resultado) values ('FALLA un pago inexistente no dio error');
exception when others then
    insert into _v (resultado) values (case when sqlerrm = 'PAGO_INEXISTENTE'
        then 'OK   un external_reference ajeno da PAGO_INEXISTENTE'
        else 'FALLA pago inexistente: ' || sqlerrm end);
end $$;

-- ---------------------------------------------------------------------------
-- Bloqueo por fuerza bruta (CU-53)
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claims',
                  json_build_object('sub', profesional, 'role', 'authenticated')::text, true)
  from _ids;
set local role authenticated;

select public.canjear_cupon('NOEXISTE' || g) from generate_series(1, 5) g;

insert into _v (resultado)
select case when resultado = 'bloqueado'
            then 'OK   después de 5 fallidos, el canje queda bloqueado'
            else 'FALLA bloqueo: ' || resultado end
  from public.canjear_cupon('OTROMAS');

reset role;

-- ---------------------------------------------------------------------------
-- Catálogo
-- ---------------------------------------------------------------------------
insert into _v (resultado)
select case when not has_function_privilege('anon', 'public.desbloquear_contacto(uuid)', 'execute')
             and not has_function_privilege('anon', 'public.canjear_cupon(text)', 'execute')
             and not has_function_privilege('authenticated',
                    'public.registrar_resultado_pago(uuid, text, text, text, numeric, text)', 'execute')
            then 'OK   permisos de ejecución revocados donde corresponde'
            else 'FALLA algún permiso de ejecución quedó abierto' end;

do $$
begin
    raise exception E'Resultado del guion 0022–0025:\n%',
        (select string_agg(resultado, E'\n' order by orden) from _v);
end $$;

rollback;
