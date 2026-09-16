// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zona_cobertura_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$zonaCoberturaControladorHash() =>
    r'951bf2b679744c8cd44e281a6e50254377accc2b';

/// CU-07 — Configurar Zona de Cobertura.
///
/// La zona es el primer insumo del emparejamiento del CU-21: sin ella no hay
/// contra qué comparar la ubicación de un pedido. El otro son las categorías
/// del CU-12.
///
/// Copied from [ZonaCoberturaControlador].
@ProviderFor(ZonaCoberturaControlador)
final zonaCoberturaControladorProvider = AutoDisposeAsyncNotifierProvider<
    ZonaCoberturaControlador, EstadoZonaCobertura>.internal(
  ZonaCoberturaControlador.new,
  name: r'zonaCoberturaControladorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$zonaCoberturaControladorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ZonaCoberturaControlador
    = AutoDisposeAsyncNotifier<EstadoZonaCobertura>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
