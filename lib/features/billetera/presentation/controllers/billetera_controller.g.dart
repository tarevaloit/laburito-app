// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billetera_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$billeteraHash() => r'c1fd0f9a41dc420bfd6e3a925cce253414b6ec8d';

/// CU-30 — Consultar Saldo de Tokens.
///
/// keepAlive a propósito: es lo que hace posible el flujo alterno de la ERS.
/// Si una recarga falla, la billetera no se vacía: queda el último saldo
/// leído, marcado como «sin conexión». Y el saldo se consulta desde varias
/// pantallas —la billetera y el detalle del pedido del CU-25— sin pedirlo dos
/// veces.
///
/// Mira la sesión, como `perfilCompleto`: un provider que sobrevive a la
/// pantalla no puede sobrevivirle al usuario. Sin esto, cerrar sesión y entrar
/// con otra cuenta mostraría el saldo de la anterior.
///
/// Copied from [Billetera].
@ProviderFor(Billetera)
final billeteraProvider =
    AsyncNotifierProvider<Billetera, EstadoBilletera>.internal(
  Billetera.new,
  name: r'billeteraProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$billeteraHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Billetera = AsyncNotifier<EstadoBilletera>;
String _$historialPagosHash() => r'046e2429df0fc4327e7c6324d2aade495fb5fe51';

/// CU-33 — Ver Historial de Pagos. Aprobados, pendientes y rechazados, del más
/// reciente al más viejo, de a veinte, con el mismo scroll infinito del CU-17.
///
/// Copied from [HistorialPagos].
@ProviderFor(HistorialPagos)
final historialPagosProvider = AutoDisposeAsyncNotifierProvider<HistorialPagos,
    EstadoHistorialPagos>.internal(
  HistorialPagos.new,
  name: r'historialPagosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historialPagosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistorialPagos = AutoDisposeAsyncNotifier<EstadoHistorialPagos>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
