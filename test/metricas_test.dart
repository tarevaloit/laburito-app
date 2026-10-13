import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/features/reputacion/data/reputacion_repository.dart';
import 'package:laburito/features/reputacion/domain/metricas.dart';
import 'package:laburito/features/reputacion/presentation/screens/estadisticas_screen.dart';

/// CU-45 — Ver Métricas de Perfil (Figura 3.18).
void main() {
  test('el JSON de metricas_perfil se lee con su serie', () {
    final m = MetricasPerfil.desdeJson({
      'periodo': 'semana',
      'vistas': 214,
      'contactos': 31,
      'calificaciones': 21,
      'efectividad': 68,
      'serie': [
        for (var i = 0; i < 7; i++)
          {'desde': '2026-10-${(7 + i).toString().padLeft(2, '0')}', 'vistas': i * 3},
      ],
    });
    expect(m.vistas, 214);
    expect(m.efectividad, 68);
    expect(m.serie, hasLength(7));
    expect(m.maximoSerie, 18);
    expect(m.sinActividad, isFalse);
  });

  test('sin contactos la efectividad queda en null', () {
    final m = MetricasPerfil.desdeJson({'periodo': 'mes', 'efectividad': null});
    expect(m.periodo, PeriodoMetricas.mes);
    expect(m.efectividad, isNull);
    expect(m.sinActividad, isTrue);
  });

  group('recorrido', () {
    late _RepoFalso repo;

    Future<void> abrir(WidgetTester t) async {
      t.view.physicalSize = const Size(390, 1400);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(ProviderScope(
        overrides: [reputacionRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: EstadisticasScreen()),
      ));
      await t.pumpAndSettle();
    }

    setUp(() => repo = _RepoFalso());

    testWidgets('muestra contadores, barras por día y efectividad', (t) async {
      await abrir(t);

      expect(find.text('214'), findsOneWidget);
      expect(find.text('Vistas al perfil'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
      expect(find.text('Actividad de la semana'), findsOneWidget);
      expect(find.text('68%'), findsOneWidget);
      expect(find.textContaining('Todavía no hay actividad'), findsNothing);
      expect(repo.pedidos, [PeriodoMetricas.semana]);
    });

    testWidgets('pasar a Mensual pide el mes y lo grafica por semana',
        (t) async {
      await abrir(t);

      await t.tap(find.text('Mensual'));
      await t.pumpAndSettle();

      expect(repo.pedidos, [PeriodoMetricas.semana, PeriodoMetricas.mes]);
      expect(find.text('Actividad del mes'), findsOneWidget);
      expect(find.text('Vistas por semana'), findsOneWidget);
    });

    testWidgets('un Profesional nuevo ve ceros y consejos', (t) async {
      repo.nuevo = true;
      await abrir(t);

      expect(find.text('0'), findsNWidgets(2));
      expect(find.textContaining('Todavía no hay actividad'), findsOneWidget);
      expect(find.textContaining('portafolio'), findsOneWidget);
    });
  });
}

class _RepoFalso implements ReputacionRepository {
  bool nuevo = false;
  final pedidos = <PeriodoMetricas>[];

  @override
  Future<MetricasPerfil> metricas(PeriodoMetricas periodo) async {
    pedidos.add(periodo);
    if (nuevo) {
      return MetricasPerfil(
        periodo: periodo,
        serie: [
          for (var i = 0; i < 7; i++)
            BarraMetricas(desde: DateTime(2026, 10, 7 + i), vistas: 0),
        ],
      );
    }
    final semanal = periodo == PeriodoMetricas.semana;
    return MetricasPerfil(
      periodo: periodo,
      vistas: 214,
      contactos: 31,
      calificaciones: 21,
      efectividad: 68,
      serie: [
        for (var i = 0; i < (semanal ? 7 : 4); i++)
          BarraMetricas(
            desde: DateTime(2026, 10, 7).add(Duration(days: semanal ? i : i * 7)),
            vistas: 10 + i * 5,
          ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
