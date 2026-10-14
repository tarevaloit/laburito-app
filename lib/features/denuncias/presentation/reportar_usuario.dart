import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/colores.dart';
import '../../../core/errors/mensajes_error.dart';
import '../../../core/widgets/boton_principal.dart';
import '../../../core/widgets/marca_laburito.dart';
import '../data/denuncias_repository.dart';
import '../domain/denuncia.dart';

/// CU-41 — Reportar Usuario. Abre el formulario (paso 2) sobre la pantalla
/// actual: el perfil público ([slug]) o el detalle de un pedido ([pedidoId]).
/// Devuelve `true` si el reporte se envió.
Future<bool> mostrarReporteUsuario(
  BuildContext context, {
  required String sobre,
  String? slug,
  String? pedidoId,
}) async {
  final enviado = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FormularioReporte(sobre: sobre, slug: slug, pedidoId: pedidoId),
    ),
  );
  if (enviado == true && context.mounted) {
    mostrarMensaje(
      context,
      'Recibimos tu reporte. Lo va a revisar un administrador.',
      esError: false,
    );
  }
  return enviado == true;
}

class FormularioReporte extends ConsumerStatefulWidget {
  const FormularioReporte({
    super.key,
    required this.sobre,
    this.slug,
    this.pedidoId,
  });

  /// A quién se reporta, para el título: «Marcelo Gómez», «el Buscador».
  final String sobre;
  final String? slug;
  final String? pedidoId;

  @override
  ConsumerState<FormularioReporte> createState() => _FormularioReporteState();
}

class _FormularioReporteState extends ConsumerState<FormularioReporte> {
  final _formKey = GlobalKey<FormState>();
  final _descripcion = TextEditingController();
  MotivoDenuncia? _motivo;
  bool _faltaMotivo = false;
  bool _enviando = false;

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    // Flujo alterno 1.1: sin motivo no se envía y el campo se resalta.
    final formOk = _formKey.currentState!.validate();
    setState(() => _faltaMotivo = _motivo == null);
    if (!formOk || _motivo == null) return;

    setState(() => _enviando = true);
    try {
      await ref.read(denunciasRepositoryProvider).reportar(
            motivo: _motivo!,
            descripcion: _descripcion.text,
            slug: widget.slug,
            pedidoId: widget.pedidoId,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reportar a ${widget.sobre}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colores.azul,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Un administrador revisa cada reporte. La otra persona no se '
              'entera de quién lo hizo.',
              style: TextStyle(color: Colores.textoSecundario, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Motivo',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _faltaMotivo ? Colores.error : Colores.texto,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Medidas.radio),
                border: Border.all(
                  color: _faltaMotivo ? Colores.error : Colores.borde,
                  width: _faltaMotivo ? 1.5 : 1,
                ),
              ),
              child: RadioGroup<MotivoDenuncia>(
                groupValue: _motivo,
                onChanged: (m) => setState(() {
                  _motivo = m;
                  _faltaMotivo = false;
                }),
                child: Column(
                  children: [
                    for (final m in MotivoDenuncia.values)
                      RadioListTile<MotivoDenuncia>(
                        key: Key('motivo-${m.valor}'),
                        value: m,
                        dense: true,
                        title: Text(m.etiqueta),
                      ),
                  ],
                ),
              ),
            ),
            if (_faltaMotivo)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Elegí el motivo del reporte.',
                  style: TextStyle(color: Colores.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('descripcion-reporte'),
              controller: _descripcion,
              enabled: !_enviando,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Qué pasó',
                hintText: 'Contá brevemente los hechos',
              ),
              validator: (v) => (v ?? '').trim().length < 10
                  ? 'Contanos qué pasó en al menos 10 caracteres.'
                  : null,
            ),
            const SizedBox(height: 8),
            BotonPrincipal(
              texto: 'Enviar reporte',
              cargando: _enviando,
              onPressed: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}
