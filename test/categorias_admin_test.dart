import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/admin/data/categorias_admin_repository.dart';
import 'package:laburito/features/admin/presentation/screens/categorias_admin_screen.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-37 — Gestionar Categorías de Oficios.
void main() {
  const plomeria = CategoriaAdmin(
    id: 'c1',
    nombre: 'Plomería',
    slug: 'plomeria',
    icono: '🔧',
    activa: true,
    profesionales: 42,
    pedidos: 10,
  );
  const jardineria = CategoriaAdmin(
    id: 'c2',
    nombre: 'Jardinería',
    slug: 'jardineria',
    icono: '🌿',
    activa: false,
  );

  test('en uso cuando tiene profesionales o pedidos', () {
    expect(plomeria.enUso, isTrue);
    expect(jardineria.enUso, isFalse);
  });

  group('recorrido', () {
    late _CategoriasFalso repo;

    Future<void> montar(WidgetTester t) async {
      t.view.physicalSize = const Size(1400, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      repo = _CategoriasFalso([plomeria, jardineria]);
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
          categoriasAdminRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
            theme: AppTheme.claro, home: const CategoriasAdminScreen()),
      ));
      await t.pumpAndSettle();
    }

    testWidgets('tarjetas con estado y cantidad de profesionales', (t) async {
      await montar(t);

      expect(find.text('Plomería'), findsOneWidget);
      expect(find.text('42 profesionales'), findsOneWidget);
      expect(find.text('Activa'), findsOneWidget);
      expect(find.text('Oculta'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('nueva categoría con nombre e ícono', (t) async {
      await montar(t);

      await t.tap(find.byKey(const Key('nueva-categoria')));
      await t.pumpAndSettle();
      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('nombre-categoria')),
            matching: find.byType(TextFormField)),
        'Pileteros',
      );
      await t.tap(find.text('🏊'));
      await t.tap(find.byKey(const Key('guardar-categoria')));
      await t.pumpAndSettle();

      expect(repo.creadas, [('Pileteros', '🏊')]);
    });

    testWidgets('el interruptor oculta la categoría', (t) async {
      await montar(t);

      await t.tap(find.descendant(
          of: find.byKey(const Key('categoria-plomeria')),
          matching: find.byType(Switch)));
      await t.pumpAndSettle();

      expect(repo.visibilidad, [('c1', false)]);
    });

    testWidgets('eliminar una en uso propone ocultarla (flujo 1.2)', (t) async {
      await montar(t);

      await t.tap(find.descendant(
          of: find.byKey(const Key('categoria-plomeria')),
          matching: find.byType(PopupMenuButton<String>)));
      await t.pumpAndSettle();
      await t.tap(find.text('Eliminar'));
      await t.pumpAndSettle();

      expect(find.text('No se puede eliminar Plomería'), findsOneWidget);
      await t.tap(find.text('Ocultarla'));
      await t.pumpAndSettle();

      expect(repo.eliminadas, isEmpty);
      expect(repo.visibilidad, [('c1', false)]);
    });
  });
}

class _CategoriasFalso implements CategoriasAdminRepository {
  _CategoriasFalso(this.lista);

  final List<CategoriaAdmin> lista;
  final creadas = <(String, String?)>[];
  final visibilidad = <(String, bool)>[];
  final eliminadas = <String>[];

  @override
  Future<List<CategoriaAdmin>> todas() async => lista;

  @override
  Future<void> crear({required String nombre, String? icono}) async =>
      creadas.add((nombre, icono));

  @override
  Future<void> cambiarVisibilidad(String id, {required bool activa}) async =>
      visibilidad.add((id, activa));

  @override
  Future<void> eliminar(String id) async => eliminadas.add(id);

  @override
  Future<void> editar(String id, {required String nombre, String? icono}) async {}
}
