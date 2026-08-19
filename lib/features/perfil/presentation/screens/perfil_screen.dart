import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../categorias/data/categorias_repository.dart';
import '../../data/perfil_repository.dart';
import '../controllers/perfil_controller.dart';

/// CU-05 — Gestionar Perfil.
class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _telefono = TextEditingController();
  final _descripcion = TextEditingController();
  final Set<String> _categorias = {};

  bool _inicializado = false;
  static const int _maxCategorias = 5;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _telefono, _descripcion]) {
      c.dispose();
    }
    super.dispose();
  }

  void _precargar(PerfilCompleto p) {
    if (_inicializado) return;
    _nombre.text = p.nombre;
    _apellido.text = p.apellido;
    _telefono.text = p.telefono ?? '';
    _descripcion.text = p.descripcion ?? '';
    _categorias
      ..clear()
      ..addAll(p.categorias);
    _inicializado = true;
  }

  Future<void> _cambiarAvatar() async {
    final archivo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (archivo == null) return;

    final bytes = await archivo.readAsBytes();
    final ok =
        await ref.read(perfilControllerProvider.notifier).cambiarAvatar(bytes);

    if (!mounted) return;
    if (ok) {
      mostrarMensaje(context, 'Foto actualizada.', esError: false);
    } else {
      final error = ref.read(perfilControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
    }
  }

  Future<void> _guardar(PerfilCompleto p) async {
    if (!_formKey.currentState!.validate()) return;

    if (p.esProfesional && _categorias.isEmpty) {
      mostrarMensaje(context, 'Mantené al menos una categoría de oficio.');
      return;
    }

    final ok = await ref.read(perfilControllerProvider.notifier).guardar(
          nombre: _nombre.text,
          apellido: _apellido.text,
          telefono: _telefono.text,
          descripcion: p.esProfesional ? _descripcion.text : null,
          categorias: p.esProfesional ? _categorias.toList() : null,
        );

    if (!mounted) return;
    if (ok) {
      mostrarMensaje(context, 'Perfil actualizado.', esError: false);
    } else {
      final error = ref.read(perfilControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilCompletoProvider);
    final cargando = ref.watch(perfilControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: perfilAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('No pudimos cargar tu perfil: $e')),
        data: (p) {
          if (p == null) return const Center(child: Text('Sin perfil.'));
          _precargar(p);

          return TarjetaFormulario(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFFE8EDF5),
                          backgroundImage: p.avatarUrl != null
                              ? NetworkImage(p.avatarUrl!)
                              : null,
                          child: p.avatarUrl == null
                              ? Text(
                                  p.nombre.characters.first.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 34, fontWeight: FontWeight.w700),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: cargando ? null : _cambiarAvatar,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.camera_alt,
                                    size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    initialValue: p.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      helperText: 'El correo no se puede modificar',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nombre,
                    enabled: !cargando,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => Validadores.nombre(v, campo: 'nombre'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apellido,
                    enabled: !cargando,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                    validator: (v) => Validadores.nombre(v, campo: 'apellido'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefono,
                    enabled: !cargando,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validadores.telefono,
                  ),
                  if (p.esProfesional) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcion,
                      enabled: !cargando,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Descripción de tu trabajo',
                        alignLabelWithHint: true,
                      ),
                      validator: Validadores.descripcion,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('Categorías de oficio',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    _selectorCategorias(cargando),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: cargando ? null : () => _guardar(p),
                    child: cargando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar cambios'),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed:
                        cargando ? null : () => context.go('/perfil/baja'),
                    icon: const Icon(Icons.person_off_outlined,
                        color: Color(0xFFC62828)),
                    label: const Text('Dar de baja mi cuenta',
                        style: TextStyle(color: Color(0xFFC62828))),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _selectorCategorias(bool cargando) {
    final categorias = ref.watch(categoriasActivasProvider);

    return categorias.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('No pudimos cargar las categorías: $e'),
      data: (lista) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: lista.map((c) {
          final elegida = _categorias.contains(c.slug);
          return FilterChip(
            label: Text(c.nombre),
            selected: elegida,
            onSelected: cargando
                ? null
                : (valor) {
                    setState(() {
                      if (valor) {
                        if (_categorias.length >= _maxCategorias) {
                          mostrarMensaje(context,
                              'Podés elegir hasta $_maxCategorias oficios.');
                          return;
                        }
                        _categorias.add(c.slug);
                      } else {
                        _categorias.remove(c.slug);
                      }
                    });
                  },
          );
        }).toList(),
      ),
    );
  }
}
