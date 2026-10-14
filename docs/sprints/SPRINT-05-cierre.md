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

**Lectura del resultado.** El sprint cerró su compromiso completo según lo planificado y salda el CU-18, arrastrado desde el Sprint 2. Se sostuvo el método de los sprints anteriores: el esquema completo en una primera migración (T-11) y cada migración verificada con su guion antes de construir encima. La T-11 no lleva puntos, con el criterio de la T-07 y la T-10.

**Desvío respecto de la ERS en el CU-18.** La ERS supone un Buscador sin cuenta que gestiona su pedido con un enlace por correo; en Laburito el Buscador está registrado (CU-01). El «enlace de gestión» se implementó como un enlace de acceso de un solo uso, enviado por Supabase Auth, que abre la sesión directamente en el pedido. Se conservan las reglas del caso de uso: solo con pedidos activos, cada pedido nuevo invalida el anterior y la respuesta es siempre genérica.

### 7.5.2 Evidencia de la ejecución

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

### 7.5.3 Tareas faltantes y replanificación

No quedó ningún ítem del compromiso sin cerrar. Se arrastra lo siguiente:

| Ítem arrastrado | Justificación | Sprint de resolución |
|---|---|---|
| Alta de cuentas de desarrollador de Apple y Google | Mitigación del apartado 6, trasladada desde el Sprint 3. Es condición de la T-03. | Sprint 6 (primera tarea) |
| Firma de los avisos de Mercado Pago | Sigue sin confirmarse; la acreditación no depende de ellos (7.4.4 b). | Sprint 6 |

### 7.5.4 Problemas encontrados

Se documentan los dos que dejan un aprendizaje trasladable al Sprint 6.

**a) Las pruebas de recorrido encontraron defectos antes que el usuario.** Las estrellas del perfil público desbordaban la pantalla del celular, el gráfico de métricas también, y el botón de compartir seguía cargando detrás de la alerta de cuenta suspendida. *Solución:* corregidos antes de la prueba en el teléfono. *Aprendizaje:* confirma el tercer ajuste del 7.4.7.

**b) La red de la facultad bloquea la Web publicada.** Su firewall intercepta las conexiones seguras y el navegador rechaza el sitio. *Solución:* las pruebas y la demostración se hacen con datos móviles. *Aprendizaje:* la demostración tiene que ensayarse en la red donde se va a presentar.

### 7.5.5 Burndown del proyecto tras el Sprint 5

El gráfico siguiente incorpora el quinto punto medido de la línea de ejecución real. Se conservan la línea ideal y la línea planificada tal como fueron publicadas en la Sección 1.

*Figura 6 — Burndown con la ejecución real acumulada al cierre del Sprint 5.*

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

### 7.5.6 Correcciones al apartado 7.4

| En el apartado 7.4 | Corrección |
|---|---|
| El 7.4.7 pone las mitigaciones del apartado 6 como primeras tareas. | La actividad periódica sobre Supabase quedó automatizada. El alta de las cuentas de desarrollador no se ejecutó y se traslada al Sprint 6 (7.5.3). |

### 7.5.7 Conclusiones y ajustes para el Sprint 6

El sprint cumplió su objetivo y deja el proyecto en la línea planificada. Se trasladan tres ajustes al Sprint 6.

**Primero, las cuentas de desarrollador como primera tarea.** La T-03 las necesita y su habilitación no depende del proyecto.

**Segundo, sostener la prueba de recorrido por pantalla.** En este sprint encontró los defectos del 7.5.4 a antes de la prueba en el teléfono; el Panel de Administración del Sprint 6 suma varias pantallas nuevas.

**Tercero, ensayar la demostración en la red donde se presenta** (7.5.4 b).

**Punto de partida del Sprint 6.** Los doce ítems del apartado 4.6 (30 puntos). Las tablas de calificaciones y denuncias de este sprint ya contemplan la moderación (CU-46) y la gestión de denuncias (CU-39).
