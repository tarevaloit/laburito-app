-- ============================================================================
-- Laburito — Migración 0016
-- Sprint 3 · CU-21: a quién hay que avisarle de un pedido nuevo
-- ============================================================================
--
-- Es el corazón del circuito de negocio: un Buscador publica un pedido y a los
-- Profesionales que trabajan en esa zona y en ese oficio les suena el
-- teléfono.
--
-- Por qué la consulta vive en la base y no adentro de la Edge Function:
--
--   * La zona es `geography` y el filtro es `ST_DWithin` contra un índice
--     GiST. Traerse las zonas de todos los Profesionales a Deno para
--     compararlas a mano es exactamente lo que la decisión del 02/09 —guardar
--     PostGIS en vez de lat/lng sueltos— buscaba evitar.
--   * La regla de «a quién le corresponde» es una sola y queda escrita en un
--     solo lugar, que se puede leer, probar con un guion y versionar.
--
-- **Contra la columna exacta, no contra la vista pública.** `pedidos_publicos`
-- redondea la ubicación a tres decimales (unos cien metros) para no publicar
-- el domicilio del Buscador. Ese redondeo es correcto para mostrar y es un
-- error para emparejar: a alguien con una zona de 1 km lo puede dejar afuera,
-- o meter adentro, por cien metros. Por eso esta función es SECURITY DEFINER y
-- lee `pedidos.ubicacion`.
--
-- Quién puede llamarla: **solo `service_role`**, es decir la Edge Function.
-- Ni `authenticated` ni `anon`. Si cualquiera pudiera invocarla, sería una
-- forma de averiguar qué Profesionales hay cerca de un punto cualquiera, que
-- es justo lo que la RLS de la 0012 protege.
--
-- Es idempotente.
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

    -- Un pedido pausado, cerrado, cancelado o vencido no genera alertas. Se
    -- comprueba acá y no en quien llama: la función es el único lugar que
    -- decide a quién se le avisa, y eso incluye decidir que no se le avisa a
    -- nadie.
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
     where
       -- 1. El filtro que usa el índice: el radio máximo es constante, así que
       --    el planificador puede expandir la caja de búsqueda. Con
       --    `z.radio_metros` —que sale de la fila— no podría.
           extensions.st_dwithin(z.centro, v_pedido.ubicacion, 100000)
       -- 2. Y el exacto, con el radio de cada quien.
       and extensions.st_dwithin(z.centro, v_pedido.ubicacion, z.radio_metros)
       -- 3. El oficio tiene que coincidir.
       and exists (
           select 1
             from public.profesional_categorias pc
            where pc.profesional_id = z.profesional_id
              and pc.categoria_id   = v_pedido.categoria_id
       )
       -- 4. Cuenta viva y verificada. Un Profesional en revisión o rechazado
       --    no recibe trabajo: es la misma puerta que el CU-09 y el CU-35.
       and pr.estado_verificacion = 'aprobado'
       and p.estado     = 'activo'
       and p.deleted_at is null
       -- 5. Lo que el Profesional ya descartó no se le vuelve a ofrecer (CU-23).
       and not exists (
           select 1 from public.pedido_ignorado i
            where i.profesional_id = z.profesional_id
              and i.pedido_id      = v_pedido.id
       )
     group by z.profesional_id, z.centro
     order by distancia_m;

    -- Lo que **todavía no** filtra: `profesionales.disponible` (CU-44). Su
    -- default es `false` y hoy no hay pantalla que lo encienda, así que
    -- filtrar por él dejaría a todo el mundo sin alertas. El filtro entra con
    -- el CU-44, junto con el interruptor que lo prende.
end;
$$;

comment on function public.profesionales_para_pedido(uuid) is
    'CU-21. Profesionales a los que hay que avisarles de un pedido: zona que lo contiene, oficio que coincide, cuenta aprobada y activa, y que no lo hayan ignorado. Lee la ubicación exacta, no la vista pública. Solo service_role.';

