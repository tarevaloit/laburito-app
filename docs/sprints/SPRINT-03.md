# SPRINT 03 — Perfil del Profesional y Notificaciones (PT 4.0)

> Plan de ejecución del sprint. Vive en `docs/sprints/SPRINT-03.md`.
> Se deriva del apartado 4.3 de la planificación (v1.2) y de los ajustes
> comprometidos en el apartado 7.2.7.
> Última actualización: 16/09/2026

---

## 1. Encuadre

| Campo | Valor |
|---|---|
| Paquete de trabajo | PT 4.0 |
| Período | 03/09/2026 al 16/09/2026 |
| Entrega por BB | 16/09/2026 hasta las 23:59 |
| Reunión | 17/09/2026 |
| Release objetivo | v0.3.0 — aplicación del Profesional operativa con alertas push |
| Rama | `sprint-3`, salida de `main` una vez mergeado el Sprint 2 |
| Remanente al inicio | 169 puntos (ver nota metodológica más abajo) |
| Requerimientos cubiertos | RF02, RF03, RF08 |

**Objetivo del sprint (apartado 4.3).** Completar el lado del Profesional —perfil,
portafolio, zona de cobertura y disponibilidad— y cerrar el circuito de negocio
central conectando la publicación de un pedido con la alerta geolocalizada en el
celular.

### Nota metodológica sobre el remanente

Se sostiene el criterio del apartado 7.1.1: el remanente se calcula sobre la escala
de la planificación, descontando **alcance cerrado** y no esfuerzo medido. Sobre esa
base, el remanente es 235 − 35 − 31 = **169 puntos**, que es la cifra que usan los
apartados 7.2.3 y 7.2.7. La tabla del apartado 7.2.5 consigna 205 y 174 porque
descuenta el esfuerzo medido del Sprint 1 (30 puntos) en lugar de su alcance cerrado
(35). La divergencia se registra acá y se corrige en la serie real a partir de este
sprint, sin modificar la Sección 1 ni el apartado 7.2, según la norma incremental.

A partir de este sprint el esfuerzo se informa **únicamente en puntos de alcance
cerrado**. Se discontinúa la columna de horas: en el Sprint 1 fue medición directa,
en el Sprint 2 fue una equivalencia derivada presentada como columna de horas, y
sostener el formato sin medición real reintroduce el problema que el propio
apartado 7.2.1 señaló. La velocidad de referencia del apartado 1.1 se conserva como
unidad de estimación, no como registro de tiempo.

---

## 2. Compromiso del sprint

El compromiso son **56 puntos**, que se descomponen así:

| Origen | Pts |
|---|---|
| Alcance planificado del PT 4.0 (apartado 4.3) | 45 |
| CU-17 replanificado desde el Sprint 2 (apartado 7.2.3) | 5 |
| Deuda técnica saldada dentro del sprint, con estimación propia (ajuste 2 de 7.2.7) | 6 |
| **Total** | **56** |

Los 6 puntos de deuda son la aplicación directa del segundo ajuste de la
retrospectiva del Sprint 2: toda deuda que se decida saldar recibe estimación propia
en el momento de planificar el sprint que la absorbe, de modo que el esfuerzo medido
refleje el trabajo realmente hecho. En el Sprint 2 esa deuda (T-05) quedó fuera de la
métrica; acá entra.

Esto convierte al Sprint 3 en el más cargado del proyecto, por encima de los 50 del
Sprint 4. Es la tensión que el apartado 7.2.7 ya había anticipado, agravada por dos
factores propios: la deuda ahora cuenta puntos, y el período efectivo de trabajo se
concentró en su tramo final.

### 2.1 Alcance

Estados: `⬜ pendiente` · `🟡 en curso` · `✅ hecho` · `⏭️ replanificado`

