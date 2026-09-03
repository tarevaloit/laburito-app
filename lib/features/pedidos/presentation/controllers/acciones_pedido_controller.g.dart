// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acciones_pedido_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accionesPedidoHash() => r'a4b45018d0f88f12c62628b367f9d2568b0cb1f2';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AccionesPedido
    extends BuildlessAutoDisposeNotifier<EstadoAccionesPedido> {
  late final String pedidoId;

  EstadoAccionesPedido build(
    String pedidoId,
  );
}

/// CU-20 (pausar/reanudar), CU-29 (cerrar), CU-14 (cancelar) y CU-51 (renovar).
///
/// Una sola familia para las cuatro operaciones porque comparten todo lo que
/// no es la llamada en sí: bloquear mientras se envía, envolver el
/// [PedidoException] y refrescar lo que quedó viejo. Lo que cambia —qué RPC se
/// llama, qué motivo se manda— cabe en una línea por método.
///
/// autoDispose: el estado de «estoy pausando» no tiene sentido fuera de la
/// pantalla que disparó la acción.
///
/// Copied from [AccionesPedido].
@ProviderFor(AccionesPedido)
const accionesPedidoProvider = AccionesPedidoFamily();

/// CU-20 (pausar/reanudar), CU-29 (cerrar), CU-14 (cancelar) y CU-51 (renovar).
///
/// Una sola familia para las cuatro operaciones porque comparten todo lo que
/// no es la llamada en sí: bloquear mientras se envía, envolver el
/// [PedidoException] y refrescar lo que quedó viejo. Lo que cambia —qué RPC se
/// llama, qué motivo se manda— cabe en una línea por método.
///
/// autoDispose: el estado de «estoy pausando» no tiene sentido fuera de la
/// pantalla que disparó la acción.
///
/// Copied from [AccionesPedido].
class AccionesPedidoFamily extends Family<EstadoAccionesPedido> {
  /// CU-20 (pausar/reanudar), CU-29 (cerrar), CU-14 (cancelar) y CU-51 (renovar).
  ///
  /// Una sola familia para las cuatro operaciones porque comparten todo lo que
  /// no es la llamada en sí: bloquear mientras se envía, envolver el
  /// [PedidoException] y refrescar lo que quedó viejo. Lo que cambia —qué RPC se
  /// llama, qué motivo se manda— cabe en una línea por método.
  ///
  /// autoDispose: el estado de «estoy pausando» no tiene sentido fuera de la
  /// pantalla que disparó la acción.
  ///
  /// Copied from [AccionesPedido].
  const AccionesPedidoFamily();

  /// CU-20 (pausar/reanudar), CU-29 (cerrar), CU-14 (cancelar) y CU-51 (renovar).
  ///
  /// Una sola familia para las cuatro operaciones porque comparten todo lo que
  /// no es la llamada en sí: bloquear mientras se envía, envolver el
  /// [PedidoException] y refrescar lo que quedó viejo. Lo que cambia —qué RPC se
  /// llama, qué motivo se manda— cabe en una línea por método.
  ///
  /// autoDispose: el estado de «estoy pausando» no tiene sentido fuera de la
  /// pantalla que disparó la acción.
  ///
  /// Copied from [AccionesPedido].
  AccionesPedidoProvider call(
    String pedidoId,
  ) {
    return AccionesPedidoProvider(
      pedidoId,
    );
  }

  @override
  AccionesPedidoProvider getProviderOverride(
    covariant AccionesPedidoProvider provider,
  ) {
    return call(
      provider.pedidoId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'accionesPedidoProvider';
}

/// CU-20 (pausar/reanudar), CU-29 (cerrar), CU-14 (cancelar) y CU-51 (renovar).
///
/// Una sola familia para las cuatro operaciones porque comparten todo lo que
/// no es la llamada en sí: bloquear mientras se envía, envolver el
/// [PedidoException] y refrescar lo que quedó viejo. Lo que cambia —qué RPC se
/// llama, qué motivo se manda— cabe en una línea por método.
///
/// autoDispose: el estado de «estoy pausando» no tiene sentido fuera de la
/// pantalla que disparó la acción.
///
/// Copied from [AccionesPedido].
class AccionesPedidoProvider extends AutoDisposeNotifierProviderImpl<
    AccionesPedido, EstadoAccionesPedido> {
  /// CU-20 (pausar/reanudar), CU-29 (cerrar), CU-14 (cancelar) y CU-51 (renovar).
  ///
  /// Una sola familia para las cuatro operaciones porque comparten todo lo que
  /// no es la llamada en sí: bloquear mientras se envía, envolver el
  /// [PedidoException] y refrescar lo que quedó viejo. Lo que cambia —qué RPC se
  /// llama, qué motivo se manda— cabe en una línea por método.
  ///
  /// autoDispose: el estado de «estoy pausando» no tiene sentido fuera de la
  /// pantalla que disparó la acción.
  ///
  /// Copied from [AccionesPedido].
  AccionesPedidoProvider(
    String pedidoId,
  ) : this._internal(
          () => AccionesPedido()..pedidoId = pedidoId,
          from: accionesPedidoProvider,
          name: r'accionesPedidoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$accionesPedidoHash,
          dependencies: AccionesPedidoFamily._dependencies,
          allTransitiveDependencies:
              AccionesPedidoFamily._allTransitiveDependencies,
          pedidoId: pedidoId,
        );

  AccionesPedidoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pedidoId,
  }) : super.internal();

  final String pedidoId;

  @override
  EstadoAccionesPedido runNotifierBuild(
    covariant AccionesPedido notifier,
  ) {
    return notifier.build(
      pedidoId,
    );
  }

  @override
  Override overrideWith(AccionesPedido Function() create) {
    return ProviderOverride(
      origin: this,
      override: AccionesPedidoProvider._internal(
        () => create()..pedidoId = pedidoId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pedidoId: pedidoId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AccionesPedido, EstadoAccionesPedido>
      createElement() {
    return _AccionesPedidoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccionesPedidoProvider && other.pedidoId == pedidoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pedidoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AccionesPedidoRef
    on AutoDisposeNotifierProviderRef<EstadoAccionesPedido> {
  /// The parameter `pedidoId` of this provider.
  String get pedidoId;
}

class _AccionesPedidoProviderElement extends AutoDisposeNotifierProviderElement<
    AccionesPedido, EstadoAccionesPedido> with AccionesPedidoRef {
  _AccionesPedidoProviderElement(super.provider);

  @override
  String get pedidoId => (origin as AccionesPedidoProvider).pedidoId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
