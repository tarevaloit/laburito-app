import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/barra_navegacion.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/reputacion_repository.dart';
import '../../domain/metricas.dart';

/// CU-45 — Ver Métricas de Perfil (Figura 3.18).
///
/// Vistas al perfil público y contactos abiertos, la actividad del período en
/// barras (por día en la semana, por semana en el mes) y la efectividad: de
/// cada contacto abierto, cuántos terminaron en una calificación. Sin
/// actividad, los contadores en cero y consejos para mejorar el perfil (flujo
/// alterno).
class EstadisticasScreen extends ConsumerStatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  ConsumerState<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends ConsumerState<EstadisticasScreen> {
  PeriodoMetricas _periodo = PeriodoMetricas.semana;

  @override
  Widget build(BuildContext context) {
    final metricas = ref.watch(metricasPerfilProvider(_periodo));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis estadísticas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/perfil'),
        ),
      ),
      bottomNavigationBar: BarraNavegacion.siCorresponde(
        actual: SeccionApp.perfil,
        mostrarBilletera: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(metricasPerfilProvider(_periodo).future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<PeriodoMetricas>(
              segments: const [
                ButtonSegment(
                    value: PeriodoMetricas.semana, label: Text('Semanal')),
                ButtonSegment(value: PeriodoMetricas.mes, label: Text('Mensual')),
              ],
              selected: {_periodo},
              onSelectionChanged: (s) => setState(() => _periodo = s.first),
            ),
            const SizedBox(height: 16),
            ...metricas.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (e, _) => [
                AvisoEstado.pendiente(
                  icono: Icons.insights_outlined,
                  titulo: 'No pudimos cargar tus estadísticas',
                  detalle: MensajesError.desde(e),
                ),
              ],
              data: (m) => _contenido(m),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _contenido(MetricasPerfil m) => [
        Row(
          children: [
            Expanded(
              child: _Contador(
                icono: Icons.visibility_outlined,
                color: Colores.azulMedio,
                valor: m.vistas,
                etiqueta: 'Vistas al perfil',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Contador(
                icono: Icons.lock_open_outlined,
                color: Colores.naranja,
                valor: m.contactos,
                etiqueta: 'Contactos abiertos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Grafico(metricas: m),
        const SizedBox(height: 12),
        if (m.efectividad != null)
          _Efectividad(porcentaje: m.efectividad!)
        else if (!m.sinActividad)
          const AvisoEstado.exito(
            icono: Icons.percent,
            titulo: 'Efectividad de postulaciones',
            detalle: 'Se calcula cuando abras contactos en este período: de '
                'cada contacto, cuántos te califican al terminar el trabajo.',
          ),
        if (m.sinActividad) ...[
          const SizedBox(height: 4),
          const _Consejos(),
        ],
      ];
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.icono,
    required this.color,
    required this.valor,
    required this.etiqueta,
  });

  final IconData icono;
  final Color color;
  final int valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return TarjetaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            '$valor',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colores.texto,
            ),
          ),
          Text(
            etiqueta,
            style: const TextStyle(color: Colores.textoSecundario, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Grafico extends StatelessWidget {
  const _Grafico({required this.metricas});

  final MetricasPerfil metricas;

  static const _dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _alto = 120.0;

  String _etiqueta(BarraMetricas b) => metricas.periodo == PeriodoMetricas.semana
      ? _dias[b.desde.weekday - 1]
      : '${b.desde.day}/${b.desde.month}';

  @override
  Widget build(BuildContext context) {
    final maximo = metricas.maximoSerie;
    final semanal = metricas.periodo == PeriodoMetricas.semana;

    return TarjetaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            semanal ? 'Actividad de la semana' : 'Actividad del mes',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colores.texto,
            ),
          ),
          Text(
            semanal ? 'Vistas por día' : 'Vistas por semana',
            style: const TextStyle(color: Colores.textoSecundario, fontSize: 12),
          ),
          const SizedBox(height: 16),
          // El alto de la barra más el de los dos textos (cantidad arriba,
          // día abajo), con margen para la letra agrandada del sistema.
          SizedBox(
            height: _alto + 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final b in metricas.serie)
                  Expanded(
                    child: Semantics(
                      label: '${_etiqueta(b)}: ${b.vistas} vistas',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            b.vistas == 0 ? '' : '${b.vistas}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colores.textoSecundario,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: semanal ? 18 : 32,
                            height: maximo == 0
                                ? 3
                                : 3 + (_alto - 3) * b.vistas / maximo,
                            decoration: BoxDecoration(
                              color: b.vistas == 0
                                  ? Colores.borde
                                  : Colores.azulMedio,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _etiqueta(b),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colores.textoTenue,
                            ),
                          ),
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

class _Efectividad extends StatelessWidget {
  const _Efectividad({required this.porcentaje});

  final int porcentaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.exitoSuave,
        borderRadius: BorderRadius.circular(Medidas.radio),
        border: Border.all(color: Colores.exitoBorde),
      ),
      child: Row(
        children: [
          Text(
            '$porcentaje%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colores.exito,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Efectividad de postulaciones',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colores.texto,
                  ),
                ),
                Text(
                  'De cada contacto abierto, cuántos terminaron en un '
                  'trabajo calificado.',
                  style: TextStyle(color: Colores.textoSecundario, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Flujo alterno 1.2 del CU-45: consejos para mejorar el perfil.
class _Consejos extends StatelessWidget {
  const _Consejos();

  @override
  Widget build(BuildContext context) {
    return TarjetaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Todavía no hay actividad. Para empezar:',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colores.texto),
          ),
          const SizedBox(height: 8),
          _consejo(Icons.photo_library_outlined,
              'Subí fotos de tus trabajos a tu portafolio.'),
          _consejo(Icons.share_outlined,
              'Compartí tu perfil público con cada cliente por WhatsApp.'),
          _consejo(Icons.star_outline_rounded,
              'Al terminar un trabajo, pedí la calificación desde Mis contactos.'),
          _consejo(Icons.schedule,
              'Mantené al día tu zona y tus horarios para recibir más alertas.'),
        ],
      ),
    );
  }

  Widget _consejo(IconData icono, String texto) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 18, color: Colores.azulMedio),
            const SizedBox(width: 8),
            Expanded(
              child: Text(texto,
                  style: const TextStyle(color: Colores.textoSecundario)),
            ),
          ],
        ),
      );
}
