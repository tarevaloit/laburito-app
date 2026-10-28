/// CU-38 — El tablero de la Figura 3.20, tal como lo devuelve
/// `dashboard_admin(desde, hasta)` (migración 0036).
library;

/// Un valor del período elegido junto al del período anterior de la misma
/// duración: «▲ +18 % vs. período anterior».
class Comparacion {
  const Comparacion({required this.actual, required this.anterior});

  final int actual;
  final int anterior;

  /// Variación porcentual redondeada. `null` cuando el período anterior fue
  /// cero: no hay base contra la cual comparar y un «+∞ %» no dice nada.
  int? get variacion =>
      anterior == 0 ? null : (((actual - anterior) / anterior) * 100).round();

  factory Comparacion.desde(Object? json) {
    final m = (json as Map?) ?? const {};
    return Comparacion(
      actual: (m['actual'] as num?)?.toInt() ?? 0,
      anterior: (m['anterior'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Altas de un mes del gráfico de barras.
class AltasMes {
  const AltasMes({
    required this.mes,
    required this.buscadores,
    required this.profesionales,
  });

  /// Primer día del mes.
  final DateTime mes;
  final int buscadores;
  final int profesionales;

  int get total => buscadores + profesionales;
}

/// Una porción del gráfico de torta «Ingresos por pack».
class IngresoPack {
  const IngresoPack({
    required this.pack,
    required this.compras,
    required this.monto,
  });

  final String pack;
  final int compras;
  final int monto;
}

class Dashboard {
  const Dashboard({
    required this.desde,
    required this.hasta,
    required this.pedidosPublicados,
    required this.ingresosArs,
    required this.tokensVendidos,
    required this.altasProfesionales,
    required this.altasBuscadores,
    required this.denunciasRecibidas,
    required this.denunciasAbiertas,
    required this.altasPorMes,
    required this.ingresosPorPack,
  });

  final DateTime desde;
  final DateTime hasta;
  final Comparacion pedidosPublicados;
  final Comparacion ingresosArs;
  final int tokensVendidos;
  final Comparacion altasProfesionales;
  final Comparacion altasBuscadores;
  final Comparacion denunciasRecibidas;
  final int denunciasAbiertas;
  final List<AltasMes> altasPorMes;
  final List<IngresoPack> ingresosPorPack;

  /// Flujo alterno 1.1: un rango anterior al lanzamiento. Las tarjetas y los
  /// gráficos se muestran en cero, sin error.
  bool get sinActividad =>
      pedidosPublicados.actual == 0 &&
      ingresosArs.actual == 0 &&
      altasProfesionales.actual == 0 &&
      altasBuscadores.actual == 0 &&
      denunciasRecibidas.actual == 0;

  int get totalPorPack => ingresosPorPack.fold(0, (s, p) => s + p.monto);

  factory Dashboard.desdeJson(Map<String, dynamic> j) => Dashboard(
        desde: DateTime.parse(j['desde'] as String),
        hasta: DateTime.parse(j['hasta'] as String),
        pedidosPublicados: Comparacion.desde(j['pedidos_publicados']),
        ingresosArs: Comparacion.desde(j['ingresos_ars']),
        tokensVendidos: (j['tokens_vendidos'] as num?)?.toInt() ?? 0,
        altasProfesionales: Comparacion.desde(j['altas_profesionales']),
        altasBuscadores: Comparacion.desde(j['altas_buscadores']),
        denunciasRecibidas: Comparacion.desde(j['denuncias_recibidas']),
        denunciasAbiertas: (j['denuncias_abiertas'] as num?)?.toInt() ?? 0,
        altasPorMes: [
          for (final f in (j['altas_por_mes'] as List? ?? const []))
            AltasMes(
              mes: DateTime.parse('${(f as Map)['mes']}-01'),
              buscadores: (f['buscadores'] as num?)?.toInt() ?? 0,
              profesionales: (f['profesionales'] as num?)?.toInt() ?? 0,
            ),
        ],
        ingresosPorPack: [
          for (final f in (j['ingresos_por_pack'] as List? ?? const []))
            IngresoPack(
              pack: (f as Map)['pack'] as String? ?? '',
              compras: (f['compras'] as num?)?.toInt() ?? 0,
              monto: (f['monto'] as num?)?.toInt() ?? 0,
            ),
        ],
      );

  /// Paso 5 del CU-38: los datos consolidados en CSV, que Excel abre
  /// directamente. Separador `;` y BOM de UTF-8: es lo que Excel en
  /// castellano espera para no romper los acentos ni las columnas.
  String aCsv() {
    String d(DateTime f) => '${f.year.toString().padLeft(4, '0')}-'
        '${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}';
    String esc(String s) =>
        s.contains(RegExp('[;"\n]')) ? '"${s.replaceAll('"', '""')}"' : s;

    final b = StringBuffer('﻿')
      ..writeln('Laburito — Reporte del panel;${d(desde)} al ${d(hasta)}')
      ..writeln()
      ..writeln('Indicador;Período;Período anterior')
      ..writeln('Pedidos publicados;${pedidosPublicados.actual};${pedidosPublicados.anterior}')
      ..writeln('Ingresos (ARS);${ingresosArs.actual};${ingresosArs.anterior}')
      ..writeln('Tokens vendidos;$tokensVendidos;')
      ..writeln('Altas de profesionales;${altasProfesionales.actual};${altasProfesionales.anterior}')
      ..writeln('Altas de buscadores;${altasBuscadores.actual};${altasBuscadores.anterior}')
      ..writeln('Denuncias recibidas;${denunciasRecibidas.actual};${denunciasRecibidas.anterior}')
      ..writeln('Denuncias abiertas hoy;$denunciasAbiertas;')
      ..writeln()
      ..writeln('Mes;Altas de buscadores;Altas de profesionales;Total');
    for (final m in altasPorMes) {
      b.writeln('${m.mes.year}-${m.mes.month.toString().padLeft(2, '0')};'
          '${m.buscadores};${m.profesionales};${m.total}');
    }
    b
      ..writeln()
      ..writeln('Pack;Compras;Ingresos (ARS)');
    for (final p in ingresosPorPack) {
      b.writeln('${esc(p.pack)};${p.compras};${p.monto}');
    }
    return b.toString();
  }
}

/// Un intento de ingreso al panel (CU-34), para la lista del Dashboard.
class AccesoAdmin {
  const AccesoAdmin({
    required this.email,
    required this.aceptado,
    required this.fecha,
    this.ip,
    this.navegador,
  });

  final String email;
  final bool aceptado;
  final DateTime fecha;
  final String? ip;
  final String? navegador;

  factory AccesoAdmin.desdeFila(Map<String, dynamic> f) => AccesoAdmin(
        email: f['email'] as String? ?? '—',
        aceptado: f['resultado'] == 'aceptado',
        fecha: DateTime.parse(f['created_at'] as String),
        ip: f['ip'] as String?,
        navegador: f['navegador'] as String?,
      );
}

/// Los rangos rápidos del selector «Últimos 30 días» de la Figura 3.20.
enum RangoDashboard {
  semana('Últimos 7 días', 7),
  mes('Últimos 30 días', 30),
  trimestre('Últimos 90 días', 90),
  anio('Últimos 12 meses', 365);

  const RangoDashboard(this.etiqueta, this.dias);

  final String etiqueta;
  final int dias;

  /// Desde y hasta, ambos inclusive, terminando [hoy].
  (DateTime, DateTime) rango(DateTime hoy) {
    final fin = DateTime(hoy.year, hoy.month, hoy.day);
    return (fin.subtract(Duration(days: dias - 1)), fin);
  }
}
