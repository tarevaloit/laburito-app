-- ============================================================================
-- Laburito — Migración 0025
-- Sprint 4 · CU-53 Canjear Cupón de Tokens
-- ============================================================================
--
-- `canjear_cupon(p_codigo)` **no levanta excepciones** para los códigos que no
-- sirven: devuelve un resultado. Es a propósito y es lo que hace funcionar el
-- bloqueo por fuerza bruta que pide el requerimiento especial del CU-53: un
-- `raise` desharía también la fila de `cupon_intentos` que registra el intento
-- fallido, y el contador nunca subiría.
--
-- Resultados: `ok`, `inexistente`, `vencido`, `agotado`, `ya_usado`,
-- `bloqueado`. La app los traduce a los mensajes de la pantalla.
--
-- Bloqueo: 5 intentos fallidos en 15 minutos bloquean el canje hasta que el más
-- viejo de esos cinco salga de la ventana. Cuenta todos los fallidos, no solo
-- los inexistentes: «vencido» y «agotado» también confirman que el código
-- existe, que es justamente lo que alguien que prueba al azar quiere saber.
-- ============================================================================

create or replace function public.canjear_cupon(p_codigo text)
returns table (
    resultado  text,
    tokens     integer,
    saldo      integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid         uuid := auth.uid();
    v_codigo      text := upper(regexp_replace(coalesce(p_codigo, ''), '\s', '', 'g'));
    v_cupon       public.cupones;
    v_movimiento  public.movimientos_tokens;
    v_resultado   text;
begin
    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa puede canjear cupones.'
              using hint = 'sin_permiso';
    end if;

    if (select count(*) from public.cupon_intentos i
         where i.profesional_id = v_uid
           and not i.exitoso
           and i.created_at > now() - interval '15 minutes') >= 5 then
        return query select 'bloqueado'::text, null::integer, null::integer;
        return;
    end if;

    select * into v_cupon
      from public.cupones c
     where upper(c.codigo) = v_codigo
       for update;

    if not found or not v_cupon.activo then
        v_resultado := 'inexistente';
    elsif v_cupon.vence_at <= now() then
        v_resultado := 'vencido';
    elsif v_cupon.limite_usos is not null and v_cupon.usos >= v_cupon.limite_usos then
        v_resultado := 'agotado';
    elsif exists (select 1 from public.cupon_canjes k
                   where k.cupon_id = v_cupon.id and k.profesional_id = v_uid) then
        v_resultado := 'ya_usado';
    end if;

    if v_resultado is not null then
        insert into public.cupon_intentos (profesional_id, codigo, exitoso)
        values (v_uid, left(v_codigo, 40), false);
        return query select v_resultado, null::integer, null::integer;
        return;
    end if;

    v_movimiento := public.aplicar_movimiento_tokens(
        v_uid, 'cupon', v_cupon.tokens, 'Cupón ' || v_cupon.codigo, p_cupon => v_cupon.id
    );

    update public.cupones set usos = usos + 1 where id = v_cupon.id;

    insert into public.cupon_canjes (cupon_id, profesional_id, movimiento_id)
    values (v_cupon.id, v_uid, v_movimiento.id);

    insert into public.cupon_intentos (profesional_id, codigo, exitoso)
    values (v_uid, v_cupon.codigo, true);

    return query select 'ok'::text, v_cupon.tokens, v_movimiento.saldo_resultante;
end;
$$;

comment on function public.canjear_cupon(text) is
    'CU-53. Canjea un cupón. Devuelve ok / inexistente / vencido / agotado / ya_usado / bloqueado sin levantar excepción, para que los intentos fallidos queden registrados. 5 fallidos en 15 min bloquean.';

revoke execute on function public.canjear_cupon(text) from public, anon;
grant  execute on function public.canjear_cupon(text) to authenticated;


-- ============================================================================
-- Guion de aceptación
-- ============================================================================
--
-- supabase/scripts/verificar_0025.sql: un código válido acredita y deja
-- saldo y movimiento; el segundo canje da `ya_usado`; uno vencido, `vencido`;
-- uno con límite 1 ya usado por otro, `agotado`; en minúsculas y con espacios
-- se reconoce; cinco inexistentes seguidos y el sexto —aunque sea válido— da
-- `bloqueado`.
-- ============================================================================
