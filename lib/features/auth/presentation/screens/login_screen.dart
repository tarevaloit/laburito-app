import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/config/superficie.dart';
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
              // Sin saludo: el logotipo con el nombre y listo.
              //
              // La Figura 3.8 dice «Bienvenido de nuevo», pero al login llega
              // tanto quien vuelve como quien entra por primera vez —el enlace
              // a «Registrate» está en esta misma pantalla—, así que «de nuevo»
              // es falso la mitad de las veces. Y «Bienvenido» a secas está en
              // masculino: a Laura González la trataría de varón.
              //
              // La bajada sí cambia con la superficie: la de la Figura 3.8
              // —«recibir trabajos»— es del Profesional, y en la web el que
              // entra es el Buscador, que publica pedidos en vez de recibirlos.
              MarcaLaburito(
                altoLogo: 104,
                subtitulo: Entorno.esWeb
                    ? 'Ingresá para publicar tu pedido y ver quién te contactó'
                    : 'Ingresá para recibir trabajos cerca tuyo',
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
              // CU-18. Solo en la Web: el pedido es del Buscador.
              if (Entorno.esWeb)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: cargando
                        ? null
                        : () => context.go('/recuperar-pedido'),
                    child: const Text('¿Perdiste el acceso a tu pedido?'),
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
              // CU-42: «desde el menú principal o pie de página».
              Center(
                child: TextButton.icon(
                  onPressed: () => context.push('/ayuda'),
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('Ayuda y soporte'),
                ),
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
