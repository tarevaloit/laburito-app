// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseClientHash() => r'3db2a4c212c7f24cea9810e376225aa1a6cab012';

/// Cliente único de Supabase.
///
/// `keepAlive` en todo este archivo: los providers generados son autoDispose
/// por defecto, y estos tres estaban escritos a mano como `Provider` /
/// `StreamProvider`, que no se descartan. Se conserva la semántica anterior;
/// un cliente que se recree al quedarse sin oyentes tiraría abajo la
/// suscripción de auth.
///
/// Copied from [supabaseClient].
@ProviderFor(supabaseClient)
final supabaseClientProvider = Provider<SupabaseClient>.internal(
  supabaseClient,
  name: r'supabaseClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseClientRef = ProviderRef<SupabaseClient>;
String _$authStateChangesHash() => r'310af7ac668b2f2faabbc6d8fc00b2b768260eed';

/// Stream de cambios de autenticación. Alimenta el redirect del router.
///
/// Copied from [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = StreamProvider<AuthState>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = StreamProviderRef<AuthState>;
String _$sesionHash() => r'2a42ae7afcce76305ed4f1b639ea78aec72340e2';

/// Sesión vigente, o null si no hay usuario autenticado.
///
/// La fuente de verdad es `auth.currentSession`, no el evento del stream: el
/// cliente la actualiza de forma sincrónica, mientras que el evento se entrega
/// un turno más tarde. El stream se observa solo para **recalcular**.
///
/// Antes se devolvía `estado.session`, la sesión del último evento recibido, y
/// eso rompía el CU-08: al validar el PIN la sesión ya existía, pero el router
/// leía todavía el evento anterior —`initialSession`, con sesión nula— y mandaba
/// al login a alguien que acababa de autenticarse.
///
/// Copied from [sesion].
@ProviderFor(sesion)
final sesionProvider = Provider<Session?>.internal(
  sesion,
  name: r'sesionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sesionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SesionRef = ProviderRef<Session?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
