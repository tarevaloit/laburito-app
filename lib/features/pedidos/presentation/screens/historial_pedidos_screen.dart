import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../data/urls_firmadas.dart';
import '../../domain/pedido_estado.dart';
import '../controllers/historial_pedidos_controller.dart';
import '../widgets/tarjeta_pedido.dart';

/// CU-17 — Consultar Historial. Es el home del Buscador logueado.
///
/// Desde acá se llega al detalle de cada pedido, que es donde viven las
/// acciones del ciclo de vida (Fase 6). Sin esta pantalla, a un pedido solo se
/// llegaba recién publicado.
class HistorialPedidosScreen extends ConsumerStatefulWidget {
  const HistorialPedidosScreen({super.key});

  @override
  ConsumerState<HistorialPedidosScreen> createState() =>
      _HistorialPedidosScreenState();
}

class _HistorialPedidosScreenState
    extends ConsumerState<HistorialPedidosScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alScrollear);
  }

  @override
  void dispose() {
    _scroll.removeListener(_alScrollear);
    _scroll.dispose();
    super.dispose();
  }

  /// Pide la página siguiente cuando falta poco para el final.
  ///
  /// El umbral es de 400 px y no del final exacto: pedirla al tocar el fondo
  /// deja al usuario mirando un indicador de carga. El control de «ya hay una
  /// en vuelo» está en el controlador, no acá: el scroll dispara este callback
  /// decenas de veces por segundo.
  void _alScrollear() {
    if (!_scroll.hasClients) return;
    final falta = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (falta < 400) {
      ref.read(historialPedidosProvider.notifier).cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    // «Mis pedidos» es del Buscador. Un Profesional no tiene pedidos propios:
    // tiene el tablero. Mismo criterio que el asistente del CU-13, que valida
    // el rol adentro de la pantalla porque el `redirect` del router no puede
    // leer el perfil de forma síncrona (decisión del 03/09).
    final perfil = ref.watch(perfilCompletoProvider).valueOrNull;
    if (perfil != null && perfil.esProfesional) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis pedidos')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AvisoEstado.riesgo(
                icono: Icons.info_outline,
                titulo: 'Esta sección es para cuentas Buscador',
                detalle: 'Con una cuenta Profesional no se publican pedidos: '
                    'se responde a los que publican otros.',
              ),
              const SizedBox(height: 16),
              BotonPrincipal(
                texto: 'Ver pedidos cerca mío',
                icono: Icons.explore_outlined,
                onPressed: () => context.go('/profesional/tablero'),
              ),
            ],
          ),
        ),
      );
    }

    final async = ref.watch(historialPedidosProvider);
    final controlador = ref.read(historialPedidosProvider.notifier);

    ref.listen(historialPedidosProvider, (anterior, siguiente) {
      final error = siguiente.valueOrNull?.error;
      if (error != null && error != anterior?.valueOrNull?.error) {
        mostrarMensaje(context, error.message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        // Al historial se llega con `context.go` desde el home, así que no hay
        // nada que desapilar y la flecha de Material no aparece sola. Sin este
        // botón, la única salida en la web es el botón «atrás» del navegador,
        // y en Android el gesto de retroceso, que acá cierra la app.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver al inicio',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Publicar un pedido',
            onPressed: () => context.go('/pedidos/nuevo'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              MensajesError.desde(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colores.textoSecundario),
            ),
          ),
        ),
        data: (estado) => Column(
          children: [
            _Buscador(
              onCambio: controlador.buscar,
              filtrando: estado.filtrandoPorTexto,
            ),
            _Filtros(
              actual: estado.filtro,
              contar: estado.contar,
              onElegir: controlador.cambiarFiltro,
            ),
            Expanded(
              child: RefreshIndicator(
                // Pull to refresh: corre el barrido de vencimientos antes de
                // leer, así el estado guardado y la realidad no se separan.
                onRefresh: controlador.refrescar,
                child: estado.pedidos.isEmpty
                    ? _Vacio(estado: estado)
                    : _Lista(estado: estado, scroll: _scroll),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Búsqueda y filtros
// ----------------------------------------------------------------------------

class _Buscador extends StatelessWidget {
  const _Buscador({required this.onCambio, required this.filtrando});

  final ValueChanged<String> onCambio;
  final bool filtrando;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: CampoTexto(
        etiqueta: 'Buscar',
        ejemplo: 'Título o descripción',
        icono: Icons.search,
        ayuda: filtrando ? 'Filtrando por texto' : null,
        onChanged: onCambio,
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({
    required this.actual,
    required this.contar,
    required this.onElegir,
  });

  final FiltroPedidos actual;
  final int Function(FiltroPedidos) contar;
  final ValueChanged<FiltroPedidos> onElegir;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          for (final filtro in FiltroPedidos.values) ...[
            if (filtro != FiltroPedidos.values.first) const SizedBox(width: 8),
            ChoiceChip(
              // El contador va en la etiqueta y no en un globo aparte: es el
              // dato que decide si vale la pena tocar la pestaña.
              label: Text('${filtro.etiqueta} (${contar(filtro)})'),
              selected: actual == filtro,
              onSelected: (_) => onElegir(filtro),
            ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Lista
// ----------------------------------------------------------------------------

class _Lista extends ConsumerStatefulWidget {
  const _Lista({required this.estado, required this.scroll});

  final EstadoHistorial estado;
  final ScrollController scroll;

  @override
  ConsumerState<_Lista> createState() => _ListaState();
}

class _ListaState extends ConsumerState<_Lista> {
  Map<String, String> _urls = const {};

  @override
  void initState() {
    super.initState();
    _firmar();
  }

  @override
  void didUpdateWidget(_Lista anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.estado.pedidos.length != widget.estado.pedidos.length) {
      _firmar();
    }
  }

  /// Firma **todas** las portadas de la página en una sola llamada.
  ///
  /// Es la razón de ser de `UrlsFirmadas`: veinte pedidos por página son
  /// veinte firmas sueltas si se pide de a una, y una si se piden juntas. Las
  /// ya vigentes salen del caché sin viajar.
  Future<void> _firmar() async {
    final rutas = [
      for (final pedido in widget.estado.pedidos)
        if (pedido.portada != null) pedido.portada!.storagePath,
    ];
    if (rutas.isEmpty) return;

    final urls = await ref.read(urlsFirmadasProvider).resolver(rutas);
    if (mounted) setState(() => _urls = urls);
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = widget.estado.pedidos;

    return ListView.separated(
      controller: widget.scroll,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      // Siempre desplazable: si no, con pocos pedidos no habría gesto que
      // disparara el pull to refresh.
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: pedidos.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == pedidos.length) return _PieDeLista(estado: widget.estado);

        final pedido = pedidos[i];
        return TarjetaPedido(
          pedido: pedido,
          urlPortada: _urls[pedido.portada?.storagePath],
          onTap: () => context.push('/pedidos/${pedido.id}'),
        );
      },
    );
  }
}

class _PieDeLista extends StatelessWidget {
  const _PieDeLista({required this.estado});

  final EstadoHistorial estado;

  @override
  Widget build(BuildContext context) {
    if (estado.cargandoMas) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (estado.hayMas) return const SizedBox(height: 24);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          estado.pedidos.length == 1
              ? 'Un pedido en este grupo'
              : '${estado.pedidos.length} pedidos en este grupo',
          style: const TextStyle(fontSize: 12, color: Colores.textoTenue),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Vacío
// ----------------------------------------------------------------------------

/// Dos pantallas vacías distintas, con salidas distintas.
///
/// «Todavía no publicaste nada» pide un botón para publicar; «no encontramos
/// nada con ese texto» pide borrar la búsqueda. Ofrecer «Publicar un pedido»
/// a alguien que acaba de buscar «termotanque» no lo ayuda en nada.
class _Vacio extends StatelessWidget {
  const _Vacio({required this.estado});

  final EstadoHistorial estado;

  @override
  Widget build(BuildContext context) {
    final buscando = estado.filtrandoPorTexto;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        Icon(
          buscando ? Icons.search_off : Icons.assignment_outlined,
          size: 56,
          color: Colores.textoTenue,
        ),
        const SizedBox(height: 16),
        Text(
          buscando
              ? 'No encontramos pedidos con ese texto'
              : _tituloSegunFiltro(estado.filtro),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colores.azul,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          buscando
              ? 'Probá con otras palabras, o mirá otro grupo.'
              : _detalleSegunFiltro(estado.filtro),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colores.textoSecundario, height: 1.4),
        ),
        const SizedBox(height: 24),
        if (!buscando)
          BotonPrincipal(
            texto: 'Publicar un pedido',
            icono: Icons.add_circle_outline,
            onPressed: () => context.go('/pedidos/nuevo'),
          ),
      ],
    );
  }

  static String _tituloSegunFiltro(FiltroPedidos filtro) => switch (filtro) {
        FiltroPedidos.activos => 'Todavía no tenés pedidos activos',
        FiltroPedidos.vencidos => 'No tenés pedidos vencidos',
        FiltroPedidos.cerrados => 'Todavía no cerraste ningún pedido',
        FiltroPedidos.cancelados => 'No cancelaste ningún pedido',
      };

  static String _detalleSegunFiltro(FiltroPedidos filtro) => switch (filtro) {
        FiltroPedidos.activos =>
          'Publicá lo que necesitás y los profesionales de tu zona van a poder '
              'verlo.',
        FiltroPedidos.vencidos =>
          'Acá van a aparecer los pedidos que pasen su fecha. Se pueden '
              'renovar.',
        FiltroPedidos.cerrados =>
          'Cuando marques un pedido como resuelto, va a quedar acá.',
        FiltroPedidos.cancelados =>
          'Los pedidos que des de baja van a quedar acá.',
      };
}
