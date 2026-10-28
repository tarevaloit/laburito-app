import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/admin/data/validaciones_repository.dart';
import 'package:laburito/features/admin/presentation/screens/validaciones_screen.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-35 — Validar Identidad Profesional.
void main() {
  test('se leen las rutas de las fotos y los datos del registro', () {
    final p = ProfesionalEnRevision.desdeFila({
      'profesional_id': 'p1',
      'nombre': 'Marcelo',
      'apellido': 'Gómez',
      'email': 'marcelo@laburito.test',
      'dni': '33456789',
      'oficios': 'Plomería, Gas',
      'documentos': {'dni_frente': 'p1/dni_frente.jpg', 'selfie': 'p1/selfie.jpg'},
      'enviado_at': '2026-10-27T10:00:00Z',
    });
    expect(p.nombreCompleto, 'Marcelo Gómez');
    expect(p.documentos['dni_frente'], 'p1/dni_frente.jpg');
    expect(p.documentos.containsKey('dni_dorso'), isFalse);
  });

  group('recorrido', () {
    late _ValidacionesFalso repo;

    Future<void> montar(WidgetTester t, List<ProfesionalEnRevision> lista) async {
      t.view.physicalSize = const Size(1400, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);

      repo = _ValidacionesFalso(lista);
      await t.pumpWidget(ProviderScope(
        overrides: [
          perfilCompletoProvider.overrideWith((ref) async => const PerfilCompleto(
                id: 'admin',
                tipo: 'administrador',
                nombre: 'Ada',
                apellido: 'Admin',
                email: 'admin@laburito.test',
                estado: 'activo',
              )),
          validacionesRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(theme: AppTheme.claro, home: const ValidacionesScreen()),
      ));
      await t.pumpAndSettle();
    }

    const marcelo = ProfesionalEnRevision(
      id: 'p1',
      nombre: 'Marcelo',
      apellido: 'Gómez',
      email: 'marcelo@laburito.test',
      dni: '33456789',
      oficios: 'Plomería, Gas',
    );
    const diego = ProfesionalEnRevision(
      id: 'p2',
      nombre: 'Diego',
      apellido: 'Ferreyra',
      email: 'diego@laburito.test',
      oficios: 'Electricidad',
    );

    testWidgets('lista, detalle y elegir otro pendiente', (t) async {
      await montar(t, [marcelo, diego]);

      expect(find.text('En revisión · 2'), findsOneWidget);
      expect(find.text('33456789'), findsOneWidget);

      await t.tap(find.byKey(const Key('validacion-p2')));
      await t.pumpAndSettle();
      expect(find.text('diego@laburito.test'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('aprobar pide confirmación y resuelve', (t) async {
      await montar(t, [marcelo]);

      await t.tap(find.byKey(const Key('aprobar-cuenta')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('confirmar-dialogo')));
      await t.pumpAndSettle();

      expect(repo.resueltos, [('p1', true, null)]);
      expect(find.text('No hay documentación pendiente'), findsOneWidget);
    });

    testWidgets('rechazar sin motivo no sale (flujo alterno 1.2)', (t) async {
      await montar(t, [marcelo]);

      await t.tap(find.byKey(const Key('rechazar-cuenta')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('confirmar-dialogo')));
      await t.pumpAndSettle();
      expect(repo.resueltos, isEmpty);
      expect(find.textContaining('al menos 10'), findsOneWidget);

      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('texto-dialogo')),
            matching: find.byType(TextFormField)),
        'La foto del frente está borrosa',
      );
      await t.tap(find.byKey(const Key('confirmar-dialogo')));
      await t.pumpAndSettle();

      expect(repo.resueltos, [('p1', false, 'La foto del frente está borrosa')]);
    });

    testWidgets('sin pendientes, el aviso vacío', (t) async {
      await montar(t, const []);
      expect(find.text('No hay documentación pendiente'), findsOneWidget);
    });
  });
}

class _ValidacionesFalso implements ValidacionesRepository {
  _ValidacionesFalso(this.lista);

  final List<ProfesionalEnRevision> lista;
  final List<(String, bool, String?)> resueltos = [];

  @override
  Future<List<ProfesionalEnRevision>> pendientes() async =>
      lista.where((p) => !resueltos.any((r) => r.$1 == p.id)).toList();

  @override
  Future<String> urlFirmada(String ruta) async => 'https://ejemplo.test/$ruta';

  @override
  Future<void> resolver(
    ProfesionalEnRevision profesional, {
    required bool aprobar,
    String? motivo,
  }) async =>
      resueltos.add((profesional.id, aprobar, motivo));
}
