# Changelog

Todas las versiones del proyecto, agrupadas por caso de uso. El formato sigue
la convención de commits del proyecto: `<tipo>(<ID>): <descripción>`.

## v1.0.0 — Sprint 6 · Administración, Cierre y Despliegue (PT 7.0)

_28/10/2026_

El Panel de Administración completo —la tercera superficie del sistema—, el
endurecimiento de seguridad de los perfiles y la documentación de usuario.
Cierra los 235 puntos del backlog.

### Casos de uso

- **CU-34 · Iniciar Sesión Administrador** — `/admin/ingresar`, sin registro.
  Cada intento queda registrado con IP, navegador y hora; una cuenta que no es
  de administrador se rechaza y se cierra su sesión.
- **CU-38 · Consultar Estadísticas** — Dashboard con pedidos, ingresos, altas y
  reportes del rango elegido contra el período anterior, altas de doce meses,
  ingresos por pack y exportación a CSV.
- **CU-35 · Validar Identidad Profesional** — revisión de las fotos con los
  datos del registro; aprobar o rechazar con motivo, y las fotos se destruyen
  al resolver.
- **CU-37 · Gestionar Categorías de Oficios** — alta con ícono, edición,
  ocultamiento y baja; una categoría en uso no se borra.
- **CU-36 · Suspender Cuenta** — buscador de usuarios con su historial;
  suspensión temporal o permanente que cierra sesiones y pausa pedidos.
- **CU-39 · Gestionar Denuncias** — bandeja por gravedad con la trazabilidad
  del pedido; resolver con sanción, marcar resuelta o desestimar.
- **CU-46 · Moderar Reseñas** — reporte desde «Mis reseñas» y filtro
  automático; eliminar recalcula el promedio.
- **CU-47 · Configurar Parámetros Globales** — radio máximo de cobertura y
  límites de renovación, leídos por las funciones de la base.
- **CU-49 · Recuperar Cuenta Bloqueada** — apelación con número de trámite y su
  resolución desde el panel.
- **CU-42 · Consultar Ayuda y Soporte** — `/ayuda` pública con preguntas
  frecuentes, buscador y canales de contacto.

### Técnico

- **T-12** — migraciones 0034 a 0044, cada una con su guion de aceptación.
- **T-13** — guard de columnas de `perfiles`: nadie se escribe el rol ni el
  estado de la cuenta por la API.
- **T-04** — Manual de Usuario y FAQ en `docs/manual/`.
- 411 pruebas (362 en v0.5.0).

## v0.5.0 — Sprint 5 · Enlaces Públicos y Calificación (PT 6.0)

_14/10/2026_

El circuito de confianza «Frictionless»: el Profesional comparte su perfil por
enlace y el Buscador lo consulta y lo califica desde el navegador, sin cuenta.
La Web queda publicada en Firebase Hosting.

### Casos de uso

- **CU-26 · Compartir Perfil Público** — «Compartir mi perfil» en Mi Perfil:
  copia el enlace `/p/<slug>` y lo manda por WhatsApp. Exige la documentación
  aprobada; con la cuenta suspendida el botón se desactiva.
- **CU-27 · Acceder a Perfil por Link** — vista pública *mobile first* con
  oficios, trabajos y reseñas, sin correo ni teléfono; 404 propio.
- **CU-28 · Calificar Profesional** — enlace de un solo uso que nace de un
  contacto desbloqueado, pedido desde «Mis contactos»; el promedio lo
  recalcula el servidor.
- **CU-48 · Ver Notificaciones de Actividad** — campana con contador en vivo y
  centro de avisos; los escriben disparadores de la base.
- **CU-45 · Ver Métricas de Perfil** — vistas, contactos abiertos, barras por
  día o por semana y efectividad.
- **CU-41 · Reportar Usuario** — desde el perfil público o el pedido, con la
  alerta en la sección «Denuncias» del panel.
- **CU-18 · Reenvío de Enlace de Gestión** — «Recuperá tu pedido»: enlace de
  acceso de un solo uso por correo, con respuesta siempre genérica.

### Técnico

- **T-11** — migraciones 0027 a 0033, 59 reglas de aceptación en OK.
- Workflow de GitHub Actions que mantiene activa la base de Supabase.

## v0.4.0 — Sprint 4 · Monetización (PT 5.0)

_01/10/2026_

El modelo de negocio funciona sobre el entorno de prueba de Mercado Pago: el
Profesional compra tokens, el pago se acredita solo y con un token obtiene el
contacto del Buscador.

### Casos de uso

- **CU-30 · Consultar Saldo de Tokens** — billetera con saldo, packs y últimos
  movimientos; muestra el último saldo si se corta la conexión y se relee al
  volver a la app.
- **CU-31 · Cargar Tokens** — Checkout Pro con credenciales de prueba. La app
  manda solo el pack; el precio lo pone el servidor.
- **CU-32 · Procesar Pago** — webhook con validación de firma y consulta a la
  API, más conciliación desde la app al volver del checkout. La acreditación es
  idempotente y exige que el monto coincida.
- **CU-33 · Ver Historial de Pagos** — aprobados, pendientes y rechazados, con
  el detalle de cada uno y el motivo de un rechazo.
- **CU-25 · Postularse (Desbloquear Contacto)** — un token por contacto, sin
  cobrar dos veces, con el teléfono enmascarado hasta pagar y el chat de
  WhatsApp. El Buscador ve cuántos Profesionales pidieron su contacto.
- **CU-40 · Configurar Precio de Tokens** — panel del administrador, con la
  contraseña pedida otra vez antes de guardar.
- **CU-52 · Crear Cupón Promocional** — código, tokens, vencimiento y límite de
  usos.
- **CU-53 · Canjear Cupón de Tokens** — una vez por Profesional, con bloqueo
  temporal ante intentos fallidos repetidos.
- **CU-19 · Descargar Comprobante** — PDF emitido por la plataforma (no es una
  factura de AFIP).

### Infraestructura y deuda

- **T-09** — la dirección exacta de un pedido deja de poder leerse por la API;
  un Profesional ya no puede cargarse tokens ni aprobarse solo; las fotos de un
  pedido cerrado no se pueden tocar.
- **T-10** — esquema de monetización: el saldo es la suma de un libro de
  movimientos que solo escribe una función del servidor.
- Migraciones 0020 a 0026, verificadas con 51 reglas contra la base. Edge
  Functions `crear_preferencia_pago`, `webhook_mercadopago`, `verificar_pago`,
  `retorno_pago` y `comprobante_pago`.

### Arreglos de la prueba real

- La sección Cupones del panel redirigía siempre a Precios.
- Guardar un precio en el panel daba un error de pantalla completa.
- Cerrar sesión en la Web pedía permisos de notificación y no salía: la Web no
  usa push.
- El inicio mostraba el saldo del momento de iniciar sesión.

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
