-- ============================================================================
-- Laburito — Migración 0019
-- Sprint 3 · CU-44: horarios de atención y estado de disponibilidad
-- ============================================================================
--
-- La tabla `profesional_horarios` es de la 0012, con su restricción de
-- exclusión: dos franjas del mismo día no se pueden superponer, y eso lo
-- garantiza la base sin contar filas. Lo que falta es lo mismo que necesitó el
-- CU-12: **guardar la semana entera es una sola operación**.
--
-- La pantalla edita la grilla completa y toca «Guardar». Resolverlo con un
-- DELETE de todas las franjas y un INSERT de las nuevas, desde el cliente,
-- deja al Profesional sin ningún horario si la segunda escritura falla. Peor
-- todavía acá que en los oficios: un horario vacío no se ve raro en la
-- pantalla —parece que nunca cargó nada— y nadie se entera de que se perdió.
--
-- Además la restricción de exclusión levanta un `23P01` con el texto de
-- Postgres («conflicting key value violates exclusion constraint …»), que no
-- se le muestra a nadie. La función lo traduce.
--
-- La segunda mitad de esta migración es el filtro que el plan del sprint
-- dejó anotado: **un Profesional no disponible no recibe alertas**. Hasta
-- ahora `profesionales_para_pedido()` (0016) no lo miraba, porque el default
-- de `disponible` es `false` y sin pantalla que lo encendiera habría dejado a
-- todo el mundo sin alertas. Con el interruptor del CU-44, el filtro entra.
--
-- Es idempotente.
-- ============================================================================


-- ============================================================================
-- 1. reemplazar_horarios
-- ============================================================================
--
-- Recibe la semana entera como jsonb: `[{"dia":1,"desde":"09:00","hasta":"13:00"}, …]`.
-- Un arreglo vacío es válido y significa «no publico horarios», que no es lo
-- mismo que no estar disponible: la disponibilidad es el interruptor.
--
-- `security invoker`: la política «horarios: gestión propia» de la 0012 ya
-- limita todo a las filas propias.
-- ============================================================================

create or replace function public.reemplazar_horarios(p_franjas jsonb)
returns table (
    dia_semana  smallint,
    hora_desde  time,
    hora_hasta  time
)
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_franjas jsonb := coalesce(p_franjas, '[]'::jsonb);
    v_maximo_por_dia constant integer := 3;
begin
    if auth.uid() is null then
        raise exception 'No hay sesión activa'
              using hint = 'sin_permiso';
    end if;

    if not public.es_profesional_activo() then
        raise exception 'Solo un Profesional con la cuenta activa publica horarios'
              using hint = 'sin_permiso';
    end if;

    if jsonb_typeof(v_franjas) <> 'array' then
        raise exception 'Los horarios tienen que venir como una lista'
              using hint = 'horarios_invalidos';
    end if;

    if jsonb_array_length(v_franjas) > 21 then
        raise exception 'Son demasiadas franjas: hasta % por día', v_maximo_por_dia
              using hint = 'limite_horarios';
    end if;

    -- Se valida todo antes de tocar nada: si una franja está mal, no se borra
    -- la semana vieja.
    if exists (
        select 1
          from jsonb_array_elements(v_franjas) f
         where (f ->> 'dia')::int not between 1 and 7
    ) then
        raise exception 'El día tiene que ir de 1 (lunes) a 7 (domingo)'
              using hint = 'horarios_invalidos';
    end if;

    if exists (
        select 1
          from jsonb_array_elements(v_franjas) f
         where (f ->> 'hasta')::time <= (f ->> 'desde')::time
    ) then
        raise exception 'Cada franja tiene que terminar después de empezar. Una que cruza la medianoche son dos franjas'
              using hint = 'horarios_invalidos';
    end if;

    if exists (
        select 1
          from jsonb_array_elements(v_franjas) f
         group by (f ->> 'dia')::int
        having count(*) > v_maximo_por_dia
    ) then
        raise exception 'Hasta % franjas por día', v_maximo_por_dia
              using hint = 'limite_horarios';
    end if;

    delete from public.profesional_horarios
     where profesional_id = auth.uid();

    begin
        insert into public.profesional_horarios (
            profesional_id, dia_semana, hora_desde, hora_hasta
        )
        select auth.uid(),
               (f ->> 'dia')::smallint,
               (f ->> 'desde')::time,
               (f ->> 'hasta')::time
          from jsonb_array_elements(v_franjas) f;
    exception when exclusion_violation then
        -- La restricción de la 0012 hablando. Su texto es para un
        -- administrador; el de acá, para quien está mirando la grilla.
        raise exception 'Hay dos franjas del mismo día que se pisan. Revisá los horarios'
              using hint = 'horarios_superpuestos';
    end;

    return query
    select h.dia_semana, h.hora_desde, h.hora_hasta
      from public.profesional_horarios h
     where h.profesional_id = auth.uid()
     order by h.dia_semana, h.hora_desde;
