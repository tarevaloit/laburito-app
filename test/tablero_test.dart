import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/pedidos/domain/pedido_estado.dart';
import 'package:laburito/features/profesional/data/tablero_repository.dart';
import 'package:laburito/features/profesional/domain/pedido_tablero.dart';
import 'package:laburito/features/profesional/presentation/controllers/tablero_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-43 y CU-22 — El tablero del Profesional.
void main() {
  group('dominio', () {
    PedidoTablero conDistancia(double? metros) => PedidoTablero.desdeFila({
          ..._fila('11111111-1111-4111-8111-111111111111'),
          'distancia_m': metros,
        });

    test('la distancia se dice en metros abajo del kilómetro y en km arriba',
        () {
      expect(conDistancia(0).distanciaLegible, 'En tu zona');
      expect(conDistancia(80).distanciaLegible, 'En tu zona');
      expect(conDistancia(800).distanciaLegible, 'A 800 m');
      expect(conDistancia(1500).distanciaLegible, 'A 1,5 km');
      expect(conDistancia(23400).distanciaLegible, 'A 23 km');
    });

    test('sin zona configurada no hay distancia que mostrar', () {
      expect(conDistancia(null).distanciaLegible, isNull);
    });

    test('la fila trae la ubicación aproximada y no la exacta', () {
      final pedido = PedidoTablero.desdeFila(_fila('x'));

      // Tres decimales es lo que devuelve `pedidos_publicos`: la pantalla no
      // tiene forma de mostrar el domicilio porque nunca lo recibe.
      expect(pedido.ubicacionAproximada.lat, -34.559);
      expect(pedido.ubicacionAproximada.lng, -58.445);
      expect(pedido.urgencia, PedidoUrgencia.alta);
      expect(pedido.cantidadFotos, 2);
    });
  });

  group('repositorio y paginado', () {
    late _ServidorFalso servidor;
    late ProviderContainer container;

    setUp(() async {
      servidor = _ServidorFalso();

      final client = SupabaseClient(
        'https://proyecto.supabase.co',
        'clave-anon-de-mentira',
        httpClient: MockClient(servidor.responder),
      );

      // Las marcas del CU-23 y del CU-24 escriben `profesional_id` con el id
      // de la sesión, así que el cliente de prueba necesita una.
      await client.auth.setInitialSession(jsonEncode({
        'access_token': 'token-de-mentira',
        'token_type': 'bearer',
        'refresh_token': 'refresh-de-mentira',
        'expires_in': 3600,
        'user': {
          'id': '44444444-4444-4444-8444-444444444444',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'aud': 'authenticated',
          'created_at': '2026-09-01T10:00:00Z',
        },
      }));

      container = ProviderContainer(
        overrides: [
          tableroRepositoryProvider.overrideWithValue(
            TableroRepository(client),
          ),
        ],
      );
      addTearDown(container.dispose);
    });

    test('la primera página pide 20 y filtra por los oficios propios',
        () async {
      servidor.cantidad = 20;

      final estado = await container.read(tableroProvider.future);

      expect(estado.pedidos, hasLength(20));
      expect(estado.hayMas, isTrue, reason: 'una página llena invita a la que sigue');
      expect(servidor.ultimosParams['p_limite'], 20);
      expect(servidor.ultimosParams['p_desplazamiento'], 0);
      expect(servidor.ultimosParams['p_solo_mis_oficios'], isTrue);
      expect(servidor.ultimosParams['p_solo_guardados'], isFalse);
    });

    test('una página incompleta corta el scroll infinito', () async {
      servidor.cantidad = 7;

      final estado = await container.read(tableroProvider.future);

      expect(estado.hayMas, isFalse);

      await container.read(tableroProvider.notifier).cargarMas();
      expect(servidor.llamadas, hasLength(1), reason: 'no se pide de más');
    });

    test('cargar más pide desde donde quedó y acumula', () async {
      servidor.cantidad = 20;
      await container.read(tableroProvider.future);

      await container.read(tableroProvider.notifier).cargarMas();

      expect(servidor.ultimosParams['p_desplazamiento'], 20);
      expect(
        container.read(tableroProvider).value!.pedidos,
        hasLength(40),
      );
    });

    test('el filtro «Guardados» cambia los parámetros y reinicia la lista',
        () async {
      servidor.cantidad = 20;
      await container.read(tableroProvider.future);

      servidor.cantidad = 2;
      await container
          .read(tableroProvider.notifier)
          .cambiarFiltro(FiltroTablero.guardados);

      final estado = container.read(tableroProvider).value!;
      expect(estado.filtro, FiltroTablero.guardados);
      expect(estado.pedidos, hasLength(2));
      expect(servidor.ultimosParams['p_solo_guardados'], isTrue);
      expect(servidor.ultimosParams['p_desplazamiento'], 0);
    });

    test('guardar se pinta al toque y escribe el favorito', () async {
      servidor.cantidad = 3;
      await container.read(tableroProvider.future);

      final id = container.read(tableroProvider).value!.pedidos.first.id;
      await container.read(tableroProvider.notifier).alternarGuardado(id);

      expect(
        container.read(tableroProvider).value!.pedidos.first.guardado,
        isTrue,
      );
      expect(servidor.llamadas, contains('POST /rest/v1/pedido_favorito'));
    });

    test('ignorar saca el pedido de la lista y lo quita de guardados primero',
        () async {
      servidor.cantidad = 3;
      await container.read(tableroProvider.future);

      final id = container.read(tableroProvider).value!.pedidos.first.id;
      final ok = await container.read(tableroProvider.notifier).ignorar(id);

      expect(ok, isTrue);
      expect(container.read(tableroProvider).value!.pedidos, hasLength(2));
      expect(
        servidor.llamadas,
        containsAllInOrder([
          'DELETE /rest/v1/pedido_favorito',
          'POST /rest/v1/pedido_ignorado',
        ]),
        reason: 'un pedido descartado y marcado como interesante a la vez no '
            'significa nada, y la solapa de guardados lo seguiría mostrando',
      );
    });

    test('si ignorar falla, el pedido vuelve a la lista', () async {
      servidor.cantidad = 3;
      await container.read(tableroProvider.future);

      final id = container.read(tableroProvider).value!.pedidos.first.id;
      servidor.fallarEscrituras = true;
      final ok = await container.read(tableroProvider.notifier).ignorar(id);

      expect(ok, isFalse);
      expect(container.read(tableroProvider).value!.pedidos, hasLength(3));
      expect(container.read(tableroProvider).value!.error, isNotNull);
    });

    test('deshacer borra la marca y vuelve a pedir la página', () async {
      servidor.cantidad = 3;
      await container.read(tableroProvider.future);

      final id = container.read(tableroProvider).value!.pedidos.first.id;
      await container.read(tableroProvider.notifier).ignorar(id);
      await container.read(tableroProvider.notifier).dejarDeIgnorar(id);

      expect(servidor.llamadas, contains('DELETE /rest/v1/pedido_ignorado'));
      expect(
        container.read(tableroProvider).value!.pedidos,
        hasLength(3),
        reason: 'el pedido vuelve a su lugar por distancia, no al final',
      );
    });

    test('en la solapa de guardados, desmarcar saca el pedido de la lista',
        () async {
      servidor.cantidad = 3;
      await container.read(tableroProvider.future);
      await container
          .read(tableroProvider.notifier)
          .cambiarFiltro(FiltroTablero.guardados);

      final id = container.read(tableroProvider).value!.pedidos.first.id;
      await container.read(tableroProvider.notifier).alternarGuardado(id);

      expect(container.read(tableroProvider).value!.pedidos, hasLength(2));
    });

    test('el detalle de un pedido que ya no está devuelve null, no un error',
        () async {
      servidor.detalleVacio = true;

      final detalle = await container
          .read(tableroRepositoryProvider)
          .detalle('11111111-1111-4111-8111-111111111111');

      expect(detalle, isNull);
    });
  });
}

