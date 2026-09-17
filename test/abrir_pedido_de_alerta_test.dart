import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laburito/features/notificaciones/presentation/abrir_pedido_de_alerta.dart';

/// CU-21 — A dónde lleva tocar una alerta, y a dónde se vuelve.
///
/// Es la prueba del error que apareció en el primer uso real: la notificación
/// abría el detalle del **dueño** con un `go`, y al volver no había nada debajo,
/// así que el Profesional caía en «Mis pedidos», que es del Buscador. Ninguna
/// prueba de antes lo agarraba porque todas miraban qué se abría, no qué
/// quedaba abajo.
void main() {
  late GoRouter router;

  Widget pantalla(String nombre) => Scaffold(body: Text(nombre));

  setUp(() {
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, __) => pantalla('home')),
        GoRoute(path: '/pedidos', builder: (_, __) => pantalla('mis pedidos')),
        GoRoute(
          path: '/pedidos/:id',
          builder: (_, s) => pantalla('detalle del dueño ${s.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/profesional/tablero',
          builder: (_, __) => pantalla('tablero'),
        ),
        GoRoute(
          path: '/profesional/pedidos/:id',
          builder: (_, s) =>
              pantalla('detalle del profesional ${s.pathParameters['id']}'),
        ),
      ],
    );
  });

  tearDown(() => router.dispose());

  Future<void> montar(WidgetTester tester) =>
      tester.pumpWidget(MaterialApp.router(routerConfig: router));

  testWidgets('abre el detalle del Profesional, no el del dueño', (tester) async {
    await montar(tester);

    abrirPedidoDeAlerta(router, 'abc');
    await tester.pumpAndSettle();

    expect(find.text('detalle del profesional abc'), findsOneWidget);
    expect(find.textContaining('detalle del dueño'), findsNothing);
  });

  testWidgets('al volver queda el tablero, no «Mis pedidos»', (tester) async {
    await montar(tester);

    abrirPedidoDeAlerta(router, 'abc');
    await tester.pumpAndSettle();

    expect(router.canPop(), isTrue,
        reason: 'con un go directo no había nada debajo y la pantalla caía en '
            'su ruta de reserva');

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('tablero'), findsOneWidget);
    expect(find.text('mis pedidos'), findsNothing);
  });

  testWidgets('dos alertas seguidas no apilan detalles uno arriba del otro',
      (tester) async {
    await montar(tester);

    abrirPedidoDeAlerta(router, 'primero');
    await tester.pumpAndSettle();
    abrirPedidoDeAlerta(router, 'segundo');
    await tester.pumpAndSettle();

    expect(find.text('detalle del profesional segundo'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('tablero'), findsOneWidget,
        reason: 'volver de la segunda alerta no tiene que pasar por la primera');
  });
}
