import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../controllers/auth_controller.dart';

/// CU-01 — Registrar Buscador.
class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _password = TextEditingController();
  final _repetir = TextEditingController();
  bool _ocultarPassword = true;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _email, _telefono, _password, _repetir]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _email.text.trim();
    final ok = await ref.read(authControllerProvider.notifier).registrarBuscador(
          nombre: _nombre.text,
          apellido: _apellido.text,
          email: email,
          telefono: _telefono.text,
          password: _password.text,
        );

    if (!mounted) return;
    if (ok) {
      context.go('/verificar?email=${Uri.encodeComponent(email)}');
    } else {
      final error = ref.read(authControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: cargando ? null : () => context.go('/registro'),
        ),
      ),
      body: TarjetaFormulario(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MarcaLaburito(
                subtitulo: 'Creá tu cuenta para publicar un pedido',
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nombre,
                      enabled: !cargando,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => Validadores.nombre(v, campo: 'nombre'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _apellido,
                      enabled: !cargando,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      validator: (v) => Validadores.nombre(v, campo: 'apellido'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                enabled: !cargando,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: Validadores.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefono,
                enabled: !cargando,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  helperText: 'Código de área y número, sin 0 ni 15',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: Validadores.telefono,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                enabled: !cargando,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  helperText: 'Mínimo 8 caracteres, una mayúscula y un número',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                ),
                validator: Validadores.password,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repetir,
                enabled: !cargando,
                obscureText: _ocultarPassword,
                decoration: const InputDecoration(
                  labelText: 'Repetir contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    Validadores.repetirPassword(v, _password.text),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: cargando ? null : _registrar,
                child: cargando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Crear cuenta'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: cargando ? null : () => context.go('/login'),
                child: const Text('Ya tengo cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
