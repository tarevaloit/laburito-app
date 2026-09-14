import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/colores.dart';
import '../../../../core/mapas/mapa_config.dart';
import '../../domain/ubicacion.dart';

/// Mapa de solo lectura con el pin del pedido (CU-16, del lado del Buscador).
///
/// No es el `SelectorUbicacion` con los gestos apagados: acá no hay pin
/// centrado ni geocodificación inversa, hay un marcador fijo en la coordenada
/// guardada. Todos los gestos van desactivados a propósito —el detalle es para
/// mirar, no para mover el pedido— y para cambiar la ubicación está el botón
/// «Editar», que abre el selector de verdad.
///
/// Si el SDK no carga (sin clave de Maps, o sin red), muestra la dirección en
/// texto: que no haya mapa no puede dejar la pantalla del pedido a medias.
class MiniMapaPedido extends StatefulWidget {
  const MiniMapaPedido({
    super.key,
    required this.ubicacion,
    this.alto = 180,
  });

  final Ubicacion ubicacion;
  final double alto;

  @override
  State<MiniMapaPedido> createState() => _MiniMapaPedidoState();
}

class _MiniMapaPedidoState extends State<MiniMapaPedido> {
  /// `null` mientras se resuelve; después, si el SDK quedó disponible.
  bool? _listo;

  @override
  void initState() {
    super.initState();
    MapaConfig.asegurarSdk().then((listo) {
      if (mounted) setState(() => _listo = listo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Medidas.radio),
      child: SizedBox(height: widget.alto, child: _contenido()),
    );
  }

  Widget _contenido() {
    if (_listo == null) {
      return Container(
        color: Colores.azulSuave,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_listo == false) {
      return Container(
        color: Colores.azulSuave,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined,
                size: 32, color: Colores.textoSecundario),
            const SizedBox(height: 8),
            Text(
              widget.ubicacion.direccionTexto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colores.textoSecundario),
            ),
          ],
        ),
      );
    }

    final punto = LatLng(widget.ubicacion.lat, widget.ubicacion.lng);

    return GoogleMap(
      initialCameraPosition:
          CameraPosition(target: punto, zoom: MapaConfig.zoomDetalle),
      markers: {
        Marker(markerId: const MarkerId('pedido'), position: punto),
      },
      zoomGesturesEnabled: false,
      scrollGesturesEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }
}
