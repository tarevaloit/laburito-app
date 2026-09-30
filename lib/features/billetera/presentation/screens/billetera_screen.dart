import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/enlaces.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/barra_navegacion.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../data/billetera_repository.dart';
import '../../domain/movimiento_tokens.dart';
import '../../domain/pago.dart';
import '../../domain/paquete_tokens.dart';
import '../controllers/billetera_controller.dart';
import '../widgets/detalle_pago.dart';

/// CU-30 Consultar Saldo · CU-31 Cargar Tokens · CU-33 Historial de Pagos.
///
/// Figura 3.13: saldo grande, los packs, y abajo los movimientos. El historial
/// de pagos es la segunda solapa de esa misma lista, como pide el paso 1 del
/// CU-33 («selecciona la pestaña Historial de Pagos»).
///
/// [pagoId] llega cuando se vuelve del checkout de Mercado Pago por el enlace
/// `laburito://` que arma la Edge Function `retorno_pago`. La pantalla no le
/// cree nada a esa URL: relee el pago de la base hasta que el webhook lo
/// resuelva (CU-32).
class BilleteraScreen extends ConsumerStatefulWidget {
  const BilleteraScreen({super.key, this.pagoId});

  final String? pagoId;

  @override
  ConsumerState<BilleteraScreen> createState() => _BilleteraScreenState();
}

enum _Solapa { movimientos, pagos }

class _BilleteraScreenState extends ConsumerState<BilleteraScreen>
    with WidgetsBindingObserver {
  final _clavePaquetes = GlobalKey();
  _Solapa _solapa = _Solapa.movimientos;
  String? _comprando;

  /// El pago que se está siguiendo: el que llegó por la URL de retorno o el
  /// último que se abrió desde acá.
  String? _pagoEnCurso;

  @override
  void initState() {
    super.initState();
    _pagoEnCurso = widget.pagoId;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(BilleteraScreen anterior) {
    super.didUpdateWidget(anterior);
    if (widget.pagoId != null && widget.pagoId != anterior.pagoId) {
      setState(() => _pagoEnCurso = widget.pagoId);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Al volver a la app —desde el navegador, desde la app de Mercado Pago—
  /// se relee todo. Es el camino que funciona siempre, aunque el enlace
  /// `laburito://` no haya abierto la app.
  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed) _recargar();
  }

  Future<void> _recargar() async {
    ref.invalidate(historialPagosProvider);
    await ref.read(billeteraProvider.notifier).refrescar();
  }

  Future<void> _comprar(PaqueteTokens paquete) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pack ${paquete.nombre}'),
        content: Text(
          'Vas a comprar ${paquete.cantidad} tokens por '
          '${paquete.precioLegible}. El pago se hace en Mercado Pago; cuando '
          'se apruebe, los tokens aparecen solos en tu billetera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ir a pagar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _comprando = paquete.id);
    try {
      final compra =
          await ref.read(billeteraRepositoryProvider).iniciarCompra(paquete.id);
      if (!mounted) return;
      setState(() => _pagoEnCurso = compra.pagoId);

      final abierto = await abrirEnlace(compra.checkout);
      if (!abierto && mounted) {
        mostrarMensaje(context,
            'No pudimos abrir Mercado Pago. Probá de nuevo en un momento.');
      }
    } on Object catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _comprando = null);
    }
  }

  void _verPaquetes() {
    final destino = _clavePaquetes.currentContext;
    if (destino != null) {
      Scrollable.ensureVisible(destino,
          duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfil = ref.watch(perfilCompletoProvider).valueOrNull;
    final billetera = ref.watch(billeteraProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi billetera'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      bottomNavigationBar: BarraNavegacion.siCorresponde(
        actual: SeccionApp.billetera,
        mostrarBilletera: true,
      ),
      body: perfil != null && !perfil.esProfesional
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: AvisoEstado.pendiente(
                icono: Icons.account_balance_wallet_outlined,
                titulo: 'La billetera es de los Profesionales',
                detalle: 'Los tokens sirven para desbloquear el contacto de '
                    'un pedido. Publicar un pedido es gratis.',
              ),
            )
          : billetera.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: AvisoEstado.riesgo(
                  icono: Icons.wifi_off,
                  titulo: 'No pudimos cargar tu billetera',
                  detalle: MensajesError.desde(error),
                  accion: 'Reintentar',
                  onAccion: () => ref.invalidate(billeteraProvider),
                ),
              ),
              data: (estado) => RefreshIndicator(
                onRefresh: _recargar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    _TarjetaSaldo(
                      saldo: estado.saldo,
                      onComprar: _verPaquetes,
                    ),
                    if (estado.sinConexion) ...[
                      const SizedBox(height: 12),
                      const AvisoEstado.pendiente(
                        icono: Icons.wifi_off,
                        titulo: 'Sin conexión',
                        detalle: 'Te mostramos el último saldo que leímos. '
                            'Deslizá hacia abajo para actualizar.',
                      ),
                    ],
                    if (_pagoEnCurso != null) ...[
                      const SizedBox(height: 12),
                      _SeguimientoPago(
                        key: ValueKey(_pagoEnCurso),
                        pagoId: _pagoEnCurso!,
                        onCerrar: () => setState(() => _pagoEnCurso = null),
                      ),
                    ],
                    if (estado.saldoBajo && _pagoEnCurso == null) ...[
                      const SizedBox(height: 12),
                      Text(
                        estado.saldo == 0
                            ? 'No te quedan tokens. Cargá un pack para seguir '
                                'desbloqueando contactos.'
                            : 'Te quedan pocos tokens.',
                        style: const TextStyle(color: Colores.naranjaOscuro),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Elegí tu pack',
                      key: _clavePaquetes,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colores.texto,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Paquetes(
                      paquetes: estado.paquetes,
                      referencia: estado.paqueteDeReferencia,
                      comprando: _comprando,
                      onElegir: _comprar,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<_Solapa>(
                            segments: const [
                              ButtonSegment(
                                value: _Solapa.movimientos,
                                label: Text('Movimientos'),
                              ),
                              ButtonSegment(
                                value: _Solapa.pagos,
                                label: Text('Historial de pagos'),
                              ),
                            ],
                            selected: {_solapa},
                            showSelectedIcon: false,
                            onSelectionChanged: (s) =>
                                setState(() => _solapa = s.first),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            context.push('/profesional/billetera/canjear'),
                        icon: const Icon(Icons.confirmation_number_outlined,
                            size: 18),
                        label: const Text('Tengo un código'),
                      ),
                    ),
                    if (_solapa == _Solapa.movimientos)
                      _Movimientos(movimientos: estado.movimientos)
                    else
                      const _HistorialPagos(),
                  ],
                ),
              ),
            ),
    );
  }
}

