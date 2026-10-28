-- ============================================================================
-- Laburito — Migración 0034
-- Sprint 6 · T-12: esquema de administración, con sus RLS
--            T-13: deuda de seguridad, columnas de `perfiles`
-- CU-34, CU-35, CU-36, CU-39, CU-42, CU-46, CU-47, CU-49
-- ============================================================================
--
-- Es al Sprint 6 lo que la 0027 fue al Sprint 5: todas las tablas del sprint
-- en un archivo, con las políticas pegadas a cada `create table`. Las
-- funciones de cada caso de uso van en su propia migración.
--
-- Regla común: **ningún cliente escribe estas tablas por la API**. Las
-- escriben funciones SECURITY DEFINER que empiezan preguntando `es_admin()` o
-- validando al dueño. Se leen por RLS: el admin todo, el usuario lo suyo.
-- ============================================================================


-- ============================================================================
-- 1. T-13 — Guard de columnas de `perfiles`
-- ============================================================================
--
-- La política «perfil propio: actualización» (0001) es de fila entera y la
-- tabla no tenía guard, a diferencia de `profesionales` (0020) y `pedidos`
-- (0008). Con un PATCH cualquiera podía escribirse `tipo = 'administrador'` o
-- levantarse una suspensión. Por PostgREST el dueño escribe solo sus datos de
-- contacto (CU-05); el admin tampoco cambia `tipo` ni `estado` por PATCH: lo
-- hace con las funciones del panel, que corren como dueñas y dejan registro.
-- ============================================================================

create or replace function public.perfiles_guard_columnas()
returns trigger
language plpgsql
as $$
begin
    if current_user <> 'authenticated' then
        return new;
    end if;

    if new.id            is distinct from old.id
       or new.tipo       is distinct from old.tipo
       or new.estado     is distinct from old.estado
       or new.email      is distinct from old.email
       or new.created_at is distinct from old.created_at
       or new.deleted_at is distinct from old.deleted_at then
        raise exception 'CAMPO_NO_MODIFICABLE_DIRECTAMENTE'
              using hint   = 'campo_no_modificable',
                    detail = format(
                        'Intento de cambiar columnas protegidas del perfil %s por la API.',
                        old.id
                    );
    end if;

    return new;
end;
$$;

comment on function public.perfiles_guard_columnas() is
    'T-13. Por PostgREST, de un perfil solo se escriben nombre, apellido, telefono y avatar_url. Tipo y estado, solo con las funciones del panel.';

drop trigger if exists perfiles_guard_columnas on public.perfiles;
create trigger perfiles_guard_columnas
    before update on public.perfiles
    for each row execute function public.perfiles_guard_columnas();


-- ============================================================================
-- 2. Accesos al panel — CU-34
-- ============================================================================
--
-- Requerimiento especial: «registro estricto de logs de acceso (dirección IP y
-- hora)». Una fila por intento, aceptado o denegado (flujo alterno 1.2).
-- ============================================================================

create table if not exists public.accesos_admin (
    id          bigint generated always as identity primary key,
    perfil_id   uuid references public.perfiles (id) on delete set null,
    email       text,
    resultado   text not null check (resultado in ('aceptado', 'denegado')),
    ip          text check (length(ip) <= 100),
    navegador   text check (length(navegador) <= 300),
    created_at  timestamptz not null default now()
);

comment on table public.accesos_admin is
    'CU-34. Intentos de ingreso al panel con IP y hora. Los escribe solo registrar_acceso_admin().';

create index if not exists accesos_admin_fecha_idx
    on public.accesos_admin (created_at desc);

alter table public.accesos_admin enable row level security;

drop policy if exists "accesos admin: lectura del admin" on public.accesos_admin;
create policy "accesos admin: lectura del admin"
    on public.accesos_admin for select
    to authenticated
    using (public.es_admin());


-- ============================================================================
-- 3. Sanciones — CU-36 (y CU-39, que las aplica desde una denuncia)
-- ============================================================================
--
-- Una sanción vigente por usuario (índice parcial). Temporal con `hasta`, o
-- permanente sin fecha. `apelable` decide si el CU-49 ofrece el botón.
-- Levantarla —por apelación o porque venció— completa `levantada_at`: la
-- historia no se borra.
-- ============================================================================

