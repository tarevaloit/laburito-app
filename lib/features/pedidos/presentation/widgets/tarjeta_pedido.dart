import 'package:flutter/material.dart';

import '../../../../app/colores.dart';
import '../../../../core/utils/fechas.dart';
import '../../domain/pedido.dart';
import '../../domain/pedido_estado.dart';
import 'chip_estado_pedido.dart';
import 'fotos_pedido.dart';

/// Una fila del historial (CU-17).
///
/// Muestra lo que hace falta para reconocer un pedido de un vistazo y decidir
/// si entrar: la foto principal, el título, en qué estado está, de qué oficio
/// es y cuánto tiempo le queda.
///
/// La fecha va en **formato relativo** —«vence en 3 días», «venció hace 2
/// días»— y no como fecha absoluta: en una lista lo único que se quiere saber
/// es si hay que hacer algo, y «08/09/2026» obliga a hacer la cuenta mental.
class TarjetaPedido extends StatelessWidget {
  const TarjetaPedido({
    super.key,
    required this.pedido,
    required this.urlPortada,
    required this.onTap,
  });

  final Pedido pedido;

  /// URL firmada de la foto principal, o `null` si no tiene foto o si la firma
  /// no volvió. En los dos casos se dibuja el ícono de la categoría.
  final String? urlPortada;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(Medidas.radioGrande);

    return Material(
      color: Colores.superficie,
      borderRadius: radio,
      child: InkWell(
        onTap: onTap,
        borderRadius: radio,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: radio,
            border: Border.all(color: Colores.borde),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Medidas.radio),
                  child: urlPortada == null
                      ? PlaceholderCategoria(
                          categoriaNombre: pedido.categoriaNombre,
                          tamanoIcono: 32,
                        )
                      : Image.network(
                          urlPortada!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) =>
                              PlaceholderCategoria(
                            categoriaNombre: pedido.categoriaNombre,
                            tamanoIcono: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colores.azul,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChipEstadoPedido(pedido.estado, compacto: true),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            pedido.categoriaNombre ?? 'Sin categoría',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colores.textoSecundario,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fecha(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colores.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colores.textoTenue),
            ],
          ),
        ),
      ),
    );
  }

  /// Qué fecha importa depende del estado: en uno terminado, cuándo terminó;
  /// en uno en curso, cuánto le queda.
  String _fecha() {
    if (pedido.estado.esTerminal && pedido.fechaCierre != null) {
      final verbo =
          pedido.estado == PedidoEstado.cerrado ? 'Cerrado' : 'Cancelado';
      return '$verbo ${Fechas.hace(pedido.fechaCierre!)}';
    }

    final vigencia = Fechas.vigencia(pedido.fechaVencimiento);
    // Con mayúscula inicial: es el arranque de la línea, no parte de una frase.
    return vigencia[0].toUpperCase() + vigencia.substring(1);
  }
}
