-- ============================================================================
-- Laburito — Migración 0008
-- Sprint 2 · Pedidos: blindaje de la máquina de estados
-- ============================================================================
--
-- Problema que resuelve:
--
-- La política «pedidos: edición propia» de la 0006 es un `for update` sobre la
-- fila entera. No distingue columnas: quien puede corregir el título puede
-- también escribir `estado`. Un PATCH directo de PostgREST —
--
--     PATCH /rest/v1/pedidos?id=eq.<uuid>   {"estado": "publicado"}
--
-- — saltea `cambiar_estado_pedido()` y con ella la tabla de transiciones, el
-- control de vencimiento y el tope de renovaciones. Reabrir un pedido cerrado,
-- o despausar uno con la fecha cumplida, es un PATCH de una línea.
--
-- Es la deuda «El estado del pedido se puede cambiar sin pasar por la RPC» de
-- la sección 6 del ESTADO.
--
-- Cómo se blinda:
--
-- Un trigger BEFORE UPDATE rechaza cualquier cambio de `estado`, y las tres
-- funciones que sí tienen derecho a moverlo abren una compuerta antes del
-- update y la cierran después. La compuerta es un parámetro de sesión,
-- `app.transicion_estado`, puesto con `set_config(..., true)`: el tercer
-- argumento en `true` lo hace **local a la transacción**, así que
--
--   * si la RPC aborta a mitad, la compuerta no queda abierta;
--   * PostgREST atiende cada request en su propia transacción, de modo que un
--     request no hereda la compuerta de otro;
--   * dos sesiones concurrentes no se pisan.
--
-- Qué NO es esto:
--
-- **No es un control de seguridad, es un control de integridad.** El parámetro
-- `app.*` lo puede escribir cualquiera que consiga ejecutar SQL arbitrario; lo
-- que lo vuelve efectivo es que a través de PostgREST no hay forma de correr un
-- `set_config()` antes del PATCH. Quien manda es la RLS: el trigger existe para
-- que la aplicación no pueda saltearse su propia máquina de estados por
-- descuido, no para contener a un atacante que ya tiene una conexión SQL.
--
-- Limitación conocida — el INSERT:
--
-- El guard es solo de UPDATE. Nada impide hoy insertar un pedido que nazca
-- directamente en `cerrado` o en `vencido`, porque la política de alta de la
-- 0006 no mira la columna `estado` y el `default 'publicado'` se puede pisar.
-- No se tapa acá a propósito: hacerlo obligaría a decidir si `crear_pedido()`
-- (migración 0009, CU-13) puede o no elegir el estado inicial, y esa decisión
-- todavía no está tomada. El daño posible es acotado —el pedido es del propio
-- Buscador y nace muerto—, pero queda anotado como pendiente.
-- ============================================================================

-- ============================================================================
-- 1. El guard
-- ============================================================================
--
-- El nombre importa: PostgreSQL dispara los triggers BEFORE de una misma tabla
-- **en orden alfabético**, y `pedidos_guard_estado` va antes que
-- `pedidos_set_updated_at` (0005). Un update rechazado no llega a tocar
-- `updated_at`.
--
-- `current_setting(..., true)` con el segundo argumento en `true` devuelve NULL
-- en vez de reventar cuando el parámetro no está definido, que es el caso
-- normal: la compuerta solo existe adentro de las tres funciones. Por eso la
-- comparación es `is distinct from` y no `<>`, que con NULL daría NULL y no
-- entraría al `if`.
-- ============================================================================

