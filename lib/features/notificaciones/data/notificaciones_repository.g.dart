// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notificaciones_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificacionesRepositoryHash() =>
    r'f767cf0e587a59f7599023136407372e5ff11303';

/// See also [notificacionesRepository].
@ProviderFor(notificacionesRepository)
final notificacionesRepositoryProvider =
    Provider<NotificacionesRepository>.internal(
  notificacionesRepository,
  name: r'notificacionesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificacionesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificacionesRepositoryRef = ProviderRef<NotificacionesRepository>;
String _$notificacionesHash() => r'e8c361a41190c08d7fcfb9877fdeb8e2b021e055';

/// See also [notificaciones].
@ProviderFor(notificaciones)
final notificacionesProvider =
    AutoDisposeStreamProvider<List<Notificacion>>.internal(
  notificaciones,
  name: r'notificacionesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificacionesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificacionesRef = AutoDisposeStreamProviderRef<List<Notificacion>>;
String _$notificacionesSinLeerHash() =>
    r'48c9acdf1f4e158c48d9353165c8dc0833eea27a';

/// El número de la campana.
///
/// Copied from [notificacionesSinLeer].
@ProviderFor(notificacionesSinLeer)
final notificacionesSinLeerProvider = AutoDisposeProvider<int>.internal(
  notificacionesSinLeer,
  name: r'notificacionesSinLeerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificacionesSinLeerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificacionesSinLeerRef = AutoDisposeProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
