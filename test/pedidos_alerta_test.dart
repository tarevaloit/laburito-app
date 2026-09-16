import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/pedidos/data/pedidos_repository.dart';
import 'package:laburito/features/pedidos/domain/pedido.dart';
import 'package:laburito/features/pedidos/domain/ubicacion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-21 c — El disparo de la alerta al publicar.
///
/// Dos propiedades, y las dos importan:
///
///   * el cliente manda **solo el id del pedido**. Si algún día apareciera una
///     lista de destinatarios en el cuerpo, sería un cliente decidiendo a quién
///     se le avisa, que es justo lo que el diseño evita;
///   * si la alerta falla, el pedido igual queda publicado. Es lo que la
///     persona pidió, y el Profesional lo ve igual entrando al tablero.
void main() {
  late _ServidorFalso servidor;
  late PedidosRepository repo;

  Future<Pedido> publicar() async => repo.crearPedido(
        categoriaId: _ServidorFalso.categoriaId,
        titulo: 'Se me tapó la cocina',
        descripcion:
            'La pileta no traga y el agua vuelve. Necesito un plomero.',
        ubicacion: const Ubicacion(
          lat: -34.5136,
          lng: -58.7645,
          direccionTexto: 'Av. Croacia 1200, José C. Paz',
        ),
        fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
      );

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
        'id': _ServidorFalso.buscadorId,
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
        'aud': 'authenticated',
        'created_at': '2026-09-01T10:00:00Z',
      },
    }));

    repo = PedidosRepository(client);
  });

  test('publicar dispara la Edge Function con el id y nada más', () async {
    final pedido = await publicar();

    expect(
      servidor.llamadas,
      contains('POST /functions/v1/emparejar_pedido'),
    );
    expect(servidor.cuerpoDeLaFuncion, {'pedido_id': pedido.id});
  });

  test('si la alerta falla, el pedido igual queda publicado', () async {
    servidor.fallarLaFuncion = true;

    final pedido = await publicar();

    expect(pedido.titulo, 'Se me tapó la cocina');
    expect(
      servidor.llamadas,
      contains('POST /functions/v1/emparejar_pedido'),
      reason: 'se intentó, y el fallo quedó en la consola',
    );
  });
}

class _ServidorFalso {
  static const String buscadorId = '11111111-1111-4111-8111-111111111111';
  static const String categoriaId = '22222222-2222-4222-8222-222222222222';
  static const String pedidoId = '33333333-3333-4333-8333-333333333333';

  final List<String> llamadas = [];
  Map<String, dynamic>? cuerpoDeLaFuncion;
  bool fallarLaFuncion = false;

  Future<http.Response> responder(http.Request pedido) async {
    llamadas.add('${pedido.method} ${pedido.url.path}');

    if (pedido.url.path == '/functions/v1/emparejar_pedido') {
      cuerpoDeLaFuncion = jsonDecode(pedido.body) as Map<String, dynamic>;

      return _json(
        pedido,
        fallarLaFuncion
            ? {'error': 'algo salió mal del otro lado'}
            : {'profesionales': 2, 'dispositivos': 2, 'enviadas': 2},
        fallarLaFuncion ? 500 : 200,
      );
    }

    if (pedido.url.path == '/rest/v1/rpc/crear_pedido') {
      final params = jsonDecode(pedido.body) as Map<String, dynamic>;
      final ahora = DateTime.now().toUtc().toIso8601String();

      return _json(pedido, {
        'id': pedidoId,
        'buscador_id': buscadorId,
        'categoria_id': params['p_categoria_id'],
        'titulo': params['p_titulo'],
        'descripcion': params['p_descripcion'],
        'urgencia': params['p_urgencia'] ?? 'media',
        'estado': 'publicado',
        'direccion_texto': params['p_direccion_texto'],
        'referencia_ubicacion': params['p_referencia'],
        'presupuesto_estimado': params['p_presupuesto'],
        'fecha_publicacion': ahora,
        'fecha_vencimiento': params['p_fecha_vencimiento'],
        'fecha_cierre': null,
        'motivo_cierre': null,
        'renovaciones': 0,
        'created_at': ahora,
        'updated_at': ahora,
        'lat': params['p_lat'],
        'lng': params['p_lng'],
      }, 200);
    }

    return _json(
      pedido,
      {'message': 'ruta no prevista por el test: ${pedido.url.path}'},
      404,
    );
  }

  http.Response _json(http.Request pedido, Object cuerpo, int codigo) =>
      http.Response(
        jsonEncode(cuerpo),
        codigo,
        headers: {'content-type': 'application/json'},
        request: pedido,
      );
}
