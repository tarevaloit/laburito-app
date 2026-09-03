# ESTADO — Laburito

> **Fuente de verdad del proyecto.** Este archivo se actualiza al cerrar cada sesión de trabajo.
> Vive en `docs/ESTADO.md` del repo y se commitea junto con el código.
> Última actualización: 02/09/2026

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

---

## 1. Snapshot

| Campo | Valor |
|---|---|
| Sprint en curso | **Sprint 2 — Pedidos** (PT 3.0) · rama `sprint-2` |
| Sprint anterior | Sprint 1 — Fundaciones y Autenticación (PT 2.0) · **cerrado en código**, 35/35 pts |
| Período | _(completar del PT 3.0)_ |
| Entrega por BB | _(completar del PT 3.0)_ |
| Esfuerzo planificado | _(completar del PT 3.0)_ |
| Backlog restante | 200 pts de 235 al cierre del Sprint 1 |
| Release objetivo | v0.2.0 — el tag `v0.1.0` cerró el Sprint 1 |
| Repositorio | https://github.com/tarevaloit/laburito |
| Proyecto Supabase | _(completar ref)_ |

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

## 4. Sprint 2 — en curso (PT 3.0)

Rama: **`sprint-2`**, salida de `main` (no del tag `v0.1.0`: main tiene 5 commits
posteriores al tag, incluido todo el ANEXO UI y el arreglo del CU-11).

### 4.1 Alcance

Estados: `⬜ pendiente` · `🟡 en curso` · `✅ hecho` · `⏭️ replanificado`

| ID | Ítem | Pts | Estado | Figura del ANEXO UI |
|---|---|---|---|---|
| CU-16 | Localizar Pedido en Mapa | 8 | ✅ | — |
| CU-13 | Publicar pedido con ubicación en el mapa | ? | 🟡 | Fig. 3.2 |
| CU-14 | _(completar del PT 3.0)_ | ? | ⬜ | — |
| CU-15 | _(completar del PT 3.0)_ | ? | ⬜ | — |
| CU-20 | Gestión del pedido publicado | ? | ⬜ | Fig. 3.4 |
| CU-29 | Gestión del pedido publicado (contraparte de CU-20) | ? | ⬜ | Fig. 3.4 |
| CU-51 | _(completar del PT 3.0)_ | ? | ⬜ | — |
| CU-17 | Historial de pedidos del Buscador | ? | ⬜ | Fig. 3.5 |
| CU-18 | _(completar del PT 3.0)_ | ? | ⬜ | — |
| | **Total** | **?** | | |

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
| El Profesional no puede ver las fotos de un pedido | Las políticas de Storage del bucket `pedidos` son solo del dueño, así que el CU-16 no va a poder firmar las URLs. Falta una política de SELECT para pedidos publicados vigentes, o firmarlas desde una Edge Function. | Sprint 2 (con CU-16) |
| **A partir del 02/09 (Fase 5): `flutter test`, `flutter build web` y `flutter build apk` se dejan de correr fase por fase** | Decisión explícita para priorizar velocidad de desarrollo con la entrega encima: se corre solo `flutter analyze` (0 issues) después de cada cambio, que tarda segundos y evita seguir escribiendo sobre código roto. La verificación completa —tests, build web, build APK— se hace una sola vez al terminar todas las fases del sprint, no en cada una. Riesgo asumido: un error de *runtime* que `analyze` no detecta (por ejemplo un `initialValue` que no existe en cierta versión de un widget) puede acumularse en varias fases sin que se note hasta el cierre | Al cerrar el desarrollo del Sprint 2 |
| Wizard de alta (CU-13) sin ejercitar contra la app corriendo ni con pruebas de widget | Se escribió y se revisó a mano (no hay `flutter test`/`flutter run` de por medio, ver el ítem de arriba). Falta la corrida real: elegir categoría, completar los 4 pasos, publicar, y confirmar que el `DropdownButtonFormField` con `initialValue` refleja bien la selección al volver a un paso | Al cerrar el desarrollo del Sprint 2 |
| Sin pruebas de widget ni de integración | Hay 18 pruebas unitarias de validadores y mensajes, más 3 de widget en `test/tema_test.dart` que cubren el lineamiento visual, más `mapa_config_test.dart`/`servicio_direcciones_test.dart` del CU-16 (101 en total). Los circuitos se verifican a mano con el guion de `ARRANQUE.md`. El wizard del CU-13 no tiene pruebas de widget todavía (ver Fase 9 del plan del sprint) | Sprint 2 |
| Figura 3.1 del Anexo UI desactualizada | Muestra 3 campos; el alta tiene los 5 del CU-01. Hay que redibujarla antes de entregar el Anexo. | Antes de la entrega |
| Textos legales provisorios | `/legales/terminos` y `/legales/privacidad` describen el alcance pero no son la redacción definitiva. | Sprint 3 |
| Barra superior de la web | La Figura 3.1 la muestra con «Cómo funciona · Mis pedidos · Ayuda»; las tres secciones son de sprints posteriores. | Sprint 2 |
| CTA fija al pie en móvil | El Anexo la muestra anclada abajo (Fig. 3.9, 3.11, 3.15); acá va al final del formulario. | Sprint 2 |
| Logotipo definitivo | Van dos PNG en `assets/logo/`: `laburito.png` y `laburito_isotipo.png`. Sin ellos, la app dibuja versiones de reserva. Ver `assets/logo/README.md`. | Al tener los archivos |
| Íconos de app y favicon | Android, iOS y Web siguen con los íconos de Flutter. Se generan con `flutter_launcher_icons` cuando esté el PNG. | Al tener el archivo |
| Tipografía del Anexo | Se usa la del sistema; el Anexo muestra una sans geométrica. Sumarla implica versionar la fuente. | Sprint 3 |

## 7. Próximo paso concreto

_(Una sola línea. Lo primero que hay que hacer al retomar.)_

→ **CU-16: configurar Google Maps y escribir el `SelectorUbicacion`**, que es lo que el asistente del CU-13 necesita para el paso «Dónde».

Antes de eso: **aplicar en el SQL Editor, en orden,
`0004_cu11_storage_sin_dml.sql`, `0005_pedidos.sql`, `0006_pedidos_rls.sql`,
`0007_pedidos_coordenadas.sql`, `0008_pedidos_guard_estado.sql` y
`0009_pedidos_alta_y_ubicacion.sql`**, y correr el guion de prueba que cada una
trae al final. `supabase/scripts/verificar_pedidos.sql` dice cuáles están
aplicadas, y su bloque 8 avisa del único orden peligroso: la 0008 aplicada a
medias —el trigger sí, las RPC no— deja el sistema **peor** que antes, porque
entonces nada puede mover el estado.

Del Sprint 1 sigue pendiente el material de la entrega: el video de los 7
circuitos de `ARRANQUE.md`, la captura del Schema Visualizer y de la tabla de
políticas RLS, y la subida a BB.

Del Sprint 2 está hecha la capa de datos de pedidos —esquema, RLS, máquina de
estados blindada, renovación y el repositorio con sus providers y tests— pero
**ninguna migración se probó contra una base**: no hay Docker en esta máquina,
así que el SQL está escrito y revisado pero nunca ejecutado. Cada una trae su
guion de aceptación comentado al final para correr en el SQL Editor; hasta que
eso pase, «migración aplicada» no quiere decir «migración verificada».

Después de aplicarlas, lo que sigue es la UI del CU-13 (formulario y mapa) y la
deuda que queda abierta de esta capa: la política de Storage que le deje al
Profesional ver las fotos de un pedido publicado (CU-16).

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
