import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// Los estados viajan como identificadores de la base. Mostrarlos crudos
/// —«sin_documentacion», «en_revision»— parece un error del sistema.
void main() {
  PerfilCompleto perfil({
    String estado = 'activo',
    String? verificacion,
  }) =>
      PerfilCompleto(
        id: 'id',
        tipo: verificacion == null ? 'buscador' : 'profesional',
        nombre: 'Marcelo',
        apellido: 'Gómez',
        email: 'marcelo.g@gmail.com',
        estado: estado,
        estadoVerificacion: verificacion,
      );

  // Los valores de los enums `estado_cuenta` y `estado_verificacion`
  // de supabase/migrations/0001_init.sql.
  const estadosDeCuenta = [
    'pendiente_verificacion',
    'activo',
    'suspendido',
    'baja',
  ];
  const estadosDeVerificacion = [
    'sin_documentacion',
    'en_revision',
    'aprobado',
    'rechazado',
  ];

  test('ningún estado de cuenta se muestra crudo', () {
    for (final estado in estadosDeCuenta) {
      final legible = perfil(estado: estado).estadoLegible;
      expect(legible, isNot(contains('_')),
          reason: '«$estado» no tiene texto legible');
    }
  });

  test('ningún estado de verificación se muestra crudo', () {
    for (final estado in estadosDeVerificacion) {
      final legible = perfil(verificacion: estado).verificacionLegible;
      expect(legible, isNot(contains('_')),
          reason: '«$estado» no tiene texto legible');
    }
  });

  test('el Buscador no tiene estado de verificación que mostrar', () {
    expect(perfil().verificacionLegible, isNull);
  });

  test('los estados que importan dicen qué hacer', () {
    expect(perfil(verificacion: 'sin_documentacion').verificacionLegible,
        'Falta subir la documentación');
    expect(perfil(verificacion: 'en_revision').verificacionLegible,
        'En revisión');
    expect(perfil(estado: 'pendiente_verificacion').estadoLegible,
        'Falta validar tu correo');
  });
}
