import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/core/errors/mensajes_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Los errores de Supabase llegan en inglés: al usuario se le muestran
/// traducidos (CU-01, CU-03, CU-08).
void main() {
  test('email ya registrado', () {
    final mensaje = MensajesError.desde(
      const AuthException('User already registered'),
    );
    expect(mensaje, contains('Ya existe una cuenta'));
  });

  test('credenciales incorrectas', () {
    final mensaje = MensajesError.desde(
      const AuthException('Invalid login credentials'),
    );
    expect(mensaje, contains('correo o la contraseña'));
  });

  test('código vencido y código incorrecto dan mensajes distintos', () {
    final vencido = MensajesError.desde(
      const AuthException('Token has expired or is invalid'),
    );
    final incorrecto = MensajesError.desde(
      const AuthException('Invalid token'),
    );

    expect(vencido, contains('venció'));
    expect(incorrecto, contains('no es correcto'));
    expect(vencido, isNot(equals(incorrecto)));
  });

  test('cuenta suspendida o dada de baja conserva su mensaje propio', () {
    const excepcion = CuentaNoHabilitadaException(
      'Esta cuenta fue dada de baja y no puede volver a utilizarse.',
    );
    expect(MensajesError.desde(excepcion), excepcion.message);
  });

  test('los archivos que no se pudieron borrar explican por qué se frenó', () {
    const excepcion = ArchivosNoEliminadosException();
    final mensaje = MensajesError.desde(excepcion);

    expect(mensaje, excepcion.message);
    expect(mensaje, contains('frenamos la baja'));
  });

  test('un error desconocido no filtra detalles técnicos', () {
    final mensaje = MensajesError.desde(Exception('SocketException: failed'));
    expect(mensaje, 'Ocurrió un error inesperado. Intentá nuevamente.');
  });

  test('el mensaje de un raise de plpgsql llega al usuario (CU-11)', () {
    // Las RPC del proyecto levantan sus errores ya escritos en castellano.
    // Taparlos con el genérico dejaba al usuario sin saber qué pasó.
    final mensaje = MensajesError.desde(
      const PostgrestException(
        message: 'La cuenta ya se encuentra dada de baja',
        code: 'P0001',
      ),
    );
    expect(mensaje, 'La cuenta ya se encuentra dada de baja');
  });

  test('una función que falta se distingue de un error cualquiera', () {
    final falta = MensajesError.desde(
      const PostgrestException(
        message: 'Could not find the function public.dar_de_baja_cuenta',
        code: 'PGRST202',
      ),
    );
    final otro = MensajesError.desde(
      const PostgrestException(message: 'algo salió mal', code: '08006'),
    );

    expect(falta, contains('migración'));
    expect(otro, 'No pudimos completar la operación. Intentá nuevamente.');
  });
}
