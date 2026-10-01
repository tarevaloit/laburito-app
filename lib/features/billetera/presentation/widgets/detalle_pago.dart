import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/enlaces.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/billetera_repository.dart';
import '../../domain/pago.dart';
import '../controllers/billetera_controller.dart';

/// El estado de un pago en una píldora de color: verde aprobado, naranja
/// pendiente, rojo rechazado o cancelado.
class ChipEstadoPago extends StatelessWidget {
  const ChipEstadoPago({super.key, required this.estado});

  final EstadoPago estado;

  @override
  Widget build(BuildContext context) {
    final (color, fondo) = switch (estado) {
      EstadoPago.aprobado => (Colores.exito, Colores.exitoSuave),
      EstadoPago.pendiente => (Colores.naranjaOscuro, Colores.naranjaSuave),
      EstadoPago.rechazado ||
      EstadoPago.cancelado =>
        (Colores.error, Colores.errorSuave),
    };

    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

/// CU-33, pasos 5 y 6: el detalle de una compra —fecha, monto, paquete, medio
/// de pago y número de comprobante— y, si está aprobada, la descarga del
/// comprobante del CU-19.
Future<void> mostrarDetallePago(BuildContext context, Pago pago) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DetallePago(pago: pago),
    );

class _DetallePago extends ConsumerStatefulWidget {
  const _DetallePago({required this.pago});

  final Pago pago;

  @override
  ConsumerState<_DetallePago> createState() => _DetallePagoState();
}

class _DetallePagoState extends ConsumerState<_DetallePago> {
  bool _descargando = false;
  bool _verificando = false;
  late Pago _pago = widget.pago;

  /// Un pago pendiente se puede consultar a mano: busca el pago en Mercado
  /// Pago y aplica lo que conteste (la conciliación del CU-32).
  Future<void> _verificar() async {
    setState(() => _verificando = true);
    final repo = ref.read(billeteraRepositoryProvider);
    try {
      await repo.verificarPago(_pago.id);
      final actualizado = await repo.pago(_pago.id);
      if (!mounted || actualizado == null) return;
      setState(() => _pago = actualizado);
      if (actualizado.estado != EstadoPago.pendiente) {
        ref.invalidate(historialPagosProvider);
        await ref.read(billeteraProvider.notifier).refrescar();
      } else if (mounted) {
        mostrarMensaje(
          context,
          'Mercado Pago todavía no tiene este pago como pagado.',
          esError: false,
        );
      }
    } on Object catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  Future<void> _descargar() async {
    setState(() => _descargando = true);
    try {
      final url =
          await ref.read(billeteraRepositoryProvider).comprobante(_pago.id);
      final abierto = await abrirEnlace(url);
      if (!abierto && mounted) {
        mostrarMensaje(context, 'No pudimos abrir el comprobante.');
      }
    } on Object catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pago = _pago;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pago.concepto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colores.azul,
                    ),
                  ),
                ),
                ChipEstadoPago(estado: pago.estado),
              ],
            ),
            const SizedBox(height: 16),
            _Fila('Fecha', Fechas.conHora(pago.fecha)),
            _Fila('Monto', pago.montoLegible),
            _Fila('Paquete', pago.paqueteNombre),
            _Fila('Tokens', '${pago.cantidadTokens}'),
            _Fila('Medio de pago', pago.metodoLegible),
            _Fila('N.º de comprobante', pago.numeroComprobanteLegible ?? '—'),
            if (pago.motivoLegible != null) ...[
              const SizedBox(height: 12),
              Text(
                pago.motivoLegible!,
                style: const TextStyle(color: Colores.textoSecundario),
              ),
            ],
            const SizedBox(height: 20),
            if (pago.tieneComprobante)
              BotonPrincipal(
                texto: 'Descargar comprobante',
                icono: Icons.picture_as_pdf_outlined,
                cargando: _descargando,
                onPressed: _descargar,
              )
            else if (pago.estado == EstadoPago.pendiente) ...[
              const AvisoEstado.pendiente(
                icono: Icons.hourglass_top_rounded,
                titulo: 'Comprobante en proceso de emisión',
                detalle: 'Va a estar disponible cuando Mercado Pago confirme '
                    'el pago.',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _verificando ? null : _verificar,
                icon: _verificando
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Consultar a Mercado Pago'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(color: Colores.textoSecundario)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
