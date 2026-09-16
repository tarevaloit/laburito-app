import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/core/errors/mensajes_error.dart';
import 'package:laburito/features/categorias/data/categorias_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-12 — Editar Categorías de Oficio.
///
/// Lo que se prueba acá es el **camino**: que el reemplazo salga en una sola
/// llamada a la RPC de la migración 0015 y no como un DELETE y un INSERT
/// sueltos, que es lo que había. Esa diferencia no se ve en pantalla: se ve el
/// día que la segunda escritura falla y el Profesional se queda sin oficios,
/// y por lo tanto sin alertas del CU-21.
///
/// Que la RPC sea de verdad transaccional lo prueba su guion de aceptación
/// contra la base, no este archivo.
void main() {
  late _ServidorFalso servidor;
  late CategoriasRepository repo;

  setUp(() async {
    servidor = _ServidorFalso();

    final client = SupabaseClient(
      'https://proyecto.supabase.co',
      'clave-anon-de-mentira',
      httpClient: MockClient(servidor.responder),
    );

    await client.auth.setInitialSession(jsonEncode({
      'access_token': 'token-de-mentira',
      'token_type': 'bearer',
      'refresh_token': 'refresh-de-mentira',
      'expires_in': 3600,
      'user': {
        'id': _ServidorFalso.profesionalId,
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
        'aud': 'authenticated',
        'created_at': '2026-09-01T10:00:00Z',
      },
    }));

    repo = CategoriasRepository(client);
  });

  test('el reemplazo es una sola llamada a la RPC, no un delete y un insert',
      () async {
    await repo.reemplazar(slugs: ['plomeria', 'gas']);

    expect(servidor.llamadas, ['POST /rest/v1/rpc/reemplazar_categorias_oficio']);
    expect(servidor.ultimosParams['p_slugs'], ['plomeria', 'gas']);
  });

  test('devuelve los oficios que quedaron guardados, leídos del servidor',
      () async {
    // El servidor contesta en el orden del catálogo, que no es el orden en que
    // se tocaron las píldoras: la pantalla muestra lo que quedó, no lo que se
    // mandó.
    servidor.responderCon = ['electricidad', 'gas', 'plomeria'];

    final guardados = await repo.reemplazar(
      slugs: ['plomeria', 'gas', 'electricidad'],
    );

    expect(guardados, ['electricidad', 'gas', 'plomeria']);
  });

  test('el id del Profesional no viaja: lo pone auth.uid() en el servidor',
      () async {
    await repo.reemplazar(slugs: ['plomeria']);

    expect(
      servidor.ultimosParams.keys,
      ['p_slugs'],
      reason: 'sin id en el payload no hay forma de editarle los oficios a otro',
    );
  });

  test('el error de la RPC llega con su mensaje, listo para la pantalla',
      () async {
    servidor.rechazarConP0001 = 'Podés elegir hasta 5 oficios';

    Object? capturado;
    try {
      await repo.reemplazar(slugs: ['uno', 'dos', 'tres', 'cuatro', 'cinco', 'seis']);
    } on Object catch (e) {
      capturado = e;
    }

    expect(capturado, isA<PostgrestException>());
    expect(MensajesError.desde(capturado!), 'Podés elegir hasta 5 oficios');
  });

  test('el tope del cliente es el mismo que aplica la migración 0015', () {
    // Si alguien sube el tope de la pantalla y se olvida de la RPC, el
    // servidor rechaza un guardado que la UI dejó armar. La constante es una
    // sola y vive acá.
    expect(CategoriaOficio.maximoPorProfesional, 5);
  });
}

/// El Supabase mínimo del CU-12: solo la RPC. Cualquier otra ruta es un 404,
/// así que si el repositorio vuelve al DELETE + INSERT, el test se entera.
class _ServidorFalso {
  static const String profesionalId = '44444444-4444-4444-8444-444444444444';

  final List<String> llamadas = [];
  Map<String, dynamic> ultimosParams = const {};
  List<String>? responderCon;
  String? rechazarConP0001;

  Future<http.Response> responder(http.Request pedido) async {
    llamadas.add('${pedido.method} ${pedido.url.path}');

    if (pedido.url.path == '/rest/v1/rpc/reemplazar_categorias_oficio') {
      ultimosParams = jsonDecode(pedido.body) as Map<String, dynamic>;

      if (rechazarConP0001 != null) {
        return _respuesta(
          pedido,
          {
            'code': 'P0001',
            'message': rechazarConP0001,
            'hint': 'limite_categorias',
            'details': null,
          },
          400,
        );
      }

      return _respuesta(
        pedido,
        responderCon ?? (ultimosParams['p_slugs'] as List).cast<String>(),
        200,
      );
    }

    return _respuesta(
      pedido,
      {'message': 'ruta no prevista por el test: ${pedido.url.path}'},
      404,
    );
  }

  http.Response _respuesta(http.Request pedido, Object cuerpo, int codigo) =>
      http.Response(
        jsonEncode(cuerpo),
        codigo,
        headers: {'content-type': 'application/json'},
        request: pedido,
      );
}
