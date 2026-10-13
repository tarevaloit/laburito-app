import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../billetera/data/billetera_repository.dart' show ErrorDeFuncion;

part 'enlace_gestion_repository.g.dart';

/// CU-18 — Solicitar Reenvío de Enlace de Gestión. Edge Function
/// `reenviar_enlace_gestion`.
class EnlaceGestionRepository {
  const EnlaceGestionRepository(this._client);

  final SupabaseClient _client;

  /// Devuelve el mensaje que se muestra, que es siempre el mismo exista o no
  /// un pedido activo (flujo alterno 1.2). Solo un correo mal escrito da un
  /// error.
  Future<String> reenviar(String email) async {
    try {
      final respuesta = await _client.functions.invoke(
        'reenviar_enlace_gestion',
        body: {'email': email.trim()},
      );
      return (respuesta.data as Map)['mensaje'] as String;
    } on FunctionException catch (error) {
      throw ErrorDeFuncion.desde(error);
    }
  }
}

@Riverpod(keepAlive: true)
EnlaceGestionRepository enlaceGestionRepository(Ref ref) =>
    EnlaceGestionRepository(ref.watch(supabaseClientProvider));
