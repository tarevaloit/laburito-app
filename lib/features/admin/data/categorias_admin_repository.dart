import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../categorias/data/categorias_repository.dart';

part 'categorias_admin_repository.g.dart';

/// Una tarjeta de la Figura 3.23: el oficio, su ícono, si está visible y
/// cuántos Profesionales activos lo ofrecen.
class CategoriaAdmin {
  const CategoriaAdmin({
    required this.id,
    required this.nombre,
    required this.slug,
    required this.activa,
    this.icono,
    this.profesionales = 0,
    this.pedidos = 0,
  });

  final String id;
  final String nombre;
  final String slug;
  final String? icono;
  final bool activa;
  final int profesionales;
  final int pedidos;

  /// Flujo alterno del CU-37: con datos asociados no se puede borrar.
  bool get enUso => profesionales > 0 || pedidos > 0;

  factory CategoriaAdmin.desdeFila(Map<String, dynamic> f) => CategoriaAdmin(
        id: f['id'] as String,
        nombre: f['nombre'] as String,
        slug: f['slug'] as String,
        icono: f['icono'] as String?,
        activa: f['activa'] as bool? ?? true,
        profesionales: (f['profesionales'] as num?)?.toInt() ?? 0,
        pedidos: (f['pedidos'] as num?)?.toInt() ?? 0,
      );

  /// Los íconos que ofrece el formulario. Son emojis: se ven igual en la Web y
  /// en Android sin sumar una fuente de íconos.
  static const iconosSugeridos = [
    '🔧', '⚡', '🔥', '🔑', '🧱', '🎨', '🪚', '⚒️', '❄️', '🏠', '📐', '🌿',
    '🧽', '🚚', '🔌', '📶', '📹', '🪵', '🪟', '🚿', '💧', '🛋️', '🏊', '🧰',
  ];
}

/// CU-37 — Gestionar Categorías de Oficios (migración 0038).
class CategoriasAdminRepository {
  const CategoriasAdminRepository(this._client);

  final SupabaseClient _client;

  Future<List<CategoriaAdmin>> todas() async {
    final filas = await _client.rpc('categorias_admin') as List;
    return [
      for (final f in filas) CategoriaAdmin.desdeFila(f as Map<String, dynamic>),
    ];
  }

  Future<void> crear({required String nombre, String? icono}) =>
      _client.rpc('crear_categoria', params: {'p_nombre': nombre, 'p_icono': icono});

  Future<void> editar(String id, {required String nombre, String? icono}) =>
      _client.rpc('editar_categoria',
          params: {'p_id': id, 'p_nombre': nombre, 'p_icono': icono});

  Future<void> cambiarVisibilidad(String id, {required bool activa}) =>
      _client.rpc('cambiar_visibilidad_categoria',
          params: {'p_id': id, 'p_activa': activa});

  Future<void> eliminar(String id) =>
      _client.rpc('eliminar_categoria', params: {'p_id': id});
}

@Riverpod(keepAlive: true)
CategoriasAdminRepository categoriasAdminRepository(Ref ref) =>
    CategoriasAdminRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<CategoriaAdmin>> categoriasAdmin(Ref ref) =>
    ref.watch(categoriasAdminRepositoryProvider).todas();

/// Después de cualquier cambio se refresca también el catálogo público: el
/// selector de oficios del registro (CU-02) y del pedido (CU-13) lo cachean.
void refrescarCatalogo(WidgetRef ref) {
  ref.invalidate(categoriasAdminProvider);
  ref.invalidate(categoriasActivasProvider);
}
