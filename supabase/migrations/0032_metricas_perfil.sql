-- ============================================================================
-- Laburito — Migración 0032
-- Sprint 5 · CU-45 Ver Métricas de Perfil
-- ============================================================================
--
-- `metricas_perfil(p_periodo)` arma la Figura 3.18 para el Profesional que
-- llama, con dos períodos (paso 3): `semana` —los últimos 7 días, una barra
-- por día— y `mes` —los últimos 28 días, una barra por semana—.
--
--   * vistas:          aperturas del perfil público (CU-27, `perfil_visitas`).
--   * contactos:       contactos que desbloqueó (CU-25).
--   * calificaciones:  reseñas recibidas (CU-28).
--   * efectividad:     de los contactos del período, qué porcentaje terminó en
--                      una calificación. Es la única prueba en el sistema de
--                      que el trabajo se hizo («de cada contacto abierto,
--                      ¿conseguís el trabajo?», Figura 3.18). `null` sin
--                      contactos: 0 % diría que le fue mal, y no hubo intento.
--
-- Los días se cortan en la hora de Buenos Aires, no en UTC: una visita a las
-- 22 h del lunes es del lunes.
--
-- Precondición del CU-45: cuenta activa y verificada (`sin_verificar`).
-- ============================================================================

create or replace function public.metricas_perfil(p_periodo text default 'semana')
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_uid        uuid := auth.uid();
    v_tz         constant text := 'America/Argentina/Buenos_Aires';
    v_hoy        date := (now() at time zone v_tz)::date;
    v_semanal    boolean := coalesce(p_periodo, 'semana') <> 'mes';
    v_desde      date;
    v_inicio     timestamptz;
    v_contactos  integer;
    v_concretados integer;
begin
    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa tiene estadísticas.'
              using hint = 'sin_permiso';
    end if;

    if not exists (select 1 from public.profesionales
                    where perfil_id = v_uid and estado_verificacion = 'aprobado') then
        raise exception 'Tus estadísticas se habilitan cuando tu documentación esté aprobada.'
              using hint = 'sin_verificar';
    end if;

    v_desde  := v_hoy - case when v_semanal then 6 else 27 end;
    v_inicio := v_desde::timestamp at time zone v_tz;

    select count(*), count(cal.id)
      into v_contactos, v_concretados
      from public.contactos_desbloqueados c
      left join public.calificaciones cal
             on cal.profesional_id = c.profesional_id and cal.pedido_id = c.pedido_id
     where c.profesional_id = v_uid and c.created_at >= v_inicio;

    return jsonb_build_object(
        'periodo', case when v_semanal then 'semana' else 'mes' end,
        'desde',   v_desde,
        'vistas', (select count(*) from public.perfil_visitas
                    where profesional_id = v_uid and created_at >= v_inicio),
        'contactos', v_contactos,
        'calificaciones', (select count(*) from public.calificaciones
                            where profesional_id = v_uid and created_at >= v_inicio),
        'efectividad', case when v_contactos = 0 then null
                            else round(100.0 * v_concretados / v_contactos)::integer end,
        'serie', (
            select jsonb_agg(jsonb_build_object('desde', b.desde, 'vistas', b.vistas)
                             order by b.desde)
              from (
                select t.desde,
                       (select count(*) from public.perfil_visitas v
                         where v.profesional_id = v_uid
                           and (v.created_at at time zone v_tz)::date >= t.desde
                           and (v.created_at at time zone v_tz)::date
                               < t.desde + case when v_semanal then 1 else 7 end) as vistas
                  from (select (v_desde + i * case when v_semanal then 1 else 7 end)::date as desde
                          from generate_series(0, case when v_semanal then 6 else 3 end) i) t
              ) b
        )
    );
end;
$$;

comment on function public.metricas_perfil(text) is
    'CU-45. Vistas, contactos, calificaciones, efectividad y serie de vistas del Profesional que llama, por semana o por mes.';

revoke execute on function public.metricas_perfil(text) from public, anon;
grant  execute on function public.metricas_perfil(text) to authenticated;
