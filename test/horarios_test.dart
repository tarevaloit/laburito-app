import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/profesional/data/horarios_repository.dart';
import 'package:laburito/features/profesional/domain/horario_atencion.dart';
import 'package:laburito/features/profesional/presentation/controllers/horarios_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-44 — Horarios de atención y disponibilidad.
void main() {
  const lunesManana = HorarioAtencion(
    dia: 1,
    desdeMinutos: 9 * 60,
    hastaMinutos: 13 * 60,
  );
  const lunesTarde = HorarioAtencion(
    dia: 1,
    desdeMinutos: 14 * 60,
    hastaMinutos: 18 * 60,
  );

  group('dominio', () {
    test('el rango es semiabierto: 9-13 y 13-18 conviven', () {
      const pegada = HorarioAtencion(
        dia: 1,
        desdeMinutos: 13 * 60,
        hastaMinutos: 18 * 60,
      );

      expect(lunesManana.sePisaCon(pegada), isFalse);
      expect(
        lunesManana.sePisaCon(
          const HorarioAtencion(dia: 1, desdeMinutos: 12 * 60, hastaMinutos: 15 * 60),
        ),
        isTrue,
      );
    });

    test('dos días distintos no se pisan aunque compartan la hora', () {
      expect(
        lunesManana.sePisaCon(
          const HorarioAtencion(dia: 2, desdeMinutos: 9 * 60, hastaMinutos: 13 * 60),
        ),
        isFalse,
      );
    });

    test('una franja que termina antes de empezar no es válida', () {
      expect(
        const HorarioAtencion(dia: 1, desdeMinutos: 18 * 60, hastaMinutos: 9 * 60)
            .esValida,
        isFalse,
      );
    });

    test('la medianoche del final es 24:00, que es lo que acepta la base', () {
      const nocturna = HorarioAtencion(
        dia: 6,
        desdeMinutos: 22 * 60,
        hastaMinutos: HorarioAtencion.finDelDia,
      );

      expect(nocturna.esValida, isTrue);
      expect(nocturna.hastaLegible, '24:00');
      expect(nocturna.aJson(), {'dia': 6, 'desde': '22:00', 'hasta': '24:00'});
    });

    test('la fila de la base se lee con el día ISO', () {
      final franja = HorarioAtencion.desdeFila({
        'dia_semana': 3,
        'hora_desde': '09:00:00',
        'hora_hasta': '13:30:00',
      });

      expect(franja.dia, 3);
      expect(franja.nombreDelDia, 'Miércoles');
      expect(franja.rangoLegible, '09:00 a 13:30');
    });
  });

  group('controlador', () {
    late _ServidorFalso servidor;
    late ProviderContainer container;

    setUp(() async {
      servidor = _ServidorFalso();

      final client = SupabaseClient(
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
          'id': '44444444-4444-4444-8444-444444444444',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'aud': 'authenticated',
          'created_at': '2026-09-01T10:00:00Z',
        },
      }));

      container = ProviderContainer(overrides: [
        horariosRepositoryProvider.overrideWithValue(
          HorariosRepository(client),
        ),
      ]);
      addTearDown(container.dispose);
    });

    test('agrega franjas y detecta que hay cambios sin guardar', () async {
      await container.read(horariosProvider.future);
      final controlador = container.read(horariosProvider.notifier);

      controlador.agregar(lunesManana);
      controlador.agregar(lunesTarde);

      final estado = container.read(horariosProvider).value!;
      expect(estado.delDia(1), hasLength(2));
      expect(estado.hayCambios, isTrue);
      expect(estado.puedeGuardar, isTrue);
      expect(servidor.rpc, isEmpty, reason: 'todavía no se guardó nada');
    });

    test('una franja que se pisa se rechaza sin salir a la red', () async {
      await container.read(horariosProvider.future);
      final controlador = container.read(horariosProvider.notifier);

      controlador.agregar(lunesManana);
      controlador.agregar(
        const HorarioAtencion(dia: 1, desdeMinutos: 12 * 60, hastaMinutos: 15 * 60),
      );

      final estado = container.read(horariosProvider).value!;
      expect(estado.delDia(1), hasLength(1));
      expect(estado.error, contains('se pisa'));
    });

    test('el tope por día es el mismo que aplica la RPC', () async {
      await container.read(horariosProvider.future);
      final controlador = container.read(horariosProvider.notifier);

      for (var i = 0; i < HorarioAtencion.maximoPorDia + 1; i++) {
        controlador.agregar(
          HorarioAtencion(dia: 2, desdeMinutos: 60 * i, hastaMinutos: 60 * i + 30),
        );
      }

      final estado = container.read(horariosProvider).value!;
      expect(estado.delDia(2), hasLength(HorarioAtencion.maximoPorDia));
      expect(estado.error, contains('${HorarioAtencion.maximoPorDia} franjas'));
    });

    test('guardar manda la semana entera a la RPC y deja de haber cambios',
        () async {
      await container.read(horariosProvider.future);
      final controlador = container.read(horariosProvider.notifier);

      controlador.agregar(lunesManana);
      controlador.agregar(lunesTarde);
      await controlador.guardar();

      expect(servidor.rpc, ['reemplazar_horarios']);
      expect(servidor.ultimosParams['p_franjas'], [
        {'dia': 1, 'desde': '09:00', 'hasta': '13:00'},
        {'dia': 1, 'desde': '14:00', 'hasta': '18:00'},
      ]);

      final estado = container.read(horariosProvider).value!;
      expect(estado.hayCambios, isFalse);
      expect(estado.aviso, isNotNull);
    });

    test('el interruptor se guarda solo, sin pasar por «Guardar»', () async {
      await container.read(horariosProvider.future);

      await container.read(horariosProvider.notifier).cambiarDisponibilidad(true);

      expect(container.read(horariosProvider).value!.disponible, isTrue);
      expect(servidor.patchDisponible, isTrue);
    });

    test('si el servidor rechaza el interruptor, vuelve a como estaba',
        () async {
      await container.read(horariosProvider.future);
      servidor.fallarPatch = true;

      await container.read(horariosProvider.notifier).cambiarDisponibilidad(true);

      final estado = container.read(horariosProvider).value!;
      expect(estado.disponible, isFalse);
      expect(estado.error, isNotNull);
    });
  });
}

class _ServidorFalso {
  final List<String> rpc = [];
  Map<String, dynamic> ultimosParams = const {};
  bool? patchDisponible;
  bool fallarPatch = false;

  Future<http.Response> responder(http.Request pedido) async {
    final ruta = pedido.url.path;

    if (ruta.startsWith('/rest/v1/rpc/')) {
      rpc.add(ruta.split('/').last);
      ultimosParams = jsonDecode(pedido.body) as Map<String, dynamic>;

      final franjas = (ultimosParams['p_franjas'] as List)
          .map((f) => {
                'dia_semana': (f as Map)['dia'],
                'hora_desde': '${f['desde']}:00',
                'hora_hasta': '${f['hasta']}:00',
              })
          .toList();

      return _json(pedido, franjas, 200);
    }

    if (ruta == '/rest/v1/profesionales' && pedido.method == 'PATCH') {
      if (fallarPatch) {
        return _json(pedido, {'code': '42501', 'message': 'no'}, 400);
      }
      patchDisponible =
          (jsonDecode(pedido.body) as Map<String, dynamic>)['disponible'] as bool;
      return _json(pedido, {'disponible': patchDisponible}, 200);
    }

    if (ruta == '/rest/v1/profesionales') {
      return _json(pedido, {'disponible': patchDisponible ?? false}, 200);
    }

    // El listado inicial de horarios: vacío.
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
