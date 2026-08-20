import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/colores.dart';

/// Ojo para mostrar u ocultar la contraseña. Va como [CampoTexto.sufijo].
class OjoPassword extends StatelessWidget {
  const OjoPassword({super.key, required this.oculto, required this.onCambio});

  final bool oculto;
  final VoidCallback onCambio;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(oculto
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined),
      tooltip: oculto ? 'Mostrar contraseña' : 'Ocultar contraseña',
      onPressed: onCambio,
    );
  }
}

/// Campo de formulario del ANEXO UI: **la etiqueta va arriba del campo**, en
/// gris oscuro y pequeña, y adentro queda el texto de ejemplo.
///
/// Es la diferencia visible con el patrón por defecto de Material, que mete la
/// etiqueta adentro y la hace flotar al escribir. Todas las figuras del Anexo
/// (3.1, 3.2, 3.9, 3.24) usan la etiqueta externa, así que el formulario entero
/// pasa por acá y no por `TextFormField` pelado.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.etiqueta,
    this.controller,
    this.initialValue,
    this.ejemplo,
    this.ayuda,
    this.icono,
    this.sufijo,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onFieldSubmitted,
    this.onChanged,
  });

  /// Texto que va arriba del campo.
  final String etiqueta;

  final TextEditingController? controller;
  final String? initialValue;

  /// Texto de ejemplo dentro del campo (el `hintText` de Material).
  final String? ejemplo;

  /// Aclaración debajo del campo: reglas de formato, avisos.
  final String? ayuda;

  final IconData? icono;
  final Widget? sufijo;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(
            etiqueta,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: enabled ? Colores.texto : Colores.textoTenue,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: ejemplo,
            helperText: ayuda,
            prefixIcon: icono == null ? null : Icon(icono),
            suffixIcon: sufijo,
            alignLabelWithHint: maxLines > 1,
          ),
        ),
      ],
    );
  }
}
