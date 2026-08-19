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
