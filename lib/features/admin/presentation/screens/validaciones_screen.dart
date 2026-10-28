import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/validaciones_repository.dart';
import '../widgets/dialogos_admin.dart';
import 'panel_admin.dart';

/// CU-35 — Validar Identidad Profesional (Figura 3.21): la lista de los que
/// esperan a la izquierda y el detalle con las fotos y los datos del registro
/// a la derecha. En pantallas angostas, el detalle va abajo.
class ValidacionesScreen extends ConsumerStatefulWidget {
  const ValidacionesScreen({super.key});

  @override
  ConsumerState<ValidacionesScreen> createState() => _ValidacionesScreenState();
}

class _ValidacionesScreenState extends ConsumerState<ValidacionesScreen> {
  String? _elegido;
  bool _resolviendo = false;

  Future<void> _resolver(ProfesionalEnRevision p, {required bool aprobar}) async {
    String? motivo;
    if (aprobar) {
      final ok = await confirmarAccion(
        context,
        titulo: 'Aprobar a ${p.nombreCompleto}',
        mensaje: 'La cuenta queda verificada y las fotos del documento se '
            'eliminan del servidor.',
        confirmar: 'Aprobar cuenta',
      );
      if (!ok) return;
    } else {
      // Flujo alterno 1.2: «solicitar un motivo por escrito».
      motivo = await pedirTexto(
        context,
        titulo: 'Rechazar la documentación',
        etiqueta: 'Motivo (lo lee el Profesional)',
        ejemplo: 'La foto del frente del DNI está borrosa.',
        confirmar: 'Rechazar',
        minimo: 10,
        maximo: 500,
      );
      if (motivo == null) return;
    }

    setState(() => _resolviendo = true);
    try {
      await ref
          .read(validacionesRepositoryProvider)
          .resolver(p, aprobar: aprobar, motivo: motivo);
      ref.invalidate(profesionalesEnRevisionProvider);
      if (!mounted) return;
      setState(() => _elegido = null);
      mostrarMensaje(
        context,
        aprobar
            ? '${p.nombreCompleto} quedó verificado. Le avisamos por la app.'
            : 'Documentación rechazada. Le avisamos el motivo por la app.',
        esError: false,
      );
    } catch (e) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(e));
    } finally {
      if (mounted) setState(() => _resolviendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = ref.watch(profesionalesEnRevisionProvider);

    return PanelAdmin(
      actual: SeccionAdmin.validaciones,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(profesionalesEnRevisionProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const EncabezadoAdmin(
              titulo: 'Validación de identidad',
              bajada: 'Revisá la documentación de los profesionales pendientes',
            ),
            const SizedBox(height: 20),
            ...lista.when(
              loading: () => const [Center(child: CircularProgressIndicator())],
              error: (e, _) => [
                AvisoEstado.riesgo(
                  icono: Icons.error_outline,
                  titulo: 'No pudimos cargar las validaciones',
                  detalle: MensajesError.desde(e),
                ),
              ],
              data: (pendientes) {
                if (pendientes.isEmpty) {
                  return const [
                    AvisoEstado.exito(
                      icono: Icons.verified_outlined,
                      titulo: 'No hay documentación pendiente',
                      detalle: 'Cuando un Profesional suba su DNI y su selfie, '
                          'aparece acá.',
                    ),
                  ];
                }
                final actual = pendientes.firstWhere(
                  (p) => p.id == _elegido,
                  orElse: () => pendientes.first,
                );
                final listado = _Listado(
                  pendientes: pendientes,
                  elegido: actual.id,
                  onElegir: (id) => setState(() => _elegido = id),
                );
                final detalle = _Detalle(
                  profesional: actual,
                  resolviendo: _resolviendo,
                  onAprobar: () => _resolver(actual, aprobar: true),
                  onRechazar: () => _resolver(actual, aprobar: false),
                );
                return [
                  LayoutBuilder(
                    builder: (context, r) => r.maxWidth >= 860
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 300, child: listado),
                              const SizedBox(width: 20),
                              Expanded(child: detalle),
                            ],
                          )
                        : Column(
                            children: [
                              listado,
                              const SizedBox(height: 20),
                              detalle,
                            ],
                          ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Listado extends StatelessWidget {
  const _Listado({
    required this.pendientes,
    required this.elegido,
    required this.onElegir,
  });

  final List<ProfesionalEnRevision> pendientes;
  final String elegido;
  final ValueChanged<String> onElegir;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('En revisión · ${pendientes.length}',
            style: const TextStyle(
                color: Colores.textoSecundario, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final p in pendientes)
          TarjetaSeleccionable(
            key: Key('validacion-${p.id}'),
            seleccionada: p.id == elegido,
            titulo: p.nombreCompleto,
            bajada: [
              if (p.oficios != null) p.oficios!,
              if (p.enviadoAt != null) Fechas.hace(p.enviadoAt!.toLocal()),
            ].join(' · '),
            onTap: () => onElegir(p.id),
          ),
      ],
    );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle({
    required this.profesional,
    required this.resolviendo,
    required this.onAprobar,
    required this.onRechazar,
  });

  final ProfesionalEnRevision profesional;
  final bool resolviendo;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  static const _documentos = [
    ('dni_frente', 'Frente del DNI'),
    ('dni_dorso', 'Dorso del DNI'),
    ('selfie', 'Selfie'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = profesional;

    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final (tipo, titulo) in _documentos)
                SizedBox(
                  width: 260,
                  child: _Foto(titulo: titulo, ruta: p.documentos[tipo]),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [
              DatoAdmin(etiqueta: 'Nombre', valor: p.nombreCompleto),
              DatoAdmin(etiqueta: 'DNI', valor: p.dni ?? '—'),
              DatoAdmin(etiqueta: 'Correo', valor: p.email),
              DatoAdmin(etiqueta: 'Teléfono', valor: p.telefono ?? '—'),
              DatoAdmin(etiqueta: 'Oficios', valor: p.oficios ?? '—'),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                key: const Key('aprobar-cuenta'),
                style: FilledButton.styleFrom(backgroundColor: Colores.exito),
                onPressed: resolviendo ? null : onAprobar,
                icon: const Icon(Icons.check),
                label: const Text('Aprobar cuenta'),
              ),
              OutlinedButton.icon(
                key: const Key('rechazar-cuenta'),
                style: OutlinedButton.styleFrom(foregroundColor: Colores.error),
                onPressed: resolviendo ? null : onRechazar,
                icon: const Icon(Icons.close),
                label: const Text('Rechazar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Foto extends ConsumerWidget {
  const _Foto({required this.titulo, required this.ruta});

  final String titulo;
  final String? ruta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget marco(Widget hijo) => ClipRRect(
          borderRadius: BorderRadius.circular(Medidas.radio),
          child: Container(
            height: 160,
            color: Colores.neutroSuave,
            alignment: Alignment.center,
            child: hijo,
          ),
        );

    final contenido = ruta == null
        ? marco(const Text('No la subió',
            style: TextStyle(color: Colores.textoTenue)))
        : ref.watch(urlDocumentoAdminProvider(ruta!)).when(
              loading: () => marco(const CircularProgressIndicator()),
              error: (e, _) => marco(const Icon(Icons.broken_image_outlined)),
              data: (url) => InkWell(
                // Paso 4: «en alta resolución». Tocarla la abre grande.
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => Dialog(
                    child: InteractiveViewer(child: Image.network(url)),
                  ),
                ),
                child: marco(Image.network(url,
                    fit: BoxFit.cover, width: double.infinity)),
              ),
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colores.textoSecundario)),
        const SizedBox(height: 6),
        contenido,
      ],
    );
  }
}