| ID | Tarea / Caso de Uso | Tipo | Pts | Estado | Evidencia |
|---|---|---|---|---|---|
| CU-17 | Consultar Historial (replanificado del Sprint 2) | Frontend | 5 | ✅ | `0f6df51` |
| T-06 | Pruebas de widget de los formularios de pedido (deuda de 7.1.7 y 7.2.3) | Técnica | 3 | ✅ | `07375ec` |
| T-07 | Migración 0012 — esquema del Profesional, con sus políticas RLS en el mismo archivo | Backend | — | ✅ | `feat(T-07)` |
| T-08 | Migración 0013 — deuda del Sprint 2: lectura del bucket para el Profesional y guard del PATCH de edición | Backend | 3 | ✅ | `fix(T-08)` |
| CU-07 | Configurar Zona de Cobertura | Full-stack | 5 | ✅ | `feat(CU-07)` |
| CU-12 | Editar Categorías de Oficio | Full-stack | 4 | ✅ | `feat(CU-12)` |
| CU-21 | Recibir Alerta Push (Edge Function de búsqueda por radio + integración FCM) | Backend | 14 | ✅ | `bdd5dc6` … `5aad5a1` (7 commits) |
| CU-43 | Explorar Tablero de Pedidos | Frontend | 5 | ✅ | `feat(CU-43)` |
| CU-22 | Ver Detalle de Pedido | Frontend | 3 | ✅ | `feat(CU-22)` |
| CU-23 | Ignorar Pedido | Full-stack | 2 | ✅ | `feat(CU-23)` |
| CU-24 | Guardar Pedido (Favorito) | Full-stack | 2 | ✅ | `feat(CU-23)` |
| CU-44 | Gestionar Horarios de Atención y estado de disponibilidad | Full-stack | 5 | ✅ | `feat(CU-44)` |
| CU-06 | Cargar Portafolio | Full-stack | 5 | ✅ | `feat(CU-06)` |
| | **Total** | | **56** | **56 ejecutados** | |

**T-07 no lleva puntos**, con el mismo criterio que la T-02b del Sprint 2: no es un
ítem del backlog sino la infraestructura que los casos de uso del PT 4.0 requieren
para existir, y su esfuerzo está contenido dentro de la estimación de esos casos de
uso. Se lista aparte para dar trazabilidad a la migración. La T-08 **sí** lleva
puntos porque no es infraestructura de este sprint sino deuda declarada del anterior.

---

## 3. Orden de ejecución

El orden respeta dependencias reales, no el orden del backlog. Una fase, un commit.

### Fase 0 — Cierre operativo del Sprint 2 · **bloqueante, sin puntos**

No es alcance del Sprint 3, pero nada de este sprint funciona sin esto y el documento
entregado el 02/09 ya afirma que el tag existe.

1. Aplicar `0011_profesionales_faltantes.sql` sola y primero: no depende de nada y
   destraba el `23503` de la carga de documentación del CU-09.
2. Aplicar en orden `0004`, `0005`, `0006`, `0007`, `0008`, `0009`, `0010`. Correr el
   guion de aceptación comentado al final de cada una.
   `supabase/scripts/verificar_pedidos.sql` dice cuáles están aplicadas; su bloque 8
   avisa del único orden peligroso: la 0008 aplicada a medias deja el sistema peor
   que antes.
3. Circuito completo contra la base: publicar un pedido con foto y ubicación, y
   después pausar, reanudar, editar, renovar, cerrar y cancelar. Es lo que nunca se
   ejercitó.
4. Aprobar a mano un Profesional de prueba con `supabase/scripts/aprobar_profesional.sql`.
5. Merge de `sprint-2` a `main`, tag `v0.2.0` con el mensaje
   *Sprint 2 — Gestión de Pedidos y Geolocalización (PT 3.0)*, push del tag,
   `CHANGELOG.md` con `v0.1.0` y `v0.2.0` agrupados por caso de uso.
6. Salir `sprint-3` de `main`.

### Fase 1 — T-07: migración 0012, esquema del Profesional

Verificar el esquema real antes de escribir (tercer ajuste de 7.2.7). Las políticas
RLS van **en el mismo archivo** que crea cada tabla (primer ajuste de 7.2.7), y toda
vista nueva se declara con invocación por parte del usuario.

Tablas que agrega:

