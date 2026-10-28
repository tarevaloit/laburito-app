import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/descargas/descarga.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/dinero.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/admin_repository.dart';
import '../../domain/dashboard.dart';
import 'panel_admin.dart';

/// CU-38 — Consultar Estadísticas (Figura 3.20). Es la pantalla a la que
/// lleva el ingreso al panel (CU-34, paso 6).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, this.hoy});

  /// Para las pruebas: el «hoy» del que salen los rangos rápidos.
  final DateTime? hoy;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late DateTime _desde;
  late DateTime _hasta;
  String _etiqueta = RangoDashboard.mes.etiqueta;

  DateTime get _hoy => widget.hoy ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    final (desde, hasta) = RangoDashboard.mes.rango(_hoy);
    _desde = desde;
    _hasta = hasta;
  }

  Future<void> _elegirRango(Object? opcion) async {
    if (opcion is RangoDashboard) {
      final (desde, hasta) = opcion.rango(_hoy);
      setState(() {
        _desde = desde;
        _hasta = hasta;
        _etiqueta = opcion.etiqueta;
      });
      return;
    }

    // Paso 1: «el rango de fechas que desea analizar utilizando el
    // calendario». Desde 2024 para poder probar el flujo alterno 1.1.
    final elegido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: _hoy,
      initialDateRange: DateTimeRange(start: _desde, end: _hasta),
      helpText: 'Rango a analizar',
    );
    if (elegido == null) return;
    setState(() {
      _desde = elegido.start;
      _hasta = elegido.end;
      _etiqueta = '${Fechas.corta(_desde)} al ${Fechas.corta(_hasta)}';
    });
  }

  Future<void> _exportar(Dashboard d) async {
    final nombre = 'laburito-reporte-${d.desde.toIso8601String().substring(0, 10)}'
        '-al-${d.hasta.toIso8601String().substring(0, 10)}.csv';
    final ok = await descargarTexto(nombre: nombre, contenido: d.aCsv());
    if (!mounted) return;
    mostrarMensaje(
      context,
      ok
          ? 'Se descargó $nombre.'
          : 'La exportación está disponible en el panel web.',
      esError: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final datos = ref.watch(dashboardAdminProvider(_desde, _hasta));

    return PanelAdmin(
      actual: SeccionAdmin.dashboard,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardAdminProvider(_desde, _hasta).future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              spacing: 12,
              children: [
                const EncabezadoAdmin(
                  titulo: 'Panel de control',
                  bajada: 'Resumen general de la plataforma',
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    PopupMenuButton<Object>(
                      key: const Key('rango-dashboard'),
                      onSelected: _elegirRango,
                      itemBuilder: (_) => [
                        for (final r in RangoDashboard.values)
                          PopupMenuItem(value: r, child: Text(r.etiqueta)),
                        const PopupMenuItem(
                          value: 'calendario',
                          child: Text('Elegir fechas…'),
                        ),
                      ],
                      child: _BotonRango(etiqueta: _etiqueta),
                    ),
                    OutlinedButton.icon(
                      key: const Key('exportar-dashboard'),
                      onPressed: datos.valueOrNull == null
                          ? null
                          : () => _exportar(datos.value!),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Exportar'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...datos.when(
              skipLoadingOnReload: true,
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (e, _) => [
                AvisoEstado.riesgo(
                  icono: Icons.error_outline,
                  titulo: 'No pudimos cargar las estadísticas',
                  detalle: MensajesError.desde(e),
                ),
              ],
              data: (d) => [
                if (d.sinActividad) ...[
                  const AvisoEstado.pendiente(
                    icono: Icons.info_outline,
                    titulo: 'No hubo actividad en este rango',
                    detalle: 'Las tarjetas y los gráficos se muestran en cero.',
                  ),
                  const SizedBox(height: 16),
                ],
                _Tarjetas(datos: d),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, r) {
                    final barras = _GraficoAltas(meses: d.altasPorMes);
                    final torta = _GraficoPacks(packs: d.ingresosPorPack);
                    if (r.maxWidth < 860) {
                      return Column(
                        children: [barras, const SizedBox(height: 20), torta],
                      );
                    }
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: barras),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: torta),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _AccesosRecientes(),
          ],
        ),
      ),
    );
  }
}

