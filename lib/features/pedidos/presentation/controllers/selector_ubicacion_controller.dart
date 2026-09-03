import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/mapas/mapa_config.dart';
import '../../../../core/mapas/mapas_providers.dart';
import '../../../../core/mapas/servicio_direcciones.dart';
import '../../../../core/mapas/ubicacion_dispositivo.dart';
import '../../domain/ubicacion.dart';

part 'selector_ubicacion_controller.freezed.dart';
part 'selector_ubicacion_controller.g.dart';

/// Adónde tiene que ir la cámara del mapa por orden del controlador.
///
/// El [sello] es lo que hace que la orden se pueda repetir: si el usuario toca
/// «Usar mi ubicación» dos veces sin moverse, la coordenada es la misma y sin
/// un valor que cambie el widget no se enteraría de que tiene que volver a
/// encuadrar.
@freezed
abstract class ObjetivoCamara with _$ObjetivoCamara {
  const factory ObjetivoCamara({
    required double lat,
    required double lng,
    required int sello,
  }) = _ObjetivoCamara;
}

@freezed
abstract class EstadoSelectorUbicacion with _$EstadoSelectorUbicacion {
  const EstadoSelectorUbicacion._();

  const factory EstadoSelectorUbicacion({
    /// Centro del mapa, que es donde está clavado el pin.
    required double lat,
    required double lng,
    @Default('') String direccionTexto,
    @Default('') String referencia,

    /// Hay una geocodificación inversa en vuelo.
    @Default(false) bool resolviendoDireccion,

    /// Hay un pedido de posición al dispositivo en vuelo.
    @Default(false) bool localizando,
    @Default(false) bool buscandoSugerencias,
    @Default(<SugerenciaDireccion>[]) List<SugerenciaDireccion> sugerencias,

    /// Mensaje no bloqueante: permiso denegado, servicio de direcciones caído.
    /// Se muestra y se descarta; nunca impide confirmar.
    String? aviso,
    ObjetivoCamara? objetivo,
  }) = _EstadoSelectorUbicacion;

  /// La [Ubicacion] que se devuelve al confirmar, o `null` si todavía no está
  /// completa. Es la única regla de «se puede confirmar» y vive acá para que la
  /// pantalla no la repita.
  Ubicacion? get ubicacion {
    final propuesta = Ubicacion(
      lat: lat,
      lng: lng,
      direccionTexto: direccionTexto.trim(),
      referencia: referencia.trim().isEmpty ? null : referencia.trim(),
    );
    return propuesta.esValida ? propuesta : null;
  }
}

/// CU-16 — Localizar Pedido en Mapa.
///
/// autoDispose: cada apertura del selector empieza de cero. Si conservara el
/// estado, editar la ubicación de un pedido (CU-15) mostraría el punto del
/// pedido anterior hasta que el mapa terminara de encuadrar.
@riverpod
class SelectorUbicacionController extends _$SelectorUbicacionController {
  Timer? _esperaGeocodificacion;
  Timer? _esperaBusqueda;

  /// Token de sesión de Places: agrupa el tecleo y el pedido de detalle de una
  /// misma búsqueda para que Google los cobre como una operación.
  String _sesionDeBusqueda = ServicioDirecciones.nuevoTokenDeSesion();

  /// Se levanta cuando el controlador movió la cámara él mismo, y lo consume el
  /// primer `onCameraIdle` que llega después.
  ///
  /// Sin esto, elegir una sugerencia de Places dispararía una geocodificación
  /// inversa que pisaría la dirección recién elegida con la que Google devuelve
  /// para ese punto, que casi nunca es la misma cadena.
  bool _movimientoPropio = false;

  /// Riverpod 2.6 no expone `ref.mounted`, y todos los métodos de acá hacen
  /// `await` antes de escribir el estado. Sin esta bandera, salir de la
  /// pantalla mientras una consulta está en vuelo termina en un
  /// «Bad state: Tried to modify a provider after it was disposed».
  bool _vivo = true;