| Tabla | Para |
|---|---|
| `profesional_zona_cobertura` | CU-07 — centro `geography(Point)` calificado desde `extensions`, radio en metros, índice espacial |
| `profesional_horarios` | CU-44 — franjas por día de la semana |
| `profesional_portafolio` | CU-06 — filas de foto con orden, más bucket `portafolio` |
| `profesional_dispositivos` | CU-21 — tokens de FCM por dispositivo |
| `pedido_ignorado` / `pedido_favorito` | CU-23 y CU-24 — clave compuesta (profesional, pedido) |

La columna de disponibilidad del CU-44 va sobre `profesionales`, no en tabla aparte.
Las categorías del CU-12 reutilizan `profesional_categorias`, que ya existe desde el
T-02: no se crea nada, se agrega la política de UPDATE y DELETE que hoy no tiene.

El tope de fotos del portafolio se resuelve **con bloqueo explícito sobre la fila del
profesional antes de contar**, igual que el tope de fotos del pedido de la 0005: toda
restricción de la forma «no más de N» implementada contando filas es una condición de
carrera hasta que se demuestre lo contrario.

**Hecha el 14/09 — `supabase/migrations/0012_profesional_esquema.sql`, aplicada y
verificada.** El esquema real contradijo al plan en cuatro puntos, que quedaron
resueltos en la migración y registrados en la sección 5 de `ESTADO.md`:

| El plan decía | La base tenía | Qué se hizo |
|---|---|---|
| Crear la zona de cobertura | `profesionales.ubicacion` y `radio_cobertura_km` desde la 0001, sin uso | Tabla nueva y **se borran las dos columnas** |
| Agregar la columna de disponibilidad | `profesionales.disponible` desde la 0001 | Nada |
| A `profesional_categorias` le faltan UPDATE y DELETE | Una política `for all` del dueño | Nada: el CU-12 no depende de la 0012 |
| Bucket `portafolio`, privado | Bucket `portafolios`, **público y sin políticas** | Se reusa el id, pasa a privado, cuatro políticas |

El tope del portafolio quedó en **10 fotos**. Los horarios no cuentan filas: la
superposición la impide una restricción de exclusión (`btree_gist`).

### Fase 2 — T-08: migración 0013, deuda del Sprint 2 · **3 pts**

Dos ítems arrastrados que son condición del resto del sprint:

1. **Lectura del bucket `pedidos` para el Profesional.** Hoy la política alcanza solo
   al Buscador dueño, así que el CU-22 y el CU-43 no podrían firmar las URLs. Se
   extiende el SELECT a los pedidos publicados y vigentes.
2. **Guard del PATCH de edición.** La RLS de UPDATE solo comprueba dueño, de modo que
   hoy se puede editar el título de un pedido cerrado y, peor, mandar
   `fecha_vencimiento` y renovar sin gastar renovaciones. Se resuelve con un
   disparador `BEFORE UPDATE` del mismo patrón que `pedidos_guard_estado` de la 0008:
   si el pedido no está `publicado` o `pausado`, rechaza; y `fecha_vencimiento` solo
   la mueve la función de renovación.

**Hecha el 14/09 — `supabase/migrations/0013_pedidos_deuda_sprint2.sql`, aplicada y
verificada.** Dos ampliaciones respecto de este plan: el guard protege todo el ciclo
de vida y no solo `fecha_vencimiento` (`renovaciones = 0` era el mismo agujero), y el
repositorio de Dart dejó de aceptar la fecha de vencimiento en la edición.

### Fase 3 — CU-07 Configurar Zona de Cobertura · **5 pts**

Reutiliza `lib/core/mapas/` del CU-16 sin tocarlo: mismo `SelectorUbicacion` para
fijar el centro, más un `Circle` con el radio y un deslizador. El marcador va fijo al
centro y se mueve el mapa, que es el patrón que se comporta igual en Web y Android
(decisión del Sprint 2).

Va antes que el CU-21 porque la búsqueda por radio no tiene contra qué comparar sin
esta tabla poblada.

**Hecha el 16/09.** Migración **0014** (computed fields `lat`/`lng` de la zona y la
RPC `guardar_zona_cobertura`, un upsert), más `lib/features/profesional/` —dominio,
repositorio, controlador y pantalla— con la ruta `/profesional/zona`. El mapa de la
zona no se arrastra: el centro sale del `SelectorUbicacion`, que no se tocó. 13
pruebas nuevas; 226 en total.

