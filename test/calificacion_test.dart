import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/core/config/env.dart';
import 'package:laburito/features/reputacion/data/reputacion_repository.dart';
import 'package:laburito/features/reputacion/domain/calificacion.dart';
import 'package:laburito/features/reputacion/domain/perfil_publico.dart';
import 'package:laburito/features/reputacion/presentation/screens/calificar_screen.dart';
import 'package:laburito/features/reputacion/presentation/screens/mis_contactos_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-28 — Calificar Profesional (vía link de un solo uso).
void main() {
  group('dominio', () {
    final contacto = MiContacto(
      pedidoId: 'pedido-1',
      titulo: 'Pérdida bajo la pileta',
      estadoPedido: 'cerrado',
      nombreCorto: 'Laura G.',
      telefono: '11 2345-6789',
      desbloqueadoAt: DateTime.utc(2026, 10, 1),
    );

    test('el WhatsApp va al Buscador con el pedido y el enlace escritos', () {
      final enlace = Uri.parse('${Env.webUrl}/calificar/abc123');
      final chat = contacto.whatsAppConEnlace(enlace)!;

      expect(chat.host, 'wa.me');
      expect(chat.path, '/5491123456789');
      expect(chat.queryParameters['text'], contains('Hola Laura'));
      expect(chat.queryParameters['text'], contains('Pérdida bajo la pileta'));
      expect(chat.queryParameters['text'], endsWith(enlace.toString()));
    });

    test('sin un teléfono que se pueda marcar no hay chat', () {
      expect(
        contacto.copyWith(telefono: '1234').whatsAppConEnlace(Uri.parse('x')),
        isNull,
      );
    });

    test('leyendas de la Figura 3.7', () {
      expect(leyendaPuntaje(4), '¡Muy bueno!');
      expect(leyendaPuntaje(1), 'Malo');
      expect(leyendaPuntaje(0), '');
    });
  });

  group('repositorio', () {
    late _ServidorFalso servidor;
    late ReputacionRepository repo;

    setUp(() {
      servidor = _ServidorFalso();
      repo = ReputacionRepository(SupabaseClient(
        'https://proyecto.supabase.co',
        'clave-anon-de-mentira',
        httpClient: MockClient(servidor.responder),
      ));
    });

    test('el enlace de calificación es la Web más /calificar/<token>',
        () async {
      final enlace = await repo.enlaceCalificacion('pedido-1');

      expect(servidor.cuerpos['generar_enlace_calificacion'],
          {'p_pedido': 'pedido-1'});
      expect(enlace.toString(),
          '${Env.webUrl}/calificar/0123456789abcdef0123456789abcdef');
    });

    test('mis contactos llegan con su estado de calificación', () async {
      final lista = await repo.misContactos();

      expect(lista, hasLength(2));
      expect(lista.first.calificado, isFalse);
      expect(lista.last.puntaje, 5);
    });

    test('info del enlace: disponible con el nombre del Profesional',
        () async {
      final info = await repo.infoCalificacion('token-bueno');
      expect(info.estado, EstadoEnlaceCalificacion.disponible);
      expect(info.nombre, 'Marcelo');
      expect(info.inicial, 'M');

      final roto = await repo.infoCalificacion('token-roto');
      expect(roto.estado, EstadoEnlaceCalificacion.invalido);
    });

    test('calificar manda token, puntaje y comentario', () async {
      await repo.calificar('token-bueno', puntaje: 4, comentario: 'Prolijo');

      expect(servidor.cuerpos['registrar_calificacion'], {
        'p_token': 'token-bueno',
        'p_puntaje': 4,
        'p_comentario': 'Prolijo',
      });
    });

    test('con el enlace usado da EnlaceUsadoException', () async {
      await expectLater(
        repo.calificar('token-usado', puntaje: 5),
        throwsA(isA<EnlaceUsadoException>()),
      );
    });
  });

  group('recorrido de la Figura 3.7', () {
    late _RepoFalso repo;

    Future<void> abrir(WidgetTester t, String token) async {
      t.view.physicalSize = const Size(390, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);

      await t.pumpWidget(ProviderScope(
        overrides: [reputacionRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(home: CalificarScreen(token: token)),
      ));
      await t.pumpAndSettle();
    }

    setUp(() => repo = _RepoFalso());

    testWidgets('sin estrellas no envía; con 4 y comentario, agradece',
        (t) async {
      await abrir(t, 'token-bueno');

      expect(find.text('¿Cómo fue tu experiencia con Marcelo?'), findsOneWidget);

      await t.tap(find.text('Enviar calificación'));
      await t.pumpAndSettle();
      expect(find.textContaining('Elegí de 1 a 5 estrellas'), findsOneWidget);
      expect(repo.calificaciones, isEmpty);

      await t.tap(find.byKey(const Key('estrella-4')));
      await t.pump();
      expect(find.text('¡Muy bueno!'), findsOneWidget);

      await t.enterText(find.byKey(const Key('comentario-calificacion')),
          'Resolvió la pérdida en el momento.');
      await t.tap(find.text('Enviar calificación'));
      await t.pumpAndSettle();

      expect(repo.calificaciones,
          [(4, 'Resolvió la pérdida en el momento.')]);
      expect(find.text('¡Gracias por tu calificación!'), findsOneWidget);
    });

    testWidgets('un enlace ya usado bloquea el formulario', (t) async {
      await abrir(t, 'token-usado');

      expect(find.text('Este enlace ya se usó'), findsOneWidget);
      expect(find.text('Enviar calificación'), findsNothing);
    });

    testWidgets('un enlace inválido lo dice y no muestra el formulario',
        (t) async {
      await abrir(t, 'token-roto');

      expect(find.text('Este enlace no es válido'), findsOneWidget);
      expect(find.text('Enviar calificación'), findsNothing);
    });

    testWidgets('si se usó en otra pestaña mientras tanto, se bloquea',
        (t) async {
      repo.usarAlEnviar = true;
      await abrir(t, 'token-bueno');

      await t.tap(find.byKey(const Key('estrella-5')));
      await t.tap(find.text('Enviar calificación'));
      await t.pumpAndSettle();

      expect(find.text('Este enlace ya se usó'), findsOneWidget);
    });
  });

  group('recorrido de Mis contactos', () {
    late List<String> portapapeles;

    setUp(() {
      portapapeles = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (llamada) async {
        if (llamada.method == 'Clipboard.setData') {
          portapapeles.add((llamada.arguments as Map)['text'] as String);
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('pedir calificación genera el enlace y copia el mensaje',
        (t) async {
      final repo = _RepoFalso();
      await t.pumpWidget(ProviderScope(
        overrides: [reputacionRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: MisContactosScreen()),
      ));
      await t.pumpAndSettle();

      expect(find.text('Pérdida bajo la pileta'), findsOneWidget);
      expect(find.text('Ya te calificó'), findsOneWidget);

      await t.tap(find.byKey(const Key('pedir-calificacion-pedido-1')));
      // Sin pumpAndSettle: el aviso queda en pantalla con su temporizador.
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }

      expect(repo.enlacesPedidos, ['pedido-1']);
      expect(portapapeles.single, contains('/calificar/token-nuevo'));
      expect(portapapeles.single, contains('Hola Laura'));
    });
  });
}

class _RepoFalso implements ReputacionRepository {
  bool usarAlEnviar = false;
  final calificaciones = <(int, String?)>[];
  final enlacesPedidos = <String>[];

  @override
  Future<EnlaceCalificacion> infoCalificacion(String token) async =>
      switch (token) {
        'token-bueno' => const EnlaceCalificacion(
            estado: EstadoEnlaceCalificacion.disponible, nombre: 'Marcelo'),
        'token-usado' => const EnlaceCalificacion(
            estado: EstadoEnlaceCalificacion.usado, nombre: 'Marcelo'),
        _ => const EnlaceCalificacion(estado: EstadoEnlaceCalificacion.invalido),
      };

  @override
  Future<void> calificar(String token,
      {required int puntaje, String? comentario}) async {
    if (usarAlEnviar) {
      throw const EnlaceUsadoException('Este enlace ya se usó para calificar.');
    }
    calificaciones.add((puntaje, comentario));
  }

  @override
  Future<List<MiContacto>> misContactos() async => [
        MiContacto(
          pedidoId: 'pedido-1',
          titulo: 'Pérdida bajo la pileta',
          estadoPedido: 'cerrado',
          nombreCorto: 'Laura G.',
          telefono: '11 2345-6789',
          desbloqueadoAt: DateTime.utc(2026, 10, 1),
        ),
        MiContacto(
          pedidoId: 'pedido-2',
          titulo: 'Instalar un termotanque',
          estadoPedido: 'cerrado',
          nombreCorto: 'Javier M.',
          desbloqueadoAt: DateTime.utc(2026, 9, 20),
          calificado: true,
          puntaje: 5,
        ),
      ];

  @override
  Future<Uri> enlaceCalificacion(String pedidoId) async {
    enlacesPedidos.add(pedidoId);
    return Uri.parse('${Env.webUrl}/calificar/token-nuevo');
  }

  @override
  Future<PerfilPublico?> perfilPublico(String slug) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ServidorFalso {
  final cuerpos = <String, Object?>{};

  Future<http.Response> responder(http.Request pedido) async {
    final funcion = pedido.url.pathSegments.last;
    final cuerpo = pedido.body.isEmpty ? null : jsonDecode(pedido.body);
    final params = cuerpo is Map<String, dynamic> ? cuerpo : const <String, dynamic>{};
    cuerpos[funcion] = params;

    switch (funcion) {
      case 'generar_enlace_calificacion':
        return _json(pedido, '0123456789abcdef0123456789abcdef', 200);
      case 'mis_contactos':
        return _json(pedido, [
          {
            'pedido_id': 'pedido-1',
            'titulo': 'Pérdida',
            'estado_pedido': 'cerrado',
            'nombre_corto': 'Laura G.',
            'telefono': '11 2345-6789',
            'desbloqueado_at': '2026-10-01T10:00:00Z',
            'calificado': false,
            'puntaje': null,
          },
          {
            'pedido_id': 'pedido-2',
            'titulo': 'Termotanque',
            'estado_pedido': 'cerrado',
            'nombre_corto': 'Javier M.',
            'telefono': null,
            'desbloqueado_at': '2026-09-20T10:00:00Z',
            'calificado': true,
            'puntaje': 5,
          },
        ], 200);
      case 'enlace_calificacion_info':
        return _json(
          pedido,
          params['p_token'] == 'token-bueno'
              ? {'estado': 'disponible', 'nombre': 'Marcelo', 'apellido': 'Gómez'}
              : {'estado': 'invalido'},
          200,
        );
      case 'registrar_calificacion':
        if (params['p_token'] == 'token-usado') {
          return _json(pedido, {
            'code': 'P0001',
            'message': 'Este enlace ya se usó para calificar.',
            'hint': 'enlace_usado',
          }, 400);
        }
        return _json(pedido, {'nombre': 'Marcelo'}, 200);
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
