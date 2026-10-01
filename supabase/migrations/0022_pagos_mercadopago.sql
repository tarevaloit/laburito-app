-- ============================================================================
-- Laburito — Migración 0022
-- Sprint 4 · CU-31 Cargar Tokens · CU-32 Procesar Pago
-- ============================================================================
--
-- Las dos funciones del circuito de pago. Las llaman las Edge Functions, no la
-- app:
--
--   * `iniciar_compra_tokens` la llama `crear_preferencia_pago` **con la sesión
--     del Profesional**, para que `auth.uid()` diga quién compra. Crea el pago
--     pendiente copiando cantidad y monto del paquete. El cliente no manda
--     ningún precio.
--
--   * `registrar_resultado_pago` la llama `webhook_mercadopago` con
--     `service_role`, después de validar la firma y de consultar el pago a la
--     API de Mercado Pago. Es la única que acredita tokens comprados.
-- ============================================================================


-- ============================================================================
-- 1. iniciar_compra_tokens — CU-31
-- ============================================================================
--
-- Cuenta activa, no verificación aprobada: los tokens no vencen y comprarlos
-- antes de que termine la revisión no le hace daño a nadie. Lo que exige la
-- aprobación es gastarlos (CU-25).
--
-- `setof` para que PostgREST admita `select=` sobre el resultado (decisión del
-- 02/09).
-- ============================================================================

create or replace function public.iniciar_compra_tokens(p_paquete uuid)
returns setof public.pagos
language plpgsql
security definer
set search_path = public
as $$
declare
    v_paquete public.paquetes_tokens;
begin
    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa puede comprar tokens.'
              using hint = 'sin_permiso';
    end if;

    select * into v_paquete
      from public.paquetes_tokens
     where id = p_paquete and activo;

    if not found then
        raise exception 'Ese paquete ya no está a la venta. Elegí otro.'
              using hint = 'paquete_inexistente';
    end if;

    return query
    insert into public.pagos (
        profesional_id, paquete_id, paquete_nombre, cantidad_tokens, monto_ars
    ) values (
        auth.uid(), v_paquete.id, v_paquete.nombre, v_paquete.cantidad, v_paquete.precio_ars
    )
    returning *;
end;
$$;

comment on function public.iniciar_compra_tokens(uuid) is
    'CU-31. Crea el pago pendiente con la cantidad y el monto del paquete copiados. La llama crear_preferencia_pago con la sesión del Profesional.';

revoke execute on function public.iniciar_compra_tokens(uuid) from public, anon;
grant  execute on function public.iniciar_compra_tokens(uuid) to authenticated;


-- ============================================================================
-- 2. registrar_resultado_pago — CU-32
-- ============================================================================
--
-- Recibe lo que **Mercado Pago dijo al consultarle el pago**, no lo que traía
-- la notificación: la Edge Function hace el GET a /v1/payments/{id} con el
-- Access Token antes de llamar acá.
--
-- Idempotente, porque Mercado Pago reintenta y repite notificaciones:
--   * bloquea la fila del pago antes de mirarla;
--   * un pago ya aprobado no se vuelve a tocar —ni a acreditar, ni a pasar a
--     rechazado por una notificación vieja que llegue tarde—;
--   * y el índice único de `movimientos_tokens.pago_id` (0021) es la red de
--     abajo.
--
-- El monto cobrado tiene que coincidir con el copiado al crear el pago. Si no
-- coincide, no se acredita y se registra el error: alguien alteró la
-- preferencia o el precio cambió por un camino que no es este.
--
-- Estados de Mercado Pago → estados nuestros:
--   approved                         → aprobado (acredita)
--   rejected                         → rechazado
--   cancelled, refunded, charged_back → cancelado
--   pending, in_process, authorized, in_mediation → sigue pendiente
-- ============================================================================

create or replace function public.registrar_resultado_pago(
    p_pago            uuid,
    p_mp_payment_id   text,
    p_estado_mp       text,
    p_estado_detalle  text,
    p_monto           numeric,
    p_metodo          text
)
returns public.pagos
language plpgsql
security definer
set search_path = public
as $$
declare
    v_pago public.pagos;
