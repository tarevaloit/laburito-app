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

String _$misContactosHash() => r'c2475387364f683a57d130d3588cc73ca1cb9f45';

/// See also [misContactos].
@ProviderFor(misContactos)
final misContactosProvider =
    AutoDisposeFutureProvider<List<MiContacto>>.internal(
  misContactos,
  name: r'misContactosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$misContactosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MisContactosRef = AutoDisposeFutureProviderRef<List<MiContacto>>;
String _$enlaceCalificacionHash() =>
    r'e7e733d4b459e8ffbc28093acffdaf471a1f2ecd';

/// See also [enlaceCalificacion].
@ProviderFor(enlaceCalificacion)
const enlaceCalificacionProvider = EnlaceCalificacionFamily();

/// See also [enlaceCalificacion].
class EnlaceCalificacionFamily extends Family<AsyncValue<EnlaceCalificacion>> {
  /// See also [enlaceCalificacion].
  const EnlaceCalificacionFamily();

  /// See also [enlaceCalificacion].
  EnlaceCalificacionProvider call(
    String token,
  ) {
    return EnlaceCalificacionProvider(
      token,
    );
  }

  @override
  EnlaceCalificacionProvider getProviderOverride(
    covariant EnlaceCalificacionProvider provider,
  ) {
    return call(
      provider.token,
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
  String? get name => r'enlaceCalificacionProvider';
}

/// See also [enlaceCalificacion].
class EnlaceCalificacionProvider
    extends AutoDisposeFutureProvider<EnlaceCalificacion> {
  /// See also [enlaceCalificacion].
  EnlaceCalificacionProvider(
    String token,
  ) : this._internal(
          (ref) => enlaceCalificacion(
            ref as EnlaceCalificacionRef,
            token,
          ),
          from: enlaceCalificacionProvider,
          name: r'enlaceCalificacionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$enlaceCalificacionHash,
          dependencies: EnlaceCalificacionFamily._dependencies,
          allTransitiveDependencies:
              EnlaceCalificacionFamily._allTransitiveDependencies,
          token: token,
        );

  EnlaceCalificacionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.token,
  }) : super.internal();

  final String token;

  @override
  Override overrideWith(
    FutureOr<EnlaceCalificacion> Function(EnlaceCalificacionRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EnlaceCalificacionProvider._internal(
        (ref) => create(ref as EnlaceCalificacionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        token: token,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EnlaceCalificacion> createElement() {
    return _EnlaceCalificacionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EnlaceCalificacionProvider && other.token == token;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, token.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EnlaceCalificacionRef
    on AutoDisposeFutureProviderRef<EnlaceCalificacion> {
  /// The parameter `token` of this provider.
  String get token;
}

class _EnlaceCalificacionProviderElement
    extends AutoDisposeFutureProviderElement<EnlaceCalificacion>
    with EnlaceCalificacionRef {
  _EnlaceCalificacionProviderElement(super.provider);

  @override
  String get token => (origin as EnlaceCalificacionProvider).token;
}

String _$metricasPerfilHash() => r'd6c55efa3680ef0e6ce6f14db67172a60c15f56e';

/// See also [metricasPerfil].
@ProviderFor(metricasPerfil)
const metricasPerfilProvider = MetricasPerfilFamily();

/// See also [metricasPerfil].
class MetricasPerfilFamily extends Family<AsyncValue<MetricasPerfil>> {
  /// See also [metricasPerfil].
  const MetricasPerfilFamily();

  /// See also [metricasPerfil].
  MetricasPerfilProvider call(
    PeriodoMetricas periodo,
  ) {
    return MetricasPerfilProvider(
      periodo,
    );
  }

  @override
  MetricasPerfilProvider getProviderOverride(
    covariant MetricasPerfilProvider provider,
  ) {
    return call(
      provider.periodo,
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
  String? get name => r'metricasPerfilProvider';
}

/// See also [metricasPerfil].
class MetricasPerfilProvider extends AutoDisposeFutureProvider<MetricasPerfil> {
  /// See also [metricasPerfil].
  MetricasPerfilProvider(
    PeriodoMetricas periodo,
  ) : this._internal(
          (ref) => metricasPerfil(
            ref as MetricasPerfilRef,
            periodo,
          ),
          from: metricasPerfilProvider,
          name: r'metricasPerfilProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$metricasPerfilHash,
          dependencies: MetricasPerfilFamily._dependencies,
          allTransitiveDependencies:
              MetricasPerfilFamily._allTransitiveDependencies,
          periodo: periodo,
        );

  MetricasPerfilProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.periodo,
  }) : super.internal();

  final PeriodoMetricas periodo;

  @override
  Override overrideWith(
    FutureOr<MetricasPerfil> Function(MetricasPerfilRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MetricasPerfilProvider._internal(
        (ref) => create(ref as MetricasPerfilRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        periodo: periodo,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MetricasPerfil> createElement() {
    return _MetricasPerfilProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MetricasPerfilProvider && other.periodo == periodo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, periodo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MetricasPerfilRef on AutoDisposeFutureProviderRef<MetricasPerfil> {
  /// The parameter `periodo` of this provider.
  PeriodoMetricas get periodo;
}

class _MetricasPerfilProviderElement
    extends AutoDisposeFutureProviderElement<MetricasPerfil>
    with MetricasPerfilRef {
  _MetricasPerfilProviderElement(super.provider);

  @override
  PeriodoMetricas get periodo => (origin as MetricasPerfilProvider).periodo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
