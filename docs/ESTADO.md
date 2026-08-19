# ESTADO — Laburito

> **Fuente de verdad del proyecto.** Este archivo se actualiza al cerrar cada sesión de trabajo.
> Vive en `docs/ESTADO.md` del repo y se commitea junto con el código.
> Última actualización: 19/08/2026

---

## 0. Cómo abrir un chat nuevo con Claude

Cuando el chat se pone largo o cambiás de tema, abrí uno nuevo y hacé esto:

1. **Subí** `docs/ESTADO.md` + `docs/sprints/SPRINT-01.md` + los archivos de código puntuales del tema.
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
| 19/08 | Documentos del CU-09 solo como imagen | Un único camino de código con `image_picker` en Web y móvil; el DNI y la selfie son fotos |
| 19/08 | El router bloquea el home con el correo sin validar | El CU-08 exige que sin PIN no se entre. Se comprueba `emailConfirmedAt` en el `redirect`, no solo la existencia de sesión |
| 19/08 | El CU-04 cierra las demás sesiones al cambiar la contraseña | `signOut(scope: others)` después del `updateUser`: si alguien entró con la contraseña vieja, queda afuera |
| 19/08 | Historial de Git reescrito en 12 commits, uno por ítem | El sprint entero había quedado en un solo commit y la evidencia que pide la Sección 2 es `git log` por caso de uso. El commit original quedó en la rama `respaldo-commit-unico` |

## 5. Deuda técnica y pendientes conocidos

| Ítem | Detalle | Cuándo se salda |
|---|---|---|
| Aprobación manual de Profesionales | CU-09 deja al Profesional en «En Revisión» pero CU-35 (resolverla) recién está en Sprint 6. Se aprueba a mano por SQL. | Sprint 6 |
| Categorías de oficio | Se cargan por seed en T-02; su ABM (CU-37) es del Sprint 6 | Sprint 6 |
| Providers escritos a mano | Sin `build_runner`, `freezed` ni `riverpod_generator`. Migrable sin tocar la UI. | Sprint 2 |
| Sin pruebas de widget ni de integración | Hay 18 pruebas unitarias de validadores y mensajes. Los circuitos se verifican a mano con el guion de `ARRANQUE.md`. | Sprint 2 |

## 6. Próximo paso concreto

_(Una sola línea. Lo primero que hay que hacer al retomar.)_

→ **Correr el guion de prueba de `ARRANQUE.md` contra el proyecto Supabase real y grabar el video de los 7 circuitos.**

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
