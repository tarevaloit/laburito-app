import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente único de Supabase.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Stream de cambios de autenticación. Alimenta el redirect del router.
final authStateChangesProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseClientProvider).auth.onAuthStateChange,
);

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
final sesionProvider = Provider<Session?>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(supabaseClientProvider).auth.currentSession;
});
