-- ============================================================================
-- Laburito — Migración 0013
-- Sprint 3 · T-08: deuda del Sprint 2
-- CU-22 / CU-43 lectura de fotos para el Profesional · CU-15 / CU-51 guard de
-- la edición
-- ============================================================================
--
-- Dos deudas declaradas en la sección 6 del ESTADO que condicionan el resto
-- del sprint:
--
--   1. El Profesional no puede firmar las fotos de un pedido: la política de
--      lectura del bucket `pedidos` (0006) alcanza solo al Buscador dueño.
--      Sin esto, el tablero (CU-43) y el detalle (CU-22) muestran siempre el
--      placeholder.
--
--   2. El PATCH de edición solo mira dueño. La política «pedidos: edición
--      propia» (0006) es de fila entera, y el guard de la 0008 cuida `estado`
--      pero nada más. Hoy, con un PATCH de PostgREST:
--
--        * se le cambia el título a un pedido cerrado, cancelado o vencido;
--        * se estira `fecha_vencimiento`, que es renovar sin gastar
--          renovaciones (el CU-51 permite tres);
--        * se pone `renovaciones = 0`, que es lo mismo por el otro lado.
--
--      La tercera no estaba anotada, pero es la misma deuda: prometer que
--      «la fecha solo la mueve la renovación» no vale nada si el contador de
--      renovaciones se puede reiniciar a mano.
--
-- No se toca ninguna política de `pedidos`: por qué la solución es un trigger
-- y no la RLS está en la decisión del 02/09 del ESTADO («Postgres no tiene RLS
-- por columna»). Es el mismo razonamiento de la 0008, y la misma compuerta.
-- ============================================================================


-- ============================================================================
-- 1. Storage: el Profesional lee las fotos de los pedidos que ve
-- ============================================================================
--
-- Se reemplaza «pedidos: lectura del dueño» por una política que repite, letra
-- por letra, la condición de «fotos: lectura si se ve el pedido» sobre la
-- tabla `pedido_fotos` (0006): el dueño en cualquier estado, y cualquier
-- usuario autenticado si el pedido está publicado y vigente.
--
-- Se escribe explícita en vez de heredarse con un `exists` que dependa de las
-- RLS de `pedidos` —como hacen las tablas de la 0012— a propósito: la fila de
-- `pedido_fotos` y el archivo que referencia tienen que verse bajo **la misma**
-- regla, y la de la tabla está escrita así. Si mañana `pedidos` suma una
-- política de lectura (por ejemplo, el Profesional que ya contactó ve el
-- pedido cerrado), las dos políticas de fotos se cambian juntas.
--
-- Pausado no entra: un pedido pausado no está en la calle y el Profesional no
-- lo ve en `pedidos`, así que tampoco tiene por qué firmar sus fotos.
--
-- El prefijo se sigue comparando como texto, por el motivo de la 0006: una ruta
-- con basura en el primer segmento no tiene que hacer fallar el casteo.
-- ============================================================================

drop policy if exists "pedidos: lectura del dueño" on storage.objects;

drop policy if exists "pedidos: lectura si se ve el pedido" on storage.objects;
create policy "pedidos: lectura si se ve el pedido"
    on storage.objects for select
    to authenticated
    using (
        bucket_id = 'pedidos'
        and exists (
            select 1 from public.pedidos p
             where p.id::text = (storage.foldername(name))[1]
               and (
                   p.buscador_id = auth.uid()
                   or (p.estado = 'publicado' and p.fecha_vencimiento > now())
               )
        )
    );


