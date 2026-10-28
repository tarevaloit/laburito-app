/// Fuera del navegador no hay descarga: el panel es de la Web.
Future<bool> descargarTexto({
  required String nombre,
  required String contenido,
  String tipo = 'text/csv;charset=utf-8',
}) async =>
    false;
