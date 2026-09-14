-- ============================================================================
-- Laburito — Migración 0005
-- Sprint 2 · Pedidos (CU-13 publicar, CU-16 listar/buscar)
-- ============================================================================
--
-- Los pedidos son geolocalizados. Se guarda `geography(Point,4326)` y no un par
-- lat/lng suelto porque en el Sprint 3 la búsqueda por radio de CU-21 (alertas
-- push a los Profesionales cercanos) se resuelve con `ST_DWithin` contra el
-- índice GIST, del lado del servidor. Con lat/lng el cálculo quedaría en el
-- cliente y habría que traerse todos los pedidos para filtrar.
--
-- Numeración: la 0003 y la 0004 ya están tomadas por el CU-11, así que esta
-- migración es la 0005 aunque el plan del sprint la nombre «0003_pedidos».
--
-- Convenciones heredadas de la 0001:
--   * PostGIS vive en el esquema `extensions`; los tipos se escriben calificados.
--   * El catálogo de oficios es `public.categorias_oficio`.
--   * `public.set_updated_at()` y `public.es_admin()` ya existen: se reusan.
--
-- Es idempotente: se puede correr dos veces sin romper nada.
-- ============================================================================

create extension if not exists postgis with schema extensions;

-- ============================================================================
-- 1. TIPOS
-- ============================================================================

do $$
begin
    if not exists (
        select 1 from pg_type t
          join pg_namespace n on n.oid = t.typnamespace
         where t.typname = 'pedido_estado' and n.nspname = 'public'
    ) then
        create type public.pedido_estado as enum (
            'publicado',   -- visible para los Profesionales
            'pausado',     -- el Buscador lo saca de circulación sin cerrarlo
            'cerrado',     -- se resolvió (con o sin contratación)
            'cancelado',   -- el Buscador se arrepintió
            'vencido'      -- pasó fecha_vencimiento sin cerrarse
        );
    end if;

    if not exists (
        select 1 from pg_type t
          join pg_namespace n on n.oid = t.typnamespace
         where t.typname = 'pedido_urgencia' and n.nspname = 'public'
    ) then
        create type public.pedido_urgencia as enum ('baja', 'media', 'alta');
    end if;
end;
$$;

comment on type public.pedido_estado   is 'Ciclo de vida del pedido. Cada cambio queda auditado en public.pedido_eventos.';
comment on type public.pedido_urgencia is 'La declara el Buscador al publicar; ordena los resultados del CU-16.';

-- ============================================================================
-- 2. TABLAS
-- ============================================================================

-- 2.1 Pedidos
create table if not exists public.pedidos (
    id                    uuid primary key default gen_random_uuid(),

    buscador_id           uuid not null references public.perfiles (id)          on delete restrict,
    categoria_id          uuid not null references public.categorias_oficio (id) on delete restrict,

    titulo                text not null check (length(trim(titulo))      between  5 and   80),
    descripcion           text not null check (length(trim(descripcion)) between 20 and 1000),

    urgencia              public.pedido_urgencia not null default 'media',
    estado                public.pedido_estado   not null default 'publicado',

    ubicacion             extensions.geography(Point, 4326) not null,
    direccion_texto       text not null,
    referencia_ubicacion  text,

    presupuesto_estimado  numeric(12,2) check (presupuesto_estimado >= 0),

    fecha_publicacion     timestamptz not null default now(),
    fecha_vencimiento     timestamptz not null,
    fecha_cierre          timestamptz,
    motivo_cierre         text,

    created_at            timestamptz not null default now(),
    updated_at            timestamptz not null default now(),

    constraint pedidos_vencimiento_posterior_ck
        check (fecha_vencimiento > fecha_publicacion)
);

comment on table public.pedidos is
    'Solicitud de trabajo publicada por un Buscador. CU-13 (publicar), CU-16 (buscar), CU-21 (alertas por cercanía, Sprint 3).';

comment on column public.pedidos.buscador_id is
    'Autor del pedido. ON DELETE RESTRICT a propósito: la baja del CU-11 anonimiza el perfil, nunca borra la fila, así que el historial del Profesional del otro lado no se puede quedar huérfano.';
