// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacto_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactoRepositoryHash() =>
    r'0abb4e103173b359b5f3222ab5721bdeabadf2d6';

/// See also [contactoRepository].
@ProviderFor(contactoRepository)
final contactoRepositoryProvider = Provider<ContactoRepository>.internal(
  contactoRepository,
  name: r'contactoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactoRepositoryRef = ProviderRef<ContactoRepository>;
String _$contactoPedidoHash() => r'fe7ec0f537b514d8cbe744966718810e911a0fb6';

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

/// See also [contactoPedido].
@ProviderFor(contactoPedido)
const contactoPedidoProvider = ContactoPedidoFamily();

/// See also [contactoPedido].
class ContactoPedidoFamily extends Family<AsyncValue<ContactoBuscador?>> {
  /// See also [contactoPedido].
  const ContactoPedidoFamily();

  /// See also [contactoPedido].
  ContactoPedidoProvider call(
    String pedidoId,
  ) {
    return ContactoPedidoProvider(
      pedidoId,
    );
  }

  @override
  ContactoPedidoProvider getProviderOverride(
    covariant ContactoPedidoProvider provider,
  ) {
    return call(
      provider.pedidoId,
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
  String? get name => r'contactoPedidoProvider';
}

/// See also [contactoPedido].
class ContactoPedidoProvider
    extends AutoDisposeFutureProvider<ContactoBuscador?> {
  /// See also [contactoPedido].
  ContactoPedidoProvider(
    String pedidoId,
  ) : this._internal(
          (ref) => contactoPedido(
            ref as ContactoPedidoRef,
            pedidoId,
          ),
          from: contactoPedidoProvider,
          name: r'contactoPedidoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contactoPedidoHash,
          dependencies: ContactoPedidoFamily._dependencies,
          allTransitiveDependencies:
              ContactoPedidoFamily._allTransitiveDependencies,
          pedidoId: pedidoId,
        );

  ContactoPedidoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pedidoId,
  }) : super.internal();

  final String pedidoId;

  @override
  Override overrideWith(
    FutureOr<ContactoBuscador?> Function(ContactoPedidoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactoPedidoProvider._internal(
        (ref) => create(ref as ContactoPedidoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pedidoId: pedidoId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ContactoBuscador?> createElement() {
    return _ContactoPedidoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactoPedidoProvider && other.pedidoId == pedidoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pedidoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactoPedidoRef on AutoDisposeFutureProviderRef<ContactoBuscador?> {
  /// The parameter `pedidoId` of this provider.
  String get pedidoId;
}

class _ContactoPedidoProviderElement
    extends AutoDisposeFutureProviderElement<ContactoBuscador?>
    with ContactoPedidoRef {
  _ContactoPedidoProviderElement(super.provider);

  @override
  String get pedidoId => (origin as ContactoPedidoProvider).pedidoId;
}

String _$interesadosPedidoHash() => r'26c7a4dbe30c0963936973fd84054bbfad009f7b';

/// See also [interesadosPedido].
@ProviderFor(interesadosPedido)
const interesadosPedidoProvider = InteresadosPedidoFamily();

/// See also [interesadosPedido].
class InteresadosPedidoFamily extends Family<AsyncValue<int>> {
  /// See also [interesadosPedido].
  const InteresadosPedidoFamily();

  /// See also [interesadosPedido].
  InteresadosPedidoProvider call(
    String pedidoId,
  ) {
    return InteresadosPedidoProvider(
      pedidoId,
    );
  }

  @override
  InteresadosPedidoProvider getProviderOverride(
    covariant InteresadosPedidoProvider provider,
  ) {
    return call(
      provider.pedidoId,
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
  String? get name => r'interesadosPedidoProvider';
}

/// See also [interesadosPedido].
class InteresadosPedidoProvider extends AutoDisposeFutureProvider<int> {
  /// See also [interesadosPedido].
  InteresadosPedidoProvider(
    String pedidoId,
  ) : this._internal(
          (ref) => interesadosPedido(
            ref as InteresadosPedidoRef,
            pedidoId,
          ),
          from: interesadosPedidoProvider,
          name: r'interesadosPedidoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$interesadosPedidoHash,
          dependencies: InteresadosPedidoFamily._dependencies,
          allTransitiveDependencies:
              InteresadosPedidoFamily._allTransitiveDependencies,
          pedidoId: pedidoId,
        );

  InteresadosPedidoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pedidoId,
  }) : super.internal();

  final String pedidoId;

  @override
  Override overrideWith(
    FutureOr<int> Function(InteresadosPedidoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InteresadosPedidoProvider._internal(
        (ref) => create(ref as InteresadosPedidoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pedidoId: pedidoId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _InteresadosPedidoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InteresadosPedidoProvider && other.pedidoId == pedidoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pedidoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InteresadosPedidoRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `pedidoId` of this provider.
  String get pedidoId;
}

class _InteresadosPedidoProviderElement
    extends AutoDisposeFutureProviderElement<int> with InteresadosPedidoRef {
  _InteresadosPedidoProviderElement(super.provider);

  @override
  String get pedidoId => (origin as InteresadosPedidoProvider).pedidoId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
