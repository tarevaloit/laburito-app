import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/colores.dart';
import '../../../../core/mapas/mapa_config.dart';
import '../../../../core/mapas/servicio_direcciones.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../domain/ubicacion.dart';
import '../controllers/selector_ubicacion_controller.dart';

/// Abre el selector de ubicación a pantalla completa y devuelve la
/// [Ubicacion] elegida, o `null` si el usuario volvió atrás sin confirmar.
///
/// [inicial] es la ubicación ya cargada cuando se edita un pedido (CU-15); en
/// el alta (CU-13) se llama con `null` y el selector arranca en José C. Paz.
Future<Ubicacion?> abrirSelectorUbicacion(
  BuildContext context, {
  Ubicacion? inicial,
}) {
  return Navigator.of(context).push<Ubicacion>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => SelectorUbicacion(inicial: inicial),
    ),
  );
}

/// CU-16 — Localizar Pedido en Mapa.
///
/// **Por qué el botón «Mi ubicación» y la lista de sugerencias no flotan
/// sobre el mapa.** En Web, `GoogleMap` se dibuja con `HtmlElementView`, y
/// cualquier widget de Flutter apilado arriba necesita el paquete
/// `pointer_interceptor` para recibir el mouse. Se resuelve con una columna
/// —búsqueda arriba, mapa en el medio con solo el pin centrado por encima
/// (que no necesita recibir toques: va con `IgnorePointer`), panel de
/// dirección, referencia y «mi ubicación» abajo— en vez de sumar otra
/// dependencia.
class SelectorUbicacion extends ConsumerStatefulWidget {
  const SelectorUbicacion({super.key, this.inicial});

  final Ubicacion? inicial;

  @override
  ConsumerState<SelectorUbicacion> createState() => _SelectorUbicacionState();
}

class _SelectorUbicacionState extends ConsumerState<SelectorUbicacion> {
  GoogleMapController? _mapa;
  late final TextEditingController _busqueda;
  late final TextEditingController _direccion;
  late final TextEditingController _referencia;

  /// `null` mientras se resuelve; después, si el SDK quedó disponible.
  bool? _mapaListo;

  /// Último `sello` de [ObjetivoCamara] ya aplicado, para no reanimar la
  /// cámara en cada rebuild.
  int _selloAplicado = 0;

  LatLng? _ultimoMovimiento;

  @override
  void initState() {
    super.initState();
    _busqueda = TextEditingController();
    _direccion = TextEditingController(text: widget.inicial?.direccionTexto);
    _referencia = TextEditingController(text: widget.inicial?.referencia);

    MapaConfig.asegurarSdk().then((listo) {
      if (mounted) setState(() => _mapaListo = listo);
    });
  }

