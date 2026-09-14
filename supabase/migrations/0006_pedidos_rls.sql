-- ============================================================================
-- Laburito — Migración 0006
-- Sprint 2 · Pedidos: RLS, Storage y máquina de estados
-- CU-13 (publicar), CU-16 (buscar), CU-51 (renovar)
-- ============================================================================
--
-- Numeración: la 0003 y la 0004 son del CU-11 y la 0005 crea las tablas de
-- pedidos, así que esta migración es la 0006 aunque el plan la nombre
-- «0004_pedidos_rls».
--
-- Relación con la 0005: aquella dejó una primera tanda de políticas, escritas
-- con `for all`. Esta las reemplaza por políticas separadas por verbo, que es
-- lo que permite la regla del punto 2: **no hay DELETE**. Un pedido no se
-- borra, se cancela — si se pudiera borrar, se llevaría puesta por cascada su
-- propia auditoría de `pedido_eventos`, que es justo lo que prueba que el
-- pedido existió. Cada política se dropea antes de crearse, así que esta
-- migración se puede correr con la 0005 aplicada o sin aplicar.
--
-- Qué NO hay acá, a propósito:
--   * Políticas de administrador. Las de la 0005 eran `for all` y habilitaban
--     DELETE. El panel de Admin es del Sprint 6 (CU-35); cuando llegue, van
--     como políticas de SELECT y UPDATE, nunca de DELETE.
--
-- ============================================================================

-- ============================================================================
-- 1. Columna de renovaciones (CU-51)
-- ============================================================================

alter table public.pedidos
    add column if not exists renovaciones integer not null default 0;

do $$
begin
    if not exists (
        select 1 from pg_constraint where conname = 'pedidos_renovaciones_ck'
    ) then
        alter table public.pedidos
            add constraint pedidos_renovaciones_ck
            check (renovaciones between 0 and 3);
    end if;
end;
$$;

comment on column public.pedidos.renovaciones is
    'Cuántas veces se estiró fecha_vencimiento con renovar_pedido(). Tope de 3: pasado eso el Buscador publica un pedido nuevo, para que el listado del CU-16 no se llene de pedidos eternos.';

-- ============================================================================
-- 2. ROW LEVEL SECURITY
-- ============================================================================

alter table public.pedidos        enable row level security;
alter table public.pedido_fotos   enable row level security;
alter table public.pedido_eventos enable row level security;

-- Baja de las políticas de la 0005
drop policy if exists "buscador propio: sus pedidos"            on public.pedidos;
drop policy if exists "público: pedidos publicados vigentes"    on public.pedidos;
drop policy if exists "admin: gestión de pedidos"               on public.pedidos;
drop policy if exists "buscador propio: fotos de sus pedidos"   on public.pedido_fotos;
drop policy if exists "público: fotos de pedidos visibles"      on public.pedido_fotos;
drop policy if exists "admin: gestión de fotos"                 on public.pedido_fotos;
drop policy if exists "buscador propio: auditoría de sus pedidos" on public.pedido_eventos;
drop policy if exists "admin: lectura de auditoría"             on public.pedido_eventos;

-- ----------------------------------------------------------------------------
-- 2.1 pedidos
-- ----------------------------------------------------------------------------

-- El Buscador ve los suyos siempre, en cualquier estado.
drop policy if exists "pedidos: lectura propia" on public.pedidos;
create policy "pedidos: lectura propia"
    on public.pedidos for select
    to authenticated
    using (buscador_id = auth.uid());

-- El resto ve solo lo que está en la calle. Es la política sobre la que se
-- apoya `pedidos_publicos` (que corre con security_invoker) y la que va a usar
-- el Profesional en el CU-16 / CU-21.
drop policy if exists "pedidos: lectura de publicados vigentes" on public.pedidos;
create policy "pedidos: lectura de publicados vigentes"
    on public.pedidos for select
    to authenticated
    using (estado = 'publicado' and fecha_vencimiento > now());

