// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registro_push.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$registroPushHash() => r'03ef8ad80ab015daec8788da651dbe4b1678fc31';

/// CU-21 — Deja este teléfono registrado mientras haya un Profesional adentro.
///
/// Es un provider con efecto y no una llamada suelta en una pantalla porque el
/// registro tiene que pasar **una vez por sesión**, no una vez por pantalla
/// abierta: depende del perfil, no de dónde esté navegando la persona.
///
/// Qué hace, en orden: si quien está adentro es un Profesional, pide el
/// permiso del sistema, registra el token y se queda escuchando las
/// renovaciones —FCM rota el token solo, y un token viejo es un teléfono que
/// deja de recibir alertas sin avisar—. Con un Buscador no hace nada: las
/// alertas del CU-21 son del lado del Profesional.
///
/// Nunca tira: un permiso denegado, o un servidor caído, no pueden impedir que
/// la app se use. Sin token no hay push, y el Profesional ve los pedidos
/// entrando al tablero.
///
/// Copied from [RegistroPush].
@ProviderFor(RegistroPush)
final registroPushProvider =
    AsyncNotifierProvider<RegistroPush, String?>.internal(
  RegistroPush.new,
  name: r'registroPushProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$registroPushHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RegistroPush = AsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
