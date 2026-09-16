import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'servicio_push.g.dart';

/// De dónde sale el token del dispositivo y por dónde llegan las
/// notificaciones abiertas (CU-21).
///
/// Es una interfaz y no una llamada directa a `firebase_messaging` por lo que
/// costó escribirla sin el proyecto de Firebase: mientras no existían
/// `google-services.json` ni `firebase_options.dart` (los genera FlutterFire
/// contra un proyecto real, ver `docs/FIREBASE.md`), todo lo de este lado
/// —el registro del token, la baja al cerrar sesión, la RPC de traspaso— se
/// escribió, se probó y se commiteó igual contra [PushNoConfigurado]. Ahora
/// que el proyecto existe, [ServicioPushFirebase] es la implementación real y
/// la interfaz sigue sirviendo para los tests, que no hablan con Firebase.
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

/// La implementación real, sobre `firebase_messaging` (CU-21, `docs/FIREBASE.md`).
///
/// El `pedido_id` que dispara la navegación viaja en `data`, no en
/// `notification`: es lo que manda `enviarFcm` de la Edge Function
/// `emparejar_pedido`, y `notification.data` no admite tipos anidados, solo
/// strings.
///
/// No hace falta un `onBackgroundMessage` de Dart: el bloque `notification`
/// del mensaje ya alcanza para que Android e iOS lo muestren solos con la app
/// cerrada o en segundo plano. Un handler en background solo haría falta para
/// reaccionar a un mensaje mientras nadie mira la pantalla, y acá lo único que
/// importa es qué pasa cuando se toca — eso lo cubren `getInitialMessage` y
/// `onMessageOpenedApp`, que corren en el isolate principal.
class ServicioPushFirebase implements ServicioPush {
  ServicioPushFirebase() {
    FirebaseMessaging.onMessageOpenedApp.listen(_agregarSiTraePedido);
    // La app puede abrirse *por* tocar la notificación estando cerrada del
    // todo: ese caso no dispara `onMessageOpenedApp`, hay que preguntarlo.
    _mensajeria.getInitialMessage().then((mensaje) {
      if (mensaje != null) _agregarSiTraePedido(mensaje);
    });
  }

  final FirebaseMessaging _mensajeria = FirebaseMessaging.instance;
  final _pedidosAbiertos = StreamController<String>.broadcast();

  void _agregarSiTraePedido(RemoteMessage mensaje) {
    final pedidoId = mensaje.data['pedido_id'];
    if (pedidoId is String && pedidoId.isNotEmpty) {
      _pedidosAbiertos.add(pedidoId);
    }
  }

  @override
  Future<bool> pedirPermiso() async {
    final ajustes = await _mensajeria.requestPermission();
    return ajustes.authorizationStatus == AuthorizationStatus.authorized ||
        ajustes.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> token() => _mensajeria.getToken();

  @override
  Stream<String> get tokenRenovado => _mensajeria.onTokenRefresh;

  @override
  Stream<String> get pedidosAbiertos => _pedidosAbiertos.stream;
}

/// Se reemplaza con un `override` en los tests por una implementación de
/// mentira: nada de esta capa vuelve a hablar con Firebase de verdad.
///
/// Cae en [PushNoConfigurado] si `Firebase.initializeApp()` no corrió (o
/// falló) en `main.dart` — mismo criterio que el resto del CU-21: sin push la
/// app funciona igual, así que un Firebase mal configurado no puede tirar acá.
@Riverpod(keepAlive: true)
ServicioPush servicioPush(Ref ref) =>
    Firebase.apps.isEmpty ? const PushNoConfigurado() : ServicioPushFirebase();

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
