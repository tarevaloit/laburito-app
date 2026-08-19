# Sprint 1 — Cierre · Sección 7.1

**Laburito · Seminario de Integración Profesional 2026 · Comisión P03**
**PT 2.0 · 06/08/2026 → 19/08/2026 · Release v0.1.0**

Este documento cubre los cinco componentes que exige la Sección 2 del documento
de planificación. La evidencia de commits está en `evidencia-sprint-01.txt`,
en esta misma carpeta.

---

## 1. Planificado

Los 12 ítems del PT 2.0, tal como se comprometieron en el apartado 4.1.

| ID | Ítem | Tipo | Pts |
|---|---|---|---|
| T-01 | Setup Flutter + Git + capas + Riverpod | Técnico | 5 |
| T-02 | Supabase: modelo, RLS, buckets, seed de categorías | Técnico | 8 |
| CU-01 | Registrar Buscador | Caso de uso | 2 |
| CU-08 | Validar Email de Buscador (PIN) | Caso de uso | 2 |
| CU-03 | Iniciar Sesión | Caso de uso | 2 |
| CU-10 | Cerrar Sesión | Caso de uso | 1 |
| CU-50 | Logout del Sistema | Caso de uso | 1 |
| CU-02 | Registrar Profesional | Caso de uso | 3 |
| CU-09 | Validar Documentación (carga) | Caso de uso | 3 |
| CU-05 | Gestionar Perfil | Caso de uso | 3 |
| CU-11 | Dar de Baja Cuenta | Caso de uso | 3 |
| CU-04 | Recuperar Contraseña | Caso de uso | 2 |
| | **Total comprometido** | | **35** |

---

## 2. Realizado

| ID | Pts plan. | Pts ejec. | Estado | Commit |
|---|---|---|---|---|
| T-01 | 5 | 5 | ✅ Hecho | `addb506` |
| T-02 | 8 | 8 | ✅ Hecho | `f979211`, `5f0dc84` |
| CU-01 | 2 | 2 | ✅ Hecho | `fcd2ca2` |
| CU-08 | 2 | 2 | ✅ Hecho | `8abfd45` |
| CU-03 | 2 | 2 | ✅ Hecho | `feb56b1` |
| CU-10 | 1 | 1 | ✅ Hecho | `feb56b1` |
| CU-50 | 1 | 1 | ✅ Hecho | `feb56b1` |
| CU-02 | 3 | 3 | ✅ Hecho | `866571a` |
| CU-09 | 3 | 3 | ✅ Hecho | `415f65e` |
| CU-05 | 3 | 3 | ✅ Hecho | `1e05627` |
| CU-11 | 3 | 3 | ✅ Hecho | `0f0d4f2` |
| CU-04 | 2 | 2 | ✅ Hecho | `6170dc9` |
| | **35** | **35** | | |

**Esfuerzo ejecutado: 35 de 35 puntos. Velocidad del Sprint 1: 35 pts.**

CU-10 y CU-50 comparten commit porque el backlog los declara implementados en
conjunto: son el mismo `signOut()` visto desde el actor y desde el sistema.
T-02 tiene dos commits porque la migración `0002` se escribió después, al
aparecer el problema de RLS que se documenta en el punto 4.

### Verificación técnica al cierre

| Control | Resultado |
|---|---|
| `flutter analyze` | 0 issues |
| `flutter test` | 18 pruebas, todas en verde |
| `flutter build web` | Compila |
| `flutter build apk --debug` | Compila |

---

## 3. Faltantes y replanificación

**No quedó ningún ítem del compromiso sin cerrar.** Los 12 ítems y los 35 puntos
se ejecutaron dentro del sprint.

Lo que sí se arrastra, y ya estaba previsto en la planificación, no es deuda del
sprint sino alcance de sprints posteriores:

| Pendiente | Por qué no es del Sprint 1 | Sprint |
|---|---|---|
| Aprobación de la documentación del Profesional | El CU-09 cubre la carga; resolver la revisión es el CU-35, que está planificado en el Sprint 6. Mientras tanto se aprueba a mano por SQL. | 6 |
| ABM de categorías de oficio | Las categorías se cargan por seed en T-02; su ABM es el CU-37. | 6 |
| Codegen de Riverpod y `freezed` | Decisión del 19/08: los providers se escriben a mano para sacar `build_runner` del camino crítico. Migrable sin tocar la UI. | 2 |

---

## 4. Problemas encontrados

Los cuatro que efectivamente costaron tiempo y que conviene dejar documentados.

### 4.1 Supabase manda un enlace, no un PIN

El CU-08 y el CU-04 se diseñaron con un código de 6 dígitos. Las plantillas de
correo que trae Supabase por defecto envían un enlace de confirmación, así que
las pantallas de código quedaban esperando un dato que nunca llegaba.

**Solución.** Reescribir las plantillas *Confirm signup* y *Reset password* para
que emitan `{{ .Token }}`. Con eso, un solo patrón de pantalla sirve para los dos
circuitos y no hace falta configurar deep links ni en Web ni en móvil.
**Costo:** media jornada, casi toda en entender que el problema estaba en la
configuración del proyecto y no en el código.

### 4.2 Las categorías del Profesional no se podían insertar durante el alta

El CU-02 tiene que crear las filas de `profesional_categorias` en el mismo acto
de registro. Pero durante el `signUp()` todavía no hay sesión, y la política RLS
de esa tabla exige `auth.uid() = profesional_id`. El insert fallaba siempre.

