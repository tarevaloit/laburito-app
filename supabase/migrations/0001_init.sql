-- ============================================================================
-- Laburito — Migración inicial (T-02, Sprint 1)
-- Supabase / PostgreSQL
-- ============================================================================

create extension if not exists "uuid-ossp";
create extension if not exists postgis with schema extensions;

-- ============================================================================
-- 1. TIPOS
-- ============================================================================

create type public.tipo_perfil as enum ('buscador', 'profesional', 'administrador');

create type public.estado_cuenta as enum ('pendiente_verificacion', 'activo', 'suspendido', 'baja');

create type public.estado_verificacion as enum ('sin_documentacion', 'en_revision', 'aprobado', 'rechazado');

create type public.tipo_documento as enum ('dni_frente', 'dni_dorso', 'selfie', 'matricula', 'constancia_afip');

-- ============================================================================
-- 2. TABLAS
-- ============================================================================

-- 2.1 Perfiles (1:1 con auth.users)
create table public.perfiles (
    id              uuid primary key references auth.users (id) on delete cascade,
    tipo            public.tipo_perfil    not null,
    nombre          text                  not null check (length(trim(nombre)) between 2 and 60),
    apellido        text                  not null check (length(trim(apellido)) between 2 and 60),
    email           text                  not null,
    telefono        text,
    avatar_url      text,
    estado          public.estado_cuenta  not null default 'pendiente_verificacion',
    created_at      timestamptz           not null default now(),
    updated_at      timestamptz           not null default now(),
    deleted_at      timestamptz
);

create index perfiles_tipo_idx   on public.perfiles (tipo);
create index perfiles_estado_idx on public.perfiles (estado);

comment on table public.perfiles is 'Datos comunes a los tres actores. CU-01, CU-02, CU-05, CU-11.';

-- 2.2 Profesionales (extensión de perfiles)
create table public.profesionales (
    perfil_id            uuid primary key references public.perfiles (id) on delete cascade,
    dni                  text unique,
    descripcion          text check (length(descripcion) <= 500),
    estado_verificacion  public.estado_verificacion not null default 'sin_documentacion',
    saldo_tokens         integer not null default 0 check (saldo_tokens >= 0),
    disponible           boolean not null default false,
    radio_cobertura_km   integer not null default 10 check (radio_cobertura_km between 1 and 100),
    ubicacion            extensions.geography(Point, 4326),
    calificacion_promedio numeric(3,2) check (calificacion_promedio between 0 and 5),
    total_calificaciones integer not null default 0,
    created_at           timestamptz not null default now(),
    updated_at           timestamptz not null default now()
);

create index profesionales_ubicacion_idx  on public.profesionales using gist (ubicacion);
create index profesionales_disponible_idx on public.profesionales (disponible) where disponible = true;

comment on table public.profesionales is 'Atributos propios del Profesional. La ubicación se usa desde el Sprint 3 (CU-21).';

-- 2.3 Categorías de oficio
create table public.categorias_oficio (
    id          uuid primary key default uuid_generate_v4(),
    nombre      text not null unique,
    slug        text not null unique,
    icono       text,
    activa      boolean not null default true,
    orden       integer not null default 0,
    created_at  timestamptz not null default now()
);

comment on table public.categorias_oficio is 'Catálogo. Carga inicial por seed en T-02; su ABM es el CU-37 (Sprint 6).';

-- 2.4 Relación Profesional ↔ Categorías
create table public.profesional_categorias (
    profesional_id  uuid not null references public.profesionales (perfil_id) on delete cascade,
    categoria_id    uuid not null references public.categorias_oficio (id)   on delete restrict,
    created_at      timestamptz not null default now(),
    primary key (profesional_id, categoria_id)
);

create index profesional_categorias_categoria_idx on public.profesional_categorias (categoria_id);

