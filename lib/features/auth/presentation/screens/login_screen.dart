import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
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
              const MarcaLaburito(subtitulo: 'Ingresá a tu cuenta'),
              const SizedBox(height: 32),
              TextFormField(
                controller: _email,
                enabled: !cargando,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: Validadores.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                enabled: !cargando,
                obscureText: _ocultarPassword,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
                validator: Validadores.passwordRequerida,
                onFieldSubmitted: (_) => cargando ? null : _ingresar(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: cargando ? null : _ingresar,
                child: cargando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Ingresar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: cargando ? null : () => context.go('/recuperar'),
                child: const Text('Olvidé mi contraseña'),
              ),
              const Divider(height: 32),
              OutlinedButton(
                onPressed: cargando ? null : () => context.go('/registro'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Crear una cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
