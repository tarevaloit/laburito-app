import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/core/errors/mensajes_error.dart';
import 'package:laburito/features/auth/data/auth_repository.dart';
import 'package:laburito/features/auth/presentation/screens/registro_profesional_screen.dart';
import 'package:laburito/features/categorias/data/categorias_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-02 — un DNI ya registrado traba el alta del Profesional (0045).
void main() {
  test('el trigger que aborta el alta se explica con el DNI', () {
    const error = AuthException('Database error saving new user');
    expect(MensajesError.desde(error), contains('DNI'));
    expect(MensajesError.desde(const DniEnUsoException()),
        startsWith('Ese DNI ya está en uso'));
  });

  group('recorrido', () {
    late _AuthFalso auth;

    Future<void> montar(WidgetTester t, {Set<String> usados = const {}}) async {
      t.view.physicalSize = const Size(800, 2000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);

      auth = _AuthFalso(usados);
      await t.pumpWidget(ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          categoriasActivasProvider.overrideWith((ref) async => const [
                CategoriaOficio(id: 'c-1', nombre: 'Plomería', slug: 'plomeria'),
              ]),
        ],
        child: MaterialApp(
          theme: AppTheme.claro,
          home: const RegistroProfesionalScreen(),
        ),
      ));
      await t.pumpAndSettle();
    }

    Future<void> completarPaso1(WidgetTester t, String dni) async {
      final campos = find.byType(TextFormField);
      await t.enterText(campos.at(0), 'Marcelo');
      await t.enterText(campos.at(1), 'Gómez');
      await t.enterText(campos.at(2), dni);
      await t.enterText(campos.at(3), 'marcelo@laburito.test');
      await t.enterText(campos.at(4), '1145678901');
      await t.enterText(campos.at(5), 'Secreta123');
      await t.enterText(campos.at(6), 'Secreta123');
      await t.tap(find.text('Continuar'));
      await t.pumpAndSettle();
    }

    testWidgets('con un DNI en uso no pasa al paso 2 y lo avisa', (t) async {
      await montar(t, usados: {'12345678'});
      await completarPaso1(t, '12.345.678');

      expect(auth.consultados, ['12.345.678']);
      expect(find.textContaining('Ese DNI ya está en uso'), findsOneWidget);
      expect(find.textContaining('TUS DATOS'), findsOneWidget);
    });

    testWidgets('con un DNI libre sigue a los oficios', (t) async {
      await montar(t);
      await completarPaso1(t, '12345678');

      expect(find.textContaining('TUS OFICIOS'), findsOneWidget);
    });

    testWidgets('si lo toman entre un paso y otro, vuelve al paso 1', (t) async {
      await montar(t);
      await completarPaso1(t, '12345678');

      auth.usados.add('12345678');
      await t.tap(find.text('Plomería'));
      await t.tap(find.byType(Checkbox));
      await t.pumpAndSettle();
      await t.tap(find.text('Finalizar registro'));
      await t.pumpAndSettle();

      expect(auth.altas, 0);
      expect(find.textContaining('Ese DNI ya está en uso'), findsOneWidget);
      expect(find.textContaining('TUS DATOS'), findsOneWidget);
    });
  });
}

class _AuthFalso implements AuthRepository {
  _AuthFalso(Set<String> usados) : usados = {...usados};

  final Set<String> usados;
  final List<String> consultados = [];
  int altas = 0;

  @override
  Future<void> comprobarDni(String dni) async {
    consultados.add(dni);
    if (usados.contains(dni.replaceAll('.', ''))) {
      throw const DniEnUsoException();
    }
  }

  @override
  Future<void> registrarProfesional({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String dni,
    required String descripcion,
    required List<String> categorias,
    required String password,
  }) async {
    await comprobarDni(dni);
    altas++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
