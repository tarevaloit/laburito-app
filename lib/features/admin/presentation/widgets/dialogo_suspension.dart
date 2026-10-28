import 'package:flutter/material.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../data/usuarios_repository.dart';

/// CU-36, paso 4: «un formulario modal para configurar los parámetros y
/// duración de la penalización». Lo abre la sección Usuarios y también la
/// bandeja de Denuncias (CU-39, punto de extensión).
Future<SuspensionPedida?> pedirSuspension(BuildContext context, String nombre) =>
    showDialog<SuspensionPedida>(
      context: context,
      builder: (_) => _DialogoSuspension(nombre: nombre),
    );

class _DialogoSuspension extends StatefulWidget {
  const _DialogoSuspension({required this.nombre});

  final String nombre;

  @override
  State<_DialogoSuspension> createState() => _DialogoSuspensionState();
}

class _DialogoSuspensionState extends State<_DialogoSuspension> {
  static const _plazos = [1, 3, 7, 15, 30, 90];

  final _formulario = GlobalKey<FormState>();
  final _motivo = TextEditingController();
  bool _permanente = false;
  int _dias = 7;
  bool _apelable = true;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Suspender a ${widget.nombre}'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formulario,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoTexto(
                  key: const Key('motivo-suspension'),
                  etiqueta: 'Motivo formal de la sanción',
                  ejemplo: 'No se presentó a tres trabajos acordados.',
                  controller: _motivo,
                  maxLines: 3,
                  maxLength: 500,
                  validator: (v) => (v ?? '').trim().length < 10
                      ? 'Escribilo en al menos 10 caracteres: lo lee el usuario.'
                      : null,
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Temporal')),
                    ButtonSegment(value: true, label: Text('Permanente')),
                  ],
                  selected: {_permanente},
                  onSelectionChanged: (s) => setState(() => _permanente = s.first),
                ),
                if (!_permanente) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    key: const Key('plazo-suspension'),
                    initialValue: _dias,
                    decoration: const InputDecoration(labelText: 'Duración'),
                    items: [
                      for (final d in _plazos)
                        DropdownMenuItem(
                          value: d,
                          child: Text(d == 1 ? '1 día' : '$d días'),
                        ),
                    ],
                    onChanged: (d) => setState(() => _dias = d ?? _dias),
                  ),
                ],
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _apelable,
                  onChanged: (v) => setState(() => _apelable = v ?? true),
                  title: const Text('Admite apelación'),
                  subtitle: const Text(
                    'Si no la admite, el usuario ve el correo de soporte legal '
                    'en lugar del botón «Apelar sanción» (CU-49).',
                    style: TextStyle(fontSize: 12, color: Colores.textoSecundario),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('confirmar-suspension'),
          style: FilledButton.styleFrom(backgroundColor: Colores.error),
          onPressed: () {
            if (!(_formulario.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(SuspensionPedida(
              motivo: _motivo.text.trim(),
              dias: _permanente ? null : _dias,
              apelable: _apelable,
            ));
          },
          child: const Text('Suspender usuario'),
        ),
      ],
    );
  }
}
