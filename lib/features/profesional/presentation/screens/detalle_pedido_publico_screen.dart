import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/enlaces.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../billetera/presentation/controllers/billetera_controller.dart';
import '../../../pedidos/data/urls_firmadas.dart';
import '../../../pedidos/presentation/widgets/mini_mapa_pedido.dart';
import '../../../reputacion/domain/calificacion.dart';
import '../../../reputacion/presentation/pedir_calificacion.dart';
import '../../data/contacto_repository.dart';
import '../../data/tablero_repository.dart';
import '../../domain/contacto_buscador.dart';
import '../../domain/pedido_tablero.dart';
import '../controllers/tablero_controller.dart';

/// CU-22 — Ver Detalle de Pedido, del lado del Profesional.
///
/// Las mismas secciones que ve el Buscador en `detalle_pedido_screen` —fotos,
/// encabezado, descripción, mapa, datos— **sin la barra de acciones del
/// dueño**, que no tiene sentido acá: pausar, cerrar o renovar son del que
/// publicó.
///
/// **Desvío respecto del plan**, que pedía derivar aquella pantalla con un
/// modo lectura. Aquella se construye sobre el modelo `Pedido`, que sale de la
/// tabla `pedidos` y trae la ubicación exacta y la referencia —piso y
/// departamento—. Reutilizarla obligaba a que el Profesional leyera esa fila,
/// que es justo lo que `pedidos_publicos` evita. Esta pantalla se construye
/// sobre [PedidoTablero], que no tiene esos datos ni puede tenerlos. Lo que sí
/// se reutiliza son los widgets: el mini mapa y las URLs firmadas.
class DetallePedidoPublicoScreen extends ConsumerWidget {
  const DetallePedidoPublicoScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidoAsync = ref.watch(pedidoPublicoProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del pedido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Sin nada que desapilar —se entró por un enlace o la app se abrió
          // desde la notificación— se vuelve al tablero, que es de donde se
          // llega a un pedido ajeno. Nunca a «Mis pedidos»: esa pantalla es
          // del Buscador.
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/profesional/tablero'),
        ),
      ),
      body: pedidoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No pudimos cargar el pedido: $e'),
        ),
        data: (pedido) {
          if (pedido == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: AvisoEstado.pendiente(
                icono: Icons.event_busy,
                titulo: 'Este pedido ya no está disponible',
                detalle: 'Puede haberse cerrado, cancelado o vencido mientras '
                    'lo mirabas. Volvé al tablero: hay otros.',
              ),
            );
          }

          return _Detalle(pedido: pedido);
        },
      ),
      bottomNavigationBar: pedidoAsync.valueOrNull == null
          ? null
          : _Acciones(pedido: pedidoAsync.value!),
    );
  }
}

/// La barra del detalle: el desbloqueo del contacto (CU-25) como acción
/// principal, como en la Figura 3.12, y al costado las dos marcas del tablero
/// —no me interesa (CU-23) y guardar (CU-24)— en versión ícono.
class _Acciones extends ConsumerStatefulWidget {
  const _Acciones({required this.pedido});

  final PedidoTablero pedido;

  @override
  ConsumerState<_Acciones> createState() => _AccionesState();
}

class _AccionesState extends ConsumerState<_Acciones> {
  bool _trabajando = false;

