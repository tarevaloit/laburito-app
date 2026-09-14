-- ============================================================================
-- Laburito — Migración 0010
-- Sprint 2 · CU-15: dejar rastro de las ediciones del pedido
-- ============================================================================
--
-- Qué resuelve:
--
-- `pedido_eventos` es la auditoría del pedido, y hasta acá solo la escribía el
-- trigger `pedidos_registrar_evento` de la 0005, que dispara **cuando cambia
-- el estado**. Una edición del CU-15 no cambia el estado: corrige el título,
-- la descripción, el presupuesto o la ubicación de un pedido que sigue
-- publicado. Con lo que había, esa edición no dejaba rastro.
--
-- Importa porque el pedido es un compromiso con la otra parte: un Profesional
-- que lo leyó ayer y lo ve distinto hoy tiene que poder ver, en la cronología,
-- que se editó y cuándo. Sin eso, «el pedido decía otra cosa» no se puede
-- verificar contra nada.
--
-- Cómo:
--
-- Una función que inserta un evento con `estado_anterior = estado_nuevo`, que
-- es la forma de decir «pasó algo que no fue un cambio de estado», y el motivo
-- fijo 'edicion'. No se agrega una columna de tipo ni un enum nuevo: el motivo
-- ya existe, es texto, y el cliente lo lee por igualdad exacta contra la
-- constante `PedidoEvento.motivoEdicion`.
--
-- SECURITY DEFINER porque sobre `pedido_eventos` **no hay política de INSERT**,
-- a propósito (0006, sección 2.3): la auditoría no se escribe a mano desde
-- PostgREST. La función es el único camino, y por eso valida dueño ella misma
-- con `auth.uid()`: bajo DEFINER las RLS de `pedidos` no la protegen.
--
-- Lo que **no** hace: no verifica que algo haya cambiado de verdad. Guardar el
-- formulario sin tocar nada deja un evento igual. Se prefiere así: la
-- alternativa es comparar la fila vieja contra la nueva del lado del servidor,
-- que obliga a pasarle a esta función todos los campos del pedido.
-- ============================================================================

create or replace function public.registrar_edicion_pedido(p_pedido_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_estado public.pedido_estado;
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    -- Bajo SECURITY DEFINER las RLS no filtran, así que el dueño se comprueba
    -- acá y de forma explícita. Sin este `and`, cualquiera podría ensuciar la
    -- auditoría de un pedido ajeno.
    select estado into v_estado
      from public.pedidos
     where id = p_pedido_id
       and buscador_id = auth.uid();

    if not found then
        raise exception 'El pedido no existe o no es tuyo'
              using hint = 'sin_permiso';
    end if;

    insert into public.pedido_eventos (
        pedido_id, estado_anterior, estado_nuevo, actor_id, motivo
    )
    values (
        p_pedido_id,
        -- Anterior y nuevo iguales: el evento no es una transición.
        v_estado,
        v_estado,
        auth.uid(),
        'edicion'
    );
end;
$$;

comment on function public.registrar_edicion_pedido(uuid) is
    'CU-15. Deja un evento en pedido_eventos por cada edición del pedido. estado_anterior = estado_nuevo indica que no hubo cambio de estado; el motivo es la constante «edicion».';

revoke all     on function public.registrar_edicion_pedido(uuid) from public;
grant  execute on function public.registrar_edicion_pedido(uuid) to authenticated;

-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor, con sesión de Buscador)
-- ============================================================================
--
--   -- 1. La función existe y tiene la firma esperada:
--   select p.proname,
--          pg_get_function_identity_arguments(p.oid) as args,
--          p.prosecdef                               as security_definer
--     from pg_proc p join pg_namespace n on n.oid = p.pronamespace
--    where n.nspname = 'public'
--      and p.proname = 'registrar_edicion_pedido';
--   -- → registrar_edicion_pedido | p_pedido_id uuid | true
--
--   -- 2. Sobre un pedido propio, deja el evento:
--   select public.registrar_edicion_pedido('PEGAR_PEDIDO_PROPIO');
--
--   select estado_anterior, estado_nuevo, motivo, actor_id
--     from public.pedido_eventos
--    where pedido_id = 'PEGAR_PEDIDO_PROPIO'
--    order by created_at desc
--    limit 1;
--   -- → publicado | publicado | edicion | <tu uuid>
--
--   -- 3. Sobre un pedido ajeno, no:
--   select public.registrar_edicion_pedido('PEGAR_PEDIDO_DE_OTRO');
--   -- → ERROR: El pedido no existe o no es tuyo   (hint: sin_permiso)
--
--   -- 4. El INSERT directo sigue prohibido: la auditoría solo se escribe por
--   --    trigger o por esta función.
--   insert into public.pedido_eventos (pedido_id, estado_nuevo)
--   values ('PEGAR_PEDIDO_PROPIO', 'publicado');
--   -- → ERROR: new row violates row-level security policy (42501)
--
-- ============================================================================
-- FIN
-- ============================================================================