create or replace function public.pedidos_guard_estado()
returns trigger
language plpgsql
as $$
begin
    -- El update no toca el estado: es una edición común (CU-15) y pasa.
    if new.estado is not distinct from old.estado then
        return new;
    end if;

    -- Toca el estado sin venir de una RPC autorizada.
    if current_setting('app.transicion_estado', true) is distinct from 'on' then
        raise exception 'ESTADO_NO_MODIFICABLE_DIRECTAMENTE'
              using hint   = 'estado_no_modificable',
                    detail = format(
                        'Intento de mover el pedido %s de «%s» a «%s» sin pasar '
                        'por cambiar_estado_pedido(), renovar_pedido() ni '
                        'marcar_pedidos_vencidos().',
                        new.id, old.estado, new.estado
                    );
    end if;

    return new;
end;
$$;

comment on function public.pedidos_guard_estado() is
    'Rechaza los UPDATE que cambian pedidos.estado sin la compuerta app.transicion_estado. Deja pasar los que no lo tocan.';

drop trigger if exists pedidos_guard_estado on public.pedidos;
create trigger pedidos_guard_estado
    before update on public.pedidos
    for each row execute function public.pedidos_guard_estado();

-- ============================================================================
-- 2. Las tres funciones que sí pueden mover el estado
-- ============================================================================
--
-- Se reescriben completas —`create or replace` del cuerpo entero de la 0006—
-- en vez de parchearse, para que este archivo sea la versión vigente y no haya
-- que leer dos migraciones para saber qué hace cada una. Lo único que cambia
-- respecto de la 0006 es el par de `set_config()` alrededor del UPDATE.
--
-- La compuerta se cierra explícitamente después del update aunque sea local a
-- la transacción: si mañana una función llama a otra, o una RPC hace un segundo
-- update después del primero, la ventana queda del tamaño mínimo.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 cambiar_estado_pedido — CU-14, CU-20, CU-29
-- ----------------------------------------------------------------------------

create or replace function public.cambiar_estado_pedido(
    p_pedido_id     uuid,
    p_nuevo_estado  public.pedido_estado,
    p_motivo        text default null
)
returns public.pedidos
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_pedido public.pedidos;
    v_motivo text := nullif(trim(coalesce(p_motivo, '')), '');
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
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

    if v_pedido.estado = p_nuevo_estado then
        raise exception 'El pedido ya está en estado «%»', p_nuevo_estado
              using hint = 'transicion_invalida';
    end if;

    if not public.transicion_pedido_valida(v_pedido.estado, p_nuevo_estado) then
        if v_pedido.estado in ('cerrado', 'cancelado') then
            raise exception 'Un pedido % no se puede reabrir', v_pedido.estado
                  using hint = 'transicion_invalida';
        elsif v_pedido.estado = 'vencido' then
            raise exception 'El pedido está vencido: para volver a publicarlo, renovalo'
                  using hint = 'transicion_invalida';
        else
            raise exception 'No se puede pasar de «%» a «%»', v_pedido.estado, p_nuevo_estado
                  using hint = 'transicion_invalida';
        end if;
    end if;

    -- Despausar un pedido cuya fecha ya pasó lo dejaría 'publicado' pero
    -- invisible (las consultas filtran por fecha). Se corta acá y se manda a
    -- renovar, que es la operación que sí corre la fecha.
    if p_nuevo_estado = 'publicado' and v_pedido.fecha_vencimiento <= now() then
        raise exception 'El pedido ya pasó su fecha de vencimiento: renovalo en vez de reanudarlo'
              using hint = 'transicion_invalida';
    end if;

    perform set_config('app.transicion_estado', 'on', true);

    update public.pedidos
       set estado        = p_nuevo_estado,
           motivo_cierre = case
                               when p_nuevo_estado in ('cerrado', 'cancelado', 'vencido')
                               then v_motivo
                               else motivo_cierre
                           end,
           fecha_cierre  = case
                               when p_nuevo_estado in ('cerrado', 'cancelado', 'vencido')
                               then now()
                               else null
                           end
     where id = p_pedido_id
    returning * into v_pedido;

    perform set_config('app.transicion_estado', 'off', true);

    return v_pedido;
end;
$$;

