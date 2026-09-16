import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../domain/foto_portafolio.dart';
import '../controllers/portafolio_controller.dart';

/// CU-06 — Cargar Portafolio.
///
/// Mismo camino de código de imágenes que el CU-09 (DNI) y el CU-13 (fotos del
/// pedido): `image_picker` con `maxWidth: 1600` y `imageQuality: 80`, bytes en
/// memoria y un solo camino para Web y Android. Sin herramienta de compresión
/// aparte.
class PortafolioScreen extends ConsumerWidget {
  const PortafolioScreen({super.key});

  Future<void> _agregar(BuildContext context, WidgetRef ref) async {
    final archivo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (archivo == null) return;

    final bytes = await archivo.readAsBytes();
    await ref.read(portafolioProvider.notifier).agregar(bytes);
  }

  Future<void> _confirmarBorrado(
    BuildContext context,
    WidgetRef ref,
    FotoPortafolio foto,
  ) async {
    final borrar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar esta foto'),
        content: const Text(
          'Se elimina del portafolio y no se puede recuperar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (borrar ?? false) {
      await ref.read(portafolioProvider.notifier).eliminar(foto);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilCompletoProvider);
    final portafolioAsync = ref.watch(portafolioProvider);

    ref.listen(portafolioProvider, (_, siguiente) {
      final error = siguiente.valueOrNull?.error;
      if (error == null) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      ref.read(portafolioProvider.notifier).descartarError();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Mi portafolio')),
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
                detalle: 'El portafolio es lo que mira quien te va a contratar.',
              ),
            );
          }

          return portafolioAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No pudimos cargar tu portafolio: $e'),
            ),
            data: (estado) => _Galeria(
              estado: estado,
              onAgregar: () => _agregar(context, ref),
              onBorrar: (foto) => _confirmarBorrado(context, ref, foto),
            ),
          );
        },
      ),
    );
  }
}

class _Galeria extends StatelessWidget {
  const _Galeria({
    required this.estado,
    required this.onAgregar,
    required this.onBorrar,
  });

  final EstadoPortafolio estado;
  final VoidCallback onAgregar;
  final void Function(FotoPortafolio) onBorrar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${estado.fotos.length} de ${FotoPortafolio.maximoPorProfesional} fotos',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colores.azul,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Mostrá trabajos terminados: es lo primero que mira quien está '
          'decidiendo a quién llamar.',
          style: TextStyle(fontSize: 13, color: Colores.textoSecundario),
        ),
        const SizedBox(height: 16),
        if (estado.fotos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 48, color: Colores.textoTenue),
                SizedBox(height: 12),
                Text(
                  'Todavía no cargaste ninguna foto.',
                  style: TextStyle(color: Colores.textoSecundario),
                ),
              ],
            ),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              for (final foto in estado.fotos)
                _Foto(
                  url: estado.urls[foto.storagePath],
                  onBorrar: estado.trabajando ? null : () => onBorrar(foto),
                ),
            ],
          ),
        const SizedBox(height: 20),
        if (estado.puedeAgregar)
          OutlinedButton.icon(
            onPressed: onAgregar,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Agregar una foto'),
          )
        else if (estado.trabajando)
          const Center(child: CircularProgressIndicator())
        else
          const AvisoEstado.pendiente(
            icono: Icons.info_outline,
            titulo: 'Llegaste al máximo',
            detalle: 'Son hasta 10 fotos. Borrá alguna para subir otra.',
          ),
      ],
    );
  }
}

class _Foto extends StatelessWidget {
  const _Foto({required this.url, required this.onBorrar});

  final String? url;
  final VoidCallback? onBorrar;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Medidas.radioGrande),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colores.azulSuave,
            child: url == null
                ? const Center(child: CircularProgressIndicator())
                : Image.network(url!, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                iconSize: 18,
                tooltip: 'Borrar foto',
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onBorrar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
