-- ============================================================================
-- Laburito — Migración 0012
-- Sprint 3 · T-07: esquema del Profesional
-- CU-07 zona de cobertura · CU-44 horarios · CU-06 portafolio ·
-- CU-21 dispositivos · CU-23 ignorar · CU-24 guardar
-- ============================================================================
--
-- Regla de este sprint (primer ajuste de 7.2.7): cada tabla trae sus políticas
-- RLS en este mismo archivo, pegadas a su `create table`. Ninguna tabla nace
-- abierta esperando una migración posterior.
--
-- Se escribió contra el esquema real, consultado en la base el 14/09 (tercer
-- ajuste de 7.2.7), y ese esquema difiere del plan del sprint en cuatro puntos:
--
--   1. `profesionales` ya tiene `ubicacion` y `radio_cobertura_km` desde la
--      0001, sin uso en ningún lado: ninguna pantalla los lee y las tres filas
--      de la base los tienen en null. El plan pide una tabla aparte para la
--      zona. Se crea la tabla y **se borran las dos columnas** (sección 2):
--      dejarlas es tener dos lugares donde vive la zona, y el emparejamiento
--      del CU-21 terminaría leyendo el que nadie actualiza.
--   2. `profesionales.disponible` (CU-44) también existe desde la 0001, con su
--      índice parcial. No se agrega nada.
--   3. `profesional_categorias` ya tiene una política `for all` para el dueño,
--      que cubre UPDATE y DELETE. El plan decía que faltaban; no faltan. El
--      CU-12 no necesita nada de esta migración.
--   4. El bucket del portafolio ya existe: se llama `portafolios` y la 0001 lo
--      creó **público y sin ninguna política**. Se reusa el id —cambiarlo por
--      `portafolio` dejaría un bucket huérfano— pero se pasa a privado, que es
--      lo que pide el plan (URLs firmadas, como las fotos del pedido). Tiene
--      cero objetos, así que no hay enlaces públicos que se rompan.
--
-- Convenciones heredadas:
--   * PostGIS vive en `extensions`: los tipos y funciones van calificados.
--   * El catálogo de oficios es `public.categorias_oficio`.
--   * `set_updated_at()` y `es_admin()` ya existen (0001): se reusan.
--   * Las excepciones de negocio llevan `hint` legible por máquina (decisión
--     del 02/09).
--
-- Es idempotente: se puede correr dos veces sin romper nada.
-- ============================================================================

create extension if not exists postgis    with schema extensions;
-- Para la restricción de exclusión de los horarios (sección 4): la igualdad
-- sobre uuid y smallint dentro de un índice GiST la da btree_gist.
create extension if not exists btree_gist with schema extensions;


-- ============================================================================
-- 1. Helper: ¿quien llama es un Profesional con la cuenta viva?
-- ============================================================================
--
-- Lo usan todas las políticas de escritura de este archivo. SECURITY DEFINER
-- por el mismo motivo que `es_admin()`: lee `perfiles` y `profesionales` sin
-- depender de las RLS de quien llama, y evita repetir el mismo `exists` con
-- join en doce políticas.
--
-- Pide `estado = 'activo'`, no solo `deleted_at is null`: un Profesional
-- suspendido no debería poder seguir configurando a qué pedidos le llegan
-- alertas.
-- ============================================================================

create or replace function public.es_profesional_activo()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
    select exists (
        select 1
          from public.profesionales pr
          join public.perfiles p on p.id = pr.perfil_id
         where pr.perfil_id = auth.uid()
           and p.tipo       = 'profesional'
           and p.estado     = 'activo'
           and p.deleted_at is null
    );
$$;

comment on function public.es_profesional_activo() is
    'true si auth.uid() es un Profesional con la cuenta activa. Condición de escritura de todas las tablas de la 0012.';


