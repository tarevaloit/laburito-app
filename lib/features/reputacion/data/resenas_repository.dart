import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

part 'resenas_repository.g.dart';

/// Una reseña, vista por el Profesional que la recibió o por el
/// administrador que la modera (CU-46).
class Resena {
  const Resena({
    required this.id,
    required this.puntaje,
    required this.autor,
    required this.fecha,
    this.comentario,
    this.profesional,
    this.pedidoTitulo,
    this.reporteMotivo,
    this.reportadaAt,
    this.revisionAutomatica = false,
    this.moderacion,
    this.oculta = false,
  });

  final String id;
  final int puntaje;
  final String autor;
  final DateTime fecha;
  final String? comentario;
  final String? profesional;
  final String? pedidoTitulo;
  final String? reporteMotivo;
  final DateTime? reportadaAt;
  final bool revisionAutomatica;

  /// `eliminada`, `mantenida` o `null` si nadie la moderó todavía.
  final String? moderacion;
  final bool oculta;

  bool get reportada => reportadaAt != null;
  bool get pendienteDeModeracion => moderacion == null;

  /// Si el Profesional todavía puede reportarla desde «Mis reseñas».
  bool get reportable => !reportada && moderacion == null && !oculta;

  factory Resena.desdeFila(Map<String, dynamic> f) => Resena(
        id: f['id'] as String,
        puntaje: (f['puntaje'] as num).toInt(),
        autor: (f['autor_nombre'] as String?) ?? 'Buscador',
        fecha: DateTime.parse(f['created_at'] as String),
        comentario: f['comentario'] as String?,
        profesional: f['profesional'] as String?,
        pedidoTitulo: f['pedido_titulo'] as String?,
        reporteMotivo: f['reporte_motivo'] as String?,
        reportadaAt: f['reportada_at'] == null
            ? null
            : DateTime.parse(f['reportada_at'] as String),
        revisionAutomatica: f['revision_automatica'] as bool? ?? false,
        moderacion: f['moderacion'] as String?,
        oculta: f['oculta'] as bool? ?? false,
      );
}

/// CU-46 — Moderar Reseñas (migración 0041).
class ResenasRepository {
  const ResenasRepository(this._client);

  final SupabaseClient _client;

  /// «Mis reseñas» del Profesional: la política de la 0027 le deja leer las
  /// suyas, también las ocultas, para que vea qué pasó con cada una.
  Future<List<Resena>> mias() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return const [];
    final filas = await _client
        .from('calificaciones')
        .select('id, puntaje, comentario, autor_nombre, created_at, '
            'reporte_motivo, reportada_at, revision_automatica, moderacion, oculta')
        .eq('profesional_id', id)
        .order('created_at', ascending: false);
    return [for (final f in filas as List) Resena.desdeFila(f as Map<String, dynamic>)];
  }

  Future<void> reportar(String id, String motivo) => _client
      .rpc('reportar_resena', params: {'p_calificacion': id, 'p_motivo': motivo});

  Future<List<Resena>> aModerar({bool incluirResueltas = false}) async {
    final filas = await _client.rpc('resenas_a_moderar',
        params: {'p_incluir_resueltas': incluirResueltas}) as List;
    return [for (final f in filas) Resena.desdeFila(f as Map<String, dynamic>)];
  }

  Future<void> moderar(String id, {required bool eliminar}) =>
      _client.rpc('moderar_resena', params: {'p_id': id, 'p_eliminar': eliminar});
}

@Riverpod(keepAlive: true)
ResenasRepository resenasRepository(Ref ref) =>
    ResenasRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Resena>> misResenas(Ref ref) =>
    ref.watch(resenasRepositoryProvider).mias();

@riverpod
Future<List<Resena>> resenasAModerar(Ref ref, bool incluirResueltas) =>
    ref.watch(resenasRepositoryProvider)
        .aModerar(incluirResueltas: incluirResueltas);
