import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laburito/features/notificaciones/data/notificaciones_repository.dart';
import 'package:laburito/features/notificaciones/domain/notificacion.dart';
import 'package:laburito/features/notificaciones/presentation/campana_notificaciones.dart';
import 'package:laburito/features/notificaciones/presentation/screens/notificaciones_screen.dart';

/// CU-48 — Ver Notificaciones de Actividad.
void main() {
  final ahora = DateTime.now();
  final avisos = [
    Notificacion(
      id: 'n1',
      tipo: TipoNotificacion.nuevoInteresado,
      titulo: 'Un profesional quiere hacer tu trabajo',
      cuerpo: 'Pidió tu contacto por «Pérdida bajo la pileta».',
      ruta: '/pedidos/pedido-1',
      creadaAt: ahora.subtract(const Duration(minutes: 5)),
    ),
    Notificacion(
      id: 'n2',
      tipo: TipoNotificacion.calificacionRecibida,
      titulo: 'Laura G. te calificó con 5 estrellas',
      ruta: '/profesional/contactos',
      creadaAt: ahora.subtract(const Duration(hours: 2)),
    ),
    Notificacion(
      id: 'n3',
      tipo: TipoNotificacion.pagoAcreditado,
      titulo: 'Se acreditaron 10 tokens',
      leidaAt: ahora.subtract(const Duration(days: 1)),
      creadaAt: ahora.subtract(const Duration(days: 2)),
    ),
  ];

  test('las filas de la base se leen con su tipo', () {
    final n = Notificacion.desdeFila({
      'id': 'x',
      'tipo': 'verificacion_rechazada',
      'titulo': 'Revisá tu documentación',
      'cuerpo': null,
      'ruta': '/verificacion',
      'leida_at': null,
      'created_at': '2026-10-13T20:00:00Z',
    });
    expect(n.tipo, TipoNotificacion.verificacionRechazada);
    expect(n.leida, isFalse);
    expect(TipoNotificacion.desde('desconocido'), TipoNotificacion.otro);
  });

  group('recorrido', () {
    late _RepoFalso repo;

    Future<void> abrir(WidgetTester t, List<Notificacion> lista,
        {String inicio = '/home'}) async {
      final router = GoRouter(
        initialLocation: inicio,
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => Scaffold(
              appBar: AppBar(actions: const [CampanaNotificaciones()]),
            ),
          ),
          GoRoute(
            path: '/notificaciones',
            builder: (_, __) => const NotificacionesScreen(),
          ),
          GoRoute(
            path: '/pedidos/:id',
            builder: (_, s) => Text('Pedido ${s.pathParameters['id']}'),
          ),
        ],
      );
      await t.pumpWidget(ProviderScope(
        overrides: [
          notificacionesRepositoryProvider.overrideWithValue(repo),
          notificacionesProvider.overrideWith((ref) => Stream.value(lista)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await t.pumpAndSettle();
    }

    setUp(() => repo = _RepoFalso());

    testWidgets('la campana muestra cuántas hay sin leer y abre el centro',
        (t) async {
      await abrir(t, avisos);

      expect(find.text('2'), findsOneWidget);

      await t.tap(find.byKey(const Key('campana-notificaciones')));
      await t.pumpAndSettle();

      expect(find.text('Notificaciones'), findsOneWidget);
      expect(find.text('Un profesional quiere hacer tu trabajo'), findsOneWidget);
      expect(find.text('Se acreditaron 10 tokens'), findsOneWidget);
    });

    testWidgets('al abrir, se marcan leídas una sola vez', (t) async {
      await abrir(t, avisos, inicio: '/notificaciones');
      await t.pump();

      expect(repo.marcadas, 1);
    });

    testWidgets('sin avisos sin leer no se marca nada', (t) async {
      await abrir(t, [avisos.last], inicio: '/notificaciones');

      expect(repo.marcadas, 0);
    });

    testWidgets('tocar un aviso lleva a su pantalla', (t) async {
      await abrir(t, avisos, inicio: '/notificaciones');

      await t.tap(find.byKey(const Key('notificacion-n1')));
      await t.pumpAndSettle();

      expect(find.text('Pedido pedido-1'), findsOneWidget);
    });

    testWidgets('«Limpiar todo» pide confirmación y borra', (t) async {
      await abrir(t, avisos, inicio: '/notificaciones');

      await t.tap(find.text('Limpiar todo'));
      await t.pumpAndSettle();
      await t.tap(find.text('Limpiar'));
      await t.pumpAndSettle();

      expect(repo.limpiezas, 1);
    });

    testWidgets('sin notificaciones muestra el estado vacío', (t) async {
      await abrir(t, const [], inicio: '/notificaciones');

      expect(find.text('No tenés notificaciones'), findsOneWidget);
      expect(find.text('Limpiar todo'), findsNothing);
    });
  });
}

class _RepoFalso implements NotificacionesRepository {
  int marcadas = 0;
  int limpiezas = 0;

  @override
  Future<void> marcarLeidas() async => marcadas++;

  @override
  Future<void> limpiar() async => limpiezas++;

  @override
  Stream<List<Notificacion>> observar() => const Stream.empty();
}