  Future<void> _hacer(Future<void> Function() accion) async {
    setState(() => _trabajando = true);
    try {
      await accion();
    } on SaldoInsuficienteException {
      if (mounted) await _ofrecerCompra();
    } on Object catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  /// Flujo alterno 1.2 del CU-25: sin tokens, la acción se bloquea y se ofrece
  /// ir a comprar.
  Future<void> _ofrecerCompra() async {
    final comprar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.account_balance_wallet_outlined,
            color: Colores.naranja, size: 36),
        title: const Text('No te quedan tokens'),
        content: const Text(
          'Para ver el teléfono del Buscador necesitás 1 token. Cargá un pack '
          'desde tu billetera y volvé a este pedido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Comprar tokens'),
          ),
        ],
      ),
    );
    if (comprar == true && mounted) context.push('/profesional/billetera');
  }

  Future<void> _desbloquear(int saldo) async {
    if (saldo < 1) return _ofrecerCompra();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desbloquear contacto'),
        content: Text(
          'Vas a usar 1 token de tu saldo y te van a quedar ${saldo - 1}. '
          'Vas a ver el teléfono del Buscador para escribirle por WhatsApp. '
          'Si ya lo desbloqueaste antes, no se cobra de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Usar 1 token'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    await _hacer(() async {
      final resultado = await ref
          .read(contactoRepositoryProvider)
          .desbloquear(widget.pedido.id);
      ref.invalidate(contactoPedidoProvider(widget.pedido.id));
      ref.read(billeteraProvider.notifier).saldoActualizado(resultado.saldo);
      if (mounted) {
        mostrarMensaje(
          context,
          resultado.cobrado
              ? 'Listo: ya podés escribirle a ${resultado.contacto.nombreCorto}.'
              : 'Ya tenías este contacto: no se te cobró nada.',
          esError: false,
        );
      }
    });
  }

  Future<void> _escribir(ContactoBuscador contacto) async {
    final enlace = contacto.enlaceWhatsApp(tituloPedido: widget.pedido.titulo);
    if (enlace == null) {
      mostrarMensaje(
        context,
        'No pudimos armar el enlace de WhatsApp con ${contacto.telefono}. '
        'Probá llamando a ese número.',
      );
      return;
    }
    final abierto = await abrirEnlace(enlace);
    if (!abierto && mounted) {
      mostrarMensaje(context, 'No pudimos abrir WhatsApp.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;
    final repo = ref.read(tableroRepositoryProvider);
    final contacto = ref.watch(contactoPedidoProvider(pedido.id)).valueOrNull;
    final saldo = ref.watch(billeteraProvider).valueOrNull?.saldo;
    final desbloqueado = contacto?.desbloqueado ?? false;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!desbloqueado && saldo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: 'Vas a usar '),
                          const TextSpan(
                            text: '1 token',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: saldo > 0
                                ? ' · te quedan $saldo'
                                : ' · no te quedan tokens',
                          ),
                        ]),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colores.textoSecundario,
                        ),
                      ),
                    ),
                    const Icon(Icons.toll, size: 16, color: Colores.naranja),
                    const SizedBox(width: 4),
                    Text('$saldo',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton.outlined(
                  tooltip: 'No me interesa',
                  onPressed: _trabajando
                      ? null
                      : () => _hacer(() async {
                            // El Navigator se toma antes del await: después
                            // del `await` el context puede no servir más.
                            final navegador = Navigator.of(context);
                            await repo.ignorar(pedido.id);
                            // Se vuelve al tablero: el pedido ya no está ahí.
                            ref.invalidate(tableroProvider);
                            await navegador.maybePop();
                          }),
                  icon: const Icon(Icons.visibility_off_outlined),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: pedido.guardado ? 'Quitar de guardados' : 'Guardar',
                  onPressed: _trabajando
                      ? null
                      : () => _hacer(() async {
                            await repo.guardar(pedido.id,
                                guardado: !pedido.guardado);
                            ref.invalidate(pedidoPublicoProvider(pedido.id));
                            ref.invalidate(tableroProvider);
                          }),
                  icon: Icon(pedido.guardado
                      ? Icons.bookmark
                      : Icons.bookmark_border),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: desbloqueado
                      ? BotonPrincipal(
                          texto: 'Escribir por WhatsApp',
                          icono: Icons.chat_outlined,
                          onPressed: () => _escribir(contacto!),
                        )
                      : BotonPrincipal(
                          texto: 'Desbloquear · 1 token',
                          icono: Icons.lock_open_outlined,
                          cargando: _trabajando,
                          onPressed: contacto == null || saldo == null
                              ? null
                              : () => _desbloquear(saldo),
                        ),
                ),
              ],
            ),
            // CU-28. Al terminar el trabajo; también desde «Mis contactos»,
            // que sigue mostrando el contacto después de que el Buscador
            // cierre el pedido.
            if (desbloqueado)
              TextButton.icon(
                onPressed: _trabajando
                    ? null
                    : () => _hacer(() async {
                          await pedirCalificacion(
                            context,
                            ref,
                            MiContacto(
                              pedidoId: pedido.id,
                              titulo: pedido.titulo,
                              estadoPedido: 'publicado',
                              nombreCorto: contacto!.nombreCorto,
                              telefono: contacto.telefono,
                              desbloqueadoAt: DateTime.now(),
                            ),
                          );
                        }),
                icon: const Icon(Icons.star_outline_rounded, size: 18),
                label: const Text('¿Terminaste el trabajo? Pedí tu calificación'),
              ),
          ],
        ),
      ),
    );
  }
}

