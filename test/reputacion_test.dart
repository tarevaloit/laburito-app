import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/app/router.dart';
import 'package:laburito/core/config/env.dart';
import 'package:laburito/features/reputacion/data/reputacion_repository.dart';
import 'package:laburito/features/reputacion/domain/perfil_publico.dart';
import 'package:laburito/features/reputacion/presentation/screens/perfil_publico_screen.dart';
import 'package:laburito/features/reputacion/presentation/widgets/compartir_perfil.dart';
import 'package:laburito/features/reputacion/presentation/widgets/estrellas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-26 Compartir Perfil Público y CU-27 Acceder a Perfil por Link.
void main() {
  late _ServidorFalso servidor;
  late SupabaseClient client;

  setUp(() {
    servidor = _ServidorFalso();
    client = SupabaseClient(
      'https://proyecto.supabase.co',
      'clave-anon-de-mentira',
      httpClient: MockClient(servidor.responder),
    );
  });

  group('repositorio', () {
    test('el enlace del perfil es la Web publicada más /p/<slug>', () async {
      final enlace = await ReputacionRepository(client).enlacePerfil();

      expect(servidor.rpcs, ['obtener_enlace_perfil']);
      expect(enlace.toString(), '${Env.webUrl}/p/marcelo-gomez-7b1e2a');
      expect(enlace.scheme, 'https');
    });

    test('con la cuenta suspendida da CuentaSuspendidaException', () async {
      servidor.suspendida = true;

      await expectLater(
        ReputacionRepository(client).enlacePerfil(),
        throwsA(isA<CuentaSuspendidaException>()
            .having((e) => e.message, 'message', contains('inhabilitada'))),
      );
    });

    test('el perfil público llega con oficios, fotos firmadas y reseñas',
        () async {
      final perfil =
          await ReputacionRepository(client).perfilPublico('marcelo-gomez-7b1e2a');

      expect(servidor.funciones, ['perfil_publico']);
      expect(servidor.ultimoCuerpo, {'slug': 'marcelo-gomez-7b1e2a'});
      expect(perfil!.nombreCompleto, 'Marcelo Gómez');
      expect(perfil.oficios, ['Gas', 'Plomería']);
      expect(perfil.calificacionPromedio, 4.5);
      expect(perfil.portafolio.single.url, startsWith('https://'));
      expect(perfil.resenas.first.autor, 'Laura G.');
      expect(perfil.resenas.first.puntaje, 5);
    });

    test('un enlace roto o un perfil dado de baja da null (404)', () async {
      expect(await ReputacionRepository(client).perfilPublico('no-existe'),
          isNull);
    });
  });

  group('ruta pública', () {
    test('/p/<slug> y /calificar/<token> se abren sin sesión', () {
      expect(esRutaNeutral('/p/marcelo-gomez-7b1e2a'), isTrue);
      expect(esRutaNeutral('/calificar/abc'), isTrue);
      expect(esRutaNeutral('/legales/terminos'), isTrue);
      expect(esRutaNeutral('/pedidos'), isFalse);
      expect(esRutaNeutral('/profesional/billetera'), isFalse);
    });

    test('el promedio se escribe con coma decimal', () {
      expect(promedioLegible(4.75), '4,8');
      expect(promedioLegible(5), '5,0');
    });
  });

  group('recorrido del CU-27', () {
    Future<void> abrir(WidgetTester t, String slug) async {
      t.view.physicalSize = const Size(390, 1600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);

      await t.pumpWidget(ProviderScope(
        overrides: [
          reputacionRepositoryProvider.overrideWithValue(_RepoFalso()),
        ],
        child: MaterialApp(home: PerfilPublicoScreen(slug: slug)),
      ));
      await t.pumpAndSettle();
    }

    testWidgets('el Buscador ve nombre, verificación, oficios y reseñas',
        (t) async {
      await abrir(t, 'marcelo-gomez-7b1e2a');

      expect(find.text('Marcelo Gómez'), findsOneWidget);
      expect(find.text('Cuenta verificada'), findsOneWidget);
      expect(find.text('Plomería'), findsOneWidget);
      expect(find.text('4,5 · 2 reseñas'), findsOneWidget);
      expect(find.text('Laura G.'), findsOneWidget);
      expect(find.text('Vino rapidísimo y resolvió la pérdida.'), findsOneWidget);
      expect(find.text('Trabajos realizados'), findsOneWidget);
      expect(find.textContaining('todavía no subió fotos'), findsOneWidget);
    });

    testWidgets('un enlace roto muestra el 404 propio', (t) async {
      await abrir(t, 'no-existe');

      expect(find.text('Este perfil no está disponible'), findsOneWidget);
      expect(find.text('Ir a Laburito'), findsOneWidget);
    });
  });

  group('recorrido del CU-26', () {
    late List<String> portapapeles;
    late _RepoFalso repo;

    setUp(() {
      repo = _RepoFalso();
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

    Future<void> dibujar(WidgetTester t, {bool suspendida = false}) async {
      await t.pumpWidget(ProviderScope(
        overrides: [
          reputacionRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: Scaffold(body: CompartirPerfil(suspendida: suspendida)),
        ),
      ));
    }

    testWidgets('compartir copia el enlace y lo deja a la vista', (t) async {
      await dibujar(t);

      await t.tap(find.byKey(const Key('compartir-perfil')));
      await t.pumpAndSettle();

      final esperado = '${Env.webUrl}/p/marcelo-gomez-7b1e2a';
      expect(portapapeles, [esperado]);
      expect(find.text(esperado), findsOneWidget);
      expect(find.text('Enviar por WhatsApp'), findsOneWidget);
      expect(find.textContaining('Enlace copiado'), findsOneWidget);
    });

    testWidgets('si el servidor dice suspendida, alerta y desactiva el botón',
        (t) async {
      repo.suspendida = true;
      await dibujar(t);

      await t.tap(find.byKey(const Key('compartir-perfil')));
      await t.pumpAndSettle();

      expect(find.text('Cuenta inhabilitada'), findsOneWidget);
      await t.tap(find.text('Entendido'));
      await t.pumpAndSettle();

      final boton = t.widget<ButtonStyleButton>(
          find.byKey(const Key('compartir-perfil')));
      expect(boton.onPressed, isNull);
      expect(portapapeles, isEmpty);
    });

    testWidgets('una cuenta ya suspendida nace con el botón desactivado',
        (t) async {
      await dibujar(t, suspendida: true);

      final boton = t.widget<ButtonStyleButton>(
          find.byKey(const Key('compartir-perfil')));
      expect(boton.onPressed, isNull);
      expect(find.textContaining('no podés compartir'), findsOneWidget);
    });
  });

  test('PerfilPublico.desdeJson tolera listas vacías y sin promedio', () {
    final p = PerfilPublico.desdeJson({
      'slug': 'ana-perez-000000',
      'nombre': 'Ana',
      'apellido': 'Pérez',
    });
    expect(p.oficios, isEmpty);
    expect(p.resenas, isEmpty);
    expect(p.calificacionPromedio, isNull);
    expect(p.inicial, 'A');
  });
}

/// Repositorio en memoria para las pruebas de widget: sin HTTP, el reloj
/// simulado de `testWidgets` no se queda esperando una respuesta real.
class _RepoFalso implements ReputacionRepository {
  bool suspendida = false;

  @override
  Future<Uri> enlacePerfil() async {
    if (suspendida) {
      throw const CuentaSuspendidaException(
          'Tu cuenta está inhabilitada: no podés compartir tu perfil.');
    }
    return Uri.parse('${Env.webUrl}/p/marcelo-gomez-7b1e2a');
  }

  @override
  Future<PerfilPublico?> perfilPublico(String slug) async {
    if (slug == 'no-existe') return null;
    return PerfilPublico(
      slug: slug,
      nombre: 'Marcelo',
      apellido: 'Gómez',
      calificacionPromedio: 4.5,
      totalCalificaciones: 2,
      oficios: const ['Gas', 'Plomería'],
      resenas: [
        Resena(
          autor: 'Laura G.',
          puntaje: 5,
          comentario: 'Vino rapidísimo y resolvió la pérdida.',
          fecha: DateTime.utc(2026, 10, 10),
        ),
        Resena(autor: 'Javier M.', puntaje: 4, fecha: DateTime.utc(2026, 10, 2)),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ServidorFalso {
  bool suspendida = false;
  bool sinFotos = false;
  final rpcs = <String>[];
  final funciones = <String>[];
  Object? ultimoCuerpo;

  Future<http.Response> responder(http.Request pedido) async {
    final ruta = pedido.url.path;

    if (ruta.startsWith('/rest/v1/rpc/')) {
      rpcs.add(ruta.split('/').last);
      if (suspendida) {
        return _json(pedido, {
          'code': 'P0001',
          'message': 'Tu cuenta está inhabilitada: no podés compartir tu perfil.',
          'hint': 'cuenta_suspendida',
        }, 400);
      }
      return _json(pedido, 'marcelo-gomez-7b1e2a', 200);
    }

    if (ruta.startsWith('/functions/v1/')) {
      funciones.add(ruta.split('/').last);
      final cuerpo = jsonDecode(pedido.body) as Map<String, dynamic>;
      ultimoCuerpo = cuerpo;
      if (cuerpo['slug'] == 'no-existe') {
        return _json(pedido,
            {'error': 'Perfil no disponible', 'codigo': 'no_encontrado'}, 404);
      }
      return _json(pedido, {
        'slug': cuerpo['slug'],
        'nombre': 'Marcelo',
        'apellido': 'Gómez',
        'avatar_url': null,
        'descripcion': 'Plomero y gasista matriculado.',
        'verificado': true,
        'calificacion_promedio': 4.5,
        'total_calificaciones': 2,
        'oficios': ['Gas', 'Plomería'],
        'portafolio': sinFotos
            ? <dynamic>[]
            : [
                {'url': 'https://proyecto.supabase.co/firmada/1.jpg', 'descripcion': null},
              ],
        'resenas': [
          {
            'autor': 'Laura G.',
            'puntaje': 5,
            'comentario': 'Vino rapidísimo y resolvió la pérdida.',
            'fecha': '2026-10-10T15:00:00Z',
          },
          {
            'autor': 'Javier M.',
            'puntaje': 4,
            'comentario': null,
            'fecha': '2026-10-02T15:00:00Z',
          },
        ],
      }, 200);
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
