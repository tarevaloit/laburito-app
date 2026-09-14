# ESTADO — Laburito

> **Fuente de verdad del proyecto.** Este archivo se actualiza al cerrar cada sesión de trabajo.
> Vive en `docs/ESTADO.md` del repo y se commitea junto con el código.
> Última actualización: 14/09/2026

---

## 0. Cómo abrir un chat nuevo con Claude

Cuando el chat se pone largo o cambiás de tema, abrí uno nuevo y hacé esto:

1. **Subí** `docs/ESTADO.md` + `docs/sprints/SPRINT-01.md` + los archivos de código puntuales del tema.
   Si el tema toca pantallas, sumá `docs/UI.md`.
2. **Pegá** el prompt de apertura de abajo.
3. **Al cerrar** el chat, pedí: *"actualizá ESTADO.md con lo que hicimos"* → guardás el archivo devuelto en el repo y commiteás.

### Prompt de apertura (copiar y pegar)

```
Proyecto Laburito (Seminario de Integración Profesional 2026, comisión P03).
Te subo ESTADO.md y el plan del sprint en curso: leelos antes de responder.
Tema de este chat: <TEMA>
Objetivo concreto: <QUÉ QUIERO TERMINAR HOY>
Trabajá directo sobre el código, no me expliques teoría salvo que te la pida.
```

### Regla de oro

**El repo es la memoria, no el chat.** Todo lo que se decide en un chat y no queda escrito
en `ESTADO.md`, en un commit o en el plan del sprint, se pierde. Si una conversación
produjo una decisión técnica, va a la sección 5 de este archivo antes de cerrar.

### Un chat por tema, no por día

| Chat | Alcance |
|---|---|
| `S1 · Setup + Supabase` | T-01, T-02, esquema, RLS, buckets, migración 0002 |
| `S1 · Auth` | CU-01, CU-02, CU-03, CU-08, CU-10/50, CU-04 |
| `S1 · Perfil y cuenta` | CU-05, CU-09, CU-11 |
| `S1 · Cierre y documentación` | Sección 7.1 del Sprint Planning, evidencias, burndown real |
| `S2 · Pedidos` | Arranque del Sprint 2: CU-13, CU-16 y siguientes |
| `S3 · Esquema del Profesional` | Fase 1 del Sprint 3: T-07, migración 0012 |

---

## 1. Snapshot

| Campo | Valor |
|---|---|
| Sprint en curso | **Sprint 3 — Perfil del Profesional y Notificaciones** (PT 4.0) · rama `sprint-3` · plan en `docs/sprints/SPRINT-03.md` |
| Sprint anterior | Sprint 2 — Gestión de Pedidos y Geolocalización (PT 3.0) · mergeado a `main`, tag `v0.2.0` |
| Período | 03/09/2026 al 16/09/2026 |
| Entrega por BB | 16/09/2026 hasta las 23:59 |
| Esfuerzo planificado | 56 pts (45 del PT 4.0 + 5 del CU-17 replanificado + 6 de deuda) |
| Backlog restante | 169 pts al inicio del Sprint 3 (criterio de alcance cerrado, ver plan) |
| Release objetivo | v0.3.0 — aplicación del Profesional operativa con alertas push |
| Repositorio | https://github.com/tarevaloit/laburito |
| Proyecto Supabase | `laburito` · ref `xbgwogitgzzxmoixqfjd` · PostgreSQL 17.6, PostGIS 3.3.7 |

## 2. Stack vigente

- **Flutter / Dart** — Web (Buscador) + App nativa (Profesional) + Panel desktop (Admin)
- **Supabase** — Auth, PostgreSQL, RLS, Storage, Edge Functions *(reemplazó a Firebase)*
- **Riverpod** — gestión de estado *(reemplazó a Bloc)*, con `riverpod_generator`
- **freezed** — modelos inmutables *(desde el Sprint 2; ver decisión del 02/09)*
- **PostGIS** — geolocalización de pedidos en la base *(Sprint 2)*
- **Firebase Cloud Messaging** — solo push notifications (Sprint 3)
- **Google Maps Platform** — geolocalización (Sprint 2)
- **Mercado Pago Checkout Pro** — sandbox / entorno de desarrollo (Sprint 4)

## 3. Avance por ítem del Sprint 1

Estados: `⬜ pendiente` · `🟡 en curso` · `✅ hecho` · `⏭️ replanificado`

| ID | Ítem | Pts | Estado | Commit / evidencia |
|---|---|---|---|---|
| T-01 | Setup Flutter + Git + capas + Riverpod | 5 | ✅ | `addb506` |
| T-02 | Supabase: modelo, RLS, buckets, seed categorías | 8 | ✅ | `f979211`, `5f0dc84` |
| CU-01 | Registrar Buscador | 2 | ✅ | `fcd2ca2` |
| CU-08 | Validar Email de Buscador (PIN) | 2 | ✅ | `8abfd45` |
| CU-03 | Iniciar Sesión | 2 | ✅ | `feb56b1` |
| CU-10 | Cerrar Sesión | 1 | ✅ | `feb56b1` |
| CU-50 | Logout del Sistema | 1 | ✅ | `feb56b1` |
| CU-02 | Registrar Profesional | 3 | ✅ | `866571a` |
| CU-09 | Validar Documentación (carga) | 3 | ✅ | `415f65e` |
| CU-05 | Gestionar Perfil | 3 | ✅ | `1e05627` |
| CU-11 | Dar de Baja Cuenta | 3 | ✅ | `0f0d4f2` |
| CU-04 | Recuperar Contraseña | 2 | ✅ | `6170dc9` |
| | **Total** | **35** | **35 ejecutados** | |

Pruebas: `13b4dff`. Cierre y Sección 7.1: `docs/sprints/SPRINT-01-cierre.md`.
Evidencia de commits: `docs/sprints/evidencia-sprint-01.txt`.

Después del cierre se aplicó el **ANEXO UI** sobre las pantallas ya funcionando:
tokens de color en `lib/app/colores.dart`, tema único derivado de ellos y widgets
compartidos. La guía y la trazabilidad figura por figura están en `docs/UI.md`.

**Lo que falta para entregar no es código**, es material de la presentación:
video de los 7 circuitos de `ARRANQUE.md`, captura del Schema Visualizer y de la
tabla de políticas RLS, y la subida a BB.

## 4. Sprint 2 — cerrado (PT 3.0)

Rama: **`sprint-2`**, salida de `main` (no del tag `v0.1.0`: main tiene 5 commits
posteriores al tag, incluido todo el ANEXO UI y el arreglo del CU-11).

### 4.1 Alcance

Estados: `⬜ pendiente` · `🟡 en curso` · `✅ hecho` · `⏭️ replanificado`

| ID | Ítem | Pts | Estado | Figura del ANEXO UI |
|---|---|---|---|---|
| CU-16 | Localizar Pedido en Mapa | 8 | ✅ | — |
| CU-13 | Publicar pedido con ubicación en el mapa | 8 | ✅ | Fig. 3.2 |
| CU-14 | Cancelar Pedido | 3 | ✅ | Fig. 3.4 |
| CU-15 | Editar Pedido | 3 | ✅ | Fig. 3.2 |
| CU-20 | Pausar Publicación (y reanudarla) | 3 | ✅ | Fig. 3.4 |
| CU-29 | Cerrar Pedido | 3 | ✅ | Fig. 3.4 |
| CU-51 | Renovar Pedido Vencido | 3 | ✅ | — |
| CU-17 | Consultar Historial de pedidos | 5 | ✅ | Fig. 3.5 |
| CU-18 | Solicitar Reenvío de Enlace de Gestión | 4 | ⏭️ | — |
| | **Total** | **40** | **36 ejecutados** | |

Los 4 puntos que faltan son el CU-18, que ya estaba marcado como descartable
en el plan del sprint: es el único ítem que no condiciona nada del Sprint 3 y
se replanifica al Sprint 5, donde ya hay trabajo de enlaces públicos (CU-26 y
CU-27).

> **Faltan nombres y puntos.** Los únicos títulos que se pueden sostener con una
> fuente del repo son los que aparecen en el ANEXO UI (CU-13, CU-17, CU-20/29).
> El resto se completa copiando del PT 3.0: no se inventan acá, porque este
> archivo es la fuente de verdad y un nombre inventado se propaga a la entrega.

El orden de la tabla es el que dio el PT 3.0. El orden de **implementación** se
define al armar `docs/sprints/SPRINT-02.md`, siguiendo dependencias reales como
en el Sprint 1: publicar un pedido (CU-13) es condición de gestionarlo (CU-20 /
CU-29) y de listarlo en el historial (CU-17).

