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

// ----------------------------------------------------------------------------
// CU-14 — Cancelar
// ----------------------------------------------------------------------------

/// Lo que devuelve el diálogo de cancelación cuando el usuario confirma.
///
/// Es una clase y no un `String?` porque el motivo es opcional: con un
/// `String?` pelado, «canceló y no escribió motivo» y «se arrepintió» serían el
/// mismo `null`.
class CancelacionConfirmada {
  const CancelacionConfirmada(this.motivo);

  /// Texto libre, o `null` si no escribió nada.
  final String? motivo;
}

/// CU-14 — Cancelar el pedido.
///
/// Devuelve `null` si el usuario se arrepiente.
///
/// El copy es la mitad del caso de uso: cerrar y cancelar terminan los dos en
/// un estado terminal, y desde afuera se parecen. **Cerrar es que se
/// resolvió; cancelar es que se da de baja.** Si alguien cancela un trabajo
/// que en realidad se hizo, Laburito pierde la única evidencia de que sirvió,
/// así que el diálogo lo dice y ofrece el otro camino.
Future<CancelacionConfirmada?> confirmarCancelacion(BuildContext context) {
  return showDialog<CancelacionConfirmada>(
    context: context,
    builder: (_) => const _DialogoCancelar(),
  );
}

class _DialogoCancelar extends StatefulWidget {
  const _DialogoCancelar();

  @override
  State<_DialogoCancelar> createState() => _DialogoCancelarState();
}

class _DialogoCancelarState extends State<_DialogoCancelar> {
  final _motivo = TextEditingController();

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Cancelar el pedido?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cancelar es dar de baja el pedido: no se hizo el trabajo. Deja '
              'de mostrarse y no se puede reabrir.',
              style: TextStyle(color: Colores.textoSecundario, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'Si el trabajo sí se resolvió, cerralo en vez de cancelarlo.',
              style: TextStyle(
                color: Colores.texto,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _motivo,
              maxLines: 2,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: '¿Por qué lo cancelás?',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('No, volver'),
        ),
        FilledButton(
          style: _estiloDestructivo,
          onPressed: () {
            final texto = _motivo.text.trim();
            Navigator.pop(
              context,
              CancelacionConfirmada(texto.isEmpty ? null : texto),
            );
          },
          child: const Text('Sí, cancelar'),
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
