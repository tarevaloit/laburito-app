import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/pedido_exception.dart';
import '../../data/pedidos_repository.dart';
import '../../domain/pedido.dart';
import '../../domain/pedido_estado.dart';
import '../controllers/acciones_pedido_controller.dart';
import '../widgets/chip_estado_pedido.dart';
import '../widgets/dialogos_pedido.dart';
import '../widgets/fotos_pedido.dart';
import '../widgets/mini_mapa_pedido.dart';

/// Detalle del pedido del Buscador y centro de su ciclo de vida.
///
/// Es la pantalla desde la que se ejecutan CU-15 (editar), CU-20 (pausar y
/// reanudar), CU-29 (cerrar), CU-14 (cancelar) y CU-51 (renovar). La barra de
/// acciones de abajo ofrece **solo** lo que la máquina de estados admite para
/// el estado actual: la regla que manda es la de la base (la RPC
/// `cambiar_estado_pedido`), y `PedidoEstado.puedePasarA` es su espejo en Dart
/// para no dibujar un botón que el servidor va a rechazar.
class DetallePedidoScreen extends ConsumerWidget {
  const DetallePedidoScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidoAsync = ref.watch(pedidoProvider(id));

    // Los errores de las acciones se avisan una sola vez, acá: cada botón se
    // ocupa de disparar la acción y nada más.
    ref.listen(accionesPedidoProvider(id), (anterior, siguiente) async {
      final error = siguiente.error;
      if (error == null || error == anterior?.error) return;

      // El caso se lee del `PedidoException`, no del texto: cuando el servidor
      // dice que el pedido agotó sus renovaciones no alcanza con avisarlo, hay
      // que ofrecer la salida, que es publicar uno nuevo (CU-51).
      if (error.caso == CasoPedido.limiteRenovaciones) {
        if (await avisarLimiteDeRenovaciones(context) && context.mounted) {
          context.go('/pedidos/nuevo');
        }
        return;
      }

      mostrarMensaje(context, error.message);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu pedido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Sin nada que desapilar —se entró por URL o recién publicado— se
          // va al historial, que es de donde se llega a un pedido (CU-17).
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/pedidos'),
        ),
      ),
      body: pedidoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Aviso(
          icono: Icons.error_outline,
          titulo: 'No pudimos abrir el pedido',
          detalle: MensajesError.desde(error),
        ),
        // Null es «no existe» o «no es tuyo»: las RLS no distinguen entre las
        // dos cosas y la pantalla tampoco tiene por qué.
        data: (pedido) => pedido == null
            ? const _Aviso(
                icono: Icons.search_off,
                titulo: 'No encontramos ese pedido',
                detalle: 'Puede que lo hayas eliminado, o que no sea tuyo.',
              )
            : _Detalle(pedido: pedido),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icono, required this.titulo, this.detalle});

  final IconData icono;
  final String titulo;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 40, color: Colores.textoSecundario),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colores.azul,
              ),
            ),
            if (detalle != null) ...[
              const SizedBox(height: 6),
              Text(
                detalle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colores.textoSecundario),
              ),
            ],
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Contenido
// ----------------------------------------------------------------------------

class _Detalle extends StatelessWidget {
  const _Detalle({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    return Column(
      // `stretch`: de acá sale el ancho de la barra de acciones de abajo.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: TarjetaFormulario(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CarruselFotosPedido(
                  fotos: pedido.fotos,
                  categoriaNombre: pedido.categoriaNombre,
                ),
                const SizedBox(height: 20),
                _Encabezado(pedido: pedido),
                const SizedBox(height: 20),
                _Seccion(
                  titulo: 'Qué se necesita',
                  child: Text(
                    pedido.descripcion,
                    style: const TextStyle(height: 1.5, color: Colores.texto),
                  ),
                ),
                const SizedBox(height: 20),
                _Seccion(
                  titulo: 'Dónde',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MiniMapaPedido(ubicacion: pedido.ubicacion),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 18, color: Colores.naranja),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pedido.ubicacion.direccionTexto,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                if (pedido.ubicacion.referencia != null)
                                  Text(
                                    pedido.ubicacion.referencia!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colores.textoSecundario,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _Seccion(
                  titulo: 'Datos del pedido',
                  child: _Datos(pedido: pedido),
                ),
                const SizedBox(height: 20),
                _AvisoDeEstado(pedido: pedido),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        BarraDeAccionesPedido(pedido: pedido),
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ChipEstadoPedido(pedido.estado),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                pedido.categoriaNombre ?? 'Sin categoría',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colores.textoSecundario,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          pedido.titulo,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colores.azul,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.bolt_outlined, size: 16, color: Colores.naranja),
            const SizedBox(width: 4),
            Text(
              pedido.urgencia.etiqueta,
              style: const TextStyle(
                fontSize: 13,
                color: Colores.textoSecundario,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colores.texto,
            ),
          ),
        ),
        TarjetaPanel(child: child),
      ],
    );
  }
}