comment on function public.cambiar_estado_pedido(uuid, public.pedido_estado, text) is
    'Único camino para mover el estado de un pedido. Valida la transición, abre la compuerta del guard de la 0008 y deja el rastro en pedido_eventos por el trigger de la 0005.';

revoke all on function public.cambiar_estado_pedido(uuid, public.pedido_estado, text) from public;
grant execute on function public.cambiar_estado_pedido(uuid, public.pedido_estado, text) to authenticated;

-- ----------------------------------------------------------------------------
-- 2.2 renovar_pedido — CU-51
-- ----------------------------------------------------------------------------
--
-- Es la única transición `vencido → publicado` que existe:
-- `transicion_pedido_valida()` la niega a propósito, porque volver a publicar
-- sin correr la fecha dejaría el pedido vencido y visible. Por eso no llama a
-- `cambiar_estado_pedido()` y necesita compuerta propia.
-- ----------------------------------------------------------------------------

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
    v_pedido  public.pedidos;
    v_ventana constant interval := interval '3 days';
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    if p_dias is null or p_dias not between 1 and 30 then
        raise exception 'La renovación tiene que ser de entre 1 y 30 días'
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

    if v_pedido.renovaciones >= 3 then
        raise exception 'El pedido ya se renovó 3 veces: publicá uno nuevo'
              using hint = 'limite_renovaciones';
    end if;

    -- Se cuenta desde hoy si ya venció, y desde el vencimiento si todavía no,
    -- para no regalar días ni comérselos.
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
    'CU-51. Estira fecha_vencimiento y devuelve el pedido a publicado. Es la única vía de salida del estado vencido. Máximo 3 renovaciones.';

revoke all on function public.renovar_pedido(uuid, integer) from public;
grant execute on function public.renovar_pedido(uuid, integer) to authenticated;

-- ----------------------------------------------------------------------------
-- 2.3 marcar_pedidos_vencidos — barrido
-- ----------------------------------------------------------------------------
--
-- Sigue siendo SECURITY DEFINER: el barrido toca pedidos de todos los usuarios
-- y como INVOKER, con las RLS de la 0006, cada quien vencería solo los propios.
-- El guard no distingue definer de invoker —es un trigger, corre igual—, así
-- que también necesita la compuerta.
--
-- Cómo se dispara y por qué el cliente lo llama al abrir el historial: ver el
-- encabezado de la sección 6 de la 0006.
-- ----------------------------------------------------------------------------

create or replace function public.marcar_pedidos_vencidos()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
    v_cantidad integer;
begin
    perform set_config('app.transicion_estado', 'on', true);

    update public.pedidos
       set estado       = 'vencido',
           fecha_cierre = now()
     where estado in ('publicado', 'pausado')
       and fecha_vencimiento < now();

    get diagnostics v_cantidad = row_count;

    perform set_config('app.transicion_estado', 'off', true);

    return v_cantidad;
end;
$$;

comment on function public.marcar_pedidos_vencidos() is
    'Pasa a vencido los pedidos vivos con fecha_vencimiento cumplida. Devuelve cuántos movió. Pensada para pg_cron; en el entorno académico la llama el cliente al abrir el historial.';

revoke all on function public.marcar_pedidos_vencidos() from public;
grant execute on function public.marcar_pedidos_vencidos() to authenticated;