-- ============================================================================
-- 2. CU-07 · profesional_zona_cobertura
-- ============================================================================
--
-- Una zona por Profesional: la clave primaria es el propio profesional_id. Es
-- un círculo —centro y radio— porque es lo que dibuja el CU-07 y lo que
-- `ST_DWithin` evalúa exacto, sin aproximar un polígono.
--
-- El radio va en metros, que es la unidad de `ST_DWithin` sobre geography: la
-- consulta del CU-21 no convierte nada. El rango (1 a 100 km) es el mismo que
-- tenía `radio_cobertura_km` en la 0001.
--
-- Sobre el índice: `ST_DWithin(centro, punto, radio_metros)` con el radio
-- tomado de la fila **no** usa el GiST, porque el planificador necesita un
-- radio constante para expandir la caja de búsqueda. El emparejamiento del
-- CU-21 filtra primero con el máximo, que sí es constante, y después con el
-- de la fila:
--
--     where extensions.st_dwithin(z.centro, p.ubicacion, 100000)       -- índice
--       and extensions.st_dwithin(z.centro, p.ubicacion, z.radio_metros) -- exacto
--
-- Visibilidad: **solo el dueño y el administrador**. El centro de la zona es,
-- en la práctica, el domicilio del Profesional; nadie más lo necesita, y el
-- emparejamiento corre en la Edge Function con service_role, que no pasa por
-- RLS.
-- ============================================================================

create table if not exists public.profesional_zona_cobertura (
    profesional_id   uuid primary key
                     references public.profesionales (perfil_id) on delete cascade,
    centro           extensions.geography(Point, 4326) not null,
    radio_metros     integer not null default 10000
                     check (radio_metros between 1000 and 100000),
    direccion_texto  text check (length(direccion_texto) <= 200),
    created_at       timestamptz not null default now(),
    updated_at       timestamptz not null default now()
);

comment on table public.profesional_zona_cobertura is
    'CU-07. Círculo dentro del cual el Profesional quiere recibir alertas (CU-21). Uno por Profesional.';
comment on column public.profesional_zona_cobertura.centro is
    'Punto WGS-84. Dato sensible: aproxima el domicilio. No se expone a nadie más que al dueño.';
comment on column public.profesional_zona_cobertura.radio_metros is
    'Metros, la unidad de ST_DWithin sobre geography. Entre 1 y 100 km.';
comment on column public.profesional_zona_cobertura.direccion_texto is
    'Lo que devolvió el SelectorUbicacion, para mostrarlo en la pantalla del CU-07. El cálculo usa centro.';

create index if not exists profesional_zona_cobertura_centro_idx
    on public.profesional_zona_cobertura using gist (centro);

drop trigger if exists profesional_zona_cobertura_set_updated_at on public.profesional_zona_cobertura;
create trigger profesional_zona_cobertura_set_updated_at
    before update on public.profesional_zona_cobertura
    for each row execute function public.set_updated_at();

alter table public.profesional_zona_cobertura enable row level security;

drop policy if exists "zona: gestión propia" on public.profesional_zona_cobertura;
create policy "zona: gestión propia"
    on public.profesional_zona_cobertura for all
    to authenticated
    using      (profesional_id = auth.uid())
    with check (profesional_id = auth.uid() and public.es_profesional_activo());

drop policy if exists "zona: lectura del admin" on public.profesional_zona_cobertura;
create policy "zona: lectura del admin"
    on public.profesional_zona_cobertura for select
    to authenticated
    using (public.es_admin());

-- Las columnas viejas de la 0001 (ver punto 1 del encabezado). Su índice GiST
-- `profesionales_ubicacion_idx` cae con la columna.
alter table public.profesionales drop column if exists ubicacion;
alter table public.profesionales drop column if exists radio_cobertura_km;


-- ============================================================================
-- 3. CU-44 · disponibilidad
-- ============================================================================
--
-- `profesionales.disponible` ya existe (0001): boolean, default false, índice
-- parcial. Se escribe con la política «profesional propio: actualización» de
-- la 0002. Solo se documenta.
-- ============================================================================

comment on column public.profesionales.disponible is
    'CU-44. Interruptor de disponibilidad: un Profesional no disponible no recibe alertas del CU-21.';


