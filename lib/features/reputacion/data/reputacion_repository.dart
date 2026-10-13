import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../billetera/data/billetera_repository.dart' show ErrorDeFuncion;
import '../domain/calificacion.dart';
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

/// El enlace de calificación ya se usó (flujo alterno 1.1 del CU-28): la Web
/// bloquea el formulario en vez de mostrar solo el error.
class EnlaceUsadoException implements Exception {
  const EnlaceUsadoException(this.message);

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

  /// CU-28. Los contactos desbloqueados del Profesional, del más nuevo al más
  /// viejo, con su calificación si ya la tienen.
  Future<List<MiContacto>> misContactos() async {
    final filas = await _client.rpc('mis_contactos') as List;
    return [
      for (final f in filas) MiContacto.desdeFila(f as Map<String, dynamic>),
    ];
  }

  /// CU-28. URL de un solo uso (`WEB_URL/calificar/<token>`) para el contacto
  /// de ese pedido. Pedir otra anula la anterior sin usar.
  Future<Uri> enlaceCalificacion(String pedidoId) async {
    final token = await _client.rpc('generar_enlace_calificacion', params: {
      'p_pedido': pedidoId,
    }) as String;
    return Uri.parse('${Env.webUrl}/calificar/$token');
  }

  /// CU-28. A quién califica el enlace y si sigue disponible. Sin sesión.
  Future<EnlaceCalificacion> infoCalificacion(String token) async {
    final json = await _client.rpc('enlace_calificacion_info', params: {
      'p_token': token,
    });
    return EnlaceCalificacion.desdeJson(json as Map<String, dynamic>);
  }

  /// CU-28. Registra la calificación. Con el enlace ya usado tira
  /// [EnlaceUsadoException]; el resto de los rechazos llega como P0001.
  Future<void> calificar(
    String token, {
    required int puntaje,
    String? comentario,
  }) async {
    try {
      await _client.rpc('registrar_calificacion', params: {
        'p_token': token,
        'p_puntaje': puntaje,
        'p_comentario': comentario,
      });
    } on PostgrestException catch (error) {
      if (error.hint == 'enlace_usado') {
        throw EnlaceUsadoException(error.message);
      }
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
ReputacionRepository reputacionRepository(Ref ref) =>
    ReputacionRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<PerfilPublico?> perfilPublico(Ref ref, String slug) =>
    ref.watch(reputacionRepositoryProvider).perfilPublico(slug);

@riverpod
Future<List<MiContacto>> misContactos(Ref ref) =>
    ref.watch(reputacionRepositoryProvider).misContactos();

@riverpod
Future<EnlaceCalificacion> enlaceCalificacion(Ref ref, String token) =>
    ref.watch(reputacionRepositoryProvider).infoCalificacion(token);
