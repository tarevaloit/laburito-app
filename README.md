# Laburito

Plataforma geolocalizada que conecta **Buscadores** con **Profesionales** de oficios.

Seminario de Integración Profesional 2026 · Comisión P03 · Release actual: `v0.1.0`

- Estado del proyecto: [`docs/ESTADO.md`](docs/ESTADO.md)
- Plan del sprint en curso: [`docs/sprints/`](docs/sprints/)
- Puesta en marcha paso a paso: [`ARRANQUE.md`](ARRANQUE.md)

## Stack

Flutter (Web + Android + iOS) · Supabase (Auth, PostgreSQL con RLS, Storage) ·
Riverpod · go_router.

## Cómo correrlo

Las claves de Supabase **no viven en el código**: entran por `--dart-define`
desde un archivo `.env` que no se commitea.

```bash
flutter pub get
cp .env.example .env      # completá SUPABASE_URL y SUPABASE_ANON_KEY
flutter run -d chrome --dart-define-from-file=.env
```

En VS Code alcanza con **F5**: las configuraciones de `.vscode/launch.json` ya
leen el `.env`.

Si faltan las claves, la app arranca igual y muestra en pantalla qué falta
completar, en vez de romper con una excepción.

### Clave de Google Maps (CU-16)

La clave viaja por **dos caminos distintos**, porque el SDK nativo de Android
no lee `--dart-define`: lee un `meta-data` del manifiesto.

- **Dart y Web** — va en el mismo `.env` que Supabase, como
  `GOOGLE_MAPS_API_KEY`. La lee `Env.googleMapsApiKey` y la inyecta
  `sdk_mapas_web.dart` en tiempo de ejecución (no está escrita en
  `web/index.html`: ver el comentario ahí).
- **Android nativo** — la lee `android/app/build.gradle.kts` de la variable
  de entorno `MAPS_API_KEY` o, si no está, de `MAPS_API_KEY=...` en
  `android/local.properties` (archivo del `.gitignore`, no del repo), y la
  vuelca al `AndroidManifest.xml` como `manifestPlaceholders`.

Sin la clave el mapa no se dibuja, pero el resto de la app funciona igual
(`Env.googleMapsApiKey` no entra en `Env.esValido`).

## Base de datos

El esquema está versionado en [`supabase/migrations/`](supabase/migrations/) y se
ejecuta en orden desde el SQL Editor de Supabase. Antes de probar el registro hay
que reescribir las plantillas de correo *Confirm signup* y *Reset password* para
que envíen `{{ .Token }}`; el detalle está en [`ARRANQUE.md`](ARRANQUE.md).

## Verificación

```bash
flutter analyze
flutter test
```

## Convención de commits

`<tipo>(<ID>): <descripción en infinitivo>` — por ejemplo
`feat(CU-01): registrar buscador con validación de email`.
Con esto, `git log --oneline --since="<inicio del sprint>"` es la evidencia
automática de lo ejecutado.
