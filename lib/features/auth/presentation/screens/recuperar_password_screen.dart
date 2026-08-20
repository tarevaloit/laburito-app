import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../controllers/auth_controller.dart';

/// CU-04 — Recuperar Contraseña, paso 1: pedir el código.
class RecuperarPasswordScreen extends ConsumerStatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  ConsumerState<RecuperarPasswordScreen> createState() =>
      _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState
    extends ConsumerState<RecuperarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _email.text.trim();
    final ok = await ref
        .read(authControllerProvider.notifier)
        .enviarCodigoDeRecuperacion(email);

    if (!mounted) return;

    // Mensaje neutro: no se revela si el correo existe en el sistema.
    if (ok) {
      mostrarMensaje(
        context,
        'Si el correo está registrado, vas a recibir un código.',
        esError: false,
      );
      context.go('/recuperar/codigo?email=${Uri.encodeComponent(email)}');
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
          onPressed: cargando ? null : () => context.go('/login'),
        ),
      ),
      body: TarjetaFormulario(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MarcaLaburito(
                titulo: 'Recuperá tu contraseña',
                subtitulo:
                    'Ingresá el correo de tu cuenta y te enviamos un código de 6 dígitos para restablecerla.',
              ),
              const SizedBox(height: 28),
              CampoTexto(
                etiqueta: 'Correo electrónico',
                controller: _email,
                enabled: !cargando,
                keyboardType: TextInputType.emailAddress,
                icono: Icons.mail_outline,
                validator: Validadores.email,
                onFieldSubmitted: (_) => cargando ? null : _enviar(),
              ),
              const SizedBox(height: 24),
              BotonPrincipal(
                texto: 'Enviar código',
                cargando: cargando,
                onPressed: _enviar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
