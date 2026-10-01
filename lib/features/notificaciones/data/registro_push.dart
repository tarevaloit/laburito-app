import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../perfil/data/perfil_repository.dart';
import 'dispositivos_repository.dart';
import 'servicio_push.dart';

part 'registro_push.g.dart';

/// CU-21 — Deja este teléfono registrado mientras haya un Profesional adentro.
///
/// Es un provider con efecto y no una llamada suelta en una pantalla porque el
/// registro tiene que pasar **una vez por sesión**, no una vez por pantalla
/// abierta: depende del perfil, no de dónde esté navegando la persona.
///
/// Qué hace, en orden: si quien está adentro es un Profesional, pide el
/// permiso del sistema, registra el token y se queda escuchando las
/// renovaciones —FCM rota el token solo, y un token viejo es un teléfono que
/// deja de recibir alertas sin avisar—. Con un Buscador no hace nada: las
/// alertas del CU-21 son del lado del Profesional.
///
/// Nunca tira: un permiso denegado, o un servidor caído, no pueden impedir que
/// la app se use. Sin token no hay push, y el Profesional ve los pedidos
/// entrando al tablero.
@Riverpod(keepAlive: true)
class RegistroPush extends _$RegistroPush {
  StreamSubscription<String>? _renovaciones;

  @override
  Future<String?> build() async {
    final perfil = await ref.watch(perfilCompletoProvider.future);
    if (perfil == null || !perfil.esProfesional) return null;

    final push = ref.watch(servicioPushProvider);
    final repo = ref.watch(dispositivosRepositoryProvider);

    ref.onDispose(() => _renovaciones?.cancel());

    if (!await push.pedirPermiso()) return null;

    _renovaciones?.cancel();
    _renovaciones = push.tokenRenovado.listen((_) => repo.registrar());

    try {
      return await repo.registrar();
    } on Object {
      return null;
    }
  }

  /// Se llama antes de cerrar sesión: el teléfono deja de recibir los pedidos
  /// de una cuenta que ya no está abierta acá.
  ///
  /// Si en esta sesión no se registró ningún token —un Buscador, un
  /// administrador, la web, un permiso denegado— no hay nada que dar de baja,
  /// y no se le vuelve a pedir el token al sistema: pedirlo puede abrir el
  /// diálogo de permisos justo cuando la persona quiere irse.
  Future<void> darDeBaja() async {
    if (state.valueOrNull == null) return;
    await ref.read(dispositivosRepositoryProvider).darDeBaja();
    state = const AsyncData(null);
  }
}
