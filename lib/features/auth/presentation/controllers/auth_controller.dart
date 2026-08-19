import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../perfil/data/perfil_repository.dart';
import '../../data/auth_repository.dart';

/// Orquesta las operaciones de autenticación y expone su estado de carga.
/// Cada método devuelve `true` si la operación terminó sin error.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> _ejecutar(Future<void> Function() accion) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(accion);
    return !state.hasError;
  }

  /// CU-01
  Future<bool> registrarBuscador({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String password,
  }) =>
      _ejecutar(() => _repo.registrarBuscador(
            nombre: nombre,
            apellido: apellido,
            email: email,
            telefono: telefono,
            password: password,
          ));

  /// CU-02
  Future<bool> registrarProfesional({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String dni,
    required String descripcion,
    required List<String> categorias,
    required String password,
  }) =>
      _ejecutar(() => _repo.registrarProfesional(
            nombre: nombre,
            apellido: apellido,
            email: email,
            telefono: telefono,
            dni: dni,
            descripcion: descripcion,
            categorias: categorias,
            password: password,
          ));

  /// CU-08
  Future<bool> verificarPin({required String email, required String pin}) =>
      _ejecutar(() => _repo.verificarPin(email: email, pin: pin));

  Future<bool> reenviarPin(String email) =>
      _ejecutar(() => _repo.reenviarPin(email));

  /// CU-03
  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) =>
      _ejecutar(() => _repo.iniciarSesion(email: email, password: password));

  /// CU-04 — paso 1
  Future<bool> enviarCodigoDeRecuperacion(String email) =>
      _ejecutar(() => _repo.enviarCodigoDeRecuperacion(email));

  /// CU-04 — paso 2
  Future<bool> verificarCodigoDeRecuperacion({
    required String email,
    required String pin,
  }) =>
      _ejecutar(
          () => _repo.verificarCodigoDeRecuperacion(email: email, pin: pin));

  /// CU-04 — paso 3
  Future<bool> actualizarPassword(String password) =>
      _ejecutar(() => _repo.actualizarPassword(password));

  /// CU-10 y CU-50: cierra la sesión e invalida el estado en memoria.
  Future<void> cerrarSesion() async {
    await _ejecutar(_repo.cerrarSesion);
    ref.invalidate(perfilCompletoProvider);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
