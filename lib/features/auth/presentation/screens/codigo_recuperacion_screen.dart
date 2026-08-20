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

/// CU-04 — paso 2: validar el código de recuperación.
class CodigoRecuperacionScreen extends ConsumerStatefulWidget {
  const CodigoRecuperacionScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<CodigoRecuperacionScreen> createState() =>
      _CodigoRecuperacionScreenState();
}

class _CodigoRecuperacionScreenState
    extends ConsumerState<CodigoRecuperacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pin = TextEditingController();

  Timer? _timer;
  int _segundos = 60;

  @override
  void initState() {
    super.initState();
    _cuentaRegresiva();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    super.dispose();
  }

  void _cuentaRegresiva() {
    _timer?.cancel();
    setState(() => _segundos = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundos <= 1) {
        t.cancel();
        if (mounted) setState(() => _segundos = 0);
      } else {
        if (mounted) setState(() => _segundos--);
      }
    });
  }

  Future<void> _validar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .verificarCodigoDeRecuperacion(email: widget.email, pin: _pin.text);

    if (!mounted) return;
    if (ok) {
      context.go('/recuperar/nueva');
    } else {
      final error = ref.read(authControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
      _pin.clear();
    }
  }

  Future<void> _reenviar() async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .enviarCodigoDeRecuperacion(widget.email);

    if (!mounted) return;
    if (ok) {
      mostrarMensaje(context, 'Te enviamos un código nuevo.', esError: false);
      _cuentaRegresiva();
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
                titulo: 'Ingresá el código',
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
                  if (v.length == 6 && !cargando) _validar();
                },
              ),
              const SizedBox(height: 24),
              BotonPrincipal(
                texto: 'Validar código',
                cargando: cargando,
                onPressed: _validar,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: (_segundos > 0 || cargando) ? null : _reenviar,
                child: Text(_segundos > 0
                    ? 'Reenviar código en $_segundos s'
                    : 'Reenviar código'),
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
