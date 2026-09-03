import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// Cliente único de Supabase.
///
/// `keepAlive` en todo este archivo: los providers generados son autoDispose
/// por defecto, y estos tres estaban escritos a mano como `Provider` /
/// `StreamProvider`, que no se descartan. Se conserva la semántica anterior;
/// un cliente que se recree al quedarse sin oyentes tiraría abajo la
/// suscripción de auth.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

/// Stream de cambios de autenticación. Alimenta el redirect del router.
@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(Ref ref) =>
    ref.watch(supabaseClientProvider).auth.onAuthStateChange;

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
@Riverpod(keepAlive: true)
Session? sesion(Ref ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseClientProvider).auth.currentSession;
}
