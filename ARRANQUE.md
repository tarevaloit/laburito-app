# Arranque — Sprint 1 completo (35 pts)

El paquete trae los **12 ítems del PT 2.0 implementados**. El trabajo que queda es
levantar el entorno, configurar Supabase, probar cada circuito y documentarlo.

| Bloque | Qué queda hecho | Pts |
|---|---|---|
| A · Proyecto Flutter | T-01 | 5 |
| B · Supabase | T-02 | 8 |
| C · Identidad | CU-01, CU-08, CU-03, CU-10, CU-50 | 8 |
| D · Profesional | CU-02, CU-09 | 6 |
| E · Cuenta | CU-05, CU-11, CU-04 | 8 |
| F · Cierre | Evidencias, sección 7.1, tag | — |
| | **Total** | **35** |

---

## Bloque A — Proyecto Flutter

```bash
flutter create --org ar.com.laburito --platforms=web,android,ios laburito
cd laburito
```

Copiá encima `lib/`, `supabase/`, `docs/`, `.vscode/`, `pubspec.yaml` y `.gitignore`.

```bash
flutter pub get
git init && git add . && git commit -m "chore(T-01): setup Flutter + Riverpod + go_router"
```

**Permisos nativos** (necesarios para el `image_picker` del CU-05 y CU-09):

`android/app/src/main/AndroidManifest.xml` → dentro de `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

`ios/Runner/Info.plist` → dentro del `<dict>` principal:
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos la cámara para que puedas fotografiar tu documento.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceder a tus fotos para subir tu documentación y tu foto de perfil.</string>
```

> **Decisión:** sin `build_runner`, `freezed` ni codegen de Riverpod. Los providers
> están escritos a mano. Se puede migrar a codegen en el Sprint 2 sin tocar la UI.

---

## Bloque B — Supabase

1. Crear el proyecto → región **South America (São Paulo)**.
2. **SQL Editor** → ejecutar `supabase/migrations/0001_init.sql`.
3. **SQL Editor** → ejecutar `supabase/migrations/0002_sprint1_completo.sql`.
   Y después `supabase/migrations/0003_cu11_anonimizacion.sql`. En orden: la 0003
   reemplaza la función de baja que crea la 0002.
4. **Database → Tables**: confirmar las 6 tablas con RLS activo.
5. **Authentication → Providers → Email**: activar *Confirm email*.
6. ⚠️ **Authentication → Email Templates**. Los dos circuitos de PIN dependen de esto.

   **Confirm signup** (CU-08):
   ```html
   <h2>Bienvenido a Laburito</h2>
   <p>Tu código de verificación es:</p>
   <h1>{{ .Token }}</h1>
   <p>Vence en 60 minutos.</p>
   ```

   **Reset password** (CU-04):
   ```html
   <h2>Recuperá tu contraseña</h2>
   <p>Tu código para restablecerla es:</p>
   <h1>{{ .Token }}</h1>
   <p>Si no lo pediste vos, ignorá este correo.</p>
   ```

   Sin estos dos cambios Supabase manda un enlace y las pantallas de código no reciben nada.
7. **Storage**: confirmar los buckets `avatares`, `documentos` (privado) y `portafolios`.
8. **Settings → API**: copiar `Project URL` y la clave `anon public` al archivo `.env`.

   ```bash
   cp .env.example .env
   ```

   ```
   SUPABASE_URL=https://xxxxxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOi...
   ```

   `.env` está en el `.gitignore`: es el único lugar donde viven las claves y no
   se commitea. Las configuraciones de `.vscode/launch.json` ya lo leen con
   `--dart-define-from-file=.env`, así que en VS Code alcanza con F5.

```bash
git add supabase/ && git commit -m "feat(T-02): esquema inicial, RLS, buckets y seed de categorías"
```

---

## Bloques C, D y E — Guion de prueba

Corré la app (F5 en VS Code, o el comando de abajo) y seguí este orden. Es también
el guion del video de demostración.

```bash
flutter run -d chrome --dart-define-from-file=.env
```

Lo mismo vale para las compilaciones:

```bash
flutter build web --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
```

