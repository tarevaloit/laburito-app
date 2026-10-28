// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'denuncias_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$denunciasRepositoryHash() =>
    r'f2ff085b31de6e859b544e13b65b8a0e003ec38c';

/// See also [denunciasRepository].
@ProviderFor(denunciasRepository)
final denunciasRepositoryProvider = Provider<DenunciasRepository>.internal(
  denunciasRepository,
  name: r'denunciasRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$denunciasRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DenunciasRepositoryRef = ProviderRef<DenunciasRepository>;
String _$denunciasAdminHash() => r'728cbd1bdb8b6e85d5a724744e5077fbc29c1a0a';

/// See also [denunciasAdmin].
@ProviderFor(denunciasAdmin)
final denunciasAdminProvider =
    AutoDisposeFutureProvider<List<DenunciaAdmin>>.internal(
  denunciasAdmin,
  name: r'denunciasAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$denunciasAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DenunciasAdminRef = AutoDisposeFutureProviderRef<List<DenunciaAdmin>>;
String _$trazabilidadDenunciaHash() =>
    r'38b393bd67e43e9b4347826c395565d97e0d0bbe';

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

/// See also [trazabilidadDenuncia].
@ProviderFor(trazabilidadDenuncia)
const trazabilidadDenunciaProvider = TrazabilidadDenunciaFamily();

/// See also [trazabilidadDenuncia].
class TrazabilidadDenunciaFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [trazabilidadDenuncia].
  const TrazabilidadDenunciaFamily();

  /// See also [trazabilidadDenuncia].
  TrazabilidadDenunciaProvider call(
    String id,
  ) {
    return TrazabilidadDenunciaProvider(
      id,
    );
  }

  @override
  TrazabilidadDenunciaProvider getProviderOverride(
    covariant TrazabilidadDenunciaProvider provider,
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
  String? get name => r'trazabilidadDenunciaProvider';
}

/// See also [trazabilidadDenuncia].
class TrazabilidadDenunciaProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [trazabilidadDenuncia].
  TrazabilidadDenunciaProvider(
    String id,
  ) : this._internal(
          (ref) => trazabilidadDenuncia(
            ref as TrazabilidadDenunciaRef,
            id,
          ),
          from: trazabilidadDenunciaProvider,
          name: r'trazabilidadDenunciaProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$trazabilidadDenunciaHash,
          dependencies: TrazabilidadDenunciaFamily._dependencies,
          allTransitiveDependencies:
              TrazabilidadDenunciaFamily._allTransitiveDependencies,
          id: id,
        );

  TrazabilidadDenunciaProvider._internal(
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
    FutureOr<Map<String, dynamic>> Function(TrazabilidadDenunciaRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrazabilidadDenunciaProvider._internal(
        (ref) => create(ref as TrazabilidadDenunciaRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _TrazabilidadDenunciaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrazabilidadDenunciaProvider && other.id == id;
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
mixin TrazabilidadDenunciaRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TrazabilidadDenunciaProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with TrazabilidadDenunciaRef {
  _TrazabilidadDenunciaProviderElement(super.provider);

  @override
  String get id => (origin as TrazabilidadDenunciaProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
