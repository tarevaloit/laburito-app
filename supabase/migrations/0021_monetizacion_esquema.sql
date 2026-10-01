-- ============================================================================
-- Laburito — Migración 0021
-- Sprint 4 · T-10: esquema de monetización, con sus políticas RLS
-- CU-30, CU-31, CU-32, CU-33, CU-25, CU-40, CU-52, CU-53, CU-19
-- ============================================================================
--
-- Es a la billetera lo que la 0012 fue al Profesional: todas las tablas del
-- sprint en un archivo, con las políticas al lado de cada una (primer ajuste
-- del 7.2.7). Las funciones de cada caso de uso van en su propia migración.
--
-- La idea central: **el saldo es la suma de un libro de movimientos**. Cada
-- token que entra (compra, cupón) o sale (desbloqueo) es una fila de
-- `movimientos_tokens` con el saldo que dejó, y `profesionales.saldo_tokens` es
-- el total cacheado. Los dos se escriben juntos, en una sola función,
-- `aplicar_movimiento_tokens()`, que ningún cliente puede ejecutar. El guard
-- de la 0020 impide mover el saldo por fuera de ella.
--
-- Nadie escribe `pagos`, `movimientos_tokens`, `contactos_desbloqueados` ni los
-- canjes por la API: no hay políticas de INSERT, UPDATE ni DELETE. Las
-- escrituras son de funciones SECURITY DEFINER que validan antes.
-- ============================================================================


-- ============================================================================
-- 1. Paquetes de tokens — CU-31, CU-40
-- ============================================================================
--
-- El precio vive acá y **solo** acá: la Edge Function del CU-31 lo lee de esta
-- tabla al crear la preferencia, y el cliente manda únicamente el id del
-- paquete. Si el precio viajara desde la app, cualquiera se compraría 20 tokens
-- a un peso.
--
-- Pesos enteros: Mercado Pago acepta decimales, pero los precios de la Figura
-- 3.13 son redondos y el CU-40 exige «un número entero positivo».
-- ============================================================================

create table if not exists public.paquetes_tokens (
    id          uuid primary key default gen_random_uuid(),
    nombre      text not null unique check (length(trim(nombre)) between 2 and 30),
    cantidad    integer not null check (cantidad between 1 and 1000),
    precio_ars  integer not null check (precio_ars > 0),
    activo      boolean not null default true,
    orden       integer not null default 0,
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now()
);

comment on table public.paquetes_tokens is
    'CU-31 / CU-40. Packs de tokens a la venta. El precio que cobra Mercado Pago sale de acá, nunca del cliente.';

drop trigger if exists paquetes_tokens_set_updated_at on public.paquetes_tokens;
create trigger paquetes_tokens_set_updated_at
    before update on public.paquetes_tokens
    for each row execute function public.set_updated_at();

-- Semilla de la Figura 3.13.
insert into public.paquetes_tokens (nombre, cantidad, precio_ars, orden) values
    ('Bronce',  5,  4500, 1),
    ('Plata',  10,  8000, 2),
    ('Oro',    20, 14000, 3)
on conflict (nombre) do nothing;

alter table public.paquetes_tokens enable row level security;

drop policy if exists "paquetes: lectura de los activos" on public.paquetes_tokens;
create policy "paquetes: lectura de los activos"
    on public.paquetes_tokens for select
    to authenticated
    using (activo or public.es_admin());

-- Sin políticas de escritura: el precio lo cambia `actualizar_precio_paquete`
-- (CU-40), que valida el rol y el valor.


-- ============================================================================
-- 2. Pagos — CU-31, CU-32, CU-33, CU-19
-- ============================================================================
--
-- Una fila por intento de compra. Nace `pendiente` cuando se crea la
-- preferencia y la mueve solo el webhook (CU-32). Su id es el
-- `external_reference` de Mercado Pago: es lo que permite encontrar el pago
-- cuando llega la notificación, sin confiar en nada de lo que traiga.
--
-- **Cantidad y monto se copian** del paquete al crear el pago. Si el admin
-- cambia el precio (CU-40) entre que el Profesional abrió el checkout y que
-- pagó, se acredita lo que se le ofreció y se compara contra lo que se le
-- cobró, no contra el precio nuevo.
--
-- `numero_comprobante` se asigna al aprobarse, de una secuencia: es el número
-- que figura en el comprobante del CU-19. Los pendientes y rechazados no
-- consumen números.
-- ============================================================================

