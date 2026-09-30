import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/billetera_repository.dart';
import '../../domain/resultado_canje.dart';
import '../controllers/billetera_controller.dart';

/// CU-53 — Canjear Cupón de Tokens (Figura 3.19).
///
/// El código se escribe en mayúsculas mientras se tipea: así se ve igual que
/// en el cartel o el correo de donde se copió. La base lo compara sin
/// distinguir mayúsculas de todos modos (migración 0025).
class CanjearCuponScreen extends ConsumerStatefulWidget {
  const CanjearCuponScreen({super.key});

  @override
  ConsumerState<CanjearCuponScreen> createState() => _CanjearCuponScreenState();
}

class _CanjearCuponScreenState extends ConsumerState<CanjearCuponScreen> {
  final _codigo = TextEditingController();
  bool _canjeando = false;
  CanjeCupon? _resultado;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  bool get _puedeCanjear => _codigo.text.trim().length >= 4 && !_canjeando;

  Future<void> _canjear() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _canjeando = true;
      _resultado = null;
    });

    try {
      final canje =
          await ref.read(billeteraRepositoryProvider).canjear(_codigo.text);
      if (!mounted) return;
      setState(() => _resultado = canje);

      if (canje.exitoso) {
        ref.read(billeteraProvider.notifier).saldoActualizado(canje.saldo ?? 0);
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.celebration, color: Colores.naranja, size: 40),
            title: Text('¡Sumaste ${canje.tokens} tokens!'),
            content: Text('Tu saldo ahora es de ${canje.saldo} tokens.'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Ir a mi billetera'),
              ),
            ],
          ),
        );
        if (mounted) {
          context.canPop() ? context.pop() : context.go('/profesional/billetera');
        }
      }
    } on Object catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _canjeando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _resultado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canjear código'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/profesional/billetera'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colores.naranja,
              borderRadius: BorderRadius.circular(Medidas.radioGrande),
            ),
            child: const Column(
              children: [
                Icon(Icons.confirmation_number_outlined,
                    color: Colores.textoSobreColor, size: 36),
                SizedBox(height: 8),
                Text(
                  'Tenés un código promocional',
                  style: TextStyle(
                    color: Colores.textoSobreColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sumá tokens gratis a tu billetera',
                  style: TextStyle(color: Colores.textoSobreColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CampoTexto(
            etiqueta: 'Ingresá tu código',
            controller: _codigo,
            ejemplo: 'BIENVENIDA10',
            textCapitalization: TextCapitalization.characters,
            maxLength: 20,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
              _Mayusculas(),
            ],
            onChanged: (_) => setState(() => _resultado = null),
            onFieldSubmitted: (_) => _puedeCanjear ? _canjear() : null,
          ),
          if (resultado != null && !resultado.exitoso)
            Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: Colores.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    resultado.resultado.mensaje,
                    key: const Key('mensaje-canje'),
                    style: const TextStyle(color: Colores.error),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          BotonPrincipal(
            texto: 'Canjear ahora',
            cargando: _canjeando,
            onPressed: _puedeCanjear ? _canjear : null,
          ),
        ],
      ),
    );
  }
}

class _Mayusculas extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue viejo,
    TextEditingValue nuevo,
  ) =>
      nuevo.copyWith(text: nuevo.text.toUpperCase());
}