comment on column public.pedidos.ubicacion is
    'Punto WGS-84 donde hay que ir a trabajar. geography (no geometry) para que ST_Distance/ST_DWithin den metros reales sin proyectar.';
comment on column public.pedidos.direccion_texto is
    'Dirección tal como la escribió o la confirmó el Buscador. Es lo que se le muestra al Profesional; la ubicación es para calcular.';
comment on column public.pedidos.referencia_ubicacion is
    'Piso, departamento, entre calles. Dato de contacto: NO se expone en public.pedidos_publicos.';
comment on column public.pedidos.presupuesto_estimado is
    'Referencia en pesos que declara el Buscador. Opcional y no vinculante: el precio se acuerda entre las partes.';
comment on column public.pedidos.fecha_vencimiento is
    'A partir de acá el pedido deja de listarse. El pasaje a «vencido» lo hace el proceso del Sprint 3; las consultas no dependen de eso, filtran por fecha.';
comment on column public.pedidos.fecha_cierre is
    'Se completa al pasar a cerrado, cancelado o vencido. Nula mientras el pedido siga vivo.';
comment on column public.pedidos.motivo_cierre is
    'Texto libre del Buscador al cerrar o cancelar. Se copia al evento de auditoría correspondiente.';

-- Índices
create index if not exists pedidos_ubicacion_idx
    on public.pedidos using gist (ubicacion);

create index if not exists pedidos_estado_vencimiento_idx
    on public.pedidos (estado, fecha_vencimiento);

create index if not exists pedidos_buscador_idx
    on public.pedidos (buscador_id, created_at desc);

create index if not exists pedidos_categoria_idx
    on public.pedidos (categoria_id);

-- updated_at: reusa la función de la 0001
drop trigger if exists pedidos_set_updated_at on public.pedidos;
create trigger pedidos_set_updated_at
    before update on public.pedidos
    for each row execute function public.set_updated_at();

-- 2.2 Fotos del pedido
create table if not exists public.pedido_fotos (
    id            uuid primary key default gen_random_uuid(),
    pedido_id     uuid not null references public.pedidos (id) on delete cascade,
    storage_path  text not null,
    orden         integer not null default 0 check (orden >= 0),
    created_at    timestamptz not null default now(),

    unique (pedido_id, orden)
);

create index if not exists pedido_fotos_pedido_idx
    on public.pedido_fotos (pedido_id, orden);

comment on table public.pedido_fotos is
    'Hasta 5 fotos por pedido. El límite lo aplica el trigger pedido_fotos_limite.';
comment on column public.pedido_fotos.storage_path is
    'Ruta dentro del bucket de Storage, no una URL. La URL firmada se arma en el cliente.';
comment on column public.pedido_fotos.orden is
    'Posición en la galería, 0 = portada. Único por pedido para que el orden no quede ambiguo.';

-- 2.3 Auditoría del ciclo de vida
create table if not exists public.pedido_eventos (
    id               uuid primary key default gen_random_uuid(),
    pedido_id        uuid not null references public.pedidos (id) on delete cascade,
    estado_anterior  public.pedido_estado,
    estado_nuevo     public.pedido_estado not null,
    actor_id         uuid references public.perfiles (id) on delete set null,
    motivo           text,
    created_at       timestamptz not null default now()
);

create index if not exists pedido_eventos_pedido_idx
    on public.pedido_eventos (pedido_id, created_at desc);

comment on table public.pedido_eventos is
    'Una fila por cambio de estado de un pedido. La escribe el trigger, no la aplicación.';
comment on column public.pedido_eventos.estado_anterior is
    'Nulo solo si alguna vez se registra el alta. Hoy la tabla arranca en el primer cambio de estado.';
comment on column public.pedido_eventos.actor_id is
    'Quién provocó el cambio, tomado de auth.uid(). Nulo si lo hizo un proceso del servidor (por ejemplo el vencimiento automático). ON DELETE SET NULL para no perder el evento.';

-- ============================================================================
-- 3. TRIGGERS PROPIOS
-- ============================================================================

