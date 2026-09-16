import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/profesional/data/portafolio_repository.dart';
import 'package:laburito/features/profesional/domain/foto_portafolio.dart';
import 'package:laburito/features/profesional/presentation/controllers/portafolio_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-06 — Cargar Portafolio.
///
/// Lo que se cuida: que la foto se suba **antes** de insertar la fila —al
/// revés, una subida fallida dejaría una fila apuntando a un archivo que no
/// existe—, que si el insert falla el archivo no quede huérfano en el bucket, y
/// que el tope del cliente sea el mismo que aplica el trigger de la 0012.
void main() {
  const idProfesional = '44444444-4444-4444-8444-444444444444';
  final bytes = Uint8List.fromList(List.filled(32, 7));

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
        'id': idProfesional,
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
        'aud': 'authenticated',
        'created_at': '2026-09-01T10:00:00Z',
      },
    }));

    container = ProviderContainer(overrides: [
      portafolioRepositoryProvider.overrideWithValue(
        PortafolioRepository(client),
      ),
    ]);
    addTearDown(container.dispose);
  });

  test('la foto se sube antes de insertar la fila, y en la carpeta propia',
      () async {
    await container.read(portafolioProvider.future);
    await container.read(portafolioProvider.notifier).agregar(bytes);

    final subida = servidor.llamadas.indexWhere(
      (l) => l.startsWith('POST /storage/v1/object/portafolios/'),
    );
    final insert = servidor.llamadas.indexOf('POST /rest/v1/profesional_portafolio');

    expect(subida, isNonNegative);
    expect(
      insert,
      greaterThan(subida),
      reason: 'al revés, una subida fallida dejaría una fila apuntando a un '
          'archivo que no existe',
    );
    expect(
      servidor.rutaSubida,
      startsWith('$idProfesional/'),
      reason: 'el check de la 0012 exige la carpeta del dueño adelante, y la '
          'política de Storage autoriza por ese primer segmento',
    );
    expect(container.read(portafolioProvider).value!.fotos, hasLength(1));
  });

  test('si el insert falla, el archivo recién subido se borra', () async {
    await container.read(portafolioProvider.future);
    servidor.fallarInsert = true;

    await container.read(portafolioProvider.notifier).agregar(bytes);

    expect(servidor.borrados, hasLength(1),
        reason: 'un objeto que ninguna fila referencia es invisible y eterno');
    expect(container.read(portafolioProvider).value!.fotos, isEmpty);
    expect(container.read(portafolioProvider).value!.error, isNotNull);
  });

  test('borrar saca primero el archivo y después la fila', () async {
    servidor.filas = [
      {
        'id': 'foto-1',
        'storage_path': '$idProfesional/uno.jpg',
        'orden': 0,
        'descripcion': null,
      },
    ];

    final estado = await container.read(portafolioProvider.future);
    await container
        .read(portafolioProvider.notifier)
        .eliminar(estado.fotos.single);

    expect(
      servidor.llamadas.where((l) => !l.contains('signed')),
      containsAllInOrder([
        'DELETE /storage/v1/object/portafolios',
        'DELETE /rest/v1/profesional_portafolio',
      ]),
    );
    expect(container.read(portafolioProvider).value!.fotos, isEmpty);
  });

  test('con el portafolio lleno no se puede agregar', () async {
    servidor.filas = [
      for (var i = 0; i < FotoPortafolio.maximoPorProfesional; i++)
        {
          'id': 'foto-$i',
          'storage_path': '$idProfesional/$i.jpg',
          'orden': i,
          'descripcion': null,
        },
    ];

    final estado = await container.read(portafolioProvider.future);
    expect(estado.puedeAgregar, isFalse);

    await container.read(portafolioProvider.notifier).agregar(bytes);
    expect(
      servidor.rutaSubida,
      isNull,
      reason: 'el tope se respeta sin gastar una subida que el trigger de la '
          '0012 va a rechazar igual',
    );
  });

  test('el próximo orden sigue al mayor, no a la cantidad', () async {
    // Borrar la foto del medio deja un hueco: si el orden nuevo fuera
    // `fotos.length`, chocaría con el unique (profesional_id, orden).
    servidor.filas = [
      {'id': 'a', 'storage_path': '$idProfesional/a.jpg', 'orden': 0, 'descripcion': null},
      {'id': 'b', 'storage_path': '$idProfesional/b.jpg', 'orden': 5, 'descripcion': null},
    ];

    final estado = await container.read(portafolioProvider.future);
    expect(estado.proximoOrden, 6);
  });
}

class _ServidorFalso {
  final List<String> llamadas = [];
  final List<String> borrados = [];
  List<Map<String, dynamic>> filas = [];
  String? rutaSubida;
  bool fallarInsert = false;

  Future<http.Response> responder(http.Request pedido) async {
    final ruta = pedido.url.path;
    llamadas.add('${pedido.method} $ruta');

    if (pedido.method == 'POST' && ruta.startsWith('/storage/v1/object/portafolios/')) {
      rutaSubida = ruta.replaceFirst('/storage/v1/object/portafolios/', '');
      return _json({'Key': ruta}, 200, pedido);
    }

    if (ruta.startsWith('/storage/v1/object/remove') ||
        (pedido.method == 'DELETE' && ruta.startsWith('/storage/v1/object/'))) {
      borrados.add(ruta);
      return _json([], 200, pedido);
    }

    if (ruta.contains('sign')) {
      return _json(
        [
          for (final f in filas)
            {'path': f['storage_path'], 'signedURL': '/firmada?x=1', 'error': null},
        ],
        200,
        pedido,
      );
    }

    if (ruta == '/rest/v1/profesional_portafolio') {
      if (pedido.method == 'POST') {
        if (fallarInsert) {
          return _json({'code': '23514', 'message': 'no'}, 400, pedido);
        }
        return _json({
          'id': 'nueva',
          'storage_path': rutaSubida,
          'orden': 0,
          'descripcion': null,
        }, 201, pedido);
      }
      if (pedido.method == 'DELETE') return _json([], 200, pedido);
      return _json(filas, 200, pedido);
    }

    return _json([], 200, pedido);
  }

  http.Response _json(Object cuerpo, int codigo, http.Request pedido) =>
      http.Response(
        jsonEncode(cuerpo),
        codigo,
        headers: {'content-type': 'application/json'},
        request: pedido,
      );
}