  @override
  EstadoSelectorUbicacion build(Ubicacion? inicial) {
    ref.onDispose(() {
      _vivo = false;
      _esperaGeocodificacion?.cancel();
      _esperaBusqueda?.cancel();
    });

    if (inicial == null) {
      // Sin ubicación previa se arranca en José C. Paz y, si el permiso ya
      // estaba dado de antes, se corrige a la posición real sin molestar a
      // nadie con un diálogo.
      Future.microtask(_centrarSiYaHayPermiso);
      return const EstadoSelectorUbicacion(
        lat: MapaConfig.latJoseCPaz,
        lng: MapaConfig.lngJoseCPaz,
      );
    }

    return EstadoSelectorUbicacion(
      lat: inicial.lat,
      lng: inicial.lng,
      direccionTexto: inicial.direccionTexto,
      referencia: inicial.referencia ?? '',
    );
  }

  ServicioDirecciones get _direcciones => ref.read(servicioDireccionesProvider);
  UbicacionDispositivo get _dispositivo =>
      ref.read(ubicacionDispositivoProvider);

  // ---------------------------------------------------------------------------
  // El mapa
  // ---------------------------------------------------------------------------

  /// Lo llama el widget en `onCameraIdle`, con el centro del mapa.
  ///
  /// El mapa se queda quieto muchas más veces de las que el usuario elige un
  /// punto: al primer encuadre, al terminar un `animateCamera`, al reacomodarse
  /// por el teclado. Por eso se filtran los movimientos propios y los que no
  /// llegan a [MapaConfig.toleranciaMetros].
  void alQuedarQuietoElMapa(double lat, double lng) {
    if (_movimientoPropio) {
      _movimientoPropio = false;
      state = state.copyWith(lat: lat, lng: lng);
      return;
    }

    final corrimiento =
        Geolocator.distanceBetween(state.lat, state.lng, lat, lng);
    if (corrimiento < MapaConfig.toleranciaMetros) return;

    state = state.copyWith(lat: lat, lng: lng);
    _programarGeocodificacion();
  }

  void _programarGeocodificacion() {
    _esperaGeocodificacion?.cancel();
    _esperaGeocodificacion = Timer(
      const Duration(milliseconds: MapaConfig.debounceGeocodificacionMs),
      _resolverDireccion,
    );
  }

  Future<void> _resolverDireccion() async {
    if (!_direcciones.habilitado) return;

    final lat = state.lat;
    final lng = state.lng;

    state = state.copyWith(resolviendoDireccion: true);
    final direccion = await _direcciones.direccionDe(lat, lng);
    if (!_vivo) return;

    // Entre que salió la consulta y volvió, el usuario pudo haber seguido
    // arrastrando: si el centro ya no es el mismo, esta respuesta es vieja y
    // escribirla dejaría el campo describiendo otra esquina.
    final vigente = state.lat == lat && state.lng == lng;

    state = state.copyWith(
      resolviendoDireccion: false,
      direccionTexto: vigente && direccion != null
          ? direccion
          : state.direccionTexto,
      aviso: vigente && direccion == null
          ? 'No pudimos leer la dirección de ese punto. Escribila a mano.'
          : state.aviso,
    );
  }

  // ---------------------------------------------------------------------------
  // Los campos de texto
  // ---------------------------------------------------------------------------

  /// La dirección siempre se puede escribir a mano. Es la salida cuando Google
  /// no contesta, y también cuando contesta algo que no es lo que el usuario
  /// diría («Ruta 8 km 42» en vez de «la casa de al lado del vivero»).
  ///
  /// Una edición manual dura hasta el próximo movimiento del mapa: si el punto
  /// cambia, la dirección vuelve a resolverse.
  void escribirDireccion(String texto) {
    state = state.copyWith(direccionTexto: texto);
  }

  void escribirReferencia(String texto) {
    state = state.copyWith(referencia: texto);
  }

  void descartarAviso() {
    if (state.aviso != null) state = state.copyWith(aviso: null);
  }

  // ---------------------------------------------------------------------------
  // Búsqueda de direcciones
  // ---------------------------------------------------------------------------