### 4.2 Deuda que se arrastra del Sprint 1

Cuatro ítems de la sección 6 vencen en este sprint. Los dos primeros son los que
hay que decidir temprano, porque tocan todo lo que se escriba después:

| Ítem | Por qué ahora |
|---|---|
| **Codegen de providers** | Hoy los providers están escritos a mano, sin `build_runner` ni `riverpod_generator`. Migrar con 8 providers cuesta menos que con 20, y el Sprint 2 suma los de pedidos. Si no se hace al principio, no se hace más |
| **Pruebas de widget** | Hay 18 unitarias y 3 de widget del lineamiento visual, pero ningún circuito cubierto. El Sprint 1 se verificó a mano con `ARRANQUE.md`, y eso no escala a los pedidos |
| Barra superior de la web | La Figura 3.1 la muestra con «Cómo funciona · Mis pedidos · Ayuda». «Mis pedidos» es justamente el CU-17 de este sprint: la barra deja de ser un placeholder |
| CTA fija al pie en móvil | El Anexo la muestra anclada abajo (Fig. 3.9, 3.11, 3.15) |

Además, el Sprint 1 no está cerrado del todo: falta aplicar la migración 0004 y
grabar el material de la entrega (sección 7).

### 4.3 Estado del código en la rama `sprint-2`

El trabajo que estaba sin commitear quedó ordenado en cuatro commits, uno por
unidad de cambio. Ninguno se pusheó todavía.

| Commit | Qué entra |
|---|---|
| `40725c1` `fix(CU-03)` | El login sin saludo y con la bajada según la superficie, más el desvío anotado en `docs/UI.md` |
| `76c69f5` `chore(T-05)` | Migración a `freezed` + `riverpod_generator` de todo lo preexistente: pubspec, providers, modelos y los `*.g.dart` / `*.freezed.dart` |
| `e0e8d34` `feat(T-02)` | Migraciones 0005, 0006 y 0007 y el guion de diagnóstico `supabase/scripts/verificar_pedidos.sql` |
| `6033700` `feat(CU-13)` | `lib/features/pedidos/` —dominio, repositorio, providers y excepciones tipadas— con sus dos suites de pruebas |
| `e0d3fe5` `fix(T-02)` | Migración 0008: el guard de la máquina de estados y el mapeo del centinela en `PedidoException` |
| `fix(CU-13)` | Migración 0009: alta y cambio de ubicación por RPC, con el punto armado del lado del servidor |
| `feat(CU-16)` | `lib/core/mapas/` completo + `SelectorUbicacion` en `lib/features/pedidos/presentation/widgets/`, manifiesto de Android, `web/index.html`, `.env.example`, README y `test/mapa_config_test.dart` + `test/servicio_direcciones_test.dart` |

Línea base de pruebas: **77 en verde** al cerrar la Fase 1. Son 30 del Sprint 1
(validadores, mensajes de error, estados de perfil y lineamiento visual) más 47
de la capa de pedidos. Verificado además que con el `chore(T-05)` aislado —sin
nada de `lib/features/pedidos/` en el árbol— `flutter analyze` da 0 issues y las
30 del Sprint 1 siguen pasando: la migración a codegen no depende del feature
nuevo. Con el guard de la 0008 son **81**, con la ida y vuelta de la
coordenada de la 0009, **87**, y con las pruebas del CU-16 (`mapa_config_test`
+ `servicio_direcciones_test`), **101**.

**Todavía no hay wizard de alta de pedido (CU-13).** El CU-16 aporta el
selector de ubicación reutilizable; falta el resto de la pantalla que lo
invoca, que es la Fase 5.

### 4.4 Fase 4 — CU-16 Localizar Pedido en Mapa · **HECHA**

Se retomó donde había quedado interrumpida (ver historial de este archivo) y
se terminó completa: compilador arreglado, widget escrito, configuración
nativa y pruebas. `flutter analyze` en 0 issues, `flutter build web` y
`flutter build apk --debug` compilan los dos.

#### Lo que se escribió (sin commitear)

| Archivo | Qué hace |
|---|---|
| `lib/core/mapas/mapa_config.dart` | Tokens del mapa: clave, zoom de dirección y de detalle, centro de reserva en José C. Paz, tolerancia de 15 m y los dos *debounce*. `asegurarSdk()` delega en el cargador por plataforma |
| `lib/core/mapas/sdk_mapas.dart` + `_stub.dart` + `_web.dart` | Carga del SDK resuelta con `export … if (dart.library.js_interop)`. En Android no hay nada que cargar; en Web inyecta el `<script>` de Maps con la clave del `--dart-define` |
| `lib/core/mapas/ubicacion_dispositivo.dart` | `geolocator` detrás de un tipo sellado `PosicionObtenida` / `SinPosicion`. Dos entradas: `actual()` pide permiso, `actualSiYaHayPermiso()` no molesta a nadie |
| `lib/core/mapas/servicio_direcciones.dart` | Places API (New) para el autocompletado y Geocoding API para la geocodificación inversa. Ningún método tira excepción: devuelven `null` o lista vacía |
| `lib/core/mapas/mapas_providers.dart` | `servicioDireccionesProvider` y `ubicacionDispositivoProvider`, los dos `keepAlive` |
| `lib/features/pedidos/presentation/controllers/selector_ubicacion_controller.dart` | Estado del selector en freezed + Notifier `@riverpod` autoDispose con familia sobre la `Ubicacion` inicial. El `ref.mounted` que no existe en Riverpod 2.6 se reemplazó por la bandera `_vivo` ya declarada |
| `lib/features/pedidos/presentation/widgets/selector_ubicacion.dart` | El widget `SelectorUbicacion` (pantalla completa) y `abrirSelectorUbicacion(context, inicial: ...)`, que lo empuja con `Navigator.push` y devuelve `Ubicacion?` |
| `lib/core/config/env.dart` | Se le agregó `googleMapsApiKey`. **No** entra en `Env.esValido`: sin mapa la app arranca igual |
| `android/app/src/main/AndroidManifest.xml` | `meta-data com.google.android.geo.API_KEY` con `${MAPS_API_KEY}` y los permisos `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` |
| `android/app/build.gradle.kts` | Lee `MAPS_API_KEY` de la variable de entorno o de `android/local.properties` (gitignored) y la vuelca como `manifestPlaceholders["MAPS_API_KEY"]`, con `""` por defecto |
| `web/index.html` | Sin la clave; solo un comentario que explica que el `<script>` de Maps lo inyecta `sdk_mapas_web.dart` |
| `.env.example` | `GOOGLE_MAPS_API_KEY=` vacío y las tres APIs a habilitar en Google Cloud |
| `README.md` | Sección «Clave de Google Maps (CU-16)»: los dos caminos de la clave y por qué son dos |
| `test/mapa_config_test.dart` + `test/servicio_direcciones_test.dart` | Centro de reserva y tolerancia; parseo del autocompletado, del detalle y de la geocodificación inversa con `MockClient`, `includedRegionCodes: ['ar']` en el cuerpo, y que un 500 devuelva `null`/lista vacía en vez de tirar |
| `pubspec.yaml` / `pubspec.lock` | `google_maps_flutter`, `google_maps_flutter_web`, `geolocator`, `web`, y `http` que pasó de `dev_dependencies` a `dependencies` |

Verificado: `flutter analyze` 0 issues, `flutter test` 101 en verde,
`flutter build web` y `flutter build apk --debug` compilan los dos.
Decisiones técnicas de esta fase: sección 5, entradas del 02/09.
Commit: `69b272f` `feat(CU-16): localizar el pedido en el mapa`.

### 4.5 Fase 5 — CU-13 Crear Pedido · **asistente hecho, sin verificar**

Wizard de 4 pasos en `/pedidos/nuevo`, ruta que exige sesión (como el resto de
la app) y valida el rol Buscador **adentro de la pantalla**: con una cuenta
Profesional muestra un aviso en vez de la ruta a `/login` — no se tocó el
`redirect` de `router.dart`, que no tiene forma síncrona de leer el rol sin
arriesgar una carrera con `perfilCompletoProvider`, que es asíncrono.

