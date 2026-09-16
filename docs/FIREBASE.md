# Firebase / FCM — puesta en marcha del CU-21

> Lo único que falta para que la alerta del CU-21 llegue a un teléfono. Todo lo
> demás está hecho: el emparejamiento (migración 0016), el registro del
> dispositivo (0017), la Edge Function `emparejar_pedido` desplegada y el
> disparo desde el alta del pedido.
>
> **Tiempo estimado: 20 minutos** para Android. iOS necesita una cuenta paga de
> Apple y va aparte, al final.

---

## Antes de empezar

| Qué | Dónde estamos |
|---|---|
| Cuenta de Google | La que ya usás para Google Maps Platform |
| Firebase CLI | Instalado (`firebase --version` → 14.9.0) |
| `flutterfire` | **Falta**: se instala en el paso 2 |
| Apple Developer | No hace falta para Android. Ver la sección de iOS |
| Emulador o teléfono | Tiene que tener **Google Play Services**: en el emulador, una imagen «Play Store», no una «AOSP». FCM no existe sin eso |

Datos del proyecto que vas a necesitar copiar y pegar:

- **ID de aplicación (Android e iOS):** `ar.com.laburito.laburito`
- **Proyecto de Supabase:** `xbgwogitgzzxmoixqfjd`

Ninguno de los archivos que vas a bajar se commitea: `google-services.json`,
`GoogleService-Info.plist` y `firebase_options.dart` ya están en el
`.gitignore` desde el T-01.

---

## Paso 1 — Crear el proyecto en Firebase

1. Entrá a <https://console.firebase.google.com> con tu cuenta de Google.
2. **Crear un proyecto**. Si querés que Firebase y la clave de Maps vivan en el
   mismo lugar, elegí en el buscador el proyecto de Google Cloud que ya usás
   para Maps en vez de crear uno nuevo; si no, un proyecto nuevo llamado
   `laburito` está bien.
3. **Google Analytics: desactivalo.** No lo usamos y agrega pasos de
   configuración que después hay que mantener.
4. Cuando termine, anotá el **ID del proyecto** (aparece en
   *Configuración del proyecto*; no es el nombre, es el identificador con
   guiones).

> No hace falta tocar nada más en la consola todavía. El paso 2 registra las
> apps solo.

---

## Paso 2 — Registrar la app con `flutterfire`

Se hace desde la terminal y evita registrar las apps a mano en la consola.

```bash
dart pub global activate flutterfire_cli
```

Si la terminal no encuentra `flutterfire` después de instalarlo, agregá
`~/.pub-cache/bin` al `PATH`.

```bash
firebase login
```

Y ahora, **parado en la raíz del repo**:

```bash
cd ~/Documents/laburito && flutterfire configure
```

Elegí, cuando pregunte:

- el proyecto que creaste en el paso 1;
- las plataformas: **android** (y **web** si querés probarlo también en el
  navegador; iOS dejalo para la sección de más abajo);
- el identificador cuando lo pida: `ar.com.laburito.laburito`.

Al terminar deja `lib/firebase_options.dart` y baja los archivos de
configuración. **Los tres están gitignoreados**: no los vas a ver en
`git status`, y está bien.

---

## Paso 3 — La clave de la cuenta de servicio

Es lo que la Edge Function usa para pedirle a Google permiso de enviar. Es la
única credencial verdaderamente secreta de todo esto.

1. Consola de Firebase → engranaje → **Configuración del proyecto**.
2. Solapa **Cuentas de servicio**.
3. **Generar nueva clave privada** → *Generar clave*. Se descarga un `.json`.
4. **Dejalo en `~/Downloads`. No lo muevas adentro del repo**, ni siquiera un
   minuto: el `.gitignore` no lo cubre por nombre.

---

## Paso 4 — Cargar la clave en Supabase

Estos tres nombres son exactamente los que busca la Edge Function
(`supabase/functions/emparejar_pedido/index.ts`).

El comando de abajo lee el `.json` descargado y arma el archivo de secretos sin
que tengas que copiar y pegar la clave privada a mano —que es larga y se corta
fácil—. **Cambiá el nombre del archivo** por el que bajaste:

```bash
cd ~/Documents/laburito && python3 - <<'PY' > /tmp/fcm.env
import json, glob, os
ruta = sorted(glob.glob(os.path.expanduser('~/Downloads/*firebase-adminsdk*.json')))[-1]
d = json.load(open(ruta))
print('FCM_PROJECT_ID=' + d['project_id'])
print('FCM_CLIENT_EMAIL=' + d['client_email'])
print('FCM_PRIVATE_KEY=' + d['private_key'].replace('\n', '\\n'))
print('Leído de:', ruta, file=__import__('sys').stderr)
PY
```

Revisá que el archivo tenga las tres líneas (la tercera va a ser larguísima):

```bash
cut -c1-40 /tmp/fcm.env
```

