-- ============================================================================
-- Laburito — Migración 0030
-- Sprint 5 · CU-28 Calificar Profesional (vía link de un solo uso)
-- ============================================================================
--
-- Cuatro funciones:
--
--   * `mis_contactos()`: los contactos que desbloqueó el Profesional (CU-25),
--     con el pedido, el Buscador y si ya lo calificaron. Es desde donde se pide
--     la calificación: el trabajo termina, el Buscador cierra el pedido, y el
--     detalle del pedido deja de mostrarse; el contacto pagado no.
--
--   * `generar_enlace_calificacion(p_pedido)`: devuelve un token nuevo para el
--     contacto de ese pedido y anula el anterior sin usar. Del token se guarda
--     solo el SHA-256: esta es la única vez que viaja en claro.
--
--   * `enlace_calificacion_info(p_token)`: lo que muestra la Figura 3.7 antes
--     de calificar —nombre e inicial del Profesional— y si el enlace sigue
--     disponible. Para `anon`: el Buscador no tiene sesión.
--
--   * `registrar_calificacion(p_token, p_puntaje, p_comentario)`: guarda la
--     reseña, marca el enlace como usado y recalcula el promedio, todo en una
--     transacción. Para `anon`.
--
-- La protección contra reseñas falsas que pide la ERS es la cadena entera: un
-- enlace solo nace de un contacto pagado con un token, se usa una vez, y un
-- contacto se califica una sola vez (`calificaciones_una_por_contacto_uq`).
-- ============================================================================


-- ============================================================================
-- 1. Hash del token
-- ============================================================================

create or replace function public.hash_token(p_token text)
returns text
language sql
immutable
set search_path = public
as $$
    select encode(extensions.digest(coalesce(p_token, ''), 'sha256'), 'hex');
$$;

comment on function public.hash_token(text) is
    'CU-28 / CU-18. SHA-256 en hexadecimal: lo que se guarda de un token de un solo uso.';


-- ============================================================================
-- 2. mis_contactos
-- ============================================================================

create or replace function public.mis_contactos()
returns table (
    pedido_id       uuid,
    titulo          text,
    estado_pedido   public.pedido_estado,
    nombre_corto    text,
    telefono        text,
    desbloqueado_at timestamptz,
    calificado      boolean,
    puntaje         smallint
)
language sql
stable
security definer
set search_path = public
as $$
    select
        p.id,
        p.titulo,
        p.estado,
        trim(b.nombre || ' ' || coalesce(left(b.apellido, 1) || '.', '')),
        b.telefono,
        c.created_at,
        cal.id is not null,
        cal.puntaje
      from public.contactos_desbloqueados c
      join public.pedidos p  on p.id = c.pedido_id
      join public.perfiles b on b.id = p.buscador_id
      left join public.calificaciones cal
             on cal.profesional_id = c.profesional_id and cal.pedido_id = c.pedido_id
     where c.profesional_id = auth.uid()
     order by c.created_at desc;
$$;

comment on function public.mis_contactos() is
    'CU-28. Contactos desbloqueados por el Profesional que llama, con el pedido y si ya lo calificaron.';


-- ============================================================================
-- 3. generar_enlace_calificacion
-- ============================================================================
--
-- Reglas, en orden:
--   1. Quien llama es un Profesional con la cuenta activa.
--   2. Desbloqueó el contacto de ese pedido (CU-25).
--   3. Ese contacto no lo calificaron todavía: `ya_calificado`.
--
-- Bloquea la fila del contacto para que dos toques seguidos no dejen dos
-- enlaces vivos (el índice parcial lo impediría igual, con un error feo).
-- ============================================================================

