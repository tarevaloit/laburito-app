import 'package:supabase_flutter/supabase_flutter.dart';

/// Traduce los errores de Supabase a mensajes que el usuario pueda entender.
class MensajesError {
  const MensajesError._();

  static String desde(Object error) {
    if (error is CuentaNoHabilitadaException) return error.message;

    if (error is AuthException) {
      final m = error.message.toLowerCase();

      if (m.contains('already registered') || m.contains('already been registered')) {
        return 'Ya existe una cuenta con ese correo electrónico.';
      }
      if (m.contains('invalid login credentials')) {
        return 'El correo o la contraseña son incorrectos.';
      }
      if (m.contains('email not confirmed')) {
        return 'Todavía no validaste tu correo. Revisá tu casilla.';
      }
      if (m.contains('token has expired') || m.contains('expired')) {
        return 'El código venció. Pedí uno nuevo.';
      }
      if (m.contains('invalid token') || m.contains('otp')) {
        return 'El código no es correcto. Revisalo e intentá de nuevo.';
      }
      if (m.contains('password should be')) {
        return 'La contraseña es demasiado débil.';
      }
      if (m.contains('rate limit') || m.contains('too many')) {
        return 'Demasiados intentos. Esperá unos minutos.';
      }
      return error.message;
    }

    if (error is PostgrestException) {
      return 'No pudimos completar la operación. Intentá nuevamente.';
    }

    return 'Ocurrió un error inesperado. Intentá nuevamente.';
  }
}

/// La cuenta existe pero está suspendida o dada de baja (CU-03).
class CuentaNoHabilitadaException implements Exception {
  const CuentaNoHabilitadaException(this.message);
  final String message;

  @override
  String toString() => message;
}
