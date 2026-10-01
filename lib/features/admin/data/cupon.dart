import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/fechas.dart';

part 'cupon.freezed.dart';

enum EstadoCupon {
  activo('Activo'),
  vencido('Vencido'),
  agotado('Agotado'),
  inactivo('Inactivo');

  const EstadoCupon(this.etiqueta);

  final String etiqueta;
}

/// CU-52 — Un cupón como lo lista el panel (Figura 3.24): código, tokens que
/// regala, vencimiento, usos sobre el límite y estado.
@freezed
abstract class Cupon with _$Cupon {
  const Cupon._();

  const factory Cupon({
    required String id,
    required String codigo,
    required int tokens,
    required DateTime venceAt,
    required int usos,
    int? limiteUsos,
    @Default(true) bool activo,
  }) = _Cupon;

  /// Reglas para validar el formulario antes de mandarlo: las mismas del
  /// `check` de la tabla y de `crear_cupon` (migración 0024).
  static final RegExp formatoCodigo = RegExp(r'^[A-Z0-9]{4,20}$');
  static const int tokensMaximos = 1000;

  EstadoCupon estado([DateTime? ahora]) {
    if (!activo) return EstadoCupon.inactivo;
    if (!venceAt.isAfter(ahora ?? DateTime.now())) return EstadoCupon.vencido;
    if (limiteUsos != null && usos >= limiteUsos!) return EstadoCupon.agotado;
    return EstadoCupon.activo;
  }

  /// «142/500 usos», «88/∞ usos».
  String get usosLegible => '$usos/${limiteUsos ?? '∞'} usos';

  /// La base guarda el final del día elegido: la medianoche siguiente en hora
  /// de Argentina (UTC−3, sin horario de verano). Para mostrar el día que se
  /// eligió se pasa a esa hora y se resta un segundo, sin depender de la zona
  /// horaria del dispositivo.
  String get venceLegible => 'Vence ${Fechas.corta(
        venceAt.toUtc().subtract(const Duration(hours: 3, seconds: 1)),
      )}';

  factory Cupon.desdeFila(Map<String, dynamic> fila) => Cupon(
        id: fila['id'] as String,
        codigo: fila['codigo'] as String,
        tokens: (fila['tokens'] as num).toInt(),
        venceAt: DateTime.parse(fila['vence_at'] as String),
        usos: (fila['usos'] as num).toInt(),
        limiteUsos: (fila['limite_usos'] as num?)?.toInt(),
        activo: (fila['activo'] as bool?) ?? true,
      );
}