create table if not exists public.sanciones (
    id                uuid primary key default gen_random_uuid(),
    perfil_id         uuid not null references public.perfiles (id) on delete cascade,
    admin_id          uuid references public.perfiles (id) on delete set null,
    denuncia_id       uuid references public.denuncias (id) on delete set null,
    motivo            text not null check (length(trim(motivo)) between 10 and 500),
    permanente        boolean not null,
    hasta             timestamptz,
    apelable          boolean not null default true,
    levantada_at      timestamptz,
    levantada_motivo  text check (length(levantada_motivo) <= 500),
    created_at        timestamptz not null default now(),

    constraint sanciones_plazo_ck check (permanente = (hasta is null))
);

comment on table public.sanciones is
    'CU-36. Suspensiones de cuenta con su motivo, plazo y si admiten apelación. Las escribe suspender_cuenta().';

create unique index if not exists sanciones_vigente_por_perfil_uq
    on public.sanciones (perfil_id)
    where levantada_at is null;

create index if not exists sanciones_perfil_fecha_idx
    on public.sanciones (perfil_id, created_at desc);

alter table public.sanciones enable row level security;

drop policy if exists "sanciones: lectura propia" on public.sanciones;
create policy "sanciones: lectura propia"
    on public.sanciones for select
    to authenticated
    using (perfil_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 4. Apelaciones — CU-49
-- ============================================================================
--
-- `numero` es el número de trámite que el paso 6 le da al usuario. Una
-- apelación pendiente por sanción.
-- ============================================================================

create table if not exists public.apelaciones (
    id            uuid primary key default gen_random_uuid(),
    numero        bigint generated always as identity (start with 1001) unique,
    sancion_id    uuid not null references public.sanciones (id) on delete cascade,
    perfil_id     uuid not null references public.perfiles (id) on delete cascade,
    descargo      text not null check (length(trim(descargo)) between 20 and 1000),
    estado        text not null default 'pendiente'
                  check (estado in ('pendiente', 'aceptada', 'rechazada')),
    respuesta     text check (length(respuesta) <= 500),
    resuelta_por  uuid references public.perfiles (id) on delete set null,
    resuelta_at   timestamptz,
    created_at    timestamptz not null default now()
);

comment on table public.apelaciones is
    'CU-49. Descargos de usuarios suspendidos. Los escribe apelar_sancion(); los resuelve el admin.';

create unique index if not exists apelaciones_pendiente_por_sancion_uq
    on public.apelaciones (sancion_id)
    where estado = 'pendiente';

alter table public.apelaciones enable row level security;

drop policy if exists "apelaciones: lectura propia" on public.apelaciones;
create policy "apelaciones: lectura propia"
    on public.apelaciones for select
    to authenticated
    using (perfil_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 5. Parámetros globales — CU-47
-- ============================================================================
--
-- Cada parámetro trae su rango: un valor fuera de él lo rechaza el `check`
-- además de la función (flujo alterno 1.1). Las funciones de la base que hoy
-- tienen esos números escritos los leen de acá desde la 0042.
-- ============================================================================

create table if not exists public.parametros_sistema (
    clave        text primary key check (clave ~ '^[a-z_]+$'),
    nombre       text not null,
    descripcion  text not null,
    unidad       text not null,
    valor        integer not null,
    minimo       integer not null,
    maximo       integer not null,
    updated_by   uuid references public.perfiles (id) on delete set null,
    updated_at   timestamptz not null default now(),

    constraint parametros_rango_ck check (minimo <= maximo and valor between minimo and maximo)
);

comment on table public.parametros_sistema is
    'CU-47. Constantes de negocio editables desde el panel. Las escribe solo actualizar_parametro().';

insert into public.parametros_sistema (clave, nombre, descripcion, unidad, valor, minimo, maximo) values
    ('radio_maximo_km', 'Radio máximo de cobertura',
     'Distancia máxima que un Profesional puede fijar como zona de cobertura (CU-07).',
     'km', 100, 1, 100),
    ('renovaciones_maximas', 'Renovaciones por pedido',
     'Veces que un Buscador puede renovar un mismo pedido antes de tener que publicar uno nuevo (CU-51).',
     'renovaciones', 3, 0, 10),
    ('dias_maximos_renovacion', 'Días por renovación',
     'Máximo de días de vigencia que suma cada renovación de un pedido (CU-51).',
     'días', 30, 1, 60)
on conflict (clave) do nothing;

alter table public.parametros_sistema enable row level security;

drop policy if exists "parametros: lectura de usuarios" on public.parametros_sistema;
create policy "parametros: lectura de usuarios"
    on public.parametros_sistema for select
    to authenticated
    using (true);

create or replace function public.parametro(p_clave text)
returns integer
language sql
stable
security definer
set search_path = public
as $$
    select valor from public.parametros_sistema where clave = p_clave;
$$;

comment on function public.parametro(text) is
    'CU-47. Valor vigente de un parámetro global. Lo leen las funciones de negocio.';

revoke execute on function public.parametro(text) from public, anon;
grant  execute on function public.parametro(text) to authenticated;


-- ============================================================================
-- 6. Preguntas frecuentes — CU-42 (contenido en la 0044)
-- ============================================================================
--
-- Lectura pública: la ayuda se abre sin cuenta, desde el login o la Web.
-- ============================================================================

create table if not exists public.preguntas_frecuentes (
    id          uuid primary key default gen_random_uuid(),
    categoria   text not null check (length(trim(categoria)) between 2 and 60),
    pregunta    text not null check (length(trim(pregunta)) between 5 and 200),
    respuesta   text not null check (length(trim(respuesta)) between 5 and 2000),
    orden       integer not null default 0,
    activa      boolean not null default true,
    created_at  timestamptz not null default now()
);

comment on table public.preguntas_frecuentes is
    'CU-42. Base de conocimientos de la ayuda. Lectura pública de las activas.';

alter table public.preguntas_frecuentes enable row level security;

drop policy if exists "preguntas: lectura pública" on public.preguntas_frecuentes;
create policy "preguntas: lectura pública"
    on public.preguntas_frecuentes for select
    to anon, authenticated
    using (activa);


-- ============================================================================
-- 7. Columnas de moderación — CU-39 y CU-46
-- ============================================================================
--
-- Las dos tablas ya existen (0027) y no tienen políticas de escritura, así que
-- columnas nuevas no quedan escribibles por PATCH.
-- ============================================================================

alter table public.denuncias
    add column if not exists resolucion   text check (length(resolucion) <= 1000),
    add column if not exists resuelta_por uuid references public.perfiles (id) on delete set null,
    add column if not exists resuelta_at  timestamptz;

alter table public.calificaciones
    add column if not exists reporte_motivo      text check (length(reporte_motivo) <= 500),
    add column if not exists reportada_at        timestamptz,
    add column if not exists revision_automatica boolean not null default false,
    add column if not exists moderacion          text check (moderacion in ('eliminada', 'mantenida')),
    add column if not exists moderada_por        uuid references public.perfiles (id) on delete set null,
    add column if not exists moderada_at         timestamptz;

create index if not exists calificaciones_a_moderar_idx
    on public.calificaciones (created_at desc)
    where moderacion is null and (reportada_at is not null or revision_automatica);


-- ============================================================================
-- 8. Tipos de aviso nuevos — CU-48
-- ============================================================================
--
-- `add value` no se puede usar en la misma transacción que lo agrega: los
-- disparadores que los escriben están en las migraciones siguientes.
-- ============================================================================

alter type public.notificacion_tipo add value if not exists 'cuenta_suspendida';
alter type public.notificacion_tipo add value if not exists 'cuenta_reactivada';
alter type public.notificacion_tipo add value if not exists 'denuncia_resuelta';
alter type public.notificacion_tipo add value if not exists 'resena_reportada';
alter type public.notificacion_tipo add value if not exists 'resena_eliminada';
alter type public.notificacion_tipo add value if not exists 'apelacion_recibida';
alter type public.notificacion_tipo add value if not exists 'apelacion_resuelta';


-- ============================================================================
-- 9. Storage — CU-35
-- ============================================================================
--
-- El admin ya lee el bucket `documentos` (0001). Para destruir las fotos del
-- DNI al resolver (requerimiento especial del CU-35) necesita borrarlas.
-- ============================================================================

drop policy if exists "documentos: borrado del admin" on storage.objects;
create policy "documentos: borrado del admin"
    on storage.objects for delete
    using (bucket_id = 'documentos' and public.es_admin());


-- ============================================================================
-- 10. Guion de aceptación
-- ============================================================================
--
-- supabase/scripts/verificar_0034.sql: RLS activa en las cinco tablas nuevas;
-- sin políticas de escritura; un usuario no puede escribirse tipo ni estado;
-- sí puede cambiar su teléfono; los rangos de los parámetros se respetan.
-- ============================================================================
