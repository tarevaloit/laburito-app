import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

part 'suspension_repository.g.dart';

/// Una apelación del CU-49, como la ve quien la hizo.
class MiApelacion {
  const MiApelacion({
    required this.numero,
    required this.estado,
    this.respuesta,
  });

  final int numero;

  /// `pendiente`, `aceptada` o `rechazada`.
  final String estado;
  final String? respuesta;

  bool get pendiente => estado == 'pendiente';
}

/// La suspensión vigente de la cuenta propia, de `revisar_mi_suspension`
/// (0039, ampliada en la 0043).
class MiSuspension {
  const MiSuspension({
    required this.motivo,
    required this.permanente,
    required this.apelable,
    this.hasta,
    this.apelacion,
  });

  final String motivo;
  final bool permanente;
  final bool apelable;
  final DateTime? hasta;
  final MiApelacion? apelacion;

  /// El botón «Apelar sanción» se ofrece si la sanción lo admite y no hay
  /// una apelación en revisión. Después de un rechazo se puede volver a
  /// apelar con un descargo nuevo.
  bool get puedeApelar => apelable && !(apelacion?.pendiente ?? false);

  static MiSuspension? desdeJson(Map<String, dynamic> j) {
    final s = j['sancion'] as Map?;
    if (j['estado'] != 'suspendido' || s == null) return null;
    final a = j['apelacion'] as Map?;
    return MiSuspension(
      motivo: s['motivo'] as String? ?? '',
      permanente: s['permanente'] as bool? ?? false,
      apelable: s['apelable'] as bool? ?? true,
      hasta: s['hasta'] == null ? null : DateTime.parse(s['hasta'] as String),
      apelacion: a == null
          ? null
          : MiApelacion(
              numero: (a['numero'] as num).toInt(),
              estado: a['estado'] as String,
              respuesta: a['respuesta'] as String?,
            ),
    );
  }
}

/// CU-36 (vencimiento de la sanción) y CU-49 — Recuperar Cuenta Bloqueada.
class SuspensionRepository {
  const SuspensionRepository(this._client);

  final SupabaseClient _client;

  /// `null` si la cuenta no está suspendida, también cuando la sanción era
  /// temporal y venció: la base la levanta en esta misma llamada.
  Future<MiSuspension?> revisar() async {
    final json = await _client.rpc('revisar_mi_suspension');
    return MiSuspension.desdeJson(Map<String, dynamic>.from(json as Map));
  }

  /// Devuelve el número de trámite (paso 6).
  Future<int> apelar(String descargo) async =>
      (await _client.rpc('apelar_sancion', params: {'p_descargo': descargo}) as num)
          .toInt();
}

@Riverpod(keepAlive: true)
SuspensionRepository suspensionRepository(Ref ref) =>
    SuspensionRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<MiSuspension?> miSuspension(Ref ref) =>
    ref.watch(suspensionRepositoryProvider).revisar();
