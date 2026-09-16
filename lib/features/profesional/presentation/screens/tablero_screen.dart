import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../../core/utils/fechas.dart';
import '../../../pedidos/data/urls_firmadas.dart';
import '../../../pedidos/domain/pedido_estado.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../domain/pedido_tablero.dart';
import '../controllers/tablero_controller.dart';

/// CU-43 — Explorar Tablero de Pedidos.
///
/// Es el home del Profesional: los pedidos vigentes ordenados por distancia a
/// su zona de cobertura. El orden lo hace el servidor (migración 0018), no
/// esta pantalla.
class TableroScreen extends ConsumerStatefulWidget {
  const TableroScreen({super.key});

  @override
  ConsumerState<TableroScreen> createState() => _TableroScreenState();
}

class _TableroScreenState extends ConsumerState<TableroScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Se pide la página siguiente 400 px antes del final, igual que el
    // historial del CU-17: el listado no tiene que llegar a quedarse vacío
    // para que aparezca el spinner.
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 400) {
        ref.read(tableroProvider.notifier).cargarMas();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilCompletoProvider);
    final tableroAsync = ref.watch(tableroProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos cerca tuyo')),
      body: perfilAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('No pudimos cargar tu perfil.')),
        data: (perfil) {
          if (perfil == null || !perfil.esProfesional) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: AvisoEstado.riesgo(
                icono: Icons.info_outline,
                titulo: 'El tablero es para cuentas Profesional',
                detalle: 'Con una cuenta Buscador se publican pedidos, no se '
                    'responden. Publicá el tuyo desde el inicio.',
              ),
            );
          }

          return tableroAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No pudimos cargar el tablero: $e'),
            ),
            data: _contenido,
          );
        },
      ),
    );
  }

  Widget _contenido(EstadoTablero estado) {
    final controlador = ref.read(tableroProvider.notifier);

    return Column(
      children: [
        _filtros(estado, controlador),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controlador.refrescar,
            child: estado.vacio
                ? _vacio(estado)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: estado.pedidos.length + (estado.hayMas ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= estado.pedidos.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final pedido = estado.pedidos[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TarjetaTablero(
                          pedido: pedido,
                          onTap: () =>
                              context.push('/profesional/pedidos/${pedido.id}'),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _filtros(EstadoTablero estado, Tablero controlador) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (final filtro in FiltroTablero.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filtro.etiqueta),
                selected: estado.filtro == filtro,
                onSelected: (_) => controlador.cambiarFiltro(filtro),
              ),
            ),
        ],
      ),
    );
  }

  Widget _vacio(EstadoTablero estado) {
    // Dos vacíos distintos, como en el historial del CU-17: uno se corrige
    // configurando algo y el otro solo esperando.
    final (titulo, detalle, accion) = switch (estado.filtro) {
      FiltroTablero.guardados => (
          'Todavía no guardaste ningún pedido',
          'Guardá los que te interesen y los encontrás acá.',
          null,
        ),
      _ => (
          'Por ahora no hay pedidos cerca',
          'Revisá tu zona de cobertura y tus oficios: son los que deciden qué '
              'pedidos te mostramos.',
          '/profesional/zona',
        ),
    };

    return ListView(
      // Una lista y no un Center: el RefreshIndicator necesita algo que se
      // pueda arrastrar aunque no haya contenido.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.inbox_outlined, size: 48, color: Colores.textoTenue),
        const SizedBox(height: 16),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colores.azul,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detalle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colores.textoSecundario),
        ),
        if (accion != null) ...[
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => context.push(accion),
              icon: const Icon(Icons.travel_explore),
              label: const Text('Configurar mi zona'),
            ),
          ),
        ],
        if (estado.error != null) ...[
          const SizedBox(height: 20),
          Text(
            estado.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colores.error),
          ),
        ],
      ],
    );
  }
}

/// La tarjeta del tablero. No se reutiliza `TarjetaPedido` del CU-17: aquella
/// muestra el **estado** del pedido propio —pausado, vencido, cerrado— y acá
/// todos los pedidos están publicados. Lo que importa es otra cosa: a qué
/// distancia está y de qué oficio es.
class _TarjetaTablero extends ConsumerWidget {
  const _TarjetaTablero({required this.pedido, required this.onTap});

  final PedidoTablero pedido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radio = BorderRadius.circular(Medidas.radioGrande);

    return Material(
      color: Colores.superficie,
      borderRadius: radio,
      child: InkWell(
        borderRadius: radio,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Portada(pedido: pedido),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pedido.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colores.azul,
                            ),
                          ),
                        ),
                        if (pedido.guardado)
                          const Icon(Icons.bookmark,
                              size: 18, color: Colores.naranja),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pedido.categoriaNombre,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colores.naranja,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pedido.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colores.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (pedido.distanciaLegible != null)
                          _Dato(
                            icono: Icons.near_me_outlined,
                            texto: pedido.distanciaLegible!,
                          ),
                        _Dato(
                          icono: Icons.schedule,
                          texto: Fechas.hace(pedido.fechaPublicacion),
                        ),
                        if (pedido.urgencia == PedidoUrgencia.alta)
                          _Dato(
                            icono: Icons.priority_high,
                            texto: pedido.urgencia.etiqueta,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Portada extends ConsumerWidget {
  const _Portada({required this.pedido});

  final PedidoTablero pedido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radio = BorderRadius.circular(Medidas.radio);
    const lado = 72.0;

    if (pedido.portada == null) {
      return Container(
        width: lado,
        height: lado,
        decoration: BoxDecoration(color: Colores.azulSuave, borderRadius: radio),
        child: const Icon(Icons.handyman_outlined, color: Colores.azul),
      );
    }

    return FutureBuilder<Map<String, String>>(
      future: ref.read(urlsFirmadasProvider).resolver([pedido.portada!]),
      builder: (context, snapshot) {
        final url = snapshot.data?[pedido.portada!];

        return ClipRRect(
          borderRadius: radio,
          child: SizedBox(
            width: lado,
            height: lado,
            child: url == null
                ? Container(color: Colores.azulSuave)
                : Image.network(url, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: Colores.textoTenue),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(fontSize: 12, color: Colores.textoTenue),
        ),
      ],
    );
  }
}
