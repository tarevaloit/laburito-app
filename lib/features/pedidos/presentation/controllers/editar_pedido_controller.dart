import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/pedido_exception.dart';
import '../../data/pedidos_repository.dart';
import '../../data/urls_firmadas.dart';
import '../../domain/pedido.dart';
import '../../domain/pedido_estado.dart';
import '../../domain/pedido_foto.dart';
import '../../domain/ubicacion.dart';
import 'historial_pedidos_controller.dart';

part 'editar_pedido_controller.freezed.dart';
part 'editar_pedido_controller.g.dart';

/// El borrador de la edición: lo que hay en el formulario ahora mismo, más el
/// pedido tal como estaba al abrirlo.
///
/// Guardar el [original] no es redundante con tener los campos sueltos: es lo
/// que permite saber si algo cambió —para no mandar escrituras que no hacen
/// nada, y para preguntar antes de salir— y de qué estado se partió.
@freezed
abstract class EstadoEditarPedido with _$EstadoEditarPedido {
  const EstadoEditarPedido._();

  const factory EstadoEditarPedido({
    required Pedido original,
    required String categoriaId,
    required String titulo,
    required String descripcion,
    required PedidoUrgencia urgencia,
    required Ubicacion ubicacion,
    double? presupuestoEstimado,

    /// Las fotos guardadas del pedido. Se editan al instante (subir y borrar
    /// son operaciones sobre Storage, no sobre el formulario), así que esta
    /// lista se actualiza sola y no espera al botón de guardar.
    @Default(<PedidoFoto>[]) List<PedidoFoto> fotos,
    @Default(false) bool guardando,
    @Default(false) bool trabajandoConFotos,
    PedidoException? error,
  }) = _EstadoEditarPedido;

  /// Solo los campos del formulario: las fotos no cuentan porque ya están
  /// guardadas en el momento en que se tocan.
  bool get hayCambios =>
      categoriaId != original.categoriaId ||
      titulo.trim() != original.titulo ||
      descripcion.trim() != original.descripcion ||
      urgencia != original.urgencia ||
      ubicacion != original.ubicacion ||
      presupuestoEstimado != original.presupuestoEstimado;

  bool get cambioLaUbicacion => ubicacion != original.ubicacion;

  bool get puedeAgregarFoto => fotos.length < PedidoFoto.maximoPorPedido;

  bool get ocupado => guardando || trabajandoConFotos;
}

/// CU-15 — Editar Pedido.
///
/// Solo tiene sentido sobre un pedido `publicado` o `pausado`: la RPC
/// `actualizar_ubicacion_pedido` rechaza el resto, y editar un pedido cerrado
/// no tendría a quién servirle. La pantalla lo comprueba antes de dibujar el
/// formulario.
///
/// **La vigencia no se edita acá.** Estirar `fecha_vencimiento` con un PATCH
/// sería una renovación sin límite, y el CU-51 permite tres: la fecha se
/// mueve solo por `renovar_pedido`, que las cuenta.
@riverpod
class EditarPedido extends _$EditarPedido {
  @override
  Future<EstadoEditarPedido> build(String pedidoId) async {
    // Se lee del repositorio y no de `pedidoProvider`: si el borrador
    // dependiera de ese provider, cada `invalidate` —el que hace esta misma
    // pantalla al subir una foto, por ejemplo— reconstruiría el formulario y
    // se llevaría puesto lo que la persona venía escribiendo.
    final pedido = await ref.read(pedidosRepositoryProvider).obtenerPedido(
          pedidoId,
        );

    if (pedido == null) {
      throw const PedidoException(
        CasoPedido.sinPermiso,
        'No encontramos ese pedido, o no es tuyo.',
      );
    }

    return EstadoEditarPedido(
      original: pedido,
      categoriaId: pedido.categoriaId,
      titulo: pedido.titulo,
      descripcion: pedido.descripcion,
      urgencia: pedido.urgencia,
      ubicacion: pedido.ubicacion,
      presupuestoEstimado: pedido.presupuestoEstimado,
      fotos: pedido.fotos,
    );
  }

  // ---------------------------------------------------------------------------
  // Campos
  // ---------------------------------------------------------------------------

  void setCategoria(String? id) {
    if (id == null) return;
    _actualizar((e) => e.copyWith(categoriaId: id));
  }

  void setTitulo(String texto) => _actualizar((e) => e.copyWith(titulo: texto));

  void setDescripcion(String texto) =>
      _actualizar((e) => e.copyWith(descripcion: texto));

  void setUrgencia(PedidoUrgencia urgencia) =>
      _actualizar((e) => e.copyWith(urgencia: urgencia));

