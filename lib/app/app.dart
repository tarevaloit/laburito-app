import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notificaciones/data/registro_push.dart';
import '../features/notificaciones/data/servicio_push.dart';
import 'router.dart';
import 'theme.dart';

class LaburitoApp extends ConsumerWidget {
  const LaburitoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // CU-21. Acá y no en una pantalla: el registro del teléfono depende de
    // quién esté adentro, no de dónde esté navegando. `watch` es lo que lo
    // mantiene vivo mientras la app lo esté.
    ref.watch(registroPushProvider);

    // Tocar la notificación abre el pedido. El `listen` vive en la raíz
    // porque la app puede estar en cualquier pantalla —o recién abriéndose—
    // cuando llega.
    ref.listen(pedidosAbiertosProvider, (_, siguiente) {
      final pedidoId = siguiente.valueOrNull;
      if (pedidoId != null && pedidoId.isNotEmpty) {
        router.go('/pedidos/$pedidoId');
      }
    });

    return MaterialApp.router(
      title: 'Laburito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      routerConfig: router,
    );
  }
}