-- Publicar: solo a nombre propio, solo un Buscador, solo si la cuenta vive.
drop policy if exists "pedidos: alta del buscador" on public.pedidos;
create policy "pedidos: alta del buscador"
    on public.pedidos for insert
    to authenticated
    with check (
        buscador_id = auth.uid()
        and exists (
            select 1
              from public.perfiles p
             where p.id = auth.uid()
               and p.tipo = 'buscador'
               and p.estado <> 'baja'
               and p.deleted_at is null
        )
    );

-- Editar: solo los propios, y sin poder regalárselos a otro (de eso se ocupa
-- el WITH CHECK; sin él, un UPDATE podría reescribir buscador_id).
drop policy if exists "pedidos: edición propia" on public.pedidos;
create policy "pedidos: edición propia"
    on public.pedidos for update
    to authenticated
    using (buscador_id = auth.uid())
    with check (buscador_id = auth.uid());

-- DELETE: sin política. Con RLS activo y ninguna política de DELETE, el verbo
-- queda denegado para todos. Es deliberado, ver el encabezado.

-- ----------------------------------------------------------------------------
-- 2.2 pedido_fotos — la visibilidad se hereda del pedido padre
-- ----------------------------------------------------------------------------

drop policy if exists "fotos: lectura si se ve el pedido" on public.pedido_fotos;
create policy "fotos: lectura si se ve el pedido"
    on public.pedido_fotos for select
    to authenticated
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and (
                   p.buscador_id = auth.uid()
                   or (p.estado = 'publicado' and p.fecha_vencimiento > now())
               )
        )
    );

drop policy if exists "fotos: alta del dueño del pedido" on public.pedido_fotos;
create policy "fotos: alta del dueño del pedido"
    on public.pedido_fotos for insert
    to authenticated
    with check (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and p.buscador_id = auth.uid()
        )
    );

drop policy if exists "fotos: edición del dueño del pedido" on public.pedido_fotos;
create policy "fotos: edición del dueño del pedido"
    on public.pedido_fotos for update
    to authenticated
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and p.buscador_id = auth.uid()
        )
    )
    with check (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and p.buscador_id = auth.uid()
        )
    );

-- Las fotos sí se borran: son archivos, no historia. El pedido queda.
drop policy if exists "fotos: baja del dueño del pedido" on public.pedido_fotos;
create policy "fotos: baja del dueño del pedido"
    on public.pedido_fotos for delete
    to authenticated
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and p.buscador_id = auth.uid()
        )
    );

-- ----------------------------------------------------------------------------
-- 2.3 pedido_eventos — auditoría: se lee, no se escribe
-- ----------------------------------------------------------------------------

drop policy if exists "eventos: lectura del dueño del pedido" on public.pedido_eventos;
create policy "eventos: lectura del dueño del pedido"
    on public.pedido_eventos for select
    to authenticated
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_eventos.pedido_id
               and p.buscador_id = auth.uid()
        )
    );

-- Sin políticas de INSERT, UPDATE ni DELETE: la única vía de escritura es el
-- trigger `pedidos_registrar_evento` de la 0005, cuya función es SECURITY
-- DEFINER y por eso no pasa por RLS. Nadie escribe la auditoría a mano.

-- ============================================================================
-- 3. STORAGE — bucket `pedidos`
-- ============================================================================
--
-- Convención de ruta: {pedido_id}/{uuid}.jpg
--
-- El primer segmento es el id del pedido, no el del usuario: así una sola
-- comparación contra `pedidos.buscador_id` resuelve el permiso, y borrar el
-- pedido es borrar un prefijo.
--
-- Consecuencia para el cliente: **el pedido tiene que existir antes de subir la
-- primera foto**. El asistente de creación del CU-13 inserta el pedido (que ya
-- nace en 'publicado') y recién después sube las imágenes con el id devuelto.
-- Si el usuario abandona a mitad de camino, queda un pedido sin fotos, que es
-- válido; la alternativa —subir a una carpeta temporal y mover— exige mover
-- objetos entre prefijos y no vale la complejidad.
--
-- El prefijo se compara como texto y no casteado a uuid: una ruta con basura
-- en el primer segmento haría fallar el casteo con 22P02 en vez de,
-- simplemente, no dar permiso.
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pedidos', 'pedidos', false, 5242880,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "pedidos: subida del dueño" on storage.objects;
create policy "pedidos: subida del dueño"
    on storage.objects for insert
    to authenticated
    with check (
        bucket_id = 'pedidos'
        and exists (
            select 1 from public.pedidos p
             where p.id::text = (storage.foldername(name))[1]
               and p.buscador_id = auth.uid()
        )
    );

