import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/pedido_exception.dart';
import '../../data/pedidos_repository.dart';
import '../../domain/pedido_estado.dart';
import 'historial_pedidos_controller.dart';

part 'acciones_pedido_controller.freezed.dart';
part 'acciones_pedido_controller.g.dart';

/// Las acciones del ciclo de vida que ofrece el detalle del pedido.
///
/// Existe para que la pantalla sepa **cuál** de todas está en curso: con un
/// `bool cargando` suelto, tocar «Pausar» dejaría girando también al botón de
/// cerrar.
enum AccionPedido {
  pausar('Pausando la publicación…'),
  reanudar('Reanudando la publicación…'),
  cerrar('Cerrando el pedido…'),
  cancelar('Cancelando el pedido…'),
  renovar('Renovando el pedido…');

  const AccionPedido(this.enProgreso);

  final String enProgreso;
}

@freezed
abstract class EstadoAccionesPedido with _$EstadoAccionesPedido {
  const EstadoAccionesPedido._();

  const factory EstadoAccionesPedido({
    /// Qué acción se está ejecutando ahora, o `null` si ninguna.
    AccionPedido? enCurso,
    PedidoException? error,
  }) = _EstadoAccionesPedido;

  bool get ocupado => enCurso != null;
}

/// CU-20 (pausar/reanudar), CU-29 (cerrar), CU-14 (cancelar) y CU-51 (renovar).
///
/// Una sola familia para las cuatro operaciones porque comparten todo lo que
/// no es la llamada en sí: bloquear mientras se envía, envolver el
/// [PedidoException] y refrescar lo que quedó viejo. Lo que cambia —qué RPC se
/// llama, qué motivo se manda— cabe en una línea por método.
///
/// autoDispose: el estado de «estoy pausando» no tiene sentido fuera de la
/// pantalla que disparó la acción.
@riverpod
class AccionesPedido extends _$AccionesPedido {
  @override
  EstadoAccionesPedido build(String pedidoId) => const EstadoAccionesPedido();

  // ---------------------------------------------------------------------------
  // CU-20 — Pausar / Reanudar
  // ---------------------------------------------------------------------------

  /// El pedido deja de verse, pero no se pierde: sigue existiendo con sus
  /// fotos y su historial, y vuelve con [reanudar].
  Future<bool> pausar() => _ejecutar(
        AccionPedido.pausar,
        (repo) => repo.cambiarEstado(pedidoId, PedidoEstado.pausado),
      );

  Future<bool> reanudar() => _ejecutar(
        AccionPedido.reanudar,
        (repo) => repo.cambiarEstado(pedidoId, PedidoEstado.publicado),
      );

  // ---------------------------------------------------------------------------
  // CU-29 — Cerrar (el trabajo se resolvió)
  // ---------------------------------------------------------------------------

  /// [motivo] sale de una lista cerrada, no de un campo libre: es el dato con
  /// el que después se mide cuántos trabajos resolvió Laburito.
  Future<bool> cerrar(MotivoCierre motivo) => _ejecutar(
        AccionPedido.cerrar,
        (repo) => repo.cambiarEstado(
          pedidoId,
          PedidoEstado.cerrado,
          motivo: motivo.etiqueta,
        ),
      );

  // ---------------------------------------------------------------------------
  // CU-14 — Cancelar (el pedido se da de baja)
  // ---------------------------------------------------------------------------

  /// A diferencia de [cerrar], el motivo es libre y opcional: acá no hay una
  /// lista de razones que valga la pena medir, y obligar a escribir una frase
  /// para dar de baja algo propio es un peaje.
  Future<bool> cancelar({String? motivo}) => _ejecutar(
        AccionPedido.cancelar,
        (repo) => repo.cambiarEstado(
          pedidoId,
          PedidoEstado.cancelado,
          motivo: motivo,
        ),
      );

  // ---------------------------------------------------------------------------
  // CU-51 — Renovar
  // ---------------------------------------------------------------------------

  Future<bool> renovar(int dias) => _ejecutar(
        AccionPedido.renovar,
        (repo) => repo.renovar(pedidoId, dias),
      );

  // ---------------------------------------------------------------------------
  // Interno
  // ---------------------------------------------------------------------------

  /// El molde de las cuatro: bloquear, llamar, refrescar lo que cambió.
  ///
  /// Si ya hay una acción en curso no se dispara otra. No es teórico: los
  /// botones se deshabilitan mientras se envía, pero entre el toque y el
  /// `setState` hay una ventana, y dos «Cerrar» seguidos terminarían en un
  /// «El pedido ya está en estado cerrado» que no le sirve a nadie.
  Future<bool> _ejecutar(
    AccionPedido accion,
    Future<void> Function(PedidosRepository repo) operacion,
  ) async {
    if (state.ocupado) return false;

    state = state.copyWith(enCurso: accion, error: null);

    try {
      await operacion(ref.read(pedidosRepositoryProvider));
      _refrescar();
      state = state.copyWith(enCurso: null);
      return true;
    } on PedidoException catch (e) {
      state = state.copyWith(enCurso: null, error: e);
      return false;
    }
  }

  /// Todo lo que acaba de quedar viejo.
  ///
  /// El detalle, porque cambió el estado; la cronología, porque el trigger dejó
  /// un evento nuevo; y el historial (CU-17), porque el pedido pudo haber
  /// cambiado de grupo —de «Activos» a «Cerrados»— y quien vuelva atrás tiene
  /// que verlo donde va, con los contadores al día.
  void _refrescar() {
    ref.invalidate(pedidoProvider(pedidoId));
    ref.invalidate(historialPedidoProvider(pedidoId));
    ref.invalidate(historialPedidosProvider);
  }
}

/// CU-29 — Por qué se cierra un pedido.
///
/// Lista cerrada y no texto libre: la diferencia entre «lo resolví con alguien
/// de Laburito» y «lo resolví por otro lado» es la métrica que justifica el
/// producto, y de un campo libre no se saca.
enum MotivoCierre {
  conProfesionalDeLaburito('Resolví con un profesional de Laburito'),
  porOtroMedio('Resolví por otro medio'),
  yaNoLoNecesito('Ya no lo necesito');

  const MotivoCierre(this.etiqueta);

  /// Va tal cual a `pedidos.motivo_cierre` y de ahí al evento de auditoría.
  final String etiqueta;
}
