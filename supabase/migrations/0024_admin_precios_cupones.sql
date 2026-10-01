-- ============================================================================
-- Laburito — Migración 0024
-- Sprint 4 · CU-40 Configurar Precio de Tokens · CU-52 Crear Cupón Promocional
-- ============================================================================
--
-- Las dos primeras operaciones del administrador. Van por RPC y no por
-- políticas de escritura sobre las tablas porque cada una tiene reglas que el
-- `check` no dice con un mensaje legible: el precio tiene que ser un entero
-- positivo, el código no se puede repetir, el vencimiento tiene que ser futuro.
-- Con la función, el error llega a la pantalla en castellano (decisión del
-- 16/09 sobre `guardar_zona_cobertura`).
--
-- La re-autenticación que pide el paso 4 del CU-40 la hace la app antes de
-- llamar (vuelve a validar la contraseña con Supabase Auth): la base no ve la
-- contraseña nunca.
-- ============================================================================


-- ============================================================================
-- 1. actualizar_precio_paquete — CU-40
-- ============================================================================

create or replace function public.actualizar_precio_paquete(
    p_paquete  uuid,
    p_precio   integer
)
returns setof public.paquetes_tokens
language plpgsql
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador puede cambiar los precios.'
              using hint = 'sin_permiso';
    end if;

    if p_precio is null or p_precio <= 0 then
        raise exception 'El precio tiene que ser un número entero positivo.'
              using hint = 'precio_invalido';
    end if;

    if p_precio > 10000000 then
        raise exception 'El precio no puede superar los $10.000.000.'
              using hint = 'precio_invalido';
    end if;

    return query
    update public.paquetes_tokens
       set precio_ars = p_precio
     where id = p_paquete
    returning *;

    if not found then
        raise exception 'Ese paquete no existe.'
              using hint = 'paquete_inexistente';
    end if;
end;
$$;

comment on function public.actualizar_precio_paquete(uuid, integer) is
    'CU-40. El admin cambia el precio de un paquete. Impacta en la próxima compra; los pagos ya iniciados conservan el monto copiado.';


-- ============================================================================
-- 2. crear_cupon — CU-52
-- ============================================================================
--
-- El vencimiento llega como fecha y vence **al final de ese día** en hora de
-- Argentina: un cupón «hasta el 31/07» tiene que poder usarse el 31 a la noche.
-- ============================================================================

create or replace function public.crear_cupon(
    p_codigo       text,
    p_tokens       integer,
    p_vence        date,
    p_limite_usos  integer default null
)
returns setof public.cupones
language plpgsql
security definer
set search_path = public
as $$
declare
    v_codigo  text := upper(trim(coalesce(p_codigo, '')));
    v_vence   timestamptz;
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador puede crear cupones.'
              using hint = 'sin_permiso';
    end if;

    if v_codigo !~ '^[A-Z0-9]{4,20}$' then
        raise exception 'El código tiene que tener entre 4 y 20 letras o números, sin espacios ni acentos.'
              using hint = 'codigo_invalido';
    end if;

    if p_tokens is null or p_tokens not between 1 and 1000 then
        raise exception 'Los tokens a regalar tienen que ser entre 1 y 1000.'
              using hint = 'tokens_invalidos';
    end if;

    if p_vence is null then
        raise exception 'Elegí una fecha de vencimiento.'
              using hint = 'vencimiento_pasado';
    end if;

    v_vence := ((p_vence + 1)::timestamp at time zone 'America/Argentina/Buenos_Aires');

    if v_vence <= now() then
        raise exception 'La fecha de vencimiento tiene que ser futura.'
              using hint = 'vencimiento_pasado';
    end if;

    if p_limite_usos is not null and p_limite_usos <= 0 then
        raise exception 'El límite de usos tiene que ser un número positivo, o quedar vacío para no tener límite.'
              using hint = 'limite_invalido';
    end if;

    if exists (select 1 from public.cupones where upper(codigo) = v_codigo) then
        raise exception 'Ya existe un cupón con el código %.', v_codigo
              using hint = 'codigo_repetido';
    end if;

    return query
    insert into public.cupones (codigo, tokens, vence_at, limite_usos, creado_por)
    values (v_codigo, p_tokens, v_vence, p_limite_usos, auth.uid())
    returning *;
end;
$$;

comment on function public.crear_cupon(text, integer, date, integer) is
    'CU-52. El admin crea un cupón. Código en mayúsculas y único; vence al final del día elegido (hora de Argentina); límite nulo = ilimitado.';


revoke execute on function public.actualizar_precio_paquete(uuid, integer)      from public, anon;
revoke execute on function public.crear_cupon(text, integer, date, integer)     from public, anon;
grant  execute on function public.actualizar_precio_paquete(uuid, integer)      to authenticated;
grant  execute on function public.crear_cupon(text, integer, date, integer)     to authenticated;


-- ============================================================================
-- 3. Guion de aceptación
-- ============================================================================
--
-- supabase/scripts/verificar_0024.sql: un Profesional recibe `sin_permiso` en
-- las dos; como admin, precio 0 y negativo dan `precio_invalido` y 9000 pasa;
-- un código con espacios, una fecha de ayer y un código repetido (en
-- minúsculas) dan su mensaje; «bienvenida10» se guarda como BIENVENIDA10.
-- ============================================================================