  void setUbicacion(Ubicacion ubicacion) =>
      _actualizar((e) => e.copyWith(ubicacion: ubicacion));

  void setPresupuesto(double? valor) =>
      _actualizar((e) => e.copyWith(presupuestoEstimado: valor));

  // ---------------------------------------------------------------------------
  // Fotos
  // ---------------------------------------------------------------------------

  /// Sube la foto ya mismo, sin esperar al botón de guardar.
  ///
  /// A diferencia del alta, acá el pedido ya existe, así que la política de
  /// Storage se cumple y no hay nada que postergar. Juntar las fotos hasta el
  /// «Guardar» obligaría a mantener en memoria imágenes que ya podrían estar
  /// en el servidor, y a deshacer subidas si la edición falla.
  Future<bool> agregarFoto(Uint8List bytes, String nombre) async {
    final actual = state.valueOrNull;
    if (actual == null || actual.ocupado || !actual.puedeAgregarFoto) {
      return false;
    }

    state = AsyncData(actual.copyWith(trabajandoConFotos: true, error: null));

    try {
      final foto = await ref.read(pedidosRepositoryProvider).subirFoto(
            pedidoId: pedidoId,
            bytes: bytes,
            filename: nombre,
          );

      state = AsyncData(actual.copyWith(
        fotos: [...actual.fotos, foto],
        trabajandoConFotos: false,
      ));
      _refrescarPedido();
      return true;
    } on PedidoException catch (e) {
      state = AsyncData(
        actual.copyWith(trabajandoConFotos: false, error: e),
      );
      return false;
    }
  }

  Future<bool> eliminarFoto(PedidoFoto foto) async {
    final actual = state.valueOrNull;
    if (actual == null || actual.ocupado) return false;

    state = AsyncData(actual.copyWith(trabajandoConFotos: true, error: null));

    try {
      await ref.read(pedidosRepositoryProvider).eliminarFoto(foto.id);

      // La firma sigue siendo válida un rato más, pero el archivo ya no está:
      // si queda en el caché, la próxima pantalla muestra una imagen rota.
      ref.read(urlsFirmadasProvider).olvidar(foto.storagePath);

      state = AsyncData(actual.copyWith(
        fotos: [
          for (final f in actual.fotos)
            if (f.id != foto.id) f,
        ],
        trabajandoConFotos: false,
      ));
      _refrescarPedido();
      return true;
    } on PedidoException catch (e) {
      state = AsyncData(
        actual.copyWith(trabajandoConFotos: false, error: e),
      );
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Guardar
  // ---------------------------------------------------------------------------

  /// Manda solo lo que cambió.
  ///
  /// La ubicación va aparte —es una RPC, porque un `geography` no se escribe
  /// desde un UPDATE de PostgREST— y por eso importa no mandarla si no se
  /// tocó: sería una escritura de más, y son dos escrituras sin transacción
  /// común.
  Future<bool> guardar() async {
    final actual = state.valueOrNull;
    if (actual == null || actual.ocupado) return false;

    if (!actual.hayCambios) return true;

    state = AsyncData(actual.copyWith(guardando: true, error: null));

    try {
      await ref.read(pedidosRepositoryProvider).actualizarPedido(
            pedidoId,
            categoriaId: actual.categoriaId,
            titulo: actual.titulo,
            descripcion: actual.descripcion,
            urgencia: actual.urgencia,
            ubicacion: actual.cambioLaUbicacion ? actual.ubicacion : null,
            // Sin centinela: lo que muestra el campo es lo que se guarda, y
            // vaciarlo es una forma legítima de borrar el presupuesto.
            presupuestoEstimado: actual.presupuestoEstimado,
          );

      _refrescarPedido();
      state = AsyncData(actual.copyWith(guardando: false));
      return true;
    } on PedidoException catch (e) {
      state = AsyncData(actual.copyWith(guardando: false, error: e));
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Interno
  // ---------------------------------------------------------------------------

  void _actualizar(
    EstadoEditarPedido Function(EstadoEditarPedido) cambio,
  ) {
    final actual = state.valueOrNull;
    if (actual == null || actual.guardando) return;
    state = AsyncData(cambio(actual));
  }

  /// El detalle, la cronología y el historial quedaron viejos. No se invalida
  /// este controller: el borrador es de la pantalla, no de la base.
  void _refrescarPedido() {
    ref.invalidate(pedidoProvider(pedidoId));
    ref.invalidate(historialPedidoProvider(pedidoId));
    ref.invalidate(historialPedidosProvider);
  }
}
