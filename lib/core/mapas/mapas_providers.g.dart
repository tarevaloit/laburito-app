// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapas_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$servicioDireccionesHash() =>
    r'3ef2d23b69577a6c49137d91494c36087f7cbdcc';

/// `keepAlive` porque adentro hay un `http.Client` con su pool de conexiones:
/// recrearlo cada vez que se abre el selector tira la conexión reusada y paga
/// el TLS de nuevo.
///
/// Los tests que ejerciten una pantalla con mapa sobrescriben este provider con
/// un [ServicioDirecciones] de cliente falso; por eso el servicio recibe el
/// `http.Client` por constructor y no lo crea adentro sin alternativa.
///
/// Copied from [servicioDirecciones].
@ProviderFor(servicioDirecciones)
final servicioDireccionesProvider = Provider<ServicioDirecciones>.internal(
  servicioDirecciones,
  name: r'servicioDireccionesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$servicioDireccionesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServicioDireccionesRef = ProviderRef<ServicioDirecciones>;
String _$ubicacionDispositivoHash() =>
    r'7a40483ac00347ab3748a007a018c7e6a142325f';

/// Sin estado: es una fachada sobre los estáticos de `geolocator`. Existe como
/// provider para poder sustituirlo en las pruebas de widget del CU-16, donde no
/// hay dispositivo que responda.
///
/// Copied from [ubicacionDispositivo].
@ProviderFor(ubicacionDispositivo)
final ubicacionDispositivoProvider = Provider<UbicacionDispositivo>.internal(
  ubicacionDispositivo,
  name: r'ubicacionDispositivoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ubicacionDispositivoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UbicacionDispositivoRef = ProviderRef<UbicacionDispositivo>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
