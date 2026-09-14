/// Implementación para todo lo que no es Web (Android y las pruebas).
///
/// No hay nada que cargar: el SDK de Maps viene compilado dentro del APK y la
/// clave la lee del `meta-data com.google.android.geo.API_KEY` del manifiesto,
/// que Gradle rellena en tiempo de compilación. Devolver `true` significa
/// «adelante, dibujá el mapa»; si la clave del manifiesto estuviera vacía, el
/// mapa se vería gris y el SDK lo avisaría en el logcat, que es un problema de
/// configuración del build y no algo que Dart pueda detectar acá.
Future<bool> cargarSdkDeMapas(String apiKey) async => true;
