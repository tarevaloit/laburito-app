import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/admin/presentation/screens/denuncias_screen.dart';
import 'package:laburito/features/denuncias/data/denuncias_repository.dart';
import 'package:laburito/features/denuncias/domain/denuncia.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-39 — Gestionar Denuncias.
void main() {
  test('la gravedad y la reputación se leen de denuncias_admin', () {
    final d = DenunciaAdmin.desdeFila({
      'id': 'd1',
      'numero': 1042,
      'gravedad': 3,
      'denunciante': 'Pedro López',
      'denunciante_tipo': 'buscador',
      'denunciado_id': 'u9',
      'denunciado': 'Juan Ramírez',
      'denunciado_tipo': 'profesional',
      'reputacion': 3.2,
      'denuncias_previas': 2,
      'motivo': 'estafa',
      'descripcion': 'Me cobró y no vino.',
      'estado': 'pendiente',
      'created_at': '2026-10-27T10:00:00Z',
    });
    expect(d.gravedad, GravedadDenuncia.grave);
    expect(d.reputacion, 3.2);
    expect(d.abierta, isTrue);
    expect(GravedadDenuncia.desde(1), GravedadDenuncia.baja);
  });

  group('recorrido', () {
    late _DenunciasFalso repo;

    final grave = DenunciaAdmin(
      id: 'd1',
      numero: 1042,
      gravedad: GravedadDenuncia.grave,
      denunciante: 'Pedro López',
      denuncianteTipo: 'buscador',
      denunciadoId: 'u9',
      denunciado: 'Juan Ramírez',
      denunciadoTipo: 'profesional',
      reputacion: 3.2,
      denunciasPrevias: 2,
      motivo: MotivoDenuncia.incumplimiento,
      descripcion: 'Acordamos el martes y nunca apareció.',
      estado: 'pendiente',
      creadaAt: DateTime(2026, 10, 27, 9),
    );

    Future<void> montar(WidgetTester t, List<DenunciaAdmin> lista) async {
      t.view.physicalSize = const Size(1400, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      repo = _DenunciasFalso(lista);
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
          denunciasRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(theme: AppTheme.claro, home: const DenunciasScreen()),
      ));
      await t.pumpAndSettle();
    }

    testWidgets('detalle con gravedad, descargo y reputación', (t) async {
      await montar(t, [grave]);

      expect(find.text('Denuncia #1042'), findsOneWidget);
      expect(find.text('Grave'), findsNWidgets(2));
      expect(find.text('«Acordamos el martes y nunca apareció.»'), findsOneWidget);
      expect(find.text('★ 3.2 · 2 denuncias previas'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('suspender desde la denuncia resuelve con la sanción', (t) async {
      await montar(t, [grave]);

      await t.tap(find.byKey(const Key('suspender-denunciado')));
      await t.pumpAndSettle();
      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('motivo-suspension')),
            matching: find.byType(TextFormField)),
        'No se presentó al trabajo acordado.',
      );
      await t.tap(find.byKey(const Key('confirmar-suspension')));
      await t.pumpAndSettle();

      final r = repo.resoluciones.single;
      expect(r.$1, 'd1');
      expect(r.$2.suspender, isTrue);
      expect(r.$2.desestimar, isFalse);
      expect(r.$2.dias, 7);
    });

    testWidgets('desestimar pide el motivo (flujo alterno 1.1)', (t) async {
      await montar(t, [grave]);

      await t.tap(find.byKey(const Key('desestimar')));
      await t.pumpAndSettle();
      await t.enterText(
        find.descendant(
            of: find.byKey(const Key('texto-dialogo')),
            matching: find.byType(TextFormField)),
        'No hay pruebas suficientes del incumplimiento.',
      );
      await t.tap(find.byKey(const Key('confirmar-dialogo')));
      await t.pumpAndSettle();

      expect(repo.resoluciones.single.$2.desestimar, isTrue);
    });

    testWidgets('una resuelta muestra la resolución y no las acciones',
        (t) async {
      await montar(t, [
        grave.copyWith(
          estado: 'resuelta',
          resolucion: 'Suspensión de 30 días.',
          resueltaAt: DateTime(2026, 10, 27, 12),
        ),
      ]);

      expect(find.text('Suspensión de 30 días.'), findsOneWidget);
      expect(find.byKey(const Key('marcar-resuelta')), findsNothing);
    });
  });
}

class _DenunciasFalso implements DenunciasRepository {
  _DenunciasFalso(this.lista);

  final List<DenunciaAdmin> lista;
  final resoluciones = <(String, ResolucionDenuncia)>[];

  @override
  Future<List<DenunciaAdmin>> listarAdmin() async => lista;

  @override
  Future<Map<String, dynamic>> trazabilidad(String id) async => {
        'pedido': {'titulo': 'Pérdida de agua', 'estado': 'cerrado'},
        'contactos': 1,
        'eventos': [
          {'de': 'publicado', 'a': 'cerrado', 'motivo': null, 'fecha': '2026-10-26T10:00:00Z'},
        ],
      };

  @override
  Future<void> resolver(String id, ResolucionDenuncia r) async =>
      resoluciones.add((id, r));

  @override
  Future<void> reportar({
    required MotivoDenuncia motivo,
    required String descripcion,
    String? slug,
    String? pedidoId,
  }) async {}
}
