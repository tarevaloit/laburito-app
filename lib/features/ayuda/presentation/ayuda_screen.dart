import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/colores.dart';
import '../../../core/config/contacto.dart';
import '../../../core/widgets/marca_laburito.dart';
import '../data/ayuda_repository.dart';

/// CU-42 — Consultar Ayuda y Soporte (`/ayuda`). Se abre con o sin sesión:
/// desde el login, el inicio y la cuenta suspendida.
///
/// Paso 2: los temas organizados y el buscador. Pasos 3 y 4: la respuesta se
/// despliega en el lugar. Pasos 5 y 6: si no la encontró, los canales de
/// contacto. Flujo alterno 1.1: si la base de conocimientos no responde, se
/// muestran directamente los datos de contacto.
class AyudaScreen extends ConsumerStatefulWidget {
  const AyudaScreen({super.key});

  @override
  ConsumerState<AyudaScreen> createState() => _AyudaScreenState();
}

class _AyudaScreenState extends ConsumerState<AyudaScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final preguntas = ref.watch(preguntasFrecuentesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda y soporte')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...preguntas.when(
                loading: () => const [
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                error: (_, __) => const [
                  AvisoEstado.pendiente(
                    key: Key('ayuda-sin-conexion'),
                    icono: Icons.cloud_off_outlined,
                    titulo: 'No pudimos cargar las preguntas frecuentes',
                    detalle: 'Escribinos por cualquiera de estos canales y te '
                        'respondemos.',
                  ),
                ],
                data: (lista) => [
                  _Preguntas(
                    lista: lista,
                    busqueda: _busqueda,
                    onBuscar: (b) => setState(() => _busqueda = b),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _Contacto(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preguntas extends StatelessWidget {
  const _Preguntas({
    required this.lista,
    required this.busqueda,
    required this.onBuscar,
  });

  final List<PreguntaFrecuente> lista;
  final String busqueda;
  final ValueChanged<String> onBuscar;

  @override
  Widget build(BuildContext context) {
    final visibles = lista.where((p) => p.coincide(busqueda)).toList();
    // Un `Set` conserva el orden de llegada: las categorías salen como las
    // ordenó la base.
    final categorias = {for (final p in visibles) p.categoria}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('buscar-ayuda'),
          onChanged: onBuscar,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: '¿En qué te podemos ayudar?',
          ),
        ),
        const SizedBox(height: 16),
        if (visibles.isEmpty)
          const AvisoEstado.pendiente(
            icono: Icons.search_off,
            titulo: 'No encontramos respuestas para esa búsqueda',
            detalle: 'Probá con otras palabras o escribinos abajo.',
          ),
        for (final c in categorias) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Text(c,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colores.azul)),
          ),
          TarjetaPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final p in visibles.where((p) => p.categoria == c))
                  ExpansionTile(
                    shape: const Border(),
                    title: Text(p.pregunta,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.respuesta,
                          style: const TextStyle(
                              color: Colores.textoSecundario, height: 1.45)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Contacto extends StatelessWidget {
  const _Contacto();

  @override
  Widget build(BuildContext context) {
    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿No encontraste lo que buscabas?',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16, color: Colores.texto)),
          const SizedBox(height: 4),
          const Text('Escribinos y te responde el equipo de Laburito.',
              style: TextStyle(color: Colores.textoSecundario)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const Key('contacto-correo'),
                onPressed: () => launchUrl(Contacto.mailSoporte),
                icon: const Icon(Icons.mail_outline),
                label: const Text(Contacto.correoSoporte),
              ),
              OutlinedButton.icon(
                key: const Key('contacto-whatsapp'),
                onPressed: () => launchUrl(Contacto.whatsapp,
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp de soporte'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
