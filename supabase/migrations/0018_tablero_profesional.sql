-- ============================================================================
-- Laburito — Migración 0018
-- Sprint 3 · CU-43 Explorar Tablero · CU-22 Ver Detalle de Pedido
-- ============================================================================
--
-- Lo que el Profesional ve de un pedido ajeno sale de `pedidos_publicos`
-- (0005/0007): sin `referencia_ubicacion` —piso y departamento— y con la
-- coordenada redondeada a tres decimales, unos cien metros. Estas dos
-- funciones no abren nada nuevo: leen esa vista, que corre con
-- `security_invoker`, y le agregan tres cosas que el cliente no puede calcular
-- solo sin traerse la tabla entera:
--
--   1. la distancia a su zona de cobertura, que es el orden del tablero;
--   2. si el pedido está guardado (CU-24) y si está ignorado (CU-23);
--   3. la portada, para no pedir las fotos de a un pedido por vez.
--
-- **Son `security invoker` a propósito.** Todo lo que leen ya se lo permite la
-- RLS a quien llama: los pedidos publicados vigentes (0006), sus propias
-- categorías, su zona (0012) y sus marcas. Nada de esto necesita
-- `SECURITY DEFINER`, y no ponerlo es lo que garantiza que un error en la
-- función no se convierta en una filtración.
--
-- La distancia se calcula contra la coordenada **redondeada** de la vista, no
-- contra la exacta: el tablero es para ordenar, no para llegar a la puerta, y
-- el error de cien metros no cambia el orden de una lista. El emparejamiento
-- del CU-21, que sí decide a quién se le avisa, usa la exacta (0016). Además
-- se redondea el resultado a cien metros: una distancia exacta a varios
-- centros conocidos permite triangular la casa.
--
-- Es idempotente.
-- ============================================================================


-- ============================================================================
-- 1. tablero_pedidos — CU-43
-- ============================================================================

create or replace function public.tablero_pedidos(
    p_limite            integer default 20,
    p_desplazamiento    integer default 0,
    p_solo_mis_oficios  boolean default true,
    p_solo_guardados    boolean default false
)
returns table (
    id                    uuid,
    titulo                text,
    descripcion           text,
    urgencia              public.pedido_urgencia,
    categoria_id          uuid,
    categoria_nombre      text,
    lat                   double precision,
    lng                   double precision,
    direccion_texto       text,
    presupuesto_estimado  numeric,
    fecha_publicacion     timestamptz,
    fecha_vencimiento     timestamptz,
    cantidad_fotos        bigint,
    distancia_m           double precision,
    guardado              boolean,
    portada               text
)
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_centro extensions.geography;
begin
    if not public.es_profesional_activo() then
        raise exception 'El tablero es para cuentas Profesional'
              using hint = 'sin_permiso';
    end if;

    if p_limite is null or p_limite not between 1 and 50 then
        raise exception 'La página del tablero va de 1 a 50 pedidos'
              using hint = 'limite_invalido';
    end if;

    -- Puede no haber zona todavía: el tablero igual sirve, sin distancia y
    -- ordenado por fecha. La pantalla es la que invita a configurarla.
    select z.centro into v_centro
      from public.profesional_zona_cobertura z
     where z.profesional_id = auth.uid();

    return query
    select v.id,
           v.titulo,
           v.descripcion,
           v.urgencia,
           v.categoria_id,
           v.categoria_nombre,
           v.lat::double precision,
           v.lng::double precision,
           v.direccion_texto,
           v.presupuesto_estimado,
           v.fecha_publicacion,
           v.fecha_vencimiento,
           v.cantidad_fotos,
           case
               when v_centro is null then null
               else round(
                        extensions.st_distance(
                            v_centro,
                            public.punto(v.lat::double precision,
                                         v.lng::double precision)
                        )::numeric / 100
                    )::double precision * 100
           end as distancia_m,
           exists (
               select 1 from public.pedido_favorito f
                where f.profesional_id = auth.uid() and f.pedido_id = v.id
           ) as guardado,
           (
               select f.storage_path
                 from public.pedido_fotos f
                where f.pedido_id = v.id
                order by f.orden
                limit 1
           ) as portada
      from public.pedidos_publicos v
     where not exists (
               select 1 from public.pedido_ignorado i
                where i.profesional_id = auth.uid() and i.pedido_id = v.id
           )
       and (
               not p_solo_mis_oficios
               or exists (
                   select 1 from public.profesional_categorias pc
                    where pc.profesional_id = auth.uid()
                      and pc.categoria_id   = v.categoria_id
               )
           )
       and (
               not p_solo_guardados
               or exists (
                   select 1 from public.pedido_favorito f
                    where f.profesional_id = auth.uid() and f.pedido_id = v.id
               )
           )
     order by distancia_m nulls last, v.fecha_publicacion desc
     limit p_limite offset greatest(coalesce(p_desplazamiento, 0), 0);
end;
$$;

comment on function public.tablero_pedidos(integer, integer, boolean, boolean) is
    'CU-43. Pedidos vigentes para el tablero del Profesional, ordenados por distancia a su zona. Lee pedidos_publicos: sin referencia y con la coordenada redondeada. Descarta los ignorados (CU-23) y marca los guardados (CU-24).';

revoke all on function public.tablero_pedidos(integer, integer, boolean, boolean)
    from public, anon;
grant execute on function public.tablero_pedidos(integer, integer, boolean, boolean)
    to authenticated;


