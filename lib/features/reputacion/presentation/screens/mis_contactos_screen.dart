import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/barra_navegacion.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/reputacion_repository.dart';
import '../../domain/calificacion.dart';
import '../pedir_calificacion.dart';
import '../widgets/estrellas.dart';

/// CU-28 — Mis contactos: los Buscadores cuyo contacto desbloqueó el
/// Profesional (CU-25), con la calificación que dejaron o el botón para
/// pedirla.
///
/// Existe porque el momento de pedir la calificación es «al finalizar el
/// trabajo», cuando el Buscador ya suele haber cerrado el pedido y el detalle
/// del tablero no se muestra más. El contacto pagado sí.
class MisContactosScreen extends ConsumerWidget {
  const MisContactosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactos = ref.watch(misContactosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis contactos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      bottomNavigationBar: BarraNavegacion.siCorresponde(
        actual: SeccionApp.perfil,
        mostrarBilletera: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(misContactosProvider.future),
        child: contactos.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [Text('No pudimos cargar tus contactos: $e')],
          ),
          data: (lista) => lista.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    AvisoEstado.pendiente(
                      icono: Icons.people_outline,
                      titulo: 'Todavía no desbloqueaste ningún contacto',
                      detalle: 'Cuando uses un token en un pedido del tablero, '
                          'el Buscador aparece acá. Al terminar el trabajo, '
                          'desde acá le pedís que te califique.',
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => i == 0
                      ? const Text(
                          'Cuando termines un trabajo, pedile al cliente que '
                          'te califique: le llega un enlace por WhatsApp y '
                          'lo hace sin crear una cuenta.',
                          style: TextStyle(color: Colores.textoSecundario),
                        )
                      : _TarjetaContacto(contacto: lista[i - 1]),
                ),
        ),
      ),
    );
  }
}

class _TarjetaContacto extends ConsumerStatefulWidget {
  const _TarjetaContacto({required this.contacto});

  final MiContacto contacto;

  @override
  ConsumerState<_TarjetaContacto> createState() => _TarjetaContactoState();
}

class _TarjetaContactoState extends ConsumerState<_TarjetaContacto> {
  bool _trabajando = false;

  Future<void> _pedir() async {
    setState(() => _trabajando = true);
    await pedirCalificacion(context, ref, widget.contacto);
    if (mounted) setState(() => _trabajando = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contacto;
    final fecha = DateFormat('d/M/yyyy').format(c.desbloqueadoAt.toLocal());

    return TarjetaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            c.titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colores.texto,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${c.nombreCorto} · contacto del $fecha',
            style: const TextStyle(color: Colores.textoSecundario, fontSize: 13),
          ),
          const SizedBox(height: 12),
          if (c.calificado)
            Row(
              children: [
                Estrellas(valor: (c.puntaje ?? 0).toDouble()),
                const SizedBox(width: 8),
                const Text(
                  'Ya te calificó',
                  style: TextStyle(color: Colores.exito, fontSize: 13),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              key: Key('pedir-calificacion-${c.pedidoId}'),
              onPressed: _trabajando ? null : _pedir,
              icon: _trabajando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.star_outline_rounded),
              label: const Text('Pedir calificación'),
            ),
        ],
      ),
    );
  }
}
