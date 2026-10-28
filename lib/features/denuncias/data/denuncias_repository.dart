import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/denuncia.dart';

part 'denuncias_repository.g.dart';

/// CU-41 — Reportar Usuario. Funciones de la migración 0033.
class DenunciasRepository {
  const DenunciasRepository(this._client);

  final SupabaseClient _client;

  /// Denuncia al Profesional de un perfil público ([slug]) o al Buscador de
  /// un pedido ([pedidoId]). Los rechazos —motivo faltante, denuncia ya
  /// abierta— llegan como P0001 con el mensaje para el usuario.
  Future<void> reportar({
    required MotivoDenuncia motivo,
    required String descripcion,
    String? slug,
    String? pedidoId,
  }) async {
    assert(slug != null || pedidoId != null);
    await _client.rpc('reportar_usuario', params: {
      'p_motivo': motivo.valor,
      'p_descripcion': descripcion,
      'p_slug': slug,
      'p_pedido': pedidoId,
    });
  }

  /// Para el panel: las abiertas primero, por gravedad y fecha (CU-39).
  Future<List<DenunciaAdmin>> listarAdmin() async {
    final filas = await _client.rpc('denuncias_admin') as List;
    return [
      for (final f in filas) DenunciaAdmin.desdeFila(f as Map<String, dynamic>),
    ];
  }

  /// CU-39, paso 4: la trazabilidad del pedido asociado (0040).
  Future<Map<String, dynamic>> trazabilidad(String id) async =>
      Map<String, dynamic>.from(await _client
          .rpc('detalle_denuncia_admin', params: {'p_id': id}) as Map);

  /// CU-39, pasos 5 y 6. Con [ResolucionDenuncia.suspender], la sanción del
  /// CU-36 se aplica en la misma transacción.
  Future<void> resolver(String id, ResolucionDenuncia r) =>
      _client.rpc('resolver_denuncia', params: {
        'p_id': id,
        'p_desestimar': r.desestimar,
        'p_resolucion': r.texto,
        'p_suspender': r.suspender,
        'p_dias': r.dias,
        'p_apelable': r.apelable,
      });
}

@Riverpod(keepAlive: true)
DenunciasRepository denunciasRepository(Ref ref) =>
    DenunciasRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<DenunciaAdmin>> denunciasAdmin(Ref ref) =>
    ref.watch(denunciasRepositoryProvider).listarAdmin();

@riverpod
Future<Map<String, dynamic>> trazabilidadDenuncia(Ref ref, String id) =>
    ref.watch(denunciasRepositoryProvider).trazabilidad(id);