| # | Circuito | CU | Qué verificar |
|---|---|---|---|
| 1 | Registro de Buscador → PIN → home | CU-01, CU-08 | En Supabase, el perfil queda en `activo` |
| 2 | Logout → login | CU-10, CU-50, CU-03 | La sesión persiste al recargar el navegador |
| 3 | Editar perfil y cambiar foto | CU-05 | El avatar aparece en `avatares/{uid}/avatar.jpg` |
| 4 | Registro de Profesional (2 pasos) | CU-02 | Se crean las filas en `profesionales` y `profesional_categorias` |
| 5 | Subir los tres documentos | CU-09 | `estado_verificacion` pasa a `en_revision` |
| 6 | Olvidé mi contraseña → código → nueva | CU-04 | Se puede entrar con la contraseña nueva |
| 7 | Dar de baja (escribir BAJA) | CU-11 | En `perfiles` el nombre queda anonimizado y el correo con lápida; en Storage no queda ningún archivo de ese uuid |
| 8 | Registrarse de nuevo con el mismo correo | CU-11 | Deja registrarse y crea un perfil nuevo, con otro `id` |

Registrá el Profesional con un correo distinto al del Buscador, y dejá la baja
para el final. El correo sí se puede reutilizar —eso es justamente lo que valida
el circuito 8—, pero el historial de esa cuenta no vuelve.

**Aprobación manual** mientras el CU-35 no exista (Sprint 6):

```sql
update public.profesionales
   set estado_verificacion = 'aprobado'
 where perfil_id = 'PEGAR_UUID';
```

Commits, uno por caso de uso:

```bash
git commit -m "feat(CU-01): registro de buscador con validaciones"
git commit -m "feat(CU-08): verificación de email por PIN de 6 dígitos"
git commit -m "feat(CU-03): inicio de sesión con control de estado de cuenta"
git commit -m "feat(CU-10,CU-50): cierre de sesión y limpieza de estado"
git commit -m "feat(CU-02): alta de profesional con categorías de oficio"
git commit -m "feat(CU-09): carga de documentación al bucket privado"
git commit -m "feat(CU-05): gestión de perfil y avatar"
git commit -m "feat(CU-11): baja lógica de cuenta"
git commit -m "feat(CU-04): recuperación de contraseña por código"
```

---

## Bloque F — Cierre

```bash
git tag -a v0.1.0 -m "Sprint 1 — Fundaciones y Autenticación"
git log --oneline --since="2026-08-06" > docs/sprints/evidencia-sprint-01.txt
```

- [ ] Video con los 7 circuitos de la tabla de arriba
- [ ] Captura del Schema Visualizer y de la tabla de políticas RLS
- [ ] Sección 7.1 completada
- [ ] `docs/ESTADO.md` actualizado con los estados en ✅
- [ ] Subida a BB antes de las 23:59

### Sección 7.1 — qué escribir

Los cinco componentes que pide la Sección 2 del documento:

1. **Planificado** — la tabla de los 12 ítems con sus 35 puntos (apartado 4.1).
2. **Realizado** — los mismos ítems con su estado. Si cerraste los 35, el esfuerzo
   ejecutado son 35 puntos y el burndown baja de 235 a 200. Eso es un dato real.
3. **Faltantes y replanificación** — si no quedó nada afuera, se consigna así.
4. **Problemas encontrados** — los reales. Tenés varios que valen la pena y que
   además demuestran criterio técnico:
   - El OTP de Supabase manda un enlace por defecto; hubo que reescribir las
     plantillas de correo para que el CU-08 y el CU-04 funcionaran con PIN.
   - Las categorías del Profesional no se podían insertar durante el alta porque
     las políticas RLS exigen `auth.uid()` y en el `signUp` todavía no hay sesión;
     se resolvió pasándolas por el metadata y procesándolas en el trigger.
   - El flujo de recuperación abre sesión al validar el código, lo que hacía que
     el redirect del router expulsara al usuario al home antes de que pudiera
     fijar la contraseña nueva.
5. **Burndown real superpuesto al planificado.**

Escribí los que efectivamente te pasaron a vos. Un informe con problemas reales y
bien explicados vale más ante el docente que uno sin ningún tropiezo: el docente
ya sabe que integrar un backend nuevo en dos semanas no sale liso.