drop policy if exists "pedidos: lectura del dueño" on storage.objects;
create policy "pedidos: lectura del dueño"
    on storage.objects for select
    to authenticated
    using (
        bucket_id = 'pedidos'
        and exists (
            select 1 from public.pedidos p
             where p.id::text = (storage.foldername(name))[1]
               and p.buscador_id = auth.uid()
        )
    );

drop policy if exists "pedidos: baja del dueño" on storage.objects;
create policy "pedidos: baja del dueño"
    on storage.objects for delete
    to authenticated
    using (
        bucket_id = 'pedidos'
        and exists (
            select 1 from public.pedidos p
             where p.id::text = (storage.foldername(name))[1]
               and p.buscador_id = auth.uid()
        )
    );

-- ============================================================================
-- 4. MÁQUINA DE ESTADOS
-- ============================================================================

-- 4.1 Tabla de transiciones. Función aparte para que la RPC y cualquier
--     validación futura lean la misma regla y no se separen.
create or replace function public.transicion_pedido_valida(
    p_desde public.pedido_estado,
    p_hasta public.pedido_estado
)
returns boolean
language sql
immutable
as $$
    select case p_desde
        when 'publicado' then p_hasta in ('pausado', 'cerrado', 'cancelado', 'vencido')
        when 'pausado'   then p_hasta in ('publicado', 'cerrado', 'cancelado', 'vencido')
        -- 'vencido' -> 'publicado' existe, pero solo por renovar_pedido() (CU-51):
        -- volver a publicar sin correr la fecha dejaría el pedido vencido y visible.
        when 'vencido'   then false
        -- 'cerrado' y 'cancelado' son terminales.
        else false
    end;
$$;

comment on function public.transicion_pedido_valida(public.pedido_estado, public.pedido_estado) is
    'Única fuente de la máquina de estados del pedido. cerrado y cancelado son terminales; de vencido solo se sale renovando.';

-- 4.2 RPC de cambio de estado.
--     SECURITY INVOKER a propósito: el UPDATE pasa por la política
--     «pedidos: edición propia», así que la RPC no puede tocar el pedido de
--     otro ni aunque tuviera un bug en la validación de dueño.
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

    return v_pedido;
end;
$$;

comment on function public.cambiar_estado_pedido(uuid, public.pedido_estado, text) is
    'Único camino para mover el estado de un pedido. Valida la transición y deja el rastro en pedido_eventos por el trigger de la 0005.';

revoke all on function public.cambiar_estado_pedido(uuid, public.pedido_estado, text) from public;
grant execute on function public.cambiar_estado_pedido(uuid, public.pedido_estado, text) to authenticated;

-- ============================================================================
-- 5. RENOVACIÓN (CU-51)
-- ============================================================================
--
-- Se puede renovar un pedido vencido, o uno vivo que esté por vencer: la
-- ventana es de 3 días. Antes de eso no tiene sentido —todavía le queda
-- vigencia— y dejarlo abierto convertiría la renovación en una forma de tener
-- un pedido permanente sin gastar renovaciones.
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
    update public.pedidos
       set fecha_vencimiento = greatest(now(), fecha_vencimiento)
                               + (p_dias * interval '1 day'),
           estado            = 'publicado',
           renovaciones      = renovaciones + 1,
           fecha_cierre      = null,
           motivo_cierre     = null
     where id = p_pedido_id
    returning * into v_pedido;

    return v_pedido;
end;
$$;

comment on function public.renovar_pedido(uuid, integer) is
    'CU-51. Estira fecha_vencimiento y devuelve el pedido a publicado. Es la única vía de salida del estado vencido. Máximo 3 renovaciones.';

