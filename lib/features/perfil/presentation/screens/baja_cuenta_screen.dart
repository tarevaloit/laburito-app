import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../controllers/perfil_controller.dart';

/// CU-11 — Dar de Baja Cuenta.
/// La baja es lógica: el perfil se conserva por trazabilidad, se anonimiza el
/// teléfono y la cuenta deja de poder iniciar sesión.
class BajaCuentaScreen extends ConsumerStatefulWidget {
  const BajaCuentaScreen({super.key});

  @override
  ConsumerState<BajaCuentaScreen> createState() => _BajaCuentaScreenState();
}

class _BajaCuentaScreenState extends ConsumerState<BajaCuentaScreen> {
  final _confirmacion = TextEditingController();
  final _motivo = TextEditingController();
  bool _puedeConfirmar = false;

  static const String _palabraClave = 'BAJA';

  @override
  void initState() {
    super.initState();
    _confirmacion.addListener(() {
      final ok = _confirmacion.text.trim().toUpperCase() == _palabraClave;
      if (ok != _puedeConfirmar) setState(() => _puedeConfirmar = ok);
    });
  }

  @override
  void dispose() {
    _confirmacion.dispose();
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final seguro = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Última confirmación'),
        content: const Text(
          'Esta acción no se puede deshacer. Tus datos personales y tus archivos '
          'se borran, y no vas a poder recuperar tu historial. Podés registrarte '
          'de nuevo más adelante, pero será una cuenta desde cero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colores.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dar de baja'),
          ),
        ],
      ),
    );

    if (seguro != true) return;

    final ok = await ref
        .read(perfilControllerProvider.notifier)
        .darDeBaja(motivo: _motivo.text);

    if (!mounted) return;
    if (ok) {
      mostrarMensaje(context, 'Tu cuenta fue dada de baja.', esError: false);
      context.go('/login');
    } else {
      final error = ref.read(perfilControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = ref.watch(perfilControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dar de baja la cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: cargando ? null : () => context.go('/perfil'),
        ),
      ),
      body: TarjetaFormulario(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AvisoEstado.riesgo(
              icono: Icons.warning_amber_rounded,
              titulo: 'Qué pasa cuando das de baja',
              detalle:
                  '• Perdés el acceso a esta cuenta de forma definitiva.\n'
                  '• Borramos tu nombre, tu teléfono, tu DNI, tu foto de perfil '
                  'y la documentación que hayas subido.\n'
                  '• Tus pedidos y publicaciones dejan de mostrarse.\n'
                  '• Conservamos el historial de operaciones sin tus datos personales: '
                  'de eso dependen los pedidos y las calificaciones de la otra parte.\n'
                  '• Tu correo queda liberado. Si algún día querés volver, podés '
                  'registrarte de nuevo con la misma dirección; será una cuenta '
                  'nueva, sin tu historial anterior.\n'
                  '• Si tenés tokens sin usar, no se reintegran.',
            ),
            const SizedBox(height: 24),
            CampoTexto(
              etiqueta: '¿Nos contás por qué te vas? (opcional)',
              controller: _motivo,
              enabled: !cargando,
              maxLines: 3,
              maxLength: 300,
            ),
            const SizedBox(height: 8),
            CampoTexto(
              etiqueta: 'Escribí BAJA para confirmar',
              controller: _confirmacion,
              enabled: !cargando,
              textCapitalization: TextCapitalization.characters,
              ejemplo: 'BAJA',
              icono: Icons.keyboard_outlined,
            ),
            const SizedBox(height: 24),
            BotonPrincipal.destructivo(
              texto: 'Dar de baja mi cuenta',
              cargando: cargando,
              onPressed: _puedeConfirmar ? _confirmar : null,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: cargando ? null : () => context.go('/perfil'),
              child: const Text('Mejor no, volver'),
            ),
          ],
        ),
      ),
    );
  }
}
