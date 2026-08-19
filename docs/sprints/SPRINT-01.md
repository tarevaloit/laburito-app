# Sprint 1 — Fundaciones y Autenticación

**PT 2.0 · 06/08/2026 → 19/08/2026 · 35 pts · Release v0.1.0 · RF06**

> **Objetivo del sprint.** Dejar el entorno, el proyecto Supabase y el ciclo completo de
> identidad de usuarios operativos, de modo que todo sprint posterior construya
> funcionalidad de negocio sin volver sobre la infraestructura.

---

## 0. Alcance

Se ejecutan los **12 ítems completos del PT 2.0**: los 35 puntos planificados, sin
recortes. El orden de abajo no es el del backlog sino el de dependencias reales,
de modo que cada bloque deje algo verificable antes de pasar al siguiente.

El detalle operativo —comandos, configuración de Supabase y guion de prueba— está
en `ARRANQUE.md`, en la raíz del repositorio.

---

## 1. Orden de implementación

El orden respeta dependencias reales, no el orden del backlog. Cada bloque deja algo
verificable antes de pasar al siguiente.

| # | Bloque | Ítems | Pts | Por qué va acá |
|---|---|---|---|---|
| 0 | Fundaciones | T-01, T-02 | 13 | Nada compila ni persiste sin esto |
| 1 | Identidad mínima | CU-01, CU-08, CU-03, CU-10, CU-50 | 8 | Primer vertical end-to-end demoable |
| 2 | Alta del Profesional | CU-02, CU-09 | 6 | Necesita categorías (seed de T-02) y bucket privado |
| 3 | Gestión de cuenta | CU-05, CU-11, CU-04 | 8 | Se apoyan en el perfil ya creado |

La recuperación de contraseña va última porque es el circuito con más piezas
móviles: plantilla de correo, OTP de tipo `recovery` y una sesión que se abre a
mitad del flujo y obliga a tratar sus rutas aparte en el router.

---

## 2. Bloque 0 — Fundaciones (13 pts)

### T-01 · Setup del entorno (5 pts)

**Estructura de carpetas** (feature-first + capas, compatible con Riverpod):

```
laburito/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart              # MaterialApp.router
│   │   ├── router.dart           # go_router + redirect por sesión
│   │   └── theme.dart
│   ├── core/
│   │   ├── config/               # env, constantes, flavors
│   │   ├── errors/               # Failure, AppException
│   │   ├── providers/            # supabaseClientProvider, authStateProvider
│   │   ├── utils/                # validators, formatters
│   │   └── widgets/              # botones, inputs, loaders compartidos
│   └── features/
│       ├── auth/
│       │   ├── data/             # datasource Supabase + repository impl
│       │   ├── domain/           # entidades + contrato del repository
│       │   └── presentation/     # notifiers, screens, widgets
│       ├── perfil/
│       └── verificacion/
├── supabase/
│   ├── migrations/
│   └── seed.sql
├── docs/
│   ├── ESTADO.md
│   └── sprints/SPRINT-01.md
└── test/
```

**Dependencias (`pubspec.yaml`)**

```yaml
dependencies:
  supabase_flutter: ^2.5.0
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.0.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  image_picker: ^1.1.0
  file_picker: ^8.0.0
  intl: ^0.19.0

dev_dependencies:
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  custom_lint: ^0.6.0
  riverpod_lint: ^2.3.10
```

