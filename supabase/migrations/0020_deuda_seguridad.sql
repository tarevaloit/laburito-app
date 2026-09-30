-- ============================================================================
-- Laburito — Migración 0020
-- Sprint 4 · T-09: deuda de seguridad arrastrada del Sprint 3 (apartado 7.3.3)
-- ============================================================================
--
-- Tres agujeros que el Sprint 4 no puede heredar, porque el CU-25 desbloquea el
-- contacto entre las partes y el CU-31/32 acredita tokens:
--
--   1. La ubicación exacta se lee por PostgREST. «pedidos: lectura de
--      publicados vigentes» (0006) deja a cualquier autenticado leer la fila
--      entera de `pedidos` —`ubicacion` y `referencia_ubicacion` incluidas—
--      con un `GET /rest/v1/pedidos`. La vista pública redondea la coordenada,
--      pero es `security_invoker` y necesita esa política para devolver algo.
--
--   2. Un Profesional puede aprobarse solo y cargarse tokens. «profesional
--      propio: actualización» (0001/0002) es de fila entera: con un PATCH se
--      escriben `estado_verificacion`, `saldo_tokens` y las calificaciones.
--
--   3. Las fotos de un pedido cerrado se pueden agregar y borrar. El guard de
--      la 0013 cuida la fila de `pedidos`, no `pedido_fotos` ni el bucket.
--
-- Mismo método que la 0012 y la 0013: ensayo con rollback, aplicación en una
-- sola transacción y guion de aceptación al final.
-- ============================================================================


-- ============================================================================
-- 1. Quién ve un pedido, en un solo lugar
-- ============================================================================
--
-- Hasta hoy la regla «el dueño siempre, cualquier autenticado si está
-- publicado y vigente» estaba escrita en la política de `pedidos` y repetida en
-- cuatro lugares que la consultaban a través de ella: la lectura de
-- `pedido_fotos`, la lectura del bucket (0013) y el alta de ignorados y
-- favoritos (0012). Si se borra la política de `pedidos`, esos cuatro `exists`
-- dejan de ver el pedido ajeno y el tablero se queda sin fotos.
--
-- La regla pasa a una función SECURITY DEFINER que devuelve un booleano: dice
-- **si** se ve el pedido, sin exponer ninguna columna. Es el mismo patrón que
-- `es_admin()` y `es_profesional_activo()`.
--
-- Pausado no entra para el tercero, igual que en la 0013: un pedido pausado no
-- está en la calle.
-- ============================================================================

create or replace function public.es_pedido_visible(p_pedido uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1 from public.pedidos p
         where p.id = p_pedido
           and (
               p.buscador_id = auth.uid()
               or (p.estado = 'publicado' and p.fecha_vencimiento > now())
               or public.es_admin()
           )
    );
$$;

comment on function public.es_pedido_visible(uuid) is
    'T-09. Si quien llama puede ver el pedido: dueño, admin, o publicado y vigente. No expone columnas: reemplaza a la política de lectura pública de pedidos en las políticas que la usaban.';

-- El bucket compara el primer segmento de la ruta como texto, por el motivo de
-- la 0006: una ruta con basura no tiene que hacer fallar un casteo a uuid.
create or replace function public.es_pedido_visible_por_ruta(p_prefijo text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1 from public.pedidos p
         where p.id::text = p_prefijo
           and (
               p.buscador_id = auth.uid()
               or (p.estado = 'publicado' and p.fecha_vencimiento > now())
               or public.es_admin()
           )
    );
$$;

comment on function public.es_pedido_visible_por_ruta(text) is
    'T-09. es_pedido_visible() para el primer segmento de una ruta del bucket pedidos, comparado como texto.';

revoke execute on function public.es_pedido_visible(uuid)          from public, anon;
revoke execute on function public.es_pedido_visible_por_ruta(text) from public, anon;
grant  execute on function public.es_pedido_visible(uuid)          to authenticated;
grant  execute on function public.es_pedido_visible_por_ruta(text) to authenticated;


-- ============================================================================
-- 2. Las políticas que dependían de leer `pedidos` pasan a la función
-- ============================================================================

drop policy if exists "fotos: lectura si se ve el pedido" on public.pedido_fotos;
create policy "fotos: lectura si se ve el pedido"
    on public.pedido_fotos for select
    to authenticated
    using (public.es_pedido_visible(pedido_id));

drop policy if exists "pedidos: lectura si se ve el pedido" on storage.objects;
create policy "pedidos: lectura si se ve el pedido"
    on storage.objects for select
    to authenticated
    using (
        bucket_id = 'pedidos'
        and public.es_pedido_visible_por_ruta((storage.foldername(name))[1])
    );

drop policy if exists "ignorados: alta propia de un pedido visible" on public.pedido_ignorado;
create policy "ignorados: alta propia de un pedido visible"
    on public.pedido_ignorado for insert
    to authenticated
    with check (
        profesional_id = auth.uid()
        and public.es_profesional_activo()
        and public.es_pedido_visible(pedido_id)
    );

