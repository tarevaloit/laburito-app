/// Canales de contacto del equipo de Laburito. Los usan la ayuda (CU-42) y la
/// cuenta suspendida (CU-49). Están en un solo lugar para cambiarlos una vez
/// cuando la plataforma tenga sus casillas definitivas.
class Contacto {
  const Contacto._();

  /// Soporte técnico y operativo (CU-42, paso 5 y flujo alterno 1.2).
  static const String correoSoporte = 'soporte@laburito.com.ar';

  /// Sanciones inapelables (CU-49, flujo alterno 1.1).
  static const String correoLegales = 'legales@laburito.com.ar';

  /// WhatsApp de soporte, en formato internacional sin `+` (para `wa.me`).
  static const String whatsappSoporte = '5491100000000';

  static Uri get mailSoporte =>
      Uri(scheme: 'mailto', path: correoSoporte, query: 'subject=Ayuda con Laburito');

  static Uri get mailLegales =>
      Uri(scheme: 'mailto', path: correoLegales, query: 'subject=Sanción de mi cuenta');

  static Uri get whatsapp => Uri.parse('https://wa.me/$whatsappSoporte');
}