-- 3.1 Máximo 5 fotos por pedido.
--     SECURITY DEFINER porque el conteo tiene que ver TODAS las filas: con las
--     RLS del invocante podría contar de menos y dejar pasar el límite.
--     El lock sobre la fila del pedido serializa dos inserciones simultáneas,
--     que si no podrían contar 4 las dos y terminar en 6.
create or replace function public.pedido_fotos_limite()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_cantidad integer;
begin
    perform 1 from public.pedidos where id = new.pedido_id for update;

    select count(*) into v_cantidad
      from public.pedido_fotos
     where pedido_id = new.pedido_id;

    if v_cantidad >= 5 then
        raise exception 'Un pedido no puede tener más de 5 fotos';
    end if;

    return new;
end;
$$;

drop trigger if exists pedido_fotos_limite on public.pedido_fotos;
create trigger pedido_fotos_limite
    before insert on public.pedido_fotos
    for each row execute function public.pedido_fotos_limite();

-- 3.2 Auditoría: una fila por cambio de estado.
--     SECURITY DEFINER para poder insertar en pedido_eventos sin darle a nadie
--     permiso de INSERT sobre la tabla: la auditoría no se escribe a mano.
create or replace function public.registrar_evento_pedido()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if new.estado is distinct from old.estado then
        insert into public.pedido_eventos (
            pedido_id, estado_anterior, estado_nuevo, actor_id, motivo
        )
        values (
            new.id,
            old.estado,
            new.estado,
            auth.uid(),
            nullif(trim(coalesce(new.motivo_cierre, '')), '')
        );
    end if;

    return null;  -- AFTER trigger: el valor de retorno se ignora
end;
$$;

drop trigger if exists pedidos_registrar_evento on public.pedidos;
create trigger pedidos_registrar_evento
    after update on public.pedidos
    for each row execute function public.registrar_evento_pedido();

-- ============================================================================
-- 4. ROW LEVEL SECURITY
-- ============================================================================
--
-- No estaba en el pedido de la tarea, pero en Supabase una tabla de `public`
-- sin RLS queda legible y escribible por PostgREST para cualquiera con la clave
-- anónima, que es pública por definición y viaja en el bundle de la web. Sin
-- esta sección, `pedidos` expondría la dirección exacta de cada Buscador.
--
-- ============================================================================

alter table public.pedidos        enable row level security;
alter table public.pedido_fotos   enable row level security;
alter table public.pedido_eventos enable row level security;

-- 4.1 pedidos
drop policy if exists "buscador propio: sus pedidos" on public.pedidos;
create policy "buscador propio: sus pedidos"
    on public.pedidos for all
    using (auth.uid() = buscador_id)
    with check (auth.uid() = buscador_id);

drop policy if exists "público: pedidos publicados vigentes" on public.pedidos;
create policy "público: pedidos publicados vigentes"
    on public.pedidos for select
    using (estado = 'publicado' and fecha_vencimiento > now());

drop policy if exists "admin: gestión de pedidos" on public.pedidos;
create policy "admin: gestión de pedidos"
    on public.pedidos for all
    using (public.es_admin());

-- 4.2 pedido_fotos — siguen la visibilidad del pedido al que cuelgan
drop policy if exists "buscador propio: fotos de sus pedidos" on public.pedido_fotos;
create policy "buscador propio: fotos de sus pedidos"
    on public.pedido_fotos for all
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_id
               and p.buscador_id = auth.uid()
        )
    )
    with check (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_id
               and p.buscador_id = auth.uid()
        )
    );

drop policy if exists "público: fotos de pedidos visibles" on public.pedido_fotos;
create policy "público: fotos de pedidos visibles"
    on public.pedido_fotos for select
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_id
               and p.estado = 'publicado'
               and p.fecha_vencimiento > now()
        )
    );

drop policy if exists "admin: gestión de fotos" on public.pedido_fotos;
create policy "admin: gestión de fotos"
    on public.pedido_fotos for all
    using (public.es_admin());

