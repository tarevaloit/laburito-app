import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../controllers/auth_controller.dart';
import '../widgets/aceptacion_legal.dart';
import '../widgets/selector_de_rol.dart';

/// CU-01 — Registrar Buscador.
///
/// Es el alta de la **web** (Figura 3.1): trae arriba el selector de rol, con
/// «Soy Buscador» ya elegido. En la app nativa esta pantalla no se alcanza —
/// el router manda directo al alta de Profesional.
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
  bool _aceptaLegales = false;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _email, _telefono, _password, _repetir]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceptaLegales) {
      mostrarMensaje(
        context,
        'Para crear la cuenta tenés que aceptar los Términos y Condiciones.',
      );
      return;
    }

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
                titulo: 'Creá tu cuenta',
                subtitulo: 'Publicá tu pedido en menos de un minuto',
              ),
              const SizedBox(height: 24),
              SelectorDeRol(
                esBuscador: true,
                habilitado: !cargando,
                onElegirBuscador: () {},
                onElegirProfesional: () =>
                    context.go('/registro/profesional'),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CampoTexto(
                      etiqueta: 'Nombre',
                      controller: _nombre,
                      enabled: !cargando,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => Validadores.nombre(v, campo: 'nombre'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CampoTexto(
                      etiqueta: 'Apellido',
                      controller: _apellido,
                      enabled: !cargando,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => Validadores.nombre(v, campo: 'apellido'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Correo electrónico',
                controller: _email,
                enabled: !cargando,
                keyboardType: TextInputType.emailAddress,
                ejemplo: 'laura.g@gmail.com',
                icono: Icons.mail_outline,
                validator: Validadores.email,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Teléfono',
                controller: _telefono,
                enabled: !cargando,
                keyboardType: TextInputType.phone,
                ayuda: 'Código de área y número, sin 0 ni 15',
                icono: Icons.phone_outlined,
                validator: Validadores.telefono,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Contraseña',
                controller: _password,
                enabled: !cargando,
                obscureText: _ocultarPassword,
                ayuda: 'Mínimo 8 caracteres, una mayúscula y un número',
                icono: Icons.lock_outline,
                sufijo: OjoPassword(
                  oculto: _ocultarPassword,
                  onCambio: () =>
                      setState(() => _ocultarPassword = !_ocultarPassword),
                ),
                validator: Validadores.password,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                etiqueta: 'Repetir contraseña',
                controller: _repetir,
                enabled: !cargando,
                obscureText: _ocultarPassword,
                icono: Icons.lock_outline,
                validator: (v) =>
                    Validadores.repetirPassword(v, _password.text),
              ),
              const SizedBox(height: 20),
              AceptacionLegal(
                aceptado: _aceptaLegales,
                habilitado: !cargando,
                onCambio: (v) => setState(() => _aceptaLegales = v),
              ),
              const SizedBox(height: 20),
              BotonPrincipal(
                texto: 'Crear cuenta',
                cargando: cargando,
                onPressed: _registrar,
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
