import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../denuncias/data/denuncias_repository.dart';
import '../../../denuncias/domain/denuncia.dart';
import 'panel_admin.dart';

/// CU-41, paso 6 — La alerta del Panel del Administrador: las denuncias que
/// llegan, las pendientes primero. Resolverlas (suspender, desestimar) es el
/// CU-39 del Sprint 6, sobre esta misma lista.
class DenunciasScreen extends ConsumerWidget {
  const DenunciasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final denuncias = ref.watch(denunciasAdminProvider);

    return PanelAdmin(
      actual: SeccionAdmin.denuncias,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(denunciasAdminProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            EncabezadoAdmin(
              titulo: 'Denuncias',
              bajada: denuncias.valueOrNull == null
                  ? 'Reportes de conducta de Buscadores y Profesionales'
                  : '${denuncias.value!.where((d) => d.pendiente).length} '
                      'pendientes de revisión',
            ),
            const SizedBox(height: 20),
            ...denuncias.when(
              loading: () => const [Center(child: CircularProgressIndicator())],
              error: (e, _) => [
                AvisoEstado.riesgo(
                  icono: Icons.error_outline,
                  titulo: 'No pudimos cargar las denuncias',
                  detalle: MensajesError.desde(e),
                ),
              ],
              data: (lista) => lista.isEmpty
                  ? const [
                      AvisoEstado.exito(
                        icono: Icons.verified_user_outlined,
                        titulo: 'No hay denuncias',
                        detalle: 'Cuando alguien reporte a un usuario, aparece acá.',
                      ),
                    ]
                  : [
                      for (final d in lista) ...[
                        _TarjetaDenuncia(denuncia: d),
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

class _TarjetaDenuncia extends StatelessWidget {
  const _TarjetaDenuncia({required this.denuncia});

  final DenunciaAdmin denuncia;

  String _rol(String tipo) => switch (tipo) {
        'profesional' => 'Profesional',
        'buscador' => 'Buscador',
        'administrador' => 'Administrador',
        _ => tipo,
      };

  @override
  Widget build(BuildContext context) {
    final d = denuncia;

    return TarjetaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_outlined,
                  color: d.pendiente ? Colores.error : Colores.textoTenue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  d.motivo.etiqueta,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colores.texto,
                  ),
                ),
              ),
              Chip(
                label: Text(d.pendiente ? 'Pendiente' : d.estado),
                backgroundColor:
                    d.pendiente ? Colores.errorSuave : Colores.neutroSuave,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${d.denunciante} (${_rol(d.denuncianteTipo)}) reportó a '
            '${d.denunciado} (${_rol(d.denunciadoTipo)})',
            style: const TextStyle(color: Colores.texto),
          ),
          if (d.pedidoTitulo != null)
            Text(
              'Pedido: ${d.pedidoTitulo}',
              style: const TextStyle(color: Colores.textoSecundario, fontSize: 13),
            ),
          const SizedBox(height: 8),
          Text('«${d.descripcion}»'),
          const SizedBox(height: 8),
          Text(
            Fechas.hace(d.creadaAt.toLocal()),
            style: const TextStyle(color: Colores.textoTenue, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
