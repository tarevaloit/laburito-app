import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/mensajes_error.dart';
import '../../../core/providers/supabase_providers.dart';

part 'auth_repository.g.dart';

/// Acceso a Supabase Auth y a la tabla `perfiles`.
/// Cubre CU-01, CU-02, CU-03, CU-04, CU-08, CU-10 y CU-50.
class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get sesionActual => _client.auth.currentSession;
  User? get usuarioActual => _client.auth.currentUser;
  String? get idUsuario => _client.auth.currentUser?.id;

  /// CU-01 — Registrar Buscador.
  Future<void> registrarBuscador({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'tipo': 'buscador',
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'telefono': telefono.trim(),
        'acepto_legales_en': _ahora(),
      },
    );
  }

  /// CU-02 — Registrar Profesional.
  /// Las categorías viajan en el metadata: el trigger `handle_new_user` las
  /// inserta, porque durante el signUp todavía no hay sesión para las RLS.
  Future<void> registrarProfesional({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String dni,
    required String descripcion,
    required List<String> categorias,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'tipo': 'profesional',
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'telefono': telefono.trim(),
        'dni': dni.replaceAll(RegExp(r'[\.\s]'), ''),
        'descripcion': descripcion.trim(),
        'categorias': categorias,
        'acepto_legales_en': _ahora(),
      },
    );
  }

  /// Momento en que se aceptaron los Términos y la Política de Privacidad.
  /// Queda en el metadata de `auth.users`, que es evidencia del consentimiento
  /// sin necesidad de tocar el esquema (Ley 25.326).
  String _ahora() => DateTime.now().toUtc().toIso8601String();

  /// CU-08 — Validar Email mediante PIN de 6 dígitos.
  Future<void> verificarPin({
    required String email,
    required String pin,
  }) async {
    await _client.auth.verifyOTP(
      email: email.trim(),
      token: pin.trim(),
      type: OtpType.email,
    );
  }

  Future<void> reenviarPin(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email.trim());
  }

  /// CU-04 — Recuperar Contraseña, paso 1: enviar el código.
  /// Se responde igual exista o no la cuenta, para no filtrar qué correos
  /// están registrados.
  Future<void> enviarCodigoDeRecuperacion(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  /// CU-04, paso 2: validar el código. Deja una sesión abierta que habilita
  /// el cambio de contraseña sin necesidad de deep links.
  Future<void> verificarCodigoDeRecuperacion({
    required String email,
    required String pin,
  }) async {
    await _client.auth.verifyOTP(
      email: email.trim(),
      token: pin.trim(),
      type: OtpType.recovery,
    );
  }

  /// CU-04, paso 3: fijar la nueva contraseña y cerrar las demás sesiones,
  /// para que un dispositivo ajeno no siga adentro con la contraseña vieja.
  Future<void> actualizarPassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
    await _client.auth.signOut(scope: SignOutScope.others);
  }

  /// CU-03 — Iniciar Sesión.
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final perfil = await _perfilDeLaSesion();
    final estado = perfil?['estado'] as String?;

    // CU-34: el administrador que entra por el login general también deja su
    // registro de acceso con IP y hora, no solo el que usa /admin/ingresar.
    if (perfil?['tipo'] == 'administrador' && estado == 'activo') {
      await _client.rpc('registrar_acceso_admin');
    }

    if (estado == 'suspendido') {
      await cerrarSesion();
      throw const CuentaNoHabilitadaException(
        'Tu cuenta está suspendida. Escribinos para revisar la situación.',
      );
    }
    if (estado == 'baja') {
      await cerrarSesion();
      throw const CuentaNoHabilitadaException(
        'Esta cuenta fue dada de baja y no puede volver a utilizarse.',
      );
    }
  }

  /// CU-34 — El ingreso del panel valida el rol con la base (0035), que es
  /// también la que registra el intento; acá solo se validan las credenciales.
  Future<void> iniciarSesionSinValidarRol({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// CU-10 y CU-50 — Cerrar Sesión / Logout del Sistema.
  Future<void> cerrarSesion() => _client.auth.signOut();

  Future<Map<String, dynamic>?> _perfilDeLaSesion() async {
    final id = idUsuario;
    if (id == null) return null;

    return _client
        .from('perfiles')
        .select('estado, tipo')
        .eq('id', id)
        .maybeSingle();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider));
