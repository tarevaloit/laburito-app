-- ============================================================================
-- Laburito — Migración 0023
-- Sprint 4 · CU-25 Postularse (Desbloquear Contacto)
-- ============================================================================
--
-- Tres funciones:
--
--   * `contacto_pedido(p_pedido)`: lo que el Profesional ve del Buscador en el
--     detalle del pedido (Figura 3.12). Antes de desbloquear, el nombre corto
--     («Laura G.») y el teléfono enmascarado; después, el teléfono entero.
--     No cobra nada.
--
--   * `desbloquear_contacto(p_pedido)`: cobra un token y revela el teléfono. Si
--     ese Profesional ya lo había desbloqueado, lo devuelve sin cobrar.
--
--   * `interesados_pedido(p_pedido)`: cuántos Profesionales desbloquearon el
--     contacto, para el dueño del pedido (paso 6 del CU-25: «registra al
--     profesional en la lista de interesados»).
--
-- Las tres son SECURITY DEFINER porque leen `perfiles` del Buscador, que la RLS
-- no le deja ver a un Profesional, y `pedidos`, que desde la 0020 tampoco. Por
-- eso cada una empieza comprobando quién llama.
-- ============================================================================


-- ============================================================================
-- 1. contacto_pedido
-- ============================================================================
--
-- El pedido tiene que ser visible (publicado y vigente) **o** ya estar
-- desbloqueado por quien llama: un contacto que se pagó no se pierde porque el
-- Buscador cierre el pedido al día siguiente.
--
-- El teléfono enmascarado deja ver el prefijo («+54 911 ••••••»), que es lo que
-- dibuja la figura: dice que hay un número sin decir cuál.
-- ============================================================================