-- ============================================================================
-- 2. El guard de la edición
-- ============================================================================
--
-- Un trigger BEFORE UPDATE, gemelo del `pedidos_guard_estado` de la 0008, con
-- la **misma compuerta** `app.transicion_estado`. No hace falta una nueva: las
-- tres funciones que la abren —`cambiar_estado_pedido`, `renovar_pedido` y
-- `marcar_pedidos_vencidos`— son exactamente las que tienen derecho a tocar el
-- ciclo de vida del pedido, y todo lo que hacen con la compuerta abierta es
-- legítimo por definición. Con la compuerta cerrada, el UPDATE es una edición
-- del CU-15 (el PATCH de PostgREST o `actualizar_ubicacion_pedido`) y tiene
-- que cumplir dos reglas:
--
--   a) El pedido está `publicado` o `pausado`. Es la regla que la 0009 ya
--      aplicaba a la ubicación y que el PATCH se salteaba. El mensaje es para
--      el usuario y lleva el mismo hint que esa RPC, `transicion_invalida`,
--      así que la app ya lo muestra bien sin cambios.
--
--   b) No cambia ninguna columna del ciclo de vida: `fecha_vencimiento`,
--      `renovaciones`, `fecha_publicacion`, `fecha_cierre`, `motivo_cierre` y
--      `created_at`. Esta sí es un bug nuestro y no del usuario —ninguna
--      pantalla las manda—, así que levanta un centinela, igual que la 0008.
--
-- `estado` no está en la lista de (b): de eso ya se ocupa el guard de la 0008,
-- y repetirlo daría dos mensajes distintos para el mismo error.
--
-- Orden. Los triggers BEFORE de una tabla disparan en orden alfabético:
-- `pedidos_guard_edicion` corre antes que `pedidos_guard_estado` y que
-- `pedidos_set_updated_at`. Consecuencia: un PATCH de `estado` sobre un pedido
-- cerrado devuelve «no se puede editar» y no el centinela de la 0008. Las dos
-- respuestas son correctas; esta es la más útil para quien la lee.
--
-- Qué NO es, igual que la 0008: un control de seguridad. Quien consiga correr
-- SQL arbitrario abre la compuerta. A través de PostgREST no se puede.
--
-- Efecto sobre guiones anteriores: el bloque 3.7 del guion de la 0008 movía
-- `fecha_vencimiento` con un UPDATE directo para provocar el vencimiento. Desde
-- esta migración ese UPDATE falla; para simular un vencimiento hay que abrir
-- la compuerta en la misma transacción, como hace la sección 3 de acá abajo.
-- ============================================================================

create or replace function public.pedidos_guard_edicion()
returns trigger
language plpgsql
as $$
begin
    -- Una de las tres RPC del ciclo de vida: pasa entera.
    if current_setting('app.transicion_estado', true) = 'on' then
        return new;
    end if;

    -- (a) Solo se edita lo que está en la calle o pausado.
    if old.estado not in ('publicado', 'pausado') then
        raise exception 'Un pedido % no se puede editar', old.estado
              using hint = 'transicion_invalida';
    end if;

    -- (b) Las columnas del ciclo de vida no se escriben desde una edición.
    if new.fecha_vencimiento is distinct from old.fecha_vencimiento
       or new.renovaciones      is distinct from old.renovaciones
       or new.fecha_publicacion is distinct from old.fecha_publicacion
       or new.fecha_cierre      is distinct from old.fecha_cierre
       or new.motivo_cierre     is distinct from old.motivo_cierre
       or new.created_at        is distinct from old.created_at
    then
        raise exception 'CAMPO_NO_MODIFICABLE_DIRECTAMENTE'
              using hint   = 'campo_no_modificable',
                    detail = format(
                        'Intento de escribir el ciclo de vida del pedido %s '
                        '(vencimiento, renovaciones, publicación o cierre) con un '
                        'UPDATE común. La vigencia se mueve con renovar_pedido() '
                        'y el cierre con cambiar_estado_pedido().',
                        new.id
                    );
    end if;

    return new;
end;
$$;

comment on function public.pedidos_guard_edicion() is
    'CU-15 / CU-51. Sin la compuerta app.transicion_estado: rechaza editar pedidos que no estén publicados o pausados, y escribir fecha_vencimiento, renovaciones, fecha_publicacion, fecha_cierre, motivo_cierre o created_at.';

