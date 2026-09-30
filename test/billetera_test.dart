import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/core/providers/supabase_providers.dart';
import 'package:laburito/core/utils/dinero.dart';
import 'package:laburito/core/utils/fechas.dart';
import 'package:laburito/features/billetera/data/billetera_repository.dart';
import 'package:laburito/features/billetera/domain/movimiento_tokens.dart';
import 'package:laburito/features/billetera/domain/pago.dart';
import 'package:laburito/features/billetera/domain/paquete_tokens.dart';
import 'package:laburito/features/billetera/domain/resultado_canje.dart';
import 'package:laburito/features/billetera/presentation/controllers/billetera_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-30, CU-31, CU-32, CU-33, CU-53 y CU-19 — La billetera del Profesional.
void main() {
  const bronce =
      PaqueteTokens(id: 'b', nombre: 'Bronce', cantidad: 5, precioArs: 4500);
  const plata =
      PaqueteTokens(id: 'p', nombre: 'Plata', cantidad: 10, precioArs: 8000);
  const oro =
      PaqueteTokens(id: 'o', nombre: 'Oro', cantidad: 20, precioArs: 14000);

  group('dominio', () {
    test('los pesos llevan punto de miles y ningún decimal', () {
      expect(Dinero.pesos(4500), r'$ 4.500');
      expect(Dinero.pesos(14000), r'$ 14.000');
      expect(Dinero.pesos(1250000), r'$ 1.250.000');
      expect(Dinero.pesos(900), r'$ 900');
    });

    test('el ahorro se calcula contra el pack más chico, no se escribe a mano',
        () {
      // Bronce: $900 el token. Plata: $800 (−11 %). Oro: $700 (−22 %).
      expect(plata.ahorroRespectoDe(bronce), 11);
      expect(oro.ahorroRespectoDe(bronce), 22);
      expect(bronce.ahorroRespectoDe(bronce), isNull);
    });

    test('un pack más caro por token no muestra ahorro', () {
      const caro =
          PaqueteTokens(id: 'c', nombre: 'Caro', cantidad: 10, precioArs: 10000);
      expect(caro.ahorroRespectoDe(bronce), isNull);
    });

    test('el paquete de referencia es el de menos tokens', () {
      const estado = EstadoBilletera(saldo: 0, paquetes: [oro, bronce, plata]);
      expect(estado.paqueteDeReferencia, bronce);
    });

    test('con menos de 3 tokens el saldo es bajo', () {
      expect(const EstadoBilletera(saldo: 2).saldoBajo, isTrue);
      expect(const EstadoBilletera(saldo: 3).saldoBajo, isFalse);
    });

    test('un movimiento se lee con su signo', () {
      final consumo = MovimientoTokens.desdeFila({
        'id': 'm1',
        'tipo': 'consumo',
        'cantidad': -1,
        'saldo_resultante': 11,
        'descripcion': 'Desbloqueo de contacto',
        'created_at': '2026-09-29T13:24:00Z',
      });
      final compra = consumo.copyWith(tipo: TipoMovimiento.compra, cantidad: 10);

      expect(consumo.esIngreso, isFalse);
      expect(consumo.cantidadLegible, '−1');
      expect(compra.cantidadLegible, '+10');
    });

    test('un pago aprobado tiene número de comprobante y descarga', () {
      final pago = Pago.desdeFila({
        'id': 'pago-1',
        'paquete_nombre': 'Plata',
        'cantidad_tokens': 10,
        'monto_ars': 8000,
        'estado': 'aprobado',
        'created_at': '2026-09-29T13:00:00Z',
        'metodo_pago': 'master',
        'mp_estado_detalle': 'accredited',
        'numero_comprobante': 12,
        'aprobado_at': '2026-09-29T13:01:00Z',
      });

      expect(pago.tieneComprobante, isTrue);
      expect(pago.numeroComprobanteLegible, '0001-00000012');
      expect(pago.concepto, 'Pack Plata · 10 tokens');
      expect(pago.montoLegible, r'$ 8.000');
      expect(pago.metodoLegible, 'Mastercard');
      expect(pago.motivoLegible, isNull);
    });

    test('un rechazo se explica con el status_detail de Mercado Pago', () {
      final pago = Pago(
        id: 'x',
        paqueteNombre: 'Oro',
        cantidadTokens: 20,
        montoArs: 14000,
        estado: EstadoPago.rechazado,
        fecha: DateTime(2026, 9, 29),
        estadoDetalle: 'cc_rejected_insufficient_amount',
      );

      expect(pago.tieneComprobante, isFalse);
      expect(pago.motivoLegible, contains('fondos'));
      expect(
        pago.copyWith(estadoDetalle: 'algo_nuevo').motivoLegible,
        'Mercado Pago rechazó el pago.',
      );
    });

    test('un pendiente sin detalle dice que falta la confirmación', () {
      final pago = Pago(
        id: 'x',
        paqueteNombre: 'Oro',
        cantidadTokens: 20,
        montoArs: 14000,
        estado: EstadoPago.pendiente,
        fecha: DateTime(2026, 9, 29),
      );
      expect(pago.motivoLegible, contains('confirmación'));
    });

    test('cada resultado del canje tiene su mensaje', () {
      expect(ResultadoCanje.desde('ya_usado'), ResultadoCanje.yaUsado);
      expect(ResultadoCanje.desde('bloqueado').mensaje, contains('intentos'));
      expect(ResultadoCanje.desde('cualquier cosa'), ResultadoCanje.inexistente);
      for (final r in ResultadoCanje.values) {
        if (r != ResultadoCanje.ok) expect(r.mensaje, isNotEmpty);
      }
    });

    test('la fecha de un movimiento lleva la hora', () {
      final ahora = DateTime(2026, 9, 29, 20);
      expect(Fechas.conHora(DateTime(2026, 9, 29, 10, 24), ahora), 'Hoy · 10:24');
      expect(Fechas.conHora(DateTime(2026, 9, 28, 19, 2), ahora), 'Ayer · 19:02');
      expect(Fechas.conHora(DateTime(2026, 9, 1, 8, 5), ahora), '01/09/2026 · 08:05');
    });
  });

  group('repositorio y controlador', () {
    late _ServidorFalso servidor;
    late SupabaseClient client;
    late ProviderContainer container;

    setUp(() async {
      servidor = _ServidorFalso();
      client = SupabaseClient(
        'https://proyecto.supabase.co',
        'clave-anon-de-mentira',
        httpClient: MockClient(servidor.responder),
      );
      await client.auth.setInitialSession(jsonEncode({
        'access_token': 'token-de-mentira',
        'token_type': 'bearer',
        'refresh_token': 'refresh-de-mentira',
        'expires_in': 3600,
        'user': {
          'id': '55555555-5555-4555-8555-555555555555',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'aud': 'authenticated',
          'created_at': '2026-09-01T10:00:00Z',
        },
      }));

      container = ProviderContainer(overrides: [
        supabaseClientProvider.overrideWithValue(client),
        billeteraRepositoryProvider.overrideWithValue(BilleteraRepository(client)),
      ]);
      addTearDown(container.dispose);
    });

    test('la compra manda solo el id del paquete: el precio lo pone el servidor',
        () async {
      final compra =
          await BilleteraRepository(client).iniciarCompra('paquete-plata');

      expect(servidor.funciones, ['crear_preferencia_pago']);
      expect(servidor.ultimoCuerpo, {'paquete_id': 'paquete-plata'});
      expect(compra.pagoId, 'pago-nuevo');
      expect(compra.checkout.host, 'www.mercadopago.com.ar');
    });

    test('sin Mercado Pago configurado, el mensaje es el del flujo alterno',
        () async {
      servidor.mercadoPagoCaido = true;

      await expectLater(
        BilleteraRepository(client).iniciarCompra('paquete-plata'),
        throwsA(isA<ErrorDeFuncion>()
            .having((e) => e.codigo, 'codigo', 'pagos_no_disponibles')
            .having((e) => e.message, 'message', contains('no están disponibles'))),
      );
    });

    test('un comprobante pendiente dice que está en proceso', () async {
      await expectLater(
        BilleteraRepository(client).comprobante('pago-pendiente'),
        throwsA(isA<ErrorDeFuncion>()
            .having((e) => e.codigo, 'codigo', 'comprobante_en_proceso')),
      );
    });

    test('el canje devuelve lo acreditado sin levantar excepciones', () async {
      final bueno = await BilleteraRepository(client).canjear('BIENVENIDA10');
      expect(bueno.exitoso, isTrue);
      expect(bueno.tokens, 10);
      expect(bueno.saldo, 22);

      final malo = await BilleteraRepository(client).canjear('NOEXISTE');
      expect(malo.exitoso, isFalse);
      expect(malo.resultado, ResultadoCanje.inexistente);
    });

    test('la billetera carga saldo, movimientos y paquetes', () async {
      final estado = await container.read(billeteraProvider.future);

      expect(estado.saldo, 12);
      expect(estado.movimientos.single.descripcion, 'Compra pack Plata');
      expect(estado.paquetes.map((p) => p.nombre), ['Bronce', 'Plata', 'Oro']);
      expect(estado.sinConexion, isFalse);
    });

    test('si la recarga falla, queda el último saldo marcado «sin conexión»',
        () async {
      await container.read(billeteraProvider.future);
      servidor.sinRed = true;

      await container.read(billeteraProvider.notifier).refrescar();

      final estado = container.read(billeteraProvider).value!;
      expect(estado.saldo, 12);
      expect(estado.sinConexion, isTrue);
    });

    test('el saldo que devuelve una operación se pinta al toque', () async {
      await container.read(billeteraProvider.future);

      container.read(billeteraProvider.notifier).saldoActualizado(11);

      expect(container.read(billeteraProvider).value!.saldo, 11);
    });
  });
}

