import 'package:freezed_annotation/freezed_annotation.dart';

part 'horario_atencion.freezed.dart';

/// CU-44 — Una franja de atención de un día de la semana.
///
/// El día es **ISO**: 1 = lunes … 7 = domingo. Es el mismo criterio que la
/// tabla `profesional_horarios` (migración 0012), que `extract(isodow …)` de
/// Postgres y que `DateTime.weekday` de Dart, así que nadie traduce números
/// en el medio.
///
/// Las horas viajan como minutos desde la medianoche y no como `TimeOfDay`
/// porque el dominio no puede depender de Flutter, y porque comparar y ordenar
/// enteros no tiene sorpresas. La medianoche del final es 1440 («24:00»), que
/// es lo que la base acepta para una franja que termina con el día.
@freezed
abstract class HorarioAtencion with _$HorarioAtencion {
  const HorarioAtencion._();

  const factory HorarioAtencion({
    required int dia,
    required int desdeMinutos,
    required int hastaMinutos,
  }) = _HorarioAtencion;

  static const int finDelDia = 24 * 60;

  /// Cuántas franjas por día acepta la RPC de la 0019.
  static const int maximoPorDia = 3;

  static const List<String> nombresDeDia = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  String get nombreDelDia => nombresDeDia[dia - 1];

  String get desdeLegible => comoTexto(desdeMinutos);
  String get hastaLegible => comoTexto(hastaMinutos);
  String get rangoLegible => '$desdeLegible a $hastaLegible';

  bool get esValida =>
      dia >= 1 &&
      dia <= 7 &&
      desdeMinutos >= 0 &&
      hastaMinutos <= finDelDia &&
      hastaMinutos > desdeMinutos;

  /// Dos franjas del mismo día que comparten aunque sea un minuto. El rango es
  /// semiabierto, igual que la restricción de exclusión de la base: 9-13 y
  /// 13-18 conviven.
  bool sePisaCon(HorarioAtencion otra) =>
      dia == otra.dia &&
      desdeMinutos < otra.hastaMinutos &&
      otra.desdeMinutos < hastaMinutos;

  static String comoTexto(int minutos) {
    final horas = (minutos ~/ 60).toString().padLeft(2, '0');
    final resto = (minutos % 60).toString().padLeft(2, '0');
    return '$horas:$resto';
  }

  static int desdeTexto(String hora) {
    final partes = hora.split(':');
    return int.parse(partes[0]) * 60 + int.parse(partes[1]);
  }

  factory HorarioAtencion.desdeFila(Map<String, dynamic> fila) =>
      HorarioAtencion(
        dia: (fila['dia_semana'] as num).toInt(),
        desdeMinutos: desdeTexto(fila['hora_desde'] as String),
        hastaMinutos: desdeTexto(fila['hora_hasta'] as String),
      );

  /// Como lo espera `reemplazar_horarios(p_franjas jsonb)`.
  Map<String, dynamic> aJson() => {
        'dia': dia,
        'desde': desdeLegible,
        'hasta': hastaLegible,
      };
}
