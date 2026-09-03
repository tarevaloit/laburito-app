// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historial_pedidos_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historialPedidosHash() => r'd24f9991c762bc5722184761f032a5c8c30da828';

/// CU-17 — Consultar Historial.
///
/// Una sola instancia para toda la pantalla, y no una familia por filtro: el
/// filtro, el texto buscado y la página cargada son **un solo estado**. Con una
/// familia por filtro, cambiar de pestaña perdería lo que se estaba buscando y
/// cada pestaña pagaría su propia paginación.
///
/// autoDispose: al volver al historial se recarga, que es lo que se espera
/// después de publicar, cerrar o renovar un pedido.
///
/// Copied from [HistorialPedidos].
@ProviderFor(HistorialPedidos)
final historialPedidosProvider = AutoDisposeAsyncNotifierProvider<
    HistorialPedidos, EstadoHistorial>.internal(
  HistorialPedidos.new,
  name: r'historialPedidosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historialPedidosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistorialPedidos = AutoDisposeAsyncNotifier<EstadoHistorial>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
