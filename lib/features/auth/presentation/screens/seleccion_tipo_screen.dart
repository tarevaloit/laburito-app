import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/marca_laburito.dart';

/// Bifurcación previa al alta: CU-01 (Buscador) o CU-02 (Profesional).
class SeleccionTipoScreen extends StatelessWidget {
  const SeleccionTipoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: TarjetaFormulario(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MarcaLaburito(subtitulo: '¿Cómo querés usar Laburito?'),
            const SizedBox(height: 32),
            _OpcionRegistro(
              icono: Icons.search_rounded,
              titulo: 'Busco un profesional',
              detalle:
                  'Publicá tu necesidad y recibí propuestas de profesionales de tu zona.',
              color: AppTheme.azul,
              onTap: () => context.go('/registro/buscador'),
            ),
            const SizedBox(height: 16),
            _OpcionRegistro(
              icono: Icons.handyman_rounded,
              titulo: 'Ofrezco mi oficio',
              detalle:
                  'Recibí alertas de pedidos cercanos y conseguí más trabajo.',
              color: AppTheme.naranja,
              onTap: () => context.go('/registro/profesional'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Ya tengo cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionRegistro extends StatelessWidget {
  const _OpcionRegistro({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDCE0E6)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icono, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(detalle,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13, height: 1.3)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
