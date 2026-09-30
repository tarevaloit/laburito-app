import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/dinero.dart';

part 'paquete_tokens.freezed.dart';

/// CU-31 / CU-40 — Un pack de tokens a la venta (Figura 3.13).
///
/// El precio que se muestra es informativo: el que cobra Mercado Pago lo lee
/// la Edge Function de la base al crear la preferencia (migración 0022). La
/// app manda solo el [id].
@freezed
abstract class PaqueteTokens with _$PaqueteTokens {
  const PaqueteTokens._();

  const factory PaqueteTokens({
    required String id,
    required String nombre,
    required int cantidad,
    required int precioArs,
    @Default(true) bool activo,
    @Default(0) int orden,
  }) = _PaqueteTokens;

  String get precioLegible => Dinero.pesos(precioArs);

  double get precioPorToken => precioArs / cantidad;

  /// Cuánto más barato sale cada token que en [referencia] (el pack más
  /// chico), en por ciento entero. `null` si no hay ahorro. Es la etiqueta
  /// «-30 %» de la Figura 3.13, calculada y no escrita a mano: si el admin
  /// cambia un precio (CU-40), la etiqueta dice la verdad.
  int? ahorroRespectoDe(PaqueteTokens referencia) {
    if (referencia.id == id) return null;
    final ahorro = 1 - precioPorToken / referencia.precioPorToken;
    final porciento = (ahorro * 100).round();
    return porciento > 0 ? porciento : null;
  }

  factory PaqueteTokens.desdeFila(Map<String, dynamic> fila) => PaqueteTokens(
        id: fila['id'] as String,
        nombre: fila['nombre'] as String,
        cantidad: (fila['cantidad'] as num).toInt(),
        precioArs: (fila['precio_ars'] as num).toInt(),
        activo: (fila['activo'] as bool?) ?? true,
        orden: (fila['orden'] as num?)?.toInt() ?? 0,
      );
}
