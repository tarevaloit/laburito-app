import 'package:freezed_annotation/freezed_annotation.dart';

import 'pedido_estado.dart';

part 'pedido_evento.freezed.dart';

/// Un cambio de estado del pedido. Espeja `public.pedido_eventos`.
///
/// Estas filas las escribe el trigger `pedidos_registrar_evento`, nunca la
/// aplicación: no hay política de INSERT sobre la tabla (migración 0006). Del
/// lado del cliente son de solo lectura.
@freezed
abstract class PedidoEvento with _$PedidoEvento {
  const PedidoEvento._();

  const factory PedidoEvento({
    required String id,
    required String pedidoId,

    /// Nulo si el evento no tuvo estado previo.
    PedidoEstado? estadoAnterior,
    required PedidoEstado estadoNuevo,

    /// Quién lo provocó, de `auth.uid()`. Nulo cuando lo hizo un proceso del
    /// servidor, como el barrido de vencimientos bajo pg_cron.
    String? actorId,
    String? motivo,
    required DateTime createdAt,
  }) = _PedidoEvento;

  /// Motivo con el que la RPC `registrar_edicion_pedido` (migración 0010)
  /// marca una edición del CU-15.
  ///
  /// Es una constante y no una frase suelta porque se compara por igualdad:
  /// si el texto cambia de un lado, la cronología deja de reconocer el evento
  /// y lo muestra como un cambio de estado que no existió.
  static const String motivoEdicion = 'edicion';

  factory PedidoEvento.desdeFila(Map<String, dynamic> fila) {
    final anterior = fila['estado_anterior'] as String?;

    return PedidoEvento(
      id: fila['id'] as String,
      pedidoId: fila['pedido_id'] as String,
      estadoAnterior:
          anterior == null ? null : PedidoEstado.desdeClave(anterior),
      estadoNuevo: PedidoEstado.desdeClave(fila['estado_nuevo'] as String),
      actorId: fila['actor_id'] as String?,
      motivo: fila['motivo'] as String?,
      createdAt: DateTime.parse(fila['created_at'] as String).toLocal(),
    );
  }

  /// Lo hizo el servidor y no una persona.
  bool get esAutomatico => actorId == null;

  /// Una edición del CU-15, que no es un cambio de estado: la RPC deja el
  /// evento con el mismo estado de los dos lados y el motivo [motivoEdicion].
  bool get esEdicion =>
      motivo == motivoEdicion && estadoAnterior == estadoNuevo;

  /// Línea para la cronología del pedido.
  String get descripcion {
    if (esEdicion) return 'Se editó el pedido';

    return estadoAnterior == null
        ? 'Pasó a ${estadoNuevo.etiqueta}'
        : 'De ${estadoAnterior!.etiqueta} a ${estadoNuevo.etiqueta}';
  }
}
