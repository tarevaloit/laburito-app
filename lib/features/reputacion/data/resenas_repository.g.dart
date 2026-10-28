// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resenas_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resenasRepositoryHash() => r'e6a38963687878271bda9effbfa8b988060184ce';

/// See also [resenasRepository].
@ProviderFor(resenasRepository)
final resenasRepositoryProvider = Provider<ResenasRepository>.internal(
  resenasRepository,
  name: r'resenasRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resenasRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ResenasRepositoryRef = ProviderRef<ResenasRepository>;
String _$misResenasHash() => r'2e3553cd25d77914171ebee572f6256eceb9f9b6';

/// See also [misResenas].
@ProviderFor(misResenas)
final misResenasProvider = AutoDisposeFutureProvider<List<Resena>>.internal(
  misResenas,
  name: r'misResenasProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$misResenasHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MisResenasRef = AutoDisposeFutureProviderRef<List<Resena>>;
String _$resenasAModerarHash() => r'e7853d477790b9eb073148047ed8ce1dde429780';

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

/// See also [resenasAModerar].
@ProviderFor(resenasAModerar)
const resenasAModerarProvider = ResenasAModerarFamily();

/// See also [resenasAModerar].
class ResenasAModerarFamily extends Family<AsyncValue<List<Resena>>> {
  /// See also [resenasAModerar].
  const ResenasAModerarFamily();

  /// See also [resenasAModerar].
  ResenasAModerarProvider call(
    bool incluirResueltas,
  ) {
    return ResenasAModerarProvider(
      incluirResueltas,
    );
  }

  @override
  ResenasAModerarProvider getProviderOverride(
    covariant ResenasAModerarProvider provider,
  ) {
    return call(
      provider.incluirResueltas,
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
  String? get name => r'resenasAModerarProvider';
}

/// See also [resenasAModerar].
class ResenasAModerarProvider extends AutoDisposeFutureProvider<List<Resena>> {
  /// See also [resenasAModerar].
  ResenasAModerarProvider(
    bool incluirResueltas,
  ) : this._internal(
          (ref) => resenasAModerar(
            ref as ResenasAModerarRef,
            incluirResueltas,
          ),
          from: resenasAModerarProvider,
          name: r'resenasAModerarProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$resenasAModerarHash,
          dependencies: ResenasAModerarFamily._dependencies,
          allTransitiveDependencies:
              ResenasAModerarFamily._allTransitiveDependencies,
          incluirResueltas: incluirResueltas,
        );

  ResenasAModerarProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.incluirResueltas,
  }) : super.internal();

  final bool incluirResueltas;

  @override
  Override overrideWith(
    FutureOr<List<Resena>> Function(ResenasAModerarRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ResenasAModerarProvider._internal(
        (ref) => create(ref as ResenasAModerarRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        incluirResueltas: incluirResueltas,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Resena>> createElement() {
    return _ResenasAModerarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ResenasAModerarProvider &&
        other.incluirResueltas == incluirResueltas;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, incluirResueltas.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ResenasAModerarRef on AutoDisposeFutureProviderRef<List<Resena>> {
  /// The parameter `incluirResueltas` of this provider.
  bool get incluirResueltas;
}

class _ResenasAModerarProviderElement
    extends AutoDisposeFutureProviderElement<List<Resena>>
    with ResenasAModerarRef {
  _ResenasAModerarProviderElement(super.provider);

  @override
  bool get incluirResueltas =>
      (origin as ResenasAModerarProvider).incluirResueltas;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
