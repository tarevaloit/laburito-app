# Sprint 3 — Cierre · Sección 7.3

**Laburito · Seminario de Integración Profesional 2026 · Comisión P03**
**PT 4.0 · 03/09/2026 → 16/09/2026 · Release v0.3.0 / v0.3.1**

Texto listo para pegar al final del documento *Planificación y Desarrollo*. Antes
de pegar, ver las tres indicaciones de la última sección de este archivo.

---
---

## 7.3 Sprint 3 — Perfil del Profesional y Notificaciones

**Estado: cerrado.** Los trece ítems comprometidos se implementaron dentro del
período, incluido el CU-21, verificado de punta a punta con una notificación real
en un dispositivo Android. Los releases v0.3.0 y v0.3.1 quedaron etiquetados en el
repositorio.

| Atributo | Detalle |
|---|---|
| Paquete de trabajo | PT 4.0 |
| Período de desarrollo | 03/09/2026 al 16/09/2026 |
| Fecha de entrega por BB | 16/09/2026 hasta las 23:59 |
| Fecha de reunión | 17/09/2026 |
| Esfuerzo comprometido | 56 puntos (13 ítems) |
| Esfuerzo real ejecutado | 56 puntos de alcance cerrado |
| Alcance cerrado | 13 de 13 ítems (100 %) |
| Requerimientos cubiertos | RF02, RF03, RF08 |
| Release | v0.3.0 (cierre del sprint) y v0.3.1 (CU-21 verificado con Firebase) |
| Estado del sprint | Cerrado. Compromiso cumplido en su totalidad. |

**Objetivo del sprint (recordatorio del apartado 4.3).** Completar el lado del
Profesional y conectar la publicación de un pedido con la alerta geolocalizada en
el celular. **El objetivo se considera alcanzado:** el Profesional configura su zona,
sus oficios, sus horarios y su portafolio, ve los pedidos cercanos ordenados por
distancia, y recibe una notificación cuando se publica uno que le corresponde.

### 7.3.1 Tareas planificadas y esfuerzo real

El compromiso fue de 56 puntos y no de los 45 del apartado 4.3: se sumaron los 5
del CU-17 replanificado (apartado 7.2.3) y 6 puntos de deuda técnica con
estimación propia, en aplicación del segundo ajuste del apartado 7.2.7.

| ID | Tarea / Caso de Uso | Pts | Estado | Evidencia (commit) |
|---|---|---|---|---|
| CU-17 | Consultar Historial *(replanificado del Sprint 2)* | 5 | Hecho | `0f6df51` |
| T-06 | Pruebas de widget de los formularios de pedido *(deuda)* | 3 | Hecho | `07375ec` |
| T-07 | Esquema del Profesional con sus políticas RLS *(infraestructura)* | — | Hecho | `76137a4` |
| T-08 | Fotografías visibles para el Profesional y protección de la edición *(deuda)* | 3 | Hecho | `de98be8` |
| CU-07 | Configurar Zona de Cobertura | 5 | Hecho | `a38c349` |
| CU-12 | Editar Categorías de Oficio | 4 | Hecho | `d4cabe7` |
| CU-21 | Recibir Alerta Push | 14 | Hecho | `bdd5dc6` … `5aad5a1` (7 commits) |
| CU-43 | Explorar Tablero de Pedidos | 5 | Hecho | `96a2f6b` |
| CU-22 | Ver Detalle de Pedido | 3 | Hecho | `96a2f6b` |
| CU-23 | Ignorar Pedido | 2 | Hecho | `7c983b1` |
| CU-24 | Guardar Pedido (Favorito) | 2 | Hecho | `7c983b1` |
| CU-44 | Gestionar Horarios y disponibilidad | 5 | Hecho | `6a3239c` |
| CU-06 | Cargar Portafolio | 5 | Hecho | `0a4b436` |
| | **Total — 13 de 13 ítems** | **56** | **100 %** | |

**Lectura del resultado.** Es el primer sprint que cierra un compromiso mayor al
planificado. Cuatro factores lo explican: el modelo de datos del Profesional se
resolvió completo en la primera fase (T-07) en lugar de repartirse entre los casos
de uso, que fue la causa del desvío del Sprint 2; los casos de uso se apoyaron en
componentes ya construidos (el selector de ubicación del CU-16, la carga de
imágenes del CU-09, la tarjeta y el paginado del CU-17); cada migración se verificó
contra la base real antes de escribir código sobre ella; y ningún ítem superó su
estimación de manera significativa. La T-07 no lleva puntos, con el mismo criterio
que la T-02b del Sprint 2.

