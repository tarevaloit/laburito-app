import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/enlaces.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/reputacion_repository.dart';

/// CU-26 — Compartir Perfil Público (vía link). Va en Mi Perfil del
/// Profesional (Figura 3.17).
///
/// «Compartir mi perfil» pide el enlace al servidor, lo copia al portapapeles
/// (paso 4) y lo deja a la vista con un atajo a WhatsApp, que es donde el
/// Profesional lo pega (paso 5). Con la cuenta suspendida el botón queda
/// desactivado y se muestra la alerta del flujo alterno.
class CompartirPerfil extends ConsumerStatefulWidget {
  const CompartirPerfil({super.key, this.suspendida = false});

  /// La cuenta ya se sabe suspendida al dibujar: el botón nace desactivado.
  final bool suspendida;

  @override
  ConsumerState<CompartirPerfil> createState() => _CompartirPerfilState();
}

class _CompartirPerfilState extends ConsumerState<CompartirPerfil> {
  Uri? _enlace;
  bool _cargando = false;
  late bool _suspendida = widget.suspendida;

  Future<void> _compartir() async {
    setState(() => _cargando = true);
    try {
      final enlace =
          await ref.read(reputacionRepositoryProvider).enlacePerfil();
      await Clipboard.setData(ClipboardData(text: enlace.toString()));
      if (!mounted) return;
      setState(() => _enlace = enlace);
      mostrarMensaje(
        context,
        'Enlace copiado. Pegalo en la conversación de WhatsApp.',
        esError: false,
      );
    } on CuentaSuspendidaException catch (error) {
      if (!mounted) return;
      // Sin `await`: el botón deja de girar antes de que aparezca la alerta,
      // no cuando se cierra.
      setState(() {
        _suspendida = true;
        _cargando = false;
      });
      _alertarSuspendida(error.message);
    } catch (error) {
      if (!mounted) return;
      mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _alertarSuspendida(String mensaje) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.block, color: Colores.error),
          title: const Text('Cuenta inhabilitada'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );

  Future<void> _abrirWhatsApp() async {
    final enlace = _enlace;
    if (enlace == null) return;
    final mensaje = 'Hola, te paso mi perfil de Laburito: ahí podés ver mis '
        'trabajos y lo que opinan otros clientes. $enlace';
    final abierto = await abrirEnlace(Uri.https('wa.me', '/', {'text': mensaje}));
    if (!abierto && mounted) {
      mostrarMensaje(context, 'No pudimos abrir WhatsApp. El enlace ya está copiado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final enlace = _enlace;

    return TarjetaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.public, color: Colores.azulMedio, size: 20),
              SizedBox(width: 8),
              Text(
                'Tu perfil público',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colores.texto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Mandale el enlace al Buscador: ve tus trabajos y tus reseñas '
            'desde el navegador, sin instalar nada.',
            style: TextStyle(color: Colores.textoSecundario, fontSize: 13),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('compartir-perfil'),
            onPressed: _suspendida || _cargando ? null : _compartir,
            icon: _cargando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share_outlined),
            label: const Text('Compartir mi perfil'),
          ),
          if (_suspendida) ...[
            const SizedBox(height: 8),
            const Text(
              'Tu cuenta está inhabilitada: no podés compartir tu perfil.',
              style: TextStyle(color: Colores.error, fontSize: 13),
            ),
          ],
          if (enlace != null) ...[
            const SizedBox(height: 12),
            SelectableText(
              enlace.toString(),
              key: const Key('enlace-perfil'),
              style: const TextStyle(color: Colores.azulMedio, fontSize: 13),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _abrirWhatsApp,
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Enviar por WhatsApp'),
            ),
          ],
        ],
      ),
    );
  }
}
