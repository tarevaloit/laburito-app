import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
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
              const MarcaLaburito(
                titulo: 'Nueva contraseña',
                subtitulo:
                    'Al guardarla se cierran las demás sesiones de tu cuenta.',
              ),
              const SizedBox(height: 28),
              CampoTexto(
                etiqueta: 'Nueva contraseña',
                controller: _password,
                enabled: !cargando,
                obscureText: _ocultar,
                ayuda: 'Mínimo 8 caracteres, una mayúscula y un número',
                icono: Icons.lock_outline,
                sufijo: OjoPassword(
                  oculto: _ocultar,
                  onCambio: () => setState(() => _ocultar = !_ocultar),
                ),
                validator: Validadores.password,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Repetir contraseña',
                controller: _repetir,
                enabled: !cargando,
                obscureText: _ocultar,
                icono: Icons.lock_outline,
                validator: (v) =>
                    Validadores.repetirPassword(v, _password.text),
              ),
              const SizedBox(height: 24),
              BotonPrincipal(
                texto: 'Guardar contraseña',
                cargando: cargando,
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