**Sobre el registro del esfuerzo.** A partir de este sprint el esfuerzo se informa
solo en puntos de alcance cerrado y se discontinúa la columna de horas, que en el
Sprint 2 había sido una equivalencia derivada y no una medición (ver 7.3.6).

### 7.3.2 Evidencia de la ejecución

Se sostiene la convención de commits con el identificador del caso de uso. El
listado completo se adjunta como `evidencia-sprint-03.txt`.

| Control al cierre | Resultado |
|---|---|
| `flutter analyze` | 0 issues |
| `flutter test` | 273 pruebas en verde (163 al cierre del Sprint 2) |
| Builds | Web, APK de Android e iOS (simulador) compilan |
| Migraciones | 0012 a 0019 aplicadas y verificadas contra la base, cada una con su guion de aceptación |
| Edge Function | `emparejar_pedido` desplegada |
| Prueba de punta a punta | Pedido publicado desde la Web → notificación recibida en Android → apertura del detalle |
| Releases | `v0.3.0` y `v0.3.1` |

**Material complementario.** Video de demostración del circuito completo: el
Buscador publica un pedido en la Web y el Profesional recibe la alerta en el celular,
abre el detalle y lo guarda; además, configuración de zona, oficios, horarios y
portafolio.

### 7.3.3 Tareas faltantes y replanificación

No quedó ningún ítem del compromiso sin cerrar. Se arrastra únicamente lo siguiente:

| Ítem | Justificación | Sprint |
|---|---|---|
| CU-18 Reenvío de enlace de gestión | Replanificación ya registrada en el apartado 7.2.3; sin cambios | Sprint 5 |
| Lectura de la ubicación exacta por la API | Las pantallas del Profesional usan la vista pública, pero la política de lectura de pedidos vigentes permite consultar la fila completa. Se corrige antes de habilitar el contacto entre las partes | Sprint 4 |
| Columnas sensibles del Profesional | La política de actualización del Profesional abarca la fila entera, incluida la verificación y el saldo de tokens. Se protege con un disparador, igual que el estado del pedido | Sprint 4 |
| Notificaciones en iOS | Requieren la cuenta del Apple Developer Program. Android y Web quedan operativos | Sprint 6 (T-03) |
| Mitigaciones del apartado 6 | No se ejecutaron la validación del entorno de prueba de Mercado Pago ni el alta de las cuentas de desarrollador de Apple y Google, previstas para este sprint. La primera se hace el primer día del Sprint 4, antes del CU-31; el alta de cuentas, dentro del mismo sprint | Sprint 4 |

### 7.3.4 Problemas encontrados

Se documentan los tres que consumieron tiempo y dejan un aprendizaje trasladable.

**a) La revocación de permisos sobre funciones no tenía efecto.** Las migraciones
revocaban la ejecución de las funciones al rol público, pero Supabase otorga ese
permiso de manera explícita a los roles anónimo y autenticado, y la revocación
genérica no lo alcanza. En la función que determina a qué Profesionales se les
envía la alerta, eso permitía averiguar dónde hay Profesionales cerca de un punto.
*Solución:* revocación explícita a cada rol y verificación sobre el catálogo.
*Aprendizaje:* un permiso se da por cerrado cuando se comprueba, no cuando se
escribe.

**b) La alerta no se disparaba desde la Web.** El navegador envía una consulta
previa antes de invocar la función del servidor, y la función la rechazaba. Como la
publicación del pedido no falla si falla la alerta, el defecto no era visible en
pantalla. *Solución:* responder la verificación del navegador. *Aprendizaje:* lo
que se hace a propósito silencioso necesita una prueba que lo mire.

**c) Tocar la notificación abría la pantalla del dueño del pedido.** La navegación
llevaba al detalle del Buscador —que muestra la dirección exacta— y, al volver,
dejaba al Profesional en «Mis pedidos». Se detectó en la prueba con un dispositivo
real. *Solución:* abrir el detalle del Profesional apilado sobre el tablero, y
validar el rol en las pantallas del Buscador. *Aprendizaje:* las pruebas
automáticas verificaban qué pantalla se abría pero no qué quedaba debajo.

### 7.3.5 Burndown del proyecto tras el Sprint 3

*Figura 4 — Burndown con la ejecución real acumulada al cierre del Sprint 3.*

> Insertar acá `figuras/burndown-sprint-03.png`.

