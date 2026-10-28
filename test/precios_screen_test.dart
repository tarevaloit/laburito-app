import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/admin/data/admin_repository.dart';
import 'package:laburito/features/admin/data/cupon.dart';
import 'package:laburito/features/admin/presentation/screens/precios_screen.dart';
import 'package:laburito/features/billetera/domain/paquete_tokens.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-40 — Regresión del 01/10: guardar un precio daba pantalla roja.
///
/// El controlador de la contraseña se descartaba mientras el diálogo todavía
/// se dibujaba al cerrarse, y la re-autenticación recargaba el perfil y el
/// panel cambiaba el formulario por un spinner en pleno guardado.
void main() {
  const plata =
      PaqueteTokens(id: 'p', nombre: 'Plata', cantidad: 10, precioArs: 8000);

  late _AdminFalso repo;

  Future<void> montar(WidgetTester t) async {
    t.view.physicalSize = const Size(1280, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);

    repo = _AdminFalso();
    await t.pumpWidget(ProviderScope(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repo),
        paquetesAdminProvider.overrideWith((ref) async => [plata]),
        perfilCompletoProvider.overrideWith((ref) async => const PerfilCompleto(
              id: 'admin',
              tipo: 'administrador',
              nombre: 'Ada',
              apellido: 'Admin',
              email: 'admin@laburito.test',
              estado: 'activo',
            )),
      ],
      child: MaterialApp(theme: AppTheme.claro, home: const PreciosScreen()),
    ));
    await t.pumpAndSettle();

    // Como en la vida real: iniciar sesión otra vez recarga el perfil.
    final container = ProviderScope.containerOf(
      t.element(find.byType(PreciosScreen)),
    );
    repo.alReautenticar = () => container.invalidate(perfilCompletoProvider);
  }

  Future<void> guardarCon(WidgetTester t, String precio, String password) async {
    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('precio-Plata')),
        matching: find.byType(TextFormField),
      ),
      precio,
    );
    await t.tap(find.text('Guardar precios'));
    await t.pumpAndSettle();

    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('password-admin')),
        matching: find.byType(TextFormField),
      ),
      password,
    );
    await t.tap(find.text('Confirmar'));
    await t.pumpAndSettle();
  }

  testWidgets('guardar un precio con la contraseña no rompe la pantalla',
      (t) async {
    await montar(t);

    await guardarCon(t, '9000', 'correcta');

    expect(t.takeException(), isNull);
    expect(repo.cambios, [('p', 9000)]);
    expect(find.text('Precio actualizado.'), findsOneWidget);
    expect(find.text('Guardar precios'), findsOneWidget,
        reason: 'el formulario sigue en pantalla después de recargar el perfil');

    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 5));
  });

  testWidgets('con la contraseña equivocada no se guarda nada', (t) async {
    await montar(t);

    await guardarCon(t, '9000', 'equivocada');

    expect(t.takeException(), isNull);
    expect(repo.cambios, isEmpty);
    expect(find.textContaining('La contraseña no es correcta'), findsOneWidget);

    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 5));
  });

  testWidgets('un precio en cero no llega a pedir la contraseña', (t) async {
    await montar(t);

    await t.enterText(
      find.descendant(
        of: find.byKey(const Key('precio-Plata')),
        matching: find.byType(TextFormField),
      ),
      '0',
    );
    await t.tap(find.text('Guardar precios'));
    await t.pumpAndSettle();

    expect(find.text('Confirmá con tu contraseña'), findsNothing);
    expect(find.text('El precio tiene que ser un número entero positivo'),
        findsOneWidget);

    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 5));
  });
}

/// Implementa la interfaz sin heredar: así no crea un `SupabaseClient`, que
/// deja timers vivos al terminar una prueba de widgets.
class _AdminFalso implements AdminRepository {
  final List<(String, int)> cambios = [];
  VoidCallback? alReautenticar;

  @override
  Future<void> reautenticar(String password) async {
    alReautenticar?.call();
    if (password != 'correcta') throw const ReautenticacionFallidaException();
  }

  @override
  Future<PaqueteTokens> actualizarPrecio(String paqueteId, int precio) async {
    cambios.add((paqueteId, precio));
    return PaqueteTokens(
        id: paqueteId, nombre: 'Plata', cantidad: 10, precioArs: precio);
  }

  @override
  Future<List<PaqueteTokens>> paquetes() async => const [];

  @override
  Future<List<Cupon>> cupones() async => const [];

  @override
  Future<Cupon> crearCupon({
    required String codigo,
    required int tokens,
    required DateTime vence,
    int? limiteUsos,
  }) =>
      throw UnimplementedError();

  // Lo que el Sprint 6 sumó al repositorio (CU-34, CU-38) no se usa en esta
  // pantalla.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
