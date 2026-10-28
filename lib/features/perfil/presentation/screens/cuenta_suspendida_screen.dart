import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/colores.dart';
import '../../../../core/config/contacto.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/perfil_repository.dart';
import '../../data/suspension_repository.dart';

/// CU-49 — Recuperar Cuenta Bloqueada, como pantalla propia
/// (`/cuenta-suspendida`). El home la muestra en lugar de su contenido cuando
/// la cuenta está suspendida: es adonde llega el login (paso 1).
class CuentaSuspendidaScreen extends StatelessWidget {
  const CuentaSuspendidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuenta suspendida')),
      body: const CuentaSuspendida(),
    );
  }
}

/// El contenido: motivo, plazo y la apelación (pasos 2 a 6).
class CuentaSuspendida extends ConsumerStatefulWidget {
  const CuentaSuspendida({super.key});

  @override
  ConsumerState<CuentaSuspendida> createState() => _CuentaSuspendidaState();
}

class _CuentaSuspendidaState extends ConsumerState<CuentaSuspendida> {
  final _formulario = GlobalKey<FormState>();
  final _descargo = TextEditingController();
  bool _escribiendo = false;
  bool _enviando = false;

  @override
  void dispose() {
    _descargo.dispose();
    super.dispose();
  }

  Future<void> _apelar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() => _enviando = true);
    try {
      final numero = await ref
          .read(suspensionRepositoryProvider)
          .apelar(_descargo.text.trim());
      ref.invalidate(miSuspensionProvider);
      if (!mounted) return;
      setState(() => _escribiendo = false);
      // Paso 6: «confirma la recepción del trámite y otorga un número de
      // ticket para seguimiento».
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Recibimos tu apelación'),
          content: Text(
            'Tu número de trámite es el #$numero. El equipo de administración '
            'la revisa y te avisamos el resultado.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _salir() async {
    await ref.read(authControllerProvider.notifier).cerrarSesion();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final suspension = ref.watch(miSuspensionProvider);

    return TarjetaFormulario(
      child: suspension.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AvisoEstado.riesgo(
          icono: Icons.error_outline,
          titulo: 'No pudimos cargar el estado de tu cuenta',
          detalle: MensajesError.desde(e),
        ),
        data: (s) {
          if (s == null) {
            // Venció mientras tanto o la levantaron: la cuenta ya está activa.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AvisoEstado.exito(
                  icono: Icons.lock_open,
                  titulo: 'Tu cuenta está activa otra vez',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(perfilCompletoProvider);
                    context.go('/home');
                  },
                  child: const Text('Ir al inicio'),
                ),
              ],
            );
          }

          final apelacion = s.apelacion;
          return Form(
            key: _formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AvisoEstado.riesgo(
                  icono: Icons.gavel,
                  titulo: s.permanente
                      ? 'Tu cuenta está suspendida de forma permanente'
                      : 'Tu cuenta está suspendida hasta el '
                          '${Fechas.larga(s.hasta!.toLocal())}',
                  detalle: 'Motivo: ${s.motivo}',
                ),
                const SizedBox(height: 16),
                if (apelacion != null && apelacion.pendiente)
                  AvisoEstado.pendiente(
                    icono: Icons.hourglass_top,
                    titulo: 'Tu apelación #${apelacion.numero} está en revisión',
                    detalle: 'Te avisamos apenas el equipo la resuelva.',
                  )
                else if (apelacion != null && apelacion.estado == 'rechazada')
                  AvisoEstado.pendiente(
                    icono: Icons.info_outline,
                    titulo: 'Rechazamos tu apelación #${apelacion.numero}',
                    detalle: apelacion.respuesta,
                  ),
                if (!s.apelable) ...[
                  // Flujo alterno 1.1.
                  const Text(
                    'Esta sanción no admite apelación según los términos de '
                    'uso. Si querés hacer un reclamo, escribí a soporte legal:',
                    style: TextStyle(color: Colores.textoSecundario),
                  ),
                  TextButton.icon(
                    key: const Key('correo-legales'),
                    onPressed: () => launchUrl(Contacto.mailLegales),
                    icon: const Icon(Icons.mail_outline),
                    label: const Text(Contacto.correoLegales),
                  ),
                ] else if (s.puedeApelar) ...[
                  const SizedBox(height: 8),
                  if (!_escribiendo)
                    FilledButton.icon(
                      key: const Key('apelar-sancion'),
                      onPressed: () => setState(() => _escribiendo = true),
                      icon: const Icon(Icons.record_voice_over_outlined),
                      label: const Text('Apelar sanción'),
                    )
                  else ...[
                    CampoTexto(
                      key: const Key('descargo'),
                      etiqueta: 'Tu descargo',
                      ejemplo: 'Contanos qué pasó y por qué la sanción no '
                          'corresponde.',
                      controller: _descargo,
                      enabled: !_enviando,
                      maxLines: 5,
                      maxLength: 1000,
                      validator: (v) => (v ?? '').trim().length < 20
                          ? 'Escribilo en al menos 20 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      key: const Key('enviar-apelacion'),
                      onPressed: _enviando ? null : _apelar,
                      child: Text(_enviando ? 'Enviando…' : 'Enviar apelación'),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.push('/ayuda'),
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Ayuda y soporte'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _salir,
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
