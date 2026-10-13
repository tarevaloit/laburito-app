import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/notificaciones_repository.dart';

/// CU-48, paso 1: la campana de la barra superior, con la cantidad de avisos
/// sin leer. La comparten la Web del Buscador y la app del Profesional.
class CampanaNotificaciones extends ConsumerWidget {
  const CampanaNotificaciones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sinLeer = ref.watch(notificacionesSinLeerProvider);

    return IconButton(
      key: const Key('campana-notificaciones'),
      tooltip: sinLeer == 0
          ? 'Notificaciones'
          : 'Notificaciones: $sinLeer sin leer',
      onPressed: () => context.push('/notificaciones'),
      icon: Badge(
        isLabelVisible: sinLeer > 0,
        label: Text(sinLeer > 9 ? '9+' : '$sinLeer'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
