import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/admin/data/admin_repository.dart';
import 'package:laburito/features/admin/domain/parametro.dart';
import 'package:laburito/features/admin/presentation/screens/parametros_screen.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-47 — Configurar Parámetros Globales.
void main() {
  const radio = Parametro(
    clave: 'radio_maximo_km',
    nombre: 'Radio máximo de cobertura',
    descripcion: 'Distancia máxima de la zona de cobertura.',
    unidad: 'km',
    valor: 100,
    minimo: 1,
    maximo: 100,
  );

  test('el rango del parámetro se valida en la pantalla (flujo 1.1)', () {
    expect(radio.validar('-5'), isNotNull);
    expect(radio.validar('0'), isNotNull);
    expect(radio.validar('101'), isNotNull);
    expect(radio.validar('veinte'), isNotNull);
    expect(radio.validar('20'), isNull);
  });

  group('recorrido', () {
    late _AdminFalso repo;

    Future<void> montar(WidgetTester t) async {
      t.view.physicalSize = const Size(1400, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      repo = _AdminFalso();
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
          adminRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(theme: AppTheme.claro, home: const ParametrosScreen()),
      ));
      await t.pumpAndSettle();
    }

    Future<void> escribir(WidgetTester t, String valor) async {
      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('parametro-radio_maximo_km')),
            matching: find.byType(TextFormField)),
        valor,
      );
      await t.tap(find.byKey(const Key('aplicar-parametros')));
      await t.pumpAndSettle();
    }

    testWidgets('fuera de rango no llega a pedir confirmación', (t) async {
      await montar(t);
      await escribir(t, '500');

      expect(find.text('Tiene que estar entre 1 y 100 km.'), findsOneWidget);
      expect(find.text('Aplicar cambios globales'), findsOneWidget);
      expect(repo.cambios, isEmpty);
    });

    testWidgets('segunda confirmación y contraseña antes de guardar', (t) async {
      await montar(t);
      await escribir(t, '20');

      expect(find.textContaining('100 → 20 km'), findsOneWidget);
      await t.tap(find.byKey(const Key('confirmar-dialogo')));
      await t.pumpAndSettle();

      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('password-admin')),
            matching: find.byType(TextFormField)),
        'correcta',
      );
      await t.tap(find.text('Confirmar'));
      await t.pumpAndSettle();

      expect(repo.cambios, [('radio_maximo_km', 20)]);
      expect(t.takeException(), isNull);
    });
  });
}

class _AdminFalso implements AdminRepository {
  final cambios = <(String, int)>[];

  @override
  Future<List<Parametro>> parametros() async => const [
        Parametro(
          clave: 'radio_maximo_km',
          nombre: 'Radio máximo de cobertura',
          descripcion: 'Distancia máxima de la zona de cobertura.',
          unidad: 'km',
          valor: 100,
          minimo: 1,
          maximo: 100,
        ),
      ];

  @override
  Future<void> reautenticar(String password) async {
    if (password != 'correcta') throw const ReautenticacionFallidaException();
  }

  @override
  Future<void> actualizarParametro(String clave, int valor) async =>
      cambios.add((clave, valor));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
