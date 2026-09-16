import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'servicio_push.g.dart';

/// De dónde sale el token del dispositivo y por dónde llegan las
/// notificaciones abiertas (CU-21).
///
/// Es una interfaz y no una llamada directa a `firebase_messaging` por una
/// razón concreta: **el proyecto de Firebase todavía no existe**. Agregar el
/// paquete hoy obliga a tener `google-services.json` en Android —sin él el
/// build falla— y `firebase_options.dart`, que los genera FlutterFire contra
/// un proyecto real. Con la interfaz, todo lo que está de este lado —el
/// registro del token, la baja al cerrar sesión, la RPC de traspaso— se
/// escribe, se prueba y se commitea igual, y el día que estén las credenciales
/// entra una sola implementación nueva sin tocar nada más.
abstract interface class ServicioPush {
  /// Pide el permiso del sistema. En Android 13+ y en iOS es un diálogo; en
  /// Web, el del navegador. `false` si la persona dijo que no.
  Future<bool> pedirPermiso();

  /// El token de esta instalación, o `null` si no hay permiso o no hay push.
  Future<String?> token();

  /// FCM rota el token solo (reinstalación, restauración de backup). Cada
  /// valor nuevo hay que volver a registrarlo.
  Stream<String> get tokenRenovado;

  /// El id de pedido de la notificación que abrió la app, si se abrió así.
  Stream<String> get pedidosAbiertos;
}

/// La implementación que corre hasta que exista el proyecto de Firebase.
///
/// No falla ni avisa: sin push, la app funciona igual y el Profesional ve los
/// pedidos entrando al tablero (CU-43). Que no haya notificaciones es una
/// degradación, no un error.
class PushNoConfigurado implements ServicioPush {
  const PushNoConfigurado();

  @override
  Future<bool> pedirPermiso() async => false;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRenovado => const Stream.empty();

  @override
  Stream<String> get pedidosAbiertos => const Stream.empty();
}

/// Se reemplaza con un `override` el día que entre `firebase_messaging`, y en
/// los tests por una implementación de mentira.
@Riverpod(keepAlive: true)
ServicioPush servicioPush(Ref ref) => const PushNoConfigurado();

/// Con qué nombre viaja la plataforma a la base. Son los tres valores que
/// acepta el `check` de `profesional_dispositivos` (migración 0012).
String plataformaActual() {
  if (kIsWeb) return 'web';
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => 'ios',
    _ => 'android',
  };
}

/// El id del pedido de cada notificación que la persona abrió. Lo escucha
/// `LaburitoApp` para navegar al detalle (CU-22 lo va a mostrar del lado del
/// Profesional; hoy abre la misma pantalla que ve el Buscador).
@Riverpod(keepAlive: true)
Stream<String> pedidosAbiertos(Ref ref) =>
    ref.watch(servicioPushProvider).pedidosAbiertos;
