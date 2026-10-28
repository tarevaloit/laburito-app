import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/admin_repository.dart';

/// CU-34 — Iniciar Sesión Administrador.
///
/// Paso 2: «un formulario de login minimalista sin opción de registro
/// público». Vive en `/admin/ingresar`, que no se enlaza desde la Web pública.
/// Supabase Auth valida la contraseña y `registrar_acceso_admin` (0035) valida
/// el rol y deja el registro con IP y hora. Si la cuenta no es de un
/// administrador, se cierra la sesión en el acto (flujo alterno 1.2).
class IngresoAdminScreen extends ConsumerStatefulWidget {
  const IngresoAdminScreen({super.key});

  @override
  ConsumerState<IngresoAdminScreen> createState() => _IngresoAdminScreenState();
}

class _IngresoAdminScreenState extends ConsumerState<IngresoAdminScreen> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ocultar = true;
  bool _cargando = false;
  String? _rechazo;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() {
      _cargando = true;
      _rechazo = null;
    });

    final auth = ref.read(authRepositoryProvider);
    try {
      await auth.iniciarSesionSinValidarRol(
        email: _email.text,
        password: _password.text,
      );
      final esAdmin = await ref.read(adminRepositoryProvider).registrarAcceso();

      if (!esAdmin) {
        await auth.cerrarSesion();
        if (!mounted) return;
        setState(() => _rechazo =
            'Esta cuenta no tiene permisos de administración. El intento '
            'quedó registrado.');
        return;
      }

      if (mounted) context.go('/admin/dashboard');
    } on AuthException catch (e) {
      if (mounted) setState(() => _rechazo = MensajesError.desde(e));
    } catch (e) {
      // Si falló el registro del acceso, no se entra: el requerimiento
      // especial del CU-34 es que todo ingreso quede registrado.
      await auth.cerrarSesion();
      if (mounted) setState(() => _rechazo = MensajesError.desde(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.azul,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TarjetaPanel(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Laburito',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colores.azul,
                          ),
                        ),
                        SizedBox(width: 8),
                        _Insignia(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Panel de administración',
                      style: TextStyle(color: Colores.textoSecundario),
                    ),
                    const SizedBox(height: 24),
                    CampoTexto(
                      etiqueta: 'Correo',
                      controller: _email,
                      enabled: !_cargando,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: Validadores.email,
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Contraseña',
                      controller: _password,
                      enabled: !_cargando,
                      obscureText: _ocultar,
                      autofillHints: const [AutofillHints.password],
                      sufijo: OjoPassword(
                        oculto: _ocultar,
                        onCambio: () => setState(() => _ocultar = !_ocultar),
                      ),
                      validator: Validadores.passwordRequerida,
                      onFieldSubmitted: (_) => _cargando ? null : _ingresar(),
                    ),
                    if (_rechazo != null) ...[
                      const SizedBox(height: 16),
                      AvisoEstado.riesgo(
                        key: const Key('rechazo-admin'),
                        icono: Icons.lock_outline,
                        titulo: 'No pudiste ingresar al panel',
                        detalle: _rechazo,
                      ),
                    ],
                    const SizedBox(height: 24),
                    BotonPrincipal(
                      texto: 'Ingresar al Panel',
                      cargando: _cargando,
                      onPressed: _ingresar,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Insignia extends StatelessWidget {
  const _Insignia();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colores.naranja,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'ADMIN',
        style: TextStyle(
          color: Colores.textoSobreColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
