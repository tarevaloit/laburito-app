import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laburito/features/notificaciones/data/dispositivos_repository.dart';
import 'package:laburito/features/notificaciones/data/registro_push.dart';
import 'package:laburito/features/notificaciones/data/servicio_push.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-21 b — El teléfono que recibe las alertas.
///
/// Lo que se cuida acá: que el token salga por las RPC de la migración 0017 —y
/// no por un upsert de PostgREST, que no puede hacer el traspaso entre
/// cuentas—, que sin push la app no llame a la red, que la baja no pueda
/// romper el cierre de sesión, y que a un Buscador no se le registre nada.
void main() {
  const token = 'tttttttttttttttttttttttttttttttttttttttt';

  const perfilProfesional = PerfilCompleto(
    id: '44444444-4444-4444-8444-444444444444',
    tipo: 'profesional',
    nombre: 'Ana',
    apellido: 'Gómez',
    email: 'ana@example.com',
    estado: 'activo',
    estadoVerificacion: 'aprobado',
  );

  const perfilBuscador = PerfilCompleto(
    id: '55555555-5555-4555-8555-555555555555',
    tipo: 'buscador',
    nombre: 'Juan',
    apellido: 'Pérez',
    email: 'juan@example.com',
    estado: 'activo',
  );

  late _ServidorFalso servidor;

  Future<SupabaseClient> cliente() async {
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
        'id': perfilProfesional.id,
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
        'aud': 'authenticated',
        'created_at': '2026-09-01T10:00:00Z',
      },
    }));

    return client;
  }

  setUp(() => servidor = _ServidorFalso());

  group('repositorio', () {
    test('registrar manda el token y la plataforma por la RPC de la 0017',
        () async {
      final repo = DispositivosRepository(
        await cliente(),
        _PushFalso(token: token),
      );

      expect(await repo.registrar(), token);
      expect(servidor.llamadas, ['POST /rest/v1/rpc/registrar_dispositivo']);
      expect(servidor.ultimosParams['p_token'], token);
      expect(
        servidor.ultimosParams['p_plataforma'],
        isIn(['android', 'ios', 'web']),
      );
    });

    test('sin push configurado no se llama a la red', () async {
      final repo = DispositivosRepository(
        await cliente(),
        const PushNoConfigurado(),
      );

      expect(await repo.registrar(), isNull);
      expect(servidor.llamadas, isEmpty);
    });

    test('la baja usa su propia RPC', () async {
      final repo = DispositivosRepository(
        await cliente(),
        _PushFalso(token: token),
      );

      await repo.darDeBaja();

      expect(servidor.llamadas, ['POST /rest/v1/rpc/dar_de_baja_dispositivo']);
      expect(servidor.ultimosParams['p_token'], token);
    });

    test('si la baja falla, no tira: cerrar sesión no se puede romper por esto',
        () async {
      servidor.fallar = true;
      final repo = DispositivosRepository(
        await cliente(),
        _PushFalso(token: token),
      );

      await expectLater(repo.darDeBaja(), completes);
    });
  });

  group('registro por sesión', () {
    ProviderContainer contenedor(PerfilCompleto? perfil, _PushFalso push) {
      final container = ProviderContainer(
        overrides: [
          perfilCompletoProvider.overrideWith((ref) async => perfil),
          servicioPushProvider.overrideWithValue(push),
          dispositivosRepositoryProvider.overrideWith(
            (ref) => _RepoFalso(),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('a un Profesional se le registra el teléfono', () async {
      final push = _PushFalso(token: token);
      final container = contenedor(perfilProfesional, push);

      expect(await container.read(registroPushProvider.future), token);
      expect(push.permisoPedido, isTrue);
    });

    test('a un Buscador no: las alertas son del lado del Profesional',
        () async {
      final push = _PushFalso(token: token);
      final container = contenedor(perfilBuscador, push);

      expect(await container.read(registroPushProvider.future), isNull);
      expect(push.permisoPedido, isFalse,
          reason: 'ni siquiera se le muestra el diálogo del sistema');
    });

    test('sin permiso no hay token registrado', () async {
      final push = _PushFalso(token: token, permiso: false);
      final container = contenedor(perfilProfesional, push);

      expect(await container.read(registroPushProvider.future), isNull);
    });

    test('sin sesión tampoco', () async {
      final container = contenedor(null, _PushFalso(token: token));

      expect(await container.read(registroPushProvider.future), isNull);
    });
  });
}

class _PushFalso implements ServicioPush {
  _PushFalso({required String token, this.permiso = true})
      : tokenDelTelefono = token;

  final String tokenDelTelefono;
  final bool permiso;
  bool permisoPedido = false;

  @override
  Future<bool> pedirPermiso() async {
    permisoPedido = true;
    return permiso;
  }

  @override
  Future<String?> token() async => permiso ? tokenDelTelefono : null;

  @override
  Stream<String> get tokenRenovado => const Stream.empty();

  @override
  Stream<String> get pedidosAbiertos => const Stream.empty();
}

/// El repositorio visto desde el controlador: devuelve el token sin red.
class _RepoFalso implements DispositivosRepository {
  @override
  Future<String?> registrar() async =>
      'tttttttttttttttttttttttttttttttttttttttt';

  @override
  Future<void> darDeBaja() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ServidorFalso {
  final List<String> llamadas = [];
  Map<String, dynamic> ultimosParams = const {};
  bool fallar = false;

  Future<http.Response> responder(http.Request pedido) async {
    llamadas.add('${pedido.method} ${pedido.url.path}');
    ultimosParams = jsonDecode(pedido.body) as Map<String, dynamic>;

    if (fallar) {
      return http.Response(
        jsonEncode({'code': '42501', 'message': 'no'}),
        400,
        headers: {'content-type': 'application/json'},
        request: pedido,
      );
    }

    return http.Response(
      'null',
      200,
      headers: {'content-type': 'application/json'},
      request: pedido,
    );
  }
}
