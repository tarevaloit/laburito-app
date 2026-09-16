// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tablero_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tableroRepositoryHash() => r'9102c4dd9fc9dbb4f30951360c1df9038666d89b';

/// See also [tableroRepository].
@ProviderFor(tableroRepository)
final tableroRepositoryProvider = Provider<TableroRepository>.internal(
  tableroRepository,
  name: r'tableroRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tableroRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TableroRepositoryRef = ProviderRef<TableroRepository>;
String _$pedidoPublicoHash() => r'9a9c41dc37dfc5a29513e74eb4585eaa2863936c';

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

/// El detalle de un pedido del tablero (CU-22). Autodispose y por familia: al
/// volver al tablero se descarta, y al entrar de nuevo se relee —un pedido
/// ajeno puede haberse cerrado mientras tanto—.
///
/// Copied from [pedidoPublico].
@ProviderFor(pedidoPublico)
const pedidoPublicoProvider = PedidoPublicoFamily();

/// El detalle de un pedido del tablero (CU-22). Autodispose y por familia: al
/// volver al tablero se descarta, y al entrar de nuevo se relee —un pedido
/// ajeno puede haberse cerrado mientras tanto—.
///
/// Copied from [pedidoPublico].
class PedidoPublicoFamily extends Family<AsyncValue<PedidoTablero?>> {
  /// El detalle de un pedido del tablero (CU-22). Autodispose y por familia: al
  /// volver al tablero se descarta, y al entrar de nuevo se relee —un pedido
  /// ajeno puede haberse cerrado mientras tanto—.
  ///
  /// Copied from [pedidoPublico].
  const PedidoPublicoFamily();

  /// El detalle de un pedido del tablero (CU-22). Autodispose y por familia: al
  /// volver al tablero se descarta, y al entrar de nuevo se relee —un pedido
  /// ajeno puede haberse cerrado mientras tanto—.
  ///
  /// Copied from [pedidoPublico].
  PedidoPublicoProvider call(
    String id,
  ) {
    return PedidoPublicoProvider(
      id,
    );
  }

  @override
  PedidoPublicoProvider getProviderOverride(
    covariant PedidoPublicoProvider provider,
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
  String? get name => r'pedidoPublicoProvider';
}

/// El detalle de un pedido del tablero (CU-22). Autodispose y por familia: al
/// volver al tablero se descarta, y al entrar de nuevo se relee —un pedido
/// ajeno puede haberse cerrado mientras tanto—.
///
/// Copied from [pedidoPublico].
class PedidoPublicoProvider extends AutoDisposeFutureProvider<PedidoTablero?> {
  /// El detalle de un pedido del tablero (CU-22). Autodispose y por familia: al
  /// volver al tablero se descarta, y al entrar de nuevo se relee —un pedido
  /// ajeno puede haberse cerrado mientras tanto—.
  ///
  /// Copied from [pedidoPublico].
  PedidoPublicoProvider(
    String id,
  ) : this._internal(
          (ref) => pedidoPublico(
            ref as PedidoPublicoRef,
            id,
          ),
          from: pedidoPublicoProvider,
          name: r'pedidoPublicoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pedidoPublicoHash,
          dependencies: PedidoPublicoFamily._dependencies,
          allTransitiveDependencies:
              PedidoPublicoFamily._allTransitiveDependencies,
          id: id,
        );

  PedidoPublicoProvider._internal(
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
    FutureOr<PedidoTablero?> Function(PedidoPublicoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PedidoPublicoProvider._internal(
        (ref) => create(ref as PedidoPublicoRef),
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
  AutoDisposeFutureProviderElement<PedidoTablero?> createElement() {
    return _PedidoPublicoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PedidoPublicoProvider && other.id == id;
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
mixin PedidoPublicoRef on AutoDisposeFutureProviderRef<PedidoTablero?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PedidoPublicoProviderElement
    extends AutoDisposeFutureProviderElement<PedidoTablero?>
    with PedidoPublicoRef {
  _PedidoPublicoProviderElement(super.provider);

  @override
  String get id => (origin as PedidoPublicoProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