revoke all on function public.renovar_pedido(uuid, integer) from public;
grant execute on function public.renovar_pedido(uuid, integer) to authenticated;

-- ============================================================================
-- 6. VENCIMIENTO AUTOMÁTICO
-- ============================================================================
--
-- SECURITY DEFINER porque el barrido toca pedidos de todos los usuarios: como
-- INVOKER, con las RLS de arriba, cada quien vencería únicamente los propios.
--
-- Cómo se dispara:
--
--   * En producción, con pg_cron. La extensión se habilita desde el dashboard
--     (Database → Extensions → pg_cron) y después, una sola vez:
--
--       select cron.schedule(
--           'pedidos-vencidos',
--           '*/15 * * * *',
--           $cron$ select public.marcar_pedidos_vencidos(); $cron$
--       );
--
--     No se agenda acá: habilitar la extensión pide permisos que la migración
--     no tiene, y correr esto sin pg_cron abortaría la migración entera.
--
--   * **En el entorno académico no hay cron.** El cliente llama a esta RPC al
--     abrir el historial de pedidos y el listado del CU-16. Es barato: el
--     índice `pedidos_estado_vencimiento_idx` la resuelve sin recorrer la
--     tabla, y si no hay nada que vencer devuelve 0 sin escribir.
--
-- Las consultas de lectura NO dependen de este barrido: filtran por
-- `fecha_vencimiento > now()`, así que un pedido vencido nunca se lista aunque
-- la función no haya corrido. El barrido está para que el estado guardado
-- coincida con la realidad y para que quede el evento en la auditoría.
--
-- Nota sobre `pedido_eventos.actor_id`: el trigger lo toma de auth.uid(), así
-- que bajo pg_cron queda nulo (correcto) y bajo llamada del cliente queda el
-- uid de quien abrió la pantalla. Es ruido conocido del entorno académico.
-- ============================================================================

create or replace function public.marcar_pedidos_vencidos()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
    v_cantidad integer;
begin
    update public.pedidos
       set estado       = 'vencido',
           fecha_cierre = now()
     where estado in ('publicado', 'pausado')
       and fecha_vencimiento < now();

    get diagnostics v_cantidad = row_count;
    return v_cantidad;
end;
$$;

comment on function public.marcar_pedidos_vencidos() is
    'Pasa a vencido los pedidos vivos con fecha_vencimiento cumplida. Devuelve cuántos movió. Pensada para pg_cron; en el entorno académico la llama el cliente al abrir el historial.';

revoke all on function public.marcar_pedidos_vencidos() from public;
grant execute on function public.marcar_pedidos_vencidos() to authenticated;

-- ============================================================================
-- 7. Prueba de aceptación (SQL Editor)
-- ============================================================================
--
--   -- La transición válida pasa y deja evento:
--   select public.cambiar_estado_pedido('PEGAR_PEDIDO', 'pausado');
--   select estado_anterior, estado_nuevo from public.pedido_eventos
--    where pedido_id = 'PEGAR_PEDIDO' order by created_at desc limit 1;
--
--   -- La inválida tiene que fallar con mensaje en castellano:
--   select public.cambiar_estado_pedido('PEGAR_PEDIDO', 'cancelado');
--   select public.cambiar_estado_pedido('PEGAR_PEDIDO', 'publicado');
--   -- → «Un pedido cancelado no se puede reabrir»
--
--   -- El DELETE tiene que estar denegado incluso para el dueño:
--   delete from public.pedidos where id = 'PEGAR_PEDIDO';
--   -- → 0 filas (RLS, no error)
--
--   -- Vencimiento y renovación:
--   update public.pedidos set fecha_vencimiento = now() - interval '1 day'
--    where id = 'PEGAR_PEDIDO';
--   select public.marcar_pedidos_vencidos();        -- → 1
--   select public.renovar_pedido('PEGAR_PEDIDO', 7); -- vuelve a publicado
--   -- repetir 3 veces más → «ya se renovó 3 veces»
--
-- ============================================================================
-- FIN
-- ============================================================================