class _TarjetaSaldo extends StatelessWidget {
  const _TarjetaSaldo({required this.saldo, required this.onComprar});

  final int saldo;
  final VoidCallback onComprar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Medidas.radioGrande),
        gradient: const LinearGradient(
          colors: [Colores.azul, Colores.azulMedio],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo disponible',
            style: TextStyle(color: Colores.textoSobreColor, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$saldo',
                key: const Key('saldo'),
                style: const TextStyle(
                  color: Colores.textoSobreColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                saldo == 1 ? 'token' : 'tokens',
                style: const TextStyle(
                  color: Colores.textoSobreColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onComprar,
            icon: const Icon(Icons.add),
            label: const Text('Comprar tokens'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          ),
        ],
      ),
    );
  }
}

class _Paquetes extends StatelessWidget {
  const _Paquetes({
    required this.paquetes,
    required this.referencia,
    required this.comprando,
    required this.onElegir,
  });

  final List<PaqueteTokens> paquetes;
  final PaqueteTokens? referencia;
  final String? comprando;
  final void Function(PaqueteTokens) onElegir;

  @override
  Widget build(BuildContext context) {
    if (paquetes.isEmpty) {
      return const Text(
        'No hay packs a la venta en este momento.',
        style: TextStyle(color: Colores.textoSecundario),
      );
    }

    return Row(
      children: [
        for (final (i, p) in paquetes.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _TarjetaPaquete(
              paquete: p,
              ahorro: referencia == null ? null : p.ahorroRespectoDe(referencia!),
              cargando: comprando == p.id,
              habilitado: comprando == null,
              onTap: () => onElegir(p),
            ),
          ),
        ],
      ],
    );
  }
}

class _TarjetaPaquete extends StatelessWidget {
  const _TarjetaPaquete({
    required this.paquete,
    required this.ahorro,
    required this.cargando,
    required this.habilitado,
    required this.onTap,
  });

