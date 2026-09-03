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

#### Cómo se saca, una sola vez

1. **Proyecto en Google Cloud.** Entrá a
   [console.cloud.google.com](https://console.cloud.google.com) con una cuenta
   de Google y creá un proyecto (arriba a la izquierda, el selector de
   proyectos → *Proyecto nuevo*). Nombre sugerido: `laburito`.
2. **Habilitá la facturación.** Google Maps Platform **exige** una tarjeta,
   aunque no cobre: hay un crédito mensual gratuito que un proyecto académico
   no llega a consumir ni de cerca. *Facturación → Vincular cuenta de
   facturación*. Sin esto las APIs responden `REQUEST_DENIED` y el mapa sale
   gris.
3. **Habilitá las cinco APIs**, en *APIs y servicios → Biblioteca*, buscando
   cada una por nombre y tocando **Habilitar**:

   | API | Para qué |
   |---|---|
   | Maps JavaScript API | Que se dibuje el mapa en la web |
   | Maps SDK for Android | Que se dibuje el mapa en el APK |
   | Maps SDK for iOS | Que se dibuje el mapa en iOS |
   | **Places API (New)** | El autocompletado de direcciones. Ojo: es la
     «(New)», no la clásica — ver la decisión del 02/09 en `docs/ESTADO.md` |
   | Geocoding API | La dirección que aparece sola al mover el pin |

4. **Creá la clave.** *APIs y servicios → Credenciales → Crear credenciales →
   Clave de API*. Copiala: es un texto que empieza con `AIza...`.
5. **Restringila por API, no por aplicación.** Tocá la clave recién creada y,
   en *Restricciones de API*, elegí *Restringir clave* y marcá las cinco de
   arriba. En *Restricciones de aplicación* dejá **Ninguna**.

   > **Por qué ninguna, aunque suene mal.** Las restricciones por app —huella
   > SHA-1 en Android, bundle id en iOS— valen para los SDK nativos, pero
   > `ServicioDirecciones` llama a Places y Geocoding **por HTTP desde Dart**,
   > y para Google eso es un *web service*, que solo admite restricción por IP.
   > Una clave restringida a la app Android haría fallar el autocompletado con
   > un 403. Para producción son dos claves, una por tipo de uso; para el
   > entorno académico es una sola, restringida por API. Lo que la protege es
   > que no está en el repositorio.

6. Opcional pero recomendado: *Facturación → Presupuestos y alertas*, con una
   alerta en algunos dólares. Es la red que avisa si algo se dispara.

#### Dónde se guarda

La clave viaja por **tres caminos distintos**, porque ningún SDK nativo lee
`--dart-define`: cada uno la busca en su propio lugar. Es **la misma clave** en
los tres archivos, y los tres están en el `.gitignore`.

- **Dart y Web** — va en el mismo `.env` que Supabase, como
  `GOOGLE_MAPS_API_KEY`. La lee `Env.googleMapsApiKey` y la inyecta
  `sdk_mapas_web.dart` en tiempo de ejecución (no está escrita en
  `web/index.html`: ver el comentario ahí).
- **Android nativo** — la lee `android/app/build.gradle.kts` de la variable
  de entorno `MAPS_API_KEY` o, si no está, de `MAPS_API_KEY=...` en
  `android/local.properties` (archivo del `.gitignore`, no del repo), y la
  vuelca al `AndroidManifest.xml` como `manifestPlaceholders`.
- **iOS nativo** — copiá `ios/Flutter/Maps.xcconfig.example` a
  `ios/Flutter/Maps.xcconfig` (también del `.gitignore`) y completá
  `MAPS_API_KEY=`. De ahí la toma la clave `GMSApiKey` del `Info.plist` y
  `AppDelegate.swift` se la pasa a `GMSServices.provideAPIKey`.

En concreto, los tres archivos:

```bash
# 1. Dart y Web (y el autocompletado y la geocodificación en TODAS las
#    plataformas, porque salen por HTTP desde Dart). Si no existe: cp .env.example .env
echo 'GOOGLE_MAPS_API_KEY=AIza...' >> .env

# 2. Android nativo
echo 'MAPS_API_KEY=AIza...' >> android/local.properties

# 3. iOS nativo
cp ios/Flutter/Maps.xcconfig.example ios/Flutter/Maps.xcconfig
# y editá la última línea: MAPS_API_KEY=AIza...
```

Sin comillas y sin espacios alrededor del `=`, en los tres.

**Después de tocar `local.properties` o `Maps.xcconfig` hay que reconstruir**,
no alcanza con un *hot restart*: esos dos valores los lee el build nativo, no
Dart.

Para comprobar que quedó bien: `flutter run -d chrome
--dart-define-from-file=.env`, entrá a *Publicar un pedido* y llegá al paso
**Dónde**. Si el mapa se dibuja y al escribir una calle aparecen sugerencias,
están andando las tres APIs. Si en cambio ves «No pudimos cargar el mapa,
escribí la dirección a mano», falta la clave o falta habilitar una API.

Sin la clave el mapa no se dibuja, pero el resto de la app funciona igual
(`Env.googleMapsApiKey` no entra en `Env.esValido`, y en iOS el `AppDelegate`
directamente no inicializa el SDK en vez de abortar con una clave vacía).

### iOS

El piso es **iOS 14**, que es lo que pide `google_maps_flutter_ios`. Después de
un `flutter pub get` que agregue plugins nuevos hay que rearmar los pods:

```bash
cd ios && pod install --repo-update && cd ..
```

Sin eso, `flutter run -d ios` falla con «required a higher minimum deployment
target» o con símbolos que no encuentra.

## Base de datos

El esquema está versionado en [`supabase/migrations/`](supabase/migrations/) y se
ejecuta en orden desde el SQL Editor de Supabase. Antes de probar el registro hay
que reescribir las plantillas de correo *Confirm signup* y *Reset password* para
que envíen `{{ .Token }}`; el detalle está en [`ARRANQUE.md`](ARRANQUE.md).

## Verificación

```bash
flutter analyze
flutter test

# Las trampas que solo existen en la web, en un navegador de verdad:
flutter test --platform chrome test/identificadores_test.dart
```

Ese último no es opcional por capricho. En la web los `int` de Dart son los
números de JavaScript, y hay código que funciona en la VM —donde corre
`flutter test`— y falla en el navegador. Ya pasó dos veces: `1 << 32` vale 0 en
la web e hizo que ninguna foto se pudiera subir, y el `toString()` de un double
entero imprime «200000.0» en la VM y «200000» en la web.

## Convención de commits

`<tipo>(<ID>): <descripción en infinitivo>` — por ejemplo
`feat(CU-01): registrar buscador con validación de email`.
Con esto, `git log --oneline --since="<inicio del sprint>"` es la evidencia
automática de lo ejecutado.