-- 4.3 pedido_eventos — solo lectura, y solo para el dueño del pedido o el admin.
--     No hay política de INSERT: la única vía de escritura es el trigger.
drop policy if exists "buscador propio: auditoría de sus pedidos" on public.pedido_eventos;
create policy "buscador propio: auditoría de sus pedidos"
    on public.pedido_eventos for select
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_id
               and p.buscador_id = auth.uid()
        )
    );

drop policy if exists "admin: lectura de auditoría" on public.pedido_eventos;
create policy "admin: lectura de auditoría"
    on public.pedido_eventos for select
    using (public.es_admin());

-- ============================================================================
-- 5. VISTA PÚBLICA
-- ============================================================================
--
-- Lo que ve un Profesional en el listado del CU-16: el pedido sin los datos con
-- los que se llega a la puerta ni se contacta al Buscador. Quedan afuera
-- `referencia_ubicacion` (piso y departamento) y la ubicación exacta; en su
-- lugar va el punto redondeado a ~3 decimales (unos 100 m) para ubicarlo en el
-- mapa sin publicar el domicilio. El dato fino se entrega recién al contactar.
--
-- security_invoker = true: sin eso la vista correría con los permisos de quien
-- la creó y saltearía las RLS de `pedidos`, que es justo lo contrario de lo que
-- se quiere.
-- ============================================================================

drop view if exists public.pedidos_publicos;

create view public.pedidos_publicos
with (security_invoker = true)
as
select
    p.id,
    p.categoria_id,
    c.nombre                                        as categoria_nombre,
    c.slug                                          as categoria_slug,
    p.titulo,
    p.descripcion,
    p.urgencia,
    extensions.st_setsrid(
        extensions.st_makepoint(
            round(extensions.st_x(p.ubicacion::extensions.geometry)::numeric, 3)::double precision,
            round(extensions.st_y(p.ubicacion::extensions.geometry)::numeric, 3)::double precision
        ),
        4326
    )::extensions.geography                         as ubicacion_aproximada,
    p.direccion_texto,
    p.presupuesto_estimado,
    p.fecha_publicacion,
    p.fecha_vencimiento,
    (select count(*) from public.pedido_fotos f where f.pedido_id = p.id) as cantidad_fotos
from public.pedidos p
join public.categorias_oficio c on c.id = p.categoria_id
where p.estado = 'publicado'
  and p.fecha_vencimiento > now();

comment on view public.pedidos_publicos is
    'Pedidos vigentes tal como los ve un Profesional (CU-16). Sin datos de contacto ni ubicación exacta del Buscador.';

grant select on public.pedidos_publicos to anon, authenticated;

-- ============================================================================
-- 6. Prueba de aceptación (SQL Editor)
-- ============================================================================
--
--   -- alta de un pedido (reemplazar el uuid por un perfil de tipo buscador)
--   insert into public.pedidos (
--       buscador_id, categoria_id, titulo, descripcion,
--       ubicacion, direccion_texto, fecha_vencimiento)
--   values (
--       'PEGAR_UUID',
--       (select id from public.categorias_oficio where slug = 'plomeria'),
--       'Pérdida en el termotanque',
--       'Pierde agua por la base desde ayer, necesito que lo vean esta semana.',
--       extensions.st_setsrid(extensions.st_makepoint(-58.3816, -34.6037), 4326),
--       'Av. Siempreviva 742, CABA',
--       now() + interval '7 days');
--
--   -- tiene que aparecer en la vista, sin referencia_ubicacion
--   select * from public.pedidos_publicos;
--
--   -- el cambio de estado tiene que dejar rastro
--   update public.pedidos set estado = 'pausado' where titulo = 'Pérdida en el termotanque';
--   select estado_anterior, estado_nuevo, actor_id from public.pedido_eventos;
--
--   -- la sexta foto tiene que fallar con «no puede tener más de 5 fotos»
--   insert into public.pedido_fotos (pedido_id, storage_path, orden)
--   select id, 'x/' || g || '.jpg', g
--     from public.pedidos, generate_series(0, 5) g
--    where titulo = 'Pérdida en el termotanque';
--
-- ============================================================================
-- FIN
-- ============================================================================
