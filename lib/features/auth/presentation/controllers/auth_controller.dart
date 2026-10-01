import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../notificaciones/data/registro_push.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../data/auth_repository.dart';

part 'auth_controller.g.dart';

/// Orquesta las operaciones de autenticación y expone su estado de carga.
/// Cada método devuelve `true` si la operación terminó sin error.
///
/// `keepAlive`: era un `AsyncNotifierProvider` a mano, que no se descarta. Con
/// autoDispose el notificador podría morir entre el `read(...notifier)` y el
/// `read(...).error` que las pantallas hacen justo después, y el mensaje de
/// error se perdería.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
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
    // Primero el dispositivo, después la sesión: la baja del token necesita
    // `auth.uid()`, así que después del signOut ya no se podría hacer y el
    // teléfono seguiría recibiendo los pedidos de esta cuenta (CU-21).
    //
    // Y nunca impide salir: si la baja falla o tarda, la sesión se cierra
    // igual (decisión del 16/09). Un token de más se limpia solo; quedarse
    // adentro sin poder salir no tiene arreglo para quien lo sufre.
    try {
      await ref
          .read(registroPushProvider.notifier)
          .darDeBaja()
          .timeout(const Duration(seconds: 8));
    } on Object catch (error) {
      if (kDebugMode) debugPrint('La baja del dispositivo falló: $error');
    }

    await _ejecutar(_repo.cerrarSesion);
    ref.invalidate(perfilCompletoProvider);
  }
}