end;
$$;

comment on function public.reemplazar_horarios(jsonb) is
    'CU-44. Reemplaza la semana entera de horarios del Profesional que llama, en una sola transacción. Traduce el 23P01 de la restricción de exclusión a un mensaje para el usuario.';

revoke all on function public.reemplazar_horarios(jsonb) from public, anon;
grant execute on function public.reemplazar_horarios(jsonb) to authenticated;


-- ============================================================================
-- 2. El emparejamiento mira la disponibilidad
-- ============================================================================
--
-- Se reescribe entera la función de la 0016 —no se parchea— para que este
-- archivo sea la versión vigente. Lo único que cambia es la línea de
-- `pr.disponible`, más el comentario que decía que faltaba.
--
-- **Los horarios no filtran el emparejamiento**, y es una decisión, no un
-- olvido: un pedido publicado a las 23:00 le sirve igual al Profesional que
-- atiende de 9 a 18 —lo ve a la mañana y lo toma—, y descartarlo por la hora
-- de publicación sería perder trabajo por nada. Los horarios son información
-- del perfil, que el Buscador mira antes de contactar (Sprint 5).
-- ============================================================================

create or replace function public.profesionales_para_pedido(p_pedido_id uuid)
returns table (
    profesional_id  uuid,
    distancia_m     double precision,
    tokens          text[]
)
language plpgsql
security definer
set search_path = public
as $$
declare
    v_pedido public.pedidos;
begin
    select * into v_pedido
      from public.pedidos
     where id = p_pedido_id;

    if not found then
        raise exception 'El pedido % no existe', p_pedido_id
              using hint = 'pedido_inexistente';
    end if;

    if v_pedido.estado <> 'publicado' or v_pedido.fecha_vencimiento <= now() then
        return;
    end if;

    return query
    select z.profesional_id,
           extensions.st_distance(z.centro, v_pedido.ubicacion) as distancia_m,
           coalesce(
               array_agg(d.token_fcm) filter (where d.token_fcm is not null),
               '{}'
           ) as tokens
      from public.profesional_zona_cobertura z
      join public.profesionales pr on pr.perfil_id = z.profesional_id
      join public.perfiles       p  on p.id        = pr.perfil_id
      left join public.profesional_dispositivos d
             on d.profesional_id = z.profesional_id
     where extensions.st_dwithin(z.centro, v_pedido.ubicacion, 100000)
       and extensions.st_dwithin(z.centro, v_pedido.ubicacion, z.radio_metros)
       and exists (
           select 1
             from public.profesional_categorias pc
            where pc.profesional_id = z.profesional_id
              and pc.categoria_id   = v_pedido.categoria_id
       )
       and pr.estado_verificacion = 'aprobado'
       and pr.disponible = true          -- CU-44: el interruptor del Profesional
       and p.estado     = 'activo'
       and p.deleted_at is null
       and not exists (
           select 1 from public.pedido_ignorado i
            where i.profesional_id = z.profesional_id
              and i.pedido_id      = v_pedido.id
       )
     group by z.profesional_id, z.centro
     order by distancia_m;
end;
$$;

