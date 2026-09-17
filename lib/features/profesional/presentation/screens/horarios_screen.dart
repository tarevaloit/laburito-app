import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../domain/horario_atencion.dart';
import '../controllers/horarios_controller.dart';

/// CU-44 — Gestionar Horarios de Atención y estado de disponibilidad.
///
/// Dos cosas distintas en una pantalla, a propósito: el interruptor dice si
/// **hoy** estás tomando trabajo —y es lo que decide si te llegan alertas
/// (migración 0019)— y la grilla dice en qué horarios atendés habitualmente,
/// que es información del perfil.
class HorariosScreen extends ConsumerWidget {
  const HorariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilCompletoProvider);
    final horariosAsync = ref.watch(horariosProvider);
    final controlador = ref.read(horariosProvider.notifier);

    ref.listen(horariosProvider, (_, siguiente) {
      final estado = siguiente.valueOrNull;
      final mensaje = estado?.error ?? estado?.aviso;
      if (mensaje == null) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensaje)));
      controlador.descartarAviso();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios y disponibilidad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
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
                detalle: 'La disponibilidad decide si te llegan pedidos; una '
                    'cuenta Buscador los publica.',
              ),
            );
          }

          return horariosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No pudimos cargar tus horarios: $e'),
            ),
            data: (estado) => _Contenido(estado: estado),
          );
        },
      ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.estado});

  final EstadoHorarios estado;

  Future<void> _agregar(
    BuildContext context,
    WidgetRef ref,
    int dia,
  ) async {
    final desde = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Desde qué hora',
    );
    if (desde == null || !context.mounted) return;

    final hasta = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (desde.hour + 4) % 24, minute: desde.minute),
      helpText: 'Hasta qué hora',
    );
    if (hasta == null) return;

    final hastaMinutos = hasta.hour * 60 + hasta.minute;

    ref.read(horariosProvider.notifier).agregar(
          HorarioAtencion(
            dia: dia,
            desdeMinutos: desde.hour * 60 + desde.minute,
            // Medianoche elegida como fin es el final del día, no el principio:
            // «22 a 00» es una franja de dos horas, no una de menos cero.
            hastaMinutos:
                hastaMinutos == 0 ? HorarioAtencion.finDelDia : hastaMinutos,
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlador = ref.read(horariosProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              TarjetaPanel(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: estado.disponible,
                  onChanged: controlador.cambiarDisponibilidad,
                  title: const Text(
                    'Estoy disponible',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    estado.disponible
                        ? 'Te llegan los pedidos nuevos de tu zona y de tus oficios.'
                        : 'No vas a recibir alertas hasta que lo vuelvas a prender.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colores.textoSecundario,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Horarios de atención',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colores.azul,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Es lo que ve quien mira tu perfil. No apaga las alertas: para '
                'eso está el interruptor de arriba.',
                style: TextStyle(fontSize: 13, color: Colores.textoSecundario),
              ),
              const SizedBox(height: 12),
              for (var dia = 1; dia <= 7; dia++)
                _Dia(
                  dia: dia,
                  franjas: estado.delDia(dia),
                  puedeAgregar: estado.puedeAgregarEn(dia),
                  onAgregar: () => _agregar(context, ref, dia),
                  onQuitar: controlador.quitar,
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: BotonPrincipal(
              texto: 'Guardar horarios',
              icono: Icons.check_circle_outline,
              cargando: estado.guardando,
              onPressed: estado.puedeGuardar ? controlador.guardar : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dia extends StatelessWidget {
  const _Dia({
    required this.dia,
    required this.franjas,
    required this.puedeAgregar,
    required this.onAgregar,
    required this.onQuitar,
  });

  final int dia;
  final List<HorarioAtencion> franjas;
  final bool puedeAgregar;
  final VoidCallback onAgregar;
  final void Function(HorarioAtencion) onQuitar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TarjetaPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    HorarioAtencion.nombresDeDia[dia - 1],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colores.azul,
                    ),
                  ),
                ),
                if (puedeAgregar)
                  TextButton.icon(
                    onPressed: onAgregar,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar'),
                  ),
              ],
            ),
            if (franjas.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Cerrado',
                  style: TextStyle(color: Colores.textoTenue),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final franja in franjas)
                    InputChip(
                      label: Text(franja.rangoLegible),
                      onDeleted: () => onQuitar(franja),
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
