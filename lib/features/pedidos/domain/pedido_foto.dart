import 'package:freezed_annotation/freezed_annotation.dart';

part 'pedido_foto.freezed.dart';

/// Una imagen del pedido. Espeja `public.pedido_fotos` (migración 0005).
///
/// `storagePath` es la ruta dentro del bucket privado `pedidos`, con la forma
/// `{pedido_id}/{nombre}.jpg` que exigen las políticas de Storage de la 0006.
/// No es una URL: para mostrarla hay que pedir una firmada.
@freezed
abstract class PedidoFoto with _$PedidoFoto {
  const PedidoFoto._();

  const factory PedidoFoto({
    required String id,
    required String pedidoId,
    required String storagePath,

    /// Posición en la galería, 0 = portada. Único por pedido.
    required int orden,
    required DateTime createdAt,
  }) = _PedidoFoto;

  /// Tope que impone el trigger `pedido_fotos_limite`.
  static const int maximoPorPedido = 5;

  factory PedidoFoto.desdeFila(Map<String, dynamic> fila) => PedidoFoto(
        id: fila['id'] as String,
        pedidoId: fila['pedido_id'] as String,
        storagePath: fila['storage_path'] as String,
        orden: (fila['orden'] as num).toInt(),
        createdAt: DateTime.parse(fila['created_at'] as String).toLocal(),
      );

  bool get esPortada => orden == 0;
}
