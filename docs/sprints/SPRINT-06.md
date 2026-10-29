# SPRINT 06 — Administración, Cierre y Despliegue (PT 7.0)

> Plan de ejecución del sprint. Vive en `docs/sprints/SPRINT-06.md`.
> Se deriva del apartado 4.6 de la planificación y de los ajustes del apartado 7.5.7.

---

## 1. Encuadre

| Campo | Valor |
|---|---|
| Paquete de trabajo | PT 7.0 |
| Período | 15/10/2026 al 28/10/2026 |
| Entrega por BB | 28/10/2026 hasta las 23:59 |
| Reunión | 29/10/2026 |
| Release objetivo | v1.0.0 — versión candidata con el core completo (3er parcial) |
| Rama | `sprint-6`, salida de `main` en `v0.5.0` |
| Remanente al inicio | 30 puntos |
| Requerimientos cubiertos | RF10 (apartado 4.6); por la ERS, además RF06 (CU-42) y RF11 (CU-34 a CU-39) |

**Objetivo del sprint (apartado 4.6).** Incorporar el Panel de Administración —tercera
superficie de interfaz del sistema—, aplicar el endurecimiento de seguridad y dejar el
producto desplegado, distribuido a los dispositivos de prueba y documentado.

---

## 2. Compromiso del sprint: 32 puntos

| Origen | Pts |
|---|---|
| Alcance planificado del PT 7.0 (apartado 4.6) | 30 |
| T-13 Deuda de seguridad: columnas de `perfiles` (hallada al planificar, ver 2.3) | 2 |
| **Total** | **32** |

### 2.1 Alcance

Estados: `⬜ pendiente` · `🟡 en curso` · `✅ hecho` · `⏭️ replanificado`

| ID | Tarea / Caso de Uso | Tipo | Pts | Estado | Evidencia |
|---|---|---|---|---|---|
| T-12 | Esquema de administración con sus políticas RLS (infraestructura) | Backend | — | ✅ | `5404333` |
| T-13 | Deuda de seguridad: columnas de `perfiles` | Backend | 2 | ✅ | `5404333` |
| CU-34 | Iniciar Sesión Administrador | Full-stack | 3 | ✅ | `27513c3` |
| CU-38 | Consultar Estadísticas (Dashboard) | Frontend | 3 | ✅ | `27513c3` |
| CU-35 | Validar Identidad Profesional | Full-stack | 3 | ✅ | `96e1c10`, `c1cf976` |
| CU-37 | Gestionar Categorías de Oficios | Full-stack | 3 | ✅ | `8352911`, `a9581c8` |
| CU-36 | Suspender Cuenta | Full-stack | 3 | ✅ | `2d35428` |
| CU-39 | Gestionar Denuncias | Full-stack | 3 | ✅ | `4f7a7c2` |
| CU-46 | Moderar Reseñas | Full-stack | 2 | ✅ | `19b7acf` |
| CU-47 | Configurar Parámetros Globales | Full-stack | 2 | ✅ | `a34a2a3` |
| CU-49 | Recuperar Cuenta Bloqueada | Full-stack | 2 | ✅ | `58baa69` |
| CU-42 | Consultar Ayuda y Soporte | Frontend | 2 | ✅ | `3bf73a0` |
| T-03 | Despliegue de la Web y el backend; distribución de la app | Técnica | 2 | ✅ | `765dd79`: migraciones aplicadas (66 reglas OK), Web publicada y APK de release. La subida a las tiendas de prueba pasa a deuda técnica |
| T-04 | Manual de Usuario y FAQ | Técnica | 2 | ✅ | `b07803e` |
| | **Total** | | **32** | | |

**Estado.** Todo el alcance está escrito, commiteado y probado: `flutter analyze` sin issues,
**411 pruebas en verde** (362 al cierre del Sprint 5), Web y APK de release compilando. La 0034
a 0044 están aplicadas con sus guiones en OK (66 reglas) y la Web está publicada con el panel.
La subida a TestFlight y a la prueba interna de Google Play queda como deuda técnica: depende del alta de
las cuentas de desarrollador (apartado 5). El apartado 7.6 está en
`SPRINT-06-cierre.md` y `.docx`, con lo que falta confirmar en amarillo.

