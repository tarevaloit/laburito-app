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
final sesionProvider = Provider<Session?>((ref) {
  final estado = ref.watch(authStateChangesProvider);
  return estado.when(
    data: (valor) => valor.session,
    loading: () => ref.watch(supabaseClientProvider).auth.currentSession,
    error: (_, __) => null,
  );
});
