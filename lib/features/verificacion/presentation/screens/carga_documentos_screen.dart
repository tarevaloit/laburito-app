import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../data/documentos_repository.dart';
import '../controllers/documentos_controller.dart';

/// CU-09 — Validar Documentación: carga del Profesional.
class CargaDocumentosScreen extends ConsumerStatefulWidget {
  const CargaDocumentosScreen({super.key});

  @override
  ConsumerState<CargaDocumentosScreen> createState() =>
      _CargaDocumentosScreenState();
}

class _CargaDocumentosScreenState
    extends ConsumerState<CargaDocumentosScreen> {
  TipoDocumento? _subiendo;

  Future<void> _elegirYSubir(TipoDocumento tipo) async {
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

    if (origen == null) return;

    final archivo = await ImagePicker().pickImage(
      source: origen,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (archivo == null) return;

    setState(() => _subiendo = tipo);

    final bytes = await archivo.readAsBytes();
    final ok = await ref
        .read(documentosControllerProvider.notifier)
        .subir(tipo: tipo, bytes: bytes);

    if (!mounted) return;
    setState(() => _subiendo = null);

    if (ok) {
      mostrarMensaje(context, '${tipo.etiqueta}: cargado.', esError: false);
    } else {
      final error = ref.read(documentosControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargadosAsync = ref.watch(documentosCargadosProvider);
    final perfil = ref.watch(perfilCompletoProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de identidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: cargadosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('No pudimos cargar el estado: $e')),
        data: (cargados) {
          final completo = TipoDocumento.values
              .every((t) => cargados.containsKey(t.clave));

          return TarjetaFormulario(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // El título ya está en la barra superior: acá va solo la
                // consigna, como en la Figura 3.10 del ANEXO UI.
                const MarcaLaburito(
                  altoLogo: 64,
                  subtitulo:
                      'Subí una foto nítida del frente y del dorso de tu DNI, y una '
                      'selfie. Validamos tu identidad para que los buscadores confíen '
                      'en vos. Solo vos y el equipo de Laburito pueden verlas.',
                ),
                const SizedBox(height: 24),
                ...TipoDocumento.values.map(
                  (tipo) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FilaDocumento(
                      tipo: tipo,
                      cargado: cargados.containsKey(tipo.clave),
                      subiendo: _subiendo == tipo,
                      onTap: _subiendo != null
                          ? null
                          : () => _elegirYSubir(tipo),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (completo)
                  AvisoEstado.exito(
                    icono: Icons.hourglass_top_rounded,
                    titulo: perfil?.verificacionLegible ?? 'En revisión',
                    detalle: [
                      if (perfil?.estadoVerificacion != 'aprobado')
                        'Te avisamos apenas se apruebe.',
                      'Tus documentos se eliminan del servidor una vez aprobada '
                          'la validación (Ley 25.326).',
                    ].join(' '),
                  )
                else
                  const AvisoEstado.pendiente(
                    icono: Icons.pending_outlined,
                    titulo: 'Faltan documentos por subir',
                    detalle:
                        'Cuando estén los tres, la revisión arranca automáticamente.',
                  ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilaDocumento extends StatelessWidget {
  const _FilaDocumento({
    required this.tipo,
    required this.cargado,
    required this.subiendo,
    required this.onTap,
  });

  final TipoDocumento tipo;
  final bool cargado;
  final bool subiendo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Medidas.radio),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colores.superficie,
          borderRadius: BorderRadius.circular(Medidas.radio),
          border: Border.all(
            color: cargado ? Colores.exitoBorde : Colores.borde,
          ),
        ),
        child: Row(
          children: [
            Icon(
              cargado
                  ? Icons.check_circle_rounded
                  : Icons.add_photo_alternate_outlined,
              color: cargado ? Colores.exito : Colores.textoTenue,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tipo.etiqueta,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colores.texto,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    cargado ? 'Cargado · tocá para reemplazar' : 'Sin cargar',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colores.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
            if (subiendo)
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.chevron_right, color: Colores.textoTenue),
          ],
        ),
      ),
    );
  }
}