**Definición de terminado**
- [ ] `flutter run -d chrome` y `flutter run -d <device>` levantan la app sin errores
- [ ] Repo Git con `.gitignore` que excluye `.env`, `**/google-services.json`, `**/GoogleService-Info.plist`
- [ ] `ProviderScope` envolviendo la app y un provider de prueba consumido en pantalla
- [ ] Claves por `--dart-define` (no hardcodeadas): `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- [ ] `go_router` con rutas `/login`, `/registro`, `/home` y redirect según sesión

**Evidencia**: captura de la app corriendo en Chrome y en el emulador + link al primer commit.

---

### T-02 · Proyecto Supabase (8 pts)

Ver `0001_init.sql` — trae el esquema completo, los tipos, los triggers, las políticas
RLS, los buckets y el seed de categorías de oficio.

**Pasos**
1. Crear el proyecto en Supabase (región São Paulo por latencia).
2. Ejecutar `0001_init.sql` en el SQL Editor.
3. Auth → Providers → Email: activar **Confirm email** con OTP de 6 dígitos (esto resuelve el CU-08 sin tabla propia de PIN).
4. Auth → URL Configuration: agregar `http://localhost:*` y el dominio de deploy a las redirect URLs.
5. Verificar buckets: `avatares` (público), `documentos` (privado), `portafolios` (público).
6. Guardar el `.sql` versionado en el repo — es el respaldo del esquema que exige la mitigación del riesgo del plan gratuito.

**Definición de terminado**
- [ ] Las 6 tablas creadas con RLS **activado** en todas
- [ ] El trigger `handle_new_user` crea la fila en `perfiles` al registrarse
- [ ] Un usuario logueado no puede leer el perfil de otro (probado desde el SQL Editor con `set request.jwt.claims`)
- [ ] Categorías de oficio cargadas y consultables sin autenticar
- [ ] Migración commiteada en `supabase/migrations/`

**Evidencia**: diagrama del esquema (vista Database → Schema Visualizer de Supabase) + captura de la tabla de políticas.

---

## 3. Bloque 1 — Identidad mínima (8 pts)

### CU-01 · Registrar Buscador (2 pts)
Formulario: nombre, apellido, email, teléfono, contraseña. `signUp()` con
`data: {'tipo': 'buscador', 'nombre': ..., 'apellido': ...}` en el metadata → el trigger
arma el perfil. Estado inicial `pendiente_verificacion`.

- [ ] Validación de email, contraseña (mín. 8, una mayúscula, un número) y teléfono argentino
- [ ] Errores de Supabase traducidos al castellano (email duplicado, contraseña débil)
- [ ] Botón bloqueado mientras se envía, sin doble submit
- [ ] Al éxito, navega a la pantalla de PIN

### CU-08 · Validar Email de Buscador (PIN) (2 pts)
Pantalla de 6 casilleros → `verifyOTP(type: OtpType.email)`. Al validar, el estado del
perfil pasa a `activo`.

- [ ] Reenvío de PIN con contador de 60 s
- [ ] Mensaje distinto para PIN incorrecto vs. PIN vencido
- [ ] Sin PIN validado no se accede al home (guard en el router)

### CU-03 · Iniciar Sesión (2 pts)
`signInWithPassword()`. El router escucha `onAuthStateChange` y redirige.

- [ ] Sesión persistida entre reinicios
- [ ] Cuenta suspendida o dada de baja → mensaje específico y cierre de sesión inmediato
- [ ] Mostrar/ocultar contraseña

### CU-10 + CU-50 · Cerrar Sesión / Logout (2 pts)
Un solo `signOut()` que limpia estado de Riverpod (`ref.invalidate`) y redirige a `/login`.
Se implementan en conjunto, tal como declara la nota de trazabilidad del backlog.

- [ ] Confirmación antes de salir
- [ ] Ningún dato del usuario anterior sobrevive en memoria

**Evidencia del bloque**: video de 60 s — registro → PIN → home → logout → login.
Este video es lo que se muestra en la reunión del 20/08.

---

## 4. Bloque 2 — Alta del Profesional (6 pts)

### CU-02 · Registrar Profesional (3 pts)
Wizard de 3 pasos: datos personales → categorías de oficio (multi-select contra
`categorias_oficio`) → documentación. Crea fila en `perfiles` **y** en `profesionales`.

- [ ] Al menos una categoría obligatoria, máximo 5
- [ ] `estado_verificacion` queda en `en_revision`
- [ ] Si abandona el wizard, el alta queda incompleta pero recuperable al reingresar

