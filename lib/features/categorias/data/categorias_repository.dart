import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

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

class CategoriaOficio {
  const CategoriaOficio({
    required this.id,
    required this.nombre,
    required this.slug,
  });

  final String id;
  final String nombre;
  final String slug;
}

final categoriasRepositoryProvider = Provider<CategoriasRepository>(
  (ref) => CategoriasRepository(ref.watch(supabaseClientProvider)),
);

final categoriasActivasProvider = FutureProvider<List<CategoriaOficio>>(
  (ref) => ref.watch(categoriasRepositoryProvider).activas(),
);