drop policy if exists "favoritos: alta propia de un pedido visible" on public.pedido_favorito;
create policy "favoritos: alta propia de un pedido visible"
    on public.pedido_favorito for insert
    to authenticated
    with check (
        profesional_id = auth.uid()
        and public.es_profesional_activo()
        and public.es_pedido_visible(pedido_id)
    );


-- ============================================================================
-- 3. Se cierra la lectura de la fila ajena
-- ============================================================================
--
-- Sin la política, un tercero no lee ninguna fila de `pedidos` por la API. Lo
-- que ve de un pedido ajeno sale de `pedidos_publicos`, que pasa a ejecutarse
-- con los permisos de su dueño (`security_invoker = false`) y lleva el filtro
-- de vigencia adentro. Es la «vista con barrera» que la sección 6 del ESTADO
-- proponía: la vista es la única puerta, y por ella no pasan ni la coordenada
-- exacta ni la referencia.
--
-- `security_barrier` impide que un filtro que venga de afuera —una función con
-- efectos laterales en el WHERE de quien consulta— se evalúe antes que el de la
-- vista y vea filas que no debería.
--
-- Queda solo para `authenticated`: la vista de la 0007 también estaba
-- concedida a `anon`, que no veía nada porque la política era `to
-- authenticated`. Con la vista corriendo como dueña, esa concesión dejaría
-- leer los pedidos sin iniciar sesión.
--
-- `tablero_pedidos()` y `pedido_publico()` (0018) no cambian: siguen siendo
-- invoker y siguen leyendo la vista.
-- ============================================================================

drop policy if exists "pedidos: lectura de publicados vigentes" on public.pedidos;

create or replace view public.pedidos_publicos
with (security_invoker = false, security_barrier = true)
as
select
    p.id,
    p.categoria_id,
    c.nombre  as categoria_nombre,
    c.slug    as categoria_slug,
    p.titulo,
    p.descripcion,
    p.urgencia,
    round(extensions.st_y(p.ubicacion::extensions.geometry)::numeric, 3) as lat,
    round(extensions.st_x(p.ubicacion::extensions.geometry)::numeric, 3) as lng,
    p.direccion_texto,
    p.presupuesto_estimado,
    p.fecha_publicacion,
    p.fecha_vencimiento,
    p.renovaciones,
    (select count(*) from public.pedido_fotos f where f.pedido_id = p.id) as cantidad_fotos
from public.pedidos p
join public.categorias_oficio c on c.id = p.categoria_id
where p.estado = 'publicado'
  and p.fecha_vencimiento > now()
  and auth.uid() is not null;

comment on view public.pedidos_publicos is
    'Pedidos vigentes tal como los ve un Profesional (CU-16, CU-43). Corre con los permisos de su dueño desde la 0020 (T-09): es la única forma de leer un pedido ajeno. Sin datos de contacto, sin referencia_ubicacion y con la coordenada redondeada a ~100 m.';

revoke all    on public.pedidos_publicos from public, anon;
grant  select on public.pedidos_publicos to authenticated;


-- ============================================================================
-- 4. Fotos: solo con el pedido en curso
-- ============================================================================
--
-- Publicado o pausado, que es exactamente lo que el guard de la edición (0013)
-- admite para el resto del pedido. Un pedido cerrado, cancelado o vencido es
-- historia: sus fotos no se agregan, no se cambian ni se borran.
--
-- El alta del CU-13 no se ve afectada: el pedido nace publicado y las fotos se
-- suben inmediatamente después. La baja de cuenta (CU-11) tampoco: no borra las
-- fotos de los pedidos, que quedan como historia del pedido.
-- ============================================================================

drop policy if exists "fotos: alta del dueño del pedido" on public.pedido_fotos;
create policy "fotos: alta del dueño del pedido"
    on public.pedido_fotos for insert
    to authenticated
    with check (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and p.buscador_id = auth.uid()
               and p.estado in ('publicado', 'pausado')
        )
    );

drop policy if exists "fotos: edición del dueño del pedido" on public.pedido_fotos;
create policy "fotos: edición del dueño del pedido"
    on public.pedido_fotos for update
    to authenticated
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and p.buscador_id = auth.uid()
               and p.estado in ('publicado', 'pausado')
        )
    )
    with check (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and p.buscador_id = auth.uid()
               and p.estado in ('publicado', 'pausado')
        )
    );

drop policy if exists "fotos: baja del dueño del pedido" on public.pedido_fotos;
create policy "fotos: baja del dueño del pedido"
    on public.pedido_fotos for delete
    to authenticated
    using (
        exists (
            select 1 from public.pedidos p
             where p.id = pedido_fotos.pedido_id
               and p.buscador_id = auth.uid()
               and p.estado in ('publicado', 'pausado')
        )
    );

drop policy if exists "pedidos: subida del dueño" on storage.objects;
create policy "pedidos: subida del dueño"
    on storage.objects for insert
    to authenticated
    with check (
        bucket_id = 'pedidos'
        and exists (
            select 1 from public.pedidos p
             where p.id::text = (storage.foldername(name))[1]
               and p.buscador_id = auth.uid()
               and p.estado in ('publicado', 'pausado')
        )
    );

