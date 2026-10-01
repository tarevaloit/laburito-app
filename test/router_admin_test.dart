import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laburito/app/router.dart';

/// Regresión del 01/10: el `redirect` de la ruta padre `/admin` corría también
/// al navegar a `/admin/cupones` y devolvía siempre a Precios.
void main() {
  Future<GoRouter> montar(WidgetTester t) async {
    final router = GoRouter(
      initialLocation: '/inicio',
      routes: [
        GoRoute(path: '/inicio', builder: (_, __) => const Text('inicio')),
        GoRoute(
          path: '/admin',
          redirect: redireccionPanelAdmin,
          routes: [
            GoRoute(path: 'precios', builder: (_, __) => const Text('precios')),
            GoRoute(path: 'cupones', builder: (_, __) => const Text('cupones')),
          ],
        ),
      ],
    );
    await t.pumpWidget(MaterialApp.router(routerConfig: router));
    return router;
  }

  testWidgets('/admin/cupones abre Cupones, no Precios', (t) async {
    final router = await montar(t);

    router.go('/admin/cupones');
    await t.pumpAndSettle();

    expect(find.text('cupones'), findsOneWidget);
  });

  testWidgets('/admin a secas lleva a Precios', (t) async {
    final router = await montar(t);

    router.go('/admin');
    await t.pumpAndSettle();

    expect(find.text('precios'), findsOneWidget);
  });
}