  @override
  void dispose() {
    _busqueda.dispose();
    _direccion.dispose();
    _referencia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = selectorUbicacionControllerProvider(widget.inicial);
    final estado = ref.watch(provider);
    final controlador = ref.read(provider.notifier);

    ref.listen(provider, (anterior, siguiente) {
      // La dirección solo se pisa cuando cambió por afuera del campo (una
      // geocodificación inversa o una sugerencia elegida): si el usuario la
      // está escribiendo, `_direccion.text` ya coincide y esta condición es
      // falsa.
      if (siguiente.direccionTexto != _direccion.text) {
        _direccion.text = siguiente.direccionTexto;
      }

      final objetivo = siguiente.objetivo;
      if (objetivo != null && objetivo.sello != _selloAplicado) {
        _selloAplicado = objetivo.sello;
        _mapa?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(objetivo.lat, objetivo.lng),
            MapaConfig.zoomDireccion,
          ),
        );
      }

      if (siguiente.aviso != null && siguiente.aviso != anterior?.aviso) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(siguiente.aviso!)));
        controlador.descartarAviso();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación del pedido')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _campoBusqueda(estado, controlador),
            ),
            if (estado.buscandoSugerencias || estado.sugerencias.isNotEmpty)
              _listaSugerencias(estado, controlador),
            Expanded(child: _areaMapa(estado)),
            _panelInferior(estado, controlador),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Búsqueda
  // ---------------------------------------------------------------------------

  Widget _campoBusqueda(
    EstadoSelectorUbicacion estado,
    SelectorUbicacionController controlador,
  ) {
    return TextField(
      controller: _busqueda,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar dirección',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: estado.buscandoSugerencias
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : (_busqueda.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Borrar búsqueda',
                    onPressed: () {
                      _busqueda.clear();
                      controlador.limpiarBusqueda();
                      setState(() {});
                    },
                  )),
      ),
      onChanged: (texto) {
        controlador.buscar(texto);
        setState(() {});
      },
    );
  }

  Widget _listaSugerencias(
    EstadoSelectorUbicacion estado,
    SelectorUbicacionController controlador,
  ) {
    if (estado.sugerencias.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colores.superficie,
        borderRadius: BorderRadius.circular(Medidas.radio),
        border: Border.all(color: Colores.borde),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: estado.sugerencias.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, indice) {
          final SugerenciaDireccion sugerencia = estado.sugerencias[indice];
          return ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(sugerencia.titulo),
            subtitle:
                sugerencia.detalle.isEmpty ? null : Text(sugerencia.detalle),
            onTap: () {
              _busqueda.clear();
              setState(() {});
              controlador.elegirSugerencia(sugerencia);
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mapa
  // ---------------------------------------------------------------------------

  Widget _areaMapa(EstadoSelectorUbicacion estado) {
    return Stack(
      children: [
        Positioned.fill(child: _mapaOFallback(estado)),
        if (_mapaListo == true)
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: Icon(
                  Icons.location_on,
                  size: 44,
                  color: Colores.naranja,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _mapaOFallback(EstadoSelectorUbicacion estado) {
    if (_mapaListo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mapaListo == false) {
      return Container(
        color: Colores.azulSuave,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 40, color: Colores.textoSecundario),
            SizedBox(height: 12),
            Text(
              'No pudimos cargar el mapa. Escribí la dirección a mano abajo, '
              'o usá tu ubicación.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colores.textoSecundario),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(estado.lat, estado.lng),
        zoom: MapaConfig.zoomDireccion,
      ),
      onMapCreated: (controlador) => _mapa = controlador,
      onCameraMove: (posicion) => _ultimoMovimiento = posicion.target,
      onCameraIdle: () {
        final movimiento = _ultimoMovimiento;
        if (movimiento == null) return;
        ref
            .read(
              selectorUbicacionControllerProvider(widget.inicial).notifier,
            )
            .alQuedarQuietoElMapa(movimiento.latitude, movimiento.longitude);
      },
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Panel inferior
  // ---------------------------------------------------------------------------

  Widget _panelInferior(
    EstadoSelectorUbicacion estado,
    SelectorUbicacionController controlador,
  ) {
    return Container(
      color: Colores.superficie,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: estado.localizando ? null : controlador.irAMiUbicacion,
            icon: estado.localizando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: const Text('Usar mi ubicación'),
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Dirección',
            controller: _direccion,
            ejemplo: 'Calle y altura',
            sufijo: estado.resolviendoDireccion
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            onChanged: controlador.escribirDireccion,
          ),
          const SizedBox(height: 12),
          CampoTexto(
            etiqueta: 'Referencia (opcional)',
            controller: _referencia,
            ejemplo: 'Piso, depto, entre calles',
            onChanged: controlador.escribirReferencia,
          ),
          const SizedBox(height: 16),
          BotonPrincipal(
            texto: 'Confirmar ubicación',
            onPressed: estado.ubicacion == null
                ? null
                : () => Navigator.of(context).pop(estado.ubicacion),
          ),
        ],
      ),
    );
  }
}
