import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Espera máxima por el `<script>` de Maps. Pasado ese tiempo se sigue sin
/// mapa: el selector degrada a búsqueda de dirección y el usuario no queda
/// mirando una pantalla en blanco.
const Duration _espera = Duration(seconds: 15);

/// Se recuerda el resultado para no inyectar el script dos veces si el usuario
/// abre el selector, vuelve y lo abre de nuevo.
Future<bool>? _carga;

/// Inyecta `https://maps.googleapis.com/maps/api/js` con la clave que llegó por
/// `--dart-define` y devuelve si el SDK quedó disponible.
///
/// `libraries=marker` es lo que pide `google_maps_flutter_web` para los
/// marcadores avanzados; `language` y `region` hacen que los rótulos del mapa
/// y el sesgo de las búsquedas sean argentinos.
Future<bool> cargarSdkDeMapas(String apiKey) {
  if (apiKey.isEmpty) return Future.value(false);
  if (_yaEstaCargado) return Future.value(true);
  return _carga ??= _inyectar(apiKey);
}

/// El script define `window.google.maps`. Preguntar por `google` alcanza:
/// nadie más en la página lo define.
bool get _yaEstaCargado => web.window.hasProperty('google'.toJS).toDart;

Future<bool> _inyectar(String apiKey) {
  final url = Uri.https('maps.googleapis.com', '/maps/api/js', {
    'key': apiKey,
    'libraries': 'marker',
    'language': 'es',
    'region': 'AR',
  });

  final listo = Completer<bool>();

  void terminar(bool exito) {
    if (!listo.isCompleted) listo.complete(exito);
  }

  final script = web.document.createElement('script') as web.HTMLScriptElement
    ..type = 'text/javascript'
    ..async = true
    ..src = url.toString();

  // Por `addEventListener` y no por `script.onload = ...`: los setters de
  // `package:web` para los manejadores de error tienen tipos propios y esto
  // es el mismo mecanismo con una sola forma para los dos eventos.
  script.addEventListener('load', ((web.Event _) => terminar(true)).toJS);
  script.addEventListener('error', ((web.Event _) => terminar(false)).toJS);

  web.document.head!.appendChild(script);

  // Si el script queda colgado —red caída, dominio bloqueado— no se espera
  // para siempre. `_carga` se limpia para que un reintento posterior vuelva a
  // probar en vez de devolver el `false` cacheado.
  return listo.future.timeout(_espera, onTimeout: () => false).then((exito) {
    if (!exito) _carga = null;
    return exito;
  });
}
