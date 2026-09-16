// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servicio_push.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$servicioPushHash() => r'35f3aea85180c5cf3b9dad56be713454aaed36b9';

/// Se reemplaza con un `override` el día que entre `firebase_messaging`, y en
/// los tests por una implementación de mentira.
///
/// Copied from [servicioPush].
@ProviderFor(servicioPush)
final servicioPushProvider = Provider<ServicioPush>.internal(
  servicioPush,
  name: r'servicioPushProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$servicioPushHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ServicioPushRef = ProviderRef<ServicioPush>;
String _$pedidosAbiertosHash() => r'20f104f995120e9cee9acd8c63bd355efdb35d4b';

/// El id del pedido de cada notificación que la persona abrió. Lo escucha
/// `LaburitoApp` para navegar al detalle (CU-22 lo va a mostrar del lado del
/// Profesional; hoy abre la misma pantalla que ve el Buscador).
///
/// Copied from [pedidosAbiertos].
@ProviderFor(pedidosAbiertos)
final pedidosAbiertosProvider = StreamProvider<String>.internal(
  pedidosAbiertos,
  name: r'pedidosAbiertosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pedidosAbiertosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PedidosAbiertosRef = StreamProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