Map<String, dynamic> _fila(String id) => {
      'id': id,
      'titulo': 'Se me tapó la cocina',
      'descripcion': 'La pileta no traga y el agua vuelve.',
      'urgencia': 'alta',
      'categoria_id': '22222222-2222-4222-8222-222222222222',
      'categoria_nombre': 'Plomería',
      'lat': -34.559,
      'lng': -58.445,
      'direccion_texto': 'José C. Paz',
      'presupuesto_estimado': 15000,
      'fecha_publicacion': '2026-09-15T10:00:00Z',
      'fecha_vencimiento': '2026-09-30T10:00:00Z',
      'cantidad_fotos': 2,
      'distancia_m': 800,
      'guardado': false,
      'portada': 'ruta/portada.jpg',
    };

class _ServidorFalso {
  final List<String> llamadas = [];
  Map<String, dynamic> ultimosParams = const {};
  int cantidad = 0;
  bool detalleVacio = false;
  bool fallarEscrituras = false;

  Future<http.Response> responder(http.Request pedido) async {
    // Las marcas del CU-23 y del CU-24 no son RPC: son un insert y un delete
    // sobre las tablas de la 0012, así que acá se las reconoce por la ruta.
    if (pedido.url.path.startsWith('/rest/v1/pedido_')) {
      llamadas.add('${pedido.method} ${pedido.url.path}');

      return http.Response(
        fallarEscrituras ? jsonEncode({'message': 'no'}) : '[]',
        fallarEscrituras ? 400 : 201,
        headers: {'content-type': 'application/json'},
        request: pedido,
      );
    }

    llamadas.add(pedido.url.path);
    ultimosParams = jsonDecode(pedido.body) as Map<String, dynamic>;

    // En la solapa de guardados, todo lo que vuelve está guardado: es lo que
    // hace `tablero_pedidos()` con `p_solo_guardados`.
    final guardados = ultimosParams['p_solo_guardados'] == true;

    final cuerpo = pedido.url.path == '/rest/v1/rpc/pedido_publico'
        ? (detalleVacio ? <dynamic>[] : [_fila('detalle')])
        : [
            for (var i = 0; i < cantidad; i++)
              {..._fila('pedido-$i'), 'guardado': guardados},
          ];

    return http.Response(
      jsonEncode(cuerpo),
      200,
      headers: {'content-type': 'application/json'},
      request: pedido,
    );
  }
}
