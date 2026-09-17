# Changelog

Todas las versiones del proyecto, agrupadas por caso de uso. El formato sigue
la convención de commits del proyecto: `<tipo>(<ID>): <descripción>`.

## v0.3.1 — CU-21 verificado de punta a punta

_16/09/2026_

La alerta push llega al teléfono. Es el cierre del CU-21, que en `v0.3.0` quedaba
completo del lado del servidor pero sin haber sido probado con un dispositivo.

- **CU-21** — Firebase conectado: permiso de notificaciones, registro y rotación
  del token, canal de Android y aviso cuando el mensaje llega con la app abierta.
- **CU-21** — la Edge Function responde la verificación CORS del navegador: desde
  la Web la alerta no se disparaba.
- **CU-21** — tocar la notificación abre el detalle del Profesional apilado sobre
  el tablero; antes abría el del dueño del pedido y, al volver, «Mis pedidos».
- Las pantallas del Buscador validan el rol.
- Guía de puesta en marcha en `docs/FIREBASE.md`.

## v0.3.0 — Sprint 3 · Perfil del Profesional y Notificaciones (PT 4.0)

_16/09/2026_

La aplicación del Profesional pasa a existir: configura dónde y en qué trabaja,
ve los pedidos de su zona y el servidor ya sabe a quién avisarle de cada pedido
nuevo.

### Casos de uso

- **CU-07 · Configurar Zona de Cobertura** — centro en el mapa y radio de 1 a
  100 km, sobre el mismo selector de ubicación del CU-16.
- **CU-12 · Editar Categorías de Oficio** — el reemplazo pasa a ser una sola
  transacción del lado del servidor, con el mínimo de uno y el tope de cinco
  aplicados ahí.
- **CU-21 · Recibir Alerta Push** — emparejamiento por zona, oficio, estado de
  la cuenta y disponibilidad, resuelto en la base y disparado desde una Edge
  Function. La conexión con Firebase y la prueba en un dispositivo real están en
  `v0.3.1`.
- **CU-43 · Explorar Tablero de Pedidos** — pedidos vigentes ordenados por
  distancia, con filtros por oficio y por guardados.
- **CU-22 · Ver Detalle de Pedido** — el pedido ajeno, sin la dirección exacta
  ni la barra de acciones del dueño.
- **CU-23 · Ignorar Pedido** y **CU-24 · Guardar Pedido** — dos acciones sobre
  la tarjeta, con deshacer en la primera.
- **CU-44 · Horarios y disponibilidad** — la semana de atención y el
  interruptor que decide si llegan alertas.
- **CU-06 · Cargar Portafolio** — hasta 10 fotos en un bucket privado.
- **CU-17 · Consultar Historial** (replanificado del Sprint 2).

### Tareas técnicas

- **T-06** — pruebas de widget de los formularios de pedido.
- **T-07** — migración 0012: esquema del Profesional, con las políticas RLS en
  el mismo archivo que crea cada tabla.
- **T-08** — migración 0013: el Profesional puede ver las fotos de un pedido, y
  el PATCH de edición deja de poder tocar el ciclo de vida.

### Migraciones

`0012` esquema del Profesional · `0013` deuda del Sprint 2 · `0014` zona de
cobertura · `0015` categorías en una transacción · `0016` emparejamiento ·
`0017` dispositivos de FCM · `0018` tablero y detalle público · `0019` horarios
y filtro de disponibilidad.

### Correcciones de fondo

- `revoke ... from public` **no revoca nada** en Supabase: los privilegios por
  defecto dan `EXECUTE` explícito a `anon` y `authenticated`. Corregido en la
  función del emparejamiento, que es la única donde tenía consecuencias.
- El `PATCH` de edición de un pedido ya no puede estirar la vigencia ni
  reiniciar el contador de renovaciones.

## v0.2.0 — Sprint 2 · Gestión de Pedidos y Geolocalización (PT 3.0)

_03/09/2026_

- **CU-13 · Publicar pedido con ubicación en el mapa** — asistente de 4 pasos.
- **CU-16 · Localizar Pedido en Mapa** — selector con búsqueda de direcciones,
  «usar mi ubicación» y geocodificación inversa.
- **CU-14 · Cancelar**, **CU-15 · Editar**, **CU-20 · Pausar y reanudar**,
  **CU-29 · Cerrar**, **CU-51 · Renovar** — el ciclo de vida completo, con su
  máquina de estados blindada en la base.
- **CU-17 · Consultar Historial** — cuatro grupos con contadores, búsqueda en
  el servidor y scroll infinito.
- **T-05** — migración a `freezed` y `riverpod_generator` en todo el proyecto.
- Migraciones `0005` a `0011`.

## v0.1.0 — Sprint 1 · Fundaciones y Autenticación (PT 2.0)

_19/08/2026_

- **CU-01 · Registrar Buscador**, **CU-02 · Registrar Profesional**,
  **CU-08 · Validar email con PIN**, **CU-03 · Iniciar sesión**,
  **CU-10 / CU-50 · Cerrar sesión**, **CU-04 · Recuperar contraseña**.
- **CU-05 · Gestionar Perfil**, **CU-09 · Validar Documentación**,
  **CU-11 · Dar de Baja Cuenta** — con anonimización y liberación del correo.
- **T-01** setup del proyecto y **T-02** esquema, RLS, buckets y seed de
  categorías. Migraciones `0001` a `0004`.
