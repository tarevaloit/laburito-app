// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portafolio_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$portafolioHash() => r'6ac8f0e0dad0c913d97a50bbe2a646b9c778a174';

/// CU-06 — Cargar Portafolio.
///
/// Las fotos se aplican al instante, como en la edición del pedido (CU-15):
/// subir y borrar son operaciones sobre Storage que no tienen nada que
/// esperar, y juntarlas hasta un botón «Guardar» obligaría a deshacer subidas
/// si algo fallara después.
///
/// Copied from [Portafolio].
@ProviderFor(Portafolio)
final portafolioProvider =
    AutoDisposeAsyncNotifierProvider<Portafolio, EstadoPortafolio>.internal(
  Portafolio.new,
  name: r'portafolioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$portafolioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Portafolio = AutoDisposeAsyncNotifier<EstadoPortafolio>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
