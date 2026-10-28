import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/dialogos.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/resenas_repository.dart';
import '../widgets/estrellas.dart';

/// CU-46, la vía del Profesional: sus reseñas recibidas, con la opción de
/// reportar la que considere falsa u ofensiva y el resultado de la
/// moderación.
class MisResenasScreen extends ConsumerWidget {
  const MisResenasScreen({super.key});

  Future<void> _reportar(BuildContext context, WidgetRef ref, Resena r) async {
    final motivo = await pedirTexto(
      context,
      titulo: 'Reportar esta reseña',
      etiqueta: 'Por qué la reportás',
      ayuda: 'La revisa el equipo de Laburito. Si no cumple las normas de la '
          'comunidad, deja de mostrarse y tu promedio se recalcula.',
      ejemplo: 'El pedido se canceló antes de que yo fuera.',
      confirmar: 'Enviar reporte',
    );
    if (motivo == null || !context.mounted) return;
    try {
      await ref.read(resenasRepositoryProvider).reportar(r.id, motivo);
      ref.invalidate(misResenasProvider);
      if (context.mounted) {
        mostrarMensaje(context, 'Reporte enviado. Te avisamos cuando lo revisemos.',
            esError: false);
      }
    } catch (e) {
      if (context.mounted) mostrarMensaje(context, MensajesError.desde(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resenas = ref.watch(misResenasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reseñas')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(misResenasProvider.future),
        child: resenas.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AvisoEstado.riesgo(
                icono: Icons.error_outline,
                titulo: 'No pudimos cargar tus reseñas',
                detalle: MensajesError.desde(e),
              ),
            ],
          ),
          data: (lista) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (lista.isEmpty)
                const AvisoEstado.pendiente(
                  icono: Icons.star_outline,
                  titulo: 'Todavía no tenés reseñas',
                  detalle: 'Pedí la calificación desde «Mis contactos» cuando '
                      'termines un trabajo.',
                ),
              for (final r in lista) ...[
                TarjetaPanel(
                  key: Key('resena-${r.id}'),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Estrellas(valor: r.puntaje.toDouble()),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${r.autor} · ${Fechas.corta(r.fecha.toLocal())}',
                              style: const TextStyle(
                                  color: Colores.textoSecundario, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      if (r.comentario != null) ...[
                        const SizedBox(height: 8),
                        Text('«${r.comentario}»'),
                      ],
                      const SizedBox(height: 8),
                      _Estado(resena: r),
                      if (r.reportable)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            key: Key('reportar-${r.id}'),
                            onPressed: () => _reportar(context, ref, r),
                            icon: const Icon(Icons.flag_outlined, size: 18),
                            label: const Text('Reportar'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Estado extends StatelessWidget {
  const _Estado({required this.resena});

  final Resena resena;

  @override
  Widget build(BuildContext context) {
    final (texto, color) = switch (resena.moderacion) {
      'eliminada' => ('Eliminada por el equipo: ya no se muestra', Colores.exito),
      'mantenida' => ('Revisada: cumple las normas y sigue publicada', Colores.textoSecundario),
      _ when resena.reportada => ('Reportada: la estamos revisando', Colores.naranjaOscuro),
      _ => ('', Colores.textoSecundario),
    };
    if (texto.isEmpty) return const SizedBox.shrink();
    return Text(texto,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700));
  }
}
