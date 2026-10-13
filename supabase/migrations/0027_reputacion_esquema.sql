-- ============================================================================
-- Laburito — Migración 0027
-- Sprint 5 · T-11: esquema de reputación, enlaces y actividad, con sus RLS
-- CU-26, CU-27, CU-28, CU-48, CU-45, CU-41
-- ============================================================================
--
-- Es al Sprint 5 lo que la 0021 fue a la billetera: todas las tablas del sprint
-- en un archivo, con las políticas pegadas a cada `create table`. Las funciones
-- de cada caso de uso van en su propia migración.
--
-- Regla común: **ningún cliente escribe estas tablas por la API**, salvo marcar
-- y borrar sus propias notificaciones. El slug, las visitas, los enlaces, las
-- calificaciones y las denuncias los escriben funciones SECURITY DEFINER que
-- validan antes. La única excepción a «sin políticas de escritura» es
-- `notificaciones`, con su propio guard de columnas.
--
-- El slug no va como columna de `profesionales` a propósito: el guard de la
-- 0020 enumera las columnas que el dueño no puede tocar, y una columna nueva
-- quedaría escribible por PATCH. En una tabla sin políticas de escritura no
-- hay nada que enumerar.
-- ============================================================================


-- ============================================================================
-- 1. Perfil público — CU-26, CU-27
-- ============================================================================
--
-- Un slug por Profesional, legible como el de la Figura 3.6
-- (`/p/marcelo-gomez`) más un sufijo aleatorio que lo hace no enumerable. Lo
-- crea `obtener_enlace_perfil()` la primera vez que el Profesional comparte, y
-- después no cambia: un enlace que ya circula por WhatsApp sigue andando.
-- ============================================================================

create table if not exists public.perfiles_publicos (
    profesional_id  uuid primary key
                    references public.profesionales (perfil_id) on delete cascade,
    slug            text not null unique
                    check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$' and length(slug) between 3 and 80),
    created_at      timestamptz not null default now()
);

comment on table public.perfiles_publicos is
    'CU-26 / CU-27. Slug del enlace público del Profesional. Lo escribe solo obtener_enlace_perfil().';

alter table public.perfiles_publicos enable row level security;

drop policy if exists "perfiles publicos: lectura propia" on public.perfiles_publicos;
create policy "perfiles publicos: lectura propia"
    on public.perfiles_publicos for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 2. Visitas al perfil — CU-27 las registra, CU-45 las cuenta
-- ============================================================================
--
-- Una fila por apertura del enlace público. No guarda nada de quien mira: el
-- visitante no tiene cuenta y la Ley 25.326 no pide más de lo que se usa.
-- ============================================================================

create table if not exists public.perfil_visitas (
    id              bigint generated always as identity primary key,
    profesional_id  uuid not null
                    references public.profesionales (perfil_id) on delete cascade,
    created_at      timestamptz not null default now()
);

comment on table public.perfil_visitas is
    'CU-27 / CU-45. Una fila por apertura del perfil público. Sin datos del visitante.';

create index if not exists perfil_visitas_profesional_fecha_idx
    on public.perfil_visitas (profesional_id, created_at);

alter table public.perfil_visitas enable row level security;

drop policy if exists "visitas: lectura propia" on public.perfil_visitas;
create policy "visitas: lectura propia"
    on public.perfil_visitas for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 3. Enlaces de calificación — CU-28
-- ============================================================================
--
-- La protección contra reseñas falsas que pide la ERS: un enlace nace de un
-- contacto desbloqueado (CU-25), es decir de un pedido real cuyo contacto el
-- Profesional pagó con un token. La FK compuesta contra
-- `contactos_desbloqueados` lo garantiza en la base, no en la app.
--
-- Se guarda el SHA-256 del token, nunca el token: quien lea la tabla no puede
-- armar el enlace. A lo sumo un enlace vivo por contacto (índice parcial):
-- generar otro anula el anterior sin usar.
-- ============================================================================

create table if not exists public.enlaces_calificacion (
    id              uuid primary key default gen_random_uuid(),
    profesional_id  uuid not null,
    pedido_id       uuid not null,
    token_hash      text not null unique check (token_hash ~ '^[0-9a-f]{64}$'),
    created_at      timestamptz not null default now(),
    usado_at        timestamptz,
    anulado_at      timestamptz,

    constraint enlaces_calificacion_contacto_fk
        foreign key (profesional_id, pedido_id)
        references public.contactos_desbloqueados (profesional_id, pedido_id)
        on delete restrict,

    constraint enlaces_calificacion_un_final_ck
        check (usado_at is null or anulado_at is null)
);

