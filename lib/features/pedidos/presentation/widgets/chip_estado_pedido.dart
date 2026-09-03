import 'package:flutter/material.dart';

import '../../../../app/colores.dart';
import '../../domain/pedido_estado.dart';

/// Chip de estado del pedido, con color propio por estado.
///
/// Vive acá y no adentro de una pantalla porque lo usan el detalle (Fase 6) y
/// las tarjetas del historial (CU-17): si el color de «Pausado» se elige dos
/// veces, en algún momento van a ser dos naranjas distintos.
///
/// El criterio de color es el mismo del ANEXO UI y de [AvisoEstado]: verde para
/// lo que está en curso y sano, naranja para lo que espera una decisión del
/// usuario, rojo para lo que se dio de baja, azul de marca para lo que terminó
/// bien, y gris para lo que simplemente se quedó sin tiempo.
class ChipEstadoPedido extends StatelessWidget {
  const ChipEstadoPedido(this.estado, {super.key, this.compacto = false});

  final PedidoEstado estado;

  /// Versión chica para las tarjetas de la lista.
  final bool compacto;

  /// Color del texto y del ícono.
  static Color colorDe(PedidoEstado estado) => switch (estado) {
        PedidoEstado.publicado => Colores.exito,
        PedidoEstado.pausado => Colores.naranja,
        PedidoEstado.vencido => Colores.textoSecundario,
        PedidoEstado.cerrado => Colores.azul,
        PedidoEstado.cancelado => Colores.error,
      };

  /// Fondo del chip.
  static Color fondoDe(PedidoEstado estado) => switch (estado) {
        PedidoEstado.publicado => Colores.exitoSuave,
        PedidoEstado.pausado => Colores.naranjaSuave,
        PedidoEstado.vencido => Colores.neutroSuave,
        PedidoEstado.cerrado => Colores.azulSuave,
        PedidoEstado.cancelado => Colores.errorSuave,
      };

  static IconData iconoDe(PedidoEstado estado) => switch (estado) {
        PedidoEstado.publicado => Icons.visibility_outlined,
        PedidoEstado.pausado => Icons.pause_circle_outline,
        PedidoEstado.vencido => Icons.schedule,
        PedidoEstado.cerrado => Icons.check_circle_outline,
        PedidoEstado.cancelado => Icons.cancel_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final color = colorDe(estado);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? 8 : 12,
        vertical: compacto ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: fondoDe(estado),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconoDe(estado), size: compacto ? 13 : 15, color: color),
          SizedBox(width: compacto ? 4 : 6),
          Text(
            estado.etiqueta,
            style: TextStyle(
              fontSize: compacto ? 11 : 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
