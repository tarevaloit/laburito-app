import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/contacto_buscador.dart';

part 'contacto_repository.g.dart';

/// Sin saldo para desbloquear: la pantalla ofrece ir a comprar tokens en vez de
/// solo mostrar el error (flujo alterno 1.2 del CU-25).
class SaldoInsuficienteException implements Exception {
  const SaldoInsuficienteException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// CU-25 — Postularse (Desbloquear Contacto). Funciones de la migración 0023.
class ContactoRepository {
  const ContactoRepository(this._client);

  final SupabaseClient _client;

  /// Nombre corto y teléfono enmascarado; el teléfono entero solo si ya se
  /// desbloqueó. `null` si el pedido ya no está visible y no se había
  /// desbloqueado.
  Future<ContactoBuscador?> contacto(String pedidoId) async {
    final filas = await _client.rpc('contacto_pedido', params: {
      'p_pedido': pedidoId,
    }) as List;
    return filas.isEmpty
        ? null
        : ContactoBuscador.desdeFila(filas.first as Map<String, dynamic>);
  }

  /// Cobra un token y devuelve el teléfono. Si ya estaba desbloqueado, no
  /// cobra. Sin saldo tira [SaldoInsuficienteException]; el resto de los
  /// rechazos (sin verificar, pedido cerrado) llegan como P0001 con el mensaje
  /// para el usuario, que `MensajesError` muestra tal cual.
  Future<ContactoDesbloqueado> desbloquear(String pedidoId) async {
    try {
      final filas = await _client.rpc('desbloquear_contacto', params: {
        'p_pedido': pedidoId,
      }) as List;
      return ContactoDesbloqueado.desdeFila(
          filas.first as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      if (error.hint == 'saldo_insuficiente') {
        throw SaldoInsuficienteException(error.message);
      }
      rethrow;
    }
  }

  /// Para el dueño del pedido: cuántos Profesionales desbloquearon su
  /// contacto.
  Future<int> interesados(String pedidoId) async {
    final total = await _client.rpc('interesados_pedido', params: {
      'p_pedido': pedidoId,
    });
    return (total as num?)?.toInt() ?? 0;
  }
}

@Riverpod(keepAlive: true)
ContactoRepository contactoRepository(Ref ref) =>
    ContactoRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<ContactoBuscador?> contactoPedido(Ref ref, String pedidoId) =>
    ref.watch(contactoRepositoryProvider).contacto(pedidoId);

@riverpod
Future<int> interesadosPedido(Ref ref, String pedidoId) =>
    ref.watch(contactoRepositoryProvider).interesados(pedidoId);
