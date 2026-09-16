import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../pedidos/domain/ubicacion.dart';
import '../domain/zona_cobertura.dart';

part 'zona_cobertura_repository.g.dart';

/// CU-07 — Zona de cobertura del Profesional.
///
/// Tabla y políticas: migración 0012. Los *computed fields* y la RPC de
/// guardado: migración 0014.
///
/// No envuelve los errores en una excepción propia: los `raise exception` de
/// la RPC llegan como `P0001` y `MensajesError.desde` ya los muestra tal cual,
/// que es para lo que están escritos en castellano.
class ZonaCoberturaRepository {
  const ZonaCoberturaRepository(this._client);

  final SupabaseClient _client;

  /// La zona del Profesional autenticado, o `null` si todavía no configuró
  /// ninguna. La RLS ya limita la fila a la propia; el filtro explícito está
  /// para no depender de eso, igual que en `listarMisPedidos`.
  Future<ZonaCobertura?> cargar() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return null;

    final fila = await _client
        .from('profesional_zona_cobertura')
        .select('radio_metros, direccion_texto, lat, lng')
        .eq('profesional_id', id)
        .maybeSingle();

    return ZonaCobertura.desdeFila(fila);
  }

  /// Alta o cambio, en una sola llamada: la zona es una por Profesional y la
  /// RPC hace el upsert, así que la pantalla no necesita saber si ya había.
  ///
  /// Va por RPC y no por un INSERT de PostgREST porque el centro es un
  /// `geography`, que se arma en la base con `public.punto(lat, lng)`: el
  /// orden `(x, y)` de PostGIS no se escribe del lado del cliente.
  Future<ZonaCobertura> guardar({
    required Ubicacion centro,
    required int radioMetros,
  }) async {
    final fila = await _client.rpc(
      'guardar_zona_cobertura',
      params: {
        // Van los dos números sueltos: el orden lo pone `public.punto()`.
        'p_lat': centro.lat,
        'p_lng': centro.lng,
        'p_radio_metros': ZonaCobertura.radioValido(radioMetros),
        'p_direccion': centro.direccionTexto.trim(),
      },
    ).select('radio_metros, direccion_texto, lat, lng').single();

    final zona = ZonaCobertura.desdeFila(fila);

    if (zona == null) {
      throw StateError('La zona se guardó pero el servidor no la devolvió.');
    }

    return zona;
  }
}

@Riverpod(keepAlive: true)
ZonaCoberturaRepository zonaCoberturaRepository(Ref ref) =>
    ZonaCoberturaRepository(ref.watch(supabaseClientProvider));