### CU-09 · Validar Documentación — carga (3 pts)
Subida de DNI frente, DNI dorso y selfie al bucket privado `documentos`, ruta
`{profesional_id}/{tipo}.jpg`.

- [ ] Solo jpg/png/pdf, máximo 5 MB, con compresión antes de subir
- [ ] Reintento si falla la subida, sin duplicar el registro
- [ ] Pantalla de estado «Tu documentación está en revisión»
- [ ] El profesional ve solo sus documentos (validar RLS del bucket)

> **Nota para la Sección 2 del documento**: durante los Sprints 2 a 5 la aprobación se
> hace manualmente por SQL, porque el CU-35 recién está en el Sprint 6. Ya está
> anticipado en la tabla de observaciones del plan.

---

## 5. Bloque 3 — Gestión de cuenta (8 pts)

### CU-05 · Gestionar Perfil (3 pts)
Ver y editar nombre, apellido, teléfono, avatar y —si es Profesional— descripción y
categorías.

- [ ] Avatar al bucket `avatares` con recorte cuadrado
- [ ] Email no editable en este sprint (requiere reverificación)
- [ ] Optimistic update con rollback si falla

### CU-04 · Recuperar Contraseña (2 pts)
`resetPasswordForEmail()` + deep link a la pantalla de nueva contraseña.

- [ ] Mensaje neutro exista o no el email (no filtrar qué cuentas existen)
- [ ] Deep link configurado en web y en la app nativa
- [ ] Al cambiarla, se cierran las demás sesiones

### CU-11 · Dar de Baja Cuenta (3 pts)
Baja lógica: `estado = 'baja'`, `deleted_at = now()`, anonimización de teléfono, signOut.

- [ ] Doble confirmación escribiendo la palabra «BAJA»
- [ ] Un perfil dado de baja no aparece en ninguna consulta pública (filtro en las políticas RLS)
- [ ] Se explica qué pasa con los datos antes de confirmar

---

## 6. Checklist de entrega

- [ ] Tag `v0.1.0` en el repo
- [ ] `git log --oneline --since="2026-08-06"` exportado como evidencia
- [ ] Video de demo del vertical de autenticación
- [ ] Sección 7.1 del Sprint Planning completada
- [ ] `ESTADO.md` actualizado y commiteado
- [ ] Subida a BB antes de las 23:59

### Estructura de la Sección 7.1

Es un ítem de la Sección 2 del documento, con estos cinco componentes:

1. **Planificado** — la tabla de los 12 ítems con sus 35 puntos (copiada del apartado 4.1).
2. **Realizado** — mismos ítems con el esfuerzo real de los completados y el estado de cada uno.
3. **Faltantes y replanificación** — qué no entró, por qué, y a qué sprint se mueve. Sin adornos: la causa real.
4. **Problemas encontrados** — los que valga la pena documentar para no repetirlos.
5. **Burndown real superpuesto al planificado** — la línea de ejecución sobre las dos existentes.

---

## 7. Riesgos vivos de este sprint

| Riesgo | Señal temprana | Respuesta |
|---|---|---|
| RLS mal diseñada | Consultas que devuelven vacío sin error | Probar cada política desde el SQL Editor antes de cablear la UI |
| Plantillas de correo sin configurar | El PIN nunca llega y el CU-08 y el CU-04 quedan muertos | Reescribir *Confirm signup* y *Reset password* con `{{ .Token }}` antes de probar |
| `image_picker` en Flutter Web | La cámara no está disponible y las rutas de archivo no existen | Se usa `readAsBytes` + `uploadBinary`, que es el único camino común a Web y móvil |
| Redirect del router en el CU-04 | Validar el código abre sesión y el usuario cae en el home | Las rutas de recuperación están declaradas como neutrales, ni públicas ni privadas |
| Desvío acumulado | Bloque 3 sin arrancar al cierre | Replanificar explícitamente, no arrastrar en silencio |
