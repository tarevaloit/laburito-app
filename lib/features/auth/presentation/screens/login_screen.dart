import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../controllers/auth_controller.dart';

/// CU-03 — Iniciar Sesión.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authControllerProvider.notifier).iniciarSesion(
          email: _email.text,
          password: _password.text,
        );

    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      final error = ref.read(authControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      body: TarjetaFormulario(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MarcaLaburito(
                conNombre: false,
                altoLogo: 76,
                titulo: 'Bienvenido de nuevo',
                subtitulo: 'Ingresá para recibir trabajos cerca tuyo',
              ),
              const SizedBox(height: 32),
              CampoTexto(
                etiqueta: 'Correo electrónico',
                controller: _email,
                enabled: !cargando,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                ejemplo: 'marcelo.g@gmail.com',
                validator: Validadores.email,
              ),
              const SizedBox(height: 18),
              CampoTexto(
                etiqueta: 'Contraseña',
                controller: _password,
                enabled: !cargando,
                obscureText: _ocultarPassword,
                autofillHints: const [AutofillHints.password],
                sufijo: OjoPassword(
                  oculto: _ocultarPassword,
                  onCambio: () =>
                      setState(() => _ocultarPassword = !_ocultarPassword),
                ),
                validator: Validadores.passwordRequerida,
                onFieldSubmitted: (_) => cargando ? null : _ingresar(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: cargando ? null : () => context.go('/recuperar'),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              const SizedBox(height: 12),
              BotonPrincipal(
                texto: 'Ingresar',
                cargando: cargando,
                onPressed: _ingresar,
              ),
              const SizedBox(height: 20),
              const Text(
                'o',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colores.textoTenue, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _EnlaceRegistro(
                onTap: cargando ? null : () => context.go('/registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «¿No tenés cuenta? **Registrate**» en una sola línea, como la Figura 3.8:
/// el enlace es la palabra, no un botón aparte.
class _EnlaceRegistro extends StatelessWidget {
  const _EnlaceRegistro({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Medidas.radio),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text.rich(
            TextSpan(
              text: '¿No tenés cuenta? ',
              style: TextStyle(
                color: Colores.textoSecundario,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'Registrate',
                  style: TextStyle(
                    color: Colores.azul,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
