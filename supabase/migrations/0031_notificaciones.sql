-- ============================================================================
-- Laburito — Migración 0031
-- Sprint 5 · CU-48 Ver Notificaciones de Actividad
-- ============================================================================
--
-- Los avisos del centro de notificaciones los escriben **disparadores**, no
-- la app: si los escribiera el cliente, cualquiera podría inventarse un «se
-- acreditaron 100 tokens». Todos pasan por `notificar()`, que ningún cliente
-- puede ejecutar.
--
--   Evento                                   Para              Lleva a
--   --------------------------------------   ---------------   ----------------------
--   Un Profesional desbloquea el contacto    Buscador          /pedidos/<id>
--   (CU-25: «nuevos interesados», 7.4.3)
--   Llega una calificación (CU-28)           Profesional       /profesional/contactos
--   Se aprueba o rechaza la documentación    Profesional       /home o /verificacion
--   Se acredita un pago (CU-32)              Profesional       /profesional/billetera
--   Entra una denuncia (CU-41)               Administradores   /admin/denuncias
--
-- Leer, marcar leídas y «Limpiar todo» van por PostgREST con las políticas de
-- la 0027: no hacen falta funciones.
-- ============================================================================


create or replace function public.notificar(
    p_destinatario uuid,
    p_tipo         public.notificacion_tipo,
    p_titulo       text,
    p_cuerpo       text default null,
    p_ruta         text default null
)
returns void
language sql
security definer
set search_path = public
as $$
    insert into public.notificaciones (destinatario_id, tipo, titulo, cuerpo, ruta)
    values (p_destinatario, p_tipo, left(p_titulo, 120), left(p_cuerpo, 500), p_ruta);
$$;

comment on function public.notificar(uuid, public.notificacion_tipo, text, text, text) is
    'CU-48. Escribe un aviso. Solo la llaman los disparadores de esta migración.';

revoke execute on function public.notificar(uuid, public.notificacion_tipo, text, text, text)
    from public, anon, authenticated;


-- ============================================================================
-- 1. Nuevo interesado — al Buscador
-- ============================================================================
--
-- No dice quién: el CU-25 decidió que el Buscador no ve la identidad de los
-- interesados en la app. Le va a escribir por WhatsApp.
-- ============================================================================

create or replace function public.notificar_nuevo_interesado()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_pedido public.pedidos;
begin
    select * into v_pedido from public.pedidos where id = new.pedido_id;

    perform public.notificar(
        v_pedido.buscador_id,
        'nuevo_interesado',
        'Un profesional quiere hacer tu trabajo',
        'Pidió tu contacto por «' || v_pedido.titulo || '». Te va a escribir por WhatsApp.',
        '/pedidos/' || v_pedido.id
    );
    return new;
end;
$$;

drop trigger if exists contactos_notificar on public.contactos_desbloqueados;
create trigger contactos_notificar
    after insert on public.contactos_desbloqueados
    for each row execute function public.notificar_nuevo_interesado();


-- ============================================================================
-- 2. Calificación recibida — al Profesional
-- ============================================================================

create or replace function public.notificar_calificacion()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    perform public.notificar(
        new.profesional_id,
        'calificacion_recibida',
        new.autor_nombre || ' te calificó con ' || new.puntaje
            || case when new.puntaje = 1 then ' estrella' else ' estrellas' end,
        coalesce('«' || new.comentario || '»', 'Sin comentario.'),
        '/profesional/contactos'
    );
    return new;
end;
$$;

drop trigger if exists calificaciones_notificar on public.calificaciones;
create trigger calificaciones_notificar
    after insert on public.calificaciones
    for each row execute function public.notificar_calificacion();


-- ============================================================================
-- 3. Verificación resuelta — al Profesional
-- ============================================================================

create or replace function public.notificar_verificacion()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
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
            'No pudimos validar tus documentos. Volvé a cargarlos para que los revisemos.',
            '/verificacion'
        );
    end if;
    return new;
end;
$$;

drop trigger if exists profesionales_notificar_verificacion on public.profesionales;
create trigger profesionales_notificar_verificacion
    after update of estado_verificacion on public.profesionales
    for each row
    when (old.estado_verificacion is distinct from new.estado_verificacion)
    execute function public.notificar_verificacion();


-- ============================================================================
-- 4. Pago acreditado — al Profesional
-- ============================================================================
--
-- Sobre `pagos` y no sobre el libro de movimientos: un cupón (CU-53) también
-- acredita, pero lo canjea el propio Profesional y ya lo ve en la pantalla.
-- ============================================================================

create or replace function public.notificar_pago()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    perform public.notificar(
        new.profesional_id,
        'pago_acreditado',
        'Se acreditaron ' || new.cantidad_tokens || ' tokens',
        'Tu pago del pack ' || new.paquete_nombre || ' fue aprobado.',
        '/profesional/billetera'
    );
    return new;
end;
$$;

drop trigger if exists pagos_notificar on public.pagos;
create trigger pagos_notificar
    after update of estado on public.pagos
    for each row
    when (old.estado is distinct from new.estado and new.estado = 'aprobado')
    execute function public.notificar_pago();


-- ============================================================================
-- 5. Denuncia nueva — a cada administrador activo (CU-41)
-- ============================================================================

create or replace function public.notificar_denuncia()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_admin uuid;
begin
    for v_admin in
        select id from public.perfiles
         where tipo = 'administrador' and estado = 'activo' and deleted_at is null
    loop
        perform public.notificar(
            v_admin,
            'denuncia_recibida',
            'Nueva denuncia para revisar',
            'Motivo: ' || replace(new.motivo::text, '_', ' ') || '.',
            '/admin/denuncias'
        );
    end loop;
    return new;
end;
$$;

drop trigger if exists denuncias_notificar on public.denuncias;
create trigger denuncias_notificar
    after insert on public.denuncias
    for each row execute function public.notificar_denuncia();


revoke execute on function public.notificar_nuevo_interesado() from public, anon, authenticated;
revoke execute on function public.notificar_calificacion()     from public, anon, authenticated;
revoke execute on function public.notificar_verificacion()     from public, anon, authenticated;
revoke execute on function public.notificar_pago()             from public, anon, authenticated;
revoke execute on function public.notificar_denuncia()         from public, anon, authenticated;


-- ============================================================================
-- 6. Guion de aceptación
-- ============================================================================
--
-- supabase/scripts/verificar_0031.sql: cada evento deja un aviso al
-- destinatario correcto con su ruta; nadie más lo ve; ningún cliente ejecuta
-- `notificar`.
-- ============================================================================
