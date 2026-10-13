import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/enlace_gestion_repository.dart';

/// CU-18 — Solicitar Reenvío de Enlace de Gestión («Recuperar mi pedido»).
///
/// El Buscador perdió el acceso a su pedido: escribe el correo con el que lo
/// publicó y, si tiene pedidos activos, le llega un enlace de un solo uso que
/// abre la sesión directo en su pedido (decisión del 13/10). La respuesta es
/// la misma tenga o no pedidos: no revela quién tiene cuenta.
class RecuperarPedidoScreen extends ConsumerStatefulWidget {
  const RecuperarPedidoScreen({super.key});

  @override
  ConsumerState<RecuperarPedidoScreen> createState() =>
      _RecuperarPedidoScreenState();
}

class _RecuperarPedidoScreenState extends ConsumerState<RecuperarPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _enviando = false;
  String? _respuesta;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);
    try {
      final mensaje =
          await ref.read(enlaceGestionRepositoryProvider).reenviar(_email.text);
      if (mounted) setState(() => _respuesta = mensaje);
    } catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final respuesta = _respuesta;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _enviando ? null : () => context.go('/login'),
        ),
      ),
      body: TarjetaFormulario(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MarcaLaburito(
                titulo: 'Recuperá tu pedido',
                subtitulo: 'Ingresá el correo con el que publicaste y te '
                    'mandamos un enlace para gestionarlo. Sirve una sola vez.',
              ),
              const SizedBox(height: 28),
              if (respuesta != null) ...[
                AvisoEstado.exito(
                  icono: Icons.mark_email_read_outlined,
                  titulo: respuesta,
                  detalle: 'Abrí el enlace del correo desde este mismo '
                      'dispositivo. Si pedís otro, el anterior deja de servir. '
                      'Revisá también la carpeta de correo no deseado.',
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Volver al inicio de sesión'),
                ),
              ] else ...[
                CampoTexto(
                  etiqueta: 'Correo electrónico',
                  controller: _email,
                  enabled: !_enviando,
                  keyboardType: TextInputType.emailAddress,
                  icono: Icons.mail_outline,
                  validator: Validadores.email,
                  onFieldSubmitted: (_) => _enviando ? null : _enviar(),
                ),
                const SizedBox(height: 24),
                BotonPrincipal(
                  texto: 'Enviar link',
                  cargando: _enviando,
                  onPressed: _enviar,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