class _BotonRango extends StatelessWidget {
  const _BotonRango({required this.etiqueta});

  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colores.superficie,
        borderRadius: BorderRadius.circular(Medidas.radio),
        border: Border.all(color: Colores.borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 18, color: Colores.azul),
          const SizedBox(width: 8),
          Text(etiqueta,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colores.texto)),
          const Icon(Icons.chevron_right, color: Colores.textoSecundario),
        ],
      ),
    );
  }
}

class _Tarjetas extends StatelessWidget {
  const _Tarjetas({required this.datos});

  final Dashboard datos;

  @override
  Widget build(BuildContext context) {
    final d = datos;
    final tarjetas = [
      _Kpi(
        titulo: 'Pedidos publicados',
        valor: '${d.pedidosPublicados.actual}',
        comparacion: d.pedidosPublicados,
      ),
      _Kpi(
        titulo: 'Ingresos (tokens)',
        valor: Dinero.pesos(d.ingresosArs.actual),
        comparacion: d.ingresosArs,
        detalle: '${d.tokensVendidos} tokens vendidos',
      ),
      _Kpi(
        titulo: 'Altas de profesionales',
        valor: '${d.altasProfesionales.actual}',
        comparacion: d.altasProfesionales,
        detalle: '${d.altasBuscadores.actual} buscadores',
      ),
      _Kpi(
        titulo: 'Reportes recibidos',
        valor: '${d.denunciasRecibidas.actual}',
        comparacion: d.denunciasRecibidas,
        detalle: '${d.denunciasAbiertas} abiertos hoy',
        // Más denuncias es una mala noticia: la flecha hacia arriba va en rojo.
        subirEsBueno: false,
      ),
    ];

    return LayoutBuilder(
      builder: (context, r) {
        final columnas = r.maxWidth >= 1000 ? 4 : (r.maxWidth >= 520 ? 2 : 1);
        final ancho = (r.maxWidth - (columnas - 1) * 16) / columnas;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final t in tarjetas) SizedBox(width: ancho, child: t),
          ],
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.titulo,
    required this.valor,
    required this.comparacion,
    this.detalle,
    this.subirEsBueno = true,
  });

  final String titulo;
  final String valor;
  final Comparacion comparacion;
  final String? detalle;
  final bool subirEsBueno;

  @override
  Widget build(BuildContext context) {
    final v = comparacion.variacion;
    final sube = (v ?? 0) >= 0;
    final bueno = sube == subirEsBueno;
    final color = v == null
        ? Colores.textoTenue
        : (bueno ? Colores.exito : Colores.error);
    final texto = v == null
        ? 'Sin datos del período anterior'
        : '${sube ? '▲ +' : '▼ '}$v % vs. período anterior';

    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  color: Colores.textoSecundario, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colores.azul,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(texto,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          if (detalle != null)
            Text(detalle!,
                style: const TextStyle(color: Colores.textoTenue, fontSize: 12)),
        ],
      ),
    );
  }
}

/// «Altas de usuarios · Últimos 12 meses». El mes en curso va en naranja,
/// como en la figura.
class _GraficoAltas extends StatelessWidget {
  const _GraficoAltas({required this.meses});

  final List<AltasMes> meses;

  static const _iniciales = ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