drop policy if exists "pedidos: baja del dueño" on storage.objects;
create policy "pedidos: baja del dueño"
    on storage.objects for delete
    to authenticated
    using (
        bucket_id = 'pedidos'
        and exists (
            select 1 from public.pedidos p
             where p.id::text = (storage.foldername(name))[1]
               and p.buscador_id = auth.uid()
               and p.estado in ('publicado', 'pausado')
        )
    );


-- ============================================================================
-- 5. Columnas sensibles del Profesional
-- ============================================================================
--
-- Mismo razonamiento que la 0008 para `pedidos.estado`: Postgres no tiene RLS
-- por columna y la política de UPDATE es de fila entera. Un trigger decide qué
-- columnas puede tocar cada quien.
--
-- `saldo_tokens` se mueve **solo** con la compuerta `app.movimiento_tokens`,
-- que abre `aplicar_movimiento_tokens()` (0021) al escribir el movimiento en el
-- libro. Vale para cualquier rol, admin incluido: un saldo escrito a mano deja
-- de coincidir con la suma de sus movimientos, y ese es justamente el dato que
-- el CU-33 y el CU-19 muestran como comprobante.
--
-- El resto se controla por rol. Lo que llega por PostgREST corre como
-- `authenticated`; una función SECURITY DEFINER nuestra corre como su dueño.
-- Así, la baja de cuenta (que limpia `dni`, `descripcion` y `disponible`) sigue
-- funcionando, y el Profesional queda con lo que su pantalla edita:
-- `descripcion`, `dni` y `disponible`.
--
-- Única transición de verificación que el dueño puede hacer: a `en_revision`
-- desde `sin_documentacion` o `rechazado`. Es la que hace el CU-09 al completar
-- los tres documentos (`marcarEnRevisionSiEstaCompleto`). Aprobar o rechazar es
-- del admin (CU-35, Sprint 6) o del guion `aprobar_profesional.sql`.
-- ============================================================================

create or replace function public.profesionales_guard_columnas()
returns trigger
language plpgsql
as $$
begin
    if new.saldo_tokens is distinct from old.saldo_tokens
       and current_setting('app.movimiento_tokens', true) is distinct from 'on' then
        raise exception 'SALDO_NO_MODIFICABLE_DIRECTAMENTE'
              using hint   = 'campo_no_modificable',
                    detail = format(
                        'Intento de mover el saldo del Profesional %s de %s a %s '
                        'sin pasar por aplicar_movimiento_tokens().',
                        new.perfil_id, old.saldo_tokens, new.saldo_tokens
                    );
    end if;

    if current_user <> 'authenticated' or public.es_admin() then
        return new;
    end if;

    if new.perfil_id             is distinct from old.perfil_id
       or new.created_at            is distinct from old.created_at
       or new.calificacion_promedio is distinct from old.calificacion_promedio
       or new.total_calificaciones  is distinct from old.total_calificaciones then
        raise exception 'CAMPO_NO_MODIFICABLE_DIRECTAMENTE'
              using hint = 'campo_no_modificable';
    end if;

    if new.estado_verificacion is distinct from old.estado_verificacion
       and not (
           new.estado_verificacion = 'en_revision'
           and old.estado_verificacion in ('sin_documentacion', 'rechazado')
       ) then
        raise exception 'CAMPO_NO_MODIFICABLE_DIRECTAMENTE'
              using hint   = 'campo_no_modificable',
                    detail = format(
                        'El Profesional %s intentó pasar su verificación de «%s» a «%s».',
                        new.perfil_id, old.estado_verificacion, new.estado_verificacion
                    );
    end if;

    return new;
end;
$$;

comment on function public.profesionales_guard_columnas() is
    'T-09. El saldo solo con la compuerta app.movimiento_tokens; por PostgREST el dueño solo escribe descripcion, dni, disponible y el paso a en_revision del CU-09.';

drop trigger if exists profesionales_guard_columnas on public.profesionales;
create trigger profesionales_guard_columnas
    before update on public.profesionales
    for each row execute function public.profesionales_guard_columnas();


-- ============================================================================
-- 6. Guion de aceptación (supabase db query --linked -f, dentro de begin … rollback)
-- ============================================================================
--
-- Ver supabase/scripts/verificar_0020.sql. Lo que comprueba:
--
--   * `select count(*) from pedidos` como un Profesional ajeno → 0.
--   * `pedidos_publicos` como ese Profesional → los vigentes; como `anon` → error
--     de permiso.
--   * `tablero_pedidos()` sigue trayendo el pedido con su portada.
--   * Las fotos del pedido ajeno vigente se leen (tabla y bucket).
--   * Guardar e ignorar un pedido vigente pasa; uno inexistente, no.
--   * PATCH de `saldo_tokens` como dueño → SALDO_NO_MODIFICABLE_DIRECTAMENTE.
--   * PATCH de `estado_verificacion` a `aprobado` como dueño → CAMPO_NO_MODIFICABLE.
--   * `en_revision` desde `sin_documentacion` como dueño → pasa.
--   * PATCH de `disponible` como dueño → pasa.
--   * Agregar una foto a un pedido cerrado → 42501.
-- ============================================================================
