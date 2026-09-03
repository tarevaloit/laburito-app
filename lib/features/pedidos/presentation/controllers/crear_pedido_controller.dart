import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/pedido_exception.dart';
import '../../data/pedidos_repository.dart';
import '../../domain/pedido.dart';
import '../../domain/pedido_estado.dart';
import '../../domain/ubicacion.dart';

part 'crear_pedido_controller.freezed.dart';
part 'crear_pedido_controller.g.dart';

/// Una foto elegida por el usuario, todavía sin subir.
///
/// El pedido tiene que existir antes de que una foto pueda subirse —la
/// política de Storage exige que el primer segmento de la ruta sea un pedido
/// del usuario—, así que durante el asistente las fotos viven solo en memoria.
class FotoPendiente {
  const FotoPendiente({required this.bytes, required this.nombre});

  final Uint8List bytes;
  final String nombre;
}

/// Los cuatro pasos del CU-13, en el orden de la pantalla.
enum PasoCrearPedido {
  queNecesitas,
  donde,
  fotos,
  vigencia;

  bool get esPrimero => this == PasoCrearPedido.queNecesitas;
  bool get esUltimo => this == PasoCrearPedido.vigencia;
}

@freezed
abstract class EstadoCrearPedido with _$EstadoCrearPedido {
  const EstadoCrearPedido._();

  const factory EstadoCrearPedido({
    @Default(PasoCrearPedido.queNecesitas) PasoCrearPedido paso,
    String? categoriaId,
    @Default('') String titulo,
    @Default('') String descripcion,
    @Default(PedidoUrgencia.media) PedidoUrgencia urgencia,
    Ubicacion? ubicacion,
    @Default(<FotoPendiente>[]) List<FotoPendiente> fotos,
    @Default(7) int diasVigencia,
    double? presupuestoEstimado,
    @Default(false) bool enviando,
    PedidoException? error,

    /// Fotos que no se pudieron subir después de crear el pedido. El pedido
    /// ya quedó publicado igual: una foto que falla no deshace el alta.
    @Default(<String>[]) List<String> erroresFotos,
    Pedido? pedidoCreado,
  }) = _EstadoCrearPedido;

  /// Paso 1 completo: es lo único que se valida acá, porque los campos de
  /// texto los valida el `Form` de la pantalla. Sirve para el indicador de
  /// progreso y para no ofrecer «Siguiente» en un paso a medias.
  bool get paso1Completo =>
      categoriaId != null && titulo.trim().length >= 5 && descripcion.trim().length >= 20;

  bool get paso2Completo => ubicacion != null;

  bool get puedeAgregarFoto => fotos.length < 5;

  bool get puedeEnviar => paso1Completo && paso2Completo && !enviando;
}

/// CU-13 — Publicar Pedido, en cuatro pasos.
///
/// autoDispose: cada apertura del asistente arranca de cero. Si el usuario
/// sale y vuelve a entrar, no tiene sentido que reaparezca un borrador viejo.
@riverpod
class CrearPedidoController extends _$CrearPedidoController {
  @override
  EstadoCrearPedido build() => const EstadoCrearPedido();

  // ---------------------------------------------------------------------------
  // Paso 1 — Qué necesitás
  // ---------------------------------------------------------------------------

  void setCategoria(String? id) => state = state.copyWith(categoriaId: id);
  void setTitulo(String texto) => state = state.copyWith(titulo: texto);
  void setDescripcion(String texto) =>
      state = state.copyWith(descripcion: texto);
  void setUrgencia(PedidoUrgencia urgencia) =>
      state = state.copyWith(urgencia: urgencia);

  // ---------------------------------------------------------------------------
  // Paso 2 — Dónde
  // ---------------------------------------------------------------------------

  void setUbicacion(Ubicacion? ubicacion) =>
      state = state.copyWith(ubicacion: ubicacion);

  // ---------------------------------------------------------------------------
  // Paso 3 — Fotos
  // ---------------------------------------------------------------------------

  /// `false` cuando ya está el tope de 5: la pantalla avisa y no agrega.
  bool agregarFoto(Uint8List bytes, String nombre) {
    if (!state.puedeAgregarFoto) return false;
    state = state.copyWith(fotos: [...state.fotos, FotoPendiente(bytes: bytes, nombre: nombre)]);
    return true;
  }

  void quitarFoto(int indice) {
    final copia = [...state.fotos]..removeAt(indice);
    state = state.copyWith(fotos: copia);
  }

  // ---------------------------------------------------------------------------
  // Paso 4 — Vigencia y presupuesto
  // ---------------------------------------------------------------------------

  void setDiasVigencia(int dias) => state = state.copyWith(diasVigencia: dias);

  void setPresupuesto(double? valor) =>
      state = state.copyWith(presupuestoEstimado: valor);

  // ---------------------------------------------------------------------------
  // Navegación entre pasos
  // ---------------------------------------------------------------------------

  void avanzar() {
    final siguiente = PasoCrearPedido.values[state.paso.index + 1];
    state = state.copyWith(paso: siguiente, error: null);
  }

  void retroceder() {
    final anterior = PasoCrearPedido.values[state.paso.index - 1];
    state = state.copyWith(paso: anterior, error: null);
  }

  /// Hay algo que se perdería si se sale ahora. Lo usa la pantalla para
  /// decidir si pregunta antes de cerrar el asistente.
  bool get hayCambiosSinGuardar =>
      state.categoriaId != null ||
      state.titulo.trim().isNotEmpty ||
      state.descripcion.trim().isNotEmpty ||
      state.ubicacion != null ||
      state.fotos.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Confirmar
  // ---------------------------------------------------------------------------

  /// Publica el pedido y después sube las fotos, en ese orden: la política de
  /// Storage exige que el pedido ya exista.
  ///
  /// Una foto que falla no deshace el alta — el pedido ya está publicado —,
  /// así que los fallos se juntan en `erroresFotos` en vez de propagarse como
  /// excepción.
  Future<bool> confirmar() async {
    if (!state.puedeEnviar) return false;

    state = state.copyWith(enviando: true, error: null, erroresFotos: const []);

    final repo = ref.read(pedidosRepositoryProvider);

    try {
      final pedido = await repo.crearPedido(
        categoriaId: state.categoriaId!,
        titulo: state.titulo,
        descripcion: state.descripcion,
        ubicacion: state.ubicacion!,
        fechaVencimiento: DateTime.now().add(Duration(days: state.diasVigencia)),
        urgencia: state.urgencia,
        presupuestoEstimado: state.presupuestoEstimado,
      );

      final errores = <String>[];
      for (final foto in state.fotos) {
        try {
          await repo.subirFoto(
            pedidoId: pedido.id,
            bytes: foto.bytes,
            filename: foto.nombre,
          );
        } on PedidoException catch (e) {
          errores.add(e.message);
        }
      }

      // Si hubo fotos, releer el pedido para que el resultado las incluya.
      final resultado =
          errores.length == state.fotos.length || state.fotos.isEmpty
              ? pedido
              : await repo.obtenerPedido(pedido.id) ?? pedido;

      state = state.copyWith(
        enviando: false,
        pedidoCreado: resultado,
        erroresFotos: errores,
      );
      return true;
    } on PedidoException catch (e) {
      state = state.copyWith(enviando: false, error: e);
      return false;
    }
  }
}