create or replace function public.contacto_pedido(p_pedido uuid)
returns table (
    nombre_corto          text,
    telefono_enmascarado  text,
    telefono              text,
    desbloqueado          boolean
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_desbloqueado boolean;
begin
    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional puede ver el contacto de un pedido.'
              using hint = 'sin_permiso';
    end if;

    v_desbloqueado := exists (
        select 1 from public.contactos_desbloqueados c
         where c.profesional_id = auth.uid() and c.pedido_id = p_pedido
    );

    if not v_desbloqueado and not public.es_pedido_visible(p_pedido) then
        return;
    end if;

    return query
    select
        trim(b.nombre || ' ' || coalesce(left(b.apellido, 1) || '.', '')),
        case
            when coalesce(b.telefono, '') = '' then null
            else left(regexp_replace(b.telefono, '\s', '', 'g'), 5) || ' ••••••'
        end,
        case when v_desbloqueado then b.telefono end,
        v_desbloqueado
      from public.pedidos p
      join public.perfiles b on b.id = p.buscador_id
     where p.id = p_pedido;
end;
$$;

comment on function public.contacto_pedido(uuid) is
    'CU-25. Datos del Buscador para el detalle del pedido: nombre corto y teléfono enmascarado; el teléfono entero solo si quien llama ya lo desbloqueó. No cobra.';


-- ============================================================================
-- 2. desbloquear_contacto
-- ============================================================================
--
-- Reglas, en el orden en que se comprueban —ninguna cobra si falla—:
--   1. Profesional activo **y aprobado**: el CU-09 existe para que un Buscador
--      no le dé su teléfono a alguien sin verificar.
--   2. Si ya lo desbloqueó, devuelve el contacto sin cobrar.
--   3. El pedido está publicado y vigente, y no es propio.
--   4. El Buscador dejó un teléfono (no cobrar por un contacto vacío).
--   5. Hay saldo: lo decide `aplicar_movimiento_tokens`, con el hint
--      `saldo_insuficiente` que la app usa para ofrecer «Comprar tokens».
--
-- La fila del Profesional se bloquea **antes** de mirar si ya estaba
-- desbloqueado: dos toques seguidos no pueden cobrar dos veces, y el segundo
-- ve la fila que escribió el primero en vez de chocar con la clave primaria.
-- ============================================================================

create or replace function public.desbloquear_contacto(p_pedido uuid)
returns table (
    nombre_corto  text,
    telefono      text,
    saldo         integer,
    cobrado       boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid         uuid := auth.uid();
    v_pedido      public.pedidos;
    v_telefono    text;
    v_nombre      text;
    v_movimiento  public.movimientos_tokens;
    v_saldo       integer;
begin
    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa puede desbloquear contactos.'
              using hint = 'sin_permiso';
    end if;

    select saldo_tokens into v_saldo
      from public.profesionales
     where perfil_id = v_uid
       and estado_verificacion = 'aprobado'
       for update;

    if not found then
        raise exception 'Tu cuenta tiene que estar verificada para contactar a un Buscador. Revisá el estado de tu documentación.'
              using hint = 'sin_verificar';
    end if;

    select * into v_pedido from public.pedidos where id = p_pedido;

    select trim(b.nombre || ' ' || coalesce(left(b.apellido, 1) || '.', '')), b.telefono
      into v_nombre, v_telefono
      from public.perfiles b
     where b.id = v_pedido.buscador_id;

    if exists (
        select 1 from public.contactos_desbloqueados c
         where c.profesional_id = v_uid and c.pedido_id = p_pedido
    ) then
        return query select v_nombre, v_telefono, v_saldo, false;
        return;
    end if;

    if v_pedido.id is null
       or v_pedido.estado <> 'publicado'
       or v_pedido.fecha_vencimiento <= now() then
        raise exception 'Este pedido ya no está disponible.'
              using hint = 'pedido_no_disponible';
    end if;

    if v_pedido.buscador_id = v_uid then
        raise exception 'Es tu propio pedido.'
              using hint = 'sin_permiso';
    end if;

    if coalesce(trim(v_telefono), '') = '' then
        raise exception 'Este Buscador no dejó un teléfono de contacto. No se te cobró ningún token.'
              using hint = 'sin_telefono';
    end if;

    v_movimiento := public.aplicar_movimiento_tokens(
        v_uid, 'consumo', -1, 'Desbloqueo de contacto', p_pedido => p_pedido
    );

    insert into public.contactos_desbloqueados (profesional_id, pedido_id, movimiento_id)
    values (v_uid, p_pedido, v_movimiento.id);

    return query select v_nombre, v_telefono, v_movimiento.saldo_resultante, true;
end;
$$;

comment on function public.desbloquear_contacto(uuid) is
    'CU-25. Cobra 1 token y devuelve el teléfono del Buscador. Exige Profesional aprobado; si ya estaba desbloqueado, no cobra.';


-- ============================================================================
-- 3. interesados_pedido
-- ============================================================================

create or replace function public.interesados_pedido(p_pedido uuid)
returns integer
language sql
stable
security definer
set search_path = public
as $$
    select case
        when exists (
            select 1 from public.pedidos p
             where p.id = p_pedido
               and (p.buscador_id = auth.uid() or public.es_admin())
        )
        then (select count(*)::integer from public.contactos_desbloqueados c
               where c.pedido_id = p_pedido)
        else 0
    end;
$$;

comment on function public.interesados_pedido(uuid) is
    'CU-25. Cuántos Profesionales desbloquearon el contacto del pedido. Solo para el dueño o el admin; a cualquier otro le contesta 0.';


revoke execute on function public.contacto_pedido(uuid)      from public, anon;
revoke execute on function public.desbloquear_contacto(uuid) from public, anon;
revoke execute on function public.interesados_pedido(uuid)   from public, anon;
grant  execute on function public.contacto_pedido(uuid)      to authenticated;
grant  execute on function public.desbloquear_contacto(uuid) to authenticated;
grant  execute on function public.interesados_pedido(uuid)   to authenticated;


-- ============================================================================
-- 4. Guion de aceptación
-- ============================================================================
--
-- supabase/scripts/verificar_0023.sql: sin saldo da `saldo_insuficiente` y no
-- escribe nada; con saldo cobra 1 y revela el teléfono; la segunda vez no
-- cobra; un Profesional sin aprobar da `sin_verificar`; un pedido cerrado da
-- `pedido_no_disponible`; `contacto_pedido` enmascara antes y revela después;
-- `interesados_pedido` da 1 al dueño y 0 a un tercero.
-- ============================================================================
