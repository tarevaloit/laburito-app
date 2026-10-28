import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/mensajes_error.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../billetera/domain/paquete_tokens.dart';
import '../domain/dashboard.dart';
import 'cupon.dart';

part 'admin_repository.g.dart';

/// La contraseña que se pidió para confirmar una operación crítica no es la
/// del administrador (paso 4 del CU-40).
class ReautenticacionFallidaException implements ErrorDeNegocio {
  const ReautenticacionFallidaException();

  @override
  String get message => 'La contraseña no es correcta. No se guardó ningún cambio.';

  @override
  String toString() => message;
}

/// CU-40 y CU-52 — Las primeras operaciones del administrador (migración 0024).
/// El Sprint 6 suma el ingreso al panel (CU-34) y el Dashboard (CU-38).
class AdminRepository {
  const AdminRepository(this._client);

  final SupabaseClient _client;

  // ---------------------------------------------------------------- CU-34

  /// Registra el intento con IP y hora (0035) y dice si la cuenta es de un
  /// administrador activo. La IP la toma la base de los encabezados del
  /// pedido: la app no la manda.
  Future<bool> registrarAcceso() async =>
      await _client.rpc('registrar_acceso_admin') as bool? ?? false;

  Future<List<AccesoAdmin>> accesosRecientes({int limite = 10}) async {
    final filas = await _client.rpc('accesos_admin_recientes',
        params: {'p_limite': limite}) as List;
    return [
      for (final f in filas) AccesoAdmin.desdeFila(f as Map<String, dynamic>),
    ];
  }

  // ---------------------------------------------------------------- CU-38

  Future<Dashboard> dashboard({
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final json = await _client.rpc('dashboard_admin', params: {
      'p_desde': _dia(desde),
      'p_hasta': _dia(hasta),
    });
    return Dashboard.desdeJson(json as Map<String, dynamic>);
  }

  static String _dia(DateTime f) => '${f.year.toString().padLeft(4, '0')}-'
      '${f.month.toString().padLeft(2, '0')}-'
      '${f.day.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------- CU-40

  /// Todos los paquetes, incluidos los inactivos: la política de la 0021 se los
  /// deja ver al admin.
  Future<List<PaqueteTokens>> paquetes() async {
    final filas = await _client
        .from('paquetes_tokens')
        .select('id, nombre, cantidad, precio_ars, activo, orden')
        .order('orden');
    return [
      for (final f in filas as List)
        PaqueteTokens.desdeFila(f as Map<String, dynamic>),
    ];
  }

  /// Paso 4 del CU-40: la operación es crítica, así que se vuelve a pedir la
  /// contraseña. Se valida contra Supabase Auth con el correo de la sesión
  /// abierta; la base no ve la contraseña nunca.
  Future<void> reautenticar(String password) async {
    final email = _client.auth.currentUser?.email;
    if (email == null) throw StateError('No hay sesión activa');
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException {
      throw const ReautenticacionFallidaException();
    }
  }

  Future<PaqueteTokens> actualizarPrecio(String paqueteId, int precio) async {
    final filas = await _client.rpc('actualizar_precio_paquete', params: {
      'p_paquete': paqueteId,
      'p_precio': precio,
    }) as List;
    return PaqueteTokens.desdeFila(filas.first as Map<String, dynamic>);
  }

  // ---------------------------------------------------------------- CU-52

  Future<List<Cupon>> cupones() async {
    final filas = await _client
        .from('cupones')
        .select('id, codigo, tokens, vence_at, limite_usos, usos, activo')
        .order('created_at', ascending: false);
    return [
      for (final f in filas as List) Cupon.desdeFila(f as Map<String, dynamic>),
    ];
  }

  Future<Cupon> crearCupon({
    required String codigo,
    required int tokens,
    required DateTime vence,
    int? limiteUsos,
  }) async {
    final dia = '${vence.year.toString().padLeft(4, '0')}-'
        '${vence.month.toString().padLeft(2, '0')}-'
        '${vence.day.toString().padLeft(2, '0')}';

    final filas = await _client.rpc('crear_cupon', params: {
      'p_codigo': codigo,
      'p_tokens': tokens,
      'p_vence': dia,
      'p_limite_usos': limiteUsos,
    }) as List;
    return Cupon.desdeFila(filas.first as Map<String, dynamic>);
  }
}

@Riverpod(keepAlive: true)
AdminRepository adminRepository(Ref ref) =>
    AdminRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<PaqueteTokens>> paquetesAdmin(Ref ref) =>
    ref.watch(adminRepositoryProvider).paquetes();

@riverpod
Future<List<Cupon>> cuponesAdmin(Ref ref) =>
    ref.watch(adminRepositoryProvider).cupones();

/// CU-38. El rango es un parámetro de la familia: cambiarlo dispara la
/// consulta de ese rango sin perder la anterior si se vuelve a ella.
@riverpod
Future<Dashboard> dashboardAdmin(Ref ref, DateTime desde, DateTime hasta) =>
    ref.watch(adminRepositoryProvider).dashboard(desde: desde, hasta: hasta);

@riverpod
Future<List<AccesoAdmin>> accesosAdmin(Ref ref) =>
    ref.watch(adminRepositoryProvider).accesosRecientes();
