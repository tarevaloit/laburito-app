# Sprint 5 — Cierre · Sección 7.5

**Laburito · Seminario de Integración Profesional 2026 · Comisión P03**

Texto del apartado 7.5 tal como va en el documento de Planificación y Desarrollo. Generado por `figuras/generar-cierre-s5-docx.js`, que produce también el `.docx`.

---

## 7.5 Sprint 5 — Enlaces Públicos y Calificación

**Estado: cerrado.** Los siete ítems comprometidos se implementaron y se verificaron contra la base real: el Profesional comparte su perfil por enlace, el Buscador lo consulta y lo califica desde el navegador sin registrarse, y ambos reciben sus avisos en el centro de notificaciones. La Web quedó publicada y el release v0.5.0 etiquetado en el repositorio.

| Atributo | Detalle |
|---|---|
| Paquete de trabajo | PT 6.0 |
| Período de desarrollo | 01/10/2026 al 14/10/2026 |
| Fecha de entrega por BB | 14/10/2026 hasta las 23:59 |
| Fecha de reunión | 15/10/2026 |
| Esfuerzo comprometido | 39 puntos (7 ítems): 35 del apartado 4.5 más el CU-18 replanificado |
| Esfuerzo real ejecutado | 39 puntos de alcance cerrado |
| Alcance cerrado | 7 de 7 ítems (100 %) |
| Requerimientos cubiertos | RF05, RF07, RF10; por la ERS, además RF01 (CU-18), RF02 (CU-48) y RF09 (CU-45) |
| Release | v0.5.0 — circuito de reputación y vistas públicas sin registro |
| Repositorio | https://github.com/tarevaloit/laburito |
| Estado del sprint | Cerrado. Compromiso cumplido en su totalidad. |

**Objetivo del sprint (recordatorio del apartado 4.5).** Cerrar el circuito de confianza del modelo «Frictionless»: el Profesional comparte su perfil por enlace, el Buscador lo consulta y lo califica desde el navegador sin instalar la aplicación ni registrarse. **El objetivo se considera alcanzado.**

### 7.5.1 Tareas planificadas y esfuerzo real

| ID | Tarea / Caso de Uso | Pts | Estado | Evidencia (commit) |
|---|---|---|---|---|
| T-11 | Esquema de reputación, enlaces y actividad con sus políticas RLS (infraestructura) | — | Hecho | 008afbd |
| CU-26 | Compartir Perfil Público (vía link) | 6 | Hecho | 8400bcd |
| CU-27 | Acceder a Perfil por Link | 5 | Hecho | 8400bcd |
| CU-28 | Calificar Profesional (vía link de un solo uso) | 8 | Hecho | 52b09ec |
| CU-48 | Ver Notificaciones de Actividad | 7 | Hecho | 93b0174 |
| CU-45 | Ver Métricas de Perfil | 5 | Hecho | c7d8a93 |
| CU-41 | Reportar Usuario | 4 | Hecho | 68778ce |
| CU-18 | Solicitar Reenvío de Enlace de Gestión | 4 | Hecho | 66d208a |
| TOTAL | 7 ítems comprometidos — 7 completados | 39 | 100 % | 12 commits |

**Lectura del resultado.** El sprint cerró su compromiso completo y salda el CU-18, arrastrado desde el Sprint 2. Como en el Sprint 4, la ejecución se concentró al final del período (ver 7.5.5 a). La T-11 no lleva puntos, con el criterio de la T-07 y la T-10.

**Desvío respecto de la ERS en el CU-18.** La ERS supone un Buscador sin cuenta que gestiona su pedido con un enlace por correo; en Laburito el Buscador está registrado (CU-01). El «enlace de gestión» se implementó como un enlace de acceso de un solo uso, enviado por Supabase Auth, que abre la sesión directamente en el pedido. Se conservan las reglas del caso de uso: solo con pedidos activos, cada pedido nuevo invalida el anterior y la respuesta es siempre genérica.

### 7.5.2 Diagramas de flujo

Flujo principal y alternos de cada caso de uso del sprint.

*Figura 6 — CU-26 Compartir Perfil Público (vía link).*

> Pegar acá el diagrama de flujo.

*Figura 7 — CU-27 Acceder a Perfil por Link.*

> Pegar acá el diagrama de flujo.

*Figura 8 — CU-28 Calificar Profesional (vía link de un solo uso).*

> Pegar acá el diagrama de flujo.

*Figura 9 — CU-48 Ver Notificaciones de Actividad.*

> Pegar acá el diagrama de flujo.

*Figura 10 — CU-45 Ver Métricas de Perfil.*

> Pegar acá el diagrama de flujo.

*Figura 11 — CU-41 Reportar Usuario.*

> Pegar acá el diagrama de flujo.

*Figura 12 — CU-18 Solicitar Reenvío de Enlace de Gestión.*

> Pegar acá el diagrama de flujo.

### 7.5.3 Evidencia de la ejecución

