-- ============================================================================
-- Laburito — Migración 0029
-- Sprint 5 · CU-27 Acceder a Perfil por Link
-- ============================================================================
--
-- `perfil_publico_datos(slug)` arma lo que muestra la Figura 3.6 y registra la
-- visita que cuenta el CU-45. **No la ejecuta ningún cliente**: la llama la
-- Edge Function `perfil_publico` con la clave de servicio, porque además hay
-- que firmar las fotos del bucket `portafolios`, que es privado.
--
-- Devuelve `null` —y no registra visita— si el slug no existe, la cuenta no
-- está activa (suspendida o dada de baja) o el Profesional ya no está
-- aprobado: es el 404 del flujo alterno del CU-27.
--
-- Lo que **no** sale: correo, teléfono, DNI ni la zona de cobertura, cuyo
-- centro aproxima el domicilio (0012). El contacto sigue siendo por WhatsApp,
-- fuera de la plataforma.
-- ============================================================================

create or replace function public.perfil_publico_datos(p_slug text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_id        uuid;
    v_resultado jsonb;
begin
    select pp.profesional_id into v_id
      from public.perfiles_publicos pp
      join public.perfiles p       on p.id = pp.profesional_id
      join public.profesionales pr on pr.perfil_id = pp.profesional_id
     where pp.slug = lower(trim(p_slug))
       and p.estado = 'activo'
       and p.deleted_at is null
       and pr.estado_verificacion = 'aprobado';

    if v_id is null then
        return null;
    end if;

    select jsonb_build_object(
        'slug',                  lower(trim(p_slug)),
        'nombre',                p.nombre,
        'apellido',              p.apellido,
        'avatar_url',            p.avatar_url,
        'descripcion',           pr.descripcion,
        'verificado',            true,
        'calificacion_promedio', pr.calificacion_promedio,
        'total_calificaciones',  pr.total_calificaciones,
        'oficios', coalesce((
            select jsonb_agg(c.nombre order by c.nombre)
              from public.profesional_categorias pc
              join public.categorias_oficio c on c.id = pc.categoria_id
             where pc.profesional_id = v_id), '[]'::jsonb),
        'portafolio', coalesce((
            select jsonb_agg(jsonb_build_object(
                       'storage_path', f.storage_path,
                       'descripcion',  f.descripcion) order by f.orden)
              from public.profesional_portafolio f
             where f.profesional_id = v_id), '[]'::jsonb),
        'resenas', coalesce((
            select jsonb_agg(jsonb_build_object(
                       'autor',      r.autor_nombre,
                       'puntaje',    r.puntaje,
                       'comentario', r.comentario,
                       'fecha',      r.created_at) order by r.created_at desc)
              from (select * from public.calificaciones
                     where profesional_id = v_id and not oculta
                     order by created_at desc
                     limit 20) r), '[]'::jsonb)
    )
      into v_resultado
      from public.perfiles p
      join public.profesionales pr on pr.perfil_id = p.id
     where p.id = v_id;

    insert into public.perfil_visitas (profesional_id) values (v_id);

    return v_resultado;
end;
$$;

comment on function public.perfil_publico_datos(text) is
    'CU-27. Datos públicos del Profesional por su slug, y registro de la visita (CU-45). Solo para la Edge Function perfil_publico.';

revoke execute on function public.perfil_publico_datos(text) from public, anon, authenticated;
grant  execute on function public.perfil_publico_datos(text) to service_role;
