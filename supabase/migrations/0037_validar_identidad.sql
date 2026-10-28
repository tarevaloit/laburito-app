-- ============================================================================
-- Laburito — Migración 0037
-- Sprint 6 · CU-35 Validar Identidad Profesional
-- ============================================================================
--
-- Cierra el circuito que abrió el CU-09 en el Sprint 1: hasta acá la
-- aprobación se hacía a mano con `aprobar_profesional.sql`.
--
--   profesionales_en_revision()   la lista de la Figura 3.21, con los datos del
--                                 registro y las rutas de las fotos para firmar
--   resolver_verificacion(...)    aprueba o rechaza con motivo, borra las filas
--                                 de los documentos y deja la decisión asentada
--
-- **Las fotos se destruyen al resolver** (requerimiento especial, Ley
-- 25.326). El panel borra los archivos por la API de Storage (política de la
-- 0034) y después llama a `resolver_verificacion`, que elimina las filas: el
-- orden del CU-11. Si el borrado de archivos falla, no se resuelve nada y se
-- puede reintentar; si falla la función, los archivos ya no están y volver a
-- resolver no los necesita.
--
-- De la decisión queda el resultado, el motivo y quién la tomó, pero ningún
-- dato del documento: es lo que el Profesional ve si lo rechazan.
-- ============================================================================

create table if not exists public.verificaciones_resueltas (
    id              uuid primary key default gen_random_uuid(),
    profesional_id  uuid not null references public.profesionales (perfil_id) on delete cascade,
    admin_id        uuid references public.perfiles (id) on delete set null,
    aprobada        boolean not null,
    motivo          text check (length(motivo) <= 500),
    created_at      timestamptz not null default now(),

    constraint verificaciones_motivo_rechazo_ck check (aprobada or length(trim(motivo)) >= 10)
);

comment on table public.verificaciones_resueltas is
    'CU-35. Cada aprobación o rechazo de identidad, con su motivo. No guarda datos del documento.';

create index if not exists verificaciones_profesional_fecha_idx
    on public.verificaciones_resueltas (profesional_id, created_at desc);

alter table public.verificaciones_resueltas enable row level security;

drop policy if exists "verificaciones: lectura propia" on public.verificaciones_resueltas;
create policy "verificaciones: lectura propia"
    on public.verificaciones_resueltas for select
    to authenticated
    using (profesional_id = auth.uid() or public.es_admin());


-- ============================================================================
-- 1. profesionales_en_revision
-- ============================================================================

create or replace function public.profesionales_en_revision()
returns table (
    profesional_id  uuid,
    nombre          text,
    apellido        text,
    email           text,
    telefono        text,
    dni             text,
    oficios         text,
    documentos      jsonb,
    enviado_at      timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador revisa la documentación.'
              using hint = 'sin_permiso';
    end if;

    return query
    select pr.perfil_id, p.nombre, p.apellido, p.email, p.telefono, pr.dni,
           (select string_agg(c.nombre, ', ' order by c.orden)
              from public.profesional_categorias pc
              join public.categorias_oficio c on c.id = pc.categoria_id
             where pc.profesional_id = pr.perfil_id),
           (select coalesce(jsonb_object_agg(d.tipo, d.storage_path), '{}'::jsonb)
              from public.documentos_verificacion d
             where d.profesional_id = pr.perfil_id),
           (select max(d.created_at)
              from public.documentos_verificacion d
             where d.profesional_id = pr.perfil_id)
      from public.profesionales pr
      join public.perfiles p on p.id = pr.perfil_id
     where pr.estado_verificacion = 'en_revision'
       and p.deleted_at is null
     order by 9 nulls last;
end;
$$;

comment on function public.profesionales_en_revision() is
    'CU-35. Profesionales con documentación en revisión, los más antiguos primero, con las rutas de sus fotos.';


-- ============================================================================
-- 2. resolver_verificacion
-- ============================================================================

create or replace function public.resolver_verificacion(
    p_profesional  uuid,
    p_aprobar      boolean,
    p_motivo       text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_motivo text := nullif(trim(coalesce(p_motivo, '')), '');
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador resuelve la verificación.'
              using hint = 'sin_permiso';
    end if;

    if p_aprobar is null then
        raise exception 'Indicá si se aprueba o se rechaza.'
              using hint = 'decision_requerida';
    end if;

    if not p_aprobar and (v_motivo is null or length(v_motivo) < 10) then
        raise exception 'Escribí el motivo del rechazo en al menos 10 caracteres: es lo que va a leer el Profesional.'
              using hint = 'motivo_requerido';
    end if;

    perform 1 from public.profesionales
     where perfil_id = p_profesional and estado_verificacion = 'en_revision'
       for update;
    if not found then
        raise exception 'Ese Profesional no tiene documentación en revisión.'
              using hint = 'no_en_revision';
    end if;

    insert into public.verificaciones_resueltas (profesional_id, admin_id, aprobada, motivo)
    values (p_profesional, auth.uid(), p_aprobar, v_motivo);

    -- El aviso del CU-48 (0031) lee el motivo de acá.
    perform set_config('app.motivo_verificacion', coalesce(v_motivo, ''), true);

    update public.profesionales
       set estado_verificacion = case when p_aprobar then 'aprobado' else 'rechazado' end
                                 ::public.estado_verificacion
     where perfil_id = p_profesional;

    delete from public.documentos_verificacion where profesional_id = p_profesional;
end;
$$;

comment on function public.resolver_verificacion(uuid, boolean, text) is
    'CU-35. Aprueba o rechaza la identidad, asienta la decisión y elimina las filas de los documentos. Los archivos los borra antes el panel.';


-- ============================================================================
-- 3. El aviso de rechazo lleva el motivo
-- ============================================================================

create or replace function public.notificar_verificacion()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_motivo text := nullif(current_setting('app.motivo_verificacion', true), '');
begin
    if new.estado_verificacion = 'aprobado' then
        perform public.notificar(
            new.perfil_id,
            'verificacion_aprobada',
            'Tu cuenta está verificada',
            'Ya podés desbloquear contactos y compartir tu perfil público.',
            '/home'
        );
    elsif new.estado_verificacion = 'rechazado' then
        perform public.notificar(
            new.perfil_id,
            'verificacion_rechazada',
            'Revisá tu documentación',
            coalesce('Motivo: ' || v_motivo || '. ', '')
                || 'Volvé a cargar tus documentos para que los revisemos.',
            '/verificacion'
        );
    end if;
    return new;
end;
$$;

revoke execute on function public.notificar_verificacion() from public, anon, authenticated;


revoke execute on function public.profesionales_en_revision()                    from public, anon;
revoke execute on function public.resolver_verificacion(uuid, boolean, text)     from public, anon;
grant  execute on function public.profesionales_en_revision()                    to authenticated;
grant  execute on function public.resolver_verificacion(uuid, boolean, text)     to authenticated;
