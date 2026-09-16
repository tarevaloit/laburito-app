import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../data/tablero_repository.dart';
import '../../domain/pedido_tablero.dart';

part 'tablero_controller.freezed.dart';
part 'tablero_controller.g.dart';

/// Qué está mirando el Profesional en el tablero.
enum FiltroTablero {
  /// Pedidos de sus oficios, que es para lo que sirve el tablero.
  misOficios('Mis oficios'),

  /// Todos los vigentes, por si quiere ver qué más se pide cerca.
  todos('Todos'),

  /// Los que guardó (CU-24).
  guardados('Guardados');

  const FiltroTablero(this.etiqueta);

  final String etiqueta;

  bool get soloMisOficios => this == FiltroTablero.misOficios;
  bool get soloGuardados => this == FiltroTablero.guardados;
}

@freezed
abstract class EstadoTablero with _$EstadoTablero {
  const EstadoTablero._();

  const factory EstadoTablero({
    @Default(<PedidoTablero>[]) List<PedidoTablero> pedidos,
    @Default(FiltroTablero.misOficios) FiltroTablero filtro,
    @Default(false) bool cargandoMas,
    @Default(false) bool hayMas,
    String? error,
  }) = _EstadoTablero;

  bool get vacio => pedidos.isEmpty;
}

/// CU-43 — Explorar Tablero de Pedidos.
///
/// El orden por distancia lo resuelve `tablero_pedidos()` (migración 0018):
/// ordenar del lado del cliente obligaría a traerse todos los pedidos vigentes
/// para poder decidir cuáles son los veinte más cercanos.
@riverpod
class Tablero extends _$Tablero {
  static const int _porPagina = 20;

  @override
  Future<EstadoTablero> build() async {
    final pedidos = await _pedir(FiltroTablero.misOficios, 0);

    return EstadoTablero(
      pedidos: pedidos,
      hayMas: pedidos.length == _porPagina,
    );
  }

  Future<List<PedidoTablero>> _pedir(FiltroTablero filtro, int desde) =>
      ref.read(tableroRepositoryProvider).listar(
            limite: _porPagina,
            desplazamiento: desde,
            soloMisOficios: filtro.soloMisOficios,
            soloGuardados: filtro.soloGuardados,
          );

  Future<void> cambiarFiltro(FiltroTablero filtro) async {
    final actual = state.valueOrNull;
    if (actual == null || actual.filtro == filtro) return;

    state = AsyncData(actual.copyWith(
      filtro: filtro,
      pedidos: const [],
      error: null,
      cargandoMas: true,
    ));

    try {
      final pedidos = await _pedir(filtro, 0);
      state = AsyncData(EstadoTablero(
        pedidos: pedidos,
        filtro: filtro,
        hayMas: pedidos.length == _porPagina,
      ));
    } on Object catch (error) {
      state = AsyncData(EstadoTablero(
        filtro: filtro,
        error: MensajesError.desde(error),
      ));
    }
  }

  /// Scroll infinito. No hace nada si ya está pidiendo o si no hay más: el
  /// listado dispara esto en cada cuadro mientras se arrastra.
  Future<void> cargarMas() async {
    final actual = state.valueOrNull;
    if (actual == null || actual.cargandoMas || !actual.hayMas) return;

    state = AsyncData(actual.copyWith(cargandoMas: true, error: null));

    try {
      final pagina = await _pedir(actual.filtro, actual.pedidos.length);

      state = AsyncData(actual.copyWith(
        pedidos: [...actual.pedidos, ...pagina],
        cargandoMas: false,
        hayMas: pagina.length == _porPagina,
      ));
    } on Object catch (error) {
      state = AsyncData(actual.copyWith(
        cargandoMas: false,
        error: MensajesError.desde(error),
      ));
    }
  }

  /// CU-24 — Guardar o dejar de guardar, con la lista actualizada al toque.
  ///
  /// Se pinta primero y se escribe después: la marca es una operación chica y
  /// esperar medio segundo a que el servidor conteste para que el ícono cambie
  /// se siente roto. Si falla, se revierte y se avisa.
  Future<void> alternarGuardado(String pedidoId) async {
    final actual = state.valueOrNull;
    if (actual == null) return;

    final pedido = actual.pedidos.firstWhere((p) => p.id == pedidoId);
    final guardado = !pedido.guardado;

    state = AsyncData(_conPedido(actual, pedido.copyWith(guardado: guardado)));

    try {
      await ref
          .read(tableroRepositoryProvider)
          .guardar(pedidoId, guardado: guardado);

      // En la solapa de guardados, dejar de guardar saca el pedido de la lista.
      if (!guardado && actual.filtro == FiltroTablero.guardados) {
        final conActual = state.valueOrNull;
        if (conActual != null) {
          state = AsyncData(conActual.copyWith(
            pedidos: [
              for (final p in conActual.pedidos)
                if (p.id != pedidoId) p,
            ],
          ));
        }
      }
    } on Object catch (error) {
      state = AsyncData(
        _conPedido(actual, pedido).copyWith(error: MensajesError.desde(error)),
      );
    }
  }

  /// CU-23 — Ignorar: el pedido sale del tablero de este Profesional y deja de
  /// contar para sus alertas (el emparejamiento de la 0016 lo descarta).
  ///
  /// Devuelve `true` si salió bien, para que la pantalla ofrezca deshacer.
  Future<bool> ignorar(String pedidoId) async {
    final actual = state.valueOrNull;
    if (actual == null) return false;

    state = AsyncData(actual.copyWith(
      pedidos: [
        for (final p in actual.pedidos)
          if (p.id != pedidoId) p,
      ],
      error: null,
    ));

    try {
      await ref.read(tableroRepositoryProvider).ignorar(pedidoId);
      return true;
    } on Object catch (error) {
      state = AsyncData(actual.copyWith(error: MensajesError.desde(error)));
      return false;
    }
  }

  /// El «Deshacer» del aviso. Vuelve a pedir la página: el pedido tiene que
  /// reaparecer en su lugar por distancia, no al final de la lista.
  Future<void> dejarDeIgnorar(String pedidoId) async {
    try {
      await ref.read(tableroRepositoryProvider).dejarDeIgnorar(pedidoId);
    } on Object catch (error) {
      final actual = state.valueOrNull;
      if (actual != null) {
        state = AsyncData(actual.copyWith(error: MensajesError.desde(error)));
      }
      return;
    }

    await refrescar();
  }

  EstadoTablero _conPedido(EstadoTablero estado, PedidoTablero pedido) =>
      estado.copyWith(
        pedidos: [
          for (final p in estado.pedidos)
            if (p.id == pedido.id) pedido else p,
        ],
        error: null,
      );

  Future<void> refrescar() async {
    final filtro = state.valueOrNull?.filtro ?? FiltroTablero.misOficios;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final pedidos = await _pedir(filtro, 0);
      return EstadoTablero(
        pedidos: pedidos,
        filtro: filtro,
        hayMas: pedidos.length == _porPagina,
      );
    });
  }
}
