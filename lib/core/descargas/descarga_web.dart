import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Arma un `Blob` con el texto y lo descarga con un enlace temporal, que es
/// como el navegador entrega un archivo creado en la página.
Future<bool> descargarTexto({
  required String nombre,
  required String contenido,
  String tipo = 'text/csv;charset=utf-8',
}) async {
  final bytes = utf8.encode(contenido).toJS;
  final blob = web.Blob([bytes].toJS, web.BlobPropertyBag(type: tipo));
  final url = web.URL.createObjectURL(blob);

  final enlace = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = nombre
    ..style.display = 'none';
  web.document.body?.append(enlace);
  enlace.click();
  enlace.remove();
  web.URL.revokeObjectURL(url);
  return true;
}
