import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Encabezado de marca para las pantallas de autenticación.
class MarcaLaburito extends StatelessWidget {
  const MarcaLaburito({super.key, this.subtitulo});

  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.azul.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.handyman_rounded,
              size: 34, color: AppTheme.naranja),
        ),
        const SizedBox(height: 16),
        Text(
          'Laburito',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.azul,
              ),
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitulo!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
          ),
        ],
      ],
    );
  }
}

/// Contenedor centrado y acotado en ancho, para que la Web no se estire.
class TarjetaFormulario extends StatelessWidget {
  const TarjetaFormulario({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: child,
        ),
      ),
    );
  }
}

/// SnackBar unificado para errores y confirmaciones.
void mostrarMensaje(BuildContext context, String texto, {bool esError = true}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
