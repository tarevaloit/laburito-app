import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/core/config/contacto.dart';
import 'package:laburito/features/admin/data/usuarios_repository.dart';
import 'package:laburito/features/admin/presentation/screens/denuncias_screen.dart';
import 'package:laburito/features/denuncias/data/denuncias_repository.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';
import 'package:laburito/features/perfil/data/suspension_repository.dart';
import 'package:laburito/features/perfil/presentation/screens/cuenta_suspendida_screen.dart';

/// CU-49 — Recuperar Cuenta Bloqueada.
void main() {
  group('modelo', () {
    test('una cuenta activa no trae suspensión', () {
      expect(MiSuspension.desdeJson({'estado': 'activo'}), isNull);
    });

    test('con apelación pendiente no se ofrece apelar otra vez', () {
      final s = MiSuspension.desdeJson({
        'estado': 'suspendido',
        'sancion': {
          'motivo': 'Trato inadecuado.',
          'permanente': false,
          'hasta': '2026-11-27T12:00:00Z',
          'apelable': true,
        },
        'apelacion': {'numero': 1001, 'estado': 'pendiente'},
      })!;
      expect(s.puedeApelar, isFalse);
      expect(s.apelacion!.numero, 1001);
    });

    test('rechazada la apelación, se puede volver a apelar', () {
      final s = MiSuspension.desdeJson({
        'estado': 'suspendido',
        'sancion': {'motivo': 'x', 'permanente': true, 'apelable': true},
        'apelacion': {'numero': 1001, 'estado': 'rechazada', 'respuesta': 'No.'},
      })!;
      expect(s.puedeApelar, isTrue);
    });
  });

  group('pantalla de la cuenta suspendida', () {
    late _SuspensionFalsa repo;

    Future<void> montar(WidgetTester t, MiSuspension? s) async {
      repo = _SuspensionFalsa(s);
      await t.pumpWidget(ProviderScope(
        overrides: [suspensionRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
            theme: AppTheme.claro, home: const CuentaSuspendidaScreen()),
      ));
      await t.pumpAndSettle();
    }

    testWidgets('motivo, apelación y número de trámite (pasos 2 a 6)',
        (t) async {
      await montar(
        t,
        MiSuspension(
          motivo: 'Trato inadecuado con un Profesional.',
          permanente: false,
          apelable: true,
          hasta: DateTime.utc(2026, 11, 27, 15),
        ),
      );

      expect(find.textContaining('hasta el 27 de noviembre de 2026'), findsOneWidget);
      expect(find.text('Motivo: Trato inadecuado con un Profesional.'), findsOneWidget);

      await t.tap(find.byKey(const Key('apelar-sancion')));
      await t.pumpAndSettle();
      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('descargo')),
            matching: find.byType(TextFormField)),
        'Nunca falté el respeto: tengo los mensajes.',
      );
      await t.tap(find.byKey(const Key('enviar-apelacion')));
      await t.pumpAndSettle();

      expect(repo.descargos, ['Nunca falté el respeto: tengo los mensajes.']);
      expect(find.textContaining('#1001'), findsWidgets);
      expect(t.takeException(), isNull);
    });

    testWidgets('un descargo corto no sale', (t) async {
      await montar(
        t,
        const MiSuspension(motivo: 'x', permanente: true, apelable: true),
      );
      await t.tap(find.byKey(const Key('apelar-sancion')));
      await t.pumpAndSettle();
      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('descargo')),
            matching: find.byType(TextFormField)),
        'Fue un error.',
      );
      await t.tap(find.byKey(const Key('enviar-apelacion')));
      await t.pumpAndSettle();

      expect(repo.descargos, isEmpty);
      expect(find.text('Escribilo en al menos 20 caracteres.'), findsOneWidget);
    });

    testWidgets('inapelable: sin botón y con el correo legal (flujo 1.1)',
        (t) async {
      await montar(
        t,
        const MiSuspension(motivo: 'Estafa comprobada.', permanente: true, apelable: false),
      );

      expect(find.byKey(const Key('apelar-sancion')), findsNothing);
      expect(find.text(Contacto.correoLegales), findsOneWidget);
      expect(find.textContaining('forma permanente'), findsOneWidget);
    });

    testWidgets('con la apelación en revisión se ve el trámite', (t) async {
      await montar(
        t,
        const MiSuspension(
          motivo: 'x',
          permanente: true,
          apelable: true,
          apelacion: MiApelacion(numero: 1007, estado: 'pendiente'),
        ),
      );

      expect(find.text('Tu apelación #1007 está en revisión'), findsOneWidget);
      expect(find.byKey(const Key('apelar-sancion')), findsNothing);
    });
  });

  testWidgets('el admin acepta la apelación desde Denuncias', (t) async {
    t.view.physicalSize = const Size(1400, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final usuarios = _UsuariosFalso();
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
        denunciasAdminProvider.overrideWith((ref) async => const []),
        usuariosRepositoryProvider.overrideWithValue(usuarios),
      ],
      child: MaterialApp(
        theme: AppTheme.claro,
        home: const DenunciasScreen(pestanaInicial: 1),
      ),
    ));
    await t.pumpAndSettle();

    expect(find.text('Apelación #1001 · Laura Gómez'), findsOneWidget);
    await t.tap(find.byKey(const Key('aceptar-1001')));
    await t.pumpAndSettle();
    await t.enterText(
      find.descendant(
          of: find.byKey(const Key('texto-dialogo')),
          matching: find.byType(TextFormField)),
      'Revisamos los mensajes y la sanción no corresponde.',
    );
    await t.tap(find.byKey(const Key('confirmar-dialogo')));
    await t.pumpAndSettle();

    expect(usuarios.resueltas, [('a1', true)]);
  });
}

class _SuspensionFalsa implements SuspensionRepository {
  _SuspensionFalsa(this.suspension);

  MiSuspension? suspension;
  final descargos = <String>[];

  @override
  Future<MiSuspension?> revisar() async => suspension;

  @override
  Future<int> apelar(String descargo) async {
    descargos.add(descargo);
    final s = suspension!;
    suspension = MiSuspension(
      motivo: s.motivo,
      permanente: s.permanente,
      apelable: s.apelable,
      hasta: s.hasta,
      apelacion: const MiApelacion(numero: 1001, estado: 'pendiente'),
    );
    return 1001;
  }
}

class _UsuariosFalso implements UsuariosRepository {
  final resueltas = <(String, bool)>[];

  @override
  Future<List<ApelacionAdmin>> apelaciones() async => [
        ApelacionAdmin(
          id: 'a1',
          numero: 1001,
          usuarioId: 'u1',
          usuario: 'Laura Gómez',
          sancionMotivo: 'Trato inadecuado.',
          permanente: false,
          hasta: DateTime(2026, 11, 27),
          descargo: 'Nunca falté el respeto: tengo los mensajes.',
          estado: resueltas.isEmpty ? 'pendiente' : 'aceptada',
          fecha: DateTime(2026, 10, 27),
        ),
      ];

  @override
  Future<void> resolverApelacion(String id,
          {required bool aceptar, required String respuesta}) async =>
      resueltas.add((id, aceptar));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
