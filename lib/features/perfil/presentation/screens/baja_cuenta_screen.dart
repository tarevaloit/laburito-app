import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
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
          'Esta acción no se puede deshacer. No vas a poder volver a ingresar '
          'con esta cuenta ni recuperar tu historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828)),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF5C6C0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828)),
                      SizedBox(width: 8),
                      Text('Qué pasa cuando das de baja',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('• Perdés el acceso a tu cuenta de forma definitiva.',
                      style: TextStyle(height: 1.5)),
                  Text('• Tus pedidos y publicaciones dejan de mostrarse.',
                      style: TextStyle(height: 1.5)),
                  Text('• Se elimina tu teléfono y tu foto de perfil.',
                      style: TextStyle(height: 1.5)),
                  Text(
                      '• Conservamos el registro de la cuenta por razones de trazabilidad, '
                      'sin datos de contacto.',
                      style: TextStyle(height: 1.5)),
                  Text('• Si tenés tokens sin usar, no se reintegran.',
                      style: TextStyle(height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _motivo,
              enabled: !cargando,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: '¿Nos contás por qué te vas? (opcional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmacion,
              enabled: !cargando,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Escribí BAJA para confirmar',
                prefixIcon: Icon(Icons.keyboard_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                disabledBackgroundColor: const Color(0xFFE0A9A4),
              ),
              onPressed: (!_puedeConfirmar || cargando) ? null : _confirmar,
              child: cargando
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Dar de baja mi cuenta'),
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