  final PaqueteTokens paquete;
  final int? ahorro;
  final bool cargando;
  final bool habilitado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final destacado = ahorro != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colores.superficie,
          borderRadius: BorderRadius.circular(Medidas.radio),
          child: InkWell(
            borderRadius: BorderRadius.circular(Medidas.radio),
            onTap: habilitado ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Medidas.radio),
                border: Border.all(
                  color: destacado ? Colores.naranja : Colores.borde,
                  width: destacado ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(paquete.nombre,
                      style: const TextStyle(
                          fontSize: 12, color: Colores.textoSecundario)),
                  const SizedBox(height: 4),
                  Text(
                    '${paquete.cantidad}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colores.azul,
                    ),
                  ),
                  const Text('tokens',
                      style: TextStyle(
                          fontSize: 11, color: Colores.textoTenue)),
                  const SizedBox(height: 8),
                  cargando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          paquete.precioLegible,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colores.texto,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        if (destacado)
          Positioned(
            top: -9,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colores.naranja,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '−$ahorro %',
                style: const TextStyle(
                  color: Colores.textoSobreColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Movimientos extends StatelessWidget {
  const _Movimientos({required this.movimientos});

  final List<MovimientoTokens> movimientos;

  @override
  Widget build(BuildContext context) {
    if (movimientos.isEmpty) return const _Vacio();

    return TarjetaPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (final m in movimientos)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor:
                    m.esIngreso ? Colores.exitoSuave : Colores.errorSuave,
                child: Icon(
                  switch (m.tipo) {
                    TipoMovimiento.compra => Icons.add,
                    TipoMovimiento.cupon => Icons.confirmation_number_outlined,
                    TipoMovimiento.consumo => Icons.lock_open,
                  },
                  size: 16,
                  color: m.esIngreso ? Colores.exito : Colores.error,
                ),
              ),
              title: Text(m.descripcion,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(Fechas.conHora(m.fecha)),
              trailing: Text(
                m.cantidadLegible,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: m.esIngreso ? Colores.exito : Colores.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistorialPagos extends ConsumerWidget {
  const _HistorialPagos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historial = ref.watch(historialPagosProvider);

    return historial.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Text(MensajesError.desde(error)),
      data: (estado) {
        if (estado.pagos.isEmpty) return const _Vacio();

        return TarjetaPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final p in estado.pagos)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => mostrarDetallePago(context, p),
                  title: Text(p.concepto,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(Fechas.conHora(p.fecha)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(p.montoLegible,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      ChipEstadoPago(estado: p.estado),
                    ],
                  ),
                ),
              if (estado.hayMas)
                TextButton(
                  onPressed: estado.cargandoMas
                      ? null
                      : () =>
                          ref.read(historialPagosProvider.notifier).cargarMas(),
                  child: Text(estado.cargandoMas ? 'Cargando…' : 'Ver más'),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Flujo alterno del CU-33: el Profesional nuevo que nunca compró.
class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 48, color: Colores.textoTenue),
          SizedBox(height: 12),
          Text(
            'Aún no tienes movimientos en tu billetera',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colores.textoSecundario),
          ),
        ],
      ),
    );
  }
}

/// CU-32, pasos 5 y 6: el resultado del pago al volver de Mercado Pago.
///
/// Relee el pago cada tres segundos mientras siga pendiente, hasta un minuto:
/// el webhook suele llegar antes que la persona a la app, pero no siempre.
/// Cuando se resuelve, recarga el saldo.
class _SeguimientoPago extends ConsumerStatefulWidget {
  const _SeguimientoPago({
    super.key,
    required this.pagoId,
    required this.onCerrar,
  });

  final String pagoId;
  final VoidCallback onCerrar;

  @override
  ConsumerState<_SeguimientoPago> createState() => _SeguimientoPagoState();
}

class _SeguimientoPagoState extends ConsumerState<_SeguimientoPago> {
  static const _intervalo = Duration(seconds: 3);
  static const _intentosMaximos = 20;

  Timer? _timer;
  Pago? _pago;
  int _intentos = 0;

  @override
  void initState() {
    super.initState();
    _consultar();
    _timer = Timer.periodic(_intervalo, (_) => _consultar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _consultar() async {
    _intentos++;
    try {
      final pago =
          await ref.read(billeteraRepositoryProvider).pago(widget.pagoId);
      if (!mounted) return;
      final resuelto = pago != null && pago.estado != EstadoPago.pendiente;
      setState(() => _pago = pago);

      if (resuelto) {
        _timer?.cancel();
        ref.invalidate(historialPagosProvider);
        await ref.read(billeteraProvider.notifier).refrescar();
      }
    } on Object {
      // Un fallo de red en el medio no corta el seguimiento: el próximo tick
      // lo vuelve a intentar.
    }
    if (_intentos >= _intentosMaximos) _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final pago = _pago;
    final siguiendo = _timer?.isActive ?? false;

    final aviso = switch (pago?.estado) {
      EstadoPago.aprobado => AvisoEstado.exito(
          icono: Icons.check_circle,
          titulo: '¡Pago aprobado!',
          detalle: 'Se acreditaron ${pago!.cantidadTokens} tokens en tu '
              'billetera. Ya podés desbloquear contactos.',
          accion: 'Entendido',
          onAccion: widget.onCerrar,
        ),
      EstadoPago.rechazado || EstadoPago.cancelado => AvisoEstado.riesgo(
          icono: Icons.error_outline,
          titulo: 'El pago no se completó',
          detalle: '${pago!.motivoLegible ?? 'Mercado Pago no aprobó el pago.'} '
              'No se acreditó ningún token.',
          accion: 'Entendido',
          onAccion: widget.onCerrar,
        ),
      _ => AvisoEstado.pendiente(
          icono: Icons.hourglass_top_rounded,
          titulo: siguiendo
              ? 'Esperando la confirmación de Mercado Pago…'
              : 'El pago sigue pendiente',
          detalle: siguiendo
              ? 'Si ya pagaste, los tokens aparecen en unos segundos.'
              : 'Cuando Mercado Pago lo confirme, los tokens se acreditan '
                  'solos. Podés cerrar este aviso.',
          accion: siguiendo ? null : 'Cerrar',
          onAccion: siguiendo ? null : widget.onCerrar,
        ),
    };

    return aviso;
  }
}
