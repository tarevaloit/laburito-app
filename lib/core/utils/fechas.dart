/// Fechas en castellano, escritas a mano.
///
/// **Por qué no `DateFormat` de `intl`.** Formatear en español pide cargar los
/// datos de locale (`initializeDateFormatting`) antes del primer uso; si falta,
/// la app no falla al compilar sino al dibujar la primera fecha, que es el peor
/// momento posible. El proyecto necesita seis frases y ningún calendario, así
/// que salen de acá y son las mismas en Web y en Android.
class Fechas {
  const Fechas._();

  static const List<String> _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// «14 de marzo de 2026».
  static String larga(DateTime fecha) =>
      '${fecha.day} de ${_meses[fecha.month - 1]} de ${fecha.year}';

  /// «14/03/2026». Para tablas y renglones de dato.
  static String corta(DateTime fecha) =>
      '${_dosDigitos(fecha.day)}/${_dosDigitos(fecha.month)}/${fecha.year}';

  /// Cuánta vida le queda al pedido, en palabras: «vence hoy», «vence en 3
  /// días», «venció hace 2 días».
  ///
  /// Es lo que va en las tarjetas del historial (CU-17): una fecha absoluta
  /// obliga a hacer la cuenta mental, y lo único que se quiere saber ahí es si
  /// hay que hacer algo o no.
  ///
  /// [ahora] es parámetro para poder probarlo sin depender del reloj.
  static String vigencia(DateTime vencimiento, [DateTime? ahora]) {
    final dias = _diasDeDiferencia(vencimiento, ahora ?? DateTime.now());

    if (dias == 0) return 'vence hoy';
    if (dias == 1) return 'vence mañana';
    if (dias > 1) return 'vence en $dias días';
    if (dias == -1) return 'venció ayer';
    return 'venció hace ${-dias} días';
  }

  /// «hoy», «ayer», «hace 5 días», «el 14 de marzo de 2026». Para algo que ya
  /// pasó: la publicación, el cierre, un evento de la cronología.
  static String hace(DateTime fecha, [DateTime? ahora]) {
    final dias = -_diasDeDiferencia(fecha, ahora ?? DateTime.now());

    if (dias <= 0) return 'hoy';
    if (dias == 1) return 'ayer';
    if (dias < 30) return 'hace $dias días';
    return 'el ${larga(fecha)}';
  }

  /// Diferencia en días **de calendario**, no en múltiplos de 24 horas.
  ///
  /// La distinción importa: a las 23:00 de hoy, un vencimiento mañana a las
  /// 08:00 está a nueve horas, y `Duration.inDays` lo redondea a 0 —«vence
  /// hoy»— cuando la respuesta que la persona espera es «vence mañana».
  static int _diasDeDiferencia(DateTime fecha, DateTime ahora) {
    final a = DateTime(fecha.year, fecha.month, fecha.day);
    final b = DateTime(ahora.year, ahora.month, ahora.day);
    return a.difference(b).inDays;
  }

  static String _dosDigitos(int n) => n.toString().padLeft(2, '0');
}