-- ============================================================================
-- 4. CU-44 · profesional_horarios
-- ============================================================================
--
-- Una fila por franja. Varias franjas por día (mañana y tarde) se permiten;
-- **superpuestas no**, y eso lo garantiza una restricción de exclusión y no un
-- trigger que cuente: dos inserciones simultáneas que se pisan no pueden
-- entrar las dos, sin necesidad de bloquear nada.
--
-- El día es ISO: 1 = lunes … 7 = domingo. Coincide con `extract(isodow ...)`
-- de Postgres y con `DateTime.weekday` de Dart, así que nadie traduce.
--
-- Una franja no cruza la medianoche: `hora_hasta > hora_desde`. La que termina
-- a medianoche se escribe hasta '24:00', que `time` admite. Una guardia de
-- 22 a 6 son dos filas.
--
-- Visibilidad: la hereda del Profesional. `exists` sobre `profesionales` corre
-- con las RLS de quien consulta, así que la fila se ve exactamente cuando se
-- ve el Profesional: el dueño, el admin, y cualquiera si está aprobado y
-- activo (política «público: profesionales aprobados» de la 0001). Los
-- horarios de atención son información de perfil público.
-- ============================================================================

create table if not exists public.profesional_horarios (
    id              uuid primary key default gen_random_uuid(),
    profesional_id  uuid not null
                    references public.profesionales (perfil_id) on delete cascade,
    dia_semana      smallint not null check (dia_semana between 1 and 7),
    hora_desde      time not null,
    hora_hasta      time not null,
    created_at      timestamptz not null default now(),

    constraint profesional_horarios_orden_ck
        check (hora_hasta > hora_desde),

    constraint profesional_horarios_sin_superposicion
        exclude using gist (
            profesional_id with =,
            dia_semana     with =,
            tsrange(date '2000-01-03' + hora_desde,
                    date '2000-01-03' + hora_hasta, '[)') with &&
        )
);

comment on table public.profesional_horarios is
    'CU-44. Franjas de atención por día de la semana (ISO, 1 = lunes). Sin superposición por construcción.';
comment on constraint profesional_horarios_sin_superposicion on public.profesional_horarios is
    'Rango semiabierto [desde, hasta): 9-13 y 13-18 el mismo día conviven; 9-13 y 12-18 no. La fecha fija es solo para armar un tsrange.';

alter table public.profesional_horarios enable row level security;

drop policy if exists "horarios: lectura si se ve el profesional" on public.profesional_horarios;
create policy "horarios: lectura si se ve el profesional"
    on public.profesional_horarios for select
    using (
        exists (
            select 1 from public.profesionales pr
             where pr.perfil_id = profesional_id
        )
    );

drop policy if exists "horarios: gestión propia" on public.profesional_horarios;
create policy "horarios: gestión propia"
    on public.profesional_horarios for all
    to authenticated
    using      (profesional_id = auth.uid())
    with check (profesional_id = auth.uid() and public.es_profesional_activo());


-- ============================================================================
-- 5. CU-06 · profesional_portafolio + bucket `portafolios`
-- ============================================================================
--
-- Mismo diseño que `pedido_fotos` (0005): la fila guarda la ruta dentro del
-- bucket, no una URL, y la URL firmada se arma en el cliente con
-- `UrlsFirmadas`.
--
-- La ruta es `<perfil_id>/<nombre>` y un `check` lo exige: la política de
-- Storage autoriza por la primera carpeta, así que una fila que apunte a la
-- carpeta de otro sería una foto que su dueño no puede borrar.
--
-- `unique (profesional_id, orden)` es DEFERRABLE: reordenar es intercambiar
-- posiciones, y con la restricción inmediata un UPDATE que mueve dos filas
-- choca consigo mismo a mitad de sentencia.
-- ============================================================================

create table if not exists public.profesional_portafolio (
    id              uuid primary key default gen_random_uuid(),
    profesional_id  uuid not null
                    references public.profesionales (perfil_id) on delete cascade,
    storage_path    text not null unique,
    descripcion     text check (length(descripcion) <= 200),
    orden           integer not null default 0 check (orden >= 0),
    created_at      timestamptz not null default now(),

    constraint profesional_portafolio_ruta_propia_ck
        check (split_part(storage_path, '/', 1) = profesional_id::text),

    constraint profesional_portafolio_orden_uq
        unique (profesional_id, orden) deferrable initially immediate
);