class _Datos extends StatelessWidget {
  const _Datos({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final vencimiento = '${Fechas.corta(pedido.fechaVencimiento)} '
        '· ${Fechas.vigencia(pedido.fechaVencimiento)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Fila(
          'Presupuesto',
          pedido.presupuestoEstimado == null
              ? 'Sin definir'
              : '\$${pedido.presupuestoEstimado!.toStringAsFixed(0)}',
        ),
        _Fila('Publicado', Fechas.corta(pedido.fechaPublicacion)),
        _Fila('Vigencia', vencimiento),
        if (pedido.fechaCierre != null)
          _Fila(
            pedido.estado == PedidoEstado.cancelado ? 'Cancelado' : 'Cerrado',
            Fechas.corta(pedido.fechaCierre!),
          ),
        if (pedido.motivoCierre != null) _Fila('Motivo', pedido.motivoCierre!),
        if (pedido.renovaciones > 0)
          _Fila(
            'Renovaciones',
            '${pedido.renovaciones} de ${Pedido.maximoRenovaciones}',
          ),
        _Fila('Fotos', '${pedido.fotos.length} de 5'),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 13,
                color: Colores.textoSecundario,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Qué significa el estado en el que está el pedido, en una frase.
///
/// El chip dice «Pausado»; esto dice qué implica estar pausado. Es donde vive
/// la explicación que pide el CU-20: el pedido no se perdió, dejó de verse.
class _AvisoDeEstado extends StatelessWidget {
  const _AvisoDeEstado({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    return switch (pedido.estado) {
      PedidoEstado.publicado => const AvisoEstado.exito(
          icono: Icons.visibility_outlined,
          titulo: 'Tu pedido está visible',
          detalle: 'Los profesionales de la zona pueden verlo y contactarte '
              'hasta que venza.',
        ),
      PedidoEstado.pausado => const AvisoEstado.pendiente(
          icono: Icons.pause_circle_outline,
          titulo: 'Tu pedido está pausado',
          detalle: 'No se perdió: sigue guardado con sus fotos y su historial, '
              'pero por ahora no lo ve nadie. Reanudalo cuando quieras.',
        ),
      PedidoEstado.vencido => const AvisoEstado.pendiente(
          icono: Icons.schedule,
          titulo: 'Tu pedido venció',
          detalle: 'Dejó de mostrarse porque pasó su fecha. Podés renovarlo '
              'para que vuelva a verse.',
        ),
      PedidoEstado.cerrado => const AvisoEstado.exito(
          icono: Icons.check_circle_outline,
          titulo: 'Pedido cerrado',
          detalle: 'Lo marcaste como resuelto. Queda en tu historial y no se '
              'puede reabrir.',
        ),
      PedidoEstado.cancelado => const AvisoEstado.riesgo(
          icono: Icons.cancel_outlined,
          titulo: 'Pedido cancelado',
          detalle: 'Lo diste de baja. Queda en tu historial y no se puede '
              'reabrir.',
        ),
    };
  }
}

// ----------------------------------------------------------------------------
// Barra de acciones
// ----------------------------------------------------------------------------

/// Las acciones disponibles según el estado, y nada más.
///
/// El criterio es el de la máquina de estados de la migración 0006: de
/// `publicado` y `pausado` se sale a todos lados, de `vencido` solo se sale
/// renovando, y `cerrado` y `cancelado` son terminales y no ofrecen nada.
class BarraDeAccionesPedido extends ConsumerWidget {
  const BarraDeAccionesPedido({super.key, required this.pedido});

  final Pedido pedido;

  /// CU-51 — Renovar, con el límite de 3 resuelto antes de salir a la red.
  ///
  /// El cliente ya sabe cuántas renovaciones lleva el pedido, así que un
  /// pedido agotado no gasta un viaje para que el servidor conteste lo mismo.
  /// Igual el servidor manda: si su respuesta es `limiteRenovaciones` —porque
  /// el pedido se renovó desde otra pestaña—, la pantalla del detalle muestra
  /// este mismo diálogo al recibir el error.
  Future<void> _renovar(
    BuildContext context,
    AccionesPedido controlador,
  ) async {
    if (pedido.renovacionesRestantes <= 0) {
      if (await avisarLimiteDeRenovaciones(context) && context.mounted) {
        context.go('/pedidos/nuevo');
      }
      return;
    }

    final dias = await pedirDiasDeRenovacion(
      context,
      restantes: pedido.renovacionesRestantes,
    );
    if (dias == null) return;

    if (await controlador.renovar(dias) && context.mounted) {
      mostrarMensaje(
        context,
        'Renovamos tu pedido por $dias días. Vuelve a estar visible.',
        esError: false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(accionesPedidoProvider(pedido.id));
    final controlador = ref.read(accionesPedidoProvider(pedido.id).notifier);

    if (pedido.estado.esTerminal) return const SizedBox.shrink();

    final acciones = <Widget>[
      // CU-15 — Editar: solo mientras el pedido sigue su curso. Un pedido
      // vencido, cerrado o cancelado es historia, y la RPC de ubicación lo
      // rechaza.
      if (pedido.estado.esEditable)
        _BotonAccion(
          icono: Icons.edit_outlined,
          texto: 'Editar',
          cargando: false,
          habilitado: !estado.ocupado,
          onPressed: () => context.push('/pedidos/${pedido.id}/editar'),
        ),
      if (pedido.estado == PedidoEstado.publicado)
        _BotonAccion(
          icono: Icons.pause_outlined,
          texto: 'Pausar',
          cargando: estado.enCurso == AccionPedido.pausar,
          habilitado: !estado.ocupado,
          onPressed: () async {
            if (await controlador.pausar() && context.mounted) {
              mostrarMensaje(
                context,
                'Pausamos tu pedido. No se perdió: dejó de verse hasta que lo '
                'reanudes.',
                esError: false,
              );
            }
          },
        ),
      if (pedido.estado == PedidoEstado.pausado)
        _BotonAccion(
          icono: Icons.play_arrow_outlined,
          texto: 'Reanudar',
          cargando: estado.enCurso == AccionPedido.reanudar,
          habilitado: !estado.ocupado,
          onPressed: () async {
            if (await controlador.reanudar() && context.mounted) {
              mostrarMensaje(
                context,
                'Tu pedido volvió a estar visible.',
                esError: false,
              );
            }
          },
        ),
      // CU-29 — Cerrar: el trabajo se resolvió.
      if (pedido.estado.puedePasarA(PedidoEstado.cerrado))
        _BotonAccion(
          icono: Icons.check_circle_outline,
          texto: 'Cerrar',
          // Verde: cerrar es el final bueno, el trabajo se resolvió.
          color: Colores.exito,
          cargando: estado.enCurso == AccionPedido.cerrar,
          habilitado: !estado.ocupado,
          onPressed: () async {
            final motivo = await pedirMotivoDeCierre(context);
            if (motivo == null) return;

            if (await controlador.cerrar(motivo) && context.mounted) {
              mostrarMensaje(
                context,
                'Cerramos tu pedido. Queda en tu historial.',
                esError: false,
              );
            }
          },
        ),
      // CU-14 — Cancelar: el pedido se da de baja sin haberse hecho.
      if (pedido.estado.puedePasarA(PedidoEstado.cancelado))
        _BotonAccion(
          icono: Icons.cancel_outlined,
          texto: 'Cancelar',
          // Rojo: es una baja, el pedido no llegó a hacerse.
          color: Colores.error,
          cargando: estado.enCurso == AccionPedido.cancelar,
          habilitado: !estado.ocupado,
          onPressed: () async {
            final confirmada = await confirmarCancelacion(context);
            if (confirmada == null) return;

            final hecho = await controlador.cancelar(motivo: confirmada.motivo);
            if (hecho && context.mounted) {
              mostrarMensaje(
                context,
                'Dimos de baja tu pedido. Queda en tu historial.',
                esError: false,
              );
            }
          },
        ),
      // CU-51 — Renovar. Es la única salida del estado vencido: de `vencido`
      // no hay transición válida, ni siquiera a `publicado`, porque volver a
      // publicar sin correr la fecha dejaría el pedido visible y ya vencido.
      //
      // También se ofrece sobre un pedido cuya fecha ya pasó pero que todavía
      // figura publicado o pausado: es el mismo caso: el barrido
      // `marcar_pedidos_vencidos` todavía no corrió. Sin esto, un pedido
      // pausado y caduco no se podría ni reanudar (la RPC lo rechaza) ni
      // renovar, que es un callejón sin salida.
      if (pedido.estado == PedidoEstado.vencido || pedido.estaCaduco())
        _BotonAccion(
          icono: Icons.autorenew,
          texto: 'Renovar',
          cargando: estado.enCurso == AccionPedido.renovar,
          habilitado: !estado.ocupado,
          onPressed: () => _renovar(context, controlador),
        ),
    ];

    if (acciones.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colores.superficie,
        border: Border(top: BorderSide(color: Colores.borde)),
      ),
      child: SafeArea(
        top: false,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: acciones,
        ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  const _BotonAccion({
    required this.icono,
    required this.texto,
    required this.onPressed,
    required this.cargando,
    required this.habilitado,
    this.color = Colores.azul,
  });

  final IconData icono;
  final String texto;
  final VoidCallback onPressed;
  final bool cargando;
  final bool habilitado;

  /// Qué **tipo de desenlace** produce la acción, no si es reversible.
  ///
  /// Azul para las que dejan el pedido en curso (editar, pausar, reanudar,
  /// renovar), verde para cerrar —el trabajo se resolvió, que es el final
  /// bueno— y rojo para cancelar, que es dar de baja.
  ///
  /// Que cerrar sea irreversible **no lo hace rojo**: eso lo explica el
  /// diálogo, que además exige elegir un motivo. Pintarlo de rojo lo hacía
  /// leer como «eliminar» y contradecía al aviso de la misma pantalla, que
  /// dibuja un pedido cerrado en verde con un tilde.
  final Color color;

  @override
  Widget build(BuildContext context) {

    return OutlinedButton.icon(
      onPressed: habilitado ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      icon: cargando
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icono, size: 18),
      label: Text(texto),
    );
  }
}
