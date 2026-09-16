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

  /// CU-12 — Reemplaza el conjunto de oficios del Profesional autenticado.
  ///
  /// Va por la RPC `reemplazar_categorias_oficio` (migración 0015) y no por un
  /// DELETE seguido de un INSERT: eran dos escrituras sin transacción común, y
  /// si la segunda fallaba el Profesional quedaba **sin ningún oficio**, que
  /// con el CU-21 significa dejar de recibir alertas sin enterarse.
  ///
  /// La RPC toma el dueño de `auth.uid()`, así que no recibe el id: no hay
  /// forma de editarle los oficios a otro. También valida del lado del
  /// servidor lo que antes vivía solo en la pantalla —entre 1 y
  /// [CategoriaOficio.maximoPorProfesional] oficios, que existan y estén
  /// activos—, con mensajes en castellano que `MensajesError` muestra tal cual.
  ///
  /// Devuelve los slugs que quedaron guardados, leídos de la base.
  Future<List<String>> reemplazar({required List<String> slugs}) async {
    final filas = await _client.rpc(
      'reemplazar_categorias_oficio',
      params: {'p_slugs': slugs},
    );

    return (filas as List).cast<String>();
  }
}

@freezed
abstract class CategoriaOficio with _$CategoriaOficio {
  /// Tope de oficios por Profesional. Lo aplican las dos puntas: el
  /// `SelectorOficios` no deja marcar más, y la RPC de la 0015 lo rechaza.
  static const int maximoPorProfesional = 5;

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
