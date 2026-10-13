# SPRINT 05 — Enlaces Públicos y Calificación (PT 6.0)

> Plan de ejecución del sprint. Vive en `docs/sprints/SPRINT-05.md`.
> Se deriva del apartado 4.5 de la planificación y de los ajustes del apartado 7.4.7.
> Última actualización: 13/10/2026

---

## 1. Encuadre

| Campo | Valor |
|---|---|
| Paquete de trabajo | PT 6.0 |
| Período | 01/10/2026 al 14/10/2026 |
| Entrega por BB | 14/10/2026 hasta las 23:59 |
| Reunión | 15/10/2026 |
| Release objetivo | v0.5.0 — circuito de reputación y vistas públicas sin registro |
| Rama | `sprint-5`, salida de `main` en `v0.4.0` |
| Remanente al inicio | 69 puntos |
| Requerimientos cubiertos | RF05, RF07, RF10 (apartado 4.5); por la ERS, además RF01 (CU-18), RF02 (CU-48) y RF09 (CU-45) |

**Objetivo del sprint (apartado 4.5).** Cerrar el circuito de confianza del modelo
«Frictionless»: el Profesional comparte su perfil por enlace, el Buscador lo consulta y lo
califica desde el navegador sin instalar la aplicación ni registrarse.

**Punto de partida real.** El trabajo del sprint arranca el 13/10: entre el 01/10 y el 12/10
no hubo ejecución. El punto de control de mitad de período que fijó el primer ajuste del
7.4.7 (la mitad del alcance cerrada al 07/10) **no se cumplió**: al 07/10 había 0 de 39
puntos. Se decidió el 13/10 sostener el compromiso completo **sin orden de descarte**; lo
que no cierre al 14/10 se registra como replanificado en el apartado 7.5.3. El desvío del
ajuste se documenta en el 7.5, no se esconde.

---

## 2. Compromiso del sprint: 39 puntos

| Origen | Pts |
|---|---|
| Alcance planificado del PT 6.0 (apartado 4.5) | 35 |
| CU-18 replanificado desde el Sprint 2 (apartados 7.2.3, 7.3.3 y 7.4.3) | 4 |
| **Total** | **39** |

### 2.1 Alcance

Estados: `⬜ pendiente` · `🟡 en curso` · `✅ hecho` · `⏭️ replanificado`

| ID | Tarea / Caso de Uso | Tipo | Pts | Estado | Evidencia |
|---|---|---|---|---|---|
| T-11 | Esquema de reputación, enlaces y actividad con sus políticas RLS (infraestructura) | Backend | — | ⬜ | |
| CU-26 | Compartir Perfil Público (vía link) | Full-stack | 6 | ⬜ | |
| CU-27 | Acceder a Perfil por Link | Frontend | 5 | ⬜ | |
| CU-28 | Calificar Profesional (vía link de un solo uso) | Full-stack | 8 | ⬜ | |
| CU-48 | Ver Notificaciones de Actividad | Full-stack | 7 | ⬜ | |
| CU-45 | Ver Métricas de Perfil | Full-stack | 5 | ⬜ | |
| CU-41 | Reportar Usuario | Full-stack | 4 | ⬜ | |
| CU-18 | Solicitar Reenvío de Enlace de Gestión | Backend | 4 | ⬜ | |
| | **Total** | | **39** | | |

La T-11 no lleva puntos, con el criterio de la T-07 y la T-10: es la infraestructura sin la
cual los casos de uso no existen, y su esfuerzo está dentro de sus estimaciones.

### 2.2 Arrastrado sin puntos

| Ítem | Origen | Cómo se cierra |
|---|---|---|
| Actividad periódica sobre Supabase | Ajuste 2 del 7.4.7 (riesgo «Límites del plan gratuito») | Workflow de GitHub Actions que consulta la API cada tres días |
| Alta de las cuentas de desarrollador de Apple y Google | 7.4.3, ajuste 2 del 7.4.7 | Acción del responsable: tiene costo y es externa al repo. Se registra la fecha de alta |
| Firma de los avisos de Mercado Pago | 7.4.3 | Con una compra de prueba: el log del webhook no muestra `[webhook] FIRMA INVÁLIDA` y el pago se acredita por el aviso |
| Despliegue de la Web en Firebase Hosting | Decisión del 13/10 | Adelanto parcial de la T-03, que sigue en el Sprint 6 con sus puntos (falta la distribución de la app) |