comment on table public.profesional_portafolio is
    'CU-06. Hasta 10 fotos de trabajos por Profesional. El límite lo aplica el trigger profesional_portafolio_limite.';
comment on column public.profesional_portafolio.storage_path is
    'Ruta dentro del bucket portafolios, con la carpeta del dueño adelante. No es una URL.';
comment on column public.profesional_portafolio.orden is
    'Posición en la galería, 0 = portada. Único por Profesional; la restricción es diferible para poder reordenar.';

-- 5.1 Tope de 10 fotos.
--
--     Toda restricción «no más de N» que se resuelve contando filas es una
--     condición de carrera: dos inserciones simultáneas cuentan 9 las dos y
--     terminan en 11. El `for update` sobre la fila del Profesional serializa
--     las inserciones del mismo dueño **antes** de contar: la segunda espera a
--     que la primera termine y cuenta 10.
--
--     SECURITY DEFINER porque el conteo tiene que ver todas las filas, no las
--     que las RLS de quien llama le dejen ver, y porque bloquear la fila de
--     `profesionales` pide un permiso de UPDATE que no depende de la política.
--
--     Dispara también si cambia `profesional_id`: mover una foto a otro
--     Profesional es, para el destino, un alta.
create or replace function public.profesional_portafolio_limite()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_cantidad integer;
begin
    perform 1
       from public.profesionales
      where perfil_id = new.profesional_id
        for update;

    select count(*) into v_cantidad
      from public.profesional_portafolio
     where profesional_id = new.profesional_id;

    if v_cantidad >= 10 then
        raise exception 'El portafolio no puede tener más de 10 fotos'
              using hint = 'limite_portafolio';
    end if;

    return new;
end;
$$;

comment on function public.profesional_portafolio_limite() is
    'Tope de 10 fotos por portafolio. Bloquea la fila del Profesional antes de contar.';

drop trigger if exists profesional_portafolio_limite on public.profesional_portafolio;
create trigger profesional_portafolio_limite
    before insert or update of profesional_id on public.profesional_portafolio
    for each row execute function public.profesional_portafolio_limite();

alter table public.profesional_portafolio enable row level security;

drop policy if exists "portafolio: lectura si se ve el profesional" on public.profesional_portafolio;
create policy "portafolio: lectura si se ve el profesional"
    on public.profesional_portafolio for select
    using (
        exists (
            select 1 from public.profesionales pr
             where pr.perfil_id = profesional_id
        )
    );

drop policy if exists "portafolio: gestión propia" on public.profesional_portafolio;
create policy "portafolio: gestión propia"
    on public.profesional_portafolio for all
    to authenticated
    using      (profesional_id = auth.uid())
    with check (profesional_id = auth.uid() and public.es_profesional_activo());

