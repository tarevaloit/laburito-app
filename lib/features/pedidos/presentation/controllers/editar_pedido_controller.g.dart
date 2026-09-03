// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editar_pedido_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editarPedidoHash() => r'e99495ca9a94261798e75c1f5b9a1f15b2938f50';

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

abstract class _$EditarPedido
    extends BuildlessAutoDisposeAsyncNotifier<EstadoEditarPedido> {
  late final String pedidoId;

  FutureOr<EstadoEditarPedido> build(
    String pedidoId,
  );
}

/// CU-15 — Editar Pedido.
///
/// Solo tiene sentido sobre un pedido `publicado` o `pausado`: la RPC
/// `actualizar_ubicacion_pedido` rechaza el resto, y editar un pedido cerrado
/// no tendría a quién servirle. La pantalla lo comprueba antes de dibujar el
/// formulario.
///
/// **La vigencia no se edita acá.** Estirar `fecha_vencimiento` con un PATCH
/// sería una renovación sin límite, y el CU-51 permite tres: la fecha se
/// mueve solo por `renovar_pedido`, que las cuenta.
///
/// Copied from [EditarPedido].
@ProviderFor(EditarPedido)
const editarPedidoProvider = EditarPedidoFamily();

/// CU-15 — Editar Pedido.
///
/// Solo tiene sentido sobre un pedido `publicado` o `pausado`: la RPC
/// `actualizar_ubicacion_pedido` rechaza el resto, y editar un pedido cerrado
/// no tendría a quién servirle. La pantalla lo comprueba antes de dibujar el
/// formulario.
///
/// **La vigencia no se edita acá.** Estirar `fecha_vencimiento` con un PATCH
/// sería una renovación sin límite, y el CU-51 permite tres: la fecha se
/// mueve solo por `renovar_pedido`, que las cuenta.
///
/// Copied from [EditarPedido].
class EditarPedidoFamily extends Family<AsyncValue<EstadoEditarPedido>> {
  /// CU-15 — Editar Pedido.
  ///
  /// Solo tiene sentido sobre un pedido `publicado` o `pausado`: la RPC
  /// `actualizar_ubicacion_pedido` rechaza el resto, y editar un pedido cerrado
  /// no tendría a quién servirle. La pantalla lo comprueba antes de dibujar el
  /// formulario.
  ///
  /// **La vigencia no se edita acá.** Estirar `fecha_vencimiento` con un PATCH
  /// sería una renovación sin límite, y el CU-51 permite tres: la fecha se
  /// mueve solo por `renovar_pedido`, que las cuenta.
  ///
  /// Copied from [EditarPedido].
  const EditarPedidoFamily();

  /// CU-15 — Editar Pedido.
  ///
  /// Solo tiene sentido sobre un pedido `publicado` o `pausado`: la RPC
  /// `actualizar_ubicacion_pedido` rechaza el resto, y editar un pedido cerrado
  /// no tendría a quién servirle. La pantalla lo comprueba antes de dibujar el
  /// formulario.
  ///
  /// **La vigencia no se edita acá.** Estirar `fecha_vencimiento` con un PATCH
  /// sería una renovación sin límite, y el CU-51 permite tres: la fecha se
  /// mueve solo por `renovar_pedido`, que las cuenta.
  ///
  /// Copied from [EditarPedido].
  EditarPedidoProvider call(
    String pedidoId,
  ) {
    return EditarPedidoProvider(
      pedidoId,
    );
  }

  @override
  EditarPedidoProvider getProviderOverride(
    covariant EditarPedidoProvider provider,
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
  String? get name => r'editarPedidoProvider';
}

/// CU-15 — Editar Pedido.
///
/// Solo tiene sentido sobre un pedido `publicado` o `pausado`: la RPC
/// `actualizar_ubicacion_pedido` rechaza el resto, y editar un pedido cerrado
/// no tendría a quién servirle. La pantalla lo comprueba antes de dibujar el
/// formulario.
///
/// **La vigencia no se edita acá.** Estirar `fecha_vencimiento` con un PATCH
/// sería una renovación sin límite, y el CU-51 permite tres: la fecha se
/// mueve solo por `renovar_pedido`, que las cuenta.
///
/// Copied from [EditarPedido].
class EditarPedidoProvider extends AutoDisposeAsyncNotifierProviderImpl<
    EditarPedido, EstadoEditarPedido> {
  /// CU-15 — Editar Pedido.
  ///
  /// Solo tiene sentido sobre un pedido `publicado` o `pausado`: la RPC
  /// `actualizar_ubicacion_pedido` rechaza el resto, y editar un pedido cerrado
  /// no tendría a quién servirle. La pantalla lo comprueba antes de dibujar el
  /// formulario.
  ///
  /// **La vigencia no se edita acá.** Estirar `fecha_vencimiento` con un PATCH
  /// sería una renovación sin límite, y el CU-51 permite tres: la fecha se
  /// mueve solo por `renovar_pedido`, que las cuenta.
  ///
  /// Copied from [EditarPedido].
  EditarPedidoProvider(
    String pedidoId,
  ) : this._internal(
          () => EditarPedido()..pedidoId = pedidoId,
          from: editarPedidoProvider,
          name: r'editarPedidoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$editarPedidoHash,
          dependencies: EditarPedidoFamily._dependencies,
          allTransitiveDependencies:
              EditarPedidoFamily._allTransitiveDependencies,
          pedidoId: pedidoId,
        );

  EditarPedidoProvider._internal(
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
  FutureOr<EstadoEditarPedido> runNotifierBuild(
    covariant EditarPedido notifier,
  ) {
    return notifier.build(
      pedidoId,
    );
  }

  @override
  Override overrideWith(EditarPedido Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditarPedidoProvider._internal(
        () => create()..pedidoId = pedidoId,
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
  AutoDisposeAsyncNotifierProviderElement<EditarPedido, EstadoEditarPedido>
      createElement() {
    return _EditarPedidoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditarPedidoProvider && other.pedidoId == pedidoId;
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
mixin EditarPedidoRef
    on AutoDisposeAsyncNotifierProviderRef<EstadoEditarPedido> {
  /// The parameter `pedidoId` of this provider.
  String get pedidoId;
}

class _EditarPedidoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<EditarPedido,
        EstadoEditarPedido> with EditarPedidoRef {
  _EditarPedidoProviderElement(super.provider);

  @override
  String get pedidoId => (origin as EditarPedidoProvider).pedidoId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
