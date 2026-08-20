# ESTADO — Laburito

> **Fuente de verdad del proyecto.** Este archivo se actualiza al cerrar cada sesión de trabajo.
> Vive en `docs/ESTADO.md` del repo y se commitea junto con el código.
> Última actualización: 19/08/2026

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
produjo una decisión técnica, va a la sección 4 de este archivo antes de cerrar.

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
| Sprint en curso | **Sprint 1 — Fundaciones y Autenticación** (PT 2.0) · **cerrado en código** |
| Período | 06/08/2026 – 19/08/2026 |
| Entrega por BB | 19/08/2026 23:59 |
| Reunión de revisión | 20/08/2026 |
| Esfuerzo planificado | 35 pts |
| Esfuerzo ejecutado | **35 pts** (12 de 12 ítems) |
| Backlog restante | 200 pts de 235 |
| Release objetivo | v0.1.0 — tag creado |
| Repositorio | https://github.com/tarevaloit/laburito |
| Proyecto Supabase | _(completar ref)_ |

## 2. Stack vigente

- **Flutter / Dart** — Web (Buscador) + App nativa (Profesional) + Panel desktop (Admin)
- **Supabase** — Auth, PostgreSQL, RLS, Storage, Edge Functions *(reemplazó a Firebase)*
- **Riverpod** — gestión de estado *(reemplazó a Bloc)*
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

## 4. Decisiones técnicas tomadas

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

## 5. Deuda técnica y pendientes conocidos

| Ítem | Detalle | Cuándo se salda |
|---|---|---|
| Aprobación manual de Profesionales | CU-09 deja al Profesional en «En Revisión» pero CU-35 (resolverla) recién está en Sprint 6. Se aprueba a mano por SQL. | Sprint 6 |
| Categorías de oficio | Se cargan por seed en T-02; su ABM (CU-37) es del Sprint 6 | Sprint 6 |
| Providers escritos a mano | Sin `build_runner`, `freezed` ni `riverpod_generator`. Migrable sin tocar la UI. | Sprint 2 |
| Sin pruebas de widget ni de integración | Hay 18 pruebas unitarias de validadores y mensajes, más 3 de widget en `test/tema_test.dart` que cubren el lineamiento visual. Los circuitos se verifican a mano con el guion de `ARRANQUE.md`. | Sprint 2 |
| Figura 3.1 del Anexo UI desactualizada | Muestra 3 campos; el alta tiene los 5 del CU-01. Hay que redibujarla antes de entregar el Anexo. | Antes de la entrega |
| Textos legales provisorios | `/legales/terminos` y `/legales/privacidad` describen el alcance pero no son la redacción definitiva. | Sprint 3 |
| Barra superior de la web | La Figura 3.1 la muestra con «Cómo funciona · Mis pedidos · Ayuda»; las tres secciones son de sprints posteriores. | Sprint 2 |
| CTA fija al pie en móvil | El Anexo la muestra anclada abajo (Fig. 3.9, 3.11, 3.15); acá va al final del formulario. | Sprint 2 |
| Logotipo definitivo | Van dos PNG en `assets/logo/`: `laburito.png` y `laburito_isotipo.png`. Sin ellos, la app dibuja versiones de reserva. Ver `assets/logo/README.md`. | Al tener los archivos |
| Íconos de app y favicon | Android, iOS y Web siguen con los íconos de Flutter. Se generan con `flutter_launcher_icons` cuando esté el PNG. | Al tener el archivo |
| Tipografía del Anexo | Se usa la del sistema; el Anexo muestra una sans geométrica. Sumarla implica versionar la fuente. | Sprint 3 |

## 6. Próximo paso concreto

_(Una sola línea. Lo primero que hay que hacer al retomar.)_

→ **Aplicar `supabase/migrations/0004_cu11_storage_sin_dml.sql` en el SQL Editor** (sin eso el CU-11 falla), y después correr el guion de prueba de `ARRANQUE.md` y grabar el video de los 7 circuitos.

El código está completo y compila en Web y en Android; lo que queda del Sprint 1
es la prueba contra el backend configurado y el material de la entrega. El
Sprint 2 arranca por CU-13 y CU-16.

---

## 7. Convención de commits

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
