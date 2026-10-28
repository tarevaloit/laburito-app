import 'package:flutter/material.dart';

import '../../app/colores.dart';
import 'campo_texto.dart';

/// Diálogos de confirmación compartidos. Nacieron con el panel del Sprint 6
/// y los usa también la app del Profesional (reportar una reseña, CU-46).

/// Confirmación simple. Devuelve `true` solo si se confirmó.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String confirmar,
  bool destructiva = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('confirmar-dialogo'),
          style: destructiva
              ? FilledButton.styleFrom(backgroundColor: Colores.error)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmar),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Pide un texto obligatorio —el motivo de un rechazo, de una sanción—.
/// Devuelve `null` si se canceló.
Future<String?> pedirTexto(
  BuildContext context, {
  required String titulo,
  required String etiqueta,
  required String confirmar,
  String? ejemplo,
  String? ayuda,
  int minimo = 10,
  int maximo = 500,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _DialogoTexto(
        titulo: titulo,
        etiqueta: etiqueta,
        confirmar: confirmar,
        ejemplo: ejemplo,
        ayuda: ayuda,
        minimo: minimo,
        maximo: maximo,
      ),
    );

/// El controlador vive en un `State` propio y no en la función: si se
/// descarta al cerrar el diálogo mientras todavía se dibuja la animación de
/// salida, la pantalla se pone roja (la regresión del 01/10 en Precios).
class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({
    required this.titulo,
    required this.etiqueta,
    required this.confirmar,
    required this.minimo,
    required this.maximo,
    this.ejemplo,
    this.ayuda,
  });

  final String titulo;
  final String etiqueta;
  final String confirmar;
  final String? ejemplo;
  final String? ayuda;
  final int minimo;
  final int maximo;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  final _formulario = GlobalKey<FormState>();
  final _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  String? _validar(String? v) {
    final t = (v ?? '').trim();
    if (t.length < widget.minimo) {
      return 'Escribilo en al menos ${widget.minimo} caracteres.';
    }
    if (t.length > widget.maximo) {
      return 'Puede tener hasta ${widget.maximo} caracteres.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.ayuda != null) ...[
                Text(widget.ayuda!,
                    style: const TextStyle(color: Colores.textoSecundario)),
                const SizedBox(height: 12),
              ],
              CampoTexto(
                key: const Key('texto-dialogo'),
                etiqueta: widget.etiqueta,
                ejemplo: widget.ejemplo,
                controller: _texto,
                maxLines: 4,
                maxLength: widget.maximo,
                validator: _validar,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('confirmar-dialogo'),
          onPressed: () {
            if (_formulario.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_texto.text.trim());
            }
          },
          child: Text(widget.confirmar),
        ),
      ],
    );
  }
}