create or replace function public.generar_enlace_calificacion(p_pedido uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid   uuid := auth.uid();
    v_token text;
begin
    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa puede pedir una calificación.'
              using hint = 'sin_permiso';
    end if;

    perform 1 from public.contactos_desbloqueados
     where profesional_id = v_uid and pedido_id = p_pedido
       for update;

    if not found then
        raise exception 'Para pedir una calificación primero tenés que haber desbloqueado el contacto de ese pedido.'
              using hint = 'sin_contacto';
    end if;

    if exists (select 1 from public.calificaciones
                where profesional_id = v_uid and pedido_id = p_pedido) then
        raise exception 'Este cliente ya te calificó por este trabajo.'
              using hint = 'ya_calificado';
    end if;

    update public.enlaces_calificacion
       set anulado_at = now()
     where profesional_id = v_uid and pedido_id = p_pedido
       and usado_at is null and anulado_at is null;

    -- 16 bytes: 128 bits de azar, 32 caracteres en la URL.
    v_token := encode(extensions.gen_random_bytes(16), 'hex');

    insert into public.enlaces_calificacion (profesional_id, pedido_id, token_hash)
    values (v_uid, p_pedido, public.hash_token(v_token));

    return v_token;
end;
$$;

comment on function public.generar_enlace_calificacion(uuid) is
    'CU-28. Token de un solo uso para calificar el contacto de un pedido. Anula el anterior sin usar; guarda solo el hash.';


-- ============================================================================
-- 4. enlace_calificacion_info
-- ============================================================================
--
-- `estado`: `disponible`, `usado` (flujo alterno 1.1 del CU-28) o `invalido`
-- (no existe, fue reemplazado por uno nuevo, o el Profesional ya no está
-- activo). No dice nada del Buscador ni del pedido: quien tenga el enlace ve
-- solo a quién está calificando.
-- ============================================================================

create or replace function public.enlace_calificacion_info(p_token text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_enlace public.enlaces_calificacion;
    v_perfil public.perfiles;
begin
    select * into v_enlace from public.enlaces_calificacion
     where token_hash = public.hash_token(p_token);

    if v_enlace.id is null or v_enlace.anulado_at is not null then
        return jsonb_build_object('estado', 'invalido');
    end if;

    select * into v_perfil from public.perfiles where id = v_enlace.profesional_id;

    if v_perfil.estado <> 'activo' or v_perfil.deleted_at is not null then
        return jsonb_build_object('estado', 'invalido');
    end if;

    return jsonb_build_object(
        'estado',     case when v_enlace.usado_at is null then 'disponible' else 'usado' end,
        'nombre',     v_perfil.nombre,
        'apellido',   v_perfil.apellido,
        'avatar_url', v_perfil.avatar_url
    );
end;
$$;

comment on function public.enlace_calificacion_info(text) is
    'CU-28. Estado del enlace de calificación y a quién califica. Para anon.';


-- ============================================================================
-- 5. registrar_calificacion
-- ============================================================================
--
-- Valida el puntaje en el servidor aunque la Web ya lo valide (paso 4 del
-- CU-28): la función la puede llamar cualquiera que tenga el enlace.
--
-- El promedio se recalcula sobre las reseñas no ocultas en vez de sumar a
-- mano: así coincide siempre con lo que se muestra, también después de una
-- moderación (CU-46).
-- ============================================================================

create or replace function public.registrar_calificacion(
    p_token      text,
    p_puntaje    integer,
    p_comentario text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_enlace     public.enlaces_calificacion;
    v_autor      text;
    v_comentario text := nullif(trim(coalesce(p_comentario, '')), '');
    v_nombre     text;
begin
    select * into v_enlace from public.enlaces_calificacion
     where token_hash = public.hash_token(p_token)
       for update;

    if v_enlace.id is null or v_enlace.anulado_at is not null then
        raise exception 'Este enlace de calificación no es válido. Pedile al profesional que te mande uno nuevo.'
              using hint = 'enlace_invalido';
    end if;

    if v_enlace.usado_at is not null then
        raise exception 'Este enlace ya se usó para calificar. Cada enlace sirve una sola vez.'
              using hint = 'enlace_usado';
    end if;

    if not exists (select 1 from public.perfiles
                    where id = v_enlace.profesional_id
                      and estado = 'activo' and deleted_at is null) then
        raise exception 'Este enlace de calificación no es válido. Pedile al profesional que te mande uno nuevo.'
              using hint = 'enlace_invalido';
    end if;

    if p_puntaje is null or p_puntaje not between 1 and 5 then
        raise exception 'Elegí de 1 a 5 estrellas.'
              using hint = 'puntaje_invalido';
    end if;

    if length(v_comentario) > 500 then
        raise exception 'El comentario puede tener hasta 500 caracteres.'
              using hint = 'comentario_largo';
    end if;

    select trim(b.nombre || ' ' || coalesce(left(b.apellido, 1) || '.', ''))
      into v_autor
      from public.pedidos p
      join public.perfiles b on b.id = p.buscador_id
     where p.id = v_enlace.pedido_id;

    insert into public.calificaciones
        (profesional_id, pedido_id, enlace_id, puntaje, comentario, autor_nombre)
    values
        (v_enlace.profesional_id, v_enlace.pedido_id, v_enlace.id,
         p_puntaje, v_comentario, coalesce(nullif(v_autor, ''), 'Buscador'));

    update public.enlaces_calificacion
       set usado_at = now()
     where id = v_enlace.id;

    update public.profesionales pr
       set calificacion_promedio = r.promedio,
           total_calificaciones  = r.total
      from (select round(avg(puntaje)::numeric, 2) as promedio, count(*)::integer as total
              from public.calificaciones
             where profesional_id = v_enlace.profesional_id and not oculta) r
     where pr.perfil_id = v_enlace.profesional_id;

    select nombre into v_nombre from public.perfiles where id = v_enlace.profesional_id;

    return jsonb_build_object('nombre', v_nombre);
end;
$$;

comment on function public.registrar_calificacion(text, integer, text) is
    'CU-28. Guarda la calificación de un enlace de un solo uso y recalcula el promedio del Profesional. Para anon.';


revoke execute on function public.hash_token(text)                          from public, anon, authenticated;
revoke execute on function public.mis_contactos()                           from public, anon;
revoke execute on function public.generar_enlace_calificacion(uuid)         from public, anon;
revoke execute on function public.enlace_calificacion_info(text)            from public;
revoke execute on function public.registrar_calificacion(text, integer, text) from public;
grant  execute on function public.mis_contactos()                           to authenticated;
grant  execute on function public.generar_enlace_calificacion(uuid)         to authenticated;
grant  execute on function public.enlace_calificacion_info(text)            to anon, authenticated;
grant  execute on function public.registrar_calificacion(text, integer, text) to anon, authenticated;


-- ============================================================================
-- 6. Guion de aceptación
-- ============================================================================
--
-- supabase/scripts/verificar_0030.sql: sin contacto da `sin_contacto`; el
-- token se guarda hasheado; un segundo enlace anula el primero; `anon`
-- consulta y califica; el enlace usado da `enlace_usado`; el anulado,
-- `enlace_invalido`; el promedio y el total se recalculan; un contacto
-- calificado da `ya_calificado`; puntaje 0 da `puntaje_invalido`.
-- ============================================================================
