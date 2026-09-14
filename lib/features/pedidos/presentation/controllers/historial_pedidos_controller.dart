import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/mapas/mapa_config.dart';
import '../../data/pedido_exception.dart';
import '../../data/pedidos_repository.dart';
import '../../domain/pedido.dart';
import '../../domain/pedido_estado.dart';

part 'historial_pedidos_controller.freezed.dart';
part 'historial_pedidos_controller.g.dart';

@freezed
abstract class EstadoHistorial with _$EstadoHistorial {
  const EstadoHistorial._();

  const factory EstadoHistorial({
    @Default(FiltroPedidos.activos) FiltroPedidos filtro,
    @Default('') String busqueda,
    @Default(<Pedido>[]) List<Pedido> pedidos,

    /// Cuántos pedidos hay por estado. De acá salen los números de las
    /// pestañas, y no del largo de [pedidos], que es solo la página cargada.
    @Default(<PedidoEstado, int>{}) Map<PedidoEstado, int> contadores,

    /// Hay una página en vuelo.
    @Default(false) bool cargandoMas,

    /// La última página vino completa, así que puede haber más.
    @Default(true) bool hayMas,
    PedidoException? error,
  }) = _EstadoHistorial;

  /// Total de un grupo, sumando los estados que agrupa.
  int contar(FiltroPedidos grupo) => grupo.estados.fold(
        0,
        (total, estado) => total + (contadores[estado] ?? 0),
      );

  int get total => contadores.values.fold(0, (a, b) => a + b);

  /// Hay texto suficiente como para que el servidor esté filtrando.
  bool get filtrandoPorTexto => busqueda.trim().length >= 2;

  /// La lista está vacía **y no es porque se esté buscando algo**. Es lo que
  /// separa «todavía no publicaste nada» de «no hay resultados», que son dos
  /// pantallas vacías distintas y con salidas distintas.
  bool get sinPedidosPropios => pedidos.isEmpty && !filtrandoPorTexto;
}

/// CU-17 — Consultar Historial.
///
/// Una sola instancia para toda la pantalla, y no una familia por filtro: el
/// filtro, el texto buscado y la página cargada son **un solo estado**. Con una
/// familia por filtro, cambiar de pestaña perdería lo que se estaba buscando y
/// cada pestaña pagaría su propia paginación.
///
/// autoDispose: al volver al historial se recarga, que es lo que se espera
/// después de publicar, cerrar o renovar un pedido.
@riverpod
class HistorialPedidos extends _$HistorialPedidos {
  /// Lo que pide el caso de uso. Coincide con el `limit` del repositorio.
  static const int porPagina = 20;

  Timer? _esperaBusqueda;

  /// Riverpod 2.6 no expone `ref.mounted` y todos los métodos de acá esperan
  /// una respuesta antes de escribir el estado. Misma solución que en el
  /// selector de ubicación del CU-16.
  bool _vivo = true;

  PedidosRepository get _repo => ref.read(pedidosRepositoryProvider);

  @override
  Future<EstadoHistorial> build() async {
    ref.onDispose(() {
      _vivo = false;
      _esperaBusqueda?.cancel();
    });

    const inicial = EstadoHistorial();

    // Los dos viajes salen juntos: la primera página y los contadores no
    // dependen entre sí, y encadenarlos duplicaría la espera de la pantalla.
    final (pedidos, contadores) = await (
      _repo.listarMisPedidos(filtro: inicial.filtro, limit: porPagina),
      _repo.contarPorEstado(),
    ).wait;

    return inicial.copyWith(
      pedidos: pedidos,
      contadores: contadores,
      hayMas: pedidos.length == porPagina,
    );
  }

  // ---------------------------------------------------------------------------
  // Filtro y búsqueda
  // ---------------------------------------------------------------------------

  Future<void> cambiarFiltro(FiltroPedidos filtro) async {
    final actual = state.valueOrNull;
    if (actual == null || actual.filtro == filtro) return;

    state = AsyncData(actual.copyWith(filtro: filtro, error: null));
    await _cargarPrimeraPagina();
  }

  /// Busca con una pausa, para no salir a la red en cada tecla.
  ///
  /// El texto se guarda enseguida —si no, el campo se vería vacío mientras se
  /// escribe— pero la consulta espera. Es el mismo criterio del autocompletado
  /// de direcciones del CU-16, y comparte su constante.
  void buscar(String texto) {
    final actual = state.valueOrNull;
    if (actual == null) return;

    _esperaBusqueda?.cancel();
    state = AsyncData(actual.copyWith(busqueda: texto));

    _esperaBusqueda = Timer(
      const Duration(milliseconds: MapaConfig.debounceAutocompletadoMs),
      _cargarPrimeraPagina,
    );
  }

  // ---------------------------------------------------------------------------
  // Paginación
  // ---------------------------------------------------------------------------

  /// La página siguiente, al final de la lista.
  ///
  /// No hace nada si ya hay uno en vuelo o si la última página vino corta: sin
  /// esas dos guardas, el scroll dispara varias veces seguidas mientras la
  /// primera respuesta viaja y los pedidos aparecen repetidos.
  Future<void> cargarMas() async {
    final actual = state.valueOrNull;
    if (actual == null || actual.cargandoMas || !actual.hayMas) return;

    state = AsyncData(actual.copyWith(cargandoMas: true, error: null));

    try {
      final pagina = await _repo.listarMisPedidos(
        filtro: actual.filtro,
        busqueda: actual.busqueda,
        limit: porPagina,
        offset: actual.pedidos.length,
      );
      if (!_vivo) return;

      state = AsyncData(actual.copyWith(
        pedidos: [...actual.pedidos, ...pagina],
        cargandoMas: false,
        hayMas: pagina.length == porPagina,
      ));
    } on PedidoException catch (e) {
      if (!_vivo) return;
      state = AsyncData(actual.copyWith(cargandoMas: false, error: e));
    }
  }

  /// Pull to refresh.
  ///
  /// Corre `marcar_pedidos_vencidos()` **antes** de leer: en producción ese
  /// barrido lo dispara pg_cron, pero en el entorno académico no hay nada que
  /// lo haga, y sin él un pedido cuya fecha ya pasó seguiría figurando como
  /// publicado. Que falle no impide refrescar: las consultas filtran por fecha
  /// igual, lo único que quedaría desalineado es la etiqueta del estado.
  Future<void> refrescar() async {
    try {
      await _repo.marcarVencidos();
    } on PedidoException {
      // Ver arriba: no es motivo para no mostrar la lista.
    }
    if (!_vivo) return;

    await _cargarPrimeraPagina(conContadores: true);
  }

  // ---------------------------------------------------------------------------
  // Interno
  // ---------------------------------------------------------------------------

  Future<void> _cargarPrimeraPagina({bool conContadores = false}) async {
    final actual = state.valueOrNull;
    if (actual == null) return;

    state = AsyncData(actual.copyWith(cargandoMas: true, error: null));

    try {
      final pedidos = await _repo.listarMisPedidos(
        filtro: actual.filtro,
        busqueda: actual.busqueda,
        limit: porPagina,
      );
      final contadores =
          conContadores ? await _repo.contarPorEstado() : actual.contadores;
      if (!_vivo) return;

      state = AsyncData(actual.copyWith(
        pedidos: pedidos,
        contadores: contadores,
        cargandoMas: false,
        hayMas: pedidos.length == porPagina,
      ));
    } on PedidoException catch (e) {
      if (!_vivo) return;
      state = AsyncData(actual.copyWith(cargandoMas: false, error: e));
    }
  }
}
