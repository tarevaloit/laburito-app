import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/features/admin/presentation/screens/denuncias_screen.dart';
import 'package:laburito/features/denuncias/data/denuncias_repository.dart';
import 'package:laburito/features/denuncias/domain/denuncia.dart';
import 'package:laburito/features/denuncias/presentation/reportar_usuario.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-41 — Reportar Usuario.
void main() {
  test('los motivos usan los valores del enum de la base', () {
    expect(MotivoDenuncia.values.map((m) => m.valor), [
      'comportamiento_inapropiado',
      'incumplimiento',
      'estafa',
      'perfil_falso',
      'otro',
    ]);
    expect(MotivoDenuncia.desde('estafa'), MotivoDenuncia.estafa);
    expect(MotivoDenuncia.desde('raro'), MotivoDenuncia.otro);
  });

  group('recorrido del formulario', () {
    late _RepoFalso repo;

    Future<void> abrir(WidgetTester t) async {
      t.view.physicalSize = const Size(390, 1200);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(ProviderScope(
        overrides: [denunciasRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => mostrarReporteUsuario(
                  context,
                  sobre: 'Marcelo Gómez',
                  slug: 'marcelo-gomez-7b1e2a',
                ),
                child: const Text('Reportar'),
              ),
            ),
          ),
        ),
      ));
      await t.tap(find.text('Reportar'));
      await t.pumpAndSettle();
    }

    setUp(() => repo = _RepoFalso());

    testWidgets('sin motivo no envía y resalta el campo', (t) async {
      await abrir(t);

      await t.enterText(find.byKey(const Key('descripcion-reporte')),
          'No vino el día que acordamos.');
      await t.tap(find.text('Enviar reporte'));
      await t.pumpAndSettle();

      expect(find.text('Elegí el motivo del reporte.'), findsOneWidget);
      expect(repo.reportes, isEmpty);
    });

    testWidgets('una descripción corta no se envía', (t) async {
      await abrir(t);

      await t.tap(find.byKey(const Key('motivo-incumplimiento')));
      await t.enterText(find.byKey(const Key('descripcion-reporte')), 'Mal');
      await t.tap(find.text('Enviar reporte'));
      await t.pumpAndSettle();

      expect(find.textContaining('al menos 10 caracteres'), findsOneWidget);
      expect(repo.reportes, isEmpty);
    });

    testWidgets('con motivo y descripción envía, cierra y confirma', (t) async {
      await abrir(t);

      expect(find.text('Reportar a Marcelo Gómez'), findsOneWidget);
      await t.tap(find.byKey(const Key('motivo-incumplimiento')));
      await t.enterText(find.byKey(const Key('descripcion-reporte')),
          'No vino el día que acordamos.');
      await t.tap(find.text('Enviar reporte'));
      await t.pumpAndSettle();

      expect(repo.reportes, [
        (MotivoDenuncia.incumplimiento, 'No vino el día que acordamos.',
            'marcelo-gomez-7b1e2a'),
      ]);
      expect(find.text('Enviar reporte'), findsNothing);
      expect(find.textContaining('Recibimos tu reporte'), findsOneWidget);
    });
  });

  testWidgets('el panel muestra las denuncias con las pendientes contadas',
      (t) async {
    t.view.physicalSize = const Size(1200, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);

    await t.pumpWidget(ProviderScope(
      overrides: [
        perfilCompletoProvider.overrideWith((ref) async => const PerfilCompleto(
              id: 'admin',
              tipo: 'administrador',
              nombre: 'Ana',
              apellido: 'Admin',
              email: 'admin@laburito.test',
              estado: 'activo',
            )),
        denunciasAdminProvider.overrideWith((ref) async => [
              DenunciaAdmin(
                id: 'd1',
                denunciante: 'Laura Gómez',
                denuncianteTipo: 'buscador',
                denunciado: 'Marcelo Pérez',
                denunciadoTipo: 'profesional',
                motivo: MotivoDenuncia.incumplimiento,
                descripcion: 'No vino el día que acordamos.',
                estado: 'pendiente',
                creadaAt: DateTime.now().subtract(const Duration(hours: 1)),
              ),
            ]),
      ],
      child: const MaterialApp(home: DenunciasScreen()),
    ));
    await t.pumpAndSettle();

    expect(find.text('1 pendientes de revisión'), findsOneWidget);
    expect(find.text('No cumplió lo acordado'), findsOneWidget);
    expect(find.textContaining('Laura Gómez (Buscador) reportó a Marcelo Pérez'),
        findsOneWidget);
  });
}

class _RepoFalso implements DenunciasRepository {
  final reportes = <(MotivoDenuncia, String, String?)>[];

  @override
  Future<void> reportar({
    required MotivoDenuncia motivo,
    required String descripcion,
    String? slug,
    String? pedidoId,
  }) async =>
      reportes.add((motivo, descripcion, slug ?? pedidoId));

  @override
  Future<List<DenunciaAdmin>> listarAdmin() async => const [];
}
