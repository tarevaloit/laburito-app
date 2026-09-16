import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../../core/utils/identificadores.dart';
import '../domain/foto_portafolio.dart';

part 'portafolio_repository.g.dart';

/// CU-06 — Portafolio del Profesional.
///
/// Tabla, tope de 10 y bucket privado: migración 0012.
class PortafolioRepository {
  const PortafolioRepository(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'portafolios';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No hay sesión activa');
    return id;
  }

  Future<List<FotoPortafolio>> listar([String? profesionalId]) async {
    final filas = await _client
        .from('profesional_portafolio')
        .select('id, storage_path, orden, descripcion')
        .eq('profesional_id', profesionalId ?? _uid)
        .order('orden');

    return [
      for (final fila in filas as List)
        FotoPortafolio.desdeFila(fila as Map<String, dynamic>),
    ];
  }

  /// Sube la imagen y después inserta la fila.
  ///
  /// Ese orden importa y es el mismo del CU-13: si se insertara primero, una
  /// subida fallida dejaría una fila que apunta a un archivo que no existe. Al
  /// revés, si falla el insert, se borra el archivo recién subido —un objeto
  /// en Storage que ninguna fila referencia es invisible y eterno—.
  ///
  /// El tope de 10 lo aplica el trigger de la 0012, que bloquea la fila del
  /// Profesional antes de contar: dos subidas simultáneas no pueden pasar de
  /// 10 entre las dos.
  Future<FotoPortafolio> subir({
    required Uint8List bytes,
    required int orden,
    String? descripcion,
  }) async {
    final ruta = '$_uid/${Identificadores.nombreDeArchivo('jpg')}';

    await _client.storage.from(_bucket).uploadBinary(
          ruta,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    try {
      final fila = await _client
          .from('profesional_portafolio')
          .insert({
            'profesional_id': _uid,
            'storage_path': ruta,
            'orden': orden,
            'descripcion': descripcion,
          })
          .select('id, storage_path, orden, descripcion')
          .single();

      return FotoPortafolio.desdeFila(fila);
    } on Object {
      await _client.storage.from(_bucket).remove([ruta]).catchError(
            (_) => <FileObject>[],
          );
      rethrow;
    }
  }

  /// Primero el archivo y después la fila, por el mismo motivo que arriba: si
  /// se borrara la fila primero y fallara el archivo, nadie sabría que ese
  /// objeto quedó ahí.
  Future<void> eliminar(FotoPortafolio foto) async {
    await _client.storage.from(_bucket).remove([foto.storagePath]);
    await _client.from('profesional_portafolio').delete().eq('id', foto.id);
  }

  /// URLs firmadas en lote, igual que las fotos del pedido: una galería de
  /// diez fotos firmada de a una son diez viajes.
  Future<Map<String, String>> urlsFirmadas(
    List<String> rutas, {
    int segundos = 600,
  }) async {
    if (rutas.isEmpty) return const {};

    try {
      final resultados = await _client.storage
          .from(_bucket)
          .createSignedUrlsResult(rutas, segundos);

      return {
        for (final resultado in resultados)
          if (resultado case SignedUrlSuccess(:final path, :final signedUrl))
            path: signedUrl,
      };
    } catch (_) {
      return const {};
    }
  }
}

@Riverpod(keepAlive: true)
PortafolioRepository portafolioRepository(Ref ref) =>
    PortafolioRepository(ref.watch(supabaseClientProvider));
