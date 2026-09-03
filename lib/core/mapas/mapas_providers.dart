import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'mapa_config.dart';
import 'servicio_direcciones.dart';
import 'ubicacion_dispositivo.dart';

part 'mapas_providers.g.dart';

/// `keepAlive` porque adentro hay un `http.Client` con su pool de conexiones:
/// recrearlo cada vez que se abre el selector tira la conexión reusada y paga
/// el TLS de nuevo.
///
/// Los tests que ejerciten una pantalla con mapa sobrescriben este provider con
/// un [ServicioDirecciones] de cliente falso; por eso el servicio recibe el
/// `http.Client` por constructor y no lo crea adentro sin alternativa.
@Riverpod(keepAlive: true)
ServicioDirecciones servicioDirecciones(Ref ref) {
  final servicio = ServicioDirecciones(apiKey: MapaConfig.apiKey);
  ref.onDispose(servicio.cerrar);
  return servicio;
}

/// Sin estado: es una fachada sobre los estáticos de `geolocator`. Existe como
/// provider para poder sustituirlo en las pruebas de widget del CU-16, donde no
/// hay dispositivo que responda.
@Riverpod(keepAlive: true)
UbicacionDispositivo ubicacionDispositivo(Ref ref) =>
    const UbicacionDispositivo();
