# Presentación — Sprint 5 y Sprint 6

> Guion para mostrar los dos sprints en **15 minutos**, porque la reunión del Sprint 5
> no se hizo. Cuenta **una sola historia** con los mismos tres personajes: el
> Profesional comparte su perfil y lo califican (Sprint 5); esa calificación y una
> denuncia llegan al panel del administrador, que modera, sanciona y resuelve la
> apelación (Sprint 6). Lo que se hace en la Parte 1 es lo que se resuelve en la
> Parte 2.
>
> Cada paso dice qué hacer, qué decir y qué caso de uso cierra. Los tiempos son
> topes: si un paso se atrasa, se saltea el siguiente marcado como *opcional*.

---

## Antes de la reunión

### El día anterior

| # | Qué | Por qué |
|---|---|---|
| 1 | Registrar un **segundo Profesional** desde la app (otro correo), validar el correo y subir las tres fotos (DNI frente, dorso y selfie) | Es el que se aprueba en vivo (CU-35). Hoy no hay ninguno en revisión con fotos cargadas |
| 2 | Volver a entrar en el teléfono con el **Profesional principal** (`profesional@laburito.test`) y aceptar las notificaciones | Es el que se usa en toda la demo |
| 3 | Correr `supabase/scripts/preparar_demo.sql` | Deja al Profesional principal aprobado, disponible y con pedidos en el tablero |
| 4 | Comprobar que el Profesional principal tiene **un contacto desbloqueado sin calificar** (hoy hay dos) | El enlace de calificación del CU-28 nace de un contacto pagado con un token |
| 5 | Ensayar todo una vez **con datos móviles** | El wifi de la facultad bloquea la Web publicada (7.5.4 b) |

### 15 minutos antes

| # | Qué |
|---|---|
| 1 | Notebook y teléfono con **datos móviles** (compartir internet desde el celular) |
| 2 | En la notebook, tres ventanas: **(A)** la Web con sesión del **Buscador**, **(B)** una ventana de **incógnito** en `https://byto-laburitoapp-2e5af.web.app/admin/ingresar` sin sesión, **(C)** el documento con el **burndown** |
| 3 | En el teléfono, la app abierta con el Profesional principal |
| 4 | Tener escrito el comentario para la reseña: «Un estafador, no vino nunca» |

**Plan B:** si una notificación push tarda, no se espera: se abre la campana y se
sigue. Si la Web no carga, es la red: se cambia a datos móviles.

---

## 0. Apertura — 1 minuto

Mostrar **(C)**, el burndown.

**Decir:** «El Sprint 5 cerró sus 39 puntos, incluido el CU-18 que venía del Sprint 2,
y el Sprint 6 cerró los 32 comprometidos. Con eso el backlog llega a 235 de 235. Les
muestro los dos juntos porque son una sola historia: el Profesional construye su
reputación, y cuando algo sale mal, el administrador interviene».

---

## Parte 1 — Sprint 5: la reputación sin registro (5 minutos)

| Min | Hacer | Decir | CU |
|---|---|---|---|
| 1 | **Teléfono** → Mi Perfil → **Compartir mi perfil** → mandarlo por WhatsApp a uno mismo o copiarlo | «El Profesional verificado genera un enlace público. El enlace usa un identificador aleatorio, no el id, para que no se puedan recorrer los perfiles» | CU-26 |
| 1 | Abrir el enlace en la **ventana de incógnito (B)** | «Se abre sin cuenta y sin instalar nada: oficios, portafolio, reseñas. No muestra ni correo ni teléfono» | CU-27 |
| 2 | **Teléfono** → Mi Perfil → **Mis contactos y calificaciones** → **Pedir calificación** en un contacto | «Solo se puede pedir sobre un contacto real, pagado con un token: es la protección contra reseñas falsas que pide la ERS» | CU-28 |
| 2 | Abrir el enlace en **(B)** → **2 estrellas** con el comentario «Un estafador, no vino nunca» → Enviar → volver a abrir el mismo enlace | «Se califica desde el navegador. El enlace sirve una sola vez: abierto de nuevo, ya no deja calificar. Este comentario lo vamos a volver a ver en el panel» | CU-28 |
| 3 | **Teléfono**: tocar la **campana** | «El aviso de la calificación lo escribe la base, no la app: así nadie puede inventarse un aviso» | CU-48 |
| 3 | **Teléfono** → **Mis estadísticas** | «Vistas del perfil, contactos abiertos y efectividad, por semana o por mes. La visita que acabamos de hacer ya cuenta» | CU-45 |
| 4 | **Web del Buscador (A)** → pegar el enlace del perfil del paso 1 → **Reportar** → motivo **Estafa** → contar qué pasó → Enviar | «El Buscador denuncia desde el perfil público. La denuncia genera una alerta en el panel: es la que el administrador va a resolver en el Sprint 6» | CU-41 |
| 5 | *Opcional:* en el login de la Web, mostrar **«¿Perdiste el acceso a tu pedido?»** | «El CU-18, que venía del Sprint 2: un enlace de un solo uso por correo, con respuesta siempre genérica para no revelar qué correos existen» | CU-18 |