### Fase 4 — CU-12 Editar Categorías de Oficio · **4 pts**

ABM sobre `profesional_categorias` desde la pantalla de perfil. Es el segundo insumo
del emparejamiento del CU-21: sin categorías del Profesional no hay filtro de oficio.

**Hecha el 16/09.** La pantalla ya existía (el `SelectorOficios` dentro del perfil);
lo que faltaba era el servidor. Migración **0015**: `reemplazar_categorias_oficio`,
que hace el reemplazo en **una sola transacción** —antes eran un DELETE y un INSERT
sueltos, y una falla en el medio dejaba al Profesional sin oficios y sin alertas— y
valida del lado del servidor el mínimo de uno, el tope de cinco y que los slugs
existan. 5 pruebas nuevas; 231 en total.

### Fase 5 — CU-21 Recibir Alerta Push · **14 pts**

El ítem de mayor estimación del proyecto y el que sostiene el circuito de negocio
central. Se ataca inmediatamente después de sus dos insumos, para que su integración
no quede contra la fecha de entrega.

Se parte en tres commits:

| Commit | Qué |
|---|---|
| `feat(CU-21) a` | Edge Function `emparejar_pedido`: recibe el id del pedido, consulta con `service_role` **contra la columna de ubicación exacta**, no contra la vista pública, y devuelve los profesionales cuya zona contiene al pedido y cuya categoría coincide |
| `feat(CU-21) b` | Registro del token de FCM por dispositivo, permisos de notificación en Android e iOS, y baja del token al cerrar sesión |
| `feat(CU-21) c` | Disparo de la alerta desde el alta del pedido y apertura del detalle al tocar la notificación |

**La búsqueda corre contra la columna exacta y no contra la vista pública**: el
redondeo a tres decimales de la vista introduciría un error de unos cien metros en el
emparejamiento. Es una de las dos condiciones que el apartado 7.2.7 dejó abiertas.

El disparo va desde el servidor y no desde el cliente: un cliente que decide a quién
notificar es un cliente que puede decidir no notificar a nadie, o notificar a todos.

**Hecha el 16/09 en sus tres commits, salvo lo que depende de Firebase.** Migración
**0016** (`profesionales_para_pedido`, SECURITY DEFINER y solo para `service_role`),
Edge Function `emparejar_pedido` desplegada, migración **0017** (registro y baja del
token, con el traspaso entre cuentas) y `lib/features/notificaciones/`. El disparo
sale del alta del pedido y manda solo el id.

`firebase_messaging` no entró: sin `google-services.json` el build de Android falla.
Está aislado detrás de `ServicioPush`, así que entra una sola clase cuando existan
las credenciales. El emparejamiento **todavía no filtra por `disponible`** (CU-44):
su default es `false` y filtrar hoy dejaría a todos sin alertas.

### Fase 6 — CU-43 Explorar Tablero + CU-22 Ver Detalle · **8 pts**

El tablero consume la vista pública de pedidos vigentes, ordenada por distancia a la
zona de cobertura. El detalle **se deriva de `detalle_pedido_screen`** en modo
lectura: el Profesional ve las mismas secciones sin la barra de acciones del dueño y
con la ubicación aproximada. No se escribe una pantalla nueva.

Depende de la Fase 2: sin la política extendida del bucket, las fotos no se firman.

**Hecha el 16/09.** Migración **0018** (`tablero_pedidos` y `pedido_publico`, las dos
`security invoker` sobre `pedidos_publicos`) y las dos pantallas en
`/profesional/tablero` y `/profesional/pedidos/:id`. **Desvío:** el detalle no deriva
de `detalle_pedido_screen`, porque aquella se apoya en el modelo `Pedido`, que trae
la ubicación exacta y la referencia; se escribió sobre `PedidoTablero`, que no las
tiene. Los widgets sí se reutilizan. 8 pruebas nuevas; 249 en total.

### Fase 7 — CU-23 Ignorar + CU-24 Guardar · **4 pts**

Dos acciones sobre la tarjeta del tablero y dos filtros. Ignorar saca el pedido del
tablero de ese Profesional; guardar lo suma a una solapa de favoritos.