comment on function public.profesionales_para_pedido(uuid) is
    'CU-21. Profesionales a los que hay que avisarles de un pedido: zona que lo contiene, oficio que coincide, cuenta aprobada y activa, disponible (CU-44) y que no lo hayan ignorado. Lee la ubicación exacta, no la vista pública. Solo service_role.';

-- El `create or replace` conserva los permisos de la 0016, pero se repiten
-- para que este archivo se pueda leer solo. Ver el comentario de la 0016
-- sobre por qué `revoke from public` no alcanza en Supabase.
revoke all on function public.profesionales_para_pedido(uuid)
    from public, anon, authenticated;
grant execute on function public.profesionales_para_pedido(uuid) to service_role;


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
-- PEGAR_PROFESIONAL = Profesional activo · PEGAR_PEDIDO = pedido publicado
-- vigente cuya zona y oficio coincidan con los de ese Profesional.
--
--   -- 1. La semana se guarda y vuelve ordenada por día y hora.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.reemplazar_horarios('[
--       {"dia":1,"desde":"09:00","hasta":"13:00"},
--       {"dia":1,"desde":"14:00","hasta":"18:00"},
--       {"dia":6,"desde":"09:00","hasta":"24:00"}]'::jsonb);
--   -- → 3 filas: lunes 09-13, lunes 14-18, sábado 09-24
--   rollback;
--
--   -- 2. Guardar de nuevo reemplaza, no acumula.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) from public.reemplazar_horarios('[
--       {"dia":1,"desde":"09:00","hasta":"13:00"},
--       {"dia":2,"desde":"09:00","hasta":"13:00"}]'::jsonb);            -- → 2
--   select count(*) from public.reemplazar_horarios('[
--       {"dia":3,"desde":"09:00","hasta":"13:00"}]'::jsonb);            -- → 1
--   rollback;
--
--   -- 3. Franjas que se pisan: mensaje nuestro, no el 23P01 de Postgres.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.reemplazar_horarios('[
--       {"dia":1,"desde":"09:00","hasta":"13:00"},
--       {"dia":1,"desde":"12:00","hasta":"15:00"}]'::jsonb);
--   -- → ERROR: Hay dos franjas del mismo día que se pisan
--   --   (HINT: horarios_superpuestos)
--   rollback;
--
--   -- 4. Lo que no entra: día fuera de rango, franja al revés, cuarta franja.
--   --    Cada uno en su bloque, todos con rollback:
--   --      '[{"dia":9,"desde":"09:00","hasta":"13:00"}]'  → horarios_invalidos
--   --      '[{"dia":1,"desde":"18:00","hasta":"09:00"}]'  → horarios_invalidos
--   --      cuatro franjas del día 1                        → limite_horarios
--
--   -- 5. Una franja inválida **no** borra la semana que ya estaba guardada.
--   --    Es lo que justifica que la función valide todo antes de tocar nada.
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select count(*) from public.reemplazar_horarios('[
--       {"dia":1,"desde":"09:00","hasta":"13:00"}]'::jsonb);            -- → 1
--   do $$
--   begin
--       perform public.reemplazar_horarios('[{"dia":9,"desde":"09:00","hasta":"13:00"}]'::jsonb);
--   exception when others then
--       raise notice 'rechazada, como se espera: %', sqlerrm;
--   end;
--   $$;
--   select count(*) from public.profesional_horarios
--    where profesional_id = 'PEGAR_PROFESIONAL';                        -- → 1
--   rollback;
--
--   -- 6. CU-44 sobre el CU-21: no disponible, no hay alerta.
--   begin;
--   update public.profesionales set disponible = false
--    where perfil_id = 'PEGAR_PROFESIONAL';
--   select count(*) from public.profesionales_para_pedido('PEGAR_PEDIDO');  -- → 0
--   update public.profesionales set disponible = true
--    where perfil_id = 'PEGAR_PROFESIONAL';
--   select count(*) from public.profesionales_para_pedido('PEGAR_PEDIDO');  -- → 1
--   rollback;
--
-- ============================================================================
-- FIN
-- ============================================================================
