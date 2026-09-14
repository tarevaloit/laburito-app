import 'package:geolocator/geolocator.dart';

/// Resultado de pedirle la posición al dispositivo.
///
/// Es un tipo sellado y no un `double?` con un `String?` al lado porque acá
/// «no hay posición» no es un error: es la mitad de los casos. El permiso
/// denegado, el GPS apagado y el navegador sin HTTPS son situaciones normales,
/// y en todas el CU-16 sigue adelante con el usuario fijando el punto a mano.
/// El tipo obliga a la pantalla a decidir qué hacer con cada una.
sealed class ResultadoUbicacion {
  const ResultadoUbicacion();
}

/// El dispositivo contestó con una coordenada.
class PosicionObtenida extends ResultadoUbicacion {
  const PosicionObtenida(this.lat, this.lng);

  final double lat;
  final double lng;
}

/// El dispositivo no contestó, y por qué.
///
/// El [mensaje] está escrito para mostrarse tal cual: es un aviso, no una
/// excepción, y nunca corta el flujo del alta.
class SinPosicion extends ResultadoUbicacion {
  const SinPosicion(this.motivo, this.mensaje);

  final MotivoSinPosicion motivo;
  final String mensaje;
}

enum MotivoSinPosicion {
  /// El GPS o los servicios de ubicación del sistema están apagados.
  serviciosApagados,

  /// El usuario dijo que no esta vez. Se le puede volver a preguntar.
  permisoDenegado,

  /// El usuario dijo que no para siempre. Solo se arregla desde los ajustes
  /// del sistema, así que no tiene sentido volver a preguntar.
  permisoBloqueado,

  /// Tardó demasiado, el navegador no está en HTTPS, o cualquier otra falla.
  falla,
}

/// Envoltorio de `geolocator` con la secuencia completa de permisos.
///
/// Se aisla acá para que la pantalla del selector no tenga que conocer el orden
/// —servicios primero, permiso después, posición al final— ni los cinco valores
/// de `LocationPermission`. Además deja el CU-16 probable: la pantalla depende
/// de esta interfaz y no del plugin.
class UbicacionDispositivo {
  const UbicacionDispositivo();

  /// Cuánto se espera al GPS antes de rendirse.
  ///
  /// Un arranque en frío sin asistencia de red puede tardar bastante más, pero
  /// para elegir la esquina de un pedido no vale la pena: es preferible caer
  /// al centro por defecto y dejar mover el mapa.
  static const Duration _limite = Duration(seconds: 12);

  Future<ResultadoUbicacion> actual() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const SinPosicion(
          MotivoSinPosicion.serviciosApagados,
          'La ubicación del dispositivo está apagada. Podés marcar el punto '
              'en el mapa igual.',
        );
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever) {
        return const SinPosicion(
          MotivoSinPosicion.permisoBloqueado,
          'Bloqueaste el acceso a tu ubicación. Podés habilitarlo desde los '
              'ajustes, o marcar el punto en el mapa.',
        );
      }

      if (permiso == LocationPermission.denied) {
        return const SinPosicion(
          MotivoSinPosicion.permisoDenegado,
          'No nos diste acceso a tu ubicación. Marcá el punto en el mapa.',
        );
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _limite,
        ),
      );

      return PosicionObtenida(posicion.latitude, posicion.longitude);
    } catch (_) {
      // Se traga a propósito: el navegador sin HTTPS, el emulador sin GPS y el
      // tiempo agotado llegan como excepciones distintas y para el usuario son
      // todas la misma cosa. Lo que importa es que el alta no se corte.
      return const SinPosicion(
        MotivoSinPosicion.falla,
        'No pudimos obtener tu ubicación. Marcá el punto en el mapa.',
      );
    }
  }

  /// Igual que [actual], pero **sin pedir permiso**: si todavía no está
  /// concedido devuelve `null` y no le muestra ningún cartel al usuario.
  ///
  /// Es la que corre sola al abrir el selector. Disparar el diálogo del sistema
  /// apenas se abre una pantalla es la forma más rápida de que alguien apriete
  /// «no» sin leer, y ese «no» en el navegador queda pegado al sitio. El
  /// permiso se pide recién cuando el usuario toca «Usar mi ubicación», que es
  /// cuando entiende para qué.
  Future<PosicionObtenida?> actualSiYaHayPermiso() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      final permiso = await Geolocator.checkPermission();
      final concedido = permiso == LocationPermission.always ||
          permiso == LocationPermission.whileInUse;
      if (!concedido) return null;

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: _limite,
        ),
      );

      return PosicionObtenida(posicion.latitude, posicion.longitude);
    } catch (_) {
      // Acá el fallo ni siquiera se avisa: nadie lo pidió.
      return null;
    }
  }
}
