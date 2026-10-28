import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

part 'documentos_repository.g.dart';

/// Documentos exigidos al Profesional (CU-09).
enum TipoDocumento {
  dniFrente('dni_frente', 'Frente del DNI'),
  dniDorso('dni_dorso', 'Dorso del DNI'),
  selfie('selfie', 'Selfie sosteniendo el DNI');

  const TipoDocumento(this.clave, this.etiqueta);

  final String clave;
  final String etiqueta;
}

/// CU-09 — Validar Documentación: carga del Profesional.
/// El bucket `documentos` es privado; se accede por URL firmada.
class DocumentosRepository {
  const DocumentosRepository(this._client);

  final SupabaseClient _client;

  static const int limiteBytes = 5 * 1024 * 1024;

  Future<Map<String, String>> cargados() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return {};

    final filas = await _client
        .from('documentos_verificacion')
        .select('tipo, estado')
        .eq('profesional_id', id);

    return {
      for (final f in filas as List) f['tipo'] as String: f['estado'] as String,
    };
  }

  Future<void> subir({
    required TipoDocumento tipo,
    required Uint8List bytes,
  }) async {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No hay sesión activa');

    if (bytes.lengthInBytes > limiteBytes) {
      throw Exception('El archivo supera los 5 MB permitidos.');
    }

    final ruta = '$id/${tipo.clave}.jpg';

    await _client.storage.from('documentos').uploadBinary(
          ruta,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    await _client.from('documentos_verificacion').upsert(
      {
        'profesional_id': id,
        'tipo': tipo.clave,
        'storage_path': ruta,
        'estado': 'en_revision',
        'observacion': null,
      },
      onConflict: 'profesional_id,tipo',
    );
  }

  /// Con los tres documentos cargados, el Profesional pasa a «En Revisión».
  Future<bool> marcarEnRevisionSiEstaCompleto() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return false;

    final actuales = await cargados();
    final completo =
        TipoDocumento.values.every((t) => actuales.containsKey(t.clave));

    if (completo) {
      await _client
          .from('profesionales')
          .update({'estado_verificacion': 'en_revision'})
          .eq('perfil_id', id);
    }

    return completo;
  }

  /// CU-35: el motivo del último rechazo, para mostrárselo al Profesional
  /// cuando vuelve a cargar. Las filas de los documentos ya no existen: lo que
  /// queda es la decisión asentada en `verificaciones_resueltas` (0037).
  Future<String?> motivoUltimoRechazo() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return null;

    final fila = await _client
        .from('verificaciones_resueltas')
        .select('aprobada, motivo')
        .eq('profesional_id', id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return fila == null || fila['aprobada'] == true
        ? null
        : fila['motivo'] as String?;
  }

  Future<String?> urlFirmada(TipoDocumento tipo) async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return null;

    try {
      return await _client.storage
          .from('documentos')
          .createSignedUrl('$id/${tipo.clave}.jpg', 600);
    } catch (_) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
DocumentosRepository documentosRepository(Ref ref) =>
    DocumentosRepository(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
Future<Map<String, String>> documentosCargados(Ref ref) {
  ref.watch(sesionProvider);
  return ref.watch(documentosRepositoryProvider).cargados();
}

@riverpod
Future<String?> motivoRechazoVerificacion(Ref ref) {
  ref.watch(sesionProvider);
  return ref.watch(documentosRepositoryProvider).motivoUltimoRechazo();
}
