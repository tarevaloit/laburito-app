import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/config/superficie.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/validadores.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../categorias/presentation/selector_oficios.dart';
import '../controllers/auth_controller.dart';
import '../widgets/aceptacion_legal.dart';
import '../widgets/selector_de_rol.dart';

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
  bool _aceptaLegales = false;

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

    if (!_aceptaLegales) {
      mostrarMensaje(
        context,
        'Para crear la cuenta tenés que aceptar los Términos y Condiciones.',
      );
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
                  // En la web se vuelve al selector de rol; en la app nativa
                  // no hay tal cosa, así que se sale al login.
                  ? context.go(Entorno.esWeb ? '/registro' : '/login')
                  : setState(() => _paso = 0),
        ),
      ),
      body: TarjetaFormulario(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PASO ${_paso + 1} DE 2 · ${_paso == 0 ? 'TUS DATOS' : 'TUS OFICIOS'}',
              style: const TextStyle(
                color: Colores.naranja,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
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
          MarcaLaburito(
            altoLogo: 64,
            titulo: Entorno.esWeb ? 'Creá tu cuenta' : 'Crear cuenta · Profesional',
            subtitulo: 'Contanos quién sos',
          ),
          const SizedBox(height: 24),
          // El cambio de rol es de la web: en la app nativa el alta es
          // siempre de Profesional.
          if (Entorno.permiteAltaDeBuscador) ...[
            SelectorDeRol(
              esBuscador: false,
              habilitado: !cargando,
              onElegirBuscador: () => context.go('/registro'),
              onElegirProfesional: () {},
            ),
            const SizedBox(height: 24),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CampoTexto(
                  etiqueta: 'Nombre',
                  controller: _nombre,
                  enabled: !cargando,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validadores.nombre(v, campo: 'nombre'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CampoTexto(
                  etiqueta: 'Apellido',
                  controller: _apellido,
                  enabled: !cargando,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validadores.nombre(v, campo: 'apellido'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'DNI',
            controller: _dni,
            enabled: !cargando,
            keyboardType: TextInputType.number,
            ejemplo: '33.456.789',
            icono: Icons.badge_outlined,
            validator: Validadores.dni,
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Correo electrónico',
            controller: _email,
            enabled: !cargando,
            keyboardType: TextInputType.emailAddress,
            ejemplo: 'marcelo.g@gmail.com',
            icono: Icons.mail_outline,
            validator: Validadores.email,
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Teléfono',
            controller: _telefono,
            enabled: !cargando,
            keyboardType: TextInputType.phone,
            ayuda: 'Código de área y número, sin 0 ni 15',
            icono: Icons.phone_outlined,
            validator: Validadores.telefono,
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Contraseña',
            controller: _password,
            enabled: !cargando,
            obscureText: _ocultarPassword,
            ayuda: 'Mínimo 8 caracteres, una mayúscula y un número',
            icono: Icons.lock_outline,
            sufijo: OjoPassword(
              oculto: _ocultarPassword,
              onCambio: () =>
                  setState(() => _ocultarPassword = !_ocultarPassword),
            ),
            validator: Validadores.password,
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Repetir contraseña',
            controller: _repetir,
            enabled: !cargando,
            obscureText: _ocultarPassword,
            icono: Icons.lock_outline,
            validator: (v) => Validadores.repetirPassword(v, _password.text),
          ),
          const SizedBox(height: 24),
          BotonPrincipal(
            texto: 'Continuar',
            cargando: cargando,
            onPressed: _siguiente,
          ),
        ],
      ),
    );
  }

  Widget _paso2(bool cargando) {
    return Form(
      key: _formPaso2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tus oficios',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colores.azul,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Elegí hasta $_maxCategorias. Vas a recibir alertas solo de esas categorías.',
            style: TextStyle(
              color: Colores.textoSecundario,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SelectorOficios(
            elegidas: _categoriasElegidas,
            habilitado: !cargando,
            maximo: _maxCategorias,
            onCambio: (nuevas, {required alTope}) {
              if (alTope) {
                mostrarMensaje(
                    context, 'Podés elegir hasta $_maxCategorias oficios.');
                return;
              }
              setState(() {
                _categoriasElegidas
                  ..clear()
                  ..addAll(nuevas);
              });
            },
          ),
          const SizedBox(height: 24),
          CampoTexto(
            etiqueta: 'Descripción de tu trabajo (opcional)',
            controller: _descripcion,
            enabled: !cargando,
            maxLines: 4,
            maxLength: 500,
            ejemplo: 'Contá tu experiencia, qué trabajos hacés, tus horarios…',
            validator: Validadores.descripcion,
          ),
          const SizedBox(height: 8),
          AceptacionLegal(
            aceptado: _aceptaLegales,
            habilitado: !cargando,
            onCambio: (v) => setState(() => _aceptaLegales = v),
          ),
          const SizedBox(height: 20),
          BotonPrincipal(
            texto: 'Finalizar registro',
            cargando: cargando,
            onPressed: _registrar,
          ),
        ],
      ),
    );
  }
}