| Archivo | Qué hace |
|---|---|
| `lib/features/pedidos/presentation/controllers/crear_pedido_controller.dart` | `EstadoCrearPedido` (freezed) + `CrearPedidoController` (`@riverpod`, autoDispose). Guarda las fotos en memoria (`FotoPendiente`, bytes + nombre) hasta confirmar: el pedido tiene que existir antes de que una foto pueda subirse |
| `lib/features/pedidos/presentation/screens/crear_pedido_screen.dart` | La pantalla: barra de progreso, los 4 pasos (`_PasoQueNecesitas`, `_PasoDonde`, `_PasoFotos`, `_PasoVigencia`) y la barra de acciones Atrás/Siguiente/Publicar |
| `lib/app/router.dart` | Ruta `/pedidos/nuevo` |
| `lib/features/home/presentation/home_screen.dart` | Botón «Publicar un pedido», solo para cuentas Buscador |

Flujo de alta: `crearPedido` (RPC, Fase 3) y después, en orden, `subirFoto` por
cada foto elegida. Una foto que falla **no** deshace el pedido —ya quedó
publicado—, se junta en `erroresFotos` y se avisa aparte. Al terminar redirige
a `/home` con un mensaje de éxito: el detalle del pedido (CU-20, Fase 6) y el
historial (CU-17, Fase 7) todavía no existen, así que no hay a dónde más
mandar a alguien que acaba de publicar. Se corrige cuando esas pantallas
existan.

**Sin verificar con `flutter test` ni con los builds de Web/Android**, a
pedido explícito: se prioriza terminar el desarrollo de las fases que faltan y
verificar todo junto al cierre del sprint. Ver la entrada nueva de la sección
6. Sí se corrió `flutter analyze` después de cada cambio (0 issues): es
prácticamente gratis y evita seguir escribiendo sobre código que no compila.

#### Decisiones que se tomaron acá

| Decisión | Motivo |
|---|---|
| El rol Buscador se valida en la pantalla, no en el `redirect` del router | `perfilCompletoProvider` es asíncrono y el `redirect` de go_router necesita una respuesta síncrona (la misma razón por la que la sesión se lee de `auth.currentSession` y no de un provider, decisión del 20/08). Gatear por rol ahí arriesgaba la misma carrera que ya se había resuelto para la sesión |
| `PopScope` necesita una bandera `_salidaForzada` además de `canPop` | Con `canPop: false`, volver a llamar `Navigator.pop()` **dentro del propio** `onPopInvokedWithResult` no saca de la pantalla: el pop programático también queda interceptado y el diálogo de «¿descartar?» se mostraría de nuevo en loop. La bandera es lo que hace que la segunda vuelta de `canPop` dé `true` |
| Los campos de texto del asistente usan `initialValue` de `CampoTexto`, no `TextEditingController` | Cada paso se renderiza condicionalmente (`switch` sobre `estado.paso`), así que al volver a un paso ya visitado el widget se reconstruye entero con el valor que quedó en el controller. Evita instanciar y descartar `TextEditingController` a mano en cuatro pasos |
| Las fotos se comprimen con `maxWidth: 1600` / `imageQuality: 80` de `image_picker`, igual que el CU-09 | Mismo criterio ya usado para el DNI y la selfie: un solo camino de código para Web y Android, sin herramienta de compresión aparte |

### 4.6 Fase 6 — Ciclo de vida del pedido · **HECHA** (5 commits, uno por CU)

Pantalla de detalle en `/pedidos/:id`, que es el centro del ciclo de vida:
carrusel de fotos con URLs firmadas, encabezado con chip de estado y
categoría, descripción, mini-mapa con el pin, dirección, datos (presupuesto,
fechas, renovaciones) y un aviso que explica qué significa el estado actual.
Abajo, la barra de acciones, que ofrece **solo** lo que la máquina de estados
de la migración 0006 admite.

| Commit | Caso de uso | Qué entra |
|---|---|---|
| `9441bea` | CU-20 | Detalle completo + pausar/reanudar. `AccionesPedido` (familia Riverpod para las cuatro operaciones), `ChipEstadoPedido`, `MiniMapaPedido`, `UrlsFirmadas` (caché de firmas en lote), `Fechas` |
| `afb44fe` | CU-29 | Cerrar con motivo de lista cerrada, confirmación obligatoria, ninguna opción preseleccionada |
| `fd6949c` | CU-14 | Cancelar con motivo libre y opcional; el copy diferencia cerrar de cancelar |
| `04558a4` | CU-51 | Renovar 7/15/30, límite de 3 resuelto en cliente y por `CasoPedido.limiteRenovaciones` del servidor, con CTA a publicar uno nuevo |
| `a557db7` | CU-15 | Editar en `/pedidos/:id/editar` + migración **0010** (`registrar_edicion_pedido`) |

Archivos nuevos de la fase:

| Archivo | Qué hace |
|---|---|
| `presentation/screens/detalle_pedido_screen.dart` | La pantalla y su barra de acciones |
| `presentation/screens/editar_pedido_screen.dart` | CU-15, con la sección de fotos |
| `presentation/controllers/acciones_pedido_controller.dart` | Pausar, reanudar, cerrar, cancelar, renovar + `MotivoCierre` |
| `presentation/controllers/editar_pedido_controller.dart` | El borrador de la edición |
| `presentation/widgets/campos_pedido.dart` | Los formularios **compartidos** con el asistente + `ValidadoresPedido` |
| `presentation/widgets/dialogos_pedido.dart` | Cerrar, cancelar, renovar y límite de renovaciones |
| `presentation/widgets/chip_estado_pedido.dart` · `fotos_pedido.dart` · `mini_mapa_pedido.dart` | Chip por estado, carrusel + placeholder por categoría, mini-mapa |
| `data/urls_firmadas.dart` | Caché de URLs firmadas, en lote |
| `core/utils/fechas.dart` | Fechas y frases relativas en castellano |
| `supabase/migrations/0010_pedido_evento_edicion.sql` | El evento de edición del CU-15 |

**Verificado el 03/09, todo junto como se había planificado:** `flutter
analyze` 0 issues, `flutter test` **163 en verde** (101 antes de sumar las pruebas de la Fase 9a; sin regresiones contra la
línea base del CU-16), `flutter build web`, `flutter build apk --debug` y
`flutter build ios --simulator --debug` compilan los tres, y el grep de
secretos (`eyJ`, `AIza`, `service_role`) sale vacío.

### 4.7 El bug que encontró la primera corrida real (`84bc8e5`)

Al llegar al paso 4 del asistente en la web, la barra de acciones no se
dibujaba y tocar donde deberían estar los botones llenaba la consola de
excepciones en cascada. La causa era **una línea del tema**:
`minimumSize: Size.fromHeight(52)` deja el ancho en `double.infinity`, así que
todos los botones de la app exigían ancho infinito. En una `Column` con
`stretch` no se nota; en un `Row`, en un `Wrap` o en las acciones de un
`AlertDialog` —o sea, en **todos** los diálogos de confirmación del proyecto,
incluido el de la baja de cuenta del Sprint 1— el layout reventaba.

Vale la pena anotarlo porque es exactamente el riesgo que se había aceptado al
diferir la verificación: un error de *runtime* que `flutter analyze` no ve.
Estaba en el repo desde el Sprint 1 y no lo encontró nadie porque ninguna
pantalla anterior ponía dos botones en fila.

### 4.8 Pruebas de las Fases 5 y 6 (`07375ec`)

62 pruebas nuevas, de 101 a **163**, incluida la de regresión del bug de
arriba —que sin el arreglo falla con el mismo «BoxConstraints forces an
infinite width»—. Cierra la deuda del apartado 7.1.7 del informe del Sprint 1,
acotada a lo que existe: nada del CU-17 ni del CU-18.

### 4.9 Fase 7 — CU-17 Consultar Historial · **HECHA** (`0f6df51`)

`/pedidos`, el home del Buscador. Era la pieza que faltaba para que el sprint
se sostenga solo: sin ella, al detalle de un pedido únicamente se llegaba
recién publicado.

| Qué | Cómo |
|---|---|
| Cuatro grupos con contador | `FiltroPedidos` rehecho: Activos, Vencidos, Cerrados, Cancelados, que **parten los estados sin superponerse**. Los contadores salen de una consulta que trae solo la columna `estado` |
| Búsqueda por texto | `ilike` sobre título y descripción, del lado del servidor, con el texto saneado antes de armar el `or` de PostgREST |
| Scroll infinito | 20 por página, pidiendo la siguiente 400 px antes del final |
| Pull to refresh | Corre `marcar_pedidos_vencidos()` **antes** de leer |
| Portadas | Firmadas en lote con el caché de `UrlsFirmadas` de la Fase 6 |
| Vacíos | Dos distintos: «todavía no publicaste» ofrece publicar, «no encontramos nada» no |

