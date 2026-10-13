import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/billetera/data/billetera_repository.dart';
import 'package:laburito/features/pedidos/data/enlace_gestion_repository.dart';
import 'package:laburito/features/pedidos/presentation/screens/recuperar_pedido_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-18 — Solicitar Reenvío de Enlace de Gestión.
void main() {
  const generico = 'Si tenés un pedido activo, vas a recibir un correo en breve.';

  group('repositorio', () {
    late List<Object?> cuerpos;
    late EnlaceGestionRepository repo;

    setUp(() {
      cuerpos = [];
      repo = EnlaceGestionRepository(SupabaseClient(
        'https://proyecto.supabase.co',
        'clave-anon-de-mentira',
        httpClient: MockClient((pedido) async {
          final cuerpo = jsonDecode(pedido.body) as Map<String, dynamic>;
          cuerpos.add(cuerpo);
          final invalido = !(cuerpo['email'] as String).contains('@');
          return http.Response(
            jsonEncode(invalido
                ? {'error': 'Ingresá un correo electrónico válido.', 'codigo': 'email_invalido'}
                : {'mensaje': generico}),
            invalido ? 400 : 200,
            headers: {'content-type': 'application/json'},
            request: pedido,
          );
        }),
      ));
    });

    test('manda el correo recortado y devuelve el mensaje genérico', () async {
      expect(await repo.reenviar('  laura@correo.com '), generico);
      expect(cuerpos.single, {'email': 'laura@correo.com'});
    });

    test('un correo mal escrito llega como ErrorDeFuncion', () async {
      await expectLater(
        repo.reenviar('no-es-correo'),
        throwsA(isA<ErrorDeFuncion>()
            .having((e) => e.codigo, 'codigo', 'email_invalido')),
      );
    });
  });

  testWidgets('recorrido: correo → mensaje genérico, sin revelar si existe',
      (t) async {
    final repo = _RepoFalso();
    await t.pumpWidget(ProviderScope(
      overrides: [enlaceGestionRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: RecuperarPedidoScreen()),
    ));

    await t.tap(find.text('Enviar link'));
    await t.pumpAndSettle();
    expect(repo.correos, isEmpty, reason: 'sin correo no se envía');

    await t.enterText(find.byType(TextFormField), 'laura@correo.com');
    await t.tap(find.text('Enviar link'));
    await t.pumpAndSettle();

    expect(repo.correos, ['laura@correo.com']);
    expect(find.text(generico), findsOneWidget);
    expect(find.text('Enviar link'), findsNothing);
  });
}

class _RepoFalso implements EnlaceGestionRepository {
  final correos = <String>[];

  @override
  Future<String> reenviar(String email) async {
    correos.add(email);
    return 'Si tenés un pedido activo, vas a recibir un correo en breve.';
  }
}
