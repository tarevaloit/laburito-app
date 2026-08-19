import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/providers/supabase_providers.dart';
import '../features/auth/presentation/screens/codigo_recuperacion_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/nueva_password_screen.dart';
import '../features/auth/presentation/screens/recuperar_password_screen.dart';
import '../features/auth/presentation/screens/registro_profesional_screen.dart';
import '../features/auth/presentation/screens/registro_screen.dart';
import '../features/auth/presentation/screens/seleccion_tipo_screen.dart';
import '../features/auth/presentation/screens/verificar_pin_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/perfil/presentation/screens/baja_cuenta_screen.dart';
import '../features/perfil/presentation/screens/perfil_screen.dart';
import '../features/verificacion/presentation/screens/carga_documentos_screen.dart';

/// Rutas que solo tienen sentido sin sesión: con sesión abierta se va al home.
const _soloSinSesion = <String>{
  '/login',
  '/registro',
  '/registro/buscador',
  '/registro/profesional',
};

/// Rutas accesibles con o sin sesión. El flujo de recuperación (CU-04) abre
/// sesión al validar el código, así que no puede expulsar al usuario al home.
const _neutrales = <String>{
  '/verificar',
  '/recuperar',
  '/recuperar/codigo',
  '/recuperar/nueva',
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
      final sesion = ref.read(sesionProvider);
      final destino = state.matchedLocation;
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
      GoRoute(
        path: '/registro',
        name: 'registro',
        builder: (context, state) => const SeleccionTipoScreen(),
        routes: [
          GoRoute(
            path: 'buscador',
            name: 'registroBuscador',
            builder: (context, state) => const RegistroScreen(),
          ),
          GoRoute(
            path: 'profesional',
            name: 'registroProfesional',
            builder: (context, state) => const RegistroProfesionalScreen(),
          ),
        ],
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
