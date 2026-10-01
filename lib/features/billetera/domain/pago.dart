import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/dinero.dart';

part 'pago.freezed.dart';

/// El enum `pago_estado` de la 0021.
enum EstadoPago {
  pendiente('Pendiente'),
  aprobado('Aprobado'),
  rechazado('Rechazado'),
  cancelado('Cancelado');

  const EstadoPago(this.etiqueta);

  final String etiqueta;

  static EstadoPago desde(String valor) =>
      EstadoPago.values.firstWhere((e) => e.name == valor);
}

/// CU-31 / CU-32 / CU-33 / CU-19 — Una compra de tokens.
///
/// Cantidad y monto son los que se copiaron del paquete al iniciar la compra:
/// si el precio cambió después (CU-40), acá sigue lo que se pagó.
@freezed
abstract class Pago with _$Pago {
  const Pago._();

  const factory Pago({
    required String id,
    required String paqueteNombre,
    required int cantidadTokens,
    required int montoArs,
    required EstadoPago estado,
    required DateTime fecha,
    String? metodoPago,
    String? estadoDetalle,
    int? numeroComprobante,
    DateTime? aprobadoAt,
  }) = _Pago;

  String get montoLegible => Dinero.pesos(montoArs);

  String get concepto => 'Pack $paqueteNombre · $cantidadTokens tokens';

  bool get tieneComprobante =>
      estado == EstadoPago.aprobado && numeroComprobante != null;

  /// «0001-00000012»: el formato del comprobante del CU-19 (punto de venta
  /// fijo y número correlativo).
  String? get numeroComprobanteLegible => numeroComprobante == null
      ? null
      : '0001-${numeroComprobante.toString().padLeft(8, '0')}';

  /// El medio de pago tal como lo informa Mercado Pago (`master`, `visa`,
  /// `account_money`), en palabras.
  String get metodoLegible => switch (metodoPago) {
        null => 'Mercado Pago',
        'account_money' => 'Dinero en cuenta de Mercado Pago',
        'master' => 'Mastercard',
        'visa' => 'Visa',
        'amex' => 'American Express',
        'debmaster' => 'Mastercard Débito',
        'debvisa' => 'Visa Débito',
        final otro => otro,
      };

  /// El motivo de un rechazo, en palabras (paso 1.2 del flujo alterno del
  /// CU-32). Mercado Pago lo manda como `status_detail`.
  String? get motivoLegible {
    if (estado == EstadoPago.aprobado) return null;
    final detalle = estadoDetalle;
    if (detalle == null) {
      return estado == EstadoPago.pendiente
          ? 'Todavía no recibimos la confirmación de Mercado Pago.'
          : null;
    }
    if (detalle.startsWith('preferencia_fallida')) {
      return 'No se pudo iniciar el pago con Mercado Pago.';
    }
    if (detalle.startsWith('monto_no_coincide')) {
      return 'El monto cobrado no coincide con el del paquete. Escribinos para revisarlo.';
    }
    return switch (detalle) {
      'cc_rejected_insufficient_amount' => 'La tarjeta no tiene fondos suficientes.',
      'cc_rejected_bad_filled_security_code' => 'El código de seguridad es incorrecto.',
      'cc_rejected_bad_filled_date' => 'La fecha de vencimiento es incorrecta.',
      'cc_rejected_bad_filled_other' => 'Algún dato de la tarjeta es incorrecto.',
      'cc_rejected_call_for_authorize' => 'Tenés que autorizar el pago con tu banco.',
      'cc_rejected_card_disabled' => 'La tarjeta está deshabilitada.',
      'cc_rejected_duplicated_payment' => 'Ya hiciste un pago igual hace un momento.',
      'cc_rejected_high_risk' => 'Mercado Pago rechazó el pago por seguridad.',
      'cc_rejected_max_attempts' => 'Superaste los intentos permitidos con esa tarjeta.',
      'pending_contingency' || 'pending_review_manual' =>
        'Mercado Pago está revisando el pago.',
      'pending_waiting_payment' || 'pending_waiting_transfer' =>
        'Falta completar el pago.',
      _ => estado == EstadoPago.rechazado
          ? 'Mercado Pago rechazó el pago.'
          : null,
    };
  }

  factory Pago.desdeFila(Map<String, dynamic> fila) => Pago(
        id: fila['id'] as String,
        paqueteNombre: fila['paquete_nombre'] as String,
        cantidadTokens: (fila['cantidad_tokens'] as num).toInt(),
        montoArs: (fila['monto_ars'] as num).toInt(),
        estado: EstadoPago.desde(fila['estado'] as String),
        fecha: DateTime.parse(fila['created_at'] as String),
        metodoPago: fila['metodo_pago'] as String?,
        estadoDetalle: fila['mp_estado_detalle'] as String?,
        numeroComprobante: (fila['numero_comprobante'] as num?)?.toInt(),
        aprobadoAt: fila['aprobado_at'] == null
            ? null
            : DateTime.parse(fila['aprobado_at'] as String),
      );
}
