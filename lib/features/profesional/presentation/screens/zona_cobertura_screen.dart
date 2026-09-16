import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/colores.dart';
import '../../../../core/mapas/mapa_config.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../pedidos/presentation/widgets/selector_ubicacion.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../domain/zona_cobertura.dart';
import '../controllers/zona_cobertura_controller.dart';

/// Zoom que deja el círculo entero a la vista.
///
/// Se calcula en vez de usar una constante porque el radio va de 1 a 100 km:
/// con el zoom fijo del detalle, una zona de 50 km no entra en la pantalla y
/// una de 1 km se ve como un punto. Cada paso de zoom duplica la escala, así
/// que la relación es logarítmica.
///
/// Es de nivel superior, y no un método de la pantalla, para poder probarlo
/// sin levantar un widget.
double zoomParaRadio(int radioMetros) {
  final km = math.max(radioMetros / 1000, 0.5);
  return (14 - math.log(km) / math.ln2).clamp(6.0, 15.0);
}

/// CU-07 — Configurar Zona de Cobertura.
///
/// Reutiliza el `SelectorUbicacion` del CU-16 **sin tocarlo**: el centro se
/// elige en esa pantalla, que ya resuelve la búsqueda de direcciones, «usar mi
/// ubicación» y la geocodificación inversa. Acá el mapa es de solo lectura y
/// agrega lo único propio del caso de uso: el círculo del radio y el
/// deslizador que lo mueve.
///
/// El rol se valida **adentro de la pantalla** y no en el `redirect` del
/// router, por la misma razón que el CU-13: `perfilCompletoProvider` es
/// asíncrono y el redirect de go_router necesita una respuesta síncrona.
class ZonaCoberturaScreen extends ConsumerStatefulWidget {
  const ZonaCoberturaScreen({super.key});

  @override
  ConsumerState<ZonaCoberturaScreen> createState() =>
      _ZonaCoberturaScreenState();
}

class _ZonaCoberturaScreenState extends ConsumerState<ZonaCoberturaScreen> {
  GoogleMapController? _mapa;

  /// `null` mientras se resuelve; después, si el SDK quedó disponible.
  bool? _mapaListo;

  /// Última zona encuadrada, para no reanimar la cámara en cada rebuild: el
  /// deslizador dispara uno por cada pixel que se arrastra.
  String? _encuadre;

  @override
  void initState() {
    super.initState();
    MapaConfig.asegurarSdk().then((listo) {
      if (mounted) setState(() => _mapaListo = listo);
    });
  }

