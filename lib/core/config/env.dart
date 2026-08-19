/// Configuración por `--dart-define`. Nunca hardcodear claves en el repositorio.
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get esValido =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