do $$
begin
    create type public.pago_estado as enum ('pendiente', 'aprobado', 'rechazado', 'cancelado');
exception when duplicate_object then null;
end $$;

create sequence if not exists public.pagos_numero_comprobante_seq start 1;

create table if not exists public.pagos (
    id                  uuid primary key default gen_random_uuid(),
    profesional_id      uuid not null references public.profesionales (perfil_id) on delete restrict,
    paquete_id          uuid not null references public.paquetes_tokens (id)       on delete restrict,
    paquete_nombre      text    not null,
    cantidad_tokens     integer not null check (cantidad_tokens > 0),
    monto_ars           integer not null check (monto_ars > 0),
    estado              public.pago_estado not null default 'pendiente',
    mp_preference_id    text,
    mp_payment_id       text unique,
    mp_estado_detalle   text,
    metodo_pago         text,
    numero_comprobante  bigint unique,
    aprobado_at         timestamptz,
    created_at          timestamptz not null default now(),
    updated_at          timestamptz not null default now(),

    constraint pagos_aprobado_completo_ck check (
        estado <> 'aprobado'
        or (numero_comprobante is not null and aprobado_at is not null and mp_payment_id is not null)
    )
);

comment on table public.pagos is
    'CU-31/32/33/19. Un intento de compra de tokens. El id es el external_reference de Mercado Pago. Cantidad y monto copiados del paquete al crearse.';
comment on column public.pagos.mp_estado_detalle is
    'status_detail de Mercado Pago (cc_rejected_insufficient_amount, accredited, ...). Es el motivo que se le muestra al Profesional si el pago se rechaza.';

create index if not exists pagos_profesional_idx
    on public.pagos (profesional_id, created_at desc);

drop trigger if exists pagos_set_updated_at on public.pagos;
create trigger pagos_set_updated_at
    before update on public.pagos
    for each row execute function public.set_updated_at();

alter table public.pagos enable row level security;

drop policy if exists "pagos: lectura propia" on public.pagos;
create policy "pagos: lectura propia"
    on public.pagos for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 3. Cupones — CU-52, CU-53
-- ============================================================================
--
-- El código se guarda en mayúsculas y es único sin distinguir mayúsculas:
-- «bienvenida10» y «BIENVENIDA10» son el mismo cupón. Solo letras y números
-- ASCII: es lo que alguien tipea en un teclado de teléfono sin equivocarse.
--
-- `limite_usos` nulo es ilimitado («88/∞ usos» de la Figura 3.24). El contador
-- `usos` lo incrementa el canje con la fila bloqueada, así que el check que lo
-- ata al límite no puede fallar por una carrera.
-- ============================================================================

create table if not exists public.cupones (
    id           uuid primary key default gen_random_uuid(),
    codigo       text not null check (codigo ~ '^[A-Z0-9]{4,20}$'),
    tokens       integer not null check (tokens between 1 and 1000),
    vence_at     timestamptz not null,
    limite_usos  integer check (limite_usos > 0),
    usos         integer not null default 0 check (usos >= 0),
    activo       boolean not null default true,
    creado_por   uuid references public.perfiles (id) on delete set null,
    created_at   timestamptz not null default now(),

    constraint cupones_usos_dentro_del_limite_ck
        check (limite_usos is null or usos <= limite_usos)
);

comment on table public.cupones is
    'CU-52 / CU-53. Códigos que regalan tokens. Código en mayúsculas, único; limite_usos nulo = ilimitado.';

create unique index if not exists cupones_codigo_unico
    on public.cupones (upper(codigo));

alter table public.cupones enable row level security;

drop policy if exists "cupones: lectura del admin" on public.cupones;
create policy "cupones: lectura del admin"
    on public.cupones for select
    to authenticated
    using (public.es_admin());

-- El Profesional no lista cupones: los conoce porque alguien se los pasó. Si
-- pudiera leer la tabla, los canjearía todos.


