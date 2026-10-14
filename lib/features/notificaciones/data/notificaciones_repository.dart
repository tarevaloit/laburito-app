import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/notificacion.dart';

part 'notificaciones_repository.g.dart';

/// CU-48 — Ver Notificaciones de Actividad. Tabla de la 0027, avisos de la
/// 0031. Leer, marcar y borrar van por PostgREST: la RLS deja a cada uno solo
/// con lo suyo y el guard de columnas solo deja cambiar `leida_at`.
class NotificacionesRepository {
  const NotificacionesRepository(this._client);

  final SupabaseClient _client;

  /// Cuántos avisos se muestran: el centro es de novedades, no un archivo.
  static const limite = 50;

  /// Las últimas notificaciones, de la más nueva a la más vieja, y cada cambio
  /// en vivo por Realtime: la campana se actualiza sin recargar.
  Stream<List<Notificacion>> observar() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Stream.value(const []);

    return _client
        .from('notificaciones')
        .stream(primaryKey: ['id'])
        .eq('destinatario_id', uid)
        .order('created_at')
        .limit(limite)
        .map((filas) => [for (final f in filas) Notificacion.desdeFila(f)]);
  }

  /// Paso 4 del CU-48: al abrir el centro, todo lo que había queda leído.
  Future<void> marcarLeidas() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client
        .from('notificaciones')
        .update({'leida_at': DateTime.now().toUtc().toIso8601String()})
        .eq('destinatario_id', uid)
        .isFilter('leida_at', null);
  }

  /// Flujo alterno 1.1: «Limpiar todo».
  Future<void> limpiar() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client.from('notificaciones').delete().eq('destinatario_id', uid);
  }
}

@Riverpod(keepAlive: true)
NotificacionesRepository notificacionesRepository(Ref ref) =>
    NotificacionesRepository(ref.watch(supabaseClientProvider));

@riverpod
Stream<List<Notificacion>> notificaciones(Ref ref) =>
    ref.watch(notificacionesRepositoryProvider).observar();

/// El número de la campana.
@riverpod
int notificacionesSinLeer(Ref ref) =>
    ref.watch(notificacionesProvider).valueOrNull
        ?.where((n) => !n.leida)
        .length ??
    0;