| Etiqueta | Remanente planificado | Remanente real |
|---|---|---|
| Inicio | 235 | 235 |
| Sprint 1 | 200 | 200 |
| Sprint 2 | 160 | 169 |
| Sprint 3 | 115 | 119 |

**Lectura del gráfico.** La línea real se acerca a la planificada: la distancia pasa
de 9 puntos al cierre del Sprint 2 a 4 al cierre del Sprint 3, y esos 4 son
exactamente el CU-18 trasladado al Sprint 5. El alcance cerrado del backlog en este
sprint es de 50 puntos (los 6 de deuda técnica no descuentan backlog) y el avance
acumulado llega al 49,4 %, frente al 51,1 % planificado. No se activa la cláusula de
descarte del apartado 6: el Sprint 3 era el de recuperación y la cumplió.

### 7.3.6 Correcciones al apartado 7.2

El documento es incremental, de modo que el apartado 7.2 no se modifica: sus
errores se registran y se corrigen acá.

| En el apartado 7.2 | Corrección |
|---|---|
| La tabla del 7.2.5 consigna remanentes reales de 205 y 174 | Descontaba el esfuerzo medido del Sprint 1 (30) en lugar de su alcance cerrado (35), contra el criterio del propio 7.2.1. Los valores correctos son **200 y 169**, y así se grafican en la Figura 4 |
| La tabla del 7.2.1 y la Figura 3 quedaron con marcas de edición sin completar («[__]» y «Regenerar si…») | Se reemplazan por la evidencia de este apartado: la Figura 4 sustituye a la Figura 3 y los commits del Sprint 2 están en su archivo de evidencia |
| El 7.2.1 anuncia que el registro de horas por ítem «se restablece en el Sprint 3» | No se restableció: se discontinuó la columna de horas y el esfuerzo se informa solo en puntos de alcance cerrado (7.3.1) |
| El 7.2.7 fija un punto de control al séptimo día | El control del 09/09 no se ejecutó. Se reemplazó por controles sobre el tramo final; el del cierre del tablero (Fase 7) quedó registrado en el plan del sprint y confirmó que no hacía falta descartar alcance |
| El 7.2.7 fija el descarte sobre el CU-23 y el CU-24 | Se modificó el orden (primero CU-06, después CU-44), porque esos dos sumaban solo 4 puntos. Finalmente no hizo falta descartar nada |
| El 7.2.6 indica que la firma de las URL de las fotografías expira a la hora | Expira a los 30 minutos, con renovación anticipada |

### 7.3.7 Conclusiones y ajustes para el Sprint 4

El sprint cumplió su objetivo y su compromiso completo, que además era el más
cargado del proyecto hasta aquí. Se trasladan tres ajustes al Sprint 4:

**Primero, cerrar las dos deudas de seguridad antes del circuito de pago.** La
lectura de la ubicación exacta y la protección de las columnas del Profesional se
resuelven al inicio, porque el CU-25 desbloquea el contacto y el CU-31 acredita
tokens: son justamente los datos que hoy quedan expuestos.

**Segundo, sostener la verificación contra la base real.** Cada migración de este
sprint se aplicó y se probó con su guion antes de construir encima, y ningún
problema de modelo de datos llegó a la interfaz. El Sprint 4 depende de Mercado
Pago, así que el mismo criterio se aplica a su entorno de prueba desde el primer día.

**Tercero, probar en un dispositivo antes de dar un caso de uso por cerrado.** Dos
de los tres problemas del 7.3.4 aparecieron recién con la aplicación instalada.

**Punto de partida del Sprint 4.** Arranca con las dos deudas de seguridad y sigue
por el CU-31 y el CU-32, que concentran 22 de sus 50 puntos y la integración con el
servicio externo. El remanente del proyecto es de 119 puntos repartidos en tres
sprints.

---
---

## Antes de pegar

1. **Tabla de revisión.** Agregar la fila
   `1.3 | 16/09/2026 | Sprint 3: Perfil del Profesional y Notificaciones. | T. N. Arévalo`
   y cambiar «Última versión» de la portada a **1.3**.
2. **Tabla de contenidos.** Hoy termina en *7.1 Sprint 1*: le falta la 7.2. Agregar
   *7.2 Sprint 2 — Gestión de Pedidos y Geolocalización* y
   *7.3 Sprint 3 — Perfil del Profesional y Notificaciones*. Actualizar el índice no
   modifica el contenido de la Sección 1.
3. **Figura 4.** Insertar `docs/sprints/figuras/burndown-sprint-03.png` en el
   apartado 7.3.5 y adjuntar `docs/sprints/evidencia-sprint-03.txt` a la entrega.
