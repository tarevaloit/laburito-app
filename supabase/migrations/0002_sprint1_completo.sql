-- ============================================================================
-- Laburito — Migración 0002 (completa el Sprint 1)
-- CU-02 (categorías al registrarse), CU-09 (recarga de documentos), CU-11 (baja)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. CU-02: el alta del Profesional trae sus categorías en el metadata.
--    Se procesan acá porque durante el signUp todavía no hay sesión y las
--    políticas de `profesional_categorias` exigen auth.uid().
-- ----------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_tipo  public.tipo_perfil;
    v_slug  text;
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
        insert into public.profesionales (perfil_id, dni, descripcion)
        values (
            new.id,
            new.raw_user_meta_data ->> 'dni',
            new.raw_user_meta_data ->> 'descripcion'
        );

        if new.raw_user_meta_data ? 'categorias' then
            for v_slug in
                select jsonb_array_elements_text(new.raw_user_meta_data -> 'categorias')
            loop
                insert into public.profesional_categorias (profesional_id, categoria_id)
                select new.id, c.id
                  from public.categorias_oficio c
                 where c.slug = v_slug
                on conflict do nothing;
            end loop;
        end if;
    end if;

    return new;
end;
$$;

-- ----------------------------------------------------------------------------
-- 2. CU-09: permitir reemplazar un documento ya cargado.
-- ----------------------------------------------------------------------------
create policy "profesional propio: reemplazar documentos"
    on public.documentos_verificacion for update
    using (auth.uid() = profesional_id)
    with check (auth.uid() = profesional_id);

create policy "documentos: reemplazo propio en storage"
    on storage.objects for update
    using (
        bucket_id = 'documentos'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

-- ----------------------------------------------------------------------------
-- 3. CU-11: baja lógica de la cuenta, en una sola transacción.
--    Se anonimiza el teléfono y se conserva el perfil por trazabilidad.
-- ----------------------------------------------------------------------------
create or replace function public.dar_de_baja_cuenta(p_motivo text default null)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_id uuid := auth.uid();
begin
    if v_id is null then
        raise exception 'No hay sesión activa';
    end if;

    update public.perfiles
       set estado     = 'baja',
           deleted_at = now(),
           telefono   = null,
           avatar_url = null
     where id = v_id
       and estado <> 'baja';

    if not found then
        raise exception 'La cuenta ya se encuentra dada de baja';
    end if;

    update public.profesionales
       set disponible = false
     where perfil_id = v_id;

    insert into public.bajas_cuenta (perfil_id, motivo)
    values (v_id, nullif(trim(coalesce(p_motivo, '')), ''));
end;
$$;

revoke all on function public.dar_de_baja_cuenta(text) from public;
grant execute on function public.dar_de_baja_cuenta(text) to authenticated;

-- ----------------------------------------------------------------------------
-- 4. Los perfiles dados de baja no pueden seguir editándose.
-- ----------------------------------------------------------------------------
drop policy if exists "profesional propio: actualización" on public.profesionales;

create policy "profesional propio: actualización"
    on public.profesionales for update
    using (
        auth.uid() = perfil_id
        and exists (
            select 1 from public.perfiles p
             where p.id = perfil_id and p.deleted_at is null
        )
    )
    with check (auth.uid() = perfil_id);
