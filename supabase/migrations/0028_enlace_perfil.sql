-- ============================================================================
-- Laburito — Migración 0028
-- Sprint 5 · CU-26 Compartir Perfil Público (vía link)
-- ============================================================================
--
-- `obtener_enlace_perfil()` devuelve el slug del Profesional que llama y lo
-- crea la primera vez. La app arma la URL con la raíz de la Web (`WEB_URL`):
-- la base no sabe dónde está publicada.
--
-- Reglas, en orden:
--   1. Quien llama es un Profesional. Si la cuenta está suspendida, el flujo
--      alterno del CU-26: `cuenta_suspendida`, y la app desactiva el botón.
--   2. La cuenta está activa y **aprobada**: el perfil público muestra «Cuenta
--      verificada» (Figura 3.6) y es la herramienta de confianza del CU-27. Un
--      perfil sin revisar no se comparte.
--   3. Si ya tiene slug, se devuelve el mismo: un enlace que circula por
--      WhatsApp no se rompe.
--
-- El slug es `nombre-apellido` sin tildes, más un sufijo aleatorio de seis
-- caracteres: legible y no enumerable. El sufijo sale de `gen_random_bytes`.
-- ============================================================================

create or replace function public.slug_de_nombre(p_nombre text, p_apellido text)
returns text
language sql
immutable
set search_path = public
as $$
    select coalesce(nullif(
        trim(both '-' from regexp_replace(
            translate(lower(coalesce(p_nombre, '') || ' ' || coalesce(p_apellido, '')),
                      'áàäâéèëêíìïîóòöôúùüûñç', 'aaaaeeeeiiiioooouuuunc'),
            '[^a-z0-9]+', '-', 'g')),
        ''), 'profesional');
$$;

comment on function public.slug_de_nombre(text, text) is
    'CU-26. «Marcelo Gómez» → «marcelo-gomez». Sin tildes ni símbolos.';


create or replace function public.obtener_enlace_perfil()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
    v_uid    uuid := auth.uid();
    v_perfil public.perfiles;
    v_estado public.estado_verificacion;
    v_slug   text;
begin
    select * into v_perfil from public.perfiles where id = v_uid;

    if v_perfil.id is null or v_perfil.tipo <> 'profesional' then
        raise exception 'Solo un Profesional tiene perfil público.'
              using hint = 'sin_permiso';
    end if;

    if v_perfil.estado = 'suspendido' then
        raise exception 'Tu cuenta está inhabilitada: no podés compartir tu perfil.'
              using hint = 'cuenta_suspendida';
    end if;

    if v_perfil.estado <> 'activo' or v_perfil.deleted_at is not null then
        raise exception 'Tu cuenta no está activa.'
              using hint = 'sin_permiso';
    end if;

    select estado_verificacion into v_estado
      from public.profesionales where perfil_id = v_uid;

    if v_estado is distinct from 'aprobado' then
        raise exception 'Tu perfil se puede compartir cuando tu documentación esté aprobada.'
              using hint = 'sin_verificar';
    end if;

    select slug into v_slug from public.perfiles_publicos where profesional_id = v_uid;
    if v_slug is not null then
        return v_slug;
    end if;

    -- Seis caracteres hexadecimales dan 16 millones de sufijos por nombre:
    -- el reintento es por prolijidad, no porque se espere un choque.
    for i in 1..5 loop
        v_slug := left(public.slug_de_nombre(v_perfil.nombre, v_perfil.apellido), 70)
                  || '-' || encode(extensions.gen_random_bytes(3), 'hex');
        begin
            insert into public.perfiles_publicos (profesional_id, slug)
            values (v_uid, v_slug);
            return v_slug;
        exception when unique_violation then
            -- Si chocó la clave primaria, otro llamado simultáneo ya lo creó.
            select slug into v_slug from public.perfiles_publicos where profesional_id = v_uid;
            if v_slug is not null then
                return v_slug;
            end if;
        end;
    end loop;

    raise exception 'No pudimos generar tu enlace. Probá de nuevo.';
end;
$$;

comment on function public.obtener_enlace_perfil() is
    'CU-26. Slug del perfil público del Profesional que llama; lo crea la primera vez. Exige cuenta activa y aprobada.';

revoke execute on function public.obtener_enlace_perfil() from public, anon;
grant  execute on function public.obtener_enlace_perfil() to authenticated;
