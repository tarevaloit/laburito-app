import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Una opción de la lista de autocompletado.
class SugerenciaDireccion {
  const SugerenciaDireccion({
    required this.placeId,
    required this.titulo,
    required this.detalle,
  });

  /// Identificador de Google. Es lo único que sirve para pedir la coordenada:
  /// el texto de la sugerencia no la trae.
  final String placeId;

  /// Renglón principal: la calle y la altura.
  final String titulo;

  /// Renglón secundario: la localidad y la provincia. Puede venir vacío.
  final String detalle;

  String get completo => detalle.isEmpty ? titulo : '$titulo, $detalle';
}

/// Una dirección con su coordenada, tal como la devolvió Google.
class DireccionResuelta {
  const DireccionResuelta({
    required this.lat,
    required this.lng,
    required this.direccion,
  });

  final double lat;
  final double lng;
  final String direccion;
}

/// Búsqueda de direcciones y geocodificación inversa del CU-16.
///
/// **Ninguno de estos métodos tira una excepción.** Devuelven `null` o una
/// lista vacía cuando la API falla, se queda sin cuota o contesta cualquier
/// cosa. Es deliberado: la dirección es un campo de texto editable, así que un
/// servicio caído degrada a «escribila vos» y no a un alta interrumpida.
///
/// **Por qué Places API (New) y no el `components=country:ar` del servicio
/// clásico.** El endpoint viejo (`maps.googleapis.com/maps/api/place/...`) no
/// manda cabeceras CORS: desde el navegador —que es la superficie del Buscador—
/// toda llamada muere antes de salir. El endpoint nuevo
/// (`places.googleapis.com/v1/...`) sí las manda, y el equivalente del filtro
/// por país es `includedRegionCodes: ['ar']`.
class ServicioDirecciones {
  ServicioDirecciones({required this.apiKey, http.Client? cliente})
      : _cliente = cliente ?? http.Client(),
        _clientePropio = cliente == null;

  final String apiKey;
  final http.Client _cliente;

  /// Solo se cierra el cliente que se creó acá: el que llega por parámetro es
  /// del test, y cerrarlo rompería el resto de sus casos.
  final bool _clientePropio;

  static const Duration _limite = Duration(seconds: 8);

  bool get habilitado => apiKey.isNotEmpty;

  void cerrar() {
    if (_clientePropio) _cliente.close();
  }

  /// Coordenada → dirección. Es lo que llena el campo al soltar el mapa.
  ///
  /// Usa la Geocoding API, que no tiene equivalente en Places: Places busca
  /// lugares por nombre, no direcciones por punto. Si el navegador rechaza la
  /// llamada por CORS, cae por el `catch` y la pantalla deja el campo como
  /// estaba para que se escriba a mano.
  Future<String?> direccionDe(double lat, double lng) async {
    if (!habilitado) return null;

    final url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      'key': apiKey,
      'language': 'es',
      'region': 'ar',
    });

    try {
      final respuesta = await _cliente.get(url).timeout(_limite);
      if (respuesta.statusCode != 200) return null;

      final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
      if (cuerpo['status'] != 'OK') return null;

      final resultados = cuerpo['results'] as List<dynamic>?;
      if (resultados == null || resultados.isEmpty) return null;

      // El primer resultado es el más específico: la Geocoding API los ordena
      // de la dirección exacta al país.
      final texto =
          (resultados.first as Map<String, dynamic>)['formatted_address'];
      return texto is String && texto.trim().isNotEmpty ? texto : null;
    } catch (_) {
      return null;
    }
  }

  /// Texto → lista de direcciones candidatas, solo de Argentina.
  ///
  /// [sesion] es el *session token* de Places: agrupa las pulsaciones de teclas
  /// de una misma búsqueda con el pedido de detalle que viene después, y hace
  /// que Google las cobre como una sola operación en vez de una por letra.
  Future<List<SugerenciaDireccion>> sugerencias(
    String texto, {
    String? sesion,
  }) async {
    if (!habilitado || texto.trim().length < 3) {
      return const <SugerenciaDireccion>[];
    }

    final url = Uri.https('places.googleapis.com', '/v1/places:autocomplete');

    try {
      final respuesta = await _cliente
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': apiKey,
            },
            body: jsonEncode({
              'input': texto.trim(),
              'includedRegionCodes': ['ar'],
              'languageCode': 'es',
              if (sesion != null) 'sessionToken': sesion,
            }),
          )
          .timeout(_limite);

      if (respuesta.statusCode != 200) return const <SugerenciaDireccion>[];

      final cuerpo =
          jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
      final crudas = cuerpo['suggestions'] as List<dynamic>?;
      if (crudas == null) return const <SugerenciaDireccion>[];

      final salida = <SugerenciaDireccion>[];
      for (final cruda in crudas) {
        final prediccion =
            (cruda as Map<String, dynamic>)['placePrediction'];
        if (prediccion is! Map<String, dynamic>) continue;

        final placeId = prediccion['placeId'];
        if (placeId is! String || placeId.isEmpty) continue;

        final formato = prediccion['structuredFormat'];
        final principal = formato is Map<String, dynamic>
            ? _texto(formato['mainText'])
            : null;
        final secundario = formato is Map<String, dynamic>
            ? _texto(formato['secondaryText'])
            : null;

        // Sin `structuredFormat` queda el texto plano de la predicción, que
        // siempre viene.
        final titulo = principal ?? _texto(prediccion['text']) ?? '';
        if (titulo.isEmpty) continue;

        salida.add(SugerenciaDireccion(
          placeId: placeId,
          titulo: titulo,
          detalle: secundario ?? '',
        ));
      }

      return salida;
    } catch (_) {
      return const <SugerenciaDireccion>[];
    }
  }

  /// `placeId` → coordenada y dirección formateada.
  ///
  /// El `X-Goog-FieldMask` no es opcional en Places API (New): sin él la
  /// llamada falla con 400. Además es lo que fija el costo, así que se piden
  /// exactamente los dos campos que se usan.
  Future<DireccionResuelta?> detalle(String placeId, {String? sesion}) async {
    if (!habilitado || placeId.isEmpty) return null;

    final url = Uri.https('places.googleapis.com', '/v1/places/$placeId', {
      'languageCode': 'es',
      if (sesion != null) 'sessionToken': sesion,
    });

    try {
      final respuesta = await _cliente.get(
        url,
        headers: {
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'formattedAddress,location',
        },
      ).timeout(_limite);

      if (respuesta.statusCode != 200) return null;

      final cuerpo =
          jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
      final punto = cuerpo['location'];
      if (punto is! Map<String, dynamic>) return null;

      final lat = punto['latitude'];
      final lng = punto['longitude'];
      if (lat is! num || lng is! num) return null;

      return DireccionResuelta(
        lat: lat.toDouble(),
        lng: lng.toDouble(),
        direccion: _texto(cuerpo['formattedAddress']) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  /// Places devuelve los rótulos como `{'text': '...'}` en unos lados y como
  /// string pelado en otros.
  static String? _texto(Object? valor) {
    if (valor is String) return valor.trim().isEmpty ? null : valor;
    if (valor is Map<String, dynamic>) return _texto(valor['text']);
    return null;
  }

  /// Identificador de sesión de Places. No hace falta que sea un UUID de
  /// verdad: Google solo lo usa para agrupar llamadas, y tiene que ser
  /// distinto entre búsquedas.
  static String nuevoTokenDeSesion() {
    final azar = Random();
    final bytes = List<int>.generate(16, (_) => azar.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
