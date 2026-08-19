-- ============================================================================
-- Laburito — Migración 0003
-- CU-11: la baja anonimiza en vez de borrar, y libera el correo electrónico.
-- ============================================================================
--
-- Por qué no se borra la fila: `perfiles` es el ancla de las claves foráneas de
-- pedidos, calificaciones y pagos. Un `delete` en cascada no solo se llevaría la
-- auditoría de `bajas_cuenta` —que cuelga de `perfiles`—, sino el historial de
-- contrataciones del otro lado del pedido. Un usuario no puede destruir datos
-- de otro usuario.
--
-- Por qué igual se libera el correo: si el mail queda cautivo, la persona no
-- puede volver nunca, y el derecho de supresión de la Ley 25.326 queda a medias.
-- La salida es reescribir el correo de `auth.users` a una lápida: el `id` no
-- cambia, así que ninguna FK se entera, y la dirección original queda libre.
--
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Storage: el dueño puede borrar los archivos de su carpeta.
--    Faltaba la política de DELETE, así que la baja prometía eliminar la foto
--    de perfil pero el archivo quedaba en un bucket público.
-- ----------------------------------------------------------------------------
create policy "avatares: borrado propio"
    on storage.objects for delete
    using (
        bucket_id = 'avatares'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

create policy "documentos: borrado propio"
    on storage.objects for delete
    using (
        bucket_id = 'documentos'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

-- ----------------------------------------------------------------------------
-- 2. La baja, en una sola transacción.
-- ----------------------------------------------------------------------------
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

    -- Los documentos se destruyen: sus filas apuntan a archivos que ya no están.
    delete from public.documentos_verificacion
     where profesional_id = v_id;

    -- Respaldo del borrado de archivos. El cliente los baja por la API de
    -- Storage —que es la única que elimina el objeto y no solo su fila—, pero
    -- si eso falló, después de este punto no queda nadie que pueda limpiarlos.
    delete from storage.objects
     where bucket_id in ('avatares', 'documentos')
       and (storage.foldername(name))[1] = v_id::text;

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
--   -- 0
--
-- Y la prueba que importa: registrarse de nuevo con el correo original.
-- Tiene que dejar, y tiene que crear un perfil nuevo con otro id.
-- ============================================================================