Archivos: `presentation/screens/historial_pedidos_screen.dart`,
`presentation/controllers/historial_pedidos_controller.dart`,
`presentation/widgets/tarjeta_pedido.dart`.

### 4.10 iOS quedó compilando otra vez (`2254b16`)

iOS no levantaba desde que el CU-16 sumó `google_maps_flutter` y `geolocator`.
Era configuración nativa, no código: piso de iOS 14 (lo pide
`google_maps_flutter_ios`, el Runner estaba en 13), `pod install` con el
`Podfile.lock` que había quedado de antes del CU-16,
`NSLocationWhenInUseUsageDescription` —sin esa clave iOS no pide permiso: mata
la app— y el tercer camino de la clave de Maps, `ios/Flutter/Maps.xcconfig`.

## 4b. Sprint 3 — en curso (PT 4.0)

Rama **`sprint-3`**, salida de `main` después del merge del Sprint 2 y del tag
`v0.2.0`. El alcance, el orden de fases y el orden de descarte viven en
`docs/sprints/SPRINT-03.md`; acá va solo lo que ya pasó.

### 4b.1 Estado de la base al arrancar (verificado el 14/09)

Consultado directo contra el proyecto con `supabase db query --linked`, no
deducido de los archivos: **las migraciones 0001 a 0011 están aplicadas**
(existen `registrar_edicion_pedido` de la 0010 y el `handle_new_user`
idempotente de la 0011). Se aplicaron por el SQL Editor, así que el historial
de migraciones de la CLI está vacío; no se reparó, para no registrar como
aplicadas cosas que no pasaron por ahí.

Datos: 3 Profesionales (uno activo y aprobado, dos dados de baja), 6 pedidos,
ninguno vigente.

### 4b.2 Fase 1 — T-07 · migración 0012, esquema del Profesional · **HECHA**

`supabase/migrations/0012_profesional_esquema.sql`. Ensayada primero dentro de
`begin … rollback` contra la base real, aplicada después en una sola
transacción, y verificada con su guion de aceptación completo —los diez
bloques— corrido contra la base, cada prueba de comportamiento en su propia
transacción con rollback. No quedó ninguna fila de prueba.

| Qué agrega | Para | Cómo |
|---|---|---|
| `es_profesional_activo()` | Todas las escrituras | SECURITY DEFINER como `es_admin()`: Profesional, cuenta `activo`, sin `deleted_at` |
| `profesional_zona_cobertura` | CU-07 | Una por Profesional (PK = `profesional_id`), `centro extensions.geography(Point,4326)`, `radio_metros` 1 000–100 000, GiST. Solo la ven el dueño y el admin |
| `profesional_horarios` | CU-44 | Día ISO (1 = lunes), `hora_desde < hora_hasta`, franjas superpuestas imposibles por **restricción de exclusión** |
| `profesional_portafolio` + bucket `portafolios` privado | CU-06 | Tope de 10 con `for update` sobre la fila del Profesional **antes** de contar; la ruta tiene que empezar con la carpeta del dueño; `unique (profesional_id, orden)` diferible |
| `profesional_dispositivos` | CU-21 | Token de FCM único en toda la tabla, plataforma `android` / `ios` / `web`. Solo el dueño |
| `pedido_ignorado` / `pedido_favorito` | CU-23 / CU-24 | PK (profesional, pedido); el alta exige ver el pedido |
| `dar_de_baja_cuenta()` reescrita | CU-11 | Borra la zona, los horarios, los dispositivos, el portafolio y las marcas. Deja de tocar `profesionales.ubicacion` |
| **Borra** `profesionales.ubicacion` y `radio_cobertura_km` | — | Venían de la 0001, sin uso y en null en las tres filas |

Lo que el guion comprobó contra la base: RLS activa y con políticas en las seis
tablas; columnas viejas fuera y bucket privado; el dueño escribe y ve su zona
y otro perfil ve 0; escribir la zona ajena da `42501`; 9–13 y 13–18 conviven y
12–15 da `23P01`; la foto número 11 da `P0001` con hint `limite_portafolio`;
una ruta ajena da `23514`; reordenar dos fotos en un UPDATE pasa; se guarda un
pedido visible y se rechaza uno invisible; un Buscador no puede registrar un
dispositivo. La prueba de concurrencia del tope no se puede hacer desde una
sola sesión: el guion verifica que el bloqueo esté antes del conteo.

Decisiones: sección 5, entradas del 14/09.

## 5. Decisiones técnicas tomadas

Formato: fecha · decisión · motivo. No se borran, se agregan.

