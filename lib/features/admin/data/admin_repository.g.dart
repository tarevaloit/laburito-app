// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminRepositoryHash() => r'aef23abc782f1d461c231511b12f578cf7327440';

/// See also [adminRepository].
@ProviderFor(adminRepository)
final adminRepositoryProvider = Provider<AdminRepository>.internal(
  adminRepository,
  name: r'adminRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRepositoryRef = ProviderRef<AdminRepository>;
String _$paquetesAdminHash() => r'eafb5dfa91d2968d4de551727fda25c79f497409';

/// See also [paquetesAdmin].
@ProviderFor(paquetesAdmin)
final paquetesAdminProvider =
    AutoDisposeFutureProvider<List<PaqueteTokens>>.internal(
  paquetesAdmin,
  name: r'paquetesAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paquetesAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaquetesAdminRef = AutoDisposeFutureProviderRef<List<PaqueteTokens>>;
String _$cuponesAdminHash() => r'f4df8b61415d7797e5a527ff56f662d64f0679cf';

/// See also [cuponesAdmin].
@ProviderFor(cuponesAdmin)
final cuponesAdminProvider = AutoDisposeFutureProvider<List<Cupon>>.internal(
  cuponesAdmin,
  name: r'cuponesAdminProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cuponesAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CuponesAdminRef = AutoDisposeFutureProviderRef<List<Cupon>>;
String _$dashboardAdminHash() => r'92d9e4353c5342a73130e14bb0fa243beb3d99f2';

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

/// CU-38. El rango es un parámetro de la familia: cambiarlo dispara la
/// consulta de ese rango sin perder la anterior si se vuelve a ella.
///
/// Copied from [dashboardAdmin].
@ProviderFor(dashboardAdmin)
const dashboardAdminProvider = DashboardAdminFamily();

/// CU-38. El rango es un parámetro de la familia: cambiarlo dispara la
/// consulta de ese rango sin perder la anterior si se vuelve a ella.
///
/// Copied from [dashboardAdmin].
class DashboardAdminFamily extends Family<AsyncValue<Dashboard>> {
  /// CU-38. El rango es un parámetro de la familia: cambiarlo dispara la
  /// consulta de ese rango sin perder la anterior si se vuelve a ella.
  ///
  /// Copied from [dashboardAdmin].
  const DashboardAdminFamily();

  /// CU-38. El rango es un parámetro de la familia: cambiarlo dispara la
  /// consulta de ese rango sin perder la anterior si se vuelve a ella.
  ///
  /// Copied from [dashboardAdmin].
  DashboardAdminProvider call(
    DateTime desde,
    DateTime hasta,
  ) {
    return DashboardAdminProvider(
      desde,
      hasta,
    );
  }

  @override
  DashboardAdminProvider getProviderOverride(
    covariant DashboardAdminProvider provider,
  ) {
    return call(
      provider.desde,
      provider.hasta,
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
  String? get name => r'dashboardAdminProvider';
}

/// CU-38. El rango es un parámetro de la familia: cambiarlo dispara la
/// consulta de ese rango sin perder la anterior si se vuelve a ella.
///
/// Copied from [dashboardAdmin].
class DashboardAdminProvider extends AutoDisposeFutureProvider<Dashboard> {
  /// CU-38. El rango es un parámetro de la familia: cambiarlo dispara la
  /// consulta de ese rango sin perder la anterior si se vuelve a ella.
  ///
  /// Copied from [dashboardAdmin].
  DashboardAdminProvider(
    DateTime desde,
    DateTime hasta,
  ) : this._internal(
          (ref) => dashboardAdmin(
            ref as DashboardAdminRef,
            desde,
            hasta,
          ),
          from: dashboardAdminProvider,
          name: r'dashboardAdminProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dashboardAdminHash,
          dependencies: DashboardAdminFamily._dependencies,
          allTransitiveDependencies:
              DashboardAdminFamily._allTransitiveDependencies,
          desde: desde,
          hasta: hasta,
        );

  DashboardAdminProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.desde,
    required this.hasta,
  }) : super.internal();

  final DateTime desde;
  final DateTime hasta;

  @override
  Override overrideWith(
    FutureOr<Dashboard> Function(DashboardAdminRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DashboardAdminProvider._internal(
        (ref) => create(ref as DashboardAdminRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        desde: desde,
        hasta: hasta,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Dashboard> createElement() {
    return _DashboardAdminProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardAdminProvider &&
        other.desde == desde &&
        other.hasta == hasta;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, desde.hashCode);
    hash = _SystemHash.combine(hash, hasta.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DashboardAdminRef on AutoDisposeFutureProviderRef<Dashboard> {
  /// The parameter `desde` of this provider.
  DateTime get desde;

  /// The parameter `hasta` of this provider.
  DateTime get hasta;
}

class _DashboardAdminProviderElement
    extends AutoDisposeFutureProviderElement<Dashboard> with DashboardAdminRef {
  _DashboardAdminProviderElement(super.provider);

  @override
  DateTime get desde => (origin as DashboardAdminProvider).desde;
  @override
  DateTime get hasta => (origin as DashboardAdminProvider).hasta;
}

String _$parametrosAdminHash() => r'96ec2ab04528a66cad34b50dda8923b261e3ad79';

/// See also [parametrosAdmin].
@ProviderFor(parametrosAdmin)
final parametrosAdminProvider =
    AutoDisposeFutureProvider<List<Parametro>>.internal(
  parametrosAdmin,
  name: r'parametrosAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$parametrosAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ParametrosAdminRef = AutoDisposeFutureProviderRef<List<Parametro>>;
String _$accesosAdminHash() => r'2f5d3341ef82ee44d90c6b1f4880d4c2d14e24cf';

/// See also [accesosAdmin].
@ProviderFor(accesosAdmin)
final accesosAdminProvider =
    AutoDisposeFutureProvider<List<AccesoAdmin>>.internal(
  accesosAdmin,
  name: r'accesosAdminProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accesosAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccesosAdminRef = AutoDisposeFutureProviderRef<List<AccesoAdmin>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
