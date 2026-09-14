import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../categorias/data/categorias_repository.dart';
import '../../domain/pedido_estado.dart';
import '../../domain/ubicacion.dart';
import 'selector_ubicacion.dart';

/// Los campos del pedido, sin la pantalla que los contiene.
///
/// Existen porque el CU-15 (editar) pide **los mismos** formularios que el
/// asistente del CU-13 (publicar): mismo orden, mismas etiquetas y —sobre
/// todo— mismas validaciones. Duplicarlos garantizaba que en algún momento el
/// alta aceptara un título de 4 caracteres que la edición rechazara.
///
/// Ninguno guarda estado: reciben el valor y devuelven el cambio. El asistente
/// lo escribe en su `EstadoCrearPedido` y la edición en el suyo.

/// Las reglas de los campos, en un solo lugar.
///
/// Son las mismas de los `check` de la tabla `pedidos` (migración 0005): entre
/// 5 y 80 caracteres el título, entre 20 y 1000 la descripción, presupuesto no
/// negativo. Si acá se aflojan, el error llega igual —lo tira la base— pero
/// como un `23514` que hay que traducir en vez de un mensaje al lado del campo.
class ValidadoresPedido {
  const ValidadoresPedido._();

  static String? titulo(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá un título';
    if (v.length < 5) return 'El título es demasiado corto (mínimo 5)';
    if (v.length > 80) return 'El título es demasiado largo (máximo 80)';
    return null;
  }

  static String? descripcion(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Contá qué necesitás';
    if (v.length < 20) return 'Contá un poco más (mínimo 20 caracteres)';
    if (v.length > 1000) return 'Demasiado largo (máximo 1000 caracteres)';
    return null;
  }

  /// Vacío es válido: el presupuesto es opcional.
  static String? presupuesto(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return null;
    final numero = double.tryParse(v.replaceAll(',', '.'));
    if (numero == null) return 'Ingresá un número válido';
    if (numero < 0) return 'No puede ser negativo';
    return null;
  }

  /// La coma decimal del teclado castellano no la entiende `double.parse`.
  static double? aNumero(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));
}

/// Etiqueta arriba del campo, como en [CampoTexto], para los controles que no
/// son un `TextFormField` (el desplegable de categoría, los chips de urgencia).
class EtiquetaCampo extends StatelessWidget {
  const EtiquetaCampo(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colores.texto,
        ),
      ),
    );
  }
}

/// Qué necesita el Buscador: categoría, título, descripción y urgencia.
///
/// Es el paso 1 del asistente y el bloque de arriba de la edición.
class CamposDatosPedido extends ConsumerWidget {
  const CamposDatosPedido({
    super.key,
    required this.categoriaId,
    required this.titulo,
    required this.descripcion,
    required this.urgencia,
    required this.onCategoria,
    required this.onTitulo,
    required this.onDescripcion,
    required this.onUrgencia,
  });

  final String? categoriaId;
  final String titulo;
  final String descripcion;
  final PedidoUrgencia urgencia;

  final ValueChanged<String?> onCategoria;
  final ValueChanged<String> onTitulo;
  final ValueChanged<String> onDescripcion;
  final ValueChanged<PedidoUrgencia> onUrgencia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasActivasProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaCampo('Categoría'),
        categoriasAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => const Text('No pudimos cargar las categorías.'),
          data: (categorias) => DropdownButtonFormField<String>(
            initialValue: categoriaId,
            hint: const Text('Elegí un oficio'),
            items: [
              for (final c in categorias)
                DropdownMenuItem(value: c.id, child: Text(c.nombre)),
            ],
            onChanged: onCategoria,
          ),
        ),
        const SizedBox(height: 16),
        CampoTexto(
          etiqueta: 'Título',
          initialValue: titulo,
          ejemplo: 'Ej: Se me tapó la cocina',
          maxLength: 80,
          validator: ValidadoresPedido.titulo,
          onChanged: onTitulo,
        ),
        const SizedBox(height: 16),
        CampoTexto(
          etiqueta: 'Descripción',
          initialValue: descripcion,
          ejemplo: 'Contá el problema con el mayor detalle posible',
          maxLines: 4,
          maxLength: 1000,
          validator: ValidadoresPedido.descripcion,
          onChanged: onDescripcion,
        ),
        const SizedBox(height: 16),
        const EtiquetaCampo('Urgencia'),
        Wrap(
          spacing: 8,
          children: [
            for (final u in PedidoUrgencia.values)
              ChoiceChip(
                label: Text(u.etiqueta),
                selected: urgencia == u,
                onSelected: (_) => onUrgencia(u),
              ),
          ],
        ),
      ],
    );
  }
}

