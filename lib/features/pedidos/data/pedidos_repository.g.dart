// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedidos_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pedidosRepositoryHash() => r'8343a05961899c8807d3cf8198a034790c51d759';

/// See also [pedidosRepository].
@ProviderFor(pedidosRepository)
final pedidosRepositoryProvider = Provider<PedidosRepository>.internal(
  pedidosRepository,
  name: r'pedidosRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pedidosRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PedidosRepositoryRef = ProviderRef<PedidosRepository>;
String _$pedidoHash() => r'd1e5ad58b43f7495d3d36a554f1e0876c79fc9de';

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

/// See also [pedido].
@ProviderFor(pedido)
const pedidoProvider = PedidoFamily();

/// See also [pedido].
class PedidoFamily extends Family<AsyncValue<Pedido?>> {
  /// See also [pedido].
  const PedidoFamily();

  /// See also [pedido].
  PedidoProvider call(
    String id,
  ) {
    return PedidoProvider(
      id,
    );
  }

  @override
  PedidoProvider getProviderOverride(
    covariant PedidoProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'pedidoProvider';
}

/// See also [pedido].
class PedidoProvider extends AutoDisposeFutureProvider<Pedido?> {
  /// See also [pedido].
  PedidoProvider(
    String id,
  ) : this._internal(
          (ref) => pedido(
            ref as PedidoRef,
            id,
          ),
          from: pedidoProvider,
          name: r'pedidoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pedidoHash,
          dependencies: PedidoFamily._dependencies,
          allTransitiveDependencies: PedidoFamily._allTransitiveDependencies,
          id: id,
        );

  PedidoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Pedido?> Function(PedidoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PedidoProvider._internal(
        (ref) => create(ref as PedidoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Pedido?> createElement() {
    return _PedidoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PedidoProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PedidoRef on AutoDisposeFutureProviderRef<Pedido?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PedidoProviderElement extends AutoDisposeFutureProviderElement<Pedido?>
    with PedidoRef {
  _PedidoProviderElement(super.provider);

  @override
  String get id => (origin as PedidoProvider).id;
}

String _$historialPedidoHash() => r'bebe3b6fe06032e6bb225a8592f9ff6f097ec534';

/// See also [historialPedido].
@ProviderFor(historialPedido)
const historialPedidoProvider = HistorialPedidoFamily();

/// See also [historialPedido].
class HistorialPedidoFamily extends Family<AsyncValue<List<PedidoEvento>>> {
  /// See also [historialPedido].
  const HistorialPedidoFamily();

  /// See also [historialPedido].
  HistorialPedidoProvider call(
    String id,
  ) {
    return HistorialPedidoProvider(
      id,
    );
  }

  @override
  HistorialPedidoProvider getProviderOverride(
    covariant HistorialPedidoProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'historialPedidoProvider';
}

/// See also [historialPedido].
class HistorialPedidoProvider
    extends AutoDisposeFutureProvider<List<PedidoEvento>> {
  /// See also [historialPedido].
  HistorialPedidoProvider(
    String id,
  ) : this._internal(
          (ref) => historialPedido(
            ref as HistorialPedidoRef,
            id,
          ),
          from: historialPedidoProvider,
          name: r'historialPedidoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$historialPedidoHash,
          dependencies: HistorialPedidoFamily._dependencies,
          allTransitiveDependencies:
              HistorialPedidoFamily._allTransitiveDependencies,
          id: id,
        );

  HistorialPedidoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<List<PedidoEvento>> Function(HistorialPedidoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HistorialPedidoProvider._internal(
        (ref) => create(ref as HistorialPedidoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PedidoEvento>> createElement() {
    return _HistorialPedidoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HistorialPedidoProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HistorialPedidoRef on AutoDisposeFutureProviderRef<List<PedidoEvento>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _HistorialPedidoProviderElement
    extends AutoDisposeFutureProviderElement<List<PedidoEvento>>
    with HistorialPedidoRef {
  _HistorialPedidoProviderElement(super.provider);

  @override
  String get id => (origin as HistorialPedidoProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
