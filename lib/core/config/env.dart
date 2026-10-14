import 'package:flutter/foundation.dart';

/// Configuración por `--dart-define`. Nunca hardcodear claves en el repositorio.
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Clave de Google Maps Platform (CU-16).
  ///
  /// **No entra en [esValido] a propósito.** Sin Supabase la app no tiene nada
  /// que mostrar; sin mapa sí: el selector de ubicación degrada a búsqueda de
  /// dirección y coordenada por defecto, y todo lo demás sigue funcionando.
  /// Bloquear el arranque por una clave que solo usa una pantalla sería peor
  /// que la falla que evita.
  ///
  /// En Android, además, el SDK nativo **no** lee este valor sino el
  /// `meta-data` del `AndroidManifest.xml`, que Gradle rellena desde
  /// `MAPS_API_KEY` (variable de entorno o `android/local.properties`). Son dos
  /// caminos distintos para la misma clave; el README explica los dos.
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  /// Raíz de la Web publicada (Sprint 5). Los enlaces que la app arma para
  /// mandar por WhatsApp —perfil público del CU-26, calificación del CU-28—
  /// apuntan acá, porque los abre el Buscador en el navegador del celular.
  ///
  /// En la Web, si no se configuró, se usa el origen de la propia página: así
  /// un enlace armado en `flutter run -d chrome` apunta al servidor local.
  static const String _webUrl = String.fromEnvironment('WEB_URL');

  static String get webUrl {
    final configurada = _webUrl.isNotEmpty
        ? _webUrl
        : (kIsWeb ? Uri.base.origin : _webUrlPorDefecto);
    return configurada.endsWith('/')
        ? configurada.substring(0, configurada.length - 1)
        : configurada;
  }

  /// El sitio de Firebase Hosting del proyecto (decisión del 13/10).
  static const String _webUrlPorDefecto = 'https://laburito.web.app';

  static bool get esValido =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
