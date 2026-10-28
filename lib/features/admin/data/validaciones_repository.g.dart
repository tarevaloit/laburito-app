// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validaciones_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$validacionesRepositoryHash() =>
    r'4bd00861f11480888bf921b6e3dae2ffc53dc3f6';

/// See also [validacionesRepository].
@ProviderFor(validacionesRepository)
final validacionesRepositoryProvider =
    Provider<ValidacionesRepository>.internal(
  validacionesRepository,
  name: r'validacionesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$validacionesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ValidacionesRepositoryRef = ProviderRef<ValidacionesRepository>;
String _$profesionalesEnRevisionHash() =>
    r'02c8fa846cf4356c295088b3f9dee92c08a831cb';

/// See also [profesionalesEnRevision].
@ProviderFor(profesionalesEnRevision)
final profesionalesEnRevisionProvider =
    AutoDisposeFutureProvider<List<ProfesionalEnRevision>>.internal(
  profesionalesEnRevision,
  name: r'profesionalesEnRevisionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profesionalesEnRevisionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfesionalesEnRevisionRef
    = AutoDisposeFutureProviderRef<List<ProfesionalEnRevision>>;
String _$urlDocumentoAdminHash() => r'd46c8f42897f930b0e3e091577b8207d3ecd3ebc';

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

/// See also [urlDocumentoAdmin].
@ProviderFor(urlDocumentoAdmin)
const urlDocumentoAdminProvider = UrlDocumentoAdminFamily();

/// See also [urlDocumentoAdmin].
class UrlDocumentoAdminFamily extends Family<AsyncValue<String>> {
  /// See also [urlDocumentoAdmin].
  const UrlDocumentoAdminFamily();

  /// See also [urlDocumentoAdmin].
  UrlDocumentoAdminProvider call(
    String ruta,
  ) {
    return UrlDocumentoAdminProvider(
      ruta,
    );
  }

  @override
  UrlDocumentoAdminProvider getProviderOverride(
    covariant UrlDocumentoAdminProvider provider,
  ) {
    return call(
      provider.ruta,
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
  String? get name => r'urlDocumentoAdminProvider';
}

/// See also [urlDocumentoAdmin].
class UrlDocumentoAdminProvider extends AutoDisposeFutureProvider<String> {
  /// See also [urlDocumentoAdmin].
  UrlDocumentoAdminProvider(
    String ruta,
  ) : this._internal(
          (ref) => urlDocumentoAdmin(
            ref as UrlDocumentoAdminRef,
            ruta,
          ),
          from: urlDocumentoAdminProvider,
          name: r'urlDocumentoAdminProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$urlDocumentoAdminHash,
          dependencies: UrlDocumentoAdminFamily._dependencies,
          allTransitiveDependencies:
              UrlDocumentoAdminFamily._allTransitiveDependencies,
          ruta: ruta,
        );

  UrlDocumentoAdminProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ruta,
  }) : super.internal();

  final String ruta;

  @override
  Override overrideWith(
    FutureOr<String> Function(UrlDocumentoAdminRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UrlDocumentoAdminProvider._internal(
        (ref) => create(ref as UrlDocumentoAdminRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ruta: ruta,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _UrlDocumentoAdminProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UrlDocumentoAdminProvider && other.ruta == ruta;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ruta.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UrlDocumentoAdminRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `ruta` of this provider.
  String get ruta;
}

class _UrlDocumentoAdminProviderElement
    extends AutoDisposeFutureProviderElement<String> with UrlDocumentoAdminRef {
  _UrlDocumentoAdminProviderElement(super.provider);

  @override
  String get ruta => (origin as UrlDocumentoAdminProvider).ruta;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
