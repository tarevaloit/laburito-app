import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/pedidos/data/pedidos_repository.dart';
import 'package:laburito/features/pedidos/domain/pedido_estado.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-17 — Qué consulta sale de verdad hacia PostgREST.
///
/// La búsqueda y el filtro se resuelven **en el servidor**, así que lo único
/// que se puede verificar del lado del cliente es que la URL que se arma sea
/// la correcta. Y hay un detalle que no perdona: el filtro `or` de PostgREST
/// usa comas para separar condiciones, así que una coma escrita por el usuario
/// parte la expresión y devuelve un 400 en vez de cero resultados.
void main() {
  const buscadorId = '11111111-1111-4111-8111-111111111111';

  late List<Uri> pedidas;
  late PedidosRepository repo;

  setUp(() async {
    pedidas = [];

    final client = SupabaseClient(
      'https://proyecto.supabase.co',
      'clave-anon-de-mentira',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((peticion) async {
        pedidas.add(peticion.url);
        // `content-range` no es decorativo: `range()` pagina con el
        // encabezado `Range` y el cliente espera la respuesta correspondiente.
        // Sin él, postgrest revienta al parsear y el repositorio lo envuelve
        // en un «No pudimos completar la operación» que no dice nada.
        return http.Response(
          '[]',
          200,
          // `request` va explícito: `MockClient` lo copia de la respuesta que
          // uno arma, no de la petición que recibió, y postgrest lo lee sin
          // preguntar (`response.request!.method`). Sin esto, cualquier
          // consulta paginada muere con un «Null check operator used on a null
          // value» que no tiene nada que ver con lo que se está probando.
          request: peticion,
          headers: {
            'content-type': 'application/json; charset=utf-8',
            // `range()` pagina con el encabezado `Range` y el cliente espera
            // la respuesta correspondiente.
            'content-range': '0-0/0',
          },
        );
      }),
    );

    await client.auth.setInitialSession(jsonEncode({
      'access_token': 'token-de-mentira',
      'token_type': 'bearer',
      'refresh_token': 'refresh-de-mentira',
      'expires_in': 3600,
      'user': {
        'id': buscadorId,
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
        'aud': 'authenticated',
        'created_at': '2026-09-01T10:00:00Z',
      },
    }));

    repo = PedidosRepository(client);
  });

  /// La consulta legible: los espacios viajan como `+` en el query string, y
  /// leer las aserciones con `+` en el medio de las palabras no ayuda a nadie.
  String consulta() =>
      Uri.decodeFull(pedidas.single.query).replaceAll('+', ' ');

  group('filtro por grupo', () {
    test('«Activos» pide los dos estados en un solo `in`', () async {
      await repo.listarMisPedidos(filtro: FiltroPedidos.activos);

      // PostgREST entrecomilla los valores de un `in`.
      expect(consulta(), contains('estado=in.("publicado","pausado")'));
    });

    test('siempre filtra por buscador_id, aunque haya RLS', () async {
      // Sobre `pedidos` hay dos políticas de SELECT: la de los propios y la de
      // los publicados vigentes de cualquiera. Sin este filtro, «Mis pedidos»
      // mostraría también los de los demás.
      await repo.listarMisPedidos(filtro: FiltroPedidos.cerrados);

      expect(consulta(), contains('buscador_id=eq.$buscadorId'));
    });

    test('ordena del más nuevo al más viejo', () async {
      await repo.listarMisPedidos(filtro: FiltroPedidos.activos);

      expect(consulta(), contains('order=created_at.desc'));
    });
  });

  group('paginación', () {
    test('la primera página arranca en cero y pide 20', () async {
      await repo.listarMisPedidos(limit: 20);

      final q = consulta();
      expect(q, contains('offset=0'));
      expect(q, contains('limit=20'));
    });

    test('la segunda página arranca donde terminó la primera', () async {
      // Es lo que sostiene el scroll infinito: el offset sale del largo de lo
      // que ya está en pantalla. Si se corriera, habría pedidos repetidos o
      // salteados, y ninguna de las dos cosas se nota mirando la lista.
      await repo.listarMisPedidos(limit: 20, offset: 20);

      final q = consulta();
      expect(q, contains('offset=20'));
      expect(q, contains('limit=20'));
    });
  });

  group('búsqueda por texto', () {
    test('busca en título y descripción con ilike', () async {
      await repo.listarMisPedidos(busqueda: 'termotanque');

      expect(
        consulta(),
        contains('or=(titulo.ilike.%termotanque%,'
            'descripcion.ilike.%termotanque%)'),
      );
    });

    test('menos de dos caracteres no filtra nada', () async {
      // Con una sola letra el `ilike` recorre la tabla entera para devolver
      // casi todo: no vale el viaje.
      await repo.listarMisPedidos(busqueda: 'a');

      expect(consulta(), isNot(contains('ilike')));
    });

    test('el texto vacío o de espacios tampoco filtra', () async {
      await repo.listarMisPedidos(busqueda: '   ');

      expect(consulta(), isNot(contains('ilike')));
    });

    test('una coma no parte la expresión `or`', () async {
      // Escrito tal cual, «cocina, baño» generaría
      // `or=(titulo.ilike.%cocina, baño%,...)`: PostgREST lee esa coma como
      // separador de condiciones y contesta 400.
      await repo.listarMisPedidos(busqueda: 'cocina, baño');

      final q = consulta();
      expect(q, contains('or=(titulo.ilike.%cocina  baño%'));
      expect(q, isNot(contains('%cocina, baño%')));
    });

    test('los paréntesis tampoco', () async {
      await repo.listarMisPedidos(busqueda: 'pileta (rota)');

      // Los paréntesis se reemplazan por espacios y el resultado se recorta.
      expect(consulta(), contains('or=(titulo.ilike.%pileta  rota%'));
    });

    test('el filtro por grupo y la búsqueda conviven', () async {
      await repo.listarMisPedidos(
        filtro: FiltroPedidos.cerrados,
        busqueda: 'termotanque',
      );

      final q = consulta();
      expect(q, contains('estado=in.("cerrado")'));
      expect(q, contains('ilike.%termotanque%'));
    });
  });

  group('contadores', () {
    test('traen solo la columna estado, no los pedidos enteros', () async {
      await repo.contarPorEstado();

      final q = consulta();
      expect(q, contains('select=estado'));
      expect(q, isNot(contains('descripcion')),
          reason: 'contar no necesita traerse el pedido entero');
      expect(q, contains('buscador_id=eq.$buscadorId'));
    });
  });
}
