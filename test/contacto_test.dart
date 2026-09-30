import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/profesional/data/contacto_repository.dart';
import 'package:laburito/features/profesional/domain/contacto_buscador.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-25 — Postularse (Desbloquear Contacto).
void main() {
  group('número para WhatsApp', () {
    test('todas las formas de escribir un celular de AMBA dan el mismo número',
        () {
      for (final escrito in [
        '11 2345-6789',
        '011 2345 6789',
        '11 15 2345-6789',
        '011 15 2345 6789',
        '+54 9 11 2345 6789',
        '+54 11 2345 6789',
        '5491123456789',
        '(011) 15-2345-6789',
      ]) {
        expect(numeroParaWhatsApp(escrito), '5491123456789', reason: escrito);
      }
    });

    test('característica de 3 y 4 dígitos, con y sin 15', () {
      expect(numeroParaWhatsApp('0351 15 234-5678'), '5493512345678');
      expect(numeroParaWhatsApp('351 234 5678'), '5493512345678');
      expect(numeroParaWhatsApp('02966 15 23-4567'), '5492966234567');
    });

    test('un número que no se puede armar no abre WhatsApp', () {
      expect(numeroParaWhatsApp('1234'), isNull);
      expect(numeroParaWhatsApp(''), isNull);
      expect(numeroParaWhatsApp('11 2345 6789 0000'), isNull);
    });

    test('el enlace lleva el número y un saludo con el título del pedido', () {
      const contacto = ContactoBuscador(
        nombreCorto: 'Laura G.',
        telefono: '11 2345-6789',
        desbloqueado: true,
      );

      final enlace =
          contacto.enlaceWhatsApp(tituloPedido: 'Pérdida bajo la pileta')!;

      expect(enlace.host, 'wa.me');
      expect(enlace.path, '/5491123456789');
      expect(enlace.queryParameters['text'], contains('Hola Laura'));
      expect(enlace.queryParameters['text'], contains('Pérdida bajo la pileta'));
    });

    test('sin teléfono entero (no desbloqueado) no hay enlace', () {
      const contacto = ContactoBuscador(
        nombreCorto: 'Laura G.',
        telefonoEnmascarado: '+5491 ••••••',
      );
      expect(contacto.enlaceWhatsApp(tituloPedido: 'x'), isNull);
    });
  });

  group('repositorio', () {
    late _ServidorFalso servidor;
    late ContactoRepository repo;

    setUp(() {
      servidor = _ServidorFalso();
      repo = ContactoRepository(SupabaseClient(
        'https://proyecto.supabase.co',
        'clave-anon-de-mentira',
        httpClient: MockClient(servidor.responder),
      ));
    });

    test('antes de pagar llega el teléfono enmascarado y no el entero',
        () async {
      final contacto = await repo.contacto('pedido-1');

      expect(contacto!.desbloqueado, isFalse);
      expect(contacto.nombreCorto, 'Laura G.');
      expect(contacto.telefonoEnmascarado, '+5491 ••••••');
      expect(contacto.telefono, isNull);
    });

    test('un pedido que ya no se ve y no se había desbloqueado da null',
        () async {
      expect(await repo.contacto('pedido-cerrado'), isNull);
    });

    test('desbloquear devuelve el teléfono, el saldo y si se cobró', () async {
      final resultado = await repo.desbloquear('pedido-1');

      expect(resultado.contacto.telefono, '11 2345-6789');
      expect(resultado.contacto.desbloqueado, isTrue);
      expect(resultado.saldo, 11);
      expect(resultado.cobrado, isTrue);
    });

    test('sin saldo, la excepción es la que ofrece ir a comprar', () async {
      servidor.sinSaldo = true;

      await expectLater(
        repo.desbloquear('pedido-1'),
        throwsA(isA<SaldoInsuficienteException>()),
      );
    });

    test('cualquier otro rechazo llega como el P0001 del servidor', () async {
      servidor.sinVerificar = true;

      await expectLater(
        repo.desbloquear('pedido-1'),
        throwsA(isA<PostgrestException>()
            .having((e) => e.hint, 'hint', 'sin_verificar')),
      );
    });

    test('el dueño ve cuántos Profesionales desbloquearon', () async {
      expect(await repo.interesados('pedido-1'), 2);
    });
  });
}

class _ServidorFalso {
  bool sinSaldo = false;
  bool sinVerificar = false;

  Future<http.Response> responder(http.Request pedido) async {
    final ruta = pedido.url.path;
    final params = pedido.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(pedido.body) as Map<String, dynamic>;

    switch (ruta) {
      case '/rest/v1/rpc/contacto_pedido':
        return _json(
          pedido,
          params['p_pedido'] == 'pedido-cerrado'
              ? <dynamic>[]
              : [
                  {
                    'nombre_corto': 'Laura G.',
                    'telefono_enmascarado': '+5491 ••••••',
                    'telefono': null,
                    'desbloqueado': false,
                  },
                ],
          200,
        );

      case '/rest/v1/rpc/desbloquear_contacto':
        if (sinSaldo) {
          return _json(pedido, {
            'code': 'P0001',
            'message': 'No te alcanzan los tokens. Cargá más desde tu billetera.',
            'hint': 'saldo_insuficiente',
          }, 400);
        }
        if (sinVerificar) {
          return _json(pedido, {
            'code': 'P0001',
            'message': 'Tu cuenta tiene que estar verificada.',
            'hint': 'sin_verificar',
          }, 400);
        }
        return _json(pedido, [
          {
            'nombre_corto': 'Laura G.',
            'telefono': '11 2345-6789',
            'saldo': 11,
            'cobrado': true,
          },
        ], 200);

      case '/rest/v1/rpc/interesados_pedido':
        return _json(pedido, 2, 200);
    }

    return _json(pedido, <dynamic>[], 200);
  }

  http.Response _json(http.Request pedido, Object cuerpo, int codigo) =>
      http.Response(
        jsonEncode(cuerpo),
        codigo,
        headers: {'content-type': 'application/json'},
        request: pedido,
      );
}
