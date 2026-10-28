import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/admin/data/admin_repository.dart';
import 'package:laburito/features/admin/domain/dashboard.dart';
import 'package:laburito/features/admin/presentation/screens/dashboard_screen.dart';
import 'package:laburito/features/admin/presentation/screens/ingreso_admin_screen.dart';
import 'package:laburito/features/auth/data/auth_repository.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-34 Iniciar Sesión Administrador y CU-38 Consultar Estadísticas.
void main() {
  Map<String, dynamic> json({int pedidos = 12, int ingresos = 54000}) => {
        'desde': '2026-09-28',
        'hasta': '2026-10-27',
        'pedidos_publicados': {'actual': pedidos, 'anterior': 10},
        'ingresos_ars': {'actual': ingresos, 'anterior': 0},
        'tokens_vendidos': 30,
        'altas_profesionales': {'actual': 4, 'anterior': 5},
        'altas_buscadores': {'actual': 9, 'anterior': 3},
        'denuncias_recibidas': {'actual': 2, 'anterior': 1},
        'denuncias_abiertas': 1,
        'altas_por_mes': [
          for (var m = 1; m <= 12; m++)
            {'mes': '2026-${m.toString().padLeft(2, '0')}', 'buscadores': m, 'profesionales': 1},
        ],
        'ingresos_por_pack': [
          {'pack': 'Oro', 'compras': 2, 'monto': 30000},
          {'pack': 'Plata; promo', 'compras': 3, 'monto': 24000},
        ],
      };

  group('CU-38 modelo', () {
    test('la variación es contra el período anterior y sin base es null', () {
      expect(const Comparacion(actual: 12, anterior: 10).variacion, 20);
      expect(const Comparacion(actual: 4, anterior: 5).variacion, -20);
      expect(const Comparacion(actual: 7, anterior: 0).variacion, isNull);
    });

    test('se lee el json de dashboard_admin', () {
      final d = Dashboard.desdeJson(json());
      expect(d.pedidosPublicados.actual, 12);
      expect(d.altasPorMes, hasLength(12));
      expect(d.altasPorMes.last.mes, DateTime(2026, 12));
      expect(d.totalPorPack, 54000);
      expect(d.sinActividad, isFalse);
    });

    test('un rango sin actividad se reconoce (flujo alterno 1.1)', () {
      final d = Dashboard.desdeJson({
        'desde': '2024-01-01',
        'hasta': '2024-01-31',
      });
      expect(d.sinActividad, isTrue);
      expect(d.altasPorMes, isEmpty);
      expect(d.ingresosArs.actual, 0);
    });

    test('el CSV abre en Excel: BOM, punto y coma y celdas escapadas', () {
      final csv = Dashboard.desdeJson(json()).aCsv();
      expect(csv.startsWith('﻿'), isTrue);
      expect(csv, contains('Pedidos publicados;12;10'));
      expect(csv, contains('2026-03;3;1;4'));
      expect(csv, contains('"Plata; promo";3;24000'));
    });

    test('los rangos rápidos terminan hoy e incluyen los dos extremos', () {
      final (desde, hasta) = RangoDashboard.semana.rango(DateTime(2026, 10, 27, 15));
      expect(hasta, DateTime(2026, 10, 27));
      expect(desde, DateTime(2026, 10, 21));
    });
  });

  group('CU-38 recorrido', () {
    Future<void> montar(WidgetTester t, Map<String, dynamic> datos) async {
      t.view.physicalSize = const Size(1400, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);

      await t.pumpWidget(ProviderScope(
        overrides: [
          perfilCompletoProvider.overrideWith((ref) async => _admin),
          adminRepositoryProvider
              .overrideWithValue(_AdminFalso(datos: Dashboard.desdeJson(datos))),
          accesosAdminProvider.overrideWith((ref) async => [
                AccesoAdmin(
                  email: 'intruso@laburito.test',
                  aceptado: false,
                  fecha: DateTime(2026, 10, 27, 10),
                  ip: '190.2.3.4',
                ),
              ]),
        ],
        child: MaterialApp(
          theme: AppTheme.claro,
          home: DashboardScreen(hoy: DateTime(2026, 10, 27)),
        ),
      ));
      await t.pumpAndSettle();
    }

    testWidgets('las cuatro tarjetas, los gráficos y los accesos', (t) async {
      await montar(t, json());

      expect(find.text('Panel de control'), findsOneWidget);
      expect(find.text('Pedidos publicados'), findsOneWidget);
      expect(find.text('▲ +20 % vs. período anterior'), findsOneWidget);
      expect(find.text('Sin datos del período anterior'), findsOneWidget);
      expect(find.text('Altas de usuarios'), findsOneWidget);
      expect(find.text('Ingresos por pack'), findsOneWidget);
      expect(find.textContaining('IP 190.2.3.4'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('el selector cambia el rango', (t) async {
      await montar(t, json());

      await t.tap(find.byKey(const Key('rango-dashboard')));
      await t.pumpAndSettle();
      await t.tap(find.text('Últimos 7 días').last);
      await t.pumpAndSettle();

      expect(find.text('Últimos 7 días'), findsOneWidget);
    });

    testWidgets('sin actividad muestra todo en cero y lo avisa', (t) async {
      await montar(t, {'desde': '2024-01-01', 'hasta': '2024-01-31'});

      expect(find.text('No hubo actividad en este rango'), findsOneWidget);
      expect(find.text('Sin compras en este rango.'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('en el celular las tarjetas se apilan sin desbordar', (t) async {
      t.view.physicalSize = const Size(390, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(ProviderScope(
        overrides: [
          perfilCompletoProvider.overrideWith((ref) async => _admin),
          adminRepositoryProvider
              .overrideWithValue(_AdminFalso(datos: Dashboard.desdeJson(json()))),
          accesosAdminProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(theme: AppTheme.claro, home: const DashboardScreen()),
      ));
      await t.pumpAndSettle();

      expect(t.takeException(), isNull);
    });
  });

  group('CU-34 recorrido', () {
    late _AuthFalso auth;
    late _AdminFalso admin;

    Future<void> montar(WidgetTester t, {required bool esAdmin}) async {
      auth = _AuthFalso();
      admin = _AdminFalso(esAdmin: esAdmin);
      final router = GoRouter(
        initialLocation: '/admin/ingresar',
        routes: [
          GoRoute(
              path: '/admin/ingresar',
              builder: (_, __) => const IngresoAdminScreen()),
          GoRoute(
              path: '/admin/dashboard',
              builder: (_, __) => const Text('dashboard')),
        ],
      );
      await t.pumpWidget(ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          adminRepositoryProvider.overrideWithValue(admin),
        ],
        child: MaterialApp.router(theme: AppTheme.claro, routerConfig: router),
      ));
      await t.pumpAndSettle();
    }

    Future<void> ingresar(WidgetTester t) async {
      await t.enterText(find.byType(TextFormField).at(0), 'ada@laburito.test');
      await t.enterText(find.byType(TextFormField).at(1), 'secreta123');
      await t.tap(find.text('Ingresar al Panel'));
      await t.pumpAndSettle();
    }

    testWidgets('el formulario no ofrece registro', (t) async {
      await montar(t, esAdmin: true);

      expect(find.textContaining('Registr'), findsNothing);
      expect(find.text('Panel de administración'), findsOneWidget);
    });

    testWidgets('un administrador entra al Dashboard', (t) async {
      await montar(t, esAdmin: true);
      await ingresar(t);

      expect(admin.registros, 1);
      expect(find.text('dashboard'), findsOneWidget);
      expect(auth.cerroSesion, isFalse);
    });

    testWidgets('otra cuenta queda afuera con la sesión cerrada (flujo 1.1)',
        (t) async {
      await montar(t, esAdmin: false);
      await ingresar(t);

      expect(admin.registros, 1);
      expect(auth.cerroSesion, isTrue);
      expect(find.byKey(const Key('rechazo-admin')), findsOneWidget);
      expect(find.textContaining('quedó registrado'), findsOneWidget);
      expect(find.text('dashboard'), findsNothing);
    });
  });
}

const _admin = PerfilCompleto(
  id: 'admin',
  tipo: 'administrador',
  nombre: 'Ada',
  apellido: 'Admin',
  email: 'admin@laburito.test',
  estado: 'activo',
);

class _AuthFalso implements AuthRepository {
  bool cerroSesion = false;

  @override
  Future<void> iniciarSesionSinValidarRol({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> cerrarSesion() async => cerroSesion = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AdminFalso implements AdminRepository {
  _AdminFalso({this.esAdmin = true, this.datos});

  final bool esAdmin;
  final Dashboard? datos;
  int registros = 0;

  @override
  Future<Dashboard> dashboard({
    required DateTime desde,
    required DateTime hasta,
  }) async =>
      datos!;

  @override
  Future<bool> registrarAcceso() async {
    registros++;
    return esAdmin;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
