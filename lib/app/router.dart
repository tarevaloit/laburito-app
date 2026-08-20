import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/superficie.dart';
import '../core/providers/supabase_providers.dart';
import '../features/auth/presentation/screens/codigo_recuperacion_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/nueva_password_screen.dart';
import '../features/auth/presentation/screens/recuperar_password_screen.dart';
import '../features/auth/presentation/screens/registro_profesional_screen.dart';
import '../features/auth/presentation/screens/registro_screen.dart';
import '../features/auth/presentation/screens/verificar_pin_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/legales/presentation/texto_legal_screen.dart';
import '../features/perfil/presentation/screens/baja_cuenta_screen.dart';
import '../features/perfil/presentation/screens/perfil_screen.dart';
import '../features/verificacion/presentation/screens/carga_documentos_screen.dart';

/// Rutas que solo tienen sentido sin sesión: con sesión abierta se va al home.
const _soloSinSesion = <String>{
  '/login',
  '/registro',
  '/registro/profesional',
};

/// Alta de Buscador. Existe solo en la web: la app nativa es la del
/// Profesional (ANEXO UI), así que en móvil estas rutas van al alta profesional.
const _altaDeBuscador = <String>{'/registro', '/registro/buscador'};

/// Rutas accesibles con o sin sesión. El flujo de recuperación (CU-04) abre
/// sesión al validar el código, así que no puede expulsar al usuario al home.
const _neutrales = <String>{
  '/verificar',
  '/recuperar',
  '/recuperar/codigo',
  '/recuperar/nueva',
  // Los textos legales se leen antes de tener cuenta y también después.
  '/legales/terminos',
  '/legales/privacidad',
};

final routerProvider = Provider<GoRouter>((ref) {
  final refresco = _RefrescoDeAuth(
    ref.watch(supabaseClientProvider).auth.onAuthStateChange,
  );
  ref.onDispose(refresco.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresco,
    redirect: (context, state) {
      // La sesión se lee del cliente, no de un provider: el redirect corre en
      // el mismo turno que la navegación, y un provider todavía tendría
      // cacheado el valor del evento anterior. `currentSession` la actualiza
      // el cliente de forma sincrónica, así que siempre está al día.
      // De esto depende que al validar el PIN (CU-08) se entre al home en vez
      // de rebotar al login.
      final sesion = ref.read(supabaseClientProvider).auth.currentSession;
      final destino = state.matchedLocation;

      // Diferenciación por superficie: en la app nativa no hay alta de
      // Buscador. Va primero que todo lo demás para que ni siquiera se
      // construya la pantalla equivocada.
      if (!Entorno.permiteAltaDeBuscador && _altaDeBuscador.contains(destino)) {
        return '/registro/profesional';
      }

      final accesibleSinSesion =
          _soloSinSesion.contains(destino) || _neutrales.contains(destino);

      if (sesion == null) {
        return accesibleSinSesion ? null : '/login';
      }

      // CU-08: con el correo sin validar no se llega al home. La sesión solo
      // existe acá si el PIN todavía no se confirmó o si Supabase tiene
      // desactivado *Confirm email*.
      if (sesion.user.emailConfirmedAt == null &&
          !_neutrales.contains(destino)) {
        final email = Uri.encodeComponent(sesion.user.email ?? '');
        return '/verificar?email=$email';
      }

      if (_soloSinSesion.contains(destino)) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      // El alta de Buscador es la de la web (Figura 3.1) y trae adentro el
      // selector de rol. En la app nativa el `redirect` de arriba desvía a
      // `/registro/profesional` antes de que esta pantalla se construya.
      GoRoute(
        path: '/registro',
        name: 'registro',
        builder: (context, state) => const RegistroScreen(),
        routes: [
          GoRoute(
            path: 'profesional',
            name: 'registroProfesional',
            builder: (context, state) => const RegistroProfesionalScreen(),
          ),
        ],
      ),
      for (final doc in DocumentoLegal.values)
        GoRoute(
          path: '/legales/${doc.ruta}',
          name: 'legales-${doc.ruta}',
          builder: (context, state) => TextoLegalScreen(documento: doc),
        ),
      GoRoute(
        path: '/verificar',
        name: 'verificar',
        builder: (context, state) => VerificarPinScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: '/recuperar',
        name: 'recuperar',
        builder: (context, state) => const RecuperarPasswordScreen(),
        routes: [
          GoRoute(
            path: 'codigo',
            name: 'recuperarCodigo',
            builder: (context, state) => CodigoRecuperacionScreen(
              email: state.uri.queryParameters['email'] ?? '',
            ),
          ),
          GoRoute(
            path: 'nueva',
            name: 'recuperarNueva',
            builder: (context, state) => const NuevaPasswordScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        builder: (context, state) => const PerfilScreen(),
        routes: [
          GoRoute(
            path: 'baja',
            name: 'bajaCuenta',
            builder: (context, state) => const BajaCuentaScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/verificacion',
        name: 'verificacion',
        builder: (context, state) => const CargaDocumentosScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
});

/// Puente entre el stream de Supabase y el `refreshListenable` de go_router.
class _RefrescoDeAuth extends ChangeNotifier {
  _RefrescoDeAuth(Stream<AuthState> stream) {
    notifyListeners();
    _suscripcion = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _suscripcion;

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }
}