**Hecha el 16/09, sin migración**: las tablas y sus políticas son de la 0012 y la
0018 ya descartaba los ignorados y marcaba los guardados. Ignorar quita primero de
guardados y ofrece deshacer. 5 pruebas nuevas; 254 en total.

### Fase 8 — CU-44 Horarios y disponibilidad · **5 pts**

Franjas por día más el interruptor de disponibilidad. El estado de disponibilidad
filtra el emparejamiento del CU-21: un Profesional no disponible no recibe alerta.

**Hecha el 16/09.** Migración **0019**: `reemplazar_horarios` guarda la semana entera
en una transacción, valida todo antes de tocar nada y traduce el `23P01` de la
restricción de exclusión; y `profesionales_para_pedido` pasa a filtrar por
`disponible`, que es lo que la Fase 5 había dejado anotado. Pantalla en
`/profesional/horarios`. **Los horarios no filtran el emparejamiento** —un pedido de
las 23:00 le sirve igual a quien atiende de 9 a 18—: son información del perfil.
11 pruebas nuevas; 265 en total.

### Fase 9 — CU-06 Cargar Portafolio · **5 pts**

Carga de hasta N fotos con el mismo camino de código de bytes del CU-09 y del CU-13
(`maxWidth: 1600`, `imageQuality: 80`), bucket privado y URLs firmadas en lote con
`UrlsFirmadas`.

**Hecha el 16/09, sin migración** (tabla, tope de 10 con bloqueo y bucket privado son
de la 0012). N quedó en **10**. Pantalla en `/profesional/portafolio`. El archivo se
sube antes de insertar la fila y se borra si el insert falla; al eliminar, primero el
archivo. De paso se saldó la deuda del CU-11: la baja de cuenta ahora borra también
los archivos del portafolio. 5 pruebas nuevas; 270 en total.

### Fase 10 — Verificación y cierre

1. `flutter analyze` en 0 issues, `flutter test`, y los tres builds: web, APK e iOS.
2. Grep de secretos (`eyJ`, `AIza`, `service_role`) vacío.
3. Merge a `main`, tag `v0.3.0`, push, `CHANGELOG.md`.
4. Actualizar `docs/ESTADO.md` y `docs/UI.md`.
5. Apartado 7.3 del documento vivo, con su burndown.

**Hecha el 16/09.** `flutter analyze` 0 issues, `flutter test` **270 en verde**, y los
tres builds —web, APK e iOS simulador— compilando. El grep de secretos solo trae
comentarios de la Edge Function que nombran el rol. `CHANGELOG.md` con las tres
versiones agrupadas por caso de uso. Merge a `main` y tag `v0.3.0`.

### Cierre del sprint: 56 de 56 puntos

| Estado | Pts | Ítems |
|---|---|---|
| Cerrados | **56** | CU-17, T-06, T-07, T-08, CU-07, CU-12, CU-21, CU-43, CU-22, CU-23, CU-24, CU-44, CU-06 |
| Descartados | 0 | El orden de descarte (CU-06 primero, después CU-44) **no se activó** |

**El CU-21 se cerró el 16/09**, después de la prueba de punta a punta con un
dispositivo real: pedido publicado desde la Web, notificación recibida en Android y
apertura del detalle. Hasta esa prueba se lo informaba en curso a propósito —el
servidor estaba completo, pero nadie había visto llegar una notificación—, y la
prueba encontró tres defectos que ninguna verificación anterior había visto (CORS
desde la Web, la pantalla que abría la notificación y lo que quedaba debajo al
volver). La integración con Firebase y esos arreglos quedaron en el tag `v0.3.1`.

La sección para el documento de planificación está en
**`docs/sprints/SPRINT-03-cierre.md`**, con el burndown en `figuras/` y la evidencia
de commits en `evidencia-sprint-03.txt`.

---

## 4. Orden de descarte

El apartado 7.2.7 fijó el descarte sobre el CU-23 y el CU-24. **Se propone
modificarlo** y dejar constancia del cambio en la 7.3.

