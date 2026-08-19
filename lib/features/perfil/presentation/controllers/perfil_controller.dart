import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/perfil_repository.dart';

/// CU-05 y CU-11.
class PerfilController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  PerfilRepository get _repo => ref.read(perfilRepositoryProvider);

  Future<bool> _ejecutar(Future<void> Function() accion) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(accion);
    return !state.hasError;
  }

  Future<bool> guardar({
    required String nombre,
    required String apellido,
    required String telefono,
    String? descripcion,
    List<String>? categorias,
  }) async {
    final ok = await _ejecutar(() => _repo.actualizar(
          nombre: nombre,
          apellido: apellido,
          telefono: telefono,
          descripcion: descripcion,
          categorias: categorias,
        ));
    if (ok) ref.invalidate(perfilCompletoProvider);
    return ok;
  }

  Future<bool> cambiarAvatar(Uint8List bytes) async {
    final ok = await _ejecutar(() => _repo.subirAvatar(bytes));
    if (ok) ref.invalidate(perfilCompletoProvider);
    return ok;
  }

  Future<bool> darDeBaja({String? motivo}) =>
      _ejecutar(() => _repo.darDeBaja(motivo: motivo));
}

final perfilControllerProvider =
    AsyncNotifierProvider<PerfilController, void>(PerfilController.new);
