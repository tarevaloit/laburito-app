// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servicio_push.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$servicioPushHash() => r'95274f3bc4758dcc3b789e31da44bb8afd60c204';

/// Se reemplaza con un `override` en los tests por una implementación de
/// mentira: nada de esta capa vuelve a hablar con Firebase de verdad.
///
/// Cae en [PushNoConfigurado] si `Firebase.initializeApp()` no corrió (o
/// falló) en `main.dart` — mismo criterio que el resto del CU-21: sin push la
/// app funciona igual, así que un Firebase mal configurado no puede tirar acá.
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
String _$avisosEnPrimerPlanoHash() =>
    r'63db636ea694d5271a938d2378b335356b09c3e7';

/// Mensajes que llegan con la app abierta. `LaburitoApp` los muestra en un
/// `SnackBar`: es la única forma de que se note una alerta en primer plano.
///
/// Copied from [avisosEnPrimerPlano].
@ProviderFor(avisosEnPrimerPlano)
final avisosEnPrimerPlanoProvider = StreamProvider<AvisoPush>.internal(
  avisosEnPrimerPlano,
  name: r'avisosEnPrimerPlanoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$avisosEnPrimerPlanoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvisosEnPrimerPlanoRef = StreamProviderRef<AvisoPush>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