| Control ejecutado al cierre | Resultado |
|---|---|
| flutter analyze | 0 issues |
| flutter test | 362 pruebas en verde (317 al cierre del Sprint 4), con una prueba de recorrido por cada pantalla nueva |
| Builds | Web y APK de Android compilan |
| Migraciones | 0027 a 0033 aplicadas y verificadas contra la base: 59 reglas de aceptación en OK |
| Edge Functions | perfil_publico y reenviar_enlace_gestion desplegadas sin sesión |
| Web publicada | https://byto-laburitoapp-2e5af.web.app (Firebase Hosting) |
| Prueba de punta a punta | Compartir el perfil desde la app → abrirlo sin cuenta en el navegador del celular → pedir la calificación por WhatsApp y registrarla → aviso en la campana y en las métricas → reporte desde el perfil y alerta en el panel del administrador |
| Tag de release | v0.5.0 |

### 7.5.4 Tareas faltantes y replanificación

No quedó ningún ítem del compromiso sin cerrar. Se arrastra lo siguiente:

| Ítem arrastrado | Justificación | Sprint de resolución |
|---|---|---|
| Alta de cuentas de desarrollador de Apple y Google | Mitigación del apartado 6, trasladada desde el Sprint 3. Es condición de la T-03. | Sprint 6 (primera tarea) |
| Firma de los avisos de Mercado Pago | Sigue sin confirmarse; la acreditación no depende de ellos (7.4.4 b). | Sprint 6 |

### 7.5.5 Problemas encontrados

**a) El sprint arrancó con el período casi agotado.** Entre el 01/10 y el 12/10 no hubo ejecución, y el punto de control de mitad de período fijado en el 7.4.7 no se cumplió. *Solución:* se sostuvo el compromiso completo con el método de los sprints anteriores —el esquema en una primera migración (T-11) y cada migración verificada con su guion antes de construir encima—. *Aprendizaje:* es el segundo sprint seguido con la ejecución al final; el ajuste para el Sprint 6 es de calendario, no de alcance.

**b) Las pruebas de recorrido encontraron defectos antes que el usuario.** Las estrellas del perfil público desbordaban la pantalla del celular, el gráfico de métricas también, y el botón de compartir seguía cargando detrás de la alerta de cuenta suspendida. *Solución:* corregidos antes de la prueba en el teléfono. *Aprendizaje:* confirma el tercer ajuste del 7.4.7.

**c) La red de la facultad bloquea la Web publicada.** Su firewall intercepta las conexiones seguras y el navegador rechaza el sitio. *Solución:* las pruebas y la demostración se hacen con datos móviles. *Aprendizaje:* la demostración tiene que ensayarse en la red donde se va a presentar.

### 7.5.6 Burndown del proyecto tras el Sprint 5

El gráfico siguiente incorpora el quinto punto medido de la línea de ejecución real. Se conservan la línea ideal y la línea planificada tal como fueron publicadas en la Sección 1.

*Figura 13 — Burndown con la ejecución real acumulada al cierre del Sprint 5.*

> Pegar acá la captura del burndown chart.

| Etiqueta | Esf. remanente (planificado) | Esf. remanente (real) |
|---|---|---|
| Inicio | 235 | 235 |
| Sprint 1 | 200 | 200 |
| Sprint 2 | 160 | 169 |
| Sprint 3 | 115 | 119 |
| Sprint 4 | 65 | 69 |
| Sprint 5 | 30 | 30 |
| Sprint 6 | 0 |  |

**Lectura del gráfico.** Con el CU-18 cerrado, la línea real alcanza a la planificada por primera vez desde el Sprint 1: quedan 30 puntos, los del Sprint 6. El avance acumulado llega al 87,2 %, igual al planificado.

### 7.5.7 Correcciones al apartado 7.4

| En el apartado 7.4 | Corrección |
|---|---|
| El 7.4.7 fija un punto de control a mitad del período, con el orden de descarte aplicado en ese momento. | No se cumplió (7.5.5 a). Al arrancar se decidió sostener el compromiso completo sin orden de descarte. |
| El 7.4.7 pone las mitigaciones del apartado 6 como primeras tareas. | La actividad periódica sobre Supabase se automatizó al inicio del sprint. El alta de las cuentas de desarrollador no se ejecutó (7.5.4). |

### 7.5.8 Conclusiones y ajustes para el Sprint 6

El sprint cumplió su objetivo y deja el proyecto en la línea planificada. Se trasladan tres ajustes al Sprint 6.

**Primero, días de trabajo fijos desde el inicio del período.** Dos sprints seguidos se ejecutaron al final; el Sprint 6 coincide con el tercer parcial y no tiene margen.

**Segundo, las cuentas de desarrollador el primer día.** La T-03 las necesita y su habilitación no depende del proyecto.

**Tercero, ensayar la demostración en la red de la facultad.**

**Punto de partida del Sprint 6.** Los doce ítems del apartado 4.6 (30 puntos). Las tablas de calificaciones y denuncias de este sprint ya contemplan la moderación (CU-46) y la gestión de denuncias (CU-39).
