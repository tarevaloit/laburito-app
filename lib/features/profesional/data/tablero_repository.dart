import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/pedido_tablero.dart';

part 'tablero_repository.g.dart';

/// CU-43 y CU-22 — Lo que el Profesional ve de los pedidos ajenos.
///
/// Todo pasa por las dos funciones de la migración 0018, que leen
/// `pedidos_publicos`: no hay ninguna consulta de este lado contra la tabla
/// `pedidos`. Es lo que garantiza que al Profesional no le lleguen ni la
/// referencia de la dirección ni la coordenada exacta.
class TableroRepository {
  const TableroRepository(this._client);

  final SupabaseClient _client;

  /// Una página del tablero, ya ordenada por distancia del lado del servidor.
  Future<List<PedidoTablero>> listar({
    int limite = 20,
    int desplazamiento = 0,
    bool soloMisOficios = true,
    bool soloGuardados = false,
  }) async {
    final filas = await _client.rpc('tablero_pedidos', params: {
      'p_limite': limite,
      'p_desplazamiento': desplazamiento,
      'p_solo_mis_oficios': soloMisOficios,
      'p_solo_guardados': soloGuardados,
    });

    return [
      for (final fila in filas as List)
        PedidoTablero.desdeFila(fila as Map<String, dynamic>),
    ];
  }

  /// El detalle. `null` cuando el pedido dejó de estar publicado o vigente
  /// entre que se dibujó el tablero y se tocó la tarjeta, que no es un error:
  /// la pantalla lo dice y ofrece volver.
  Future<PedidoTablero?> detalle(String pedidoId) async {
    final filas = await _client.rpc('pedido_publico', params: {
      'p_pedido_id': pedidoId,
    });

    final lista = filas as List;
    if (lista.isEmpty) return null;

    return PedidoTablero.desdeFila(lista.first as Map<String, dynamic>);
  }

  // --------------------------------------------------------------------------
  // CU-23 Ignorar · CU-24 Guardar
  // --------------------------------------------------------------------------
  //
  // Van por PostgREST y no por RPC: son un insert y un delete sobre tablas con
  // clave compuesta (profesional, pedido), y las políticas de la 0012 ya dicen
  // todo lo que hay que decir —solo a nombre propio, solo sobre un pedido que
  // se pueda ver, y borrar solo lo propio—. Una función no agregaría ninguna
  // regla que la RLS no tenga.

  /// CU-23 — Sacar el pedido del tablero de este Profesional.
  ///
  /// Ignorar también lo quita de guardados: tener un pedido descartado y
  /// marcado como interesante a la vez es un estado que no significa nada, y
  /// la solapa de guardados lo seguiría mostrando después de haberlo sacado.
  Future<void> ignorar(String pedidoId) async {
    await _client.from('pedido_favorito').delete().match({
      'profesional_id': _uid,
      'pedido_id': pedidoId,
    });

    await _client.from('pedido_ignorado').upsert({
      'profesional_id': _uid,
      'pedido_id': pedidoId,
    });
  }

  /// Deshacer, para el «Deshacer» del aviso: ignorar es la única acción del
  /// tablero que hace desaparecer algo de la pantalla.
  Future<void> dejarDeIgnorar(String pedidoId) async {
    await _client.from('pedido_ignorado').delete().match({
      'profesional_id': _uid,
      'pedido_id': pedidoId,
    });
  }

  /// CU-24 — Guardar o dejar de guardar.
  Future<void> guardar(String pedidoId, {required bool guardado}) async {
    if (guardado) {
      await _client.from('pedido_favorito').upsert({
        'profesional_id': _uid,
        'pedido_id': pedidoId,
      });
    } else {
      await _client.from('pedido_favorito').delete().match({
        'profesional_id': _uid,
        'pedido_id': pedidoId,
      });
    }
  }

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('No hay sesión activa');
    }
    return id;
  }
}

@Riverpod(keepAlive: true)
TableroRepository tableroRepository(Ref ref) =>
    TableroRepository(ref.watch(supabaseClientProvider));

/// El detalle de un pedido del tablero (CU-22). Autodispose y por familia: al
/// volver al tablero se descarta, y al entrar de nuevo se relee —un pedido
/// ajeno puede haberse cerrado mientras tanto—.
@riverpod
Future<PedidoTablero?> pedidoPublico(Ref ref, String id) =>
    ref.watch(tableroRepositoryProvider).detalle(id);
