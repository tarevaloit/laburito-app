import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

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

final documentosRepositoryProvider = Provider<DocumentosRepository>(
  (ref) => DocumentosRepository(ref.watch(supabaseClientProvider)),
);

final documentosCargadosProvider = FutureProvider<Map<String, String>>((ref) {
  ref.watch(sesionProvider);
  return ref.watch(documentosRepositoryProvider).cargados();
});
