/// Carga del SDK de mapas, resuelta en tiempo de compilación por plataforma.
///
/// **Por qué el `<script>` de Maps no está en `web/index.html`.** Es donde lo
/// pone la documentación de `google_maps_flutter_web`, pero ahí la clave queda
/// escrita en un archivo del repositorio, y la regla del proyecto es que ningún
/// secreto se commitea: las claves entran por `--dart-define`, como las de
/// Supabase. Un `index.html` con la clave de verdad terminaría commiteado la
/// primera vez que alguien probara el mapa; uno con un marcador de posición
/// deja la Web sin mapa hasta que se edite a mano un archivo generado.
///
/// La salida es inyectar el script desde Dart con la clave que ya está en
/// memoria. Cuesta una espera la primera vez que se abre un mapa y a cambio la
/// clave viaja por el mismo camino que las demás.
///
/// El `if (dart.library.js_interop)` elige la implementación: en Android y en
/// las pruebas se compila el stub, que no importa nada de web.
library;

export 'sdk_mapas_stub.dart'
    if (dart.library.js_interop) 'sdk_mapas_web.dart';
