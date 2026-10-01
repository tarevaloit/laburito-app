import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/mensajes_error.dart';
import '../../../core/providers/supabase_providers.dart';
import '../domain/movimiento_tokens.dart';
import '../domain/pago.dart';
import '../domain/paquete_tokens.dart';
import '../domain/resultado_canje.dart';

part 'billetera_repository.g.dart';

/// Un error que contestó una Edge Function con el mensaje ya redactado para el
/// usuario (`{ error, codigo }`, ver `supabase/functions/_shared/http.ts`).
class ErrorDeFuncion implements ErrorDeNegocio {
  const ErrorDeFuncion(this.message, {this.codigo});

  @override
  final String message;

  /// El `hint` de la base o el código propio de la función:
  /// `pagos_no_disponibles`, `comprobante_en_proceso`, `sin_permiso`...
  final String? codigo;

  static const _generico =
      'No pudimos completar la operación. Probá de nuevo en un momento.';

  /// Traduce la excepción del cliente de Functions. Un 5xx sin mensaje propio,
  /// o un fallo de red (status 0), no le dice nada útil a nadie: va el genérico.
  factory ErrorDeFuncion.desde(FunctionException error) {
    final detalles = error.details;
    if (detalles is Map && detalles['error'] is String) {
      final codigo = detalles['codigo'] as String?;
      final conMensajePropio = codigo != null || error.status < 500;
      return ErrorDeFuncion(
        conMensajePropio ? detalles['error'] as String : _generico,
        codigo: codigo,
      );
    }
    return const ErrorDeFuncion(_generico);
  }

  @override
  String toString() => message;
}

/// Lo que devuelve `crear_preferencia_pago`: el pago pendiente y la URL del
/// checkout de Mercado Pago.
typedef CompraIniciada = ({String pagoId, Uri checkout});

/// CU-30, CU-31, CU-33, CU-53 y CU-19 — La billetera del Profesional.
///
/// Todo se lee por las políticas de la migración 0021 (cada uno ve lo suyo) y
/// se escribe por funciones: la app nunca inserta un pago ni un movimiento.
class BilleteraRepository {
  const BilleteraRepository(this._client);

  final SupabaseClient _client;

  static const int tamanioPagina = 20;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No hay sesión activa');
    return id;
  }

  // ---------------------------------------------------------------- CU-30

  Future<int> saldo() async {
    final fila = await _client
        .from('profesionales')
        .select('saldo_tokens')
        .eq('perfil_id', _uid)
        .maybeSingle();
    return (fila?['saldo_tokens'] as num?)?.toInt() ?? 0;
  }

  Future<List<MovimientoTokens>> movimientos({int limite = 10}) async {
    final filas = await _client
        .from('movimientos_tokens')
        .select('id, tipo, cantidad, saldo_resultante, descripcion, created_at')
        .eq('profesional_id', _uid)
        .order('created_at', ascending: false)
        .limit(limite);

    return [
      for (final f in filas as List)
        MovimientoTokens.desdeFila(f as Map<String, dynamic>),
    ];
  }

  Future<List<PaqueteTokens>> paquetes() async {
    final filas = await _client
        .from('paquetes_tokens')
        .select('id, nombre, cantidad, precio_ars, activo, orden')
        .eq('activo', true)
        .order('orden');

    return [
      for (final f in filas as List)
        PaqueteTokens.desdeFila(f as Map<String, dynamic>),
    ];
  }

  // ---------------------------------------------------------------- CU-31

  /// Crea el pago pendiente y la preferencia. **Manda solo el id del
  /// paquete**: el precio lo pone el servidor.
  Future<CompraIniciada> iniciarCompra(String paqueteId) async {
    try {
      final respuesta = await _client.functions.invoke(
        'crear_preferencia_pago',
        body: {'paquete_id': paqueteId},
      );
      final datos = respuesta.data as Map<String, dynamic>;
      return (
        pagoId: datos['pago_id'] as String,
        checkout: Uri.parse(datos['url'] as String),
      );
    } on FunctionException catch (error) {
      throw ErrorDeFuncion.desde(error);
    }
  }

  // ---------------------------------------------------------------- CU-33

  static const _columnasPago =
      'id, paquete_nombre, cantidad_tokens, monto_ars, estado, created_at, '
      'metodo_pago, mp_estado_detalle, numero_comprobante, aprobado_at';

  Future<Pago?> pago(String id) async {
    final fila = await _client
        .from('pagos')
        .select(_columnasPago)
        .eq('id', id)
        .maybeSingle();
    return fila == null ? null : Pago.desdeFila(fila);
  }

  /// Del más reciente al más viejo, de a [tamanioPagina].
  Future<List<Pago>> pagos({int desde = 0}) async {
    final filas = await _client
        .from('pagos')
        .select(_columnasPago)
        .eq('profesional_id', _uid)
        .order('created_at', ascending: false)
        .range(desde, desde + tamanioPagina - 1);

    return [
      for (final f in filas as List) Pago.desdeFila(f as Map<String, dynamic>),
    ];
  }

  /// Conciliación del CU-32: le pide al servidor que busque este pago en
  /// Mercado Pago y aplique lo que conteste. Es el respaldo del webhook: si el
  /// aviso de Mercado Pago se demora o no llega, el pago se resuelve igual.
  ///
  /// Nunca falla hacia la pantalla: si la verificación no se pudo hacer, el
  /// pago queda como estaba y se lo vuelve a leer de la base.
  Future<void> verificarPago(String id) async {
    try {
      await _client.functions.invoke('verificar_pago', body: {'pago_id': id});
    } on Object {
      // El seguimiento vuelve a intentar en el próximo ciclo.
    }
  }

  // ---------------------------------------------------------------- CU-53

  Future<CanjeCupon> canjear(String codigo) async {
    final filas = await _client.rpc('canjear_cupon', params: {
      'p_codigo': codigo,
    });
    return CanjeCupon.desdeFila((filas as List).first as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------- CU-19

  /// URL firmada (diez minutos) del PDF del comprobante.
  Future<Uri> comprobante(String pagoId) async {
    try {
      final respuesta = await _client.functions.invoke(
        'comprobante_pago',
        body: {'pago_id': pagoId},
      );
      return Uri.parse((respuesta.data as Map<String, dynamic>)['url'] as String);
    } on FunctionException catch (error) {
      throw ErrorDeFuncion.desde(error);
    }
  }
}

@Riverpod(keepAlive: true)
BilleteraRepository billeteraRepository(Ref ref) =>
    BilleteraRepository(ref.watch(supabaseClientProvider));
