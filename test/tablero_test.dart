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

  Future<http.Response> responder(http.Request pedido) async {
    llamadas.add(pedido.url.path);
    ultimosParams = jsonDecode(pedido.body) as Map<String, dynamic>;

    final cuerpo = pedido.url.path == '/rest/v1/rpc/pedido_publico'
        ? (detalleVacio ? <dynamic>[] : [_fila('detalle')])
        : [for (var i = 0; i < cantidad; i++) _fila('pedido-$i')];

    return http.Response(
      jsonEncode(cuerpo),
      200,
      headers: {'content-type': 'application/json'},
      request: pedido,
    );
  }
}
