import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/core/utils/fechas.dart';

/// Fechas y frases relativas en castellano.
///
/// El reloj entra por parámetro en todo lo que lo necesita, así que estas
/// pruebas no dependen de cuándo se corran.
void main() {
  // Un martes cualquiera, a media tarde.
  final ahora = DateTime(2026, 9, 3, 15, 30);

  group('formatos absolutos', () {
    test('larga escribe el mes en castellano', () {
      expect(Fechas.larga(DateTime(2026, 3, 14)), '14 de marzo de 2026');
      expect(Fechas.larga(DateTime(2026, 12, 1)), '1 de diciembre de 2026');
    });

    test('corta rellena con ceros', () {
      expect(Fechas.corta(DateTime(2026, 3, 4)), '04/03/2026');
      expect(Fechas.corta(DateTime(2026, 12, 25)), '25/12/2026');
    });
  });

  group('vigencia · lo que se lee en la tarjeta del pedido', () {
    test('hoy, mañana y en varios días', () {
      expect(Fechas.vigencia(DateTime(2026, 9, 3, 23, 0), ahora), 'vence hoy');
      expect(Fechas.vigencia(DateTime(2026, 9, 4, 8, 0), ahora), 'vence mañana');
      expect(Fechas.vigencia(DateTime(2026, 9, 10), ahora), 'vence en 7 días');
    });

    test('ayer y hace varios días', () {
      expect(Fechas.vigencia(DateTime(2026, 9, 2, 9, 0), ahora), 'venció ayer');
      expect(Fechas.vigencia(DateTime(2026, 9, 1), ahora), 'venció hace 2 días');
    });

    test('cuenta días de calendario, no múltiplos de 24 horas', () {
      // A las 23:00 de hoy, un vencimiento mañana a las 08:00 está a nueve
      // horas: `Duration.inDays` daría 0 y diría «vence hoy», que no es lo que
      // espera quien lo lee.
      final casiMedianoche = DateTime(2026, 9, 3, 23, 0);
      expect(
        Fechas.vigencia(DateTime(2026, 9, 4, 8, 0), casiMedianoche),
        'vence mañana',
      );
    });
  });

  group('hace · algo que ya pasó', () {
    test('hoy y ayer', () {
      expect(Fechas.hace(DateTime(2026, 9, 3, 9, 0), ahora), 'hoy');
      expect(Fechas.hace(DateTime(2026, 9, 2), ahora), 'ayer');
    });

    test('hasta 30 días, en días; después, la fecha entera', () {
      expect(Fechas.hace(DateTime(2026, 8, 25), ahora), 'hace 9 días');
      expect(Fechas.hace(DateTime(2026, 7, 1), ahora), 'el 1 de julio de 2026');
    });

    test('una fecha futura no dice «hace -3 días»', () {
      expect(Fechas.hace(DateTime(2026, 9, 6), ahora), 'hoy');
    });
  });
}
