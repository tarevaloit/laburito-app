import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import 'servicio_push.dart';

part 'dispositivos_repository.g.dart';

/// CU-21 — Los teléfonos a los que hay que mandarles la alerta.
///
/// Tabla y RLS: migración 0012. Las dos RPC: migración 0017.
class DispositivosRepository {
  const DispositivosRepository(this._client, this._push);

  final SupabaseClient _client;
  final ServicioPush _push;

  /// Registra el token de esta instalación a nombre del Profesional
  /// autenticado. Devuelve el token registrado, o `null` si no hubo ninguno
  /// (sin permiso, o sin push configurado todavía).
  ///
  /// Va por RPC y no por un upsert de PostgREST porque el token es **de la
  /// instalación, no del usuario**: si en este teléfono había iniciado sesión
  /// otro Profesional, hay que sacárselo, y su fila es invisible bajo las RLS
  /// del nuevo dueño. Ese traspaso solo lo puede hacer la función SECURITY
  /// DEFINER de la 0017.
  Future<String?> registrar() async {
    final token = await _push.token();
    if (token == null) return null;

    await _client.rpc('registrar_dispositivo', params: {
      'p_token': token,
      'p_plataforma': plataformaActual(),
    });

    return token;
  }

  /// Baja del token al cerrar sesión (CU-10 / CU-50).
  ///
  /// Si no se llamara, el teléfono seguiría recibiendo los pedidos de una
  /// cuenta que ya no está abierta ahí.
  ///
  /// Nunca hace fallar el cierre de sesión: quedarse adentro de la app porque
  /// no se pudo borrar una fila es peor que un token de más, que además se
  /// limpia solo —la Edge Function da de baja los que FCM reporta como
  /// desconocidos, y el próximo inicio de sesión lo traspasa—.
  ///
  /// Pedir el token también va adentro del `try`, y con un tope de tiempo: en
  /// la web, `getToken()` abría el permiso del navegador y fallaba, y como
  /// estaba afuera, la excepción cortaba el cierre de sesión (01/10).
  Future<void> darDeBaja() async {
    try {
      final token = await _push.token().timeout(_tope);
      if (token == null) return;

      await _client
          .rpc('dar_de_baja_dispositivo', params: {'p_token': token})
          .timeout(_tope);
    } on Object catch (error) {
      if (kDebugMode) debugPrint('No se pudo dar de baja el dispositivo: $error');
    }
  }

  static const _tope = Duration(seconds: 5);
}

@Riverpod(keepAlive: true)
DispositivosRepository dispositivosRepository(Ref ref) =>
    DispositivosRepository(
      ref.watch(supabaseClientProvider),
      ref.watch(servicioPushProvider),
    );