comment on table public.enlaces_calificacion is
    'CU-28. Enlaces de un solo uso para calificar, atados a un contacto desbloqueado. Guarda el hash del token, no el token.';

create unique index if not exists enlaces_calificacion_vivo_uq
    on public.enlaces_calificacion (profesional_id, pedido_id)
    where usado_at is null and anulado_at is null;

alter table public.enlaces_calificacion enable row level security;

drop policy if exists "enlaces calificacion: lectura propia" on public.enlaces_calificacion;
create policy "enlaces calificacion: lectura propia"
    on public.enlaces_calificacion for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 4. Calificaciones — CU-28 (moderación: CU-46, Sprint 6)
-- ============================================================================
--
-- Una por contacto: el mismo pedido no califica dos veces al mismo
-- Profesional. `autor_nombre` copia el nombre corto del Buscador del pedido
-- («Laura G.», Figura 3.6) al calificar; si después se da de baja, la reseña
-- queda con el nombre que tenía.
--
-- `oculta` es para la moderación del CU-46: una reseña oculta no cuenta en el
-- promedio ni se muestra, pero no se borra.
-- ============================================================================

create table if not exists public.calificaciones (
    id              uuid primary key default gen_random_uuid(),
    profesional_id  uuid not null
                    references public.profesionales (perfil_id) on delete cascade,
    pedido_id       uuid not null
                    references public.pedidos (id) on delete restrict,
    enlace_id       uuid not null unique
                    references public.enlaces_calificacion (id) on delete restrict,
    puntaje         smallint not null check (puntaje between 1 and 5),
    comentario      text check (length(comentario) <= 500),
    autor_nombre    text not null check (length(trim(autor_nombre)) between 1 and 80),
    oculta          boolean not null default false,
    created_at      timestamptz not null default now(),

    constraint calificaciones_una_por_contacto_uq unique (profesional_id, pedido_id)
);

comment on table public.calificaciones is
    'CU-28. Reseñas de los Buscadores. Una por contacto desbloqueado; las escribe solo registrar_calificacion().';

create index if not exists calificaciones_profesional_fecha_idx
    on public.calificaciones (profesional_id, created_at desc);

alter table public.calificaciones enable row level security;

drop policy if exists "calificaciones: lectura propia" on public.calificaciones;
create policy "calificaciones: lectura propia"
    on public.calificaciones for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());

-- Las reseñas son públicas, pero se leen por el perfil público (CU-27), que
-- filtra las ocultas. La tabla no se abre a `anon`.


-- ============================================================================
-- 5. Notificaciones — CU-48
-- ============================================================================
--
-- El centro de actividad de los dos actores. Las escriben disparadores
-- (migración de CU-48): nuevo interesado, calificación recibida, verificación
-- resuelta, pago acreditado y denuncia nueva. `ruta` es la pantalla a la que
-- lleva tocar el aviso.
--
-- El dueño lee, marca leídas y borra («Limpiar todo»). Para que marcar leída no
-- abra la puerta a reescribir el aviso, un guard deja cambiar solo `leida_at`.
-- ============================================================================

do $$
begin
    if not exists (select 1 from pg_type where typname = 'notificacion_tipo') then
        create type public.notificacion_tipo as enum (
            'nuevo_interesado',
            'calificacion_recibida',
            'verificacion_aprobada',
            'verificacion_rechazada',
            'pago_acreditado',
            'denuncia_recibida'
        );
    end if;
end;
$$;

create table if not exists public.notificaciones (
    id               uuid primary key default gen_random_uuid(),
    destinatario_id  uuid not null
                     references public.perfiles (id) on delete cascade,
    tipo             public.notificacion_tipo not null,
    titulo           text not null check (length(trim(titulo)) between 1 and 120),
    cuerpo           text check (length(cuerpo) <= 500),
    ruta             text check (ruta like '/%'),
    leida_at         timestamptz,
    created_at       timestamptz not null default now()
);

comment on table public.notificaciones is
    'CU-48. Avisos de actividad. Los escriben disparadores; el dueño los lee, los marca leídos y los borra.';

create index if not exists notificaciones_destinatario_fecha_idx
    on public.notificaciones (destinatario_id, created_at desc);

create index if not exists notificaciones_sin_leer_idx
    on public.notificaciones (destinatario_id)
    where leida_at is null;

alter table public.notificaciones enable row level security;

drop policy if exists "notificaciones: lectura propia" on public.notificaciones;
create policy "notificaciones: lectura propia"
    on public.notificaciones for select
    to authenticated
    using (destinatario_id = auth.uid());

