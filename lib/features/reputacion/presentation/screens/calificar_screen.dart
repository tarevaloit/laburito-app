import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/reputacion_repository.dart';
import '../../domain/calificacion.dart';
import '../widgets/estrellas.dart';

/// CU-28 — Calificar Profesional (vía link de un solo uso), Figura 3.7.
///
/// Ruta neutral `/calificar/:token` de la Web: la abre el Buscador desde el
/// WhatsApp del Profesional, sin cuenta. Las estrellas son obligatorias (paso
/// 4) y el comentario, opcional. Con el enlace ya usado, el formulario no se
/// muestra (flujo alterno 1.1); tampoco si se usa en otra pestaña mientras
/// esta estaba abierta.
class CalificarScreen extends ConsumerWidget {
  const CalificarScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enlace = ref.watch(enlaceCalificacionProvider(token));

    return Scaffold(
      backgroundColor: Colores.fondo,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colores.superficie,
        title: const LogoLaburito(alto: 30),
      ),
      body: TarjetaFormulario(
        child: TarjetaPanel(
          padding: const EdgeInsets.all(24),
          child: enlace.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => _Aviso(
              icono: Icons.wifi_off,
              titulo: 'No pudimos abrir el enlace',
              detalle: 'Revisá tu conexión e intentá de nuevo.',
              accion: 'Reintentar',
              onAccion: () => ref.invalidate(enlaceCalificacionProvider(token)),
            ),
            data: (info) => switch (info.estado) {
              EstadoEnlaceCalificacion.disponible =>
                _Formulario(token: token, info: info),
              EstadoEnlaceCalificacion.usado => const _Aviso(
                  icono: Icons.lock_outline,
                  titulo: 'Este enlace ya se usó',
                  detalle: 'Cada enlace de calificación sirve una sola vez, '
                      'y con este ya se calificó el trabajo.',
                ),
              EstadoEnlaceCalificacion.invalido => _Aviso(
                  icono: Icons.link_off,
                  titulo: 'Este enlace no es válido',
                  detalle: 'Puede estar incompleto o el profesional te mandó '
                      'uno más nuevo. Pedile que te lo vuelva a enviar.',
                  accion: 'Ir a Laburito',
                  onAccion: () => context.go('/login'),
                ),
            },
          ),
        ),
      ),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.token, required this.info});

  final String token;
  final EnlaceCalificacion info;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  final _comentario = TextEditingController();
  int _puntaje = 0;
  bool _faltaPuntaje = false;
  bool _enviando = false;
  bool _enviada = false;
  bool _usadoMientrasTanto = false;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_puntaje == 0) {
      setState(() => _faltaPuntaje = true);
      return;
    }

    setState(() => _enviando = true);
    try {
      await ref.read(reputacionRepositoryProvider).calificar(
            widget.token,
            puntaje: _puntaje,
            comentario: _comentario.text,
          );
      if (mounted) setState(() => _enviada = true);
    } on EnlaceUsadoException {
      if (mounted) setState(() => _usadoMientrasTanto = true);
    } catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.info.nombre ?? 'el profesional';

    if (_enviada) {
      return _Aviso(
        icono: Icons.check_circle_outline,
        color: Colores.exito,
        titulo: '¡Gracias por tu calificación!',
        detalle: 'Tu opinión sobre $nombre ya está en su perfil y ayuda a '
            'otros buscadores a elegir. Ya podés cerrar esta pestaña.',
      );
    }
    if (_usadoMientrasTanto) {
      return const _Aviso(
        icono: Icons.lock_outline,
        titulo: 'Este enlace ya se usó',
        detalle: 'Cada enlace de calificación sirve una sola vez, y con este '
            'ya se calificó el trabajo.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colores.azulSuave,
            backgroundImage: widget.info.avatarUrl != null
                ? NetworkImage(widget.info.avatarUrl!)
                : null,
            child: widget.info.avatarUrl == null
                ? Text(
                    widget.info.inicial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colores.azulMedio,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¿Cómo fue tu experiencia con $nombre?',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colores.azul,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tu opinión ayuda a otros buscadores',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colores.textoSecundario, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                key: Key('estrella-$i'),
                tooltip: '$i ${i == 1 ? 'estrella' : 'estrellas'}',
                iconSize: 40,
                visualDensity: VisualDensity.compact,
                onPressed: _enviando
                    ? null
                    : () => setState(() {
                          _puntaje = i;
                          _faltaPuntaje = false;
                        }),
                icon: Icon(
                  i <= _puntaje ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i <= _puntaje ? colorEstrella : Colores.borde,
                ),
              ),
          ],
        ),
        SizedBox(
          height: 20,
          child: Text(
            _faltaPuntaje
                ? 'Elegí de 1 a 5 estrellas para enviar tu calificación.'
                : leyendaPuntaje(_puntaje),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _faltaPuntaje ? Colores.error : Colores.naranja,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('comentario-calificacion'),
          controller: _comentario,
          enabled: !_enviando,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Contá cómo fue el trabajo (opcional)',
          ),
        ),
        const SizedBox(height: 8),
        BotonPrincipal(
          texto: 'Enviar calificación',
          cargando: _enviando,
          onPressed: _enviar,
        ),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.titulo,
    required this.detalle,
    this.color = Colores.textoTenue,
    this.accion,
    this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final Color color;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 52, color: color),
        const SizedBox(height: 12),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colores.texto,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detalle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colores.textoSecundario),
        ),
        if (accion != null) ...[
          const SizedBox(height: 20),
          OutlinedButton(onPressed: onAccion, child: Text(accion!)),
        ],
      ],
    );
  }
}
