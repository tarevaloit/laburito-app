import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../controllers/auth_controller.dart';

/// CU-08 — Validar Email de Buscador mediante PIN.
class VerificarPinScreen extends ConsumerStatefulWidget {
  const VerificarPinScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerificarPinScreen> createState() => _VerificarPinScreenState();
}

class _VerificarPinScreenState extends ConsumerState<VerificarPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();

  Timer? _timer;
  int _segundosParaReenvio = 60;

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    super.dispose();
  }

  void _iniciarCuentaRegresiva() {
    _timer?.cancel();
    setState(() => _segundosParaReenvio = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundosParaReenvio <= 1) {
        t.cancel();
        if (mounted) setState(() => _segundosParaReenvio = 0);
      } else {
        if (mounted) setState(() => _segundosParaReenvio--);
      }
    });
  }

  Future<void> _verificar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authControllerProvider.notifier).verificarPin(
          email: widget.email,
          pin: _pin.text,
        );

    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      final error = ref.read(authControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
      _pin.clear();
    }
  }

  Future<void> _reenviar() async {
    final ok =
        await ref.read(authControllerProvider.notifier).reenviarPin(widget.email);

    if (!mounted) return;
    if (ok) {
      mostrarMensaje(context, 'Te enviamos un código nuevo.', esError: false);
      _iniciarCuentaRegresiva();
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
              MarcaLaburito(
                titulo: 'Verificá tu correo',
                subtitulo:
                    'Te enviamos un código de 6 dígitos a ${widget.email}',
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _pin,
                enabled: !cargando,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 30,
                  letterSpacing: 14,
                  fontWeight: FontWeight.w700,
                  color: Colores.azul,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '------',
                ),
                validator: Validadores.pin,
                onChanged: (v) {
                  if (v.length == 6 && !cargando) _verificar();
                },
              ),
              const SizedBox(height: 24),
              BotonPrincipal(
                texto: 'Verificar mi correo',
                cargando: cargando,
                onPressed: _verificar,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    (_segundosParaReenvio > 0 || cargando) ? null : _reenviar,
                child: Text(
                  _segundosParaReenvio > 0
                      ? 'Reenviar código en $_segundosParaReenvio s'
                      : 'Reenviar código',
                ),
              ),
              TextButton(
                onPressed: cargando ? null : () => context.go('/login'),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
