import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:laburito/features/pedidos/data/pedido_exception.dart';
import 'package:laburito/features/pedidos/data/pedidos_repository.dart';
import 'package:laburito/features/pedidos/domain/ubicacion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// La ida y vuelta de la coordenada.
///
/// Es el único error del CU-13 que **no falla**: invertir `(lng, lat)` no tira
/// excepción, no viola ninguna restricción y no rompe ninguna pantalla. Guarda
/// el pedido a nueve mil kilómetros y no se entera nadie hasta que el mapa del
/// CU-16 aparece vacío.
///
/// Qué prueba esto y qué no:
///
///   * **Sí**: que `PedidosRepository` mande lat y lng a los parámetros que
///     corresponden, y que lea de vuelta los computed fields en el orden
///     correcto. El servidor falso de acá abajo aplica exactamente la misma
///     regla que PostGIS —`ST_MakePoint(x, y)` con `x = lng`, `st_x` devuelve
///     `x`, `st_y` devuelve `y`— así que una inversión en cualquiera de los dos
///     extremos rompe el test.
///   * **No**: que la migración 0009 esté bien escrita. Eso solo lo dice correr
///     el SQL contra una base, y en esta máquina no hay Docker. El guion de
///     aceptación está comentado al final de
///     `supabase/migrations/0009_pedidos_alta_y_ubicacion.sql`.
void main() {
  // Plaza de José C. Paz. Latitud y longitud negativas y bastante parecidas
  // entre sí en magnitud: si se invirtieran, el punto seguiría cayendo en un
  // lugar plausible, que es justo lo que hace peligroso a este error.
  const latJoseCPaz = -34.5136;
  const lngJoseCPaz = -58.7645;

  const tolerancia = 1e-6;

  late _ServidorFalso servidor;
  late PedidosRepository repo;

  setUp(() async {
    servidor = _ServidorFalso();

    final client = SupabaseClient(
      'https://proyecto.supabase.co',
      'clave-anon-de-mentira',
      httpClient: MockClient(servidor.responder),
    );

    // `setInitialSession` escribe la sesión sin salir a la red ni mirar el
    // vencimiento: es el camino que usa supabase_flutter al levantar una
    // sesión guardada.
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

  group('CU-13 · alta', () {
    test('la coordenada vuelve igual a como se mandó, con tolerancia 1e-6',
        () async {
      final pedido = await repo.crearPedido(
        categoriaId: _ServidorFalso.categoriaId,
        titulo: 'Se me tapó la cocina',
        descripcion:
            'La pileta de la cocina no traga y el agua vuelve. Necesito un '
            'plomero lo antes posible.',
        ubicacion: const Ubicacion(
          lat: latJoseCPaz,
          lng: lngJoseCPaz,
          direccionTexto: 'Av. Croacia 1200, José C. Paz',
          referencia: 'Casa del fondo, timbre 2',
        ),
        fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
      );

      expect(pedido.ubicacion.lat, closeTo(latJoseCPaz, tolerancia));
      expect(pedido.ubicacion.lng, closeTo(lngJoseCPaz, tolerancia));
    });

    test('lat y lng viajan cada uno en su parámetro, no cruzados', () async {
      await repo.crearPedido(
        categoriaId: _ServidorFalso.categoriaId,
        titulo: 'Se me tapó la cocina',
        descripcion:
            'La pileta de la cocina no traga y el agua vuelve. Necesito un '
            'plomero lo antes posible.',
        ubicacion: const Ubicacion(
          lat: latJoseCPaz,
          lng: lngJoseCPaz,
          direccionTexto: 'Av. Croacia 1200, José C. Paz',
        ),
        fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
      );

      // Lo que de verdad llegó a la RPC.
      expect(servidor.ultimosParams['p_lat'], latJoseCPaz);
      expect(servidor.ultimosParams['p_lng'], lngJoseCPaz);
    });

    test('el punto guardado tiene x = lng e y = lat, como ST_MakePoint',
        () async {
      await repo.crearPedido(
        categoriaId: _ServidorFalso.categoriaId,
        titulo: 'Se me tapó la cocina',
        descripcion:
            'La pileta de la cocina no traga y el agua vuelve. Necesito un '
            'plomero lo antes posible.',
        ubicacion: const Ubicacion(
          lat: latJoseCPaz,
          lng: lngJoseCPaz,
          direccionTexto: 'Av. Croacia 1200, José C. Paz',
        ),
        fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
      );

      final punto = servidor.ultimoPunto!;
      expect(punto.x, lngJoseCPaz, reason: 'x es la longitud');
      expect(punto.y, latJoseCPaz, reason: 'y es la latitud');
    });

    test('el alta no elige el estado: lo pone el default de la tabla',
        () async {
      await repo.crearPedido(
        categoriaId: _ServidorFalso.categoriaId,
        titulo: 'Se me tapó la cocina',
        descripcion:
            'La pileta de la cocina no traga y el agua vuelve. Necesito un '
            'plomero lo antes posible.',
        ubicacion: const Ubicacion(
          lat: latJoseCPaz,
          lng: lngJoseCPaz,
          direccionTexto: 'Av. Croacia 1200, José C. Paz',
        ),
        fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
      );

      // Si apareciera, el trigger `pedidos_guard_alta` de la 0009 rechazaría
      // el alta salvo que el valor fuese 'publicado'.
      expect(servidor.ultimosParams.keys, isNot(contains('p_estado')));
      expect(servidor.ultimosParams.keys, isNot(contains('estado')));
    });

    test('no se manda la ubicación como texto: el punto lo arma la base',
        () async {
      await repo.crearPedido(
        categoriaId: _ServidorFalso.categoriaId,
        titulo: 'Se me tapó la cocina',
        descripcion:
            'La pileta de la cocina no traga y el agua vuelve. Necesito un '
            'plomero lo antes posible.',
        ubicacion: const Ubicacion(
          lat: latJoseCPaz,
          lng: lngJoseCPaz,
          direccionTexto: 'Av. Croacia 1200, José C. Paz',
        ),
        fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
      );

      expect(jsonEncode(servidor.ultimosParams), isNot(contains('SRID')));
    });
  });

  group('CU-15 · mover el pedido de lugar', () {
    test('la coordenada nueva también vuelve igual', () async {
      final creado = await repo.crearPedido(
        categoriaId: _ServidorFalso.categoriaId,
        titulo: 'Se me tapó la cocina',
        descripcion:
            'La pileta de la cocina no traga y el agua vuelve. Necesito un '
            'plomero lo antes posible.',
        ubicacion: const Ubicacion(
          lat: latJoseCPaz,
          lng: lngJoseCPaz,
          direccionTexto: 'Av. Croacia 1200, José C. Paz',
        ),
        fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
      );

      // Unas cuadras al norte y al este.
      const latNueva = -34.5008;
      const lngNueva = -58.7401;

      final movido = await repo.actualizarUbicacion(
        creado.id,
        const Ubicacion(
          lat: latNueva,
          lng: lngNueva,
          direccionTexto: 'Av. Presidente Perón 3500, José C. Paz',
        ),
      );

      expect(movido.ubicacion.lat, closeTo(latNueva, tolerancia));
      expect(movido.ubicacion.lng, closeTo(lngNueva, tolerancia));
      expect(servidor.ultimoPunto!.x, lngNueva);
      expect(servidor.ultimoPunto!.y, latNueva);
    });

    test('editar el título no manda la ubicación ni la pisa', () async {
      final creado = await repo.crearPedido(
        categoriaId: _ServidorFalso.categoriaId,
        titulo: 'Se me tapó la cocina',
        descripcion:
            'La pileta de la cocina no traga y el agua vuelve. Necesito un '
            'plomero lo antes posible.',
        ubicacion: const Ubicacion(
          lat: latJoseCPaz,
          lng: lngJoseCPaz,
          direccionTexto: 'Av. Croacia 1200, José C. Paz',
        ),
        fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
      );

      final editado = await repo.actualizarPedido(
        creado.id,
        titulo: 'Se me tapó la pileta de la cocina',
      );

      expect(editado.titulo, 'Se me tapó la pileta de la cocina');
      expect(editado.ubicacion.lat, closeTo(latJoseCPaz, tolerancia));
      expect(editado.ubicacion.lng, closeTo(lngJoseCPaz, tolerancia));

      // El PATCH de PostgREST no puede escribir un `geography`: si estas
      // claves aparecieran, la migración 0008 y la 0009 no alcanzarían.
      expect(servidor.ultimoPatch, isNot(contains('ubicacion')));
      expect(servidor.ultimoPatch, isNot(contains('estado')));
    });
  });

  group('validación del lado del cliente', () {
    test('una latitud imposible no llega a salir a la red', () {
      // `crearPedido` valida antes de devolver el Future, así que la excepción
      // se levanta acá mismo y no hay nada que esperar.
      expect(
        () => repo.crearPedido(
          categoriaId: _ServidorFalso.categoriaId,
          titulo: 'Se me tapó la cocina',
          descripcion:
              'La pileta de la cocina no traga y el agua vuelve. Necesito un '
              'plomero lo antes posible.',
          ubicacion: const Ubicacion(
            lat: 190,
            lng: lngJoseCPaz,
            direccionTexto: 'Av. Croacia 1200, José C. Paz',
          ),
          fechaVencimiento: DateTime.now().add(const Duration(days: 7)),
        ),
        throwsA(isA<PedidoException>()),
      );

      expect(servidor.llamadas, isEmpty);
    });
  });
}

/// PostGIS de juguete: un punto con `x` y `y`, y nada más.
///
/// Se construye siempre por [desdeLatLng], que es la traducción que hace
/// `public.punto(lat, lng)` en la migración 0007. Si esa traducción se
/// invirtiera acá, habría que invertirla también en el repositorio para que los
/// tests pasaran — que es exactamente la propiedad que se quiere.
class _Punto {
  const _Punto(this.x, this.y);

  /// `ST_MakePoint(lng, lat)`: la longitud es la x.
  factory _Punto.desdeLatLng(double lat, double lng) => _Punto(lng, lat);

  final double x;
  final double y;

  /// `extensions.st_y(...)`
  double get lat => y;

  /// `extensions.st_x(...)`
  double get lng => x;
}

/// Un Supabase de mentira, del tamaño justo para este test.
///
/// Responde solo lo que el repositorio pide: la RPC de alta, la de ubicación,
/// el PATCH de edición y el SELECT del detalle. Cualquier otra ruta devuelve
/// 404 con el cuerpo de PostgREST, así que si el repositorio empieza a llamar a
/// otro lado, el test se entera.
class _ServidorFalso {
  static const String buscadorId = '11111111-1111-4111-8111-111111111111';
  static const String categoriaId = '22222222-2222-4222-8222-222222222222';
  static const String pedidoId = '33333333-3333-4333-8333-333333333333';

  final List<String> llamadas = [];

  Map<String, dynamic> ultimosParams = const {};
  String ultimoPatch = '';
  _Punto? ultimoPunto;

  /// La fila tal como vive en la tabla, con el punto aparte: `ubicacion` es
  /// `geography` y no sale nunca en el JSON, igual que en la base.
  Map<String, dynamic>? _fila;

  Future<http.Response> responder(http.Request pedido) async {
    llamadas.add('${pedido.method} ${pedido.url.path}');

    final ruta = pedido.url.path;

    if (ruta == '/rest/v1/rpc/crear_pedido') {
      return _json(pedido, _crear(jsonDecode(pedido.body) as Map<String, dynamic>));
    }

    if (ruta == '/rest/v1/rpc/actualizar_ubicacion_pedido') {
      return _json(
        pedido,
        _moverUbicacion(jsonDecode(pedido.body) as Map<String, dynamic>),
      );
    }

    if (ruta == '/rest/v1/pedidos' && pedido.method == 'PATCH') {
      ultimoPatch = pedido.body;
      final cambios = jsonDecode(pedido.body) as Map<String, dynamic>;
      _fila = {..._fila!, ...cambios};
      return _json(pedido, _respuesta());
    }

    if (ruta == '/rest/v1/pedidos' && pedido.method == 'GET') {
      return _json(pedido, _respuesta());
    }

    return http.Response(
      jsonEncode({'message': 'ruta no prevista por el test: $ruta'}),
      404,
      headers: {'content-type': 'application/json'},
      request: pedido,
    );
  }

  Map<String, dynamic> _crear(Map<String, dynamic> params) {
    ultimosParams = params;

    // Lo que hace `public.punto(p_lat, p_lng)`.
    ultimoPunto = _Punto.desdeLatLng(
      (params['p_lat'] as num).toDouble(),
      (params['p_lng'] as num).toDouble(),
    );

    final ahora = DateTime.now().toUtc().toIso8601String();

    _fila = {
      'id': pedidoId,
      'buscador_id': buscadorId,
      'categoria_id': params['p_categoria_id'],
      'titulo': params['p_titulo'],
      'descripcion': params['p_descripcion'],
      'urgencia': params['p_urgencia'] ?? 'media',
      // El default de la tabla. La RPC no lo manda y el guard de la 0009 no
      // dejaría que lo mandara.
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
    };

    return _respuesta();
  }

  Map<String, dynamic> _moverUbicacion(Map<String, dynamic> params) {
    ultimosParams = params;

    ultimoPunto = _Punto.desdeLatLng(
      (params['p_lat'] as num).toDouble(),
      (params['p_lng'] as num).toDouble(),
    );

    _fila = {
      ..._fila!,
      'direccion_texto': params['p_direccion_texto'],
      'referencia_ubicacion': params['p_referencia'],
    };

    return _respuesta();
  }

  /// La fila con los computed fields de la 0007 agregados, que es lo que
  /// devuelve PostgREST cuando se los pide en el `select`.
  Map<String, dynamic> _respuesta() => {
        ..._fila!,
        'lat': ultimoPunto!.lat,
        'lng': ultimoPunto!.lng,
        'categorias_oficio': {'nombre': 'Plomería'},
        'pedido_fotos': <Map<String, dynamic>>[],
      };

  /// PostgREST devuelve un objeto cuando el cliente pidió
  /// `Accept: application/vnd.pgrst.object+json` —que es lo que hace
  /// `.single()`— y un arreglo en cualquier otro caso.
  ///
  /// `request:` no es opcional en la práctica: `postgrest` lee
  /// `response.request!` para decidir cómo parsear el cuerpo, y `MockClient`
  /// no lo completa solo.
  http.Response _json(http.Request pedido, Map<String, dynamic> fila) {
    final quiereObjeto = (pedido.headers['Accept'] ?? '')
        .contains('application/vnd.pgrst.object+json');

    return http.Response(
      jsonEncode(quiereObjeto ? fila : [fila]),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
      request: pedido,
    );
  }
}