---

## 3. Decisiones de diseño

Se toman al planificar porque condicionan el esquema de la T-11.

1. **Los enlaces apuntan a la Web publicada.** La URL base vive en `.env` como `WEB_URL`
   y la app la lee con `--dart-define-from-file`, igual que las claves de Supabase. La Web
   se despliega en Firebase Hosting, en el proyecto que ya usa el CU-21. Las rutas son las
   del Anexo UI: `/p/<slug>` (Fig. 3.6) y `/calificar/<token>` (Fig. 3.7), con la estrategia
   de URL por ruta y no por `#`.
2. **El perfil público tiene un slug, no el id.** `nombre-apellido` más un sufijo
   aleatorio: legible como en la Figura 3.6 y no enumerable. Lo genera el servidor la
   primera vez que se comparte; el cliente no lo puede escribir (guard de la 0020).
3. **El perfil público se sirve con una Edge Function, no con una RPC para `anon`.** El
   bucket `portafolios` es privado y firmar sus URLs exige la clave de servicio. La misma
   función registra la visita que cuenta el CU-45. Si el perfil no existe, está dado de
   baja o suspendido, la Web muestra el 404 propio del flujo alterno del CU-27.
4. **El enlace de calificación nace de un contacto desbloqueado.** El Profesional lo genera
   desde el pedido cuyo contacto pagó (CU-25) y se lo manda por WhatsApp al Buscador. Es lo
   que pide la ERS como protección contra reseñas falsas: no hay enlace sin un contacto
   real pagado con un token, cada enlace se usa una vez y generar otro invalida el anterior
   sin usar. En la base se guarda el hash del token, nunca el token.
5. **El promedio lo recalcula el servidor.** `registrar_calificacion` bloquea el enlace,
   inserta la calificación y actualiza `calificacion_promedio` y `total_calificaciones` en
   la misma transacción. Corre como dueña, así que pasa el guard de la 0020.
6. **Las notificaciones se escriben con disparadores**, no desde el cliente: nuevo
   interesado (al Buscador), calificación recibida, verificación resuelta y pago acreditado
   (al Profesional), denuncia nueva (a los administradores). El usuario lee, marca leídas y
   borra las suyas; nadie inserta por la API.
7. **CU-18 con el enlace mágico de Supabase Auth.** En Laburito el Buscador tiene cuenta, de
   modo que el «enlace de gestión» de la ERS es un acceso de un solo uso que abre la sesión
   directamente en sus pedidos. Una Edge Function busca pedidos activos para el correo y,
   si los hay, pide a Supabase Auth el envío: cada pedido nuevo invalida el enlace anterior
   y la respuesta es siempre el mensaje genérico del flujo alterno. No suma un proveedor
   de correo.
8. **La efectividad del CU-45 es «contactos que terminaron en calificación» sobre
   «contactos abiertos»** (Fig. 3.18: «de cada contacto abierto, ¿conseguís el trabajo?»).
   Una calificación es la única prueba en el sistema de que el trabajo se hizo.
9. **El Buscador denuncia desde el perfil público** (con sesión), porque el CU-25 decidió
   que no ve quiénes son los interesados de su pedido. El Profesional denuncia desde el
   detalle del pedido. La alerta al administrador es una sección «Denuncias» en el panel
   con su contador; resolverlas es el CU-39 del Sprint 6.

---

## 4. Orden de ejecución

El orden respeta dependencias reales. Una fase, un commit por caso de uso.

### Fase 0 — Arranque y mitigaciones · sin puntos
Rama `sprint-5`, este plan, workflow de actividad periódica sobre Supabase, `WEB_URL` en
`.env.example`, estrategia de URL por ruta y configuración de Firebase Hosting.

### Fase 1 — T-11 · migración 0027 · infraestructura
Slug público en `profesionales`; `calificaciones` y `enlaces_calificacion`;
`perfil_visitas`; `notificaciones`; `denuncias`. Cada tabla con su RLS pegada al
`create table`, y `scripts/verificar_0027.sql` con el patrón de guion que aborta.

### Fase 2 — CU-26 Compartir Perfil · 6 pts
RPC `obtener_enlace_perfil()`: genera el slug si no existe y rechaza una cuenta suspendida.
Botón «Compartir mi perfil» en Mi Perfil (Fig. 3.17): copia al portapapeles y abre la hoja
de compartir. Deshabilitado con alerta si la cuenta está suspendida (flujo alterno).