-- 5.2 Bucket. Existe desde la 0001 como público; pasa a privado.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('portafolios', 'portafolios', false, 5242880,
        array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
   set public             = false,
       file_size_limit    = excluded.file_size_limit,
       allowed_mime_types = excluded.allowed_mime_types;

-- 5.3 Políticas de Storage. La lectura sigue a la tabla: se firma una foto
--     cuando se ve al Profesional. La escritura, sobre la carpeta propia y
--     solo con la cuenta activa. El borrado no pide cuenta activa: el CU-11
--     borra los archivos por la API **antes** de anonimizar (0004), y tiene
--     que poder hacerlo pase lo que pase con el estado.
drop policy if exists "portafolios: lectura si se ve el profesional" on storage.objects;
create policy "portafolios: lectura si se ve el profesional"
    on storage.objects for select
    using (
        bucket_id = 'portafolios'
        and exists (
            select 1 from public.profesionales pr
             where pr.perfil_id::text = (storage.foldername(name))[1]
        )
    );

drop policy if exists "portafolios: subida propia" on storage.objects;
create policy "portafolios: subida propia"
    on storage.objects for insert
    to authenticated
    with check (
        bucket_id = 'portafolios'
        and (storage.foldername(name))[1] = auth.uid()::text
        and public.es_profesional_activo()
    );

drop policy if exists "portafolios: reemplazo propio" on storage.objects;
create policy "portafolios: reemplazo propio"
    on storage.objects for update
    to authenticated
    using (
        bucket_id = 'portafolios'
        and (storage.foldername(name))[1] = auth.uid()::text
    )
    with check (
        bucket_id = 'portafolios'
        and (storage.foldername(name))[1] = auth.uid()::text
        and public.es_profesional_activo()
    );

drop policy if exists "portafolios: borrado propio" on storage.objects;
create policy "portafolios: borrado propio"
    on storage.objects for delete
    to authenticated
    using (
        bucket_id = 'portafolios'
        and (storage.foldername(name))[1] = auth.uid()::text
    );


-- ============================================================================
-- 6. CU-21 · profesional_dispositivos
-- ============================================================================
--
-- Un token de FCM por instalación. El token es único en toda la tabla: FCM lo
-- emite por instalación de la app, no por usuario, así que si en un mismo
-- teléfono se cierra una sesión y se abre otra, el token tiene que cambiar de
-- dueño y no duplicarse — si no, el Profesional anterior seguiría recibiendo
-- las alertas del nuevo.
--
-- Ese traspaso no se puede hacer con estas políticas (la fila del dueño
-- anterior es invisible para el nuevo) y es a propósito: lo va a hacer la RPC
-- de registro del CU-21 b, SECURITY DEFINER, que es el único lugar donde tiene
-- sentido decidir que un token cambia de manos.
--
-- Visibilidad: solo el dueño. El envío lo hace la Edge Function con
-- service_role.
-- ============================================================================

create table if not exists public.profesional_dispositivos (
    id              uuid primary key default gen_random_uuid(),
    profesional_id  uuid not null
                    references public.profesionales (perfil_id) on delete cascade,
    token_fcm       text not null unique
                    check (length(token_fcm) between 20 and 4096),
    plataforma      text not null
                    check (plataforma in ('android', 'ios', 'web')),
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

comment on table public.profesional_dispositivos is
    'CU-21. Tokens de Firebase Cloud Messaging, uno por instalación. Se da de baja al cerrar sesión.';
comment on column public.profesional_dispositivos.token_fcm is
    'Único en toda la tabla: el token es de la instalación, no del usuario. El traspaso entre cuentas lo hace la RPC del CU-21 b.';
comment on column public.profesional_dispositivos.updated_at is
    'Último registro del token. Sirve para purgar los que FCM ya no reconoce.';

create index if not exists profesional_dispositivos_profesional_idx
    on public.profesional_dispositivos (profesional_id);

drop trigger if exists profesional_dispositivos_set_updated_at on public.profesional_dispositivos;
create trigger profesional_dispositivos_set_updated_at
    before update on public.profesional_dispositivos
    for each row execute function public.set_updated_at();

alter table public.profesional_dispositivos enable row level security;

drop policy if exists "dispositivos: gestión propia" on public.profesional_dispositivos;
create policy "dispositivos: gestión propia"
    on public.profesional_dispositivos for all
    to authenticated
    using      (profesional_id = auth.uid())
    with check (profesional_id = auth.uid() and public.es_profesional_activo());


-- ============================================================================
-- 7. CU-23 · pedido_ignorado  /  CU-24 · pedido_favorito
-- ============================================================================
--
-- Relaciones puras: clave compuesta (profesional, pedido), sin id propio y sin
-- UPDATE — no hay nada que editar, se marca o se desmarca.
--
-- El alta exige que quien marca **vea** el pedido: el `exists` sobre `pedidos`
-- corre con las RLS de quien llama, así que solo entra un pedido publicado y
-- vigente (política de la 0006). Sin eso, cualquiera podría confirmar que un
-- id de pedido existe probando uuids contra la FK.
--
-- El borrado no pide ver el pedido: un favorito de un pedido que después se
-- cerró se tiene que poder quitar.
--
-- `on delete cascade` hacia `pedidos` no se lleva historia: los pedidos no se
-- borran (no hay política de DELETE, decisión del 02/09).
--
-- Que un pedido no esté ignorado y guardado a la vez lo resuelve la acción del
-- CU-23 en la Fase 7 (ignorar quita de favoritos); no es una regla de esquema.
-- ============================================================================

create table if not exists public.pedido_ignorado (
    profesional_id  uuid not null references public.profesionales (perfil_id) on delete cascade,
    pedido_id       uuid not null references public.pedidos (id)               on delete cascade,
    created_at      timestamptz not null default now(),
    primary key (profesional_id, pedido_id)
);

comment on table public.pedido_ignorado is
    'CU-23. Pedidos que el Profesional sacó de su tablero. Solo los ve él.';

create index if not exists pedido_ignorado_pedido_idx
    on public.pedido_ignorado (pedido_id);

alter table public.pedido_ignorado enable row level security;

drop policy if exists "ignorados: lectura propia" on public.pedido_ignorado;
create policy "ignorados: lectura propia"
    on public.pedido_ignorado for select
    to authenticated
    using (profesional_id = auth.uid());

drop policy if exists "ignorados: alta propia de un pedido visible" on public.pedido_ignorado;
create policy "ignorados: alta propia de un pedido visible"
    on public.pedido_ignorado for insert
    to authenticated
    with check (
        profesional_id = auth.uid()
        and public.es_profesional_activo()
        and exists (select 1 from public.pedidos p where p.id = pedido_id)
    );

drop policy if exists "ignorados: baja propia" on public.pedido_ignorado;
create policy "ignorados: baja propia"
    on public.pedido_ignorado for delete
    to authenticated
    using (profesional_id = auth.uid());


create table if not exists public.pedido_favorito (
    profesional_id  uuid not null references public.profesionales (perfil_id) on delete cascade,
    pedido_id       uuid not null references public.pedidos (id)               on delete cascade,
    created_at      timestamptz not null default now(),
    primary key (profesional_id, pedido_id)
);

comment on table public.pedido_favorito is
    'CU-24. Pedidos que el Profesional guardó. Solo los ve él.';

create index if not exists pedido_favorito_pedido_idx
    on public.pedido_favorito (pedido_id);

alter table public.pedido_favorito enable row level security;

drop policy if exists "favoritos: lectura propia" on public.pedido_favorito;
create policy "favoritos: lectura propia"
    on public.pedido_favorito for select
    to authenticated
    using (profesional_id = auth.uid());

drop policy if exists "favoritos: alta propia de un pedido visible" on public.pedido_favorito;
create policy "favoritos: alta propia de un pedido visible"
    on public.pedido_favorito for insert
    to authenticated
    with check (
        profesional_id = auth.uid()
        and public.es_profesional_activo()
        and exists (select 1 from public.pedidos p where p.id = pedido_id)
    );

drop policy if exists "favoritos: baja propia" on public.pedido_favorito;
create policy "favoritos: baja propia"
    on public.pedido_favorito for delete
    to authenticated
    using (profesional_id = auth.uid());


-- ============================================================================
-- 8. CU-11 · la baja limpia lo que agrega esta migración
-- ============================================================================
--
-- La baja no borra la fila de `profesionales`, así que ningún `on delete
-- cascade` de arriba dispara. Lo que es dato personal se borra a mano:
--
--   * la zona, que aproxima el domicilio;
--   * los horarios, los dispositivos y las marcas de ignorado/favorito;
--   * las filas del portafolio. **Los archivos no**: Supabase rechaza el DML
--     sobre `storage.objects` (0004), así que los tiene que borrar el cliente
--     por la API antes de llamar a la RPC, como ya hace con el avatar y el
--     DNI. Hoy el bucket está vacío y no hay pantalla de carga; el borrado
--     del lado del cliente entra con el CU-06 (Fase 9).
--
-- Se reescribe la función entera, como en la 0004, para que este archivo sea
-- la versión vigente. Respecto de la 0004 cambia solo el bloque del
-- Profesional: sale `ubicacion = null` (la columna ya no existe) y entran los
-- `delete`.
-- ============================================================================

create or replace function public.dar_de_baja_cuenta(p_motivo text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_id     uuid := auth.uid();
    v_lapida text;
begin
    if v_id is null then
        raise exception 'No hay sesión activa';
    end if;

    if exists (select 1 from public.perfiles where id = v_id and estado = 'baja') then
        raise exception 'La cuenta ya se encuentra dada de baja';
    end if;

    v_lapida := 'baja+' || v_id::text || '@laburito.invalid';

    -- La auditoría va primero: después del anonimizado ya no hay de dónde
    -- sacar el dato.
    insert into public.bajas_cuenta (perfil_id, motivo)
    values (v_id, nullif(trim(coalesce(p_motivo, '')), ''));

    -- Perfil: sobrevive la fila, no los datos personales.
    update public.perfiles
       set estado     = 'baja',
           deleted_at = now(),
           nombre     = 'Cuenta',
           apellido   = 'dada de baja',
           email      = v_lapida,
           telefono   = null,
           avatar_url = null
     where id = v_id;

    -- Datos del profesional.
    update public.profesionales
       set dni         = null,
           descripcion = null,
           disponible  = false
     where perfil_id = v_id;

    delete from public.profesional_zona_cobertura where profesional_id = v_id;
    delete from public.profesional_horarios       where profesional_id = v_id;
    delete from public.profesional_dispositivos   where profesional_id = v_id;
    delete from public.profesional_portafolio     where profesional_id = v_id;
    delete from public.pedido_ignorado            where profesional_id = v_id;
    delete from public.pedido_favorito            where profesional_id = v_id;

    -- Los documentos se destruyen: sus archivos ya los borró el cliente por la
    -- API de Storage antes de llegar acá.
    delete from public.documentos_verificacion
     where profesional_id = v_id;

    -- Identidad: se libera el correo real y se limpia el metadata del signUp,
    -- que guarda nombre, apellido, teléfono y DNI.
    update auth.users
       set email              = v_lapida,
           phone              = null,
           raw_user_meta_data = '{}'::jsonb
     where id = v_id;

    update auth.identities
       set identity_data = jsonb_build_object('sub', v_id::text, 'email', v_lapida)
     where user_id = v_id
       and provider = 'email';

    -- Cortar cualquier sesión viva en otros dispositivos. Los refresh tokens
    -- caen por la FK a auth.sessions.
    delete from auth.sessions where user_id = v_id;
end;
$$;

revoke all on function public.dar_de_baja_cuenta(text) from public;
grant execute on function public.dar_de_baja_cuenta(text) to authenticated;


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
-- El editor corre como `postgres`, que ignora las RLS. Para probar políticas
-- se baja a `authenticated` y se falsifica el JWT **dentro de una transacción
-- que termina en rollback**: no queda nada escrito. Cada bloque se envía solo.
-- PEGAR_PROFESIONAL = un Profesional activo; PEGAR_OTRO = cualquier otro
-- perfil; PEGAR_PEDIDO = un pedido en estado publicado.
--
--   -- 1. Catálogo: seis tablas, todas con RLS y con políticas.
--   select c.relname, c.relrowsecurity,
--          (select count(*) from pg_policies p
--            where p.schemaname = 'public' and p.tablename = c.relname) as politicas
--     from pg_class c
--    where c.relnamespace = 'public'::regnamespace
--      and c.relname in ('profesional_zona_cobertura', 'profesional_horarios',
--                        'profesional_portafolio', 'profesional_dispositivos',
--                        'pedido_ignorado', 'pedido_favorito')
--    order by 1;
--   -- → 6 filas, relrowsecurity = true en todas, politicas ≥ 1
--
--   -- 2. Las columnas viejas ya no están y el bucket es privado.
--   select column_name from information_schema.columns
--    where table_schema = 'public' and table_name = 'profesionales'
--      and column_name in ('ubicacion', 'radio_cobertura_km');
--   -- → 0 filas
--   select public from storage.buckets where id = 'portafolios';
--   -- → false
--
--   -- 3. El tope del portafolio bloquea la fila padre antes de contar.
--   select prosrc ~* 'for\s+update.*count\(\*\)'
--     from pg_proc where proname = 'profesional_portafolio_limite';
--   -- → true
--
--   -- 4. Zona: el dueño escribe y lee la suya; otro no la ve.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   insert into public.profesional_zona_cobertura (profesional_id, centro, radio_metros)
--   values ('PEGAR_PROFESIONAL', public.punto(-34.5226, -58.7614), 5000);
--   select count(*) from public.profesional_zona_cobertura;          -- → 1
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_OTRO","role":"authenticated"}', true);
--   select count(*) from public.profesional_zona_cobertura;          -- → 0
--   rollback;
--
--   -- 5. Nadie escribe la zona de otro.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_OTRO","role":"authenticated"}', true);
--   insert into public.profesional_zona_cobertura (profesional_id, centro)
--   values ('PEGAR_PROFESIONAL', public.punto(-34.5226, -58.7614));
--   -- → ERROR 42501: new row violates row-level security policy
--   rollback;
--
--   -- 6. Horarios: 9-13 y 13-18 conviven; 12-15 el mismo día no entra.
--   begin;
--   insert into public.profesional_horarios (profesional_id, dia_semana, hora_desde, hora_hasta)
--   values ('PEGAR_PROFESIONAL', 1, '09:00', '13:00'),
--          ('PEGAR_PROFESIONAL', 1, '13:00', '18:00'),
--          ('PEGAR_PROFESIONAL', 1, '20:00', '24:00');                -- → INSERT 3
--   insert into public.profesional_horarios (profesional_id, dia_semana, hora_desde, hora_hasta)
--   values ('PEGAR_PROFESIONAL', 1, '12:00', '15:00');
--   -- → ERROR 23P01: conflicting key value violates exclusion constraint
--   --   "profesional_horarios_sin_superposicion"
--   rollback;
--
--   -- 7. Portafolio: la undécima foto falla, y una ruta ajena también.
--   begin;
--   insert into public.profesional_portafolio (profesional_id, storage_path, orden)
--   select 'PEGAR_PROFESIONAL', 'PEGAR_PROFESIONAL/' || g || '.jpg', g
--     from generate_series(0, 9) g;                                   -- → INSERT 10
--   insert into public.profesional_portafolio (profesional_id, storage_path, orden)
--   values ('PEGAR_PROFESIONAL', 'PEGAR_PROFESIONAL/10.jpg', 10);
--   -- → ERROR: El portafolio no puede tener más de 10 fotos  (HINT: limite_portafolio)
--   rollback;
--   begin;
--   insert into public.profesional_portafolio (profesional_id, storage_path)
--   values ('PEGAR_PROFESIONAL', 'PEGAR_OTRO/x.jpg');
--   -- → ERROR 23514: profesional_portafolio_ruta_propia_ck
--   rollback;
--
--   -- 8. Reordenar dos fotos en un solo UPDATE funciona (restricción diferible).
--   begin;
--   insert into public.profesional_portafolio (profesional_id, storage_path, orden)
--   values ('PEGAR_PROFESIONAL', 'PEGAR_PROFESIONAL/a.jpg', 0),
--          ('PEGAR_PROFESIONAL', 'PEGAR_PROFESIONAL/b.jpg', 1);
--   update public.profesional_portafolio set orden = 1 - orden
--    where profesional_id = 'PEGAR_PROFESIONAL';                     -- → UPDATE 2
--   rollback;
--
--   -- 9. Favorito: entra un pedido visible, no uno que el Profesional no ve.
--   begin;
--   update public.pedidos set fecha_vencimiento = now() + interval '1 day'
--    where id = 'PEGAR_PEDIDO';          -- no toca estado: el guard de la 0008 lo deja
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   insert into public.pedido_favorito (profesional_id, pedido_id)
--   values ('PEGAR_PROFESIONAL', 'PEGAR_PEDIDO');                     -- → INSERT 1
--   insert into public.pedido_ignorado (profesional_id, pedido_id)
--   values ('PEGAR_PROFESIONAL', gen_random_uuid());
--   -- → ERROR 42501: el pedido no existe para quien llama
--   rollback;
--
--   -- 10. Un Buscador no puede escribir en las tablas del Profesional.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_BUSCADOR","role":"authenticated"}', true);
--   select public.es_profesional_activo();                           -- → false
--   insert into public.profesional_dispositivos (profesional_id, token_fcm, plataforma)
--   values ('PEGAR_BUSCADOR', repeat('x', 40), 'android');
--   -- → ERROR 42501 (RLS), o 23503 si la RLS lo dejara: no tiene fila de Profesional
--   rollback;
--
-- ============================================================================
-- FIN
-- ============================================================================
