import 'dart:math';

/// Nombres de archivo únicos para Storage.
///
/// Vive en `core/utils` y no adentro del repositorio de pedidos por un motivo
/// concreto: **esto se puede probar en la web**, y el repositorio no. La
/// primera versión de este código usaba `Random().nextInt(1 << 32)`, que en la
/// VM funciona y en la web tira `RangeError` —los `int` de Dart ahí son los
/// números de JavaScript y los corrimientos se hacen módulo 32, así que
/// `1 << 32` vale 0—. Ninguna prueba lo agarró porque todas corren en la VM.
///
/// Con la lógica acá afuera, `flutter test --platform chrome
/// test/identificadores_test.dart` la ejercita en un navegador de verdad.
class Identificadores {
  const Identificadores._();

  /// Tope del sufijo azaroso.
  ///
  /// Literal y no `1 << 32`: ver el comentario de la clase. `Random.nextInt`
  /// exige `0 < max ≤ 2^32` en las dos plataformas.
  static const int topeAzar = 0xFFFFFFFF;

  static final Random _azar = Random();

  /// `{microsegundos}_{azar}.{extension}`.
  ///
  /// La marca de tiempo ya alcanzaría para no pisar nada; el sufijo azaroso
  /// está para dos subidas en el mismo microsegundo. No pretende ser secreto:
  /// lo que protege el archivo son las políticas de Storage, no que su nombre
  /// sea difícil de adivinar.
  static String nombreDeArchivo(String extension) {
    final sufijo = _azar.nextInt(topeAzar).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}_$sufijo.$extension';
  }
}
