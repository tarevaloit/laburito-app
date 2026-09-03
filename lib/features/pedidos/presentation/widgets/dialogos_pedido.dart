import 'package:flutter/material.dart';

import '../../../../app/colores.dart';
import '../controllers/acciones_pedido_controller.dart';

/// Diálogos de las acciones del ciclo de vida que piden una decisión.
///
/// Están acá y no adentro del detalle porque la Fase 8 (CU-18) va a abrirlos
/// desde la pantalla de gestión por enlace, que es otra pantalla y ofrece las
/// mismas tres acciones.
///
/// Ninguno ejecuta nada: juntan la decisión y devuelven `null` si el usuario se
/// arrepiente. Quién llama a qué RPC es problema de quien los abrió.

/// CU-29 — Cerrar el pedido.
///
/// Devuelve el motivo elegido, o `null` si se canceló.
///
/// El botón de confirmar arranca deshabilitado y ninguna opción viene
/// preseleccionada, a propósito: de estas tres respuestas sale la métrica de
/// cuántos trabajos resolvió Laburito de verdad, y una opción por defecto la
/// llena de datos que nadie eligió.
Future<MotivoCierre?> pedirMotivoDeCierre(BuildContext context) {
  return showDialog<MotivoCierre>(
    context: context,
    builder: (_) => const _DialogoCerrar(),
  );
}

class _DialogoCerrar extends StatefulWidget {
  const _DialogoCerrar();

  @override
  State<_DialogoCerrar> createState() => _DialogoCerrarState();
}

class _DialogoCerrarState extends State<_DialogoCerrar> {
  MotivoCierre? _motivo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Cerrar el pedido?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cerrar quiere decir que el trabajo se resolvió. El pedido deja '
              'de mostrarse y no se puede reabrir.',
              style: TextStyle(color: Colores.textoSecundario, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cómo lo resolviste?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            // `RadioGroup` y no `groupValue`/`onChanged` en cada tile: desde
            // Flutter 3.32 esos dos parámetros de `RadioListTile` están
            // deprecados y el estado del grupo lo lleva el ancestro.
            RadioGroup<MotivoCierre>(
              groupValue: _motivo,
              onChanged: (valor) => setState(() => _motivo = valor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final motivo in MotivoCierre.values)
                    RadioListTile<MotivoCierre>(
                      value: motivo,
                      title: Text(
                        motivo.etiqueta,
                        style: const TextStyle(fontSize: 14),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
        FilledButton(
          style: _estiloDestructivo,
          onPressed:
              _motivo == null ? null : () => Navigator.pop(context, _motivo),
          child: const Text('Cerrar pedido'),
        ),
      ],
    );
  }
}

/// El botón que confirma algo irreversible va en rojo, como el de la baja de
/// cuenta (CU-11).
final ButtonStyle _estiloDestructivo = FilledButton.styleFrom(
  backgroundColor: Colores.error,
  disabledBackgroundColor: Colores.errorApagado,
  foregroundColor: Colores.textoSobreColor,
  disabledForegroundColor: Colores.textoSobreColor,
);
