import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../categorias/data/categorias_repository.dart';
import '../controllers/auth_controller.dart';

/// CU-02 — Registrar Profesional.
/// Asistente de dos pasos: datos personales y categorías de oficio.
/// La documentación (CU-09) se carga después de validar el correo, porque
/// las políticas de Storage exigen una sesión activa.
class RegistroProfesionalScreen extends ConsumerStatefulWidget {
  const RegistroProfesionalScreen({super.key});

  @override
  ConsumerState<RegistroProfesionalScreen> createState() =>
      _RegistroProfesionalScreenState();
}

class _RegistroProfesionalScreenState
    extends ConsumerState<RegistroProfesionalScreen> {
  final _formPaso1 = GlobalKey<FormState>();
  final _formPaso2 = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _dni = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _descripcion = TextEditingController();
  final _password = TextEditingController();
  final _repetir = TextEditingController();

  final Set<String> _categoriasElegidas = {};
  int _paso = 0;
  bool _ocultarPassword = true;

  static const int _maxCategorias = 5;

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _apellido,
      _dni,
      _email,
      _telefono,
      _descripcion,
      _password,
      _repetir
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _siguiente() {
    if (!_formPaso1.currentState!.validate()) return;
    setState(() => _paso = 1);
  }

  Future<void> _registrar() async {
    if (!_formPaso2.currentState!.validate()) return;

    if (_categoriasElegidas.isEmpty) {
      mostrarMensaje(context, 'Elegí al menos una categoría de oficio.');
      return;
    }

    final email = _email.text.trim();
    final ok =
        await ref.read(authControllerProvider.notifier).registrarProfesional(
              nombre: _nombre.text,
              apellido: _apellido.text,
              email: email,
              telefono: _telefono.text,
              dni: _dni.text,
              descripcion: _descripcion.text,
              categorias: _categoriasElegidas.toList(),
              password: _password.text,
            );

    if (!mounted) return;
    if (ok) {
      context.go('/verificar?email=${Uri.encodeComponent(email)}');
    } else {
      final error = ref.read(authControllerProvider).error;
      mostrarMensaje(context, MensajesError.desde(error!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: cargando
              ? null
              : () => _paso == 0
                  ? context.go('/registro')
                  : setState(() => _paso = 0),
        ),
        title: Text('Paso ${_paso + 1} de 2'),
      ),
      body: TarjetaFormulario(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_paso + 1) / 2,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 24),
            if (_paso == 0) _paso1(cargando) else _paso2(cargando),
          ],
        ),
      ),
    );
  }

  Widget _paso1(bool cargando) {
    return Form(
      key: _formPaso1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MarcaLaburito(subtitulo: 'Contanos quién sos'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nombre,
                  enabled: !cargando,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => Validadores.nombre(v, campo: 'nombre'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _apellido,
                  enabled: !cargando,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (v) => Validadores.nombre(v, campo: 'apellido'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dni,
            enabled: !cargando,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'DNI',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: Validadores.dni,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            enabled: !cargando,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: Validadores.email,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefono,
            enabled: !cargando,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              helperText: 'Código de área y número, sin 0 ni 15',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: Validadores.telefono,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            enabled: !cargando,
            obscureText: _ocultarPassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              helperText: 'Mínimo 8 caracteres, una mayúscula y un número',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_ocultarPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () =>
                    setState(() => _ocultarPassword = !_ocultarPassword),
              ),
            ),
            validator: Validadores.password,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _repetir,
            enabled: !cargando,
            obscureText: _ocultarPassword,
            decoration: const InputDecoration(
              labelText: 'Repetir contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) => Validadores.repetirPassword(v, _password.text),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: cargando ? null : _siguiente,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Widget _paso2(bool cargando) {
    final categorias = ref.watch(categoriasActivasProvider);

    return Form(
      key: _formPaso2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MarcaLaburito(subtitulo: '¿A qué te dedicás?'),
          const SizedBox(height: 12),
          const Text(
            'Elegí hasta $_maxCategorias oficios. Vas a recibir alertas de los pedidos que coincidan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          categorias.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('No pudimos cargar las categorías: $e'),
            data: (lista) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lista.map((c) {
                final elegida = _categoriasElegidas.contains(c.slug);
                return FilterChip(
                  label: Text(c.nombre),
                  selected: elegida,
                  onSelected: cargando
                      ? null
                      : (valor) {
                          setState(() {
                            if (valor) {
                              if (_categoriasElegidas.length >=
                                  _maxCategorias) {
                                mostrarMensaje(context,
                                    'Podés elegir hasta $_maxCategorias oficios.');
                                return;
                              }
                              _categoriasElegidas.add(c.slug);
                            } else {
                              _categoriasElegidas.remove(c.slug);
                            }
                          });
                        },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _descripcion,
            enabled: !cargando,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Descripción de tu trabajo (opcional)',
              alignLabelWithHint: true,
              hintText:
                  'Contá tu experiencia, qué trabajos hacés, tus horarios…',
            ),
            validator: Validadores.descripcion,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: cargando ? null : _registrar,
            child: cargando
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Crear cuenta'),
          ),
        ],
      ),
    );
  }
}