begin
    select * into v_pago
      from public.pagos
     where id = p_pago
       for update;

    if not found then
        raise exception 'PAGO_INEXISTENTE'
              using hint = 'pago_inexistente',
                    detail = format('external_reference %s no corresponde a ningún pago.', p_pago);
    end if;

    if v_pago.estado = 'aprobado' then
        return v_pago;
    end if;

    if p_estado_mp = 'approved' then
        if round(p_monto) <> v_pago.monto_ars then
            update public.pagos
               set mp_payment_id     = p_mp_payment_id,
                   mp_estado_detalle = format('monto_no_coincide: cobrado %s, esperado %s',
                                              p_monto, v_pago.monto_ars)
             where id = p_pago
            returning * into v_pago;

            raise warning 'Pago % aprobado por % pero se esperaba %: no se acredita.',
                          p_pago, p_monto, v_pago.monto_ars;
            return v_pago;
        end if;

        update public.pagos
           set estado             = 'aprobado',
               mp_payment_id      = p_mp_payment_id,
               mp_estado_detalle  = p_estado_detalle,
               metodo_pago        = p_metodo,
               numero_comprobante = nextval('public.pagos_numero_comprobante_seq'),
               aprobado_at        = now()
         where id = p_pago
        returning * into v_pago;

        perform public.aplicar_movimiento_tokens(
            v_pago.profesional_id,
            'compra',
            v_pago.cantidad_tokens,
            'Compra pack ' || v_pago.paquete_nombre,
            p_pago => v_pago.id
        );

    elsif p_estado_mp = 'rejected' then
        update public.pagos
           set estado            = 'rechazado',
               mp_payment_id     = p_mp_payment_id,
               mp_estado_detalle = p_estado_detalle,
               metodo_pago       = p_metodo
         where id = p_pago
        returning * into v_pago;

    elsif p_estado_mp in ('cancelled', 'refunded', 'charged_back') then
        update public.pagos
           set estado            = 'cancelado',
               mp_payment_id     = p_mp_payment_id,
               mp_estado_detalle = p_estado_detalle,
               metodo_pago       = p_metodo
         where id = p_pago
        returning * into v_pago;

    else
        -- Pendiente para Mercado Pago (efectivo sin pagar, revisión manual, ...).
        -- Se guarda el detalle para mostrarlo; el estado no cambia. Si antes se
        -- había rechazado con otra tarjeta, un reintento vuelve a pendiente.
        update public.pagos
           set estado            = 'pendiente',
               mp_payment_id     = p_mp_payment_id,
               mp_estado_detalle = p_estado_detalle,
               metodo_pago       = p_metodo
         where id = p_pago
        returning * into v_pago;
    end if;

    return v_pago;
end;
$$;

comment on function public.registrar_resultado_pago(uuid, text, text, text, numeric, text) is
    'CU-32. Aplica el resultado que devolvió la API de Mercado Pago. Idempotente; acredita solo si el monto coincide. Solo service_role.';

revoke execute on function public.registrar_resultado_pago(uuid, text, text, text, numeric, text)
    from public, anon, authenticated;
grant  execute on function public.registrar_resultado_pago(uuid, text, text, text, numeric, text)
    to service_role;


-- ============================================================================
-- 3. Guion de aceptación (dentro de begin … rollback)
-- ============================================================================
--
--   -- Como el Profesional (claims + set local role authenticated):
--   select id, estado, cantidad_tokens, monto_ars
--     from public.iniciar_compra_tokens((select id from paquetes_tokens where nombre = 'Plata'));
--     -- → pendiente, 10, 8000
--   select public.registrar_resultado_pago(...);   -- → 42501 (no la ejecuta un cliente)
--
--   -- Como dueño:
--   select estado, numero_comprobante from public.registrar_resultado_pago(
--       'PAGO', '123', 'approved', 'accredited', 8000, 'master');   -- → aprobado, N
--   -- repetido → mismo N, el saldo no cambia
--   -- 'rejected' después → sigue aprobado
--   -- otro pago con monto 1 → sigue pendiente, detalle monto_no_coincide, sin tokens
--
-- Ver supabase/scripts/verificar_0022.sql.
-- ============================================================================
