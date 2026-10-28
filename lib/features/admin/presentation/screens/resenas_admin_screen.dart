import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../reputacion/data/resenas_repository.dart';
import '../../../reputacion/presentation/widgets/estrellas.dart';
import '../widgets/dialogos_admin.dart';
import 'panel_admin.dart';

/// CU-46 — Moderar Reseñas: la sección «Moderación de comentarios» del panel.
/// Lista las reseñas reportadas por los Profesionales o marcadas por el
/// filtro automático (paso 2), con quién la escribió y quién la recibió
/// (paso 4).
class ResenasAdminScreen extends ConsumerStatefulWidget {
  const ResenasAdminScreen({super.key});

  @override
  ConsumerState<ResenasAdminScreen> createState() => _ResenasAdminScreenState();
}

class _ResenasAdminScreenState extends ConsumerState<ResenasAdminScreen> {
  bool _incluirResueltas = false;

  Future<void> _moderar(Resena r, {required bool eliminar}) async {
    final ok = await confirmarAccion(
      context,
      titulo: eliminar ? 'Eliminar la reseña' : 'Mantener la reseña',
      mensaje: eliminar
          ? 'Deja de mostrarse en el perfil público, se recalcula el promedio '
              'de ${r.profesional ?? 'el Profesional'} y se le avisa al autor.'
          : 'El reporte se desestima y la reseña queda intacta en el perfil.',
      confirmar: eliminar ? 'Eliminar reseña' : 'Mantener',
      destructiva: eliminar,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(resenasRepositoryProvider).moderar(r.id, eliminar: eliminar);
      ref.invalidate(resenasAModerarProvider);
      if (mounted) {
        mostrarMensaje(
          context,
          eliminar ? 'Reseña eliminada y promedio recalculado.' : 'Reseña mantenida.',
          esError: false,
        );
      }
    } catch (e) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final resenas = ref.watch(resenasAModerarProvider(_incluirResueltas));

    return PanelAdmin(
      actual: SeccionAdmin.resenas,
      child: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(resenasAModerarProvider(_incluirResueltas).future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const EncabezadoAdmin(
              titulo: 'Moderación de comentarios',
              bajada: 'Reseñas reportadas o detectadas por el filtro automático',
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _incluirResueltas,
              onChanged: (v) => setState(() => _incluirResueltas = v),
              title: const Text('Mostrar también las ya moderadas'),
            ),
            const SizedBox(height: 8),
            ...resenas.when(
              loading: () => const [Center(child: CircularProgressIndicator())],
              error: (e, _) => [
                AvisoEstado.riesgo(
                  icono: Icons.error_outline,
                  titulo: 'No pudimos cargar las reseñas',
                  detalle: MensajesError.desde(e),
                ),
              ],
              data: (lista) => lista.isEmpty
                  ? const [
                      AvisoEstado.exito(
                        icono: Icons.rate_review_outlined,
                        titulo: 'No hay reseñas para moderar',
                        detalle: 'Cuando un Profesional reporte una reseña o el '
                            'filtro marque una, aparece acá.',
                      ),
                    ]
                  : [
                      for (final r in lista) ...[
                        _Tarjeta(
                          resena: r,
                          onEliminar: () => _moderar(r, eliminar: true),
                          onMantener: () => _moderar(r, eliminar: false),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.resena,
    required this.onEliminar,
    required this.onMantener,
  });

  final Resena resena;
  final VoidCallback onEliminar;
  final VoidCallback onMantener;

  @override
  Widget build(BuildContext context) {
    final r = resena;
    return TarjetaPanel(
      key: Key('moderar-${r.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Estrellas(valor: r.puntaje.toDouble()),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${r.autor} calificó a ${r.profesional ?? 'un Profesional'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: Colores.texto),
                ),
              ),
              if (r.revisionAutomatica)
                const Pildora(
                    texto: 'Filtro automático',
                    color: Colores.naranjaOscuro,
                    fondo: Colores.naranjaSuave),
              if (r.reportada) ...[
                const SizedBox(width: 6),
                const Pildora(
                    texto: 'Reportada',
                    color: Colores.error,
                    fondo: Colores.errorSuave),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text('«${r.comentario ?? 'Sin comentario'}»',
              style: const TextStyle(color: Colores.texto, height: 1.4)),
          const SizedBox(height: 8),
          Text(
            [
              if (r.pedidoTitulo != null) 'Pedido: ${r.pedidoTitulo}',
              Fechas.corta(r.fecha.toLocal()),
            ].join(' · '),
            style: const TextStyle(color: Colores.textoSecundario, fontSize: 13),
          ),
          if (r.reporteMotivo != null) ...[
            const SizedBox(height: 8),
            Text('Motivo del Profesional: ${r.reporteMotivo}',
                style: const TextStyle(color: Colores.textoSecundario)),
          ],
          const SizedBox(height: 12),
          if (r.pendienteDeModeracion)
            Wrap(
              spacing: 12,
              children: [
                FilledButton(
                  key: Key('eliminar-${r.id}'),
                  style: FilledButton.styleFrom(backgroundColor: Colores.error),
                  onPressed: onEliminar,
                  child: const Text('Eliminar reseña'),
                ),
                OutlinedButton(
                  key: Key('mantener-${r.id}'),
                  onPressed: onMantener,
                  child: const Text('Mantener'),
                ),
              ],
            )
          else
            Text(
              r.moderacion == 'eliminada' ? 'Eliminada' : 'Mantenida',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colores.textoSecundario),
            ),
        ],
      ),
    );
  }
}
