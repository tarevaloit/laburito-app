import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../controllers/auth_controller.dart';

/// CU-04 — paso 3: fijar la nueva contraseña.
class NuevaPasswordScreen extends ConsumerStatefulWidget {
  const NuevaPasswordScreen({super.key});

  @override
  ConsumerState<NuevaPasswordScreen> createState() =>
      _NuevaPasswordScreenState();
}

class _NuevaPasswordScreenState extends ConsumerState<NuevaPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _repetir = TextEditingController();
  bool _ocultar = true;

  @override
  void dispose() {
    _password.dispose();
    _repetir.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .actualizarPassword(_password.text);

    if (!mounted) return;
    if (ok) {
      mostrarMensaje(context, 'Tu contraseña se actualizó.', esError: false);
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
              const MarcaLaburito(subtitulo: 'Elegí una contraseña nueva'),
              const SizedBox(height: 28),
              TextFormField(
                controller: _password,
                enabled: !cargando,
                obscureText: _ocultar,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  helperText: 'Mínimo 8 caracteres, una mayúscula y un número',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultar
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _ocultar = !_ocultar),
                  ),
                ),
                validator: Validadores.password,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repetir,
                enabled: !cargando,
                obscureText: _ocultar,
                decoration: const InputDecoration(
                  labelText: 'Repetir contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    Validadores.repetirPassword(v, _password.text),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: cargando ? null : _guardar,
                child: cargando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Guardar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
