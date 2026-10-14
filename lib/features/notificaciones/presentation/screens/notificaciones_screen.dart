import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/notificaciones_repository.dart';
import '../../domain/notificacion.dart';

/// CU-48 — Ver Notificaciones de Actividad.
///
/// Orden cronológico, de la más nueva a la más vieja (paso 2). Al abrir, todo
/// queda leído (paso 4), pero lo que estaba sin leer se sigue resaltando
/// mientras la pantalla está abierta: si no, el usuario no sabría qué es
/// nuevo. Tocar un aviso lleva a su pantalla (pasos 5 y 6). «Limpiar todo»
/// borra el historial (flujo alterno).
class NotificacionesScreen extends ConsumerStatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  ConsumerState<NotificacionesScreen> createState() =>
      _NotificacionesScreenState();
}

class _NotificacionesScreenState extends ConsumerState<NotificacionesScreen> {
  /// Los ids que estaban sin leer al abrir. `null` hasta la primera carga.
  Set<String>? _nuevas;

  void _alCargar(List<Notificacion> lista) {
    if (_nuevas != null) return;
    _nuevas = {for (final n in lista) if (!n.leida) n.id};
    if (_nuevas!.isNotEmpty) {
      // Sin bloquear el dibujo: si falla, el contador se corrige solo en la
      // próxima apertura.
      ref.read(notificacionesRepositoryProvider).marcarLeidas().catchError((_) {});
    }
  }

  Future<void> _limpiar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar todo'),
        content: const Text(
            'Se borran todas tus notificaciones. No se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await ref.read(notificacionesRepositoryProvider).limpiar();
      ref.invalidate(notificacionesProvider);
    } catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    }
  }

  void _abrir(Notificacion n) {
    final ruta = n.ruta;
    if (ruta == null) return;
    context.go(ruta);
  }

  @override
  Widget build(BuildContext context) {
    final notificaciones = ref.watch(notificacionesProvider);
    final hay = notificaciones.valueOrNull?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          if (hay)
            TextButton(
              onPressed: _limpiar,
              child: const Text('Limpiar todo'),
            ),
        ],
      ),
      body: notificaciones.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No pudimos cargar tus notificaciones: $e'),
        ),
        data: (lista) {
          _alCargar(lista);

          if (lista.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: AvisoEstado.exito(
                icono: Icons.notifications_none,
                titulo: 'No tenés notificaciones',
                detalle: 'Acá te avisamos cuando un profesional pida tu '
                    'contacto, cuando recibas una calificación o cuando '
                    'cambie el estado de tu cuenta o de un pago.',
              ),
            );
          }

          return ListView.separated(
            itemCount: lista.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = lista[i];
              final nueva = _nuevas?.contains(n.id) ?? !n.leida;
              return ListTile(
                key: Key('notificacion-${n.id}'),
                tileColor: nueva ? Colores.azulSuave : null,
                leading: CircleAvatar(
                  backgroundColor: Colores.superficie,
                  child: Icon(_icono(n.tipo), color: _color(n.tipo)),
                ),
                title: Text(
                  n.titulo,
                  style: TextStyle(
                    fontWeight: nueva ? FontWeight.w700 : FontWeight.w500,
                    color: Colores.texto,
                  ),
                ),
                subtitle: Text(
                  [if ((n.cuerpo ?? '').isNotEmpty) n.cuerpo!, Fechas.hace(n.creadaAt.toLocal())]
                      .join('\n'),
                ),
                isThreeLine: (n.cuerpo ?? '').isNotEmpty,
                trailing: n.ruta == null ? null : const Icon(Icons.chevron_right),
                onTap: n.ruta == null ? null : () => _abrir(n),
              );
            },
          );
        },
      ),
    );
  }

  static IconData _icono(TipoNotificacion tipo) => switch (tipo) {
        TipoNotificacion.nuevoInteresado => Icons.person_add_alt_1_outlined,
        TipoNotificacion.calificacionRecibida => Icons.star_outline_rounded,
        TipoNotificacion.verificacionAprobada => Icons.verified_outlined,
        TipoNotificacion.verificacionRechazada => Icons.report_gmailerrorred,
        TipoNotificacion.pagoAcreditado => Icons.toll,
        TipoNotificacion.denunciaRecibida => Icons.flag_outlined,
        TipoNotificacion.otro => Icons.notifications_outlined,
      };

  static Color _color(TipoNotificacion tipo) => switch (tipo) {
        TipoNotificacion.verificacionRechazada ||
        TipoNotificacion.denunciaRecibida =>
          Colores.error,
        TipoNotificacion.verificacionAprobada => Colores.exito,
        TipoNotificacion.calificacionRecibida ||
        TipoNotificacion.pagoAcreditado =>
          Colores.naranja,
        _ => Colores.azulMedio,
      };
}
