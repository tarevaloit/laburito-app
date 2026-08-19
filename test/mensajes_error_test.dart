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

  test('un error desconocido no filtra detalles técnicos', () {
    final mensaje = MensajesError.desde(Exception('SocketException: failed'));
    expect(mensaje, 'Ocurrió un error inesperado. Intentá nuevamente.');
  });
}