-- ============================================================================
-- 3. Prueba de aceptación (SQL Editor)
-- ============================================================================
--
-- Correr como el Buscador dueño del pedido, no como `postgres`: desde el SQL
-- Editor de Supabase se corre con un rol que ignora las RLS, así que las
-- consultas que dependen de `auth.uid()` no valen. Para las RPC conviene
-- probarlas desde la app o con un token de usuario.
--
-- El trigger, en cambio, se puede verificar tal cual desde el editor: no mira
-- quién sos, mira si la compuerta está abierta.
--
--   -- Un pedido de prueba (pegá el uuid en PEGAR_PEDIDO):
--   select id, estado, titulo from public.pedidos order by created_at desc limit 5;
--
--   -- 3.1 El PATCH directo tiene que fallar:
--   update public.pedidos set estado = 'cerrado' where id = 'PEGAR_PEDIDO';
--   -- → ERROR: ESTADO_NO_MODIFICABLE_DIRECTAMENTE
--   --   DETALLE: Intento de mover el pedido ... de «publicado» a «cerrado» ...
--
--   -- 3.2 Editar cualquier otra cosa tiene que seguir funcionando (CU-15):
--   update public.pedidos set titulo = 'Título editado' where id = 'PEGAR_PEDIDO';
--   -- → UPDATE 1, y updated_at se movió
--   select titulo, estado, updated_at from public.pedidos where id = 'PEGAR_PEDIDO';
--
--   -- 3.3 Un update que "toca" el estado pero no lo cambia también pasa:
--   update public.pedidos set estado = estado where id = 'PEGAR_PEDIDO';
--   -- → UPDATE 1 (el guard compara valores, no la lista de columnas del SET)
--
--   -- 3.4 La RPC sí puede, y deja el evento:
--   select public.cambiar_estado_pedido('PEGAR_PEDIDO', 'pausado');
--   select estado_anterior, estado_nuevo, motivo
--     from public.pedido_eventos
--    where pedido_id = 'PEGAR_PEDIDO'
--    order by created_at desc limit 1;
--   -- → publicado | pausado
--
--   -- 3.5 La compuerta se cierra sola. Estas dos líneas, juntas y en el mismo
--   --     envío —el editor de Supabase envuelve el script entero en una sola
--   --     transacción, así que comparten la compuerta—, tienen que terminar en
--   --     error:
--   select public.cambiar_estado_pedido('PEGAR_PEDIDO', 'pausado');
--   update public.pedidos set estado = 'cerrado' where id = 'PEGAR_PEDIDO';
--   -- → ERROR: ESTADO_NO_MODIFICABLE_DIRECTAMENTE
--   --   Si el update pasa, falta el `set_config(..., 'off', true)` del final de
--   --   la RPC. Es la prueba que de verdad importa: en producción cada request
--   --   de PostgREST es su propia transacción y la compuerta muere sola, pero
--   --   acá se ve que además se cierra a mano.
--
--   -- 3.6 Una RPC que aborta tampoco la deja abierta, por construcción: el
--   --     `raise` revierte la transacción entera y con ella el set_config. No
--   --     hay forma de probarlo en un solo envío del editor, porque después del
--   --     error toda sentencia siguiente falla con «current transaction is
--   --     aborted». Se verifica desde la app: un cierre inválido seguido de un
--   --     PATCH de estado tiene que dar ESTADO_NO_MODIFICABLE_DIRECTAMENTE.
--
--   -- 3.7 El barrido sigue funcionando con el guard puesto:
--   update public.pedidos set fecha_vencimiento = now() - interval '1 day'
--    where id = 'PEGAR_PEDIDO';                      -- no toca estado: pasa
--   select public.marcar_pedidos_vencidos();          -- → 1
--   select estado from public.pedidos where id = 'PEGAR_PEDIDO';  -- → vencido
--
--   -- 3.8 Y la renovación, que es la única salida de 'vencido':
--   select public.renovar_pedido('PEGAR_PEDIDO', 7);
--   select estado, renovaciones, fecha_vencimiento
--     from public.pedidos where id = 'PEGAR_PEDIDO';
--   -- → publicado | 1 | hoy + 7 días
--
--   -- 3.9 El trigger quedó en el orden correcto (guard antes que updated_at):
--   select tgname
--     from pg_trigger
--    where tgrelid = 'public.pedidos'::regclass
--      and not tgisinternal
--    order by tgname;
--   -- → pedidos_guard_estado, pedidos_registrar_evento, pedidos_set_updated_at
--
-- ============================================================================
-- FIN
-- ============================================================================
