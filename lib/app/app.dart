import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notificaciones/data/registro_push.dart';
import '../features/notificaciones/data/servicio_push.dart';
import 'router.dart';
import 'theme.dart';

/// Deja mostrar un `SnackBar` desde fuera de la jerarquía de `Scaffold` —acá,
/// desde el `ref.listen` de un aviso push que puede llegar con la app en
/// cualquier pantalla—, sin tener que pasar un `BuildContext` de por medio.
final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

    // Con la app en primer plano, FCM no muestra nada solo (ver
    // `ServicioPushFirebase.avisosEnPrimerPlano`): sin este `listen`, una
    // alerta que llega mientras se mira la pantalla no se nota nunca.
    ref.listen(avisosEnPrimerPlanoProvider, (_, siguiente) {
      final aviso = siguiente.valueOrNull;
      if (aviso == null) return;

      _scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('${aviso.titulo}: ${aviso.cuerpo}'),
          action: aviso.pedidoId == null
              ? null
              : SnackBarAction(
                  label: 'Ver',
                  onPressed: () => router.go('/pedidos/${aviso.pedidoId}'),
                ),
        ));
    });

    return MaterialApp.router(
      title: 'Laburito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      routerConfig: router,
      scaffoldMessengerKey: _scaffoldMessengerKey,
    );
  }
}
