import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/core/utils/identificadores.dart';

/// Nombres de archivo para Storage.
///
/// **Esta prueba tiene que correr también en la web:**
///
///     flutter test --platform chrome test/identificadores_test.dart
///
/// No es un capricho. La primera versión de `nombreDeArchivo` usaba
/// `Random().nextInt(1 << 32)`, que en la VM funciona y en el navegador tira
/// `RangeError: max must be in range 0 < max ≤ 2^32, was 0`: en la web los
/// `int` de Dart son los números de JavaScript y los corrimientos se hacen
/// módulo 32, así que `1 << 32` vale 0. El resultado era que **ninguna foto se
/// podía subir desde la web** y ninguna prueba lo veía, porque todas corrían
/// en la VM.
void main() {
  test('el tope del azar es válido para Random.nextInt', () {
    // El contrato de `nextInt` es 0 < max ≤ 2^32 en las dos plataformas. Con
    // `1 << 32` esto daba 0 en la web y rompía la aserción.
    expect(Identificadores.topeAzar, greaterThan(0));
    expect(Identificadores.topeAzar, lessThanOrEqualTo(4294967296));
  });

  test('arma un nombre con la extensión pedida', () {
    final nombre = Identificadores.nombreDeArchivo('png');

    expect(nombre, endsWith('.png'));
    expect(nombre, matches(RegExp(r'^\d+_[0-9a-f]+\.png$')));
  });

  test('no repite entre llamadas seguidas', () {
    // Dos subidas en el mismo microsegundo son improbables pero posibles; para
    // eso está el sufijo azaroso.
    final nombres = {
      for (var i = 0; i < 500; i++) Identificadores.nombreDeArchivo('jpg'),
    };

    expect(nombres.length, 500);
  });

  test('la ruta que arma no tiene barras ni espacios', () {
    // El primer segmento de la ruta en Storage es el id del pedido y lo mira
    // la política de la migración 0006: si el nombre trajera una barra, el
    // archivo caería en otra carpeta y la política lo rechazaría.
    for (var i = 0; i < 50; i++) {
      final nombre = Identificadores.nombreDeArchivo('webp');
      expect(nombre.contains('/'), isFalse);
      expect(nombre.contains(' '), isFalse);
    }
  });
}
