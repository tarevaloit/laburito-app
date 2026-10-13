import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/barra_navegacion.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../categorias/data/categorias_repository.dart';
import '../../../categorias/presentation/selector_oficios.dart';
import '../../../reputacion/presentation/widgets/compartir_perfil.dart';
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
  static const int _maxCategorias = CategoriaOficio.maximoPorProfesional;

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
      bottomNavigationBar: BarraNavegacion.siCorresponde(
        actual: SeccionApp.perfil,
        mostrarBilletera: perfilAsync.valueOrNull?.esProfesional ?? false,
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
                          backgroundColor: Colores.azulSuave,
                          backgroundImage: p.avatarUrl != null
                              ? NetworkImage(p.avatarUrl!)
                              : null,
                          child: p.avatarUrl == null
                              ? Text(
                                  p.nombre.characters.first.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    color: Colores.azul,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: Colores.naranja,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: cargando ? null : _cambiarAvatar,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.camera_alt,
                                    size: 18, color: Colores.textoSobreColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (p.esProfesional) ...[
                    const SizedBox(height: 24),
                    // CU-26. Solo se ofrece con la documentación aprobada:
                    // el perfil público muestra «Cuenta verificada».
                    if (p.estadoVerificacion == 'aprobado') ...[
                      CompartirPerfil(suspendida: p.estado == 'suspendido'),
                      const SizedBox(height: 8),
                      // CU-45 y CU-28: los accesos de la Figura 3.17.
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.bar_chart,
                            color: Colores.azulMedio),
                        title: const Text('Mis estadísticas'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/profesional/estadisticas'),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.people_outline,
                            color: Colores.azulMedio),
                        title: const Text('Mis contactos y calificaciones'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/profesional/contactos'),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  CampoTexto(
                    etiqueta: 'Correo electrónico',
                    initialValue: p.email,
                    enabled: false,
                    ayuda: 'El correo no se puede modificar',
                    icono: Icons.mail_outline,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Nombre',
                    controller: _nombre,
                    enabled: !cargando,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validadores.nombre(v, campo: 'nombre'),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Apellido',
                    controller: _apellido,
                    enabled: !cargando,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validadores.nombre(v, campo: 'apellido'),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Teléfono',
                    controller: _telefono,
                    enabled: !cargando,
                    keyboardType: TextInputType.phone,
                    icono: Icons.phone_outlined,
                    validator: Validadores.telefono,
                  ),
                  if (p.esProfesional) ...[
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Descripción de tu trabajo',
                      controller: _descripcion,
                      enabled: !cargando,
                      maxLines: 4,
                      maxLength: 500,
                      ejemplo:
                          'Contá tu experiencia, qué trabajos hacés, tus horarios…',
                      validator: Validadores.descripcion,
                    ),
                    SelectorOficios(
                      elegidas: _categorias,
                      habilitado: !cargando,
                      maximo: _maxCategorias,
                      onCambio: (nuevas, {required alTope}) {
                        if (alTope) {
                          mostrarMensaje(context,
                              'Podés elegir hasta $_maxCategorias oficios.');
                          return;
                        }
                        setState(() {
                          _categorias
                            ..clear()
                            ..addAll(nuevas);
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  BotonPrincipal(
                    texto: 'Guardar cambios',
                    cargando: cargando,
                    onPressed: () => _guardar(p),
                  ),
                  const Divider(),
                  TextButton.icon(
                    onPressed:
                        cargando ? null : () => context.go('/perfil/baja'),
                    icon: const Icon(Icons.person_off_outlined,
                        color: Colores.error),
                    label: const Text('Dar de baja mi cuenta',
                        style: TextStyle(color: Colores.error)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