  void _encuadrar(EstadoZonaCobertura estado) {
    final centro = estado.centro;
    if (centro == null || _mapa == null) return;

    final sello = '${centro.lat},${centro.lng},${estado.radioMetros}';
    if (sello == _encuadre) return;
    _encuadre = sello;

    _mapa!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(centro.lat, centro.lng),
        zoomParaRadio(estado.radioMetros),
      ),
    );
  }

  Future<void> _elegirCentro(EstadoZonaCobertura estado) async {
    final elegida = await abrirSelectorUbicacion(
      context,
      inicial: estado.centro,
    );
    if (!mounted) return;
    ref.read(zonaCoberturaControladorProvider.notifier).elegirCentro(elegida);
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilCompletoProvider);
    final zonaAsync = ref.watch(zonaCoberturaControladorProvider);
    final controlador = ref.read(zonaCoberturaControladorProvider.notifier);

    ref.listen(zonaCoberturaControladorProvider, (anterior, siguiente) {
      final estado = siguiente.valueOrNull;
      if (estado == null) return;

      final mensaje = estado.error ??
          (estado.guardado ? 'Guardamos tu zona de cobertura.' : null);
      if (mensaje == null) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensaje)));
      controlador.descartarAviso();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Zona de cobertura')),
      body: perfilAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('No pudimos cargar tu perfil.')),
        data: (perfil) {
          if (perfil == null || !perfil.esProfesional) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: AvisoEstado.riesgo(
                icono: Icons.info_outline,
                titulo: 'Esta sección es para cuentas Profesional',
                detalle: 'La zona de cobertura decide qué pedidos te llegan '
                    'como alerta. Una cuenta Buscador no la necesita.',
              ),
            );
          }

          return zonaAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No pudimos cargar tu zona: $e'),
            ),
            data: (estado) => _contenido(estado, controlador),
          );
        },
      ),
    );
  }

  Widget _contenido(
    EstadoZonaCobertura estado,
    ZonaCoberturaControlador controlador,
  ) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(child: _areaMapa(estado)),
          _panelInferior(estado, controlador),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mapa
  // ---------------------------------------------------------------------------

  Widget _areaMapa(EstadoZonaCobertura estado) {
    if (_mapaListo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final centro = estado.centro;

    if (centro == null) {
      return Container(
        color: Colores.azulSuave,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore, size: 44, color: Colores.azul),
            SizedBox(height: 12),
            Text(
              'Todavía no elegiste desde dónde trabajás.\nMarcá el centro de '
              'tu zona y elegí hasta qué distancia querés ir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colores.textoSecundario),
            ),
          ],
        ),
      );
    }

    if (_mapaListo == false) {
      // Sin mapa la pantalla sigue siendo usable: la dirección se eligió en el
      // selector, que también funciona sin SDK, y el radio es un deslizador.
      return Container(
        color: Colores.azulSuave,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined,
                size: 40, color: Colores.textoSecundario),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar el mapa. Tu zona igual queda guardada: '
              '${centro.direccionTexto}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colores.textoSecundario),
            ),
          ],
        ),
      );
    }

    final punto = LatLng(centro.lat, centro.lng);
    _encuadrar(estado);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: punto,
        zoom: zoomParaRadio(estado.radioMetros),
      ),
      onMapCreated: (controlador) {
        _mapa = controlador;
        _encuadrar(estado);
      },
      markers: {Marker(markerId: const MarkerId('centro'), position: punto)},
      circles: {
        Circle(
          circleId: const CircleId('zona'),
          center: punto,
          radius: estado.radioMetros.toDouble(),
          fillColor: Colores.naranja.withValues(alpha: 0.15),
          strokeColor: Colores.naranja,
          strokeWidth: 2,
        ),
      },
      // El centro se mueve en el selector, no arrastrando este mapa: así hay
      // un solo lugar donde se elige una ubicación en todo el proyecto.
      scrollGesturesEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
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
    EstadoZonaCobertura estado,
    ZonaCoberturaControlador controlador,
  ) {
    final centro = estado.centro;

    return Container(
      color: Colores.superficie,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: estado.guardando ? null : () => _elegirCentro(estado),
            icon: const Icon(Icons.place_outlined),
            label: Text(
              centro == null ? 'Elegir el centro' : 'Cambiar el centro',
            ),
          ),
          if (centro != null) ...[
            const SizedBox(height: 12),
            Text(
              centro.direccionTexto,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Distancia máxima'),
                Text(
                  estado.radioLegible,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colores.azul,
                  ),
                ),
              ],
            ),
            Slider(
              value: estado.radioKm.clamp(
                ZonaCobertura.radioMinimoKm,
                ZonaCobertura.radioMaximoKm,
              ),
              min: ZonaCobertura.radioMinimoKm,
              max: ZonaCobertura.radioMaximoKm,
              // Un paso por kilómetro: 99 posiciones, suficientes para el
              // arrastre y sin decimales que no se puedan repetir a mano.
              divisions: (ZonaCobertura.radioMaximoKm -
                      ZonaCobertura.radioMinimoKm)
                  .round(),
              label: estado.radioLegible,
              onChanged:
                  estado.guardando ? null : controlador.cambiarRadioKm,
            ),
            const Text(
              'Te van a llegar los pedidos publicados dentro de este círculo, '
              'de los oficios que tengas cargados.',
              style: TextStyle(
                fontSize: 13,
                color: Colores.textoSecundario,
              ),
            ),
          ],
          const SizedBox(height: 16),
          BotonPrincipal(
            texto: estado.esPrimeraVez ? 'Guardar mi zona' : 'Guardar cambios',
            icono: Icons.check_circle_outline,
            cargando: estado.guardando,
            onPressed: estado.puedeGuardar ? controlador.guardar : null,
          ),
        ],
      ),
    );
  }
}