| Fecha | Decisión | Motivo |
|---|---|---|
| 05/08 | Supabase reemplaza a Firebase | Modelo relacional + RLS + Edge Functions en un solo servicio; PostGIS para el radio de búsqueda |
| 05/08 | Riverpod reemplaza a Bloc | Menos boilerplate para un equipo de una persona; providers componibles |
| 05/08 | Distribución móvil por TestFlight + canal interno de Play | Evita los plazos de revisión de tiendas, externos al proyecto |
| 05/08 | Mercado Pago solo en entorno de desarrollo | No se opera con dinero real; el circuito es idéntico al productivo |
| 19/08 | Riverpod sin `build_runner` ni codegen | Providers escritos a mano: saca la generación del camino crítico. Migrable en el Sprint 2 |
| 19/08 | CU-08 y CU-04 con OTP de 6 dígitos en vez de enlace | Un solo patrón de pantalla para ambos y cero configuración de deep links en Web y móvil |
| 19/08 | Las categorías del Profesional viajan en el metadata del signUp | Durante el alta todavía no hay sesión y las RLS de `profesional_categorias` exigen `auth.uid()` |
| 19/08 | CU-11 resuelto con RPC `dar_de_baja_cuenta` | Baja lógica, anonimización y auditoría en una sola transacción del lado del servidor |
| 19/08 | La baja anonimiza y libera el correo, no borra la fila | Se evaluó el borrado físico: `perfiles` es el ancla de las FK de pedidos, calificaciones y pagos, y la cascada se llevaría la auditoría de `bajas_cuenta` y el historial de la otra parte del pedido. Se conserva la fila sin datos personales y se reescribe el correo de `auth.users` a una lápida, de modo que la dirección quede libre para volver a registrarse (Ley 25.326, derecho de supresión) |
| 19/08 | Documentos del CU-09 solo como imagen | Un único camino de código con `image_picker` en Web y móvil; el DNI y la selfie son fotos |
| 19/08 | El router bloquea el home con el correo sin validar | El CU-08 exige que sin PIN no se entre. Se comprueba `emailConfirmedAt` en el `redirect`, no solo la existencia de sesión |
| 19/08 | El CU-04 cierra las demás sesiones al cambiar la contraseña | `signOut(scope: others)` después del `updateUser`: si alguien entró con la contraseña vieja, queda afuera |
| 19/08 | Historial de Git reescrito en 12 commits, uno por ítem | El sprint entero había quedado en un solo commit y la evidencia que pide la Sección 2 es `git log` por caso de uso. El commit original quedó en la rama `respaldo-commit-unico` |
| 19/08 | Los colores viven en `lib/app/colores.dart`, no en las pantallas | Los hex estaban repetidos en diez archivos y ya habían divergido. Un solo archivo de tokens (`Colores` y `Medidas`) del que sale el `ThemeData` y toda la UI. Regla: ninguna pantalla escribe un color literal |
| 19/08 | El naranja es la acción principal; el azul es la marca | Es el criterio del ANEXO UI: en todas las figuras el CTA es naranja y el azul marino queda para logotipo, títulos y chips. Estaba al revés (`FilledButton` salía azul por `colorScheme.primary`) |
| 19/08 | Los formularios usan `CampoTexto`, con la etiqueta arriba del campo | El Anexo no usa la etiqueta flotante de Material: en todas las figuras el rótulo está afuera y arriba, y adentro va el texto de ejemplo. Era la diferencia más visible entre lo implementado y lo diseñado |
| 19/08 | El color de la etiqueta del chip va como `WidgetStateColor` | `secondaryLabelStyle` solo lo usa `ChoiceChip`: con `FilterChip` el texto quedaba oscuro sobre el azul y no se leía. Cubierto en `test/tema_test.dart` |
| 20/08 | El router lee la sesión de `auth.currentSession`, no de un provider | Al validar el PIN, el CU-08 rebotaba al login a alguien que acababa de autenticarse. `sesionProvider` devolvía la sesión del **último evento recibido** del stream, y ese evento llega un turno después de que la sesión ya existe: el redirect corría con el valor viejo (`initialSession`, nulo). `currentSession` la actualiza el cliente de forma sincrónica |
| 20/08 | Los estados de la base se traducen en `PerfilCompleto`, no en cada pantalla | Se mostraban crudos —«sin_documentacion», «en_revision»—: parece un error del sistema y no sirve para la presentación. `estadoLegible` y `verificacionLegible` son la única fuente, y `test/perfil_estados_test.dart` verifica que ningún valor de los enums quede sin texto |
| 20/08 | La baja no borra en `storage.objects` por SQL (migración 0004) | Supabase rechaza el DML directo sobre las tablas de Storage: `42501 · Direct deletion from storage tables is not allowed`. El «respaldo» de la 0003 no solo no funcionaba, sino que abortaba la transacción entera y el CU-11 quedaba muerto. Los archivos los destruye el cliente por la API, que además es el único camino que elimina el objeto y no solo su fila |
| 20/08 | Si falla el borrado de archivos, la baja se interrumpe antes de anonimizar | Antes el fallo se tragaba en silencio. Después del anonimizado la persona pierde los permisos sobre su propia carpeta: un fallo posterior dejaría el DNI y la selfie huérfanos, sin nadie que pueda borrarlos nunca. Frenar y reintentar es mejor que una baja a medias |
| 20/08 | Los errores de Postgres dejan de taparse con un mensaje único | `MensajesError` devolvía el mismo genérico para todo `PostgrestException`. Los `raise exception` de las RPC —escritos en castellano y para el usuario— no llegaban nunca a la pantalla, y en la consola no quedaba ni el código. Ahora `P0001` se muestra tal cual, `PGRST202` y `42501` tienen mensaje propio, y en debug el error completo va a la consola |
| 19/08 | **Un solo proyecto Flutter para la app y la web, no dos** | Se evaluó separar en dos proyectos. Comparten el cliente de Supabase, los repositorios de auth, perfil y categorías, los validadores, los mensajes de error y todo el sistema visual: lo único distinto es qué pantallas se componen y con qué navegación. Separar obligaría a extraer un paquete común y mantener tres `pubspec` —cuatro con el panel de Admin— para un equipo de una persona, y a rehacer el repo, los tags y la evidencia del plan. Se revisa si la parte compartida se achica, cosa que no pasa: pedidos, calificaciones y contacto son dominio común |
| 19/08 | La superficie se decide en `core/config/superficie.dart`, no con `kIsWeb` desperdigado | La regla se expresa por intención (`Entorno.permiteAltaDeBuscador`, `usaBarraInferior`) y en un solo lugar. En la app nativa el alta es siempre de Profesional; en la web se cambia de rol dentro de la tarjeta de alta, como la Figura 3.1. Si mañana el Buscador tiene app, se cambia un archivo |
| 19/08 | El alta conserva los 5 campos del CU-01; se redibuja la Figura 3.1 | La Figura 3.1 muestra 3 campos y el CU-01 pide 5. Manda el CU-01: el teléfono es el dato con el que el Profesional contacta al Buscador, y sacarlo del alta lo empujaría al CU-13. **Pendiente: actualizar la figura del Anexo UI** |
| 19/08 | Checkbox de Términos y Política de Privacidad en las dos altas | Está en la Figura 3.1 y faltaba en el código. Se agrega también al alta del Profesional, que la Figura 3.9 no dibuja: el consentimiento de la Ley 25.326 no depende del rol. La fecha de aceptación queda en el metadata de `auth.users` (`acepto_legales_en`) — evidencia del consentimiento sin tocar el esquema |
| 19/08 | La pantalla de selección de rol se elimina | El Anexo no la tiene: el selector va **adentro** de la tarjeta de alta (Fig. 3.1). En móvil directamente no existe, porque no hay rol que elegir |
| 19/08 | La barra de navegación inferior se implementa completa, con la Billetera marcada «Pronto» | El Tablero (CU-43) es del Sprint 2 y la Billetera (CU-30) del Sprint 4, pero dejar la estructura del Anexo desde ahora evita rearmar la navegación después, y la demo del 20/08 muestra el recorrido real. Al Buscador no se le muestra la Billetera: los tokens son del Profesional |
| 19/08 | El logotipo se carga de `assets/logo/laburito.png` con un logo de reserva dibujado | Permite cerrar el lineamiento visual sin bloquearse esperando el PNG: si el archivo no está, `LogoLaburito` dibuja el isotipo y el nombre, y la app compila igual. Al dejar el archivo, aparece sin tocar código |
| 02/09 | **Se adopta codegen: `freezed` para los modelos y `riverpod_generator` para los providers, en todo el proyecto** | Revierte la decisión del 19/08, que difería la migración al Sprint 2. Se migró todo de una en vez de solo el feature nuevo: dejar la mitad del repo con providers a mano y la otra mitad generados obliga a recordar en qué archivo rige qué regla. La UI no se tocó — los nombres que genera `@riverpod` coinciden con los que estaban escritos a mano (`perfilCompletoProvider`, `sesionProvider`) — y los 30 tests del Sprint 1 siguen pasando sin cambios. Costo aceptado: `dart run build_runner build` entra al camino crítico de cada cambio de modelo |
| 02/09 | Los providers migrados van con `@Riverpod(keepAlive: true)` | `@riverpod` genera autoDispose por defecto, y los que había eran `Provider` / `FutureProvider` / `AsyncNotifierProvider`, que no se descartan. Con autoDispose el notificador de un controller podría morir entre el `read(...notifier)` y el `read(...).error` que las pantallas hacen justo después, y el mensaje de error se perdería. Las familias nuevas de pedidos sí son autoDispose: se quiere que el historial se recargue al volver a entrar |
| 02/09 | Los pedidos son geolocalizados con PostGIS y no con lat/lng sueltos | La búsqueda por radio del CU-21 (Sprint 3) se resuelve con `ST_DWithin` contra un índice GIST, del lado del servidor. Con lat/lng habría que traerse todos los pedidos al cliente para filtrar |
| 02/09 | Las coordenadas se leen por *computed fields*, no por la columna | PostgREST serializa `geography` como WKB hexadecimal (`0101000020E6100000...`), que en Dart no es una coordenada, y **no admite expresiones SQL en el `select`**: `st_y(ubicacion::geometry) as lat` no es una opción. Las funciones `public.lat(pedidos)` y `public.lng(pedidos)` de la 0007 se piden como si fueran columnas. Por lo mismo, el alta manda la ubicación como EWKT: PostgREST tampoco deja llamar funciones dentro de un INSERT |
| 02/09 | Las excepciones de las RPC viajan con un `hint` legible por máquina | Todo `raise exception` de plpgsql llega como `P0001`, así que el código solo no distingue «no se puede pasar de cerrado a publicado» de «ya renovaste 3 veces». Las funciones de la 0006 mandan además `hint = 'transicion_invalida' \| 'limite_renovaciones' \| 'sin_permiso'`, y `PedidoException` mapea por esa clave. El texto del mensaje no se lee nunca: está escrito para el usuario y va a cambiar |
| 02/09 | Solo los `P0001` muestran el mensaje del servidor; el resto se traduce | Un `42501` trae «new row violates row-level security policy for table "pedidos"», que no se le enseña a nadie. Los `P0001` son nuestros y ya vienen redactados en castellano. Cubierto en `test/pedidos_errores_test.dart` |
| 02/09 | Los pedidos no se borran: no hay política de DELETE | Un `delete` se llevaría por cascada la auditoría de `pedido_eventos`, que es justo lo que prueba que el pedido existió. El ciclo termina en `cerrado` o `cancelado`, que son terminales. Las fotos sí se borran: son archivos, no historia |
| 02/09 | `listarMisPedidos` filtra por `buscador_id` aunque haya RLS | Sobre `pedidos` hay **dos** políticas de SELECT: la de los propios y la de los publicados vigentes de cualquiera, que es la que va a usar el Profesional. Sin el filtro explícito, «Mis pedidos» mostraría también los de los demás |
| 02/09 | Al subir una foto, si falla el insert se borra el archivo | Misma lección que el CU-11: un objeto en Storage que ninguna fila referencia es invisible y eterno. Y al eliminar, primero el archivo y después la fila, por el mismo motivo |
| 02/09 | La máquina de estados se blinda con un trigger y una compuerta de transacción, no restringiendo columnas en la RLS | Postgres no tiene RLS por columna, y las políticas `for update` son de fila entera: quien puede corregir el título puede escribir `estado`. La alternativa era `grant update (col, col, ...)` columna por columna, que se desincroniza en silencio cada vez que se agrega una columna. El trigger `pedidos_guard_estado` (0008) rechaza todo cambio de `estado` salvo que `app.transicion_estado` esté en `'on'`, y solo `cambiar_estado_pedido`, `renovar_pedido` y `marcar_pedidos_vencidos` la abren |
| 02/09 | La compuerta se pone con `set_config(..., true)`, local a la transacción | Con el tercer argumento en `false` el valor sobreviviría a la request y quedaría pegado al connection pool de Supabase: la conexión siguiente, de otro usuario, encontraría la puerta abierta. Local a la transacción, una RPC que aborta la revierte sola y PostgREST —que atiende cada request en su propia transacción— no la propaga. Igual se cierra a mano después del UPDATE, para que la ventana sea del tamaño mínimo |
| 02/09 | El guard es integridad, no seguridad | Cualquiera con una conexión SQL puede hacer `set_config('app.transicion_estado','on',...)` y abrir la puerta. Lo que la vuelve efectiva es que a través de PostgREST no hay forma de correr SQL arbitrario antes del PATCH. Quien contiene a un atacante es la RLS; el trigger está para que la propia app no se saltee su máquina de estados por descuido |
| 02/09 | El alta y el cambio de ubicación pasan a RPC; se borra `Ubicacion.aEwkt()` | El EWKT **funcionaba**: `'SRID=4326;POINT(lng lat)'` lo acepta la función de entrada de `geography` y PostgREST lo manda como texto sin enterarse. Se cambió por tres cosas que el EWKT no puede dar: el orden `(x, y) = (lng, lat)` dejaba de estar escrito en Dart y pasa a estar una sola vez, en `public.punto()` de la 0007; el rango de la coordenada se valida del lado del servidor (PostGIS acepta una latitud de 190 y la normaliza en silencio); y el estado inicial deja de ser elegible. `aEwkt()` se borró en vez de conservarse: era el único lugar de Dart donde estaba el orden de PostGIS, y dejarlo a mano invita a volver a usarlo |
| 02/09 | Las RPC nuevas devuelven `setof public.pedidos`, no `public.pedidos` | Con `setof`, PostgREST trata el resultado como un recurso y admite `select=*,lat,lng,categorias_oficio(nombre)` sobre la llamada: el alta sigue siendo **un solo viaje**. Con el tipo compuesto a secas devuelve la fila cruda, sin computed fields ni embeds, y hay que releer el pedido —que es lo que hoy hacen `cambiar_estado_pedido` y `renovar_pedido`, y conviene corregir cuando se las toque |
| 02/09 | Editar la ubicación es una llamada aparte de editar el resto | Un `geography` no se escribe desde un UPDATE de PostgREST. `actualizarPedido` manda primero la RPC de ubicación y después el PATCH de los campos de texto: en ese orden, una edición sobre un pedido cerrado falla antes de haber escrito nada, porque la RPC valida estado y dueño y el PATCH solo dueño. Costo asumido: son dos escrituras sin transacción común, así que si la segunda falla la primera queda hecha. La alternativa era una RPC con el formulario entero adentro y el problema del centinela para distinguir «no cambiar» de «poner en null» |
| 02/09 | El guard levanta un centinela, no una frase | `ESTADO_NO_MODIFICABLE_DIRECTAMENTE` es la única excepción a la regla de que los P0001 se muestran tal cual: no es un error del usuario sino un bug nuestro —una pantalla mandando `estado` en el payload de una edición— y no hay nada que explicarle a quien lo ve. El mensaje lo redacta la app. Se mapea por `hint`, y por el texto del centinela como red de contención si el hint se perdiera |
| 02/09 | Places **API (New)** en vez del servicio clásico con `components=country:ar` (CU-16) | El endpoint viejo no manda cabeceras CORS: desde el navegador toda llamada muere antes de salir. El filtro equivalente es `includedRegionCodes: ['ar']`. **Desvío respecto de la consigna del sprint**, que pedía el parámetro clásico |
| 02/09 | El `<script>` de Google Maps se inyecta desde Dart, no se escribe en `web/index.html` | La documentación de `google_maps_flutter_web` lo pone en el HTML, pero ahí la clave queda en un archivo del repositorio. La regla del proyecto es que las claves entran por `--dart-define`; se paga una espera la primera vez que se abre un mapa |
| 02/09 | La clave de Maps viaja por dos caminos: `--dart-define` para Dart/Web, `manifestPlaceholders` de Gradle para Android nativo | El SDK nativo no lee `--dart-define`, lee el `meta-data` del manifiesto. Es la misma clave cargada en los dos lados; `Env.googleMapsApiKey` no entra en `Env.esValido` porque sin mapa el resto de la app funciona igual |
| 02/09 | Ningún método de `ServicioDirecciones` tira excepción | La dirección es un campo de texto editable: un servicio caído degrada a «escribila vos», no a un alta interrumpida |
| 02/09 | El permiso de ubicación no se pide al abrir el selector, solo al tocar «Usar mi ubicación» | Disparar el diálogo del sistema apenas se abre una pantalla es la forma más rápida de que alguien apriete «no» sin leer, y en el navegador ese «no» queda pegado al sitio |
| 02/09 | La geocodificación inversa se filtra por distancia (15 m) y por origen del movimiento | El mapa se queda quieto muchas más veces de las que el usuario elige un punto (primer encuadre, `animateCamera`, teclado); se ignoran los movimientos que hizo el propio controlador |
| 03/09 | «Vencidos» es un grupo propio del historial, no parte de un «Historial» común | No es un final: es lo único que se puede renovar (CU-51). Meterlo junto a cerrados y cancelados escondería la única acción que le queda. Por lo mismo, cerrados y cancelados van separados: la diferencia entre «se resolvió» y «no se hizo» es la que mide si Laburito sirve |
| 03/09 | La búsqueda del CU-17 se sanea antes de armar el filtro | El `or` de PostgREST separa condiciones con comas, así que una coma escrita por el usuario parte la expresión y el servidor contesta 400 en vez de cero resultados. Se reemplazan comas, paréntesis y asteriscos por espacios, y con menos de dos caracteres no se busca: un `ilike` de una letra recorre la tabla entera para devolver casi todo |
| 03/09 | Los contadores de las pestañas no respetan la búsqueda | Dicen cuánto hay en cada grupo, que es lo que sirve para elegir pestaña. Si cambiaran con cada letra tecleada dejarían de ser un punto de referencia |
| 03/09 | El color de una acción dice **qué desenlace produce**, no si es reversible | «Cerrar» estaba en rojo, como «Cancelar», y se leía como «eliminar». Cerrar es el final bueno —el trabajo se resolvió— y la misma pantalla ya dibuja el pedido cerrado en verde con un tilde: el botón que lleva ahí no puede decir lo contrario. La irreversibilidad la comunica el diálogo, que además exige elegir un motivo antes de habilitar la confirmación. Queda: azul lo que deja el pedido en curso, verde cerrar, rojo cancelar. Cubierto en `test/pedidos_ciclo_vida_test.dart` |
| 03/09 | La fila de `profesionales` la repara una migración, no la app (0011) | Sobre esa tabla no hay política de INSERT para el usuario, a propósito: solo SELECT y UPDATE. El único que puede crear la fila es el trigger `handle_new_user`, que es SECURITY DEFINER. Darle al cliente permiso de INSERT para que se repare solo dejaría que cualquiera se fabrique una fila de Profesional |
| 03/09 | `handle_new_user` pasa a ser idempotente | Corre dentro de la transacción del signUp: un DNI repetido o un reintento sobre un id que ya tenía perfil tumbaba **el alta entera** con un error de base en la cara del usuario. Con `on conflict do nothing` el alta sigue y lo que falte se completa después desde el perfil (CU-05) |
| 03/09 | Los formularios del pedido viven en `widgets/campos_pedido.dart`, no adentro del asistente | El CU-15 pide «los mismos formularios» que el CU-13. Duplicarlos garantizaba que en algún momento el alta aceptara un título de 4 caracteres que la edición rechazara. Las reglas están una sola vez, en `ValidadoresPedido`, y son las mismas de los `check` de la tabla `pedidos` |
| 03/09 | **La vigencia no se edita en el CU-15** | Estirar `fecha_vencimiento` con un PATCH sería una renovación sin límite, y el CU-51 permite tres. La fecha se mueve solo por `renovar_pedido`, que las cuenta. La app no manda ese campo; el servidor todavía no lo impide (deuda de la sección 6) |
| 03/09 | Las fotos de la edición se aplican al instante; el resto, al guardar | El pedido ya existe, así que subir y borrar son operaciones sobre Storage que no tienen nada que esperar. Juntarlas hasta el «Guardar» obligaría a deshacer subidas si la edición falla. La pantalla lo dice en un renglón, para que nadie espere que «descartar cambios» devuelva una foto borrada |
| 03/09 | El evento de edición se marca con `estado_anterior = estado_nuevo` y el motivo `edicion` (migración 0010) | `pedido_eventos` solo lo escribía el trigger que dispara al cambiar el estado, y una edición no cambia el estado: quedaba sin rastro. Un Profesional que leyó el pedido ayer y lo ve distinto hoy tiene que poder verlo en la cronología. No se agrega un enum ni una columna nueva: el motivo ya existe y es texto. SECURITY DEFINER porque sobre `pedido_eventos` no hay política de INSERT, a propósito |
| 03/09 | Un fallo al registrar la edición **no** hace fallar la edición | La edición ya se escribió y no se puede deshacer (son escrituras sin transacción común, igual que la ubicación). Mostrar «no se pudo guardar» sobre datos que sí se guardaron es peor que un renglón faltante en la cronología. Queda en la consola |
| 03/09 | «Renovar» se ofrece también sobre un pedido caduco que todavía figura publicado o pausado | Es el mismo caso real: el barrido `marcar_pedidos_vencidos` no corrió. Sin eso, un pedido pausado y caduco no se puede ni reanudar —la RPC lo rechaza y manda a renovar— ni renovar, y queda en un callejón sin salida. Es un desvío consciente del «solo en vencido» de la consigna |
| 03/09 | Las URLs firmadas se piden en lote con `createSignedUrlsResult` y se cachean hasta 2 minutos antes de vencer | Una página del historial son 20 portadas: firmarlas de a una son 20 viajes contra uno. El plural clásico (`createSignedUrls`) está deprecado justamente porque no distingue una ruta que no se pudo firmar de una que sí, y esa diferencia es la que decide entre mostrar la foto o el placeholder. El margen evita entregar una firma que expira mientras la imagen se descarga |
| 03/09 | Las fechas en castellano se escriben a mano (`core/utils/fechas.dart`), sin `DateFormat` | Formatear en español obliga a inicializar los datos de locale de `intl`; si falta, la app no falla al compilar sino **al dibujar la primera fecha**, que es el peor momento posible. Hacen falta seis frases y ningún calendario. La diferencia de días se cuenta por calendario y no por múltiplos de 24 h: a las 23:00, «mañana a las 08:00» tiene que decir «vence mañana», no «vence hoy» |
| 03/09 | El piso de iOS pasa a 14 y la clave de Maps viaja por un **tercer** camino | `google_maps_flutter_ios` declara `platform :ios, '14.0'`: con 13 no hay `pod install` que funcione. Y el SDK nativo de iOS no lee `--dart-define` ni el manifiesto de Android: lee el `Info.plist`, que toma `MAPS_API_KEY` de `ios/Flutter/Maps.xcconfig` (gitignored, con `.example` al lado). Con la clave vacía no se llama a `provideAPIKey`: con `""` el SDK aborta la app al arrancar |
| 14/09 | **Las migraciones se aplican y se verifican desde la CLI** (`supabase db query --linked -f`), envueltas en `begin … commit` | Antes se pegaban en el SQL Editor y nadie comprobaba el resultado: el ESTADO del 03/09 decía que ninguna migración se había corrido y la base las tenía todas. Con la CLI se ensaya con `rollback`, se aplica atómica y el guion de aceptación corre contra la base real. Las pruebas de RLS bajan a `authenticated` con `set local role` y un `request.jwt.claims` falso, dentro de una transacción que termina en rollback |
| 14/09 | La zona de cobertura va en tabla propia y **se borran** `profesionales.ubicacion` y `radio_cobertura_km` (0012) | Las columnas venían de la 0001 y nadie las usaba. Dejarlas era tener dos lugares donde vive la zona, y el emparejamiento del CU-21 terminaría leyendo el que nadie actualiza. Radio en metros, la unidad de `ST_DWithin` sobre geography |
| 14/09 | El índice de la zona se usa filtrando primero por el radio máximo | `ST_DWithin` con el radio tomado de la fila no aprovecha el GiST: el planificador necesita un radio constante. El CU-21 filtra con `100000` (índice) y después con `radio_metros` (exacto). Un polígono de buffer indexado se descartó: es inscripto, y deja afuera pedidos que están en el borde del radio |
| 14/09 | La zona de cobertura no la ve nadie más que el dueño y el admin | El centro aproxima el domicilio del Profesional. El emparejamiento corre con `service_role` en la Edge Function y no la necesita a través de RLS |
| 14/09 | Los horarios no se superponen por **restricción de exclusión**, no por un trigger que cuente | Es la única regla del esquema del Profesional que no necesita bloqueo: la exclusión es atómica frente a dos inserciones simultáneas. Requiere `btree_gist` en `extensions`. Una franja no cruza medianoche; la que termina a medianoche va hasta `24:00` |
| 14/09 | Tope del portafolio: **10 fotos**, con `for update` sobre `profesionales` antes del `count` | El plan decía «N». Mismo patrón que el tope de 5 fotos del pedido (0005). También dispara si cambia `profesional_id` |
| 14/09 | El bucket del portafolio sigue siendo `portafolios`, pero privado | La 0001 lo creó público y sin políticas. Renombrarlo a `portafolio` dejaba un bucket huérfano; estaba vacío, así que pasarlo a privado no rompe enlaces. La lectura sigue a la del Profesional: se firma una foto cuando se ve a su dueño |
| 14/09 | La visibilidad de horarios y portafolio se hereda con `exists` sobre `profesionales` | El `exists` corre con las RLS de quien consulta: la fila se ve exactamente cuando se ve al Profesional (dueño, admin, o aprobado y activo). No se duplica la regla de «perfil público» en cada tabla |
| 14/09 | El token de FCM es único en toda la tabla; el traspaso entre cuentas lo hará una RPC | El token es de la instalación, no del usuario: si en el mismo teléfono cambia la sesión, el Profesional anterior no puede seguir recibiendo alertas. Con RLS el nuevo dueño no ve la fila vieja, así que el traspaso va en la RPC SECURITY DEFINER del CU-21 b |
| 14/09 | Guardar o ignorar un pedido exige verlo | El `exists` sobre `pedidos` en el `with check` corre con RLS: solo entran pedidos publicados y vigentes. Sin eso, la FK permitía confirmar si un uuid de pedido existe |
| 14/09 | La baja (CU-11) borra las filas nuevas del Profesional, no los archivos del portafolio | La fila de `profesionales` sobrevive a la baja, así que los `on delete cascade` no disparan. Los archivos los tiene que borrar el cliente por la API, como el avatar y el DNI (0004) |
| 02/09 | El botón «Mi ubicación» y las sugerencias de búsqueda van en la columna del `SelectorUbicacion`, no flotando sobre el mapa | En Web, `GoogleMap` se dibuja con `HtmlElementView`, y un widget interactivo apilado arriba necesita `pointer_interceptor` para recibir el mouse. Se resolvió con una columna —búsqueda arriba, mapa con solo el pin encima (`IgnorePointer`, no necesita recibir toques), panel de «mi ubicación»/dirección/referencia abajo— en vez de sumar otra dependencia |

