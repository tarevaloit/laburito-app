import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../data/urls_firmadas.dart';
import '../../domain/pedido_foto.dart';

/// Ícono que representa a un oficio.
///
/// Se usa cuando el pedido no tiene fotos: un cuadrado gris vacío no dice
/// nada, y una llave inglesa sobre un pedido de jardinería tampoco. Los nombres
/// son los del seed de `categorias_oficio` (migración 0001); cualquier otro cae
/// en la herramienta genérica, así que agregar una categoría nueva no rompe
/// nada, solo deja el ícono por defecto hasta que se la agregue acá.
IconData iconoDeCategoria(String? nombre) => switch (nombre) {
      'Plomería' || 'Destapaciones' => Icons.plumbing,
      'Electricidad' => Icons.electrical_services,
      'Gas' => Icons.local_fire_department_outlined,
      'Albañilería' || 'Durlock' => Icons.foundation,
      'Pintura' => Icons.format_paint_outlined,
      'Carpintería' => Icons.carpenter_outlined,
      'Herrería' => Icons.hardware_outlined,
      'Cerrajería' => Icons.vpn_key_outlined,
      'Aire acondicionado' => Icons.ac_unit,
      'Techista' || 'Impermeabilización' => Icons.roofing,
      'Jardinería' => Icons.grass_outlined,
      'Limpieza' => Icons.cleaning_services_outlined,
      'Fletes y mudanzas' => Icons.local_shipping_outlined,
      'Service de electrodomésticos' => Icons.kitchen_outlined,
      'Redes e internet' => Icons.wifi,
      'Cámaras de seguridad' => Icons.videocam_outlined,
      'Colocación de pisos' => Icons.grid_on,
      'Vidriería' => Icons.window_outlined,
      'Tapicería' => Icons.chair_outlined,
      _ => Icons.handyman_outlined,
    };

/// Lo que se muestra donde iría una foto que no hay.
class PlaceholderCategoria extends StatelessWidget {
  const PlaceholderCategoria({
    super.key,
    this.categoriaNombre,
    this.tamanoIcono = 40,
    this.radio,
  });

  final String? categoriaNombre;
  final double tamanoIcono;
  final BorderRadius? radio;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colores.azulSuave,
        borderRadius: radio,
      ),
      alignment: Alignment.center,
      child: Icon(
        iconoDeCategoria(categoriaNombre),
        size: tamanoIcono,
        color: Colores.azul,
      ),
    );
  }
}

/// Carrusel de fotos del pedido, con URLs firmadas.
///
/// Las fotos viven en un bucket privado, así que no se muestran por su ruta:
/// hay que firmarlas. Las pide todas juntas a [UrlsFirmadas] —una sola llamada
/// por pedido— y las cachea hasta que vencen.
///
/// Sin fotos, o si la firma falla, cae en [PlaceholderCategoria]. Una foto que
/// no se puede mostrar nunca deja la pantalla en blanco.
class CarruselFotosPedido extends ConsumerStatefulWidget {
  const CarruselFotosPedido({
    super.key,
    required this.fotos,
    this.categoriaNombre,
    this.alto = 220,
  });

  final List<PedidoFoto> fotos;
  final String? categoriaNombre;
  final double alto;

  @override
  ConsumerState<CarruselFotosPedido> createState() =>
      _CarruselFotosPedidoState();
}

class _CarruselFotosPedidoState extends ConsumerState<CarruselFotosPedido> {
  final _pagina = PageController();
  Map<String, String> _urls = const {};
  int _actual = 0;

  /// Hay un pedido de firmas en vuelo.
  ///
  /// Sin esta bandera, «todavía no llegó la URL» y «la URL no se pudo obtener»
  /// eran el mismo estado —el mapa sin la clave— y la foto quedaba girando
  /// para siempre en vez de caer en el placeholder.
  bool _firmando = false;

  @override
  void initState() {
    super.initState();
    _firmar();
  }

  @override
  void didUpdateWidget(CarruselFotosPedido anterior) {
    super.didUpdateWidget(anterior);
    // Al volver de editar, el pedido puede traer otras fotos.
    if (anterior.fotos.length != widget.fotos.length) _firmar();
  }

  @override
  void dispose() {
    _pagina.dispose();
    super.dispose();
  }

  Future<void> _firmar() async {
    if (widget.fotos.isEmpty) return;

    setState(() => _firmando = true);

    final urls = await ref
        .read(urlsFirmadasProvider)
        .resolver([for (final f in widget.fotos) f.storagePath]);

    if (mounted) {
      setState(() {
        _urls = urls;
        _firmando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(Medidas.radioGrande);

    if (widget.fotos.isEmpty) {
      return SizedBox(
        height: widget.alto,
        child: PlaceholderCategoria(
          categoriaNombre: widget.categoriaNombre,
          tamanoIcono: 56,
          radio: radio,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.alto,
          child: ClipRRect(
            borderRadius: radio,
            child: PageView.builder(
              controller: _pagina,
              itemCount: widget.fotos.length,
              onPageChanged: (i) => setState(() => _actual = i),
              itemBuilder: (context, i) {
                final url = _urls[widget.fotos[i].storagePath];

                if (url == null) {
                  // Mientras se pide la firma, el indicador. Si la firma ya
                  // volvió sin esta ruta, el archivo no está o no se puede
                  // leer: se muestra el placeholder y se ofrece reintentar,
                  // que es lo único accionable desde acá.
                  return Container(
                    color: Colores.azulSuave,
                    alignment: Alignment.center,
                    child: _firmando
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconoDeCategoria(widget.categoriaNombre),
                                size: 40,
                                color: Colores.azul,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No pudimos cargar esta foto',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colores.textoSecundario,
                                ),
                              ),
                              TextButton(
                                onPressed: _firmar,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                  );
                }

                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, _, __) => PlaceholderCategoria(
                    categoriaNombre: widget.categoriaNombre,
                    tamanoIcono: 56,
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.fotos.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.fotos.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Container(
                  width: i == _actual ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _actual ? Colores.naranja : Colores.borde,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
