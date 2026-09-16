import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/pedidos/domain/ubicacion.dart';
import 'package:laburito/features/profesional/data/zona_cobertura_repository.dart';
import 'package:laburito/features/profesional/domain/zona_cobertura.dart';
import 'package:laburito/features/profesional/presentation/controllers/zona_cobertura_controller.dart';
import 'package:laburito/features/profesional/presentation/screens/zona_cobertura_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-07 — Configurar Zona de Cobertura.
///
/// El error que persigue la mitad de este archivo es el mismo del CU-13: una
/// coordenada invertida no falla, no rompe ninguna pantalla y deja la zona en
/// el Índico. El servidor falso aplica la misma regla que PostGIS, así que
/// invertir `(lat, lng)` en cualquiera de los dos extremos rompe el test.
///
/// Lo que **no** prueba: que la migración 0014 esté bien escrita. Eso lo dice
/// su guion de aceptación corrido contra la base, que ya se corrió.
void main() {
  const latJoseCPaz = -34.5136;
  const lngJoseCPaz = -58.7645;
  const tolerancia = 1e-6;

  const centro = Ubicacion(
    lat: latJoseCPaz,
    lng: lngJoseCPaz,
    direccionTexto: 'Av. Croacia 1200, José C. Paz',
  );

  group('dominio', () {
    test('la fila de la base se lee con sus computed fields', () {
      final zona = ZonaCobertura.desdeFila({
        'radio_metros': 7000,
        'direccion_texto': 'Av. Croacia 1200',
        'lat': latJoseCPaz,
        'lng': lngJoseCPaz,
      });

      expect(zona, isNotNull);
      expect(zona!.centro.lat, closeTo(latJoseCPaz, tolerancia));
      expect(zona.centro.lng, closeTo(lngJoseCPaz, tolerancia));
      expect(zona.radioMetros, 7000);
    });

    test('sin fila, o sin coordenadas, no hay zona', () {
      expect(ZonaCobertura.desdeFila(null), isNull);
      expect(
        ZonaCobertura.desdeFila({'radio_metros': 5000, 'lat': null, 'lng': null}),
        isNull,
        reason: 'sin centro no hay círculo que dibujar: es «todavía no '
            'configuró», no una zona rota',
      );
    });

    test('el radio se muestra en kilómetros, con decimal solo si sirve', () {
      String legible(int metros) =>
          ZonaCobertura(centro: centro, radioMetros: metros).radioLegible;

      expect(legible(1000), '1 km');
      expect(legible(1500), '1,5 km');
      expect(legible(10000), '10 km');
      expect(legible(100000), '100 km');
    });

    test('el radio se acota al rango que acepta la base', () {
      expect(ZonaCobertura.radioValido(10), ZonaCobertura.radioMinimoMetros);
      expect(
        ZonaCobertura.radioValido(999999),
        ZonaCobertura.radioMaximoMetros,
      );
      expect(ZonaCobertura.radioValido(25000), 25000);
    });

    test('el zoom del mapa se achica a medida que crece el radio', () {
      // Sin esto, una zona de 50 km no entra en la pantalla y una de 1 km se
      // ve como un punto.
      expect(zoomParaRadio(1000), greaterThan(zoomParaRadio(10000)));
      expect(zoomParaRadio(10000), greaterThan(zoomParaRadio(100000)));
      expect(zoomParaRadio(1000), lessThanOrEqualTo(15.0));
      expect(zoomParaRadio(100000), greaterThanOrEqualTo(6.0));
    });
  });

  group('repositorio contra un servidor falso', () {
    late _ServidorFalso servidor;
    late ZonaCoberturaRepository repo;

    setUp(() async {
      servidor = _ServidorFalso();
      repo = ZonaCoberturaRepository(await _clienteConSesion(servidor));
    });

    test('sin zona guardada, cargar devuelve null', () async {
      expect(await repo.cargar(), isNull);
    });

    test('guardar manda lat y lng a los parámetros correctos y los lee de '
        'vuelta igual', () async {
      final zona = await repo.guardar(centro: centro, radioMetros: 5000);

      expect(servidor.ultimoPunto!.lat, latJoseCPaz);
      expect(servidor.ultimoPunto!.lng, lngJoseCPaz);
      expect(zona.centro.lat, closeTo(latJoseCPaz, tolerancia));
      expect(zona.centro.lng, closeTo(lngJoseCPaz, tolerancia));
      expect(zona.radioMetros, 5000);
      expect(zona.centro.direccionTexto, 'Av. Croacia 1200, José C. Paz');
    });

    test('un radio fuera de rango se acota antes de salir a la red', () async {
      await repo.guardar(centro: centro, radioMetros: 500000);

      expect(
        servidor.ultimosParams['p_radio_metros'],
        ZonaCobertura.radioMaximoMetros,
      );
    });

    test('lo guardado se vuelve a leer', () async {
      await repo.guardar(centro: centro, radioMetros: 25000);

      final zona = await repo.cargar();
      expect(zona!.radioMetros, 25000);
      expect(zona.centro.lat, closeTo(latJoseCPaz, tolerancia));
    });
  });

  group('controlador', () {
    late _ServidorFalso servidor;
    late ProviderContainer container;

    Future<EstadoZonaCobertura> estado() =>
        container.read(zonaCoberturaControladorProvider.future);

    ZonaCoberturaControlador controlador() =>
        container.read(zonaCoberturaControladorProvider.notifier);

    setUp(() async {
      servidor = _ServidorFalso();
      final repo = ZonaCoberturaRepository(await _clienteConSesion(servidor));

      container = ProviderContainer(
        overrides: [zonaCoberturaRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
    });

    test('quien entra por primera vez no tiene centro y no puede guardar',
        () async {
      final e = await estado();

      expect(e.esPrimeraVez, isTrue);
      expect(e.tieneCentro, isFalse);
      expect(e.puedeGuardar, isFalse);
      expect(e.radioMetros, ZonaCobertura.radioPorDefectoMetros);
    });

    test('volver del selector sin elegir no toca nada', () async {
      await estado();
      controlador().elegirCentro(null);

      expect(container.read(zonaCoberturaControladorProvider).value!.tieneCentro,
          isFalse);
    });

    test('con centro elegido se puede guardar, y después ya no hay cambios',
        () async {
      await estado();

      controlador().elegirCentro(centro);
      controlador().cambiarRadioKm(25);

      var e = container.read(zonaCoberturaControladorProvider).value!;
      expect(e.radioMetros, 25000);
      expect(e.puedeGuardar, isTrue);

      await controlador().guardar();

      e = container.read(zonaCoberturaControladorProvider).value!;
      expect(e.guardado, isTrue);
      expect(e.esPrimeraVez, isFalse);
      expect(e.hayCambios, isFalse,
          reason: 'lo guardado pasa a ser el original: el botón se apaga');
      expect(e.puedeGuardar, isFalse);
      expect(e.error, isNull);
    });

    test('el error del servidor se muestra con el mensaje de la RPC', () async {
      servidor.rechazarConP0001 =
          'El radio tiene que estar entre 1 y 100 km';

      await estado();
      controlador().elegirCentro(centro);
      await controlador().guardar();

      final e = container.read(zonaCoberturaControladorProvider).value!;
      expect(e.error, 'El radio tiene que estar entre 1 y 100 km');
      expect(e.guardando, isFalse);
      expect(e.guardado, isFalse);
      expect(e.esPrimeraVez, isTrue, reason: 'no se guardó nada');
    });
  });
}

Future<SupabaseClient> _clienteConSesion(_ServidorFalso servidor) async {
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

  return client;
}

/// PostGIS de juguete, igual que en `pedidos_geografia_test.dart`: un punto con
/// `x` y `y` construido siempre por la traducción de `public.punto(lat, lng)`.
class _Punto {
  const _Punto(this.x, this.y);

  /// `ST_MakePoint(lng, lat)`: la longitud es la x.
  factory _Punto.desdeLatLng(double lat, double lng) => _Punto(lng, lat);

  final double x;
  final double y;

  double get lat => y;
  double get lng => x;
}

/// El Supabase mínimo que necesita el CU-07: la RPC de guardado y el SELECT de
/// la zona propia. Cualquier otra ruta es un 404, así que si el repositorio
/// empieza a llamar a otro lado, el test se entera.
class _ServidorFalso {
  static const String profesionalId = '44444444-4444-4444-8444-444444444444';

  final List<String> llamadas = [];
  Map<String, dynamic> ultimosParams = const {};
  _Punto? ultimoPunto;

  /// Cuando no es null, la RPC contesta como un `raise exception` de plpgsql.
  String? rechazarConP0001;

  Map<String, dynamic>? _fila;

  Future<http.Response> responder(http.Request pedido) async {
    llamadas.add('${pedido.method} ${pedido.url.path}');
    final ruta = pedido.url.path;

    if (ruta == '/rest/v1/rpc/guardar_zona_cobertura') {
      final params = jsonDecode(pedido.body) as Map<String, dynamic>;
      ultimosParams = params;

      if (rechazarConP0001 != null) {
        return http.Response(
          jsonEncode({
            'code': 'P0001',
            'message': rechazarConP0001,
            'hint': 'radio_invalido',
            'details': null,
          }),
          400,
          headers: {'content-type': 'application/json'},
          request: pedido,
        );
      }

      // Lo que hace `public.punto(p_lat, p_lng)`.
      ultimoPunto = _Punto.desdeLatLng(
        (params['p_lat'] as num).toDouble(),
        (params['p_lng'] as num).toDouble(),
      );

      _fila = {
        'profesional_id': profesionalId,
        'radio_metros': params['p_radio_metros'],
        'direccion_texto': params['p_direccion'],
      };

      // `.single()` pide `application/vnd.pgrst.object+json`: PostgREST
      // contesta el objeto, no una lista de uno.
      return _json(pedido, _respuesta());
    }

    if (ruta == '/rest/v1/profesional_zona_cobertura' &&
        pedido.method == 'GET') {
      return _json(pedido, _fila == null ? <dynamic>[] : [_respuesta()]);
    }

    return http.Response(
      jsonEncode({'message': 'ruta no prevista por el test: $ruta'}),
      404,
      headers: {'content-type': 'application/json'},
      request: pedido,
    );
  }

  /// La fila con los computed fields `lat` y `lng` de la 0014 agregados, que es
  /// lo que devuelve PostgREST cuando se los pide en el `select`.
  Map<String, dynamic> _respuesta() => {
        ..._fila!,
        'lat': ultimoPunto?.lat,
        'lng': ultimoPunto?.lng,
      };

  http.Response _json(http.Request pedido, Object cuerpo) => http.Response(
        jsonEncode(cuerpo),
        200,
        headers: {'content-type': 'application/json'},
        request: pedido,
      );
}