-- Nadie más que la Edge Function.
--
-- **`revoke ... from public` no alcanza**, y el resto del repo lo venía dando
-- por sentado. Supabase tiene `alter default privileges ... grant all on
-- functions to anon, authenticated, service_role`, así que toda función nueva
-- nace con un grant **explícito** para esos tres roles, y un revoke a `public`
-- no toca los grants explícitos. Se comprueba mirando `proacl`:
--
--     select proname, proacl from pg_proc where proname = 'profesionales_para_pedido';
--     -- sin las dos líneas de abajo: {... anon=X/postgres, authenticated=X/postgres ...}
--
-- En las funciones anteriores del proyecto el descuido no tiene consecuencias
-- —todas empiezan comprobando `auth.uid()`, que para `anon` es nulo—, pero
-- esta no puede depender de eso: devuelve dónde hay Profesionales, que es
-- justo lo que la RLS de la 0012 esconde.
revoke all on function public.profesionales_para_pedido(uuid)
    from public, anon, authenticated;
grant execute on function public.profesionales_para_pedido(uuid) to service_role;


-- ============================================================================
-- GUION DE ACEPTACIÓN (correr en el SQL Editor)
-- ============================================================================
--
-- El editor corre como `postgres`, que puede ejecutar la función. Para probar
-- que `authenticated` **no** puede, hay que bajar de rol.
-- PEGAR_PROFESIONAL = Profesional aprobado y activo ·
-- PEGAR_PEDIDO = un pedido publicado · PEGAR_CATEGORIA = la categoría de ese
-- pedido.
--
--   -- 1. Caso feliz: zona que contiene el pedido y oficio que coincide.
--   --    Se arma todo adentro de la transacción y se deshace al final.
--   begin;
--   select set_config('app.transicion_estado', 'on', true);
--   update public.pedidos set fecha_vencimiento = now() + interval '1 day'
--    where id = 'PEGAR_PEDIDO';
--   select set_config('app.transicion_estado', 'off', true);
--
--   insert into public.profesional_zona_cobertura (profesional_id, centro, radio_metros)
--   select 'PEGAR_PROFESIONAL', p.ubicacion, 20000
--     from public.pedidos p where p.id = 'PEGAR_PEDIDO'
--   on conflict (profesional_id) do update
--      set centro = excluded.centro, radio_metros = excluded.radio_metros;
--
--   insert into public.profesional_categorias (profesional_id, categoria_id)
--   select 'PEGAR_PROFESIONAL', p.categoria_id
--     from public.pedidos p where p.id = 'PEGAR_PEDIDO'
--   on conflict do nothing;
--
--   insert into public.profesional_dispositivos (profesional_id, token_fcm, plataforma)
--   values ('PEGAR_PROFESIONAL', repeat('t', 40), 'android');
--
--   select profesional_id, round(distancia_m::numeric) as metros,
--          array_length(tokens, 1) as dispositivos
--     from public.profesionales_para_pedido('PEGAR_PEDIDO');
--   -- → una fila, distancia 0 (la zona se centró en el pedido), 1 dispositivo
--   rollback;
--
--   -- 2. Los cuatro motivos por los que alguien queda afuera. Cada uno se
--   --    prueba sacando una sola condición del caso 1: la consulta tiene que
--   --    devolver 0 filas en los cuatro.
--   --      a) zona lejos:      radio_metros = 1000 y centro a 50 km
--   --      b) otro oficio:     borrar la fila de profesional_categorias
--   --      c) sin aprobar:     estado_verificacion = 'en_revision'
--   --      d) pedido ignorado: insert en pedido_ignorado
--   --    (el guion de arriba, con esa línea cambiada, y rollback)
--
--   -- 3. Un pedido que no está en la calle no avisa a nadie.
--   begin;
--   select count(*) from public.profesionales_para_pedido('PEGAR_CERRADO');
--   -- → 0
--   rollback;
--
--   -- 4. Un pedido que no existe es un error, no una lista vacía: quien llama
--   --    mandó un id mal y tiene que enterarse.
--   select * from public.profesionales_para_pedido(gen_random_uuid());
--   -- → ERROR: El pedido ... no existe  (HINT: pedido_inexistente)
--
--   -- 5. Un usuario común no puede usarla para espiar dónde hay Profesionales.
--   --    Antes del revoke a anon y authenticated, este bloque **pasaba**.
--   select proacl::text from pg_proc where proname = 'profesionales_para_pedido';
--   -- → {postgres=X/postgres,service_role=X/postgres}  (ni anon ni authenticated)
--   begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--          '{"sub":"PEGAR_PROFESIONAL","role":"authenticated"}', true);
--   select * from public.profesionales_para_pedido('PEGAR_PEDIDO');
--   -- → ERROR 42501: permission denied for function profesionales_para_pedido
--   rollback;
--
-- ============================================================================
-- FIN
-- ============================================================================
