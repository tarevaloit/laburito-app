import 'package:flutter/material.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/campo_texto.dart';

export '../../../../core/widgets/dialogos.dart';

/// Piezas compartidas por las secciones del panel del Sprint 6: la lista de
/// la izquierda con su detalle a la derecha (Figuras 3.21 y 3.22). Los
/// diálogos viven en `core/widgets/dialogos.dart` y se reexportan acá.

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

/// Segunda confirmación de las operaciones críticas del panel: precios
/// (CU-40, paso 4) y parámetros globales (CU-47, paso 4). Devuelve la
/// contraseña escrita o `null` si se canceló; la valida Supabase Auth.
Future<String?> pedirContrasena(BuildContext context, {required String aviso}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _DialogoPassword(aviso: aviso),
    );

class _DialogoPassword extends StatefulWidget {
  const _DialogoPassword({required this.aviso});

  final String aviso;

  @override
  State<_DialogoPassword> createState() => _DialogoPasswordState();
}

class _DialogoPasswordState extends State<_DialogoPassword> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmá con tu contraseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.aviso),
          const SizedBox(height: 16),
          CampoTexto(
            key: const Key('password-admin'),
            etiqueta: 'Contraseña',
            controller: _controller,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (v) => Navigator.pop(context, v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
