// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crear_pedido_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$crearPedidoControllerHash() =>
    r'2a321d917784be9332a5a0369c9c22872f0cc5f3';

/// CU-13 — Publicar Pedido, en cuatro pasos.
///
/// autoDispose: cada apertura del asistente arranca de cero. Si el usuario
/// sale y vuelve a entrar, no tiene sentido que reaparezca un borrador viejo.
///
/// Copied from [CrearPedidoController].
@ProviderFor(CrearPedidoController)
final crearPedidoControllerProvider = AutoDisposeNotifierProvider<
    CrearPedidoController, EstadoCrearPedido>.internal(
  CrearPedidoController.new,
  name: r'crearPedidoControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$crearPedidoControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CrearPedidoController = AutoDisposeNotifier<EstadoCrearPedido>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
