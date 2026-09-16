-- ============================================================================
-- Laburito — Preparar la base para la demo del Sprint 3
-- ============================================================================
--
-- Deja el entorno en el estado que la demo necesita. Es idempotente: se puede
-- correr las veces que haga falta, incluso minutos antes de mostrar.
--
-- Qué hace, y por qué cada cosa:
--
--   1. Aprueba al Profesional de prueba y lo pone **disponible**. Desde la
--      migración 0019 el emparejamiento filtra por ese interruptor: con la
--      cuenta en «no disponible» no llega ninguna alerta, y eso es lo correcto.
--   2. Le da zona de cobertura (José C. Paz, 20 km) si no tiene. Sin zona, el
--      tablero lista igual pero sin distancias, y el emparejamiento no lo
--      encuentra nunca.
--   3. Le asegura al menos un oficio, que es el otro insumo del emparejamiento.
--   4. Devuelve a la calle los pedidos vencidos del Buscador de prueba, para
--      que el tablero tenga qué mostrar. La fecha se mueve con la compuerta
--      `app.transicion_estado` abierta porque, desde la 0013, un UPDATE común
--      no puede tocar la vigencia.
--
-- Al final imprime el estado, que es lo que conviene mirar antes de empezar.
-- ============================================================================

-- 1 y 3. El Profesional de prueba: el más recientemente activo con fila propia.
do $$
declare
    v_prof uuid;
    v_categoria uuid;
begin
    select pr.perfil_id into v_prof
      from public.profesionales pr
      join public.perfiles p on p.id = pr.perfil_id
     where p.estado = 'activo' and p.deleted_at is null
     order by pr.created_at desc
     limit 1;

    if v_prof is null then
        raise notice 'No hay ningún Profesional activo: registrá uno desde la app y volvé a correr esto.';
        return;
    end if;

    update public.profesionales
       set estado_verificacion = 'aprobado',
           disponible          = true
     where perfil_id = v_prof;

    -- 2. Zona de cobertura, si no tiene.
    insert into public.profesional_zona_cobertura (
        profesional_id, centro, radio_metros, direccion_texto)
    values (v_prof, public.punto(-34.5136, -58.7645), 20000, 'José C. Paz')
    on conflict (profesional_id) do nothing;

    -- 3. Al menos un oficio.
    if not exists (
        select 1 from public.profesional_categorias where profesional_id = v_prof
    ) then
        select id into v_categoria from public.categorias_oficio
         where slug = 'plomeria';

        insert into public.profesional_categorias (profesional_id, categoria_id)
        values (v_prof, v_categoria)
        on conflict do nothing;
    end if;

    raise notice 'Profesional de la demo: %', v_prof;
end;
$$;

-- 4. Pedidos vigentes para que el tablero no esté vacío.
select set_config('app.transicion_estado', 'on', true);

update public.pedidos
   set fecha_vencimiento = now() + interval '14 days',
       estado            = 'publicado',
       fecha_cierre      = null
 where estado in ('publicado', 'vencido', 'pausado')
    or fecha_vencimiento <= now();

select set_config('app.transicion_estado', 'off', true);

-- ============================================================================
-- Estado final: esto es lo que conviene mirar antes de la demo.
-- ============================================================================

select p.email,
       pr.estado_verificacion,
       pr.disponible,
       (select count(*) from public.profesional_categorias c
         where c.profesional_id = pr.perfil_id)             as oficios,
       (select count(*) from public.profesional_zona_cobertura z
         where z.profesional_id = pr.perfil_id)             as zona,
       (select count(*) from public.profesional_dispositivos d
         where d.profesional_id = pr.perfil_id)             as dispositivos
  from public.profesionales pr
  join public.perfiles p on p.id = pr.perfil_id
 where p.estado = 'activo' and p.deleted_at is null;

select count(*) filter (where estado = 'publicado' and fecha_vencimiento > now())
           as pedidos_en_la_calle,
       count(*) as pedidos_totales
  from public.pedidos;
