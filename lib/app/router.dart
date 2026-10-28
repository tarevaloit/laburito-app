import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/superficie.dart';
import '../core/providers/supabase_providers.dart';
import '../features/admin/presentation/screens/categorias_admin_screen.dart';
import '../features/admin/presentation/screens/cupones_screen.dart';
import '../features/admin/presentation/screens/dashboard_screen.dart';
import '../features/admin/presentation/screens/denuncias_screen.dart';
import '../features/admin/presentation/screens/ingreso_admin_screen.dart';
import '../features/admin/presentation/screens/parametros_screen.dart';
import '../features/admin/presentation/screens/precios_screen.dart';
import '../features/admin/presentation/screens/resenas_admin_screen.dart';
import '../features/admin/presentation/screens/usuarios_screen.dart';
import '../features/admin/presentation/screens/validaciones_screen.dart';
import '../features/auth/presentation/screens/codigo_recuperacion_screen.dart';
import '../features/billetera/presentation/screens/billetera_screen.dart';
import '../features/billetera/presentation/screens/canjear_cupon_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/nueva_password_screen.dart';
import '../features/auth/presentation/screens/recuperar_password_screen.dart';
import '../features/auth/presentation/screens/registro_profesional_screen.dart';
import '../features/auth/presentation/screens/registro_screen.dart';
import '../features/auth/presentation/screens/verificar_pin_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/legales/presentation/texto_legal_screen.dart';
import '../features/pedidos/presentation/screens/crear_pedido_screen.dart';
import '../features/pedidos/presentation/screens/detalle_pedido_screen.dart';
import '../features/pedidos/presentation/screens/editar_pedido_screen.dart';
import '../features/pedidos/presentation/screens/historial_pedidos_screen.dart';
import '../features/pedidos/presentation/screens/recuperar_pedido_screen.dart';
import '../features/notificaciones/presentation/screens/notificaciones_screen.dart';
import '../features/perfil/presentation/screens/baja_cuenta_screen.dart';
import '../features/profesional/presentation/screens/detalle_pedido_publico_screen.dart';
import '../features/profesional/presentation/screens/horarios_screen.dart';
import '../features/profesional/presentation/screens/portafolio_screen.dart';
import '../features/profesional/presentation/screens/tablero_screen.dart';
import '../features/profesional/presentation/screens/zona_cobertura_screen.dart';
import '../features/reputacion/presentation/screens/calificar_screen.dart';
import '../features/reputacion/presentation/screens/estadisticas_screen.dart';
import '../features/reputacion/presentation/screens/mis_contactos_screen.dart';
import '../features/reputacion/presentation/screens/mis_resenas_screen.dart';
import '../features/reputacion/presentation/screens/perfil_publico_screen.dart';
import '../features/perfil/presentation/screens/perfil_screen.dart';
import '../features/verificacion/presentation/screens/carga_documentos_screen.dart';

/// Rutas que solo tienen sentido sin sesión: con sesión abierta se va al home.
const _soloSinSesion = <String>{
  '/login',
  '/registro',
  '/registro/profesional',
  // CU-18: con sesión ya se llega a los pedidos.
  '/recuperar-pedido',
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
  // CU-34: el ingreso del panel valida el rol después de iniciar sesión y
  // navega por su cuenta. Si la ruta expulsara al tener sesión, el aviso de
  // «esta cuenta no es de un administrador» no llegaría a verse.
  ingresoAdmin,
};

/// CU-34. La «URL oculta» del panel: no se enlaza desde la Web pública.
const ingresoAdmin = '/admin/ingresar';

/// Rutas públicas del Sprint 5, con un parámetro: las abre alguien sin cuenta
/// desde un enlace de WhatsApp (modelo «Frictionless»). Con sesión también se
/// ven: un Buscador registrado puede abrir el mismo enlace.
const _prefijosPublicos = <String>['/p/', '/calificar/'];