/// «Datos del Buscador» de la Figura 3.12: el nombre corto y el teléfono
/// enmascarado, o entero si ya se desbloqueó.
class _DatosDelBuscador extends ConsumerWidget {
  const _DatosDelBuscador({required this.pedidoId});

  final String pedidoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacto = ref.watch(contactoPedidoProvider(pedidoId)).valueOrNull;
    if (contacto == null) return const SizedBox.shrink();

    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATOS DEL BUSCADOR',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              color: Colores.textoTenue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colores.azulSuave,
                child: Text(
                  contacto.nombreCorto.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Colores.azul,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contacto.nombreCorto,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          contacto.desbloqueado
                              ? Icons.phone_outlined
                              : Icons.lock_outline,
                          size: 14,
                          color: Colores.textoSecundario,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          contacto.desbloqueado
                              ? (contacto.telefono ?? 'Sin teléfono')
                              : (contacto.telefonoEnmascarado ??
                                  'Sin teléfono'),
                          key: const Key('telefono-buscador'),
                          style: const TextStyle(
                              color: Colores.textoSecundario),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.pedido});

  final PedidoTablero pedido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (pedido.fotos.isNotEmpty) ...[
          _Fotos(rutas: pedido.fotos),
          const SizedBox(height: 16),
        ],
        Text(
          pedido.titulo,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colores.azul,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(
              label: Text(pedido.categoriaNombre),
              backgroundColor: Colores.naranjaSuave,
              side: BorderSide.none,
            ),
            const SizedBox(width: 8),
            if (pedido.distanciaLegible != null)
              Text(
                pedido.distanciaLegible!,
                style: const TextStyle(color: Colores.textoSecundario),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TarjetaPanel(
          child: Text(
            pedido.descripcion,
            style: const TextStyle(height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        MiniMapaPedido(ubicacion: pedido.ubicacionAproximada),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.place_outlined,
                size: 16, color: Colores.textoTenue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                pedido.ubicacionAproximada.direccionTexto,
                style: const TextStyle(color: Colores.textoSecundario),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'La ubicación es aproximada. La dirección exacta la acordás con el '
          'Buscador cuando lo contactes.',
          style: TextStyle(fontSize: 12, color: Colores.textoTenue),
        ),
        const SizedBox(height: 16),
        _DatosDelBuscador(pedidoId: pedido.id),
        const SizedBox(height: 16),
        TarjetaPanel(
          child: Column(
            children: [
              _Fila(
                'Presupuesto estimado',
                pedido.presupuestoEstimado == null
                    ? 'Sin definir'
                    : '\$ ${pedido.presupuestoEstimado!.toStringAsFixed(0)}',
              ),
              _Fila('Urgencia', pedido.urgencia.etiqueta),
              _Fila('Publicado', Fechas.hace(pedido.fechaPublicacion)),
              _Fila('Vigencia', Fechas.vigencia(pedido.fechaVencimiento)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Fotos extends ConsumerWidget {
  const _Fotos({required this.rutas});

  final List<String> rutas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 200,
      child: FutureBuilder<Map<String, String>>(
        // Las firmas se piden en lote, como en el historial del CU-17: una
        // galería de cinco fotos son cinco viajes si se firman de a una.
        future: ref.read(urlsFirmadasProvider).resolver(rutas),
        builder: (context, snapshot) {
          final urls = snapshot.data ?? const <String, String>{};

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: rutas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final url = urls[rutas[i]];

              return ClipRRect(
                borderRadius: BorderRadius.circular(Medidas.radioGrande),
                child: Container(
                  width: 280,
                  color: Colores.azulSuave,
                  child: url == null
                      ? const Center(child: CircularProgressIndicator())
                      : Image.network(url, fit: BoxFit.cover),
                ),
              );
            },
          );
        },
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: const TextStyle(color: Colores.textoSecundario)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
