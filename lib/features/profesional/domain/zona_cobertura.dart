import 'package:freezed_annotation/freezed_annotation.dart';

import '../../pedidos/domain/ubicacion.dart';

part 'zona_cobertura.freezed.dart';

/// CU-07 — Dónde quiere trabajar el Profesional.
///
/// Un círculo: un centro y un radio. En la base son la tabla
/// `profesional_zona_cobertura` de la migración 0012 —una fila por
/// Profesional— y el centro es una columna `geography(Point,4326)`, que como
/// en los pedidos no se lee cruda sino por los *computed fields* `lat` y `lng`
/// de la 0014.
///
/// El centro reutiliza [Ubicacion], el mismo tipo que devuelve el
/// `SelectorUbicacion` del CU-16: es el dato que la pantalla elige en el mapa,
/// y duplicarlo con otro nombre obligaría a convertir de un lado al otro en
/// cada pasada.
@freezed
abstract class ZonaCobertura with _$ZonaCobertura {
  const ZonaCobertura._();

  const factory ZonaCobertura({
    required Ubicacion centro,
    required int radioMetros,
  }) = _ZonaCobertura;

  /// El radio va en metros porque es la unidad de `ST_DWithin` sobre
  /// `geography`: la consulta del CU-21 no convierte nada. La pantalla habla
  /// en kilómetros, que es como la gente piensa una zona de trabajo.
  static const int radioMinimoMetros = 1000;
  static const int radioMaximoMetros = 100000;
  static const int radioPorDefectoMetros = 10000;

  /// Los mismos límites en kilómetros, para el deslizador.
  static const double radioMinimoKm = radioMinimoMetros / 1000;
  static const double radioMaximoKm = radioMaximoMetros / 1000;

  double get radioKm => radioMetros / 1000;

  /// Cómo se escribe el radio en pantalla. Hasta 9 km se muestra con un
  /// decimal si lo tiene, porque la diferencia entre 1 y 1,5 km es media zona;
  /// de 10 en adelante el decimal es ruido.
  String get radioLegible {
    final km = radioKm;
    if (km >= 10 || km == km.roundToDouble()) {
      return '${km.round()} km';
    }
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  /// Lo que se lee de la base. Devuelve `null` si a la fila le falta el
  /// centro: sin coordenadas no hay zona que dibujar, y es preferible tratarlo
  /// como «todavía no configuró» antes que inventar un punto.
  static ZonaCobertura? desdeFila(Map<String, dynamic>? fila) {
    if (fila == null) return null;

    final lat = (fila['lat'] as num?)?.toDouble();
    final lng = (fila['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return ZonaCobertura(
      centro: Ubicacion(
        lat: lat,
        lng: lng,
        direccionTexto: (fila['direccion_texto'] as String?) ?? '',
      ),
      radioMetros: (fila['radio_metros'] as num?)?.toInt() ??
          radioPorDefectoMetros,
    );
  }

  /// Un radio que la base vaya a aceptar. La pantalla ya lo acota con el
  /// deslizador; esto es la red por si el valor llega de otro lado.
  static int radioValido(int metros) =>
      metros.clamp(radioMinimoMetros, radioMaximoMetros);
}
