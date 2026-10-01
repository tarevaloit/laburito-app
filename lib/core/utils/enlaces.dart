import 'package:url_launcher/url_launcher.dart';

/// Abre una URL fuera de la app: el checkout de Mercado Pago (CU-31), el chat
/// de WhatsApp (CU-25) o el PDF del comprobante (CU-19).
///
/// Siempre en una aplicación externa —navegador, WhatsApp, la app de Mercado
/// Pago si está instalada— y en la web en una pestaña nueva: la app no se
/// pierde de vista mientras se paga, y al volver sigue donde estaba.
///
/// Devuelve `false` si el sistema no pudo abrirla, para que la pantalla lo
/// diga en vez de quedarse en silencio.
Future<bool> abrirEnlace(Uri url) async {
  try {
    return await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } on Object {
    return false;
  }
}
