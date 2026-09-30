import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/admin/data/admin_repository.dart';
import 'package:laburito/features/admin/data/cupon.dart';
import 'package:laburito/features/admin/presentation/screens/precios_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-40 y CU-52 — Precios y cupones del administrador.
void main() {
  group('CU-40 precios', () {
    test('cero, negativo, vacío y texto se rechazan antes de salir', () {
      const validar = PreciosScreenValidaciones.validarPrecio;
      expect(validar('0'), isNotNull);
      expect(validar('-5'), isNotNull);
      expect(validar(''), isNotNull);
      expect(validar('mil'), isNotNull);
      expect(validar('9000'), isNull);
    });
  });

  group('CU-52 cupones', () {
    final ahora = DateTime.utc(2026, 9, 29, 12);
    Cupon cupon({int usos = 0, int? limite, DateTime? vence, bool activo = true}) =>
        Cupon(
          id: 'c',
          codigo: 'BIENVENIDA10',
          tokens: 10,
          venceAt: vence ?? DateTime.utc(2026, 10, 31, 3),
          usos: usos,
          limiteUsos: limite,
          activo: activo,
        );

    test('el estado sale de la fecha, los usos y el interruptor', () {
      expect(cupon().estado(ahora), EstadoCupon.activo);
      expect(cupon(vence: DateTime.utc(2026, 9, 1)).estado(ahora),
          EstadoCupon.vencido);
      expect(cupon(usos: 500, limite: 500).estado(ahora), EstadoCupon.agotado);
      expect(cupon(activo: false).estado(ahora), EstadoCupon.inactivo);
    });

    test('sin límite se muestra el infinito de la Figura 3.24', () {
      expect(cupon(usos: 88).usosLegible, '88/∞ usos');
      expect(cupon(usos: 142, limite: 500).usosLegible, '142/500 usos');
    });

    test('el formato del código es el mismo del check de la tabla', () {
      expect(Cupon.formatoCodigo.hasMatch('BIENVENIDA10'), isTrue);
      expect(Cupon.formatoCodigo.hasMatch('ABC'), isFalse);
      expect(Cupon.formatoCodigo.hasMatch('CON ESPACIO'), isFalse);
      expect(Cupon.formatoCodigo.hasMatch('OTOÑO10'), isFalse);
    });

    test('crear manda la fecha como día, sin hora ni zona', () async {
      Map<String, dynamic>? params;
      final repo = AdminRepository(SupabaseClient(
        'https://proyecto.supabase.co',
        'clave-anon-de-mentira',
        httpClient: MockClient((pedido) async {
          params = jsonDecode(pedido.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode([
              {
                'id': 'nuevo',
                'codigo': 'VERANO25',
                'tokens': 25,
                'vence_at': '2026-12-01T03:00:00+00:00',
                'limite_usos': null,
                'usos': 0,
                'activo': true,
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
            request: pedido,
          );
        }),
      ));

      final creado = await repo.crearCupon(
        codigo: 'verano25',
        tokens: 25,
        vence: DateTime(2026, 11, 30),
      );

      expect(params, {
        'p_codigo': 'verano25',
        'p_tokens': 25,
        'p_vence': '2026-11-30',
        'p_limite_usos': null,
      });
      expect(creado.codigo, 'VERANO25');
      expect(creado.venceLegible, 'Vence 30/11/2026');
    });
  });
}
