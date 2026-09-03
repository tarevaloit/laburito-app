// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authControllerHash() => r'8b1bf467e675ab94fa655c8700881f41387a691e';

/// Orquesta las operaciones de autenticación y expone su estado de carga.
/// Cada método devuelve `true` si la operación terminó sin error.
///
/// `keepAlive`: era un `AsyncNotifierProvider` a mano, que no se descarta. Con
/// autoDispose el notificador podría morir entre el `read(...notifier)` y el
/// `read(...).error` que las pantallas hacen justo después, y el mensaje de
/// error se perdería.
///
/// Copied from [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
