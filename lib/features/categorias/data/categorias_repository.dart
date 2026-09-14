import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

part 'categorias_repository.freezed.dart';
part 'categorias_repository.g.dart';

/// Catálogo de oficios. Lectura pública: se consulta sin sesión durante el
/// registro del Profesional (CU-02).
class CategoriasRepository {
  const CategoriasRepository(this._client);

  final SupabaseClient _client;

  Future<List<CategoriaOficio>> activas() async {
    final filas = await _client
        .from('categorias_oficio')
        .select('id, nombre, slug')
        .eq('activa', true)
        // `ascending` va explícito: el cliente de Supabase ordena descendente
        // por defecto, y el catálogo salía al revés (Tapicería primero,
        // Plomería última).
        .order('orden', ascending: true);

    return (filas as List)
        .map((f) => CategoriaOficio(
              id: f['id'] as String,
              nombre: f['nombre'] as String,
              slug: f['slug'] as String,
            ))
        .toList();
  }

  Future<List<String>> slugsDelProfesional(String profesionalId) async {
    final filas = await _client
        .from('profesional_categorias')
        .select('categorias_oficio(slug)')
        .eq('profesional_id', profesionalId);

    return (filas as List)
        .map((f) => (f['categorias_oficio'] as Map)['slug'] as String)
        .toList();
  }

  /// Reemplaza el conjunto de categorías del Profesional (CU-05, CU-12).
  Future<void> reemplazar({
    required String profesionalId,
    required List<String> slugs,
  }) async {
    await _client
        .from('profesional_categorias')
        .delete()
        .eq('profesional_id', profesionalId);

    if (slugs.isEmpty) return;

    final catalogo = await _client
        .from('categorias_oficio')
        .select('id, slug')
        .inFilter('slug', slugs);

    final filas = (catalogo as List)
        .map((c) => {
              'profesional_id': profesionalId,
              'categoria_id': c['id'],
            })
        .toList();

    if (filas.isNotEmpty) {
      await _client.from('profesional_categorias').insert(filas);
    }
  }
}

@freezed
abstract class CategoriaOficio with _$CategoriaOficio {
  const factory CategoriaOficio({
    required String id,
    required String nombre,
    required String slug,
  }) = _CategoriaOficio;
}

@Riverpod(keepAlive: true)
CategoriasRepository categoriasRepository(Ref ref) =>
    CategoriasRepository(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
Future<List<CategoriaOficio>> categoriasActivas(Ref ref) =>
    ref.watch(categoriasRepositoryProvider).activas();