## 6. Deuda técnica y pendientes conocidos

| Ítem | Detalle | Cuándo se salda |
|---|---|---|
| Aprobación manual de Profesionales | CU-09 deja al Profesional en «En Revisión» pero CU-35 (resolverla) recién está en Sprint 6. Se aprueba a mano por SQL. | Sprint 6 |
| Categorías de oficio | Se cargan por seed en T-02; su ABM (CU-37) es del Sprint 6 | Sprint 6 |
| ~~Providers escritos a mano~~ | **Saldada el 02/09.** Todo el proyecto pasó a `@riverpod` y `freezed`. La UI no se tocó: los nombres generados coinciden con los de antes. | ✅ |
| ~~El estado del pedido se puede cambiar sin pasar por la RPC~~ | **Saldada el 02/09 con la migración 0008.** Trigger `pedidos_guard_estado` `BEFORE UPDATE` + compuerta `app.transicion_estado` en las tres RPC que sí pueden mover el estado. | ✅ |
| ~~Un pedido puede nacer en un estado terminal~~ | **Saldada el 02/09 con la migración 0009.** Trigger `pedidos_guard_alta` `BEFORE INSERT`, con la misma compuerta que el de UPDATE. | ✅ |
| El PATCH de edición no mira el estado del pedido | `actualizar_ubicacion_pedido` exige que el pedido esté `publicado` o `pausado`, pero el UPDATE de PostgREST que cambia título, descripción o presupuesto no: la RLS solo comprueba dueño. Hoy se le puede editar el título a un pedido cerrado. No molesta a nadie —el pedido ya no se lista— pero es una regla del CU-15 que vive solo en el cliente. | Sprint 3 |
| El Profesional no puede ver las fotos de un pedido | Las políticas de Storage del bucket `pedidos` son solo del dueño, así que el CU-16 no va a poder firmar las URLs. Falta una política de SELECT para pedidos publicados vigentes, o firmarlas desde una Edge Function. | Sprint 3 (T-08, migración 0013) |
| **Un Profesional puede aprobarse solo y cargarse tokens** | La política «profesional propio: actualización» (0001/0002) es de fila entera, como la de `pedidos` antes de la 0008: el dueño puede escribir `estado_verificacion`, `saldo_tokens`, `calificacion_promedio` y `total_calificaciones` con un PATCH. Importa ya: el CU-21 va a notificar según la verificación, y el Sprint 4 cobra tokens. Se cierra con un trigger `BEFORE UPDATE` del patrón de `pedidos_guard_estado`, dejándole al dueño solo `descripcion`, `dni` y `disponible` | Sprint 3, antes del CU-21 |
| La baja no borra los archivos del portafolio | `dar_de_baja_cuenta` ya borra las filas (0012), pero `PerfilRepository._borrarArchivos` solo baja avatar y DNI. Hoy el bucket está vacío y no hay pantalla de carga | Sprint 3, con el CU-06 (Fase 9) |
| Historial de migraciones de la CLI vacío | 0001–0012 están aplicadas pero `supabase migration list` no lo sabe, así que `supabase db push` intentaría correrlas todas otra vez. No usar `db push` hasta hacer `supabase migration repair --status applied` de las doce | Cuando se adopte `db push` |
| ~~`flutter test` y los builds se dejan de correr fase por fase~~ | **Saldada el 03/09.** La verificación diferida se hizo entera al cerrar la Fase 6: analyze 0 issues, 101 tests en verde, y web, APK e iOS compilando. La apuesta salió bien: no había ningún error acumulado de las Fases 5 y 6 | ✅ |
| ~~CU-17 Consultar Historial (Fase 7)~~ | **Hecho el 03/09.** Con los cuatro grupos y sus contadores, búsqueda por texto en el servidor, scroll infinito de 20, pull to refresh que corre el barrido de vencimientos, portadas firmadas en lote y dos estados vacíos distintos | ✅ |
| **CU-18 Reenvío de Enlace de Gestión (Fase 8) — replanificado** | No se hizo. Ya estaba marcado como descartable en el plan del sprint: es el único ítem que no condiciona nada del Sprint 3 y se replanifica al Sprint 5, donde ya hay trabajo de enlaces públicos (CU-26 y CU-27) | Sprint 5 |
| ~~Pruebas de widget del Sprint 2 (Fase 9a)~~ | **Saldada el 03/09.** 62 pruebas nuevas, de 101 a **163**: el asistente del CU-13 contra el árbol de widgets, los diálogos del ciclo de vida, la barra de acciones en los cinco estados, el borrador de edición del CU-15, los validadores compartidos y las fechas. Ninguna toca Supabase | ✅ |
| El ciclo de vida (Fase 6) sin ejercitar contra una base real | Las pruebas de widget cubren la UI y la máquina de estados del lado del cliente, pero nadie tocó todavía los botones de pausar, cerrar, cancelar, renovar y editar contra Supabase. Depende de aplicar las migraciones | Antes de la demo |
| El PATCH de edición tampoco mira `fecha_vencimiento` | Del mismo tipo que el ítem de arriba sobre el estado: la app no manda ese campo al editar (decisión del 03/09), pero la RLS no lo impide, así que un cliente que lo mandara renovaría sin gastar renovaciones. Se cierra con un trigger, como el `pedidos_guard_estado` de la 0008 | Sprint 3 |
| Sin pruebas de widget ni de integración | Hay 18 pruebas unitarias de validadores y mensajes, más 3 de widget en `test/tema_test.dart` que cubren el lineamiento visual, más `mapa_config_test.dart`/`servicio_direcciones_test.dart` del CU-16 (101 en total). Los circuitos se verifican a mano con el guion de `ARRANQUE.md`. El wizard del CU-13 no tiene pruebas de widget todavía (ver Fase 9 del plan del sprint) | Sprint 2 |
| Figura 3.1 del Anexo UI desactualizada | Muestra 3 campos; el alta tiene los 5 del CU-01. Hay que redibujarla antes de entregar el Anexo. | Antes de la entrega |
| Textos legales provisorios | `/legales/terminos` y `/legales/privacidad` describen el alcance pero no son la redacción definitiva. | Sprint 3 |
| Barra superior de la web | La Figura 3.1 la muestra con «Cómo funciona · Mis pedidos · Ayuda»; las tres secciones son de sprints posteriores. | Sprint 2 |
| CTA fija al pie en móvil | El Anexo la muestra anclada abajo (Fig. 3.9, 3.11, 3.15); acá va al final del formulario. | Sprint 2 |
| Logotipo definitivo | Van dos PNG en `assets/logo/`: `laburito.png` y `laburito_isotipo.png`. Sin ellos, la app dibuja versiones de reserva. Ver `assets/logo/README.md`. | Al tener los archivos |
| Íconos de app y favicon | Android, iOS y Web siguen con los íconos de Flutter. Se generan con `flutter_launcher_icons` cuando esté el PNG. | Al tener el archivo |
| Tipografía del Anexo | Se usa la del sistema; el Anexo muestra una sans geométrica. Sumarla implica versionar la fuente. | Sprint 3 |

