import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/core/mapas/servicio_direcciones.dart';

/// CU-16 — `ServicioDirecciones` contra un Google de mentira.
///
/// La regla que gobierna toda la clase es que **ningún método tira
/// excepción**: la dirección es un campo editable, así que un 500 o una
/// respuesta rara degradan a `null` / lista vacía y no a un alta interrumpida.
/// Eso es lo que se prueba acá, junto con el parseo de las tres formas de
/// respuesta que devuelve Google.
void main() {
  group('direccionDe (Geocoding API)', () {
    test('parsea el formatted_address del primer resultado', () async {
      final servicio = ServicioDirecciones(
        apiKey: 'clave-de-prueba',
        cliente: MockClient((request) async {
          expect(request.url.host, 'maps.googleapis.com');
          expect(request.url.queryParameters['latlng'], '-34.5136,-58.7645');
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'results': [
                {'formatted_address': 'Av. Croacia 1200, José C. Paz, Buenos Aires'},
                {'formatted_address': 'José C. Paz, Buenos Aires'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final direccion = await servicio.direccionDe(-34.5136, -58.7645);

      expect(direccion, 'Av. Croacia 1200, José C. Paz, Buenos Aires');
    });

    test('un 500 devuelve null en vez de tirar', () async {
      final servicio = ServicioDirecciones(
        apiKey: 'clave-de-prueba',
        cliente: MockClient((request) async => http.Response('', 500)),
      );

      expect(await servicio.direccionDe(-34.5136, -58.7645), isNull);
    });

    test('un status distinto de OK devuelve null', () async {
      final servicio = ServicioDirecciones(
        apiKey: 'clave-de-prueba',
        cliente: MockClient((request) async {
          return http.Response(
            jsonEncode({'status': 'ZERO_RESULTS', 'results': []}),
            200,
          );
        }),
      );

      expect(await servicio.direccionDe(-34.5136, -58.7645), isNull);
    });

    test('sin clave no sale a la red', () async {
      var llamadas = 0;
      final servicio = ServicioDirecciones(
        apiKey: '',
        cliente: MockClient((request) async {
          llamadas++;
          return http.Response('', 200);
        }),
      );

      expect(await servicio.direccionDe(-34.5136, -58.7645), isNull);
      expect(llamadas, 0);
    });
  });

  group('sugerencias (Places API New — autocomplete)', () {
    test('filtra por Argentina y parsea el texto estructurado', () async {
      late http.Request pedidoRecibido;
      late Map<String, dynamic> cuerpoRecibido;

      final servicio = ServicioDirecciones(
        apiKey: 'clave-de-prueba',
        cliente: MockClient((request) async {
          pedidoRecibido = request;
          cuerpoRecibido = jsonDecode(request.body) as Map<String, dynamic>;

          return http.Response(
            jsonEncode({
              'suggestions': [
                {
                  'placePrediction': {
                    'placeId': 'place-1',
                    'structuredFormat': {
                      'mainText': {'text': 'Av. Croacia 1200'},
                      'secondaryText': {'text': 'José C. Paz, Buenos Aires'},
                    },
                  },
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final sugerencias = await servicio.sugerencias('Av. Croacia');

      expect(pedidoRecibido.url.host, 'places.googleapis.com');
      expect(pedidoRecibido.headers['X-Goog-Api-Key'], 'clave-de-prueba');
      expect(cuerpoRecibido['includedRegionCodes'], ['ar']);
      expect(cuerpoRecibido['input'], 'Av. Croacia');

      expect(sugerencias, hasLength(1));
      expect(sugerencias.single.placeId, 'place-1');
      expect(sugerencias.single.titulo, 'Av. Croacia 1200');
      expect(sugerencias.single.detalle, 'José C. Paz, Buenos Aires');
      expect(sugerencias.single.completo,
          'Av. Croacia 1200, José C. Paz, Buenos Aires');
    });

    test('con menos de tres letras no sale a la red', () async {
      var llamadas = 0;
      final servicio = ServicioDirecciones(
        apiKey: 'clave-de-prueba',
        cliente: MockClient((request) async {
          llamadas++;
          return http.Response('{}', 200);
        }),
      );

      expect(await servicio.sugerencias('av'), isEmpty);
      expect(llamadas, 0);
    });

    test('un 500 devuelve lista vacía en vez de tirar', () async {
      final servicio = ServicioDirecciones(
        apiKey: 'clave-de-prueba',
        cliente: MockClient((request) async => http.Response('', 500)),
      );

      expect(await servicio.sugerencias('Av. Croacia'), isEmpty);
    });
  });

  group('detalle (Places API New — place details)', () {
    test('parsea la coordenada y la dirección formateada', () async {
      late http.Request pedidoRecibido;

      final servicio = ServicioDirecciones(
        apiKey: 'clave-de-prueba',
        cliente: MockClient((request) async {
          pedidoRecibido = request;

          return http.Response(
            jsonEncode({
              'formattedAddress': 'Av. Croacia 1200, José C. Paz, Buenos Aires',
              'location': {'latitude': -34.5136, 'longitude': -58.7645},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final detalle = await servicio.detalle('place-1');

      expect(pedidoRecibido.url.path, '/v1/places/place-1');
      expect(
        pedidoRecibido.headers['X-Goog-FieldMask'],
        'formattedAddress,location',
      );
      expect(detalle, isNotNull);
      expect(detalle!.lat, closeTo(-34.5136, 1e-9));
      expect(detalle.lng, closeTo(-58.7645, 1e-9));
      expect(detalle.direccion, 'Av. Croacia 1200, José C. Paz, Buenos Aires');
    });

    test('un 500 devuelve null en vez de tirar', () async {
      final servicio = ServicioDirecciones(
        apiKey: 'clave-de-prueba',
        cliente: MockClient((request) async => http.Response('', 500)),
      );

      expect(await servicio.detalle('place-1'), isNull);
    });
  });
}