  @override
  Widget build(BuildContext context) {
    final maximo = meses.fold<int>(0, (m, e) => math.max(m, e.total));

    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Altas de usuarios',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16, color: Colores.texto)),
          const Text('Últimos 12 meses',
              style: TextStyle(color: Colores.textoSecundario, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < meses.length; i++)
                  Expanded(
                    child: Tooltip(
                      message: '${meses[i].buscadores} buscadores · '
                          '${meses[i].profesionales} profesionales',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${meses[i].total}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colores.textoSecundario)),
                          const SizedBox(height: 4),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: maximo == 0
                                ? 2
                                : math.max(2, 130 * meses[i].total / maximo),
                            decoration: BoxDecoration(
                              color: i == meses.length - 1
                                  ? Colores.naranja
                                  : Colores.azulMedio,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(_iniciales[meses[i].mes.month - 1],
                              style: const TextStyle(
                                  fontSize: 11, color: Colores.textoTenue)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// «Ingresos por pack»: torta con el total en el centro y la leyenda abajo.
class _GraficoPacks extends StatelessWidget {
  const _GraficoPacks({required this.packs});

  final List<IngresoPack> packs;

  static const _colores = [
    Colores.naranja,
    Colores.azulMedio,
    Colores.azul,
    Colores.textoTenue,
  ];

  @override
  Widget build(BuildContext context) {
    final total = packs.fold<int>(0, (s, p) => s + p.monto);

    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingresos por pack',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16, color: Colores.texto)),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: _Torta(
                  valores: [for (final p in packs) p.monto.toDouble()],
                  colores: _colores,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        child: Text(Dinero.pesos(total),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colores.azul)),
                      ),
                      const Text('total',
                          style: TextStyle(
                              fontSize: 11, color: Colores.textoSecundario)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (packs.isEmpty)
            const Text('Sin compras en este rango.',
                style: TextStyle(color: Colores.textoTenue))
          else
            for (var i = 0; i < packs.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle,
                        size: 10, color: _colores[i % _colores.length]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${packs[i].pack} · '
                        '${(100 * packs[i].monto / total).round()} % · '
                        '${packs[i].compras} compras',
                        style: const TextStyle(color: Colores.textoSecundario),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _Torta extends CustomPainter {
  const _Torta({required this.valores, required this.colores});

  final List<double> valores;
  final List<Color> colores;

  @override
  void paint(Canvas canvas, Size size) {
    const grosor = 22.0;
    final rect = Rect.fromLTWH(grosor / 2, grosor / 2,
        size.width - grosor, size.height - grosor);
    final pincel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor;

    final total = valores.fold<double>(0, (s, v) => s + v);
    if (total == 0) {
      canvas.drawArc(rect, 0, 2 * math.pi, false,
          pincel..color = Colores.neutroSuave);
      return;
    }

    var inicio = -math.pi / 2;
    for (var i = 0; i < valores.length; i++) {
      final barrido = 2 * math.pi * valores[i] / total;
      canvas.drawArc(rect, inicio, barrido, false,
          pincel..color = colores[i % colores.length]);
      inicio += barrido;
    }
  }

  @override
  bool shouldRepaint(_Torta old) =>
      old.valores.toString() != valores.toString();
}

/// CU-34, requerimiento especial: el registro de accesos con IP y hora.
class _AccesosRecientes extends ConsumerWidget {
  const _AccesosRecientes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accesos = ref.watch(accesosAdminProvider);

    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Últimos accesos al panel',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16, color: Colores.texto)),
          const SizedBox(height: 8),
          ...accesos.when(
            loading: () => const [LinearProgressIndicator()],
            error: (e, _) => [Text(MensajesError.desde(e))],
            data: (lista) => lista.isEmpty
                ? const [Text('Todavía no hay accesos registrados.')]
                : [
                    for (final a in lista)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          a.aceptado ? Icons.login : Icons.block,
                          color: a.aceptado ? Colores.exito : Colores.error,
                        ),
                        title: Text(a.email),
                        subtitle: Text(
                          '${a.aceptado ? 'Aceptado' : 'Denegado'} · '
                          '${Fechas.conHora(a.fecha.toLocal())}'
                          '${a.ip == null ? '' : ' · IP ${a.ip}'}',
                        ),
                      ),
                  ],
          ),
        ],
      ),
    );
  }
}
