import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/core/utils/validadores.dart';

/// Reglas de validación exigidas por el CU-01 y el CU-02.
void main() {
  group('email', () {
    test('acepta direcciones válidas', () {
      expect(Validadores.email('juan.perez@gmail.com'), isNull);
      expect(Validadores.email('  alumno+test@universidad.edu.ar  '), isNull);
    });

    test('rechaza vacío y formatos inválidos', () {
      expect(Validadores.email(''), isNotNull);
      expect(Validadores.email(null), isNotNull);
      expect(Validadores.email('juan@'), isNotNull);
      expect(Validadores.email('juan@gmail'), isNotNull);
      expect(Validadores.email('sin-arroba.com'), isNotNull);
    });
  });

  group('contraseña', () {
    test('acepta mínimo 8, una mayúscula y un número', () {
      expect(Validadores.password('Laburito1'), isNull);
    });

    test('rechaza las que no cumplen la política', () {
      expect(Validadores.password('corta1A'), isNotNull); // menos de 8
      expect(Validadores.password('minusculas1'), isNotNull); // sin mayúscula
      expect(Validadores.password('SinNumeros'), isNotNull); // sin número
      expect(Validadores.password(''), isNotNull);
    });

    test('repetir exige coincidencia', () {
      expect(Validadores.repetirPassword('Laburito1', 'Laburito1'), isNull);
      expect(Validadores.repetirPassword('Laburito2', 'Laburito1'), isNotNull);
      expect(Validadores.repetirPassword('', 'Laburito1'), isNotNull);
    });
  });

  group('teléfono argentino', () {
    test('acepta código de área más número, con y sin separadores', () {
      expect(Validadores.telefono('1156781234'), isNull);
      expect(Validadores.telefono('(011) 5678-1234'), isNull);
    });

    test('rechaza cortos, largos y no numéricos', () {
      expect(Validadores.telefono('12345'), isNotNull);
      expect(Validadores.telefono('11567812345678'), isNotNull);
      expect(Validadores.telefono('11-abcd-1234'), isNotNull);
      expect(Validadores.telefono(''), isNotNull);
    });
  });

  group('PIN de 6 dígitos (CU-08 y CU-04)', () {
    test('acepta seis dígitos', () {
      expect(Validadores.pin('123456'), isNull);
    });

    test('rechaza longitudes distintas o letras', () {
      expect(Validadores.pin('12345'), isNotNull);
      expect(Validadores.pin('1234567'), isNotNull);
      expect(Validadores.pin('12345a'), isNotNull);
      expect(Validadores.pin(''), isNotNull);
    });
  });

  group('DNI', () {
    test('acepta 7 y 8 dígitos, con o sin puntos', () {
      expect(Validadores.dni('1234567'), isNull);
      expect(Validadores.dni('40.123.456'), isNull);
    });

    test('rechaza fuera de rango', () {
      expect(Validadores.dni('123456'), isNotNull);
      expect(Validadores.dni('123456789'), isNotNull);
      expect(Validadores.dni(''), isNotNull);
    });
  });

  group('nombre y descripción', () {
    test('nombre entre 2 y 60 caracteres', () {
      expect(Validadores.nombre('Tobías'), isNull);
      expect(Validadores.nombre('T'), isNotNull);
      expect(Validadores.nombre(''), isNotNull);
      expect(Validadores.nombre('a' * 61), isNotNull);
    });

    test('descripción opcional, tope de 500', () {
      expect(Validadores.descripcion(''), isNull);
      expect(Validadores.descripcion(null), isNull);
      expect(Validadores.descripcion('a' * 500), isNull);
      expect(Validadores.descripcion('a' * 501), isNotNull);
    });
  });
}
