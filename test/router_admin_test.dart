import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laburito/app/router.dart';

/// Regresión del 01/10: el `redirect` de la ruta padre `/admin` corría también
/// al navegar a `/admin/cupones` y devolvía siempre a la primera sección.
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
            GoRoute(
                path: 'dashboard',
                pageBuilder: (_, s) => paginaDelPanel(s, const Text('dashboard'))),
            GoRoute(
                path: 'precios',
                pageBuilder: (_, s) => paginaDelPanel(s, const Text('precios'))),
            GoRoute(
                path: 'cupones',
                pageBuilder: (_, s) => paginaDelPanel(s, const Text('cupones'))),
          ],
        ),
      ],
    );
    await t.pumpWidget(MaterialApp.router(routerConfig: router));
    return router;
  }

  testWidgets('/admin/cupones abre Cupones, no el Dashboard', (t) async {
    final router = await montar(t);

    router.go('/admin/cupones');
    await t.pumpAndSettle();

    expect(find.text('cupones'), findsOneWidget);
  });

  testWidgets('/admin a secas lleva al Dashboard (CU-34, paso 6)', (t) async {
    final router = await montar(t);

    router.go('/admin');
    await t.pumpAndSettle();

    expect(find.text('dashboard'), findsOneWidget);
  });

  // Regresión del 28/10: cambiar de sección animaba una pantalla nueva, cuando
  // la barra lateral es la misma y solo cambia el contenido.
  testWidgets('cambiar de sección no anima: en el primer cuadro ya está',
      (t) async {
    final router = await montar(t);
    router.go('/admin/dashboard');
    await t.pumpAndSettle();

    router.go('/admin/cupones');
    await t.pump();

    expect(find.text('cupones'), findsOneWidget);
    expect(find.text('dashboard'), findsNothing);
  });
}
