import 'package:freezed_annotation/freezed_annotation.dart';

part 'foto_portafolio.freezed.dart';

/// CU-06 — Una foto de trabajo del Profesional.
///
/// Espeja `public.profesional_portafolio` (migración 0012). `storagePath` es
/// la ruta dentro del bucket privado `portafolios`, con la forma
/// `{perfil_id}/{nombre}.jpg` que exigen el `check` de la tabla y las
/// políticas de Storage: no es una URL, para mostrarla hay que firmarla.
@freezed
abstract class FotoPortafolio with _$FotoPortafolio {
  const FotoPortafolio._();

  const factory FotoPortafolio({
    required String id,
    required String storagePath,
    required int orden,
    String? descripcion,
  }) = _FotoPortafolio;

  /// El tope que aplica el trigger `profesional_portafolio_limite`, que además
  /// bloquea la fila del Profesional antes de contar.
  static const int maximoPorProfesional = 10;

  factory FotoPortafolio.desdeFila(Map<String, dynamic> fila) => FotoPortafolio(
        id: fila['id'] as String,
        storagePath: fila['storage_path'] as String,
        orden: (fila['orden'] as num).toInt(),
        descripcion: fila['descripcion'] as String?,
      );
}