La T-12 no lleva puntos, con el criterio de la T-07, la T-10 y la T-11: es la
infraestructura sin la cual los casos de uso no existen. La T-13 sí, con el criterio de la
T-08 y la T-09: es deuda de seguridad con estimación propia, y sus puntos no descuentan
backlog.

### 2.2 Arrastrado sin puntos

| Ítem | Origen | Cómo se cierra |
|---|---|---|
| Alta de las cuentas de desarrollador de Apple y Google | 7.5.3, ajuste 1 del 7.5.7 | Acción del responsable (tiene costo). Es condición de la distribución de la T-03 |
| Firma de los avisos de Mercado Pago | 7.5.3 | Con una compra de prueba: el webhook acredita sin `[webhook] FIRMA INVÁLIDA` |

### 2.3 La T-13: `perfiles` se puede escribir entera

La política «perfil propio: actualización» (0001) es de fila entera y la tabla no tiene
guard de columnas, a diferencia de `profesionales` (0020) y `pedidos` (0008). Verificado
contra la base: el único disparador de `perfiles` es `perfiles_set_updated_at`. Con un
PATCH por la API, cualquier usuario puede escribir su propio `tipo` y su `estado`, es
decir, **darse el rol de administrador** o levantarse una suspensión. Con el panel de este
sprint, esa columna pasa a ser la llave de todo el sistema. Se cierra con un guard
`BEFORE UPDATE` del patrón de la 0020: el dueño solo escribe `nombre`, `apellido`,
`telefono` y `avatar_url`.

---

## 3. Decisiones de diseño

1. **El administrador entra por `/admin/ingresar`.** Un formulario mínimo, sin registro ni
   enlace desde la Web pública (CU-34). Si las credenciales son de un Buscador o de un
   Profesional se cierra la sesión y el intento queda registrado. Cada intento —aceptado o
   denegado— se guarda en `accesos_admin` con la IP (encabezado `x-forwarded-for` que
   PostgREST expone en `request.headers`), el navegador y la hora, que es el requerimiento
   especial del caso de uso. El ingreso lleva al Dashboard.
2. **No hay rol «SuperAdmin».** La ERS lo nombra en el CU-36 y el CU-47. Laburito tiene un
   solo rol de administrador: el flujo alterno del CU-36 se cumple bloqueando **siempre**
   la sanción a otro administrador, y el CU-47 se protege como el CU-40, con una segunda
   confirmación y la contraseña.
3. **Los avisos van al centro de notificaciones, no por correo.** El CU-35 y el CU-46
   piden un email al Profesional o al autor. Como en el CU-18, no se suma un proveedor de
   correo: el aviso es una notificación del CU-48 (verificación aprobada o rechazada con el
   motivo, reseña eliminada, denuncia resuelta, apelación resuelta).
4. **Las fotos del DNI se destruyen al resolver.** Requerimiento especial del CU-35 (Ley
   25.326). El panel borra los archivos por la API de Storage y después llama a
   `resolver_verificacion`, que cambia el estado y elimina las filas: el mismo orden del
   CU-11, que deja la operación reintentable si algo falla en el medio. Al rechazar, el
   Profesional vuelve a cargar su documentación desde cero (la 0020 ya permite pasar de
   `rechazado` a `en_revision`).
5. **La suspensión es una sanción con historia.** Tabla `sanciones`: motivo, temporal (con
   fecha de fin) o permanente, apelable o no. `suspender_cuenta` cambia el estado, cierra
   las sesiones activas del usuario, pausa sus pedidos publicados («deja de figurar en
   búsquedas») y guarda el registro. Una sanción temporal se levanta sola al vencer: lo
   comprueba el login.
6. **La gravedad de una denuncia sale del motivo.** Estafa y perfil falso son graves;
   incumplimiento y comportamiento inapropiado, medias; «otro», baja. La bandeja ordena por
   gravedad y fecha (CU-39, paso 2), y el detalle muestra la reputación del denunciado, sus
   denuncias previas y los eventos del pedido.
