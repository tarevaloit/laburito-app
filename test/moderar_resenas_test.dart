import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/admin/presentation/screens/resenas_admin_screen.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';
import 'package:laburito/features/reputacion/data/resenas_repository.dart';
import 'package:laburito/features/reputacion/presentation/screens/mis_resenas_screen.dart';

/// CU-46 — Moderar Reseñas.
void main() {
  final nueva = Resena(
    id: 'r1',
    puntaje: 1,
    autor: 'Laura',
    fecha: DateTime(2026, 10, 20),
    comentario: 'No vino nunca y no avisó.',
    profesional: 'Marcelo Gómez',
  );
  final ofensiva = Resena(
    id: 'r2',
    puntaje: 1,
    autor: 'Laura',
    fecha: DateTime(2026, 10, 21),
    comentario: 'Un estafador.',
    profesional: 'Marcelo Gómez',
    revisionAutomatica: true,
  );

  test('solo se reporta una reseña sin reporte ni moderación', () {
    expect(nueva.reportable, isTrue);
    final reportada = Resena.desdeFila({
      'id': 'r1',
      'puntaje': 2,
      'autor_nombre': 'Laura',
      'created_at': '2026-10-20T10:00:00Z',
      'reportada_at': '2026-10-21T10:00:00Z',
    });
    expect(reportada.reportable, isFalse);
    expect(reportada.pendienteDeModeracion, isTrue);
  });

  Widget app(_ResenasFalso repo, Widget home) => ProviderScope(
        overrides: [
          perfilCompletoProvider.overrideWith((ref) async => const PerfilCompleto(
                id: 'admin',
                tipo: 'administrador',
                nombre: 'Ada',
                apellido: 'Admin',
                email: 'admin@laburito.test',
                estado: 'activo',
              )),
          resenasRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(theme: AppTheme.claro, home: home),
      );

  testWidgets('el Profesional reporta una reseña con motivo', (t) async {
    final repo = _ResenasFalso([nueva]);
    await t.pumpWidget(app(repo, const MisResenasScreen()));
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('reportar-r1')));
    await t.pumpAndSettle();
    await t.enterText(
      find.descendant(
          of: find.byKey(const Key('texto-dialogo')),
          matching: find.byType(TextFormField)),
      'El pedido se canceló antes de que yo fuera.',
    );
    await t.tap(find.byKey(const Key('confirmar-dialogo')));
    await t.pumpAndSettle();

    expect(repo.reportes, [('r1', 'El pedido se canceló antes de que yo fuera.')]);
  });

  testWidgets('el admin elimina la del filtro y mantiene la otra', (t) async {
    t.view.physicalSize = const Size(1400, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final repo = _ResenasFalso([ofensiva, nueva]);
    await t.pumpWidget(app(repo, const ResenasAdminScreen()));
    await t.pumpAndSettle();

    expect(find.text('Filtro automático'), findsOneWidget);
    expect(find.text('Laura calificó a Marcelo Gómez'), findsNWidgets(2));

    await t.tap(find.byKey(const Key('eliminar-r2')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirmar-dialogo')));
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('mantener-r1')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirmar-dialogo')));
    await t.pumpAndSettle();

    expect(repo.moderadas, [('r2', true), ('r1', false)]);
    expect(t.takeException(), isNull);
  });
}

class _ResenasFalso implements ResenasRepository {
  _ResenasFalso(this.lista);

  final List<Resena> lista;
  final reportes = <(String, String)>[];
  final moderadas = <(String, bool)>[];

  @override
  Future<List<Resena>> mias() async => lista;

  @override
  Future<void> reportar(String id, String motivo) async =>
      reportes.add((id, motivo));

  @override
  Future<List<Resena>> aModerar({bool incluirResueltas = false}) async => lista;

  @override
  Future<void> moderar(String id, {required bool eliminar}) async =>
      moderadas.add((id, eliminar));
}
