import 'package:freezed_annotation/freezed_annotation.dart';

part 'metricas.freezed.dart';

enum PeriodoMetricas { semana, mes }

/// CU-45 — Ver Métricas de Perfil (Figura 3.18). Sale de `metricas_perfil()`.
@freezed
abstract class MetricasPerfil with _$MetricasPerfil {
  const MetricasPerfil._();

  const factory MetricasPerfil({
    required PeriodoMetricas periodo,
    @Default(0) int vistas,
    @Default(0) int contactos,
    @Default(0) int calificaciones,

    /// Porcentaje de contactos que terminaron en una calificación. `null` sin
    /// contactos en el período.
    int? efectividad,
    @Default(<BarraMetricas>[]) List<BarraMetricas> serie,
  }) = _MetricasPerfil;

  /// Flujo alterno 1.1: un Profesional nuevo, sin ninguna interacción.
  bool get sinActividad => vistas == 0 && contactos == 0 && calificaciones == 0;

  int get maximoSerie =>
      serie.fold(0, (max, b) => b.vistas > max ? b.vistas : max);

  factory MetricasPerfil.desdeJson(Map<String, dynamic> json) => MetricasPerfil(
        periodo: json['periodo'] == 'mes'
            ? PeriodoMetricas.mes
            : PeriodoMetricas.semana,
        vistas: (json['vistas'] as num?)?.toInt() ?? 0,
        contactos: (json['contactos'] as num?)?.toInt() ?? 0,
        calificaciones: (json['calificaciones'] as num?)?.toInt() ?? 0,
        efectividad: (json['efectividad'] as num?)?.toInt(),
        serie: [
          for (final b in json['serie'] as List? ?? const [])
            BarraMetricas(
              desde: DateTime.parse((b as Map)['desde'] as String),
              vistas: (b['vistas'] as num).toInt(),
            ),
        ],
      );
}

@freezed
abstract class BarraMetricas with _$BarraMetricas {
  const factory BarraMetricas({required DateTime desde, required int vistas}) =
      _BarraMetricas;
}
