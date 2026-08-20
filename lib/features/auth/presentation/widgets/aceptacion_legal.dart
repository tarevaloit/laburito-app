import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../legales/presentation/texto_legal_screen.dart';

/// Checkbox de aceptación de los Términos y Condiciones y la Política de
/// Privacidad (Figura 3.1 del ANEXO UI, Ley 25.326).
///
/// Va en las dos altas —Buscador y Profesional—: el consentimiento no depende
/// del rol, aunque la Figura 3.9 no lo dibuje.
class AceptacionLegal extends StatefulWidget {
  const AceptacionLegal({
    super.key,
    required this.aceptado,
    required this.onCambio,
    this.habilitado = true,
  });

  final bool aceptado;
  final ValueChanged<bool> onCambio;
  final bool habilitado;

  @override
  State<AceptacionLegal> createState() => _AceptacionLegalState();
}

class _AceptacionLegalState extends State<AceptacionLegal> {
  // Los reconocedores de un TextSpan hay que liberarlos a mano.
  late final TapGestureRecognizer _terminos;
  late final TapGestureRecognizer _privacidad;

  @override
  void initState() {
    super.initState();
    _terminos = TapGestureRecognizer()
      ..onTap = () => context.go('/legales/${DocumentoLegal.terminos.ruta}');
    _privacidad = TapGestureRecognizer()
      ..onTap = () => context.go('/legales/${DocumentoLegal.privacidad.ruta}');
  }

  @override
  void dispose() {
    _terminos.dispose();
    _privacidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontSize: 13,
      color: Colores.textoSecundario,
      height: 1.4,
    );
    const enlace = TextStyle(
      fontSize: 13,
      color: Colores.azulMedio,
      fontWeight: FontWeight.w700,
      height: 1.4,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: widget.aceptado,
            onChanged: widget.habilitado
                ? (v) => widget.onCambio(v ?? false)
                : null,
            activeColor: Colores.azul,
            side: const BorderSide(color: Colores.borde, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text.rich(
              TextSpan(
                text: 'Acepto los ',
                style: base,
                children: [
                  TextSpan(
                    text: 'Términos y Condiciones',
                    style: enlace,
                    recognizer: _terminos,
                  ),
                  const TextSpan(text: ' y la ', style: base),
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: enlace,
                    recognizer: _privacidad,
                  ),
                  const TextSpan(text: ' (Ley 25.326)', style: base),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