## 7. Próximo paso concreto

_(Lo primero que hay que hacer al retomar. Está en orden: cada punto depende
del anterior.)_

### 7.1 Sprint 3 — lo que sigue

1. **Fase 2 — T-08, migración 0013** (plan, Fase 2): lectura del bucket
   `pedidos` para el Profesional y guard del PATCH de edición (estado y
   `fecha_vencimiento`). Mismo método que la 0012: ensayo con `rollback`,
   aplicación en transacción y guion de aceptación contra la base.
2. **Guard de las columnas sensibles de `profesionales`** (sección 6): un
   Profesional hoy puede aprobarse solo. Tiene que estar cerrado antes del
   CU-21, que filtra por verificación. Si entra en la 0013 o en una
   migración propia se decide al abrir la Fase 2.
3. Fase 3 — CU-07 Zona de cobertura, sobre la tabla de la 0012. Le faltan a la
   base los *computed fields* `lat`/`lng` de la zona y la RPC de guardado con
   `public.punto()`, igual que los pedidos (decisiones del 02/09).

### 7.2 Arrastrado de sprints anteriores

4. **Circuito completo contra la base**: publicar un pedido con foto y
   ubicación, y después pausar, reanudar, editar, renovar, cerrar y cancelar.
   Las migraciones ya están aplicadas (verificado el 14/09); lo que falta es
   ejercitar la app. Hay un Profesional aprobado para las pruebas del Sprint 3.
5. `CHANGELOG.md` con `v0.1.0` y `v0.2.0`: los tags existen y están
   pusheados, el archivo no.
6. Del **Sprint 1** sigue pendiente el material de la entrega: el video de los
   7 circuitos de `ARRANQUE.md`, la captura del Schema Visualizer y de la
   tabla de políticas RLS, y la subida a BB.
7. Si iOS vuelve a fallar después de agregar un plugin: `cd ios && pod install
   --repo-update`. El piso es iOS 14.

---

## 8. Convención de commits

`<tipo>(<ID>): <descripción en infinitivo>`

```
feat(CU-01): registrar buscador con validación de email
feat(T-02): esquema inicial, RLS y seed de categorías
fix(CU-03): manejar sesión expirada al reabrir la app
docs(S1): completar sección 7.1 del Sprint Planning
chore: actualizar dependencias
```

Con esta convención, `git log --oneline --since="2026-08-06"` es la evidencia
automática del sprint para la Sección 2 del documento de planificación.
