import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/env.dart';
import 'sdk_mapas.dart';

/// Todo lo que el CU-16 necesita saber del mapa antes de dibujarlo.
///
/// Existe por el mismo motivo que `lib/app/colores.dart`: que el zoom por
/// defecto, la coordenada de reserva y la clave de la API no queden escritos a
/// mano en cada pantalla que abra un mapa. El detalle del pedido (CU-20) y el
/// tablero del Profesional (Sprint 3) van a pedir lo mismo.
class MapaConfig {
  const MapaConfig._();

  /// Clave de Google Maps Platform. Vacía si no se pasó por `--dart-define`.
  static String get apiKey => Env.googleMapsApiKey;

  /// Con la clave vacía el mapa no se dibuja, pero la pantalla no se cae: el
  /// selector muestra un aviso y deja fijar la dirección a mano.
  static bool get hayClave => apiKey.isNotEmpty;

  /// Plaza de José C. Paz. Es el centro de reserva cuando no hay ubicación
  /// previa, no hay permiso de geolocalización o el dispositivo tarda.
  ///
  /// No es una coordenada decorativa: es la ciudad donde se ambienta el
  /// proyecto, así que abrir el mapa acá deja al usuario a unas cuadras de su
  /// pedido en vez de en medio del Atlántico, que es donde cae `LatLng(0, 0)`.
  static const double latJoseCPaz = -34.5136;
  static const double lngJoseCPaz = -58.7645;

  /// Los dos números de arriba, en el tipo que pide el mapa. Se guardan también
  /// sueltos porque `LatLng.latitude` no es constante y no se puede usar dentro
  /// de un `const` del estado del selector.
  static const LatLng joseCPaz = LatLng(latJoseCPaz, lngJoseCPaz);

  /// Zoom para elegir una dirección: se distinguen las cuadras y los números.
  static const double zoomDireccion = 16;

  /// Zoom para mostrar un pedido ya ubicado sin invitar a moverlo.
  static const double zoomDetalle = 15;

  /// Cuánto tiene que moverse el centro del mapa para que valga la pena volver
  /// a preguntarle la dirección a Google.
  ///
  /// El mapa se queda quieto muchas veces por razones que no son un gesto del
  /// usuario —el primer encuadre, un `animateCamera`, el reacomodo del teclado—
  /// y cada una de esas dispararía una geocodificación inversa que se paga.
  /// Quince metros es menos que el frente de un lote y bastante más que el
  /// temblor de la cámara al asentarse.
  static const double toleranciaMetros = 15;

  /// Espera antes de geocodificar hacia atrás, en milisegundos.
  ///
  /// El usuario arrastra el mapa en varios tirones cortos; sin esta pausa cada
  /// tirón sería una llamada a la API. El número sale de la consigna del CU-16.
  static const int debounceGeocodificacionMs = 700;

  /// Espera antes de pedirle sugerencias a Places mientras se escribe.
  ///
  /// Más corta que la del mapa: acá el usuario está esperando ver la lista, y
  /// 700 ms de demora sobre cada tecla se sienten como que la búsqueda no anda.
  static const int debounceAutocompletadoMs = 300;

  /// Carga el SDK que haga falta para esta plataforma y devuelve si el mapa se
  /// puede dibujar.
  ///
  /// En Android no hay nada que cargar —el SDK nativo viene en el APK y lee la
  /// clave del manifiesto—, así que devuelve `true` sin hacer nada. En Web
  /// inyecta el `<script>` de Maps JavaScript con la clave del `--dart-define`.
  /// Ver `sdk_mapas.dart` para por qué el script no está escrito en
  /// `web/index.html`.
  static Future<bool> asegurarSdk() => cargarSdkDeMapas(apiKey);
}
