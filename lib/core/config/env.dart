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

  static bool get esValido =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
