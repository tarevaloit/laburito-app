// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selector_ubicacion_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectorUbicacionControllerHash() =>
    r'77a5d91b9e5b1b43a12ba6a8cfcf840e8bb634dd';

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

abstract class _$SelectorUbicacionController
    extends BuildlessAutoDisposeNotifier<EstadoSelectorUbicacion> {
  late final Ubicacion? inicial;

  EstadoSelectorUbicacion build(
    Ubicacion? inicial,
  );
}

/// CU-16 — Localizar Pedido en Mapa.
///
/// autoDispose: cada apertura del selector empieza de cero. Si conservara el
/// estado, editar la ubicación de un pedido (CU-15) mostraría el punto del
/// pedido anterior hasta que el mapa terminara de encuadrar.
///
/// Copied from [SelectorUbicacionController].
@ProviderFor(SelectorUbicacionController)
const selectorUbicacionControllerProvider = SelectorUbicacionControllerFamily();

/// CU-16 — Localizar Pedido en Mapa.
///
/// autoDispose: cada apertura del selector empieza de cero. Si conservara el
/// estado, editar la ubicación de un pedido (CU-15) mostraría el punto del
/// pedido anterior hasta que el mapa terminara de encuadrar.
///
/// Copied from [SelectorUbicacionController].
class SelectorUbicacionControllerFamily
    extends Family<EstadoSelectorUbicacion> {
  /// CU-16 — Localizar Pedido en Mapa.
  ///
  /// autoDispose: cada apertura del selector empieza de cero. Si conservara el
  /// estado, editar la ubicación de un pedido (CU-15) mostraría el punto del
  /// pedido anterior hasta que el mapa terminara de encuadrar.
  ///
  /// Copied from [SelectorUbicacionController].
  const SelectorUbicacionControllerFamily();

  /// CU-16 — Localizar Pedido en Mapa.
  ///
  /// autoDispose: cada apertura del selector empieza de cero. Si conservara el
  /// estado, editar la ubicación de un pedido (CU-15) mostraría el punto del
  /// pedido anterior hasta que el mapa terminara de encuadrar.
  ///
  /// Copied from [SelectorUbicacionController].
  SelectorUbicacionControllerProvider call(
    Ubicacion? inicial,
  ) {
    return SelectorUbicacionControllerProvider(
      inicial,
    );
  }

  @override
  SelectorUbicacionControllerProvider getProviderOverride(
    covariant SelectorUbicacionControllerProvider provider,
  ) {
    return call(
      provider.inicial,
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
  String? get name => r'selectorUbicacionControllerProvider';
}

/// CU-16 — Localizar Pedido en Mapa.
///
/// autoDispose: cada apertura del selector empieza de cero. Si conservara el
/// estado, editar la ubicación de un pedido (CU-15) mostraría el punto del
/// pedido anterior hasta que el mapa terminara de encuadrar.
///
/// Copied from [SelectorUbicacionController].
class SelectorUbicacionControllerProvider
    extends AutoDisposeNotifierProviderImpl<SelectorUbicacionController,
        EstadoSelectorUbicacion> {
  /// CU-16 — Localizar Pedido en Mapa.
  ///
  /// autoDispose: cada apertura del selector empieza de cero. Si conservara el
  /// estado, editar la ubicación de un pedido (CU-15) mostraría el punto del
  /// pedido anterior hasta que el mapa terminara de encuadrar.
  ///
  /// Copied from [SelectorUbicacionController].
  SelectorUbicacionControllerProvider(
    Ubicacion? inicial,
  ) : this._internal(
          () => SelectorUbicacionController()..inicial = inicial,
          from: selectorUbicacionControllerProvider,
          name: r'selectorUbicacionControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectorUbicacionControllerHash,
          dependencies: SelectorUbicacionControllerFamily._dependencies,
          allTransitiveDependencies:
              SelectorUbicacionControllerFamily._allTransitiveDependencies,
          inicial: inicial,
        );

  SelectorUbicacionControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.inicial,
  }) : super.internal();

  final Ubicacion? inicial;

  @override
  EstadoSelectorUbicacion runNotifierBuild(
    covariant SelectorUbicacionController notifier,
  ) {
    return notifier.build(
      inicial,
    );
  }

  @override
  Override overrideWith(SelectorUbicacionController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectorUbicacionControllerProvider._internal(
        () => create()..inicial = inicial,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        inicial: inicial,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SelectorUbicacionController,
      EstadoSelectorUbicacion> createElement() {
    return _SelectorUbicacionControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectorUbicacionControllerProvider &&
        other.inicial == inicial;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inicial.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SelectorUbicacionControllerRef
    on AutoDisposeNotifierProviderRef<EstadoSelectorUbicacion> {
  /// The parameter `inicial` of this provider.
  Ubicacion? get inicial;
}

class _SelectorUbicacionControllerProviderElement
    extends AutoDisposeNotifierProviderElement<SelectorUbicacionController,
        EstadoSelectorUbicacion> with SelectorUbicacionControllerRef {
  _SelectorUbicacionControllerProviderElement(super.provider);

  @override
  Ubicacion? get inicial =>
      (origin as SelectorUbicacionControllerProvider).inicial;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
