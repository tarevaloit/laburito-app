import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/horario_atencion.dart';

part 'horarios_repository.g.dart';

/// CU-44 — Horarios de atención y disponibilidad.
///
/// Tabla y restricción de exclusión: migración 0012. La RPC que reemplaza la
/// semana entera: migración 0019.
class HorariosRepository {
  const HorariosRepository(this._client);

  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No hay sesión activa');
    return id;
  }

  Future<List<HorarioAtencion>> cargar() async {
    final filas = await _client
        .from('profesional_horarios')
        .select('dia_semana, hora_desde, hora_hasta')
        .eq('profesional_id', _uid)
        .order('dia_semana')
        .order('hora_desde');

    return [
      for (final fila in filas as List)
        HorarioAtencion.desdeFila(fila as Map<String, dynamic>),
    ];
  }

  /// Guarda la semana entera. Va por RPC y no como un borrado más varios
  /// insert desde el cliente: si la segunda escritura fallara, el Profesional
  /// se quedaría sin ningún horario, y un horario vacío no se ve raro en la
  /// pantalla —parece que nunca cargó nada— así que nadie se enteraría.
  Future<List<HorarioAtencion>> reemplazar(List<HorarioAtencion> franjas) async {
    final filas = await _client.rpc('reemplazar_horarios', params: {
      'p_franjas': [for (final f in franjas) f.aJson()],
    });

    return [
      for (final fila in filas as List)
        HorarioAtencion.desdeFila(fila as Map<String, dynamic>),
    ];
  }

  /// El interruptor del CU-44. Es un PATCH común: la política «profesional
  /// propio: actualización» (0001/0002) ya limita la fila a la propia.
  ///
  /// Desde la migración 0019, estar no disponible saca al Profesional del
  /// emparejamiento del CU-21: deja de recibir alertas hasta que lo vuelva a
  /// encender.
  Future<bool> cambiarDisponibilidad(bool disponible) async {
    final fila = await _client
        .from('profesionales')
        .update({'disponible': disponible})
        .eq('perfil_id', _uid)
        .select('disponible')
        .single();

    return fila['disponible'] as bool;
  }

  Future<bool> disponible() async {
    final fila = await _client
        .from('profesionales')
        .select('disponible')
        .eq('perfil_id', _uid)
        .maybeSingle();

    return (fila?['disponible'] as bool?) ?? false;
  }
}

@Riverpod(keepAlive: true)
HorariosRepository horariosRepository(Ref ref) =>
    HorariosRepository(ref.watch(supabaseClientProvider));