### Fase 3 — CU-27 Acceder a Perfil por Link · 5 pts
Edge Function `perfil_publico` sin JWT y ruta neutral `/p/:slug` en la Web, *mobile first*
(Fig. 3.6): nombre, verificación, estrellas, oficios, trabajos del portafolio y reseñas.
404 propio para un enlace roto o un perfil eliminado.

### Fase 4 — CU-28 Calificar Profesional · 8 pts
RPC `generar_enlace_calificacion(pedido)` desde el detalle del pedido desbloqueado, con el
mensaje de WhatsApp armado. Ruta neutral `/calificar/:token` (Fig. 3.7): estrellas
obligatorias, comentario opcional, agradecimiento; con el enlace ya usado, el formulario se
bloquea con el mensaje del flujo alterno.

**Punto de control: el circuito compartir → ver → calificar probado de punta a punta,
desde el teléfono, antes de seguir.** Es el objetivo del sprint.

### Fase 5 — CU-48 Ver Notificaciones de Actividad · 7 pts
Disparadores de la decisión 6. Campana con contador en la barra superior de la Web y en la
app; centro en `/notificaciones`: orden cronológico, marca leídas al abrir, cada aviso
lleva a su pantalla, «Limpiar todo».

### Fase 6 — CU-45 Ver Métricas de Perfil · 5 pts
RPC `metricas_perfil(periodo)` y pantalla «Mis estadísticas» desde Mi Perfil (Fig. 3.18):
vistas, contactos abiertos, barras por día (semana) o por semana (mes) y efectividad.
Contadores en cero con consejos para un Profesional sin actividad.

### Fase 7 — CU-41 Reportar Usuario · 4 pts
Formulario con motivo obligatorio y descripción; RPC `reportar_usuario` (no a uno mismo,
una denuncia pendiente por par). Sección «Denuncias» en el panel del administrador.

### Fase 8 — CU-18 Reenvío de Enlace de Gestión · 4 pts
Pantalla «Recuperar mi pedido» en la Web y Edge Function `reenviar_enlace_gestion`
(decisión 7). Requiere la plantilla *Magic Link* y las URL de redirección en Supabase.

### Fase 9 — Verificación y cierre
Analyze, pruebas (cada pantalla con la prueba de su recorrido, ajuste 3 del 7.4.7), builds,
migración aplicada con su guion en OK, Edge Functions desplegadas, Web en Firebase Hosting,
circuito completo en el teléfono y en el navegador del celular, merge, tag `v0.5.0`,
`CHANGELOG.md` y apartado 7.5 con su burndown.

---

## 5. Orden de descarte

**No se fija** (decisión del 13/10). Se compromete el alcance completo; un ítem que no
cierre se replanifica al Sprint 6 en el apartado 7.5.3, con su estimación original.

## 6. Puntos de control

| Momento | Qué se contrasta | Corrección si no se cumple |
|---|---|---|
| 07/10 (ajuste 1 del 7.4.7) | La mitad del alcance cerrada | **No se cumplió** (0 de 39). Se registra en el 7.5 |
| Mediodía del 14/10 | Fases 1 a 4: el objetivo del sprint probado en el teléfono | Se completa antes de abrir las Fases 5 a 8 |
| Antes del cierre documental | Migración y funciones aplicadas, Web publicada | Lo que falte se declara en el 7.5.3 |

## 7. Lo que depende de acciones fuera del repo

| Qué | Dónde | Para qué |
|---|---|---|
| Sesión de Firebase CLI y el sitio de Hosting | `firebase login`, consola de Firebase | Publicar la Web (decisión 1) |
| Plantilla *Magic Link* y URL de redirección | Supabase → Authentication → Email Templates y URL Configuration | CU-18 |
| Secretos del workflow | GitHub → Settings → Secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY` | Actividad periódica |
| Cuentas de desarrollador | Apple Developer Program, Google Play Console | Mitigación del apartado 6 para la T-03 |

## 8. Convención de commits

```
chore(S5): actividad periódica sobre Supabase y despliegue de la Web
feat(T-11): esquema de reputación, enlaces y actividad
feat(CU-26): compartir el perfil público con un enlace
feat(CU-28): calificar al profesional con un enlace de un solo uso
docs(S5): completar el apartado 7.5 del documento vivo
```
