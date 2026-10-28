// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuarios_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$usuariosRepositoryHash() =>
    r'd69119e498531f14aee691418be70ab0fa70f904';

/// See also [usuariosRepository].
@ProviderFor(usuariosRepository)
final usuariosRepositoryProvider = Provider<UsuariosRepository>.internal(
  usuariosRepository,
  name: r'usuariosRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$usuariosRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UsuariosRepositoryRef = ProviderRef<UsuariosRepository>;
String _$usuariosAdminHash() => r'10445968e7b2ad290e9de981f473841bc2e32462';

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

/// See also [usuariosAdmin].
@ProviderFor(usuariosAdmin)
const usuariosAdminProvider = UsuariosAdminFamily();

/// See also [usuariosAdmin].
class UsuariosAdminFamily extends Family<AsyncValue<List<UsuarioAdmin>>> {
  /// See also [usuariosAdmin].
  const UsuariosAdminFamily();

  /// See also [usuariosAdmin].
  UsuariosAdminProvider call(
    String texto,
    String? tipo,
  ) {
    return UsuariosAdminProvider(
      texto,
      tipo,
    );
  }

  @override
  UsuariosAdminProvider getProviderOverride(
    covariant UsuariosAdminProvider provider,
  ) {
    return call(
      provider.texto,
      provider.tipo,
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
  String? get name => r'usuariosAdminProvider';
}

/// See also [usuariosAdmin].
class UsuariosAdminProvider
    extends AutoDisposeFutureProvider<List<UsuarioAdmin>> {
  /// See also [usuariosAdmin].
  UsuariosAdminProvider(
    String texto,
    String? tipo,
  ) : this._internal(
          (ref) => usuariosAdmin(
            ref as UsuariosAdminRef,
            texto,
            tipo,
          ),
          from: usuariosAdminProvider,
          name: r'usuariosAdminProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$usuariosAdminHash,
          dependencies: UsuariosAdminFamily._dependencies,
          allTransitiveDependencies:
              UsuariosAdminFamily._allTransitiveDependencies,
          texto: texto,
          tipo: tipo,
        );

  UsuariosAdminProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.texto,
    required this.tipo,
  }) : super.internal();

  final String texto;
  final String? tipo;

  @override
  Override overrideWith(
    FutureOr<List<UsuarioAdmin>> Function(UsuariosAdminRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UsuariosAdminProvider._internal(
        (ref) => create(ref as UsuariosAdminRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        texto: texto,
        tipo: tipo,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UsuarioAdmin>> createElement() {
    return _UsuariosAdminProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UsuariosAdminProvider &&
        other.texto == texto &&
        other.tipo == tipo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, texto.hashCode);
    hash = _SystemHash.combine(hash, tipo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UsuariosAdminRef on AutoDisposeFutureProviderRef<List<UsuarioAdmin>> {
  /// The parameter `texto` of this provider.
  String get texto;

  /// The parameter `tipo` of this provider.
  String? get tipo;
}

class _UsuariosAdminProviderElement
    extends AutoDisposeFutureProviderElement<List<UsuarioAdmin>>
    with UsuariosAdminRef {
  _UsuariosAdminProviderElement(super.provider);

  @override
  String get texto => (origin as UsuariosAdminProvider).texto;
  @override
  String? get tipo => (origin as UsuariosAdminProvider).tipo;
}

String _$detalleUsuarioAdminHash() =>
    r'fa7ce49ee0ddd3cf25bdfabff0241712dd2fdb39';

/// See also [detalleUsuarioAdmin].
@ProviderFor(detalleUsuarioAdmin)
const detalleUsuarioAdminProvider = DetalleUsuarioAdminFamily();

/// See also [detalleUsuarioAdmin].
class DetalleUsuarioAdminFamily extends Family<AsyncValue<DetalleUsuario>> {
  /// See also [detalleUsuarioAdmin].
  const DetalleUsuarioAdminFamily();

  /// See also [detalleUsuarioAdmin].
  DetalleUsuarioAdminProvider call(
    String id,
  ) {
    return DetalleUsuarioAdminProvider(
      id,
    );
  }

  @override
  DetalleUsuarioAdminProvider getProviderOverride(
    covariant DetalleUsuarioAdminProvider provider,
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
  String? get name => r'detalleUsuarioAdminProvider';
}

/// See also [detalleUsuarioAdmin].
class DetalleUsuarioAdminProvider
    extends AutoDisposeFutureProvider<DetalleUsuario> {
  /// See also [detalleUsuarioAdmin].
  DetalleUsuarioAdminProvider(
    String id,
  ) : this._internal(
          (ref) => detalleUsuarioAdmin(
            ref as DetalleUsuarioAdminRef,
            id,
          ),
          from: detalleUsuarioAdminProvider,
          name: r'detalleUsuarioAdminProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$detalleUsuarioAdminHash,
          dependencies: DetalleUsuarioAdminFamily._dependencies,
          allTransitiveDependencies:
              DetalleUsuarioAdminFamily._allTransitiveDependencies,
          id: id,
        );

  DetalleUsuarioAdminProvider._internal(
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
    FutureOr<DetalleUsuario> Function(DetalleUsuarioAdminRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DetalleUsuarioAdminProvider._internal(
        (ref) => create(ref as DetalleUsuarioAdminRef),
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
  AutoDisposeFutureProviderElement<DetalleUsuario> createElement() {
    return _DetalleUsuarioAdminProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DetalleUsuarioAdminProvider && other.id == id;
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
mixin DetalleUsuarioAdminRef on AutoDisposeFutureProviderRef<DetalleUsuario> {
  /// The parameter `id` of this provider.
  String get id;
}

class _DetalleUsuarioAdminProviderElement
    extends AutoDisposeFutureProviderElement<DetalleUsuario>
    with DetalleUsuarioAdminRef {
  _DetalleUsuarioAdminProviderElement(super.provider);

  @override
  String get id => (origin as DetalleUsuarioAdminProvider).id;
}

String _$apelacionesAdminHash() => r'd54b71dcccb1fecdc7ef539342a2f8dc8de8f3bc';

/// See also [apelacionesAdmin].
@ProviderFor(apelacionesAdmin)
final apelacionesAdminProvider =
    AutoDisposeFutureProvider<List<ApelacionAdmin>>.internal(
  apelacionesAdmin,
  name: r'apelacionesAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apelacionesAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApelacionesAdminRef
    = AutoDisposeFutureProviderRef<List<ApelacionAdmin>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
