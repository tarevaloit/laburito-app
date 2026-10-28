import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/admin/data/usuarios_repository.dart';
import 'package:laburito/features/admin/presentation/screens/usuarios_screen.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-36 — Suspender Cuenta.
void main() {
  test('el detalle reconoce la sanción vigente', () {
    final d = DetalleUsuario.desdeJson({
      'id': 'u1',
      'nombre': 'Juan',
      'apellido': 'Ramírez',
      'email': 'juan@laburito.test',
      'tipo': 'profesional',
      'estado': 'suspendido',
      'profesional': {
        'estado_verificacion': 'aprobado',
        'calificacion_promedio': 3.2,
        'total_calificaciones': 5,
        'contactos': 8,
      },
      'sanciones': [
        {
          'id': 's2',
          'motivo': 'No se presentó al trabajo.',
          'permanente': false,
          'hasta': '2026-11-03T12:00:00Z',
          'apelable': true,
          'fecha': '2026-10-27T12:00:00Z',
        },
        {
          'id': 's1',
          'motivo': 'Trato inadecuado.',
          'permanente': false,
          'hasta': '2026-09-03T12:00:00Z',
          'apelable': true,
          'levantada_at': '2026-09-03T12:00:00Z',
          'fecha': '2026-09-01T12:00:00Z',
        },
      ],
    });
    expect(d.promedio, 3.2);
    expect(d.sancionVigente?.id, 's2');
    expect(d.usuario.suspendido, isTrue);
  });

  group('recorrido', () {
    late _UsuariosFalso repo;

    Future<void> montar(WidgetTester t, UsuarioAdmin u) async {
      t.view.physicalSize = const Size(1400, 1100);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      repo = _UsuariosFalso(u);
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
          usuariosRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(theme: AppTheme.claro, home: const UsuariosScreen()),
      ));
      await t.pumpAndSettle();
    }

    const juan = UsuarioAdmin(
      id: 'u1',
      nombre: 'Juan',
      apellido: 'Ramírez',
      email: 'juan@laburito.test',
      tipo: 'profesional',
      estado: 'activo',
    );

    testWidgets('elegir, suspender por 15 días sin apelación', (t) async {
      await montar(t, juan);

      await t.tap(find.byKey(const Key('usuario-u1')));
      await t.pumpAndSettle();
      expect(find.text('Sin sanciones previas.'), findsOneWidget);

      await t.tap(find.byKey(const Key('suspender-usuario')));
      await t.pumpAndSettle();

      // Sin motivo no sale.
      await t.tap(find.byKey(const Key('confirmar-suspension')));
      await t.pumpAndSettle();
      expect(repo.suspensiones, isEmpty);

      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('motivo-suspension')),
            matching: find.byType(TextFormField)),
        'No se presentó a tres trabajos acordados.',
      );
      await t.tap(find.byKey(const Key('plazo-suspension')));
      await t.pumpAndSettle();
      await t.tap(find.text('15 días').last);
      await t.pumpAndSettle();
      await t.tap(find.text('Admite apelación'));
      await t.tap(find.byKey(const Key('confirmar-suspension')));
      await t.pumpAndSettle();

      expect(repo.suspensiones, hasLength(1));
      final s = repo.suspensiones.single;
      expect(s.dias, 15);
      expect(s.apelable, isFalse);
      expect(t.takeException(), isNull);
    });

    testWidgets('un administrador no ofrece el botón (flujo 1.1)', (t) async {
      await montar(
        t,
        const UsuarioAdmin(
          id: 'u1',
          nombre: 'Otro',
          apellido: 'Admin',
          email: 'otro@laburito.test',
          tipo: 'administrador',
          estado: 'activo',
        ),
      );

      await t.tap(find.byKey(const Key('usuario-u1')));
      await t.pumpAndSettle();

      expect(find.byKey(const Key('suspender-usuario')), findsNothing);
      expect(find.textContaining('SuperAdmin'), findsOneWidget);
    });
  });
}

class _UsuariosFalso implements UsuariosRepository {
  _UsuariosFalso(this.usuario);

  final UsuarioAdmin usuario;
  final suspensiones = <SuspensionPedida>[];

  @override
  Future<List<UsuarioAdmin>> buscar({String? texto, String? tipo}) async =>
      [usuario];

  @override
  Future<DetalleUsuario> detalle(String id) async => DetalleUsuario(usuario: usuario);

  @override
  Future<void> suspender(String perfilId, SuspensionPedida s,
          {String? denunciaId}) async =>
      suspensiones.add(s);

  @override
  Future<void> levantar(String sancionId, String motivo) async {}
}