-- 2.5 Documentos de verificación (CU-09 / CU-35)
create table public.documentos_verificacion (
    id              uuid primary key default uuid_generate_v4(),
    profesional_id  uuid not null references public.profesionales (perfil_id) on delete cascade,
    tipo            public.tipo_documento not null,
    storage_path    text not null,
    estado          public.estado_verificacion not null default 'en_revision',
    observacion     text,
    revisado_por    uuid references public.perfiles (id),
    revisado_at     timestamptz,
    created_at      timestamptz not null default now(),
    unique (profesional_id, tipo)
);

create index documentos_estado_idx on public.documentos_verificacion (estado);

-- 2.6 Auditoría de bajas (CU-11)
create table public.bajas_cuenta (
    id          uuid primary key default uuid_generate_v4(),
    perfil_id   uuid not null references public.perfiles (id) on delete cascade,
    motivo      text,
    created_at  timestamptz not null default now()
);

-- ============================================================================
-- 3. FUNCIONES Y TRIGGERS
-- ============================================================================

-- 3.1 updated_at automático
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at := now();
    return new;
end;
$$;

create trigger perfiles_set_updated_at
    before update on public.perfiles
    for each row execute function public.set_updated_at();

create trigger profesionales_set_updated_at
    before update on public.profesionales
    for each row execute function public.set_updated_at();

-- 3.2 Alta automática del perfil al registrarse (CU-01 / CU-02)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_tipo public.tipo_perfil;
begin
    v_tipo := coalesce(
        (new.raw_user_meta_data ->> 'tipo')::public.tipo_perfil,
        'buscador'
    );

    insert into public.perfiles (id, tipo, nombre, apellido, email, telefono)
    values (
        new.id,
        v_tipo,
        coalesce(new.raw_user_meta_data ->> 'nombre',   'Sin nombre'),
        coalesce(new.raw_user_meta_data ->> 'apellido', 'Sin apellido'),
        new.email,
        new.raw_user_meta_data ->> 'telefono'
    );

    if v_tipo = 'profesional' then
        insert into public.profesionales (perfil_id, dni)
        values (new.id, new.raw_user_meta_data ->> 'dni');
    end if;

    return new;
end;
$$;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- 3.3 Activar la cuenta cuando el email queda confirmado (CU-08)
create or replace function public.handle_email_confirmed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if new.email_confirmed_at is not null and old.email_confirmed_at is null then
        update public.perfiles
           set estado = 'activo'
         where id = new.id
           and estado = 'pendiente_verificacion';
    end if;
    return new;
end;
$$;

create trigger on_auth_email_confirmed
    after update on auth.users
    for each row execute function public.handle_email_confirmed();

-- 3.4 Helper de rol admin (security definer para evitar recursión en RLS)
create or replace function public.es_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
    select exists (
        select 1 from public.perfiles
         where id = auth.uid()
           and tipo = 'administrador'
           and estado = 'activo'
    );
$$;

-- ============================================================================
-- 4. ROW LEVEL SECURITY
-- ============================================================================

alter table public.perfiles                enable row level security;
alter table public.profesionales           enable row level security;
alter table public.categorias_oficio       enable row level security;
alter table public.profesional_categorias  enable row level security;
alter table public.documentos_verificacion enable row level security;
alter table public.bajas_cuenta            enable row level security;

-- 4.1 perfiles
create policy "perfil propio: lectura"
    on public.perfiles for select
    using (auth.uid() = id);

create policy "perfil propio: actualización"
    on public.perfiles for update
    using (auth.uid() = id and deleted_at is null)
    with check (auth.uid() = id);

create policy "admin: lectura total de perfiles"
    on public.perfiles for select
    using (public.es_admin());

create policy "admin: actualización total de perfiles"
    on public.perfiles for update
    using (public.es_admin());

-- 4.2 profesionales
create policy "profesional propio: lectura"
    on public.profesionales for select
    using (auth.uid() = perfil_id);

create policy "profesional propio: actualización"
    on public.profesionales for update
    using (auth.uid() = perfil_id)
    with check (auth.uid() = perfil_id);

-- Perfil público de profesionales aprobados y activos (necesario desde el Sprint 3)
create policy "público: profesionales aprobados"
    on public.profesionales for select
    using (
        estado_verificacion = 'aprobado'
        and exists (
            select 1 from public.perfiles p
             where p.id = perfil_id
               and p.estado = 'activo'
               and p.deleted_at is null
        )
    );

