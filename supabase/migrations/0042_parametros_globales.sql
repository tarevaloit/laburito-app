-- ============================================================================
-- Laburito — Migración 0042
-- Sprint 6 · CU-47 Configurar Parámetros Globales
-- ============================================================================
--
--   actualizar_parametro(clave, valor)   paso 6, con el rango de la 0034 y el
--                                        mismo registro que el resto del panel
--
-- y las dos funciones de negocio que tenían esos números escritos pasan a
-- leerlos de `parametros_sistema` (decisión 8 del plan):
--
--   guardar_zona_cobertura (0014)   radio máximo: `radio_maximo_km`
--   renovar_pedido (0008)           `renovaciones_maximas` y
--                                   `dias_maximos_renovacion`
--
-- Se reescriben completas, como hizo la 0008 con las de la 0006: este archivo
-- pasa a ser la versión vigente de ambas. Lo único que cambia son los límites.
--
-- La segunda confirmación del paso 4 la hace la app con la contraseña, como
-- en el CU-40: la base no ve la contraseña nunca.
-- ============================================================================


create or replace function public.actualizar_parametro(p_clave text, p_valor integer)
returns setof public.parametros_sistema
language plpgsql
security definer
set search_path = public
as $$
declare
    v_param public.parametros_sistema;
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador cambia los parámetros globales.'
              using hint = 'sin_permiso';
    end if;

    select * into v_param from public.parametros_sistema where clave = p_clave for update;
    if not found then
        raise exception 'Ese parámetro no existe.' using hint = 'no_encontrado';
    end if;

    -- Flujo alterno 1.1: fuera de rango se informa y se conserva el anterior.
    if p_valor is null or p_valor not between v_param.minimo and v_param.maximo then
        raise exception '«%» tiene que estar entre % y % %. Se conserva el valor anterior (%).',
                        v_param.nombre, v_param.minimo, v_param.maximo, v_param.unidad, v_param.valor
              using hint = 'fuera_de_rango';
    end if;

    return query
    update public.parametros_sistema
       set valor = p_valor, updated_by = auth.uid(), updated_at = now()
     where clave = p_clave
    returning *;
end;
$$;

comment on function public.actualizar_parametro(text, integer) is
    'CU-47. Cambia un parámetro global dentro de su rango y registra quién y cuándo.';

revoke execute on function public.actualizar_parametro(text, integer) from public, anon;
grant  execute on function public.actualizar_parametro(text, integer) to authenticated;


-- ============================================================================
-- guardar_zona_cobertura — CU-07 con el radio máximo del parámetro
-- ============================================================================

create or replace function public.guardar_zona_cobertura(
    p_lat           double precision,
    p_lng           double precision,
    p_radio_metros  integer,
    p_direccion     text default null
)
returns setof public.profesional_zona_cobertura
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_max_km integer := coalesce(public.parametro('radio_maximo_km'), 100);
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa puede configurar su zona de cobertura'
              using hint = 'sin_permiso';
    end if;

    if p_lat is null or p_lng is null
       or p_lat not between  -90 and  90
       or p_lng not between -180 and 180
    then
        raise exception 'El centro de la zona no es válido. Marcalo de nuevo en el mapa'
              using hint = 'ubicacion_invalida';
    end if;

    if p_radio_metros is null or p_radio_metros not between 1000 and v_max_km * 1000 then
        raise exception 'El radio tiene que estar entre 1 y % km', v_max_km
              using hint = 'radio_invalido';
    end if;

    return query
    with guardada as (
        insert into public.profesional_zona_cobertura as z (
            profesional_id, centro, radio_metros, direccion_texto
        )
        values (
            auth.uid(),
            public.punto(p_lat, p_lng),
            p_radio_metros,
            nullif(trim(coalesce(p_direccion, '')), '')
        )
        on conflict (profesional_id) do update
           set centro          = excluded.centro,
               radio_metros    = excluded.radio_metros,
               direccion_texto = excluded.direccion_texto
        returning z.*
    )
    select * from guardada;
end;
$$;

comment on function public.guardar_zona_cobertura(double precision, double precision, integer, text) is
    'CU-07. Alta o cambio de la zona de cobertura del Profesional que llama. El radio máximo sale del parámetro radio_maximo_km (CU-47).';


-- ============================================================================
-- renovar_pedido — CU-51 con los límites de los parámetros
-- ============================================================================

create or replace function public.renovar_pedido(
    p_pedido_id uuid,
    p_dias      integer
)
returns public.pedidos
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_pedido   public.pedidos;
    v_ventana  constant interval := interval '3 days';
    v_max_dias integer := coalesce(public.parametro('dias_maximos_renovacion'), 30);
    v_max_ren  integer := coalesce(public.parametro('renovaciones_maximas'), 3);
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    if p_dias is null or p_dias not between 1 and v_max_dias then
        raise exception 'La renovación tiene que ser de entre 1 y % días', v_max_dias
              using hint = 'dias_invalidos';
    end if;

    select * into v_pedido
      from public.pedidos
     where id = p_pedido_id
       and buscador_id = auth.uid()
     for update;

    if not found then
        raise exception 'El pedido no existe o no es tuyo'
              using hint = 'sin_permiso';
    end if;

    if v_pedido.estado in ('cerrado', 'cancelado') then
        raise exception 'Un pedido % no se puede renovar', v_pedido.estado
              using hint = 'transicion_invalida';
    end if;

    if v_pedido.estado <> 'vencido'
       and v_pedido.fecha_vencimiento > now() + v_ventana then
        raise exception 'Todavía no se puede renovar: al pedido le quedan más de 3 días de vigencia'
              using hint = 'transicion_invalida';
    end if;

    if v_pedido.renovaciones >= v_max_ren then
        raise exception 'El pedido ya se renovó % veces: publicá uno nuevo', v_max_ren
              using hint = 'limite_renovaciones';
    end if;

    perform set_config('app.transicion_estado', 'on', true);

    update public.pedidos
       set fecha_vencimiento = greatest(now(), fecha_vencimiento)
                               + (p_dias * interval '1 day'),
           estado            = 'publicado',
           renovaciones      = renovaciones + 1,
           fecha_cierre      = null,
           motivo_cierre     = null
     where id = p_pedido_id
    returning * into v_pedido;

    perform set_config('app.transicion_estado', 'off', true);

    return v_pedido;
end;
$$;

comment on function public.renovar_pedido(uuid, integer) is
    'CU-51. Estira fecha_vencimiento y devuelve el pedido a publicado. Los límites salen de renovaciones_maximas y dias_maximos_renovacion (CU-47).';

revoke all on function public.renovar_pedido(uuid, integer) from public;
grant execute on function public.renovar_pedido(uuid, integer) to authenticated;
