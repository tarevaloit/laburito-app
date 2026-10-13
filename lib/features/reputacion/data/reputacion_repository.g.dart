// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reputacion_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reputacionRepositoryHash() =>
    r'2e092ff0de89b2b866322facbab8aae8fb72c184';

/// See also [reputacionRepository].
@ProviderFor(reputacionRepository)
final reputacionRepositoryProvider = Provider<ReputacionRepository>.internal(
  reputacionRepository,
  name: r'reputacionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reputacionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReputacionRepositoryRef = ProviderRef<ReputacionRepository>;
String _$perfilPublicoHash() => r'6296fb6b26daa7092aca94e864e433f9eb0500bc';

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

/// See also [perfilPublico].
@ProviderFor(perfilPublico)
const perfilPublicoProvider = PerfilPublicoFamily();

/// See also [perfilPublico].
class PerfilPublicoFamily extends Family<AsyncValue<PerfilPublico?>> {
  /// See also [perfilPublico].
  const PerfilPublicoFamily();

  /// See also [perfilPublico].
  PerfilPublicoProvider call(
    String slug,
  ) {
    return PerfilPublicoProvider(
      slug,
    );
  }

  @override
  PerfilPublicoProvider getProviderOverride(
    covariant PerfilPublicoProvider provider,
  ) {
    return call(
      provider.slug,
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
  String? get name => r'perfilPublicoProvider';
}

/// See also [perfilPublico].
class PerfilPublicoProvider extends AutoDisposeFutureProvider<PerfilPublico?> {
  /// See also [perfilPublico].
  PerfilPublicoProvider(
    String slug,
  ) : this._internal(
          (ref) => perfilPublico(
            ref as PerfilPublicoRef,
            slug,
          ),
          from: perfilPublicoProvider,
          name: r'perfilPublicoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$perfilPublicoHash,
          dependencies: PerfilPublicoFamily._dependencies,
          allTransitiveDependencies:
              PerfilPublicoFamily._allTransitiveDependencies,
          slug: slug,
        );

  PerfilPublicoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  Override overrideWith(
    FutureOr<PerfilPublico?> Function(PerfilPublicoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PerfilPublicoProvider._internal(
        (ref) => create(ref as PerfilPublicoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PerfilPublico?> createElement() {
    return _PerfilPublicoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PerfilPublicoProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PerfilPublicoRef on AutoDisposeFutureProviderRef<PerfilPublico?> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _PerfilPublicoProviderElement
    extends AutoDisposeFutureProviderElement<PerfilPublico?>
    with PerfilPublicoRef {
  _PerfilPublicoProviderElement(super.provider);

  @override
  String get slug => (origin as PerfilPublicoProvider).slug;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
