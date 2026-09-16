// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tablero_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tableroHash() => r'bc7dd86172fc5ef0e4b14e58378501ecb7fc599a';

/// CU-43 — Explorar Tablero de Pedidos.
///
/// El orden por distancia lo resuelve `tablero_pedidos()` (migración 0018):
/// ordenar del lado del cliente obligaría a traerse todos los pedidos vigentes
/// para poder decidir cuáles son los veinte más cercanos.
///
/// Copied from [Tablero].
@ProviderFor(Tablero)
final tableroProvider =
    AutoDisposeAsyncNotifierProvider<Tablero, EstadoTablero>.internal(
  Tablero.new,
  name: r'tableroProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tableroHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Tablero = AutoDisposeAsyncNotifier<EstadoTablero>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