/// El presupuesto estimado, que es opcional en el alta y en la edición.
class CampoPresupuesto extends StatelessWidget {
  const CampoPresupuesto({
    super.key,
    required this.valor,
    required this.onCambio,
  });

  final double? valor;
  final ValueChanged<double?> onCambio;

  @override
  Widget build(BuildContext context) {
    return CampoTexto(
      etiqueta: 'Presupuesto estimado (opcional)',
      // Sin decimales cuando son redondos: «15000» y no «15000.0».
      initialValue: valor?.toStringAsFixed(0),
      ejemplo: 'En pesos',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: ValidadoresPedido.presupuesto,
      onChanged: (texto) => onCambio(ValidadoresPedido.aNumero(texto)),
    );
  }
}

/// Una imagen que el usuario acaba de elegir, ya leída a memoria.
class FotoElegida {
  const FotoElegida(this.bytes, this.nombre);

  final Uint8List bytes;

  /// Nombre original del archivo. Solo se usa por su extensión: el repositorio
  /// arma un nombre único al subir.
  final String nombre;
}

/// Cámara o galería, y la imagen ya comprimida.
///
/// La compresión es la misma del CU-09 (DNI y selfie): `maxWidth` de 1600 y
/// calidad 80 de `image_picker`, que es un solo camino de código para Web y
/// Android y no suma una herramienta de compresión aparte.
///
/// Devuelve `null` si el usuario cerró la hoja o no eligió nada.
Future<FotoElegida?> elegirFotoDePedido(BuildContext context) async {
  final origen = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tomar una foto'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (origen == null) return null;

  final archivo = await ImagePicker().pickImage(
    source: origen,
    maxWidth: 1600,
    imageQuality: 80,
  );
  if (archivo == null) return null;

  return FotoElegida(await archivo.readAsBytes(), archivo.name);
}

/// La ubicación elegida, con el botón que abre el selector del CU-16.
///
/// El mapa no se dibuja acá: se abre a pantalla completa y devuelve el punto.
/// En el alta arranca vacío; en la edición muestra la ubicación guardada y el
/// botón dice «Cambiar».
class CampoUbicacion extends StatelessWidget {
  const CampoUbicacion({
    super.key,
    required this.ubicacion,
    required this.onCambio,
  });

  final Ubicacion? ubicacion;
  final ValueChanged<Ubicacion> onCambio;

  @override
  Widget build(BuildContext context) {
    final actual = ubicacion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (actual != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colores.superficie,
              borderRadius: BorderRadius.circular(Medidas.radioGrande),
              border: Border.all(color: Colores.borde),
            ),
            child: Row(
              children: [
                const Icon(Icons.place, color: Colores.naranja),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actual.direccionTexto,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (actual.referencia != null)
                        Text(
                          actual.referencia!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colores.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.map_outlined),
          label: Text(
            actual == null ? 'Marcar ubicación en el mapa' : 'Cambiar ubicación',
          ),
          onPressed: () async {
            final elegida = await abrirSelectorUbicacion(
              context,
              inicial: actual,
            );
            if (elegida != null) onCambio(elegida);
          },
        ),
      ],
    );
  }
}
