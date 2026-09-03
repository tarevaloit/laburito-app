import 'package:freezed_annotation/freezed_annotation.dart';

part 'ubicacion.freezed.dart';

/// Dónde hay que ir a trabajar.
///
/// En la base esto son dos cosas: la columna `ubicacion`, de tipo
/// `geography(Point,4326)`, y las columnas de texto `direccion_texto` y
/// `referencia_ubicacion`. Acá viajan juntas porque para la pantalla son un
/// solo dato.
///
/// Las coordenadas **no** se leen de la columna: PostgREST serializa
/// `geography` como WKB hexadecimal («0101000020E6100000...»), que en Dart no
/// es una coordenada. Se piden como `lat` y `lng`, los *computed fields* que
/// agrega la migración 0007.
@freezed
abstract class Ubicacion with _$Ubicacion {
  const Ubicacion._();

  const factory Ubicacion({
    required double lat,
    required double lng,
    required String direccionTexto,

    /// Piso, departamento, entre calles. Es dato de contacto: la vista
    /// `pedidos_publicos` no lo expone.
    String? referencia,
  }) = _Ubicacion;

  bool get esValida =>
      lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180 &&
      direccionTexto.trim().isNotEmpty;

  /// Representación que entiende la función de entrada de `geography`.
  ///
  /// Se manda como texto porque PostgREST no admite llamar funciones dentro de
  /// un INSERT, así que `public.punto()` no está disponible desde el cliente.
  ///
  /// Dos trampas, las dos cubiertas por los tests:
  ///   * PostGIS toma **(x, y) = (lng, lat)**, al revés de como se dice.
  ///   * `toStringAsFixed` evita la notación exponencial que `toString()`
  ///     produce con valores muy chicos (`1e-7`), que el parser de WKT no
  ///     acepta. Siete decimales son ~1 cm: sobra.
  String aEwkt() =>
      'SRID=4326;POINT(${lng.toStringAsFixed(7)} ${lat.toStringAsFixed(7)})';
}