7. **Las reseñas se reportan desde «Mis reseñas» y por un filtro automático.** El
   Profesional reporta una reseña que considera falsa u ofensiva; además, un disparador
   marca para revisión las que contienen términos de una lista corta. Eliminar oculta la
   reseña (la columna `oculta` de la 0027), recalcula el promedio y avisa al Buscador que
   la escribió.
8. **Los parámetros globales viven en una tabla y la base los lee.** `parametros_sistema`
   con valor, mínimo y máximo. Se cablean los tres que hoy están escritos en las funciones:
   radio máximo de la zona de cobertura (`guardar_zona_cobertura`), renovaciones máximas de
   un pedido y días máximos por renovación (`renovar_pedido`). Un valor fuera de rango se
   rechaza y se conserva el anterior.
9. **Una cuenta suspendida puede apelar.** El login de una cuenta suspendida no se cierra en
   el acto: lleva a «Cuenta suspendida», con el motivo, la fecha de fin y el botón «Apelar
   sanción». La apelación devuelve un número de trámite y aparece en el panel, en la
   sección Denuncias. Una sanción inapelable muestra el correo de soporte legal.
10. **La ayuda es pública y viene de la base.** `/ayuda` se abre con o sin sesión, desde la
    Web, la app y el login. Las preguntas frecuentes están en `preguntas_frecuentes`, de
    lectura pública; si no se pueden cargar, la pantalla muestra directamente los datos de
    contacto (flujo alterno del CU-42).
11. **La exportación del Dashboard es un CSV.** Lo abre Excel directamente (paso 5 del
    CU-38) y no suma dependencias.

---

## 4. Orden de ejecución

Una fase, un commit por caso de uso. Cada migración se aplica y se verifica con su guion
antes de construir encima.

| Fase | Ítem | Migración | Qué |
|---|---|---|---|
| 1 | T-12 + T-13 | 0034 | `sanciones`, `apelaciones`, `parametros_sistema`, `accesos_admin`, `preguntas_frecuentes`; columnas de moderación en `denuncias` y `calificaciones`; tipos de aviso nuevos; guard de `perfiles` |
| 2 | CU-34 | 0035 | `registrar_acceso_admin`, `/admin/ingresar` |
| 3 | CU-38 | 0036 | `dashboard_admin(desde, hasta)`, Dashboard (Fig. 3.20), exportación CSV |
| 4 | CU-35 | 0037 | Validaciones (Fig. 3.21), `resolver_verificacion`, Storage del admin |
| 5 | CU-37 | 0038 | Categorías (Fig. 3.23): alta, edición, ocultar, borrar sin profesionales |
| 6 | CU-36 | 0039 | Usuarios: buscador, detalle y `suspender_cuenta` |
| 7 | CU-39 | 0040 | Denuncias (Fig. 3.22): gravedad, detalle, resolver y desestimar |
| 8 | CU-46 | 0041 | Reportar reseña, filtro automático y moderación |
| 9 | CU-47 | 0042 | Parámetros globales cableados a la base |
| 10 | CU-49 | 0043 | «Cuenta suspendida», apelación y su resolución en el panel |
| 11 | CU-42 | 0044 | `/ayuda` con las preguntas frecuentes y los canales de contacto |
| 12 | T-04 | — | Manual de Usuario |
| 13 | T-03 | — | Migraciones y funciones aplicadas, Web publicada, builds de distribución |
| 14 | Cierre | — | Analyze, pruebas, builds, merge, tag `v1.0.0`, `CHANGELOG.md`, apartado 7.6 |

---

## 5. Lo que depende de acciones fuera del repo

| Qué | Dónde | Para qué |
|---|---|---|
| Cuentas de desarrollador | Apple Developer Program (anual) y Google Play Console (alta única) | Distribución por TestFlight y prueba interna (T-03) |
| Publicar la Web | `firebase deploy --only hosting` | T-03: la Web con el panel |

## 6. Convención de commits

```
feat(T-12,T-13): esquema de administración y guard de columnas de perfiles
feat(CU-34): ingreso del administrador con registro de accesos
docs(S6): completar el apartado 7.6 del documento vivo
```
