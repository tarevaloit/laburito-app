import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/core/mapas/mapa_config.dart';

/// CU-16 — los números fijos de `MapaConfig`: el centro de reserva y la
/// tolerancia del debounce de geocodificación. No cambian con el entorno, así
/// que un test que dependiera de la app entera sería probar de más; alcanza
/// con congelar los valores.
void main() {
  group('MapaConfig', () {
    test('el centro de reserva es José C. Paz', () {
      expect(MapaConfig.latJoseCPaz, closeTo(-34.5136, 1e-4));
      expect(MapaConfig.lngJoseCPaz, closeTo(-58.7645, 1e-4));
    });

    test('joseCPaz es el mismo punto que latJoseCPaz/lngJoseCPaz', () {
      expect(MapaConfig.joseCPaz.latitude, MapaConfig.latJoseCPaz);
      expect(MapaConfig.joseCPaz.longitude, MapaConfig.lngJoseCPaz);
    });

    test('la tolerancia de movimiento es menor a una cuadra', () {
      // Una cuadra típica del conurbano ronda los 100 m: 15 no invita a
      // disparar la geocodificación por el temblor de la cámara, pero tampoco
      // deja pasar un desplazamiento real.
      expect(MapaConfig.toleranciaMetros, 15);
      expect(MapaConfig.toleranciaMetros, lessThan(100));
    });

    test('el debounce del mapa es más largo que el del autocompletado', () {
      // El usuario escribe una tecla por vez esperando ver la lista, y
      // arrastra el mapa en tirones más largos: si el orden se invirtiera, la
      // búsqueda se sentiría trabada y el mapa dispararía una llamada por
      // cuadro.
      expect(
        MapaConfig.debounceGeocodificacionMs,
        greaterThan(MapaConfig.debounceAutocompletadoMs),
      );
    });

    test('sin clave, hayClave es falso y no se intenta cargar el SDK', () {
      // El entorno de test corre sin `--dart-define`, así que `apiKey` está
      // vacía: es el mismo estado que un desarrollador sin la clave todavía.
      expect(MapaConfig.apiKey, isEmpty);
      expect(MapaConfig.hayClave, isFalse);
    });
  });
}
