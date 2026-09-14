import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Traduce los errores de Supabase a mensajes que el usuario pueda entender.
class MensajesError {
  const MensajesError._();

  static String desde(Object error) {
    if (error is ErrorDeNegocio) return error.message;

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
      _registrar(error);

      switch (error.code) {
        // `raise exception` de plpgsql. Las funciones del proyecto levantan
        // estos mensajes ya escritos en castellano y para el usuario —
        // «La cuenta ya se encuentra dada de baja»—, así que se muestran tal
        // cual en vez de taparlos con un genérico.
        case 'P0001':
          return error.message;

        // La función no está en el esquema: falta correr una migración.
        case 'PGRST202':
          return 'Esta operación todavía no está disponible en el servidor. '
              'Avisale al equipo: falta aplicar una migración.';

        // Permisos insuficientes del lado de la base.
        case '42501':
          return 'El servidor rechazó la operación por permisos. '
              'Avisale al equipo.';

        case '23505':
          return 'Ese dato ya está registrado.';

        // foreign_key_violation. Del lado del usuario esto nunca es un error
        // que pueda corregir: significa que una fila que la operación da por
        // existente no está. El caso conocido es un Profesional sin fila en
        // `profesionales` al subir su documentación (CU-09), que repara la
        // migración 0011.
        case '23503':
          return 'A tu cuenta le falta un dato para completar esta operación. '
              'Avisale al equipo: hay que revisar tu perfil.';
      }

      return 'No pudimos completar la operación. Intentá nuevamente.';
    }

    _registrar(error);
    return 'Ocurrió un error inesperado. Intentá nuevamente.';
  }

  /// Deja el error completo en la consola durante el desarrollo.
  ///
  /// Sin esto, un fallo de la base llega al usuario como «No pudimos completar
  /// la operación» y **también** al programador, sin código ni detalle: no hay
  /// por dónde empezar a mirar. En release no imprime nada.
  static void _registrar(Object error) {
    if (kReleaseMode) return;

    if (error is PostgrestException) {
      debugPrint(
        'PostgrestException · code=${error.code} · message=${error.message} '
        '· details=${error.details} · hint=${error.hint}',
      );
      return;
    }

    debugPrint('${error.runtimeType} · $error');
  }
}

/// Error cuyo mensaje ya está escrito para el usuario y se muestra tal cual.
/// Es lo contrario de un error de infraestructura, que se traduce.
abstract class ErrorDeNegocio implements Exception {
  String get message;
}

/// La cuenta existe pero está suspendida o dada de baja (CU-03).
class CuentaNoHabilitadaException implements ErrorDeNegocio {
  const CuentaNoHabilitadaException(this.message);

  @override
  final String message;

  @override
  String toString() => message;
}

/// No se pudieron destruir los archivos del usuario, así que la baja se
/// interrumpe antes de anonimizar (CU-11).
class ArchivosNoEliminadosException implements ErrorDeNegocio {
  const ArchivosNoEliminadosException([
    this.message =
        'No pudimos eliminar tus archivos, así que frenamos la baja para no '
            'dejarlos sin dueño. Probá de nuevo en un momento.',
  ]);

  @override
  final String message;

  @override
  String toString() => message;
}
