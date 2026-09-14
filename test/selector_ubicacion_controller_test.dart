import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/core/mapas/mapas_providers.dart';
import 'package:laburito/core/mapas/servicio_direcciones.dart';
import 'package:laburito/core/mapas/ubicacion_dispositivo.dart';
import 'package:laburito/features/pedidos/presentation/controllers/selector_ubicacion_controller.dart';

/// CU-16 — el camino de «Usar mi ubicación».
///
/// Regresión de un bug que solo aparece con el mapa de verdad: el controlador
/// pide la posición al GPS y encuadra ahí, pero el `onCameraIdle` del mapa
/// devuelve **el centro real de la cámara**, que difiere del pedido en los
/// últimos decimales. La comprobación de «esta respuesta sigue siendo del
/// punto actual» se hacía con `==` entre doubles, así que esa diferencia
/// invisible descartaba la dirección recién resuelta: el mapa se centraba, el
/// campo quedaba vacío y el botón de confirmar no se habilitaba nunca.
void main() {
  // Plaza de José C. Paz.
  const lat = -34.5136;
  const lng = -58.7645;

  const direccion = 'Av. Croacia 1200, José C. Paz, Buenos Aires';

  /// El servicio con un servidor falso que **tarda**.
  ///
  /// La demora no es decorativa: reproduce el orden real de los hechos. Sin
  /// ella la geocodificación contestaría antes de que el mapa se acomode, que
  /// es justamente el caso en el que el bug no se ve.
  ServicioDirecciones direccionesLentas() => ServicioDirecciones(
        apiKey: 'clave-de-mentira',
        cliente: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'results': [
                {'formatted_address': direccion},
              ],
            }),
            200,
          );
        }),
      );

  /// El contenedor **con un oyente vivo** sobre el controlador.
  ///
  /// El provider es autoDispose, así que sin alguien escuchando se descarta en
  /// cuanto termina el `read` que lo creó: el `_vivo` del controlador se apaga
  /// a mitad del `await` de la geocodificación y el estado que leería el test
  /// sería el de una instancia nueva, no el de la que ejecutó la acción. Es la
  /// pantalla real la que sostiene esa suscripción con su `ref.watch`.
  ProviderContainer contenedor(UbicacionDispositivo dispositivo) {
    final container = ProviderContainer(overrides: [
      ubicacionDispositivoProvider.overrideWithValue(dispositivo),
      servicioDireccionesProvider.overrideWithValue(direccionesLentas()),
    ]);
    addTearDown(container.dispose);

    final suscripcion = container.listen(
      selectorUbicacionControllerProvider(null),
      (_, __) {},
    );
    addTearDown(suscripcion.close);

    return container;
  }

  test(
      'tras «usar mi ubicación», la dirección se escribe aunque el mapa '
      'reporte un centro con decimales distintos', () async {
    final container = contenedor(const _DispositivoQueResponde(lat, lng));
    final provider = selectorUbicacionControllerProvider(null);
    final notifier = container.read(provider.notifier);

    await notifier.irAMiUbicacion();

    // El mapa termina de animar y avisa dónde quedó: la misma esquina, pero
    // no el mismo double. Un centímetro de diferencia.
    notifier.alQuedarQuietoElMapa(lat + 0.0000001, lng - 0.0000002);

    // Recién ahora contesta Google.
    await Future<void>.delayed(const Duration(milliseconds: 60));

    final estado = container.read(provider);
    expect(estado.direccionTexto, direccion);
    expect(estado.ubicacion, isNotNull,
        reason: 'con dirección y coordenada válidas, se puede confirmar');
    expect(estado.ubicacion!.lat, closeTo(lat, 0.001));
  });

  test('una respuesta vieja no pisa la dirección de otro punto', () async {
    // La contracara: la tolerancia no puede ser tan grande como para escribir
    // la dirección de una esquina en la que el usuario ya no está.
    final container = contenedor(const _DispositivoQueResponde(lat, lng));
    final provider = selectorUbicacionControllerProvider(null);
    final notifier = container.read(provider.notifier);

    await notifier.irAMiUbicacion();

    // El usuario arrastra el mapa a cuatro cuadras de ahí antes de que
    // conteste la geocodificación del punto anterior.
    notifier.alQuedarQuietoElMapa(lat + 0.004, lng);
    await Future<void>.delayed(const Duration(milliseconds: 60));

    // La respuesta vieja se descarta. Lo que sí puede pasar es que la
    // geocodificación del punto nuevo la escriba después, pero eso lo dispara
    // el debounce y no esta prueba.
    expect(container.read(provider).direccionTexto, isNot(direccion));
  });

  test('sin permiso, avisa y deja el punto donde estaba', () async {
    final container = contenedor(const _DispositivoQueNiega());
    final provider = selectorUbicacionControllerProvider(null);
    final notifier = container.read(provider.notifier);

    final antes = container.read(provider);
    await notifier.irAMiUbicacion();
    final despues = container.read(provider);

    expect(despues.aviso, contains('permiso'));
    expect(despues.localizando, isFalse);
    expect(despues.lat, antes.lat);
    expect(despues.lng, antes.lng,
        reason: 'que digan que no no puede mover el mapa a ningún lado');
  });
}

/// Un dispositivo que siempre contesta la misma coordenada.
class _DispositivoQueResponde extends UbicacionDispositivo {
  const _DispositivoQueResponde(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  Future<ResultadoUbicacion> actual() async => PosicionObtenida(lat, lng);

  @override
  Future<PosicionObtenida?> actualSiYaHayPermiso() async => null;
}

/// Un dispositivo con el permiso denegado.
class _DispositivoQueNiega extends UbicacionDispositivo {
  const _DispositivoQueNiega();

  @override
  Future<ResultadoUbicacion> actual() async => const SinPosicion(
        MotivoSinPosicion.permisoDenegado,
        'No nos diste permiso para usar tu ubicación. Podés marcar el punto a '
        'mano en el mapa.',
      );

  @override
  Future<PosicionObtenida?> actualSiYaHayPermiso() async => null;
}
