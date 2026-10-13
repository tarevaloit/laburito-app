import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../billetera/data/billetera_repository.dart' show ErrorDeFuncion;
import '../domain/perfil_publico.dart';

part 'reputacion_repository.g.dart';

/// La cuenta está suspendida: el botón de compartir se desactiva (flujo
/// alterno 1.2 del CU-26).
class CuentaSuspendidaException implements Exception {
  const CuentaSuspendidaException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// CU-26, CU-27 y CU-28: enlaces públicos y reputación del Profesional.
class ReputacionRepository {
  const ReputacionRepository(this._client);

  final SupabaseClient _client;

  /// CU-26. URL pública del Profesional que llama (`WEB_URL/p/<slug>`). El
  /// slug lo crea el servidor la primera vez y después es siempre el mismo.
  Future<Uri> enlacePerfil() async {
    try {
      final slug = await _client.rpc('obtener_enlace_perfil') as String;
      return Uri.parse('${Env.webUrl}/p/$slug');
    } on PostgrestException catch (error) {
      if (error.hint == 'cuenta_suspendida') {
        throw CuentaSuspendidaException(error.message);
      }
      rethrow;
    }
  }

  /// CU-27. `null` si el enlace no lleva a ningún perfil disponible: no existe,
  /// la cuenta está suspendida o dada de baja (el 404 del flujo alterno).
  Future<PerfilPublico?> perfilPublico(String slug) async {
    try {
      final respuesta = await _client.functions.invoke(
        'perfil_publico',
        body: {'slug': slug},
      );
      return PerfilPublico.desdeJson(respuesta.data as Map<String, dynamic>);
    } on FunctionException catch (error) {
      if (error.status == 404) return null;
      throw ErrorDeFuncion.desde(error);
    }
  }
}

@Riverpod(keepAlive: true)
ReputacionRepository reputacionRepository(Ref ref) =>
    ReputacionRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<PerfilPublico?> perfilPublico(Ref ref, String slug) =>
    ref.watch(reputacionRepositoryProvider).perfilPublico(slug);
