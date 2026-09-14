import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/features/pedidos/presentation/widgets/campos_pedido.dart';

/// Reglas de los campos del pedido (CU-13 y CU-15).
///
/// Son las mismas de los `check` de la tabla `pedidos` (migración 0005), y esa
/// duplicación es a propósito: el servidor es el que manda, pero si el cliente
/// no valida, el error llega como un `23514` genérico en vez de un mensaje al
/// lado del campo. Lo que estas pruebas cuidan es que las dos tablas de reglas
/// no se separen, y que el alta y la edición —que desde la Fase 6 comparten
/// `ValidadoresPedido`— nunca acepten cosas distintas.
void main() {
  group('título · entre 5 y 80 caracteres', () {
    test('acepta un título normal', () {
      expect(ValidadoresPedido.titulo('Se me tapó la cocina'), isNull);
    });

    test('rechaza vacío y solo espacios', () {
      expect(ValidadoresPedido.titulo(''), 'Ingresá un título');
      expect(ValidadoresPedido.titulo('   '), 'Ingresá un título');
      expect(ValidadoresPedido.titulo(null), 'Ingresá un título');
    });

    test('el mínimo se cuenta sin los espacios de los bordes', () {
      // 4 caracteres útiles, aunque el string tenga 8.
      expect(ValidadoresPedido.titulo('  Gas   '), contains('corto'));
      expect(ValidadoresPedido.titulo('Gas!!'), isNull);
    });

    test('rechaza más de 80', () {
      expect(ValidadoresPedido.titulo('a' * 80), isNull);
      expect(ValidadoresPedido.titulo('a' * 81), contains('largo'));
    });
  });

  group('descripción · entre 20 y 1000 caracteres', () {
    test('acepta una descripción con detalle', () {
      expect(
        ValidadoresPedido.descripcion(
          'La pileta de la cocina no traga y el agua vuelve.',
        ),
        isNull,
      );
    });

    test('rechaza vacío', () {
      expect(ValidadoresPedido.descripcion(''), 'Contá qué necesitás');
    });

    test('rechaza menos de 20 y acepta exactamente 20', () {
      expect(ValidadoresPedido.descripcion('a' * 19), contains('mínimo 20'));
      expect(ValidadoresPedido.descripcion('a' * 20), isNull);
    });

    test('rechaza más de 1000', () {
      expect(ValidadoresPedido.descripcion('a' * 1000), isNull);
      expect(ValidadoresPedido.descripcion('a' * 1001), contains('máximo 1000'));
    });
  });

  group('presupuesto · opcional y no negativo', () {
    test('vacío es válido: el presupuesto no es obligatorio', () {
      expect(ValidadoresPedido.presupuesto(''), isNull);
      expect(ValidadoresPedido.presupuesto('   '), isNull);
      expect(ValidadoresPedido.presupuesto(null), isNull);
    });

    test('acepta enteros y decimales', () {
      expect(ValidadoresPedido.presupuesto('200000'), isNull);
      expect(ValidadoresPedido.presupuesto('1500.50'), isNull);
    });

    test('acepta la coma decimal del teclado castellano', () {
      expect(ValidadoresPedido.presupuesto('1500,50'), isNull);
      expect(ValidadoresPedido.aNumero('1500,50'), 1500.5);
    });

    test('rechaza texto y negativos', () {
      expect(ValidadoresPedido.presupuesto('dos mil'), 'Ingresá un número válido');
      expect(ValidadoresPedido.presupuesto('-1'), 'No puede ser negativo');
    });

    test('aNumero devuelve null cuando no hay número, no cero', () {
      // Cero es un presupuesto legítimo; «no escribió nada» no puede
      // confundirse con «puso 0».
      expect(ValidadoresPedido.aNumero('cualquier cosa'), isNull);
      expect(ValidadoresPedido.aNumero('0'), 0);
    });
  });
}
