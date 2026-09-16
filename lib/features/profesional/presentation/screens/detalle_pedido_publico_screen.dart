import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../pedidos/data/urls_firmadas.dart';
import '../../../pedidos/presentation/widgets/mini_mapa_pedido.dart';
import '../../data/tablero_repository.dart';
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
      appBar: AppBar(title: const Text('Detalle del pedido')),
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

/// CU-24 y CU-23 desde el detalle. Son las dos mismas acciones de la tarjeta
/// del tablero: no hay una tercera cosa que el Profesional pueda hacer con un
/// pedido ajeno hasta el Sprint 4, cuando exista la postulación.
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
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(MensajesError.desde(error))));
      }
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;
    final repo = ref.read(tableroRepositoryProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _trabajando
                    ? null
                    : () => _hacer(() async {
                          // El Navigator se toma antes del await: después del
                          // `await` el context puede no servir más, y el
                          // analizador tiene razón en desconfiar.
                          final navegador = Navigator.of(context);
                          await repo.ignorar(pedido.id);
                          // Se vuelve al tablero: el pedido ya no está ahí, y
                          // quedarse mirándolo sería raro.
                          ref.invalidate(tableroProvider);
                          await navegador.maybePop();
                        }),
                icon: const Icon(Icons.visibility_off_outlined),
                label: const Text('No me interesa'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BotonPrincipal(
                texto: pedido.guardado ? 'Guardado' : 'Guardar',
                icono: pedido.guardado
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                cargando: _trabajando,
                onPressed: () => _hacer(() async {
                  await repo.guardar(pedido.id, guardado: !pedido.guardado);
                  ref.invalidate(pedidoPublicoProvider(pedido.id));
                  ref.invalidate(tableroProvider);
                }),
              ),
            ),
          ],
        ),
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
          'La ubicación es aproximada. La dirección exacta se comparte al '
          'tomar el trabajo.',
          style: TextStyle(fontSize: 12, color: Colores.textoTenue),
        ),
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