-- ============================================================================
-- 4. Libro de movimientos — CU-30, CU-25, CU-53, CU-32
-- ============================================================================
--
-- Cada fila dice cuánto entró o salió y **el saldo que quedó**. Con eso el
-- listado de «Últimos movimientos» de la Figura 3.13 no hace cuentas, y
-- cualquier desfase entre el libro y `saldo_tokens` se encuentra con una
-- consulta.
--
-- Cada tipo exige su referencia: una compra sin pago o un consumo sin pedido no
-- se pueden escribir. Y un pago acredita **una sola vez**: el índice único
-- sobre `pago_id` es la última red si el webhook llegara dos veces a la vez.
-- ============================================================================

do $$
begin
    create type public.movimiento_tipo as enum ('compra', 'consumo', 'cupon');
exception when duplicate_object then null;
end $$;

create table if not exists public.movimientos_tokens (
    id                uuid primary key default gen_random_uuid(),
    profesional_id    uuid not null references public.profesionales (perfil_id) on delete restrict,
    tipo              public.movimiento_tipo not null,
    cantidad          integer not null check (cantidad <> 0),
    saldo_resultante  integer not null check (saldo_resultante >= 0),
    descripcion       text not null,
    pago_id           uuid references public.pagos (id)   on delete restrict,
    pedido_id         uuid references public.pedidos (id) on delete restrict,
    cupon_id          uuid references public.cupones (id) on delete restrict,
    created_at        timestamptz not null default now(),

    constraint movimientos_referencia_ck check (
        (tipo = 'compra'  and cantidad > 0 and pago_id   is not null) or
        (tipo = 'consumo' and cantidad < 0 and pedido_id is not null) or
        (tipo = 'cupon'   and cantidad > 0 and cupon_id  is not null)
    )
);

comment on table public.movimientos_tokens is
    'CU-30. Libro de tokens: cada entrada y salida con el saldo que dejó. profesionales.saldo_tokens es su total; los escribe juntos aplicar_movimiento_tokens().';

create index if not exists movimientos_profesional_idx
    on public.movimientos_tokens (profesional_id, created_at desc);

create unique index if not exists movimientos_un_credito_por_pago
    on public.movimientos_tokens (pago_id) where pago_id is not null;

alter table public.movimientos_tokens enable row level security;

drop policy if exists "movimientos: lectura propia" on public.movimientos_tokens;
create policy "movimientos: lectura propia"
    on public.movimientos_tokens for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 5. Contactos desbloqueados — CU-25
-- ============================================================================
--
-- Una fila por Profesional y pedido: desbloquear dos veces el mismo contacto no
-- cobra dos veces. Es además «la lista de interesados del pedido» del paso 6
-- del CU-25: el Buscador ve cuántos hay por una función, no leyendo la tabla,
-- porque la fila dice quién es cada Profesional.
-- ============================================================================

create table if not exists public.contactos_desbloqueados (
    profesional_id  uuid not null references public.profesionales (perfil_id) on delete restrict,
    pedido_id       uuid not null references public.pedidos (id)               on delete restrict,
    movimiento_id   uuid not null references public.movimientos_tokens (id)   on delete restrict,
    created_at      timestamptz not null default now(),
    primary key (profesional_id, pedido_id)
);

comment on table public.contactos_desbloqueados is
    'CU-25. Qué Profesional pagó un token por el contacto de qué pedido. Desbloquear de nuevo no cobra.';

create index if not exists contactos_pedido_idx
    on public.contactos_desbloqueados (pedido_id);

alter table public.contactos_desbloqueados enable row level security;

drop policy if exists "contactos: lectura propia" on public.contactos_desbloqueados;
create policy "contactos: lectura propia"
    on public.contactos_desbloqueados for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 6. Canjes e intentos de cupón — CU-53
-- ============================================================================

create table if not exists public.cupon_canjes (
    cupon_id        uuid not null references public.cupones (id)                on delete restrict,
    profesional_id  uuid not null references public.profesionales (perfil_id) on delete restrict,
    movimiento_id   uuid not null references public.movimientos_tokens (id)   on delete restrict,
    created_at      timestamptz not null default now(),
    primary key (cupon_id, profesional_id)
);

comment on table public.cupon_canjes is
    'CU-53. Un cupón se canjea una vez por Profesional.';

alter table public.cupon_canjes enable row level security;

drop policy if exists "canjes: lectura propia" on public.cupon_canjes;
create policy "canjes: lectura propia"
    on public.cupon_canjes for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());

