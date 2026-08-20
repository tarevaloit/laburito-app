-- ============================================================================
-- Laburito — Migración 0004
-- CU-11: la baja ya no borra en `storage.objects` por SQL.
-- ============================================================================
--
-- Síntoma: al dar de baja, la RPC fallaba entera con
--
--     42501 · Direct deletion from storage tables is not allowed.
--             Use the Storage API instead.
--
-- Supabase bloquea el DML directo sobre las tablas de Storage. La 0003 lo hacía
-- igual, como respaldo del borrado que el cliente ya hace por la API. Ese
-- respaldo no solo no funciona: al abortar la transacción se llevaba puesta
-- toda la baja, que es lo único que el usuario pidió.
--
-- Cómo queda el borrado de archivos:
--
--   * Lo hace el cliente, con la API de Storage, **antes** de llamar a la RPC.
--     Es el único camino que elimina el objeto y no solo su fila.
--   * Si esa eliminación falla, el cliente **no llama a la RPC**. Es a
--     propósito: después del anonimizado la persona pierde los permisos sobre
--     su propia carpeta, así que un fallo posterior dejaría el DNI y la selfie
--     huérfanos, sin nadie que pueda borrarlos. Mejor cortar y reintentar.
--   * Las políticas de DELETE de la 0003 siguen vigentes: son las que le
--     permiten al dueño borrar su carpeta por la API.
--
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
           disponible  = false,
           ubicacion   = null
     where perfil_id = v_id;

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
-- Prueba de aceptación (SQL Editor, después de dar de baja una cuenta):
--
--   select id, nombre, apellido, email, telefono, estado
--     from public.perfiles where id = 'PEGAR_UUID';
--   -- nombre/apellido anonimizados, email de lápida, teléfono nulo
--
--   select email, raw_user_meta_data from auth.users where id = 'PEGAR_UUID';
--   -- email de lápida y metadata vacío
--
--   select count(*) from storage.objects
--    where (storage.foldername(name))[1] = 'PEGAR_UUID';
--   -- 0, borrados por el cliente vía API de Storage
--
-- Y la prueba que importa: registrarse de nuevo con el correo original.
-- Tiene que dejar, y tiene que crear un perfil nuevo con otro id.
-- ============================================================================