class _ServidorFalso {
  final List<String> funciones = [];
  Object? ultimoCuerpo;
  bool mercadoPagoCaido = false;
  bool sinRed = false;

  Future<http.Response> responder(http.Request pedido) async {
    if (sinRed) throw http.ClientException('sin red');

    final ruta = pedido.url.path;

    if (ruta.startsWith('/functions/v1/')) {
      final nombre = ruta.split('/').last;
      funciones.add(nombre);
      ultimoCuerpo = jsonDecode(pedido.body);

      if (nombre == 'crear_preferencia_pago') {
        return mercadoPagoCaido
            ? _json(pedido, {
                'error': 'Los pagos no están disponibles en este momento. '
                    'Probá de nuevo más tarde.',
                'codigo': 'pagos_no_disponibles',
              }, 503)
            : _json(pedido, {
                'pago_id': 'pago-nuevo',
                'url': 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=1',
              }, 200);
      }
      if (nombre == 'comprobante_pago') {
        return _json(pedido, {
          'error': 'El comprobante está en proceso de emisión.',
          'codigo': 'comprobante_en_proceso',
        }, 409);
      }
    }

    if (ruta == '/rest/v1/rpc/canjear_cupon') {
      final codigo = (jsonDecode(pedido.body) as Map)['p_codigo'];
      return _json(pedido, [
        codigo == 'BIENVENIDA10'
            ? {'resultado': 'ok', 'tokens': 10, 'saldo': 22}
            : {'resultado': 'inexistente', 'tokens': null, 'saldo': null},
      ], 200);
    }

    if (ruta == '/rest/v1/profesionales') {
      return _json(pedido, {'saldo_tokens': 12}, 200);
    }

    if (ruta == '/rest/v1/movimientos_tokens') {
      return _json(pedido, [
        {
          'id': 'm1',
          'tipo': 'compra',
          'cantidad': 10,
          'saldo_resultante': 12,
          'descripcion': 'Compra pack Plata',
          'created_at': '2026-09-29T13:00:00Z',
        },
      ], 200);
    }

    if (ruta == '/rest/v1/paquetes_tokens') {
      return _json(pedido, [
        {'id': 'b', 'nombre': 'Bronce', 'cantidad': 5, 'precio_ars': 4500, 'activo': true, 'orden': 1},
        {'id': 'p', 'nombre': 'Plata', 'cantidad': 10, 'precio_ars': 8000, 'activo': true, 'orden': 2},
        {'id': 'o', 'nombre': 'Oro', 'cantidad': 20, 'precio_ars': 14000, 'activo': true, 'orden': 3},
      ], 200);
    }

    return _json(pedido, <dynamic>[], 200);
  }

  http.Response _json(http.Request pedido, Object cuerpo, int codigo) =>
      http.Response(
        jsonEncode(cuerpo),
        codigo,
        headers: {'content-type': 'application/json'},
        request: pedido,
      );
}