-- ============================================================================
-- 2. pedido_publico — CU-22
-- ============================================================================
--
-- El mismo pedido, uno solo, con todas sus fotos en vez de la portada. Es lo
-- que dibuja la pantalla de detalle del lado del Profesional: las mismas
-- secciones que ve el Buscador, sin la barra de acciones del dueño y con la
-- ubicación aproximada.
--
-- Un pedido que no está publicado y vigente devuelve cero filas, no un error:
-- desde el tablero se puede tocar un pedido que se cerró hace un segundo, y
-- eso no es una falla, es la pantalla diciendo «este pedido ya no está».
-- ============================================================================

create or replace function public.pedido_publico(p_pedido_id uuid)
returns table (
    id                    uuid,
    titulo                text,
    descripcion           text,
    urgencia              public.pedido_urgencia,
    categoria_id          uuid,
    categoria_nombre      text,
    lat                   double precision,
    lng                   double precision,
    direccion_texto       text,
    presupuesto_estimado  numeric,
    fecha_publicacion     timestamptz,
    fecha_vencimiento     timestamptz,
    cantidad_fotos        bigint,
    distancia_m           double precision,
    guardado              boolean,
    ignorado              boolean,
    fotos                 text[]
)
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_centro extensions.geography;
begin
    if not public.es_profesional_activo() then
        raise exception 'El detalle del tablero es para cuentas Profesional'
              using hint = 'sin_permiso';
    end if;

    select z.centro into v_centro
      from public.profesional_zona_cobertura z
     where z.profesional_id = auth.uid();

    return query
    select v.id,
           v.titulo,
           v.descripcion,
           v.urgencia,
           v.categoria_id,
           v.categoria_nombre,
           v.lat::double precision,
           v.lng::double precision,
           v.direccion_texto,
           v.presupuesto_estimado,
           v.fecha_publicacion,
           v.fecha_vencimiento,
           v.cantidad_fotos,
           case
               when v_centro is null then null
               else round(
                        extensions.st_distance(
                            v_centro,
                            public.punto(v.lat::double precision,
                                         v.lng::double precision)
                        )::numeric / 100
                    )::double precision * 100
           end as distancia_m,
           exists (
               select 1 from public.pedido_favorito f
                where f.profesional_id = auth.uid() and f.pedido_id = v.id
           ) as guardado,
           exists (
               select 1 from public.pedido_ignorado i
                where i.profesional_id = auth.uid() and i.pedido_id = v.id
           ) as ignorado,
           coalesce(
               (
                   select array_agg(f.storage_path order by f.orden)
                     from public.pedido_fotos f
                    where f.pedido_id = v.id
               ),
               '{}'
           ) as fotos
      from public.pedidos_publicos v
     where v.id = p_pedido_id;
end;
$$;

comment on function public.pedido_publico(uuid) is
    'CU-22. Un pedido vigente como lo ve el Profesional, con sus fotos y la distancia a su zona. Cero filas si el pedido dejó de estar publicado.';

revoke all on function public.pedido_publico(uuid) from public, anon;
grant execute on function public.pedido_publico(uuid) to authenticated;


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
-- PEGAR_PROFESIONAL = Profesional activo · PEGAR_PEDIDO = pedido publicado ·
-- PEGAR_BUSCADOR = un Buscador. Cada bloque termina en rollback.
--
--   -- 1. El tablero trae el pedido vigente del oficio del Profesional, con su
--   --    distancia y su portada.
--   begin;
--   select set_config('app.transicion_estado', 'on', true);
--   update public.pedidos set fecha_vencimiento = now() + interval '1 day'
--    where id = 'PEGAR_PEDIDO';
--   select set_config('app.transicion_estado', 'off', true);
--   insert into public.profesional_zona_cobertura (profesional_id, centro, radio_metros)
--   select 'PEGAR_PROFESIONAL', p.ubicacion, 20000 from public.pedidos p
--    where p.id = 'PEGAR_PEDIDO'
--   on conflict (profesional_id) do update set centro = excluded.centro;
--   insert into public.profesional_categorias (profesional_id, categoria_id)
--   select 'PEGAR_PROFESIONAL', p.categoria_id from public.pedidos p
--    where p.id = 'PEGAR_PEDIDO' on conflict do nothing;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select id, distancia_m, guardado, portada is not null as tiene_portada
--     from public.tablero_pedidos();
--   -- → el pedido, distancia 0 (la zona se centró ahí), guardado false
--   rollback;
--
--   -- 2. La coordenada que sale es la redondeada de la vista, no la exacta.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select lat, lng, scale(lat::numeric) <= 3 and scale(lng::numeric) <= 3 as redondeada
--     from public.tablero_pedidos(50, 0, false);
--   -- → redondeada = true en todas
--   rollback;
--
--   -- 3. Lo ignorado no aparece, y `p_solo_guardados` filtra.
--   begin;
--   ... (mismo armado del bloque 1)
--   insert into public.pedido_ignorado (profesional_id, pedido_id)
--   values ('PEGAR_PROFESIONAL', 'PEGAR_PEDIDO');
--   select count(*) from public.tablero_pedidos();          -- → 0
--   rollback;
--
--   -- 4. Sin zona configurada el tablero igual trae pedidos, sin distancia.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) filter (where distancia_m is null) as sin_distancia
--     from public.tablero_pedidos(50, 0, false);
--   -- → todas, si el Profesional no tiene zona
--   rollback;
--
--   -- 5. El detalle de un pedido que ya no está publicado da cero filas, no
--   --    un error.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) from public.pedido_publico('PEGAR_CERRADO');   -- → 0
--   rollback;
--
--   -- 6. Un Buscador no entra al tablero.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_BUSCADOR","role":"authenticated"}', true);
--   select * from public.tablero_pedidos();
--   -- → ERROR: El tablero es para cuentas Profesional  (HINT: sin_permiso)
--   rollback;
--
-- ============================================================================
-- FIN
-- ============================================================================