El criterio original era correcto en abstracto —son los ítems que no condicionan
ningún otro circuito— pero suman solo 4 puntos, insuficientes frente al desvío real,
y son además los dos más baratos de todo el paquete. Descartarlos deja el tablero a
medias por cuatro puntos de ahorro.

Orden de descarte propuesto, de mayor a menor prioridad de conservación:

| Orden | Ítem | Pts | Por qué se puede descartar |
|---|---|---|---|
| 1º | CU-06 Cargar Portafolio | 5 | No condiciona ningún circuito. El perfil del Profesional funciona sin portafolio; su ausencia se nota recién en el Sprint 5, cuando el perfil se comparte por enlace (CU-26 y CU-27). Destino natural: Sprint 5 |
| 2º | CU-44 Horarios y disponibilidad | 5 | El emparejamiento del CU-21 puede ignorar la disponibilidad sin romperse: notifica a todo Profesional cuya zona y categoría coincidan. Es una degradación de calidad del emparejamiento, no una falla. Destino: Sprint 4 |
| 3º | CU-23 y CU-24 | 4 | Se mantienen como último descarte, según el criterio original |

**Lo que no se descarta bajo ninguna circunstancia** es el CU-21. Es el circuito de
negocio central, es lo que el release v0.3.0 promete, y el Sprint 4 completo depende
de que exista: sin alerta no hay postulación, y sin postulación no hay nada que
desbloquear con tokens.

---

## 5. Puntos de control

El cuarto ajuste de 7.2.7 fijó un control al séptimo día, que caía el 09/09 y **no se
ejecutó**. Queda registrado como hallazgo de la retrospectiva de este sprint.

Se reemplaza por dos controles sobre el tramo que resta:

| Momento | Qué se contrasta | Corrección si no se cumple |
|---|---|---|
| Al cerrar la Fase 5 | El CU-21 está encaminado de punta a punta, aunque sea con un dispositivo | Se activa el descarte del CU-06 |
| Al cerrar la Fase 7 | 45 de los 56 puntos cerrados | Se activa el descarte del CU-44 |

**Contraste al cerrar la Fase 7 (16/09):** 32 puntos cerrados y 14 en curso —el
CU-21, completo salvo lo que depende del proyecto de Firebase—. Contra los 45
esperados, faltan 13: son exactamente el CU-44 (5), el CU-06 (5) y los 3 del CU-21
que no se pueden dar por cerrados sin haber visto llegar una notificación. El
descarte previsto era el CU-44; queda a decisión de la reunión, porque el sprint
llegó a su fecha de entrega con el circuito de negocio armado de punta a punta del
lado del servidor.

---

## 6. Mitigaciones que vencen en este sprint

Vienen del apartado 6 de la planificación y no suman puntos, pero si no se hacen acá
el costo se traslada a sprints que ya están más cargados.

| Mitigación | Origen |
|---|---|
| Validar el entorno de prueba de Mercado Pago y la recepción de la notificación IPN | Concentración de riesgo en el Sprint 4 |
| Alta de las cuentas Apple Developer y Google Play Console | Densidad funcional del Sprint 6; la habilitación es externa y tiene plazos propios |

---

## 7. Deuda que queda abierta al cerrar

Se registra para que no se pierda, sin pretender saldarla en este sprint:

| Ítem | Destino |
|---|---|
| Textos legales definitivos de `/legales/terminos` y `/legales/privacidad` | Sprint 5 |
| Tipografía del Anexo UI (implica versionar la fuente) | Sprint 5 |
| Figura 3.1 del Anexo UI desactualizada: muestra 3 campos y el alta tiene 5 | Antes de la entrega del Anexo |
| Logotipo definitivo e íconos de app | Al tener los archivos |
| Material de la entrega del Sprint 1: video de los 7 circuitos, capturas de esquema y de políticas RLS | Pendiente desde el Sprint 1 |

---

## 8. Convención de commits

Sin cambios respecto de los sprints anteriores:

```
feat(CU-07): configurar la zona de cobertura del profesional
feat(T-07): esquema del profesional con sus políticas
fix(CU-21): emparejar contra la ubicación exacta y no contra la vista
docs(S3): completar el apartado 7.3 del documento vivo
```
