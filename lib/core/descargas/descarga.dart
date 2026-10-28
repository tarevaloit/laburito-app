/// Entrega un archivo generado en la app al navegador para que lo guarde.
///
/// Lo usa la exportación del Dashboard (CU-38, paso 6: «genera el archivo
/// descargable y lo entrega al navegador»). El panel del administrador es de
/// la Web; en Android y en las pruebas se compila el stub, que avisa que la
/// descarga no está disponible.
library;

export 'descarga_stub.dart'
    if (dart.library.js_interop) 'descarga_web.dart';