bool esRutaNeutral(String ruta) =>
    _neutrales.contains(ruta) || _prefijosPublicos.any(ruta.startsWith);

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
          _soloSinSesion.contains(destino) || esRutaNeutral(destino);

      if (sesion == null) {
        if (accesibleSinSesion) return null;
        // Sin sesión, el panel lleva a su propio ingreso y no al de la app.
        return destino.startsWith('/admin') ? ingresoAdmin : '/login';
      }

      // CU-08: con el correo sin validar no se llega al home. La sesión solo
      // existe acá si el PIN todavía no se confirmó o si Supabase tiene
      // desactivado *Confirm email*.
      if (sesion.user.emailConfirmedAt == null && !esRutaNeutral(destino)) {
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
      // CU-27. Perfil público del Profesional (Figura 3.6).
      GoRoute(
        path: '/p/:slug',
        name: 'perfilPublico',
        builder: (context, state) => PerfilPublicoScreen(
          slug: state.pathParameters['slug'] ?? '',
        ),
      ),
      // CU-28. Calificación por enlace de un solo uso (Figura 3.7).
      GoRoute(
        path: '/calificar/:token',
        name: 'calificar',
        builder: (context, state) => CalificarScreen(
          token: state.pathParameters['token'] ?? '',
        ),
      ),
      // CU-28. Desde acá el Profesional pide la calificación al terminar.
      GoRoute(
        path: '/profesional/contactos',
        name: 'misContactos',
        builder: (context, state) => const MisContactosScreen(),
      ),
      // CU-48. Centro de notificaciones de los dos actores.
      GoRoute(
        path: '/notificaciones',
        name: 'notificaciones',
        builder: (context, state) => const NotificacionesScreen(),
      ),
      // CU-45 (Figura 3.18).
      // CU-46: la vía del Profesional para reportar una reseña.
      GoRoute(
        path: '/profesional/resenas',
        name: 'misResenas',
        builder: (context, state) => const MisResenasScreen(),
      ),
      GoRoute(
        path: '/profesional/estadisticas',
        name: 'estadisticas',
        builder: (context, state) => const EstadisticasScreen(),
      ),
      // CU-18. «Recuperar mi pedido».
      GoRoute(
        path: '/recuperar-pedido',
        name: 'recuperarPedido',
        builder: (context, state) => const RecuperarPedidoScreen(),
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
      // CU-07. Va bajo /profesional porque es la primera de las pantallas de
      // ese lado (le siguen horarios y portafolio en este mismo sprint).
      GoRoute(
        path: '/profesional/zona',
        name: 'zonaCobertura',
        builder: (context, state) => const ZonaCoberturaScreen(),
      ),
      // CU-43 y CU-22. El tablero es el home del Profesional; el detalle va
      // bajo /profesional para no confundirse con /pedidos/:id, que es el del
      // Buscador dueño y muestra la barra de acciones.
      // CU-06.
      GoRoute(
        path: '/profesional/portafolio',
        name: 'portafolio',
        builder: (context, state) => const PortafolioScreen(),
      ),
      // CU-44.
      GoRoute(
        path: '/profesional/horarios',
        name: 'horarios',
        builder: (context, state) => const HorariosScreen(),
      ),
      GoRoute(
        path: '/profesional/tablero',
        name: 'tablero',
        builder: (context, state) => const TableroScreen(),
      ),
      GoRoute(
        path: '/profesional/pedidos/:id',
        name: 'pedidoPublico',
        builder: (context, state) => DetallePedidoPublicoScreen(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: ingresoAdmin,
        name: 'adminIngresar',
        builder: (context, state) => const IngresoAdminScreen(),
      ),
      // Panel del administrador (CU-40, CU-52). El rol se valida en
      // `PanelAdmin`, no en el `redirect`: ver el comentario de esa clase.
      //
      // La redirección mira `state.uri.path` y no `matchedLocation`: el
      // `redirect` de una ruta padre corre también al navegar a sus hijas, y
      // ahí `matchedLocation` es el del padre (`/admin`). Con esa condición,
      // tocar «Cupones» devolvía siempre a Precios.
      GoRoute(
        path: '/admin',
        redirect: redireccionPanelAdmin,
        routes: [
          // CU-38: la entrada del panel (CU-34, paso 6).
          GoRoute(
            path: 'dashboard',
            name: 'adminDashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          // CU-35.
          GoRoute(
            path: 'validaciones',
            name: 'adminValidaciones',
            builder: (context, state) => const ValidacionesScreen(),
          ),
          // CU-37.
          GoRoute(
            path: 'categorias',
            name: 'adminCategorias',
            builder: (context, state) => const CategoriasAdminScreen(),
          ),
          // CU-36. `?id=` abre el detalle de un usuario (desde Denuncias).
          GoRoute(
            path: 'usuarios',
            name: 'adminUsuarios',
            builder: (context, state) =>
                UsuariosScreen(inicial: state.uri.queryParameters['id']),
          ),
          // CU-46.
          GoRoute(
            path: 'resenas',
            name: 'adminResenas',
            builder: (context, state) => const ResenasAdminScreen(),
          ),
          // CU-47.
          GoRoute(
            path: 'parametros',
            name: 'adminParametros',
            builder: (context, state) => const ParametrosScreen(),
          ),
          GoRoute(
            path: 'precios',
            name: 'adminPrecios',
            builder: (context, state) => const PreciosScreen(),
          ),
          GoRoute(
            path: 'cupones',
            name: 'adminCupones',
            builder: (context, state) => const CuponesScreen(),
          ),
          // CU-41: la alerta del panel.
          GoRoute(
            path: 'denuncias',
            name: 'adminDenuncias',
            builder: (context, state) => const DenunciasScreen(),
          ),
        ],
      ),
      // CU-30, CU-31, CU-33. `pago` llega al volver del checkout de Mercado
      // Pago por `laburito://laburito/profesional/billetera?pago=…`, el enlace
      // que arma la Edge Function `retorno_pago`.
      GoRoute(
        path: '/profesional/billetera',
        name: 'billetera',
        builder: (context, state) => BilleteraScreen(
          pagoId: state.uri.queryParameters['pago'],
        ),
        routes: [
          // CU-53.
          GoRoute(
            path: 'canjear',
            name: 'canjearCupon',
            builder: (context, state) => const CanjearCuponScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/verificacion',
        name: 'verificacion',
        builder: (context, state) => const CargaDocumentosScreen(),
      ),
      // CU-17. Va antes que `/pedidos/nuevo` y `/pedidos/:id` porque es una
      // ruta exacta y no compite con ellas; el orden entre esas dos sí importa.
      GoRoute(
        path: '/pedidos',
        name: 'pedidos',
        builder: (context, state) => const HistorialPedidosScreen(),
      ),
      GoRoute(
        path: '/pedidos/nuevo',
        name: 'pedidosNuevo',
        builder: (context, state) => const CrearPedidoScreen(),
      ),
      // Va **después** de `/pedidos/nuevo`: go_router evalúa las rutas en el
      // orden en que se declaran, y `:id` matchea cualquier cosa. Al revés,
      // «nuevo» se leería como el id de un pedido.
      GoRoute(
        path: '/pedidos/:id',
        name: 'pedidoDetalle',
        builder: (context, state) => DetallePedidoScreen(
          id: state.pathParameters['id'] ?? '',
        ),
        routes: [
          GoRoute(
            path: 'editar',
            name: 'pedidoEditar',
            builder: (context, state) => EditarPedidoScreen(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
    ),
  );
});

/// `/admin` a secas lleva al Dashboard (CU-34, paso 6); `/admin/cupones` y el
/// resto, a donde pidieron. Ver el comentario de la ruta en [routerProvider].
String? redireccionPanelAdmin(BuildContext context, GoRouterState state) =>
    state.uri.path == '/admin' ? '/admin/dashboard' : null;

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