-- Los intentos fallidos alimentan el bloqueo por fuerza bruta que pide el
-- requerimiento especial del CU-53. Sin políticas: solo los lee y escribe la
-- función del canje.
create table if not exists public.cupon_intentos (
    id              bigint generated always as identity primary key,
    profesional_id  uuid not null references public.profesionales (perfil_id) on delete cascade,
    codigo          text not null,
    exitoso         boolean not null,
    created_at      timestamptz not null default now()
);

comment on table public.cupon_intentos is
    'CU-53. Intentos de canje, para bloquear la fuerza bruta. Solo la función del canje los toca.';

create index if not exists cupon_intentos_profesional_idx
    on public.cupon_intentos (profesional_id, created_at desc);

alter table public.cupon_intentos enable row level security;


-- ============================================================================
-- 7. La única función que mueve el saldo
-- ============================================================================
--
-- Bloquea la fila del Profesional **antes** de leer el saldo: dos desbloqueos
-- simultáneos con un token de saldo no pueden pasar los dos (el mismo patrón
-- que el tope de fotos de la 0005 y el del portafolio de la 0012).
--
-- Abre la compuerta de la 0020 local a la transacción y la cierra después del
-- UPDATE, como las funciones de la 0008.
--
-- Sin saldo suficiente, el mensaje es para el usuario y el hint para la app:
-- el CU-25 lo usa para ofrecer «Comprar tokens».
--
-- No la puede ejecutar ningún cliente: la llaman las funciones de cada caso de
-- uso, que son SECURITY DEFINER y validan quién pide qué. Revocada a `public`,
-- `anon` y `authenticated` por separado (decisión del 16/09: el revoke a
-- `public` solo no alcanza en Supabase).
-- ============================================================================

create or replace function public.aplicar_movimiento_tokens(
    p_profesional  uuid,
    p_tipo         public.movimiento_tipo,
    p_cantidad     integer,
    p_descripcion  text,
    p_pago         uuid default null,
    p_pedido       uuid default null,
    p_cupon        uuid default null
)
returns public.movimientos_tokens
language plpgsql
security definer
set search_path = public
as $$
declare
    v_saldo       integer;
    v_nuevo       integer;
    v_movimiento  public.movimientos_tokens;
begin
    select saldo_tokens into v_saldo
      from public.profesionales
     where perfil_id = p_profesional
       for update;

    if not found then
        raise exception 'No encontramos la cuenta del Profesional.'
              using hint = 'sin_permiso';
    end if;

    v_nuevo := v_saldo + p_cantidad;

    if v_nuevo < 0 then
        raise exception 'No te alcanzan los tokens. Cargá más desde tu billetera.'
              using hint = 'saldo_insuficiente';
    end if;

    perform set_config('app.movimiento_tokens', 'on', true);
    update public.profesionales
       set saldo_tokens = v_nuevo
     where perfil_id = p_profesional;
    perform set_config('app.movimiento_tokens', 'off', true);

    insert into public.movimientos_tokens (
        profesional_id, tipo, cantidad, saldo_resultante, descripcion,
        pago_id, pedido_id, cupon_id
    ) values (
        p_profesional, p_tipo, p_cantidad, v_nuevo, p_descripcion,
        p_pago, p_pedido, p_cupon
    )
    returning * into v_movimiento;

    return v_movimiento;
end;
$$;

comment on function public.aplicar_movimiento_tokens(uuid, public.movimiento_tipo, integer, text, uuid, uuid, uuid) is
    'T-10. Único camino para mover tokens: bloquea al Profesional, escribe saldo y movimiento juntos. Ningún cliente la ejecuta.';

revoke execute on function public.aplicar_movimiento_tokens(uuid, public.movimiento_tipo, integer, text, uuid, uuid, uuid)
    from public, anon, authenticated;


-- ============================================================================
-- 8. Guion de aceptación
-- ============================================================================
--
-- supabase/scripts/verificar_0021.sql: RLS activa en las siete tablas; la
-- semilla de tres paquetes; un Profesional lee sus pagos y movimientos y no los
-- de otro; ningún `authenticated` puede insertar en pagos, movimientos,
-- contactos ni canjes; `aplicar_movimiento_tokens` no figura en el `proacl` de
-- anon ni authenticated; ejecutada como dueña acredita, deja el saldo y el
-- movimiento coincidiendo, y un débito mayor al saldo da `saldo_insuficiente`.
-- ============================================================================