  void buscar(String texto) {
    _esperaBusqueda?.cancel();

    if (texto.trim().length < 3) {
      state = state.copyWith(
        sugerencias: const [],
        buscandoSugerencias: false,
      );
      return;
    }

    _esperaBusqueda = Timer(
      const Duration(milliseconds: MapaConfig.debounceAutocompletadoMs),
      () => _pedirSugerencias(texto),
    );
  }

  Future<void> _pedirSugerencias(String texto) async {
    if (!_direcciones.habilitado) return;

    state = state.copyWith(buscandoSugerencias: true);
    final sugerencias = await _direcciones.sugerencias(
      texto,
      sesion: _sesionDeBusqueda,
    );
    if (!_vivo) return;

    state = state.copyWith(
      buscandoSugerencias: false,
      sugerencias: sugerencias,
    );
  }

  void limpiarBusqueda() {
    _esperaBusqueda?.cancel();
    state = state.copyWith(sugerencias: const [], buscandoSugerencias: false);
  }

  /// Lleva el mapa a la dirección elegida.
  ///
  /// El detalle de Places trae la coordenada **y** la dirección formateada, así
  /// que no hay que geocodificar de vuelta: se escribe la que el usuario acaba
  /// de leer en la lista, que es la que espera ver en el campo.
  Future<void> elegirSugerencia(SugerenciaDireccion sugerencia) async {
    limpiarBusqueda();

    final detalle = await _direcciones.detalle(
      sugerencia.placeId,
      sesion: _sesionDeBusqueda,
    );
    if (!_vivo) return;

    // El token de sesión muere con el detalle: la próxima búsqueda es otra
    // sesión para Google.
    _sesionDeBusqueda = ServicioDirecciones.nuevoTokenDeSesion();

    if (detalle == null) {
      state = state.copyWith(
        aviso: 'No pudimos ubicar esa dirección. Probá con otra o marcá el '
            'punto en el mapa.',
      );
      return;
    }

    _moverCamara(
      detalle.lat,
      detalle.lng,
      direccion: detalle.direccion.isEmpty
          ? sugerencia.completo
          : detalle.direccion,
    );
  }

  // ---------------------------------------------------------------------------
  // Mi ubicación
  // ---------------------------------------------------------------------------

  /// La pide el usuario tocando el botón: acá sí se muestra el diálogo del
  /// sistema, y si dice que no, el aviso lo explica y el mapa sigue donde
  /// estaba.
  Future<void> irAMiUbicacion() async {
    state = state.copyWith(localizando: true, aviso: null);

    final resultado = await _dispositivo.actual();
    if (!_vivo) return;

    switch (resultado) {
      case PosicionObtenida(:final lat, :final lng):
        state = state.copyWith(localizando: false);
        _moverCamara(lat, lng);
        // No hay dirección formateada para una coordenada del GPS: hay que
        // pedirla, y sin esperar el debounce porque el movimiento no fue un
        // arrastre.
        unawaited(_resolverDireccion());
      case SinPosicion(:final mensaje):
        state = state.copyWith(localizando: false, aviso: mensaje);
    }
  }

  Future<void> _centrarSiYaHayPermiso() async {
    final posicion = await _dispositivo.actualSiYaHayPermiso();
    if (posicion == null || !_vivo) return;

    _moverCamara(posicion.lat, posicion.lng);
    unawaited(_resolverDireccion());
  }

  // ---------------------------------------------------------------------------
  // Interno
  // ---------------------------------------------------------------------------

  /// Mueve el punto y le avisa al widget que encuadre el mapa ahí.
  ///
  /// El `_movimientoPropio` que se levanta acá lo baja el `onCameraIdle` que
  /// llega cuando la animación termina; hasta entonces ese `idle` no vale como
  /// gesto del usuario.
  void _moverCamara(double lat, double lng, {String? direccion}) {
    _esperaGeocodificacion?.cancel();
    _movimientoPropio = true;

    state = state.copyWith(
      lat: lat,
      lng: lng,
      direccionTexto: direccion ?? state.direccionTexto,
      objetivo: ObjetivoCamara(
        lat: lat,
        lng: lng,
        sello: (state.objetivo?.sello ?? 0) + 1,
      ),
    );
  }
}
