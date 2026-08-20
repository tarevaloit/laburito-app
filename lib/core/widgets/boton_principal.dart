import 'package:flutter/material.dart';

import '../../app/colores.dart';

/// Acción principal de una pantalla: naranja, ancho completo y con el
/// indicador de carga adentro del botón, como en el ANEXO UI.
///
/// Existe para que las ocho pantallas del Sprint 1 no repitan el mismo
/// `FilledButton` con su `CircularProgressIndicator` a mano, y para que
/// «botón bloqueado mientras se envía» sea una sola regla y no ocho.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.icono,
  }) : _destructivo = false;

  /// Variante destructiva: rojo. Se usa en la baja de cuenta (CU-11).
  const BotonPrincipal.destructivo({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.icono,
  }) : _destructivo = true;

  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icono;

  final bool _destructivo;

  @override
  Widget build(BuildContext context) {
    final estilo = _destructivo
        ? FilledButton.styleFrom(
            backgroundColor: Colores.error,
            disabledBackgroundColor: Colores.errorApagado,
            foregroundColor: Colores.textoSobreColor,
            disabledForegroundColor: Colores.textoSobreColor,
          )
        : null;

    return FilledButton(
      style: estilo,
      onPressed: cargando ? null : onPressed,
      child: cargando
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colores.textoSobreColor,
              ),
            )
          : (icono == null
              ? Text(texto)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icono, size: 20),
                    const SizedBox(width: 8),
                    Text(texto),
                  ],
                )),
    );
  }
}
