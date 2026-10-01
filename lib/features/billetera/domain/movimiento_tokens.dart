import 'package:freezed_annotation/freezed_annotation.dart';

part 'movimiento_tokens.freezed.dart';

/// Los tres orígenes de un movimiento: el enum `movimiento_tipo` de la 0021.
enum TipoMovimiento {
  compra,
  consumo,
  cupon;

  static TipoMovimiento desde(String valor) =>
      TipoMovimiento.values.firstWhere((t) => t.name == valor);
}

/// CU-30 — Un renglón del libro de tokens: cuánto entró o salió y el saldo que
/// dejó. Es lo que lista «Últimos movimientos» en la Figura 3.13.
@freezed
abstract class MovimientoTokens with _$MovimientoTokens {
  const MovimientoTokens._();

  const factory MovimientoTokens({
    required String id,
    required TipoMovimiento tipo,
    required int cantidad,
    required int saldoResultante,
    required String descripcion,
    required DateTime fecha,
  }) = _MovimientoTokens;

  bool get esIngreso => cantidad > 0;

  /// «+10», «−1». El signo menos es el tipográfico, no el guion.
  String get cantidadLegible => esIngreso ? '+$cantidad' : '−${-cantidad}';

  factory MovimientoTokens.desdeFila(Map<String, dynamic> fila) =>
      MovimientoTokens(
        id: fila['id'] as String,
        tipo: TipoMovimiento.desde(fila['tipo'] as String),
        cantidad: (fila['cantidad'] as num).toInt(),
        saldoResultante: (fila['saldo_resultante'] as num).toInt(),
        descripcion: fila['descripcion'] as String,
        fecha: DateTime.parse(fila['created_at'] as String),
      );
}
