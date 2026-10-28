-- ============================================================================
-- Laburito — Migración 0036
-- Sprint 6 · CU-38 Consultar Estadísticas (Dashboard)
-- ============================================================================
--
-- Una sola función devuelve todo el tablero de la Figura 3.20 para el rango
-- elegido: las cuatro tarjetas con el valor del período anterior de la misma
-- duración (para el «vs. período anterior»), las altas de usuarios de los
-- últimos doce meses y los ingresos por pack.
--
-- Requerimiento especial: «consultas optimizadas para no ralentizar el
-- sistema». Es una sola llamada con agregados sobre columnas de fecha, sin
-- traer filas al cliente. Los días se cuentan en hora de Argentina.
--
-- Flujo alterno 1.1: un rango anterior al lanzamiento devuelve ceros, no un
-- error (todos los agregados van con `coalesce`).
-- ============================================================================

create or replace function public.dashboard_admin(p_desde date, p_hasta date)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
    v_tz        constant text := 'America/Argentina/Buenos_Aires';
    v_ini       timestamptz;
    v_fin       timestamptz;
    v_ant_ini   timestamptz;
    v_resultado jsonb;
begin
    if not public.es_admin() then
        raise exception 'Solo un administrador ve las estadísticas.'
              using hint = 'sin_permiso';
    end if;

    if p_desde is null or p_hasta is null or p_desde > p_hasta then
        raise exception 'Elegí un rango de fechas válido.'
              using hint = 'rango_invalido';
    end if;

    if p_hasta - p_desde > 731 then
        raise exception 'El rango puede abarcar hasta dos años.'
              using hint = 'rango_invalido';
    end if;

    v_ini     := p_desde::timestamp at time zone v_tz;
    v_fin     := (p_hasta + 1)::timestamp at time zone v_tz;
    v_ant_ini := v_ini - (v_fin - v_ini);

    with
    pedidos_k as (
        select count(*) filter (where fecha_publicacion >= v_ini     and fecha_publicacion < v_fin) as actual,
               count(*) filter (where fecha_publicacion >= v_ant_ini and fecha_publicacion < v_ini) as anterior
          from public.pedidos
         where fecha_publicacion >= v_ant_ini and fecha_publicacion < v_fin
    ),
    ingresos_k as (
        select coalesce(sum(monto_ars) filter (where aprobado_at >= v_ini     and aprobado_at < v_fin), 0) as actual,
               coalesce(sum(monto_ars) filter (where aprobado_at >= v_ant_ini and aprobado_at < v_ini), 0) as anterior,
               coalesce(sum(cantidad_tokens) filter (where aprobado_at >= v_ini and aprobado_at < v_fin), 0) as tokens
          from public.pagos
         where estado = 'aprobado' and aprobado_at >= v_ant_ini and aprobado_at < v_fin
    ),
    altas_k as (
        select count(*) filter (where tipo = 'profesional' and created_at >= v_ini     and created_at < v_fin) as profesionales,
               count(*) filter (where tipo = 'profesional' and created_at >= v_ant_ini and created_at < v_ini) as profesionales_ant,
               count(*) filter (where tipo = 'buscador'    and created_at >= v_ini     and created_at < v_fin) as buscadores,
               count(*) filter (where tipo = 'buscador'    and created_at >= v_ant_ini and created_at < v_ini) as buscadores_ant
          from public.perfiles
         where tipo in ('profesional', 'buscador') and created_at >= v_ant_ini and created_at < v_fin
    ),
    denuncias_k as (
        select count(*) filter (where created_at >= v_ini     and created_at < v_fin) as actual,
               count(*) filter (where created_at >= v_ant_ini and created_at < v_ini) as anterior,
               (select count(*) from public.denuncias where estado in ('pendiente', 'en_revision')) as abiertas
          from public.denuncias
         where created_at >= v_ant_ini and created_at < v_fin
    ),
    meses as (
        select generate_series(
                   date_trunc('month', p_hasta::timestamp) - interval '11 months',
                   date_trunc('month', p_hasta::timestamp),
                   interval '1 month'
               )::date as mes
    ),
    altas_mes as (
        select m.mes,
               count(p.id) filter (where p.tipo = 'buscador')    as buscadores,
               count(p.id) filter (where p.tipo = 'profesional') as profesionales
          from meses m
          left join public.perfiles p
            on p.tipo in ('buscador', 'profesional')
           and (p.created_at at time zone v_tz) >= m.mes
           and (p.created_at at time zone v_tz) <  m.mes + interval '1 month'
         group by m.mes
    ),
    por_pack as (
        select paquete_nombre as pack, count(*) as compras, sum(monto_ars) as monto
          from public.pagos
         where estado = 'aprobado' and aprobado_at >= v_ini and aprobado_at < v_fin
         group by paquete_nombre
    )
    select jsonb_build_object(
        'desde', p_desde,
        'hasta', p_hasta,
        'pedidos_publicados',   jsonb_build_object('actual', pk.actual, 'anterior', pk.anterior),
        'ingresos_ars',         jsonb_build_object('actual', ik.actual, 'anterior', ik.anterior),
        'tokens_vendidos',      ik.tokens,
        'altas_profesionales',  jsonb_build_object('actual', ak.profesionales, 'anterior', ak.profesionales_ant),
        'altas_buscadores',     jsonb_build_object('actual', ak.buscadores,    'anterior', ak.buscadores_ant),
        'denuncias_recibidas',  jsonb_build_object('actual', dk.actual, 'anterior', dk.anterior),
        'denuncias_abiertas',   dk.abiertas,
        'altas_por_mes', (
            select coalesce(jsonb_agg(jsonb_build_object(
                       'mes', to_char(mes, 'YYYY-MM'),
                       'buscadores', buscadores,
                       'profesionales', profesionales) order by mes), '[]'::jsonb)
              from altas_mes
        ),
        'ingresos_por_pack', (
            select coalesce(jsonb_agg(jsonb_build_object(
                       'pack', pack, 'compras', compras, 'monto', monto) order by monto desc), '[]'::jsonb)
              from por_pack
        )
    )
      into v_resultado
      from pedidos_k pk, ingresos_k ik, altas_k ak, denuncias_k dk;

    return v_resultado;
end;
$$;

comment on function public.dashboard_admin(date, date) is
    'CU-38. Tarjetas del período con su comparación, altas de los últimos doce meses e ingresos por pack, en una sola llamada.';

create index if not exists perfiles_alta_idx
    on public.perfiles (created_at);
create index if not exists pedidos_publicacion_idx
    on public.pedidos (fecha_publicacion);
create index if not exists pagos_aprobado_idx
    on public.pagos (aprobado_at) where estado = 'aprobado';

revoke execute on function public.dashboard_admin(date, date) from public, anon;
grant  execute on function public.dashboard_admin(date, date) to authenticated;