**Solución.** Las categorías viajan en el `data` del `signUp` y las inserta el
trigger `handle_new_user`, que corre como `security definer` y por lo tanto no
está sujeto a la RLS. Es la migración `0002`.
**Aprendizaje:** con RLS, todo lo que ocurre antes de que exista sesión tiene que
resolverse del lado del servidor.

### 4.3 El flujo de recuperación abría sesión y el router expulsaba al usuario

Validar el código de recuperación con `verifyOTP(type: recovery)` deja una sesión
abierta. El `redirect` del router, que mandaba al home a todo usuario con sesión,
sacaba al usuario de la pantalla de nueva contraseña justo antes de que pudiera
fijarla.

**Solución.** Clasificar las rutas en tres grupos en vez de dos: solo-sin-sesión,
solo-con-sesión y **neutrales**. Las cuatro rutas de verificación y recuperación
son neutrales: valen con sesión y sin ella.

### 4.4 `image_picker` no se comporta igual en Web que en móvil

En Web no hay cámara disponible por la vía habitual y las rutas de archivo del
sistema no existen, así que `File(archivo.path)` rompe. El CU-05 y el CU-09
suben imágenes desde las dos plataformas.

**Solución.** Un único camino: `readAsBytes()` + `uploadBinary()`. Funciona igual
en las dos y evita mantener dos ramas de código. Como consecuencia, se decidió
que los documentos del CU-09 se acepten solo como imagen: el DNI y la selfie son
fotos, y con eso el bucket recibe siempre `image/jpeg`.

### 4.5 La baja no borraba los archivos y dejaba el correo cautivo

Al revisar el CU-11 aparecieron dos problemas distintos en la misma función.

El primero es un defecto: la pantalla de baja le promete al usuario que se
elimina su foto de perfil, pero la RPC solo ponía `avatar_url = null`. **El
archivo seguía en el bucket `avatares`, que es público con lectura abierta**: la
cara de una persona dada de baja continuaba accesible para cualquiera con la URL,
y lo mismo pasaba con el DNI y la selfie. Faltaba además la política de `DELETE`
sobre `storage.objects`, así que ni siquiera había forma de borrarlos.

El segundo es de diseño: con la baja lógica, el correo quedaba tomado para
siempre y la persona no podía volver nunca.

**Solución.** Se descartó el borrado físico —`perfiles` es el ancla de las claves
foráneas de pedidos, calificaciones y pagos, y la cascada se habría llevado tanto
la auditoría de `bajas_cuenta` como el historial de la contraparte del pedido— y
se optó por **anonimizar y liberar la identidad**: la fila sobrevive sin datos
personales, los archivos se destruyen por la API de Storage con respaldo en SQL,
y el correo de `auth.users` se reescribe a una lápida `baja+{uuid}@laburito.invalid`.
Como el `id` no cambia, ninguna FK se entera, y la dirección original queda libre.

**Aprendizaje:** en un marketplace, «borrar mi cuenta» nunca es un `delete`. El
dato de una operación pertenece a las dos partes; lo que se elimina es la
identidad, no la historia.

---

## 5. Burndown

Backlog total del proyecto: **235 pts**. Al cerrar el Sprint 1 con 35 pts
ejecutados, el remanente pasa a **200 pts**.

### 5.1 Burndown del sprint (35 pts)

La línea planificada sigue el orden de bloques del apartado 1 del plan; la línea
real está reconstruida a partir del historial del repositorio.

| Fecha | Bloque planificado | Pts restantes (plan) | Pts restantes (real) |
|---|---|---|---|
| 06/08 | — inicio — | 35 | 35 |
| 09/08 | Bloque 0 · T-01, T-02 (13) | 22 | 35 |
| 13/08 | Bloque 1 · CU-01, CU-08, CU-03, CU-10, CU-50 (8) | 14 | 35 |
| 16/08 | Bloque 2 · CU-02, CU-09 (6) | 8 | 35 |
| 19/08 | Bloque 3 · CU-05, CU-11, CU-04 (8) | 0 | 0 |

> **Nota de honestidad metodológica.** Todos los commits del repositorio tienen
> fecha 19/08. La línea real de arriba refleja eso: el trabajo se consolidó al
> cierre en vez de distribuirse. Si el avance efectivo fue anterior a la carga en
> Git, hay que corregir la columna «real» con las fechas verdaderas antes de
> entregar — el burndown es un dato, no un adorno, y un pico al final es
> justamente el síntoma que el gráfico existe para mostrar.

**Lectura del gráfico.** El compromiso se cumplió al 100 %, pero la curva real no
acompañó a la planificada durante el sprint: se cerró todo contra la fecha. Para
el Sprint 2 la corrección es commitear al terminar cada caso de uso y no al
final del bloque, de modo que el burndown sea un instrumento de control y no un
informe a posteriori.

### 5.2 Burndown del proyecto

| Hito | Pts restantes |
|---|---|
| Inicio del proyecto | 235 |
| Cierre del Sprint 1 | 200 |

---

## 6. Checklist de entrega

- [x] Los 12 ítems del PT 2.0 implementados
- [x] `flutter analyze` sin issues y pruebas en verde
- [x] Migraciones versionadas en `supabase/migrations/`
- [x] `evidencia-sprint-01.txt` generado desde `git log`
- [x] Tag `v0.1.0`
- [x] `ESTADO.md` actualizado
- [ ] Video de demo del vertical de autenticación (7 circuitos de `ARRANQUE.md`)
- [ ] Captura del Schema Visualizer y de la tabla de políticas RLS
- [ ] Subida a BB antes de las 23:59