---

## Parte 2 — Sprint 6: el Panel de Administración (8 minutos)

Todo en la **ventana de incógnito (B)**, salvo donde se indica.

| Min | Hacer | Decir | CU |
|---|---|---|---|
| 1 | `/admin/ingresar` con el correo y la contraseña del **Buscador** | «Un usuario común no entra: se cierra su sesión y el intento queda registrado con la IP y la hora» | CU-34 (flujo alterno) |
| 1 | Ingresar con el **administrador** → Dashboard | «Pedidos, ingresos, altas y reportes del período, comparados con el anterior. Al pie, el registro de accesos, con el intento rechazado de recién» | CU-34, CU-38 |
| 2 | Cambiar el rango a **Últimos 7 días** → **Exportar** | «El reporte se descarga en CSV y lo abre Excel» | CU-38 |
| 2 | **Validaciones** → el segundo Profesional → **Aprobar cuenta** | «Las fotos del DNI se ven junto a los datos del registro. Al resolver, se borran del servidor: es el requerimiento de la Ley 25.326 que pide la ERS. Si se rechaza, el motivo es obligatorio y le llega al Profesional» | CU-35 |
| 3 | **Reseñas** | «La reseña de recién aparece sola: la marcó el filtro automático por la palabra "estafador". También llegan las que reporta el Profesional desde "Mis reseñas"» | CU-46 |
| 3 | **Eliminar reseña** → volver a **(B)** con el perfil público y recargar | «Se oculta, no se borra, y el promedio se recalcula sin ella» | CU-46 |
| 4 | **Denuncias** → la de recién, marcada **Grave** | «La bandeja ordena por gravedad, que sale del motivo, y muestra el descargo, la reputación del denunciado, sus denuncias previas y lo que pasó con el pedido» | CU-39 |
| 5 | **Suspender usuario** → motivo → **Temporal, 3 días**, apelable → confirmar | «La sanción resuelve la denuncia en la misma operación: cambia el estado de la cuenta, cierra sus sesiones y la saca de las búsquedas. Un administrador no puede sancionar a otro» | CU-39, CU-36 |
| 6 | **Teléfono**: cerrar sesión y volver a entrar | «Al entrar ve el motivo y hasta cuándo dura. Puede apelar» | CU-49 |
| 6 | **Apelar sanción** → escribir el descargo → Enviar | «Le damos un número de trámite para el seguimiento» | CU-49 |
| 7 | **(B)** → Denuncias → **Apelaciones** → **Aceptar y reactivar** con una respuesta | «La apelación llega a la misma bandeja. Al aceptarla, se levanta la sanción y el usuario recibe el aviso» | CU-49 |
| 7 | **Teléfono**: cerrar sesión y volver a entrar | Entra al inicio de siempre: la cuenta vuelve a estar activa | CU-49 |
| 8 | **Categorías**: mostrar las tarjetas y apagar una | «El catálogo se administra sin tocar código. Una categoría con profesionales no se borra: se oculta» | CU-37 |
| 8 | **Parámetros**, solo mostrar | «Radio máximo de cobertura y límites de renovación. La base los lee al validar; cambiarlos pide confirmación y contraseña» | CU-47 |

---

## Cierre — 1 minuto

| Hacer | Decir |
|---|---|
| **Teléfono** o login de la Web → **Ayuda y soporte** | «Preguntas frecuentes con buscador y los canales de contacto. Es lo mismo que el Manual de Usuario de la T-04» (CU-42, T-04) |
| Volver al burndown **(C)** | «La línea real llega a cero junto con la planificada. Además encontramos y cerramos una falla de seguridad: cualquier usuario podía darse el rol de administrador desde la API. Se registró como deuda de 2 puntos, la T-13, igual que las del Sprint 3 y el Sprint 4. Queda el release v1.0.0» |

---

## Si preguntan

| Pregunta | Respuesta corta |
|---|---|
| ¿Por qué no hay correo cuando se rechaza o se modera? | Como en el CU-18, no se sumó un proveedor de correo: el aviso va al centro de notificaciones, con el motivo (desvío registrado en el 7.6.1) |
| ¿Dónde está el «SuperAdmin»? | Hay un solo rol de administrador. Sancionar a otro administrador se bloquea siempre, y los parámetros piden contraseña (7.6.1) |
| ¿Por qué CSV y no Excel o PDF? | Excel lo abre directamente y no suma dependencias (7.6.1) |
| ¿Cómo se prueba todo esto? | 411 pruebas automáticas, una de recorrido por pantalla, y un guion de aceptación por migración: 66 reglas verificadas contra la base |
| ¿Y la app en las tiendas? | Se distribuye por los canales de prueba (apartado 2.1). ==Completar según el estado de las cuentas de desarrollador== |

## Después de la demo

- La reseña quedó eliminada, la denuncia resuelta y el Profesional reactivado. Para
  repetir la demo hace falta otro contacto sin calificar y otro Profesional en revisión.
- La categoría apagada en el paso de Categorías: volver a encenderla.