Cargalos y borrá el temporal:

```bash
cd ~/Documents/laburito && supabase secrets set --env-file /tmp/fcm.env && rm /tmp/fcm.env
```

Comprobá que quedaron los tres:

```bash
cd ~/Documents/laburito && supabase secrets list
```

> La clave privada viaja con los saltos de línea escapados como `\n`. La Edge
> Function los repone antes de firmar (`pemADer` en `index.ts`), así que está
> previsto.

---

## Paso 5 — Avisame

Con los pasos 1 a 4 hechos, el lado de servidor queda completo. Falta el lado
de la app, que es **una clase y dos líneas de configuración**, y lo hago yo:

- `firebase_core` y `firebase_messaging` en el `pubspec.yaml`;
- la implementación de `ServicioPush` que hoy es `PushNoConfigurado`
  (`lib/features/notificaciones/data/servicio_push.dart`) — la interfaz ya está
  escrita justamente para esto: pedir permiso, devolver el token, avisar cuando
  FCM lo rota y emitir el id del pedido cuando se toca la notificación;
- el permiso `POST_NOTIFICATIONS` del manifiesto, que Android 13+ exige;
- el canal de notificaciones de Android y el manejo de mensajes en segundo
  plano.

Nada de eso toca el resto del proyecto: el registro del dispositivo, la baja
del token al cerrar sesión y la navegación al detalle ya están escritos y
probados contra la interfaz.

---

## Paso 6 — La prueba de que funciona

En orden, y cada paso se puede verificar solo:

1. **El teléfono se registra.** Entrá a la app con el Profesional y aceptá el
   permiso de notificaciones. En el SQL Editor:

   ```sql
   select profesional_id, plataforma, updated_at
     from public.profesional_dispositivos;
   ```

   Tiene que haber una fila. Si no la hay, el token no llegó: revisá que el
   emulador tenga Play Store y que hayas aceptado el permiso.

2. **El servidor lo elige.** Con el id de un pedido publicado y vigente:

   ```sql
   select * from public.profesionales_para_pedido('<id del pedido>');
   ```

   Tiene que devolver al Profesional **con su token** en la columna `tokens`.
   Si devuelve cero filas, mirá el interruptor «Estoy disponible» en la app:
   desde la migración 0019 un Profesional no disponible no recibe alertas.

3. **Llega la notificación.** Publicá un pedido nuevo desde la web con el
   Buscador, en una categoría que el Profesional tenga cargada y dentro de su
   zona. El teléfono tiene que sonar, y al tocar la notificación abrirse el
   detalle del pedido.

4. **Si no suena**, mirá los logs de la función en
   *Supabase → Functions → emparejar_pedido → Logs*. La respuesta dice
   exactamente en qué punto se cortó:

   | Respuesta | Qué significa |
   |---|---|
   | `profesionales: 0` | Nadie coincide: zona, oficio, verificación o disponibilidad |
   | `dispositivos: 0` | Coincide pero no tiene teléfono registrado (paso 1) |
   | `enviadas: 0` con `detalle: Faltan las credenciales…` | Los secretos del paso 4 no están cargados |
   | `fallidas > 0` | Google rechazó el envío; el detalle está en el log |

---

## iOS (opcional, y va aparte)

Las notificaciones en iOS **necesitan una cuenta del Apple Developer Program**
(US$ 99 al año), que es una de las mitigaciones que el plan del sprint ya tenía
anotadas como pendientes. Sin esa cuenta no hay clave APNs y no hay push en
iOS, por más que el resto esté.

Cuando exista:

1. En <https://developer.apple.com> → *Certificates, Identifiers & Profiles* →
   **Keys** → crear una clave con **Apple Push Notifications service (APNs)**
   habilitado. Se descarga un `.p8` **una sola vez**.
2. Consola de Firebase → *Configuración del proyecto* → **Cloud Messaging** →
   sección de iOS → subir el `.p8` con su **Key ID** y tu **Team ID**.
3. `flutterfire configure` otra vez, agregando la plataforma ios.
4. En Xcode, en el target Runner, agregar las capacidades **Push Notifications**
   y **Background Modes → Remote notifications**.

El resto —el registro del token, el emparejamiento, el envío— es el mismo
código: la Edge Function ya manda el bloque `apns` en cada mensaje.

---

## Lo que NO hay que hacer

- **No commitees** `google-services.json`, el `.p8`, ni el `.json` de la cuenta
  de servicio. Los tres primeros ya están en el `.gitignore`; el último ni
  siquiera tiene que entrar al repo.
- **No pongas la clave privada en el `.env`.** El `.env` es del cliente: todo
  lo que está ahí termina en el bundle de la app. La clave de la cuenta de
  servicio vive solo en los secretos de Supabase, que son del servidor.
- **No habilites la API Legacy de FCM.** La Edge Function usa HTTP v1, que es
  la vigente; la legacy está dada de baja desde 2024.