drop trigger if exists pedidos_guard_edicion on public.pedidos;
create trigger pedidos_guard_edicion
    before update on public.pedidos
    for each row execute function public.pedidos_guard_edicion();


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
-- Cada bloque se envía solo y termina en rollback: no queda nada escrito.
-- PEGAR_PUBLICADO = pedido publicado · PEGAR_CERRADO = pedido cerrado ·
-- PEGAR_BUSCADOR = dueño de los dos · PEGAR_PROFESIONAL = Profesional activo ·
-- PEGAR_CON_FOTO = pedido publicado con al menos un archivo en el bucket ·
-- PEGAR_SIN_VIGENCIA = otro pedido publicado con archivo y la fecha vencida.
--
--   -- 1. Catálogo: el guard existe y los BEFORE UPDATE quedan en este orden.
--   select tgname from pg_trigger
--    where tgrelid = 'public.pedidos'::regclass and not tgisinternal
--    order by tgname;
--   -- → pedidos_guard_alta, pedidos_guard_edicion, pedidos_guard_estado,
--   --   pedidos_registrar_evento, pedidos_set_updated_at
--   select policyname from pg_policies
--    where schemaname = 'storage' and policyname like 'pedidos:%' order by 1;
--   -- → baja del dueño, lectura si se ve el pedido, subida del dueño
--   --   («lectura del dueño» ya no está)
--
--   -- 2. Editar el título de un pedido publicado sigue funcionando (CU-15).
--   begin;
--   update public.pedidos set titulo = 'Título editado por el guion'
--    where id = 'PEGAR_PUBLICADO';                                    -- → UPDATE 1
--   rollback;
--
--   -- 3. Estirar la vigencia con un PATCH falla.
--   begin;
--   update public.pedidos set fecha_vencimiento = now() + interval '90 days'
--    where id = 'PEGAR_PUBLICADO';
--   -- → ERROR P0001: CAMPO_NO_MODIFICABLE_DIRECTAMENTE  (HINT: campo_no_modificable)
--   rollback;
--
--   -- 4. Tocar el contador de renovaciones también. Se suma uno en vez de
--   --    ponerlo en 0 porque sobre un pedido que nunca se renovó `= 0` no
--   --    cambia nada y el guard, que compara valores, lo deja pasar.
--   begin;
--   update public.pedidos set renovaciones = renovaciones + 1
--    where id = 'PEGAR_PUBLICADO';
--   -- → ERROR P0001: CAMPO_NO_MODIFICABLE_DIRECTAMENTE
--   rollback;
--
--   -- 5. Un pedido cerrado no se edita.
--   begin;
--   update public.pedidos set titulo = 'Título editado por el guion'
--    where id = 'PEGAR_CERRADO';
--   -- → ERROR P0001: Un pedido cerrado no se puede editar  (HINT: transicion_invalida)
--   rollback;
--
--   -- 6. Las tres RPC del ciclo de vida siguen andando con el guard puesto.
--   begin;
--   select public.marcar_pedidos_vencidos() >= 0;                     -- → true
--   rollback;
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_BUSCADOR","role":"authenticated"}', true);
--   select renovaciones from public.renovar_pedido('PEGAR_PUBLICADO', 7);  -- → 1
--   select estado from public.cambiar_estado_pedido('PEGAR_PUBLICADO', 'cerrado');
--   -- → cerrado
--   rollback;
--   --   (renovar exige que al pedido le queden 3 días o menos de vigencia)
--
--   -- 7. El Profesional firma las fotos de un pedido vigente y no las de uno
--   --    vencido. La vigencia se simula abriendo la compuerta, que es la única
--   --    forma de mover fecha_vencimiento desde esta migración.
--   begin;
--   select set_config('app.transicion_estado', 'on', true);
--   update public.pedidos set fecha_vencimiento = now() + interval '1 day'
--    where id = 'PEGAR_CON_FOTO';
--   select set_config('app.transicion_estado', 'off', true);
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select (storage.foldername(name))[1] as pedido, count(*)
--     from storage.objects
--    where bucket_id = 'pedidos'
--      and (storage.foldername(name))[1] in ('PEGAR_CON_FOTO', 'PEGAR_SIN_VIGENCIA')
--    group by 1;
--   -- → una sola fila, la de PEGAR_CON_FOTO
--   rollback;
--
-- ============================================================================
-- FIN
-- ============================================================================