create policy "admin: gestión de profesionales"
    on public.profesionales for all
    using (public.es_admin());

-- 4.3 categorías de oficio — lectura pública, escritura solo admin
create policy "público: lectura de categorías"
    on public.categorias_oficio for select
    using (activa = true);

create policy "admin: gestión de categorías"
    on public.categorias_oficio for all
    using (public.es_admin());

-- 4.4 profesional_categorias
create policy "profesional propio: gestión de sus categorías"
    on public.profesional_categorias for all
    using (auth.uid() = profesional_id)
    with check (auth.uid() = profesional_id);

create policy "público: lectura de categorías del profesional"
    on public.profesional_categorias for select
    using (true);

-- 4.5 documentos de verificación
create policy "profesional propio: sus documentos"
    on public.documentos_verificacion for select
    using (auth.uid() = profesional_id);

create policy "profesional propio: cargar documentos"
    on public.documentos_verificacion for insert
    with check (auth.uid() = profesional_id);

create policy "admin: revisión de documentos"
    on public.documentos_verificacion for all
    using (public.es_admin());

-- 4.6 bajas
create policy "usuario propio: registrar su baja"
    on public.bajas_cuenta for insert
    with check (auth.uid() = perfil_id);

create policy "admin: lectura de bajas"
    on public.bajas_cuenta for select
    using (public.es_admin());

-- ============================================================================
-- 5. STORAGE
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
    ('avatares',    'avatares',    true,  2097152, array['image/jpeg','image/png','image/webp']),
    ('documentos',  'documentos',  false, 5242880, array['image/jpeg','image/png','application/pdf']),
    ('portafolios', 'portafolios', true,  5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

-- Avatares: lectura pública, escritura sobre la carpeta propia
create policy "avatares: lectura pública"
    on storage.objects for select
    using (bucket_id = 'avatares');

create policy "avatares: subida propia"
    on storage.objects for insert
    with check (
        bucket_id = 'avatares'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

create policy "avatares: actualización propia"
    on storage.objects for update
    using (
        bucket_id = 'avatares'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

-- Documentos: privados, solo el dueño y el administrador
create policy "documentos: lectura propia"
    on storage.objects for select
    using (
        bucket_id = 'documentos'
        and ((storage.foldername(name))[1] = auth.uid()::text or public.es_admin())
    );

create policy "documentos: subida propia"
    on storage.objects for insert
    with check (
        bucket_id = 'documentos'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

-- ============================================================================
-- 6. SEED — Categorías de oficio (carga inicial exigida por T-02)
-- ============================================================================

insert into public.categorias_oficio (nombre, slug, orden) values
    ('Plomería',                    'plomeria',            10),
    ('Electricidad',                'electricidad',        20),
    ('Gas',                         'gas',                 30),
    ('Albañilería',                 'albanileria',         40),
    ('Pintura',                     'pintura',             50),
    ('Carpintería',                 'carpinteria',         60),
    ('Herrería',                    'herreria',            70),
    ('Cerrajería',                  'cerrajeria',          80),
    ('Aire acondicionado',          'aire-acondicionado',  90),
    ('Techista',                    'techista',           100),
    ('Durlock',                     'durlock',            110),
    ('Jardinería',                  'jardineria',         120),
    ('Limpieza',                    'limpieza',           130),
    ('Fletes y mudanzas',           'fletes-mudanzas',    140),
    ('Service de electrodomésticos','service-electro',    150),
    ('Redes e internet',            'redes-internet',     160),
    ('Cámaras de seguridad',        'camaras-seguridad',  170),
    ('Colocación de pisos',         'pisos',              180),
    ('Vidriería',                   'vidrieria',          190),
    ('Destapaciones',               'destapaciones',      200),
    ('Impermeabilización',          'impermeabilizacion', 210),
    ('Tapicería',                   'tapiceria',          220)
on conflict (slug) do nothing;

-- ============================================================================
-- FIN
-- ============================================================================