drop policy if exists "notificaciones: marcar propias" on public.notificaciones;
create policy "notificaciones: marcar propias"
    on public.notificaciones for update
    to authenticated
    using (destinatario_id = auth.uid())
    with check (destinatario_id = auth.uid());

drop policy if exists "notificaciones: borrar propias" on public.notificaciones;
create policy "notificaciones: borrar propias"
    on public.notificaciones for delete
    to authenticated
    using (destinatario_id = auth.uid());

create or replace function public.notificaciones_guard_columnas()
returns trigger
language plpgsql
as $$
begin
    if current_user <> 'authenticated' then
        return new;
    end if;

    if new.id              is distinct from old.id
       or new.destinatario_id is distinct from old.destinatario_id
       or new.tipo            is distinct from old.tipo
       or new.titulo          is distinct from old.titulo
       or new.cuerpo          is distinct from old.cuerpo
       or new.ruta            is distinct from old.ruta
       or new.created_at      is distinct from old.created_at then
        raise exception 'CAMPO_NO_MODIFICABLE_DIRECTAMENTE'
              using hint = 'campo_no_modificable';
    end if;

    return new;
end;
$$;

comment on function public.notificaciones_guard_columnas() is
    'CU-48. Por PostgREST, de una notificación solo se puede cambiar leida_at.';

drop trigger if exists notificaciones_guard_columnas on public.notificaciones;
create trigger notificaciones_guard_columnas
    before update on public.notificaciones
    for each row execute function public.notificaciones_guard_columnas();

-- Realtime: la campana actualiza su contador cuando llega un aviso.
do $$
begin
    if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
       and not exists (
           select 1 from pg_publication_tables
            where pubname = 'supabase_realtime'
              and schemaname = 'public' and tablename = 'notificaciones'
       ) then
        alter publication supabase_realtime add table public.notificaciones;
    end if;
end;
$$;


-- ============================================================================
-- 6. Denuncias — CU-41 (gestión: CU-39, Sprint 6)
-- ============================================================================
--
-- La escribe solo `reportar_usuario()`, que valida motivo, descripción y que no
-- sea una autodenuncia. Una denuncia abierta por par denunciante–denunciado
-- (índice parcial): repetir la misma no suma información, solo ruido para el
-- administrador.
-- ============================================================================

do $$
begin
    if not exists (select 1 from pg_type where typname = 'denuncia_motivo') then
        create type public.denuncia_motivo as enum (
            'comportamiento_inapropiado',
            'incumplimiento',
            'estafa',
            'perfil_falso',
            'otro'
        );
    end if;
    if not exists (select 1 from pg_type where typname = 'denuncia_estado') then
        create type public.denuncia_estado as enum (
            'pendiente',
            'en_revision',
            'resuelta',
            'desestimada'
        );
    end if;
end;
$$;

create table if not exists public.denuncias (
    id              uuid primary key default gen_random_uuid(),
    denunciante_id  uuid not null references public.perfiles (id) on delete restrict,
    denunciado_id   uuid not null references public.perfiles (id) on delete restrict,
    pedido_id       uuid references public.pedidos (id) on delete set null,
    motivo          public.denuncia_motivo not null,
    descripcion     text not null check (length(trim(descripcion)) between 10 and 1000),
    estado          public.denuncia_estado not null default 'pendiente',
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now(),

    constraint denuncias_no_a_uno_mismo_ck check (denunciante_id <> denunciado_id)
);

comment on table public.denuncias is
    'CU-41. Reportes de conducta. Los escribe solo reportar_usuario(); los resuelve el administrador (CU-39, Sprint 6).';

create unique index if not exists denuncias_abierta_por_par_uq
    on public.denuncias (denunciante_id, denunciado_id)
    where estado in ('pendiente', 'en_revision');

create index if not exists denuncias_estado_fecha_idx
    on public.denuncias (estado, created_at desc);

drop trigger if exists denuncias_set_updated_at on public.denuncias;
create trigger denuncias_set_updated_at
    before update on public.denuncias
    for each row execute function public.set_updated_at();

alter table public.denuncias enable row level security;

drop policy if exists "denuncias: lectura propia" on public.denuncias;
create policy "denuncias: lectura propia"
    on public.denuncias for select
    to authenticated
    using (denunciante_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 7. Guion de aceptación
-- ============================================================================
--
-- supabase/scripts/verificar_0027.sql: RLS activa en las seis tablas; sin
-- políticas de escritura salvo las dos de notificaciones; el enlace exige un
-- contacto desbloqueado; un solo enlace vivo por contacto; puntaje fuera de
-- 1..5 rechazado; una notificación solo deja cambiar leida_at; sin
-- autodenuncias.
-- ============================================================================
