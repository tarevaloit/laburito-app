import 'package:flutter/material.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/campo_texto.dart';

/// Piezas compartidas por las secciones del panel del Sprint 6: la lista de
/// la izquierda con su detalle a la derecha (Figuras 3.21 y 3.22) y los
/// diálogos de confirmación de cada operación.

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

/// Un renglón de la lista de la izquierda: azul cuando está elegido, como
/// «Marcelo Gómez» en la Figura 3.21.
class TarjetaSeleccionable extends StatelessWidget {
  const TarjetaSeleccionable({
    super.key,
    required this.seleccionada,
    required this.titulo,
    required this.bajada,
    required this.onTap,
    this.insignia,
  });

  final bool seleccionada;
  final String titulo;
  final String bajada;
  final VoidCallback onTap;
  final Widget? insignia;

  @override
  Widget build(BuildContext context) {
    final texto = seleccionada ? Colores.textoSobreColor : Colores.texto;
    final secundario = seleccionada
        ? Colores.textoSobreColor.withValues(alpha: 0.8)
        : Colores.textoSecundario;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: seleccionada ? Colores.azul : Colores.superficie,
        borderRadius: BorderRadius.circular(Medidas.radio),
        child: InkWell(
          borderRadius: BorderRadius.circular(Medidas.radio),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Medidas.radio),
              border: Border.all(
                  color: seleccionada ? Colores.azul : Colores.borde),
            ),
            child: Row(
              children: [
                if (insignia != null) ...[insignia!, const SizedBox(width: 10)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: TextStyle(
                              color: texto, fontWeight: FontWeight.w700)),
                      if (bajada.isNotEmpty)
                        Text(bajada,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: secundario, fontSize: 13)),
                    ],
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

/// «Nombre / Marcelo Gómez»: etiqueta tenue arriba y el dato abajo.
class DatoAdmin extends StatelessWidget {
  const DatoAdmin({super.key, required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: const TextStyle(color: Colores.textoSecundario)),
          Text(valor,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colores.texto)),
        ],
      ),
    );
  }
}

/// Píldora de color: «Grave», «Media», «Activa», «Oculta».
class Pildora extends StatelessWidget {
  const Pildora({
    super.key,
    required this.texto,
    required this.color,
    required this.fondo,
  });

  final String texto;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(texto,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
