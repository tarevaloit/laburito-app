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
}

// Acá vivía `aEwkt()`, que armaba «SRID=4326;POINT(lng lat)» para mandarle la
// coordenada a la base como texto. Desde la migración 0009 el punto lo arma
// `public.punto(lat, lng)` del lado del servidor y el cliente manda los dos
// números sueltos, así que el método quedó sin usar y se borró.
//
// No se conserva «por las dudas» a propósito: era el único lugar de Dart donde
// estaba escrito el orden `(x, y) = (lng, lat)` de PostGIS, y dejarlo a mano
// invita a volver a usarlo. Si alguna vez hace falta EWKT —para un seed, para
// un import— que se escriba en SQL, que es donde vive esa regla.
