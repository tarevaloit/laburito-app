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

// ----------------------------------------------------------------------------
// CU-51 — Renovar
// ----------------------------------------------------------------------------

/// Las tres duraciones que se ofrecen, las mismas del alta (CU-13).
const List<int> diasDeRenovacion = [7, 15, 30];

/// CU-51 — Por cuántos días se renueva.
///
/// Devuelve los días elegidos, o `null` si se canceló. No se ofrece un campo
/// libre: `renovar_pedido` acepta de 1 a 30 días, y tres opciones se eligen de
/// un toque mientras que un número escrito a mano hay que validarlo.
Future<int?> pedirDiasDeRenovacion(
  BuildContext context, {
  required int restantes,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _DialogoRenovar(restantes: restantes),
  );
}

class _DialogoRenovar extends StatefulWidget {
  const _DialogoRenovar({required this.restantes});

  /// Cuántas renovaciones le quedan al pedido, para avisar cuando es la última.
  final int restantes;

  @override
  State<_DialogoRenovar> createState() => _DialogoRenovarState();
}

class _DialogoRenovarState extends State<_DialogoRenovar> {
  int _dias = diasDeRenovacion.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Renovar el pedido'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vuelve a publicarse y a verse desde ahora, por el plazo que '
            'elijas.',
            style: TextStyle(color: Colores.textoSecundario, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final dias in diasDeRenovacion)
                ChoiceChip(
                  label: Text('$dias días'),
                  selected: _dias == dias,
                  onSelected: (_) => setState(() => _dias = dias),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.restantes <= 1
                ? 'Es la última renovación de este pedido: son 3 en total.'
                : 'Te quedan ${widget.restantes} renovaciones de 3.',
            style: const TextStyle(fontSize: 13, color: Colores.textoSecundario),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _dias),
          child: const Text('Renovar'),
        ),
      ],
    );
  }
}

/// CU-51 — El pedido agotó sus 3 renovaciones.
///
/// Devuelve `true` si el usuario eligió publicar uno nuevo.
///
/// Es el caso [CasoPedido.limiteRenovaciones] del `PedidoException`, y se
/// muestra por dos caminos: cuando el cliente ya sabe que no quedan —el
/// pedido trae `renovaciones = 3`— y cuando lo dice el servidor, que es la
/// respuesta que manda. Un callejón sin salida con una salida: publicar de
/// nuevo es exactamente lo que esa persona quería hacer.
Future<bool> avisarLimiteDeRenovaciones(BuildContext context) async {
  final publicarOtro = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Este pedido ya no se puede renovar'),
      content: const Text(
        'Se renovó 3 veces, que es el máximo. Si todavía necesitás el '
        'trabajo, publicá un pedido nuevo: podés copiar el texto de este.',
        style: TextStyle(color: Colores.textoSecundario, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Publicar uno nuevo'),
        ),
      ],
    ),
  );

  return publicarOtro ?? false;
}

/// El botón que confirma algo irreversible va en rojo, como el de la baja de
/// cuenta (CU-11).
final ButtonStyle _estiloDestructivo = FilledButton.styleFrom(
  backgroundColor: Colores.error,
  disabledBackgroundColor: Colores.errorApagado,
  foregroundColor: Colores.textoSobreColor,
  disabledForegroundColor: Colores.textoSobreColor,
);
