import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/colores.dart';
import '../../../../core/providers/supabase_providers.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../denuncias/presentation/reportar_usuario.dart';
import '../../data/reputacion_repository.dart';
import '../../domain/perfil_publico.dart';
import '../widgets/estrellas.dart';

/// CU-27 — Acceder a Perfil por Link (Figura 3.6).
///
/// Ruta neutral `/p/:slug` de la Web: la abre un Buscador sin cuenta desde el
/// enlace que le mandó el Profesional por WhatsApp. *Mobile first*: en el
/// celular, trabajos y reseñas van uno debajo del otro; desde 760 px de ancho,
/// lado a lado como en la figura.
class PerfilPublicoScreen extends ConsumerWidget {
  const PerfilPublicoScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilPublicoProvider(slug));
    // CU-41: reportar exige sesión (precondición del caso de uso). Sin
    // cuenta, el perfil se ve igual y el botón no aparece.
    final conSesion =
        ref.watch(supabaseClientProvider).auth.currentSession != null;

    return Scaffold(
      backgroundColor: Colores.fondo,
      body: perfil.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Mensaje(
          icono: Icons.wifi_off,
          titulo: 'No pudimos cargar el perfil',
          detalle: 'Revisá tu conexión e intentá de nuevo.',
          accion: 'Reintentar',
          onAccion: () => ref.invalidate(perfilPublicoProvider(slug)),
        ),
        data: (p) => p == null
            ? _Mensaje(
                icono: Icons.person_search_outlined,
                titulo: 'Este perfil no está disponible',
                detalle: 'El enlace está incompleto o el profesional ya no '
                    'tiene su perfil activo en Laburito.',
                accion: 'Ir a Laburito',
                onAccion: () => context.go('/login'),
              )
            : _Perfil(
                perfil: p,
                acciones: conSesion
                    ? Center(
                        child: TextButton.icon(
                          onPressed: () => mostrarReporteUsuario(
                            context,
                            sobre: p.nombreCompleto,
                            slug: p.slug,
                          ),
                          icon: const Icon(Icons.flag_outlined,
                              color: Colores.textoSecundario),
                          label: const Text(
                            'Reportar a este profesional',
                            style: TextStyle(color: Colores.textoSecundario),
                          ),
                        ),
                      )
                    : null,
              ),
      ),
    );
  }
}

class _Perfil extends StatelessWidget {
  const _Perfil({required this.perfil, this.acciones});

  final PerfilPublico perfil;
  final Widget? acciones;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _Encabezado(perfil: perfil),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: LayoutBuilder(
                  builder: (context, restricciones) {
                    final trabajos = _Trabajos(fotos: perfil.portafolio);
                    final resenas = _Resenas(resenas: perfil.resenas);
                    final ancho = restricciones.maxWidth >= 760;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if ((perfil.descripcion ?? '').trim().isNotEmpty) ...[
                          TarjetaPanel(
                            child: Text(
                              perfil.descripcion!.trim(),
                              style: const TextStyle(color: Colores.texto),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (ancho)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: trabajos),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: resenas),
                            ],
                          )
                        else ...[
                          trabajos,
                          const SizedBox(height: 16),
                          resenas,
                        ],
                        if (acciones != null) ...[
                          const SizedBox(height: 16),
                          acciones!,
                        ],
                        const SizedBox(height: 32),
                        const Center(child: LogoLaburito(alto: 28)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.perfil});

  final PerfilPublico perfil;

  @override
  Widget build(BuildContext context) {
    final promedio = perfil.calificacionPromedio;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colores.azul, Colores.azulMedio],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colores.superficie,
                  backgroundImage: perfil.avatarUrl != null
                      ? NetworkImage(perfil.avatarUrl!)
                      : null,
                  child: perfil.avatarUrl == null
                      ? Text(
                          perfil.inicial,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colores.azul,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            perfil.nombreCompleto,
                            style: const TextStyle(
                              color: Colores.textoSobreColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const _Insignia(
                            icono: Icons.verified_outlined,
                            texto: 'Cuenta verificada',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (promedio != null && perfil.totalCalificaciones > 0)
                        // Wrap y no Row: a 360 px con un nombre largo, el
                        // contador baja de renglón en vez de desbordar.
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Estrellas(valor: promedio),
                            Text(
                              '${promedioLegible(promedio)} · '
                              '${perfil.totalCalificaciones} '
                              '${perfil.totalCalificaciones == 1 ? 'reseña' : 'reseñas'}',
                              style: const TextStyle(
                                color: Colores.textoSobreColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Todavía sin reseñas',
                          style: TextStyle(
                            color: Colores.textoSobreColor,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final oficio in perfil.oficios)
                            _Insignia(texto: oficio),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Insignia extends StatelessWidget {
  const _Insignia({required this.texto, this.icono});

  final String texto;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colores.textoSobreColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 14, color: Colores.textoSobreColor),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: const TextStyle(
              color: Colores.textoSobreColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Trabajos extends StatelessWidget {
  const _Trabajos({required this.fotos});

  final List<FotoPublica> fotos;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Titulo('Trabajos realizados'),
        const SizedBox(height: 10),
        if (fotos.isEmpty)
          const TarjetaPanel(
            child: Text(
              'Este profesional todavía no subió fotos de sus trabajos.',
              style: TextStyle(color: Colores.textoSecundario),
            ),
          )
        else
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final foto in fotos)
                ClipRRect(
                  borderRadius: BorderRadius.circular(Medidas.radio),
                  child: InkWell(
                    onTap: () => _ampliar(context, foto),
                    child: Image.network(
                      foto.url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colores.neutroSuave,
                        child: const Icon(Icons.broken_image_outlined,
                            color: Colores.textoTenue),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  void _ampliar(BuildContext context, FotoPublica foto) => showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InteractiveViewer(child: Image.network(foto.url)),
              if ((foto.descripcion ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(foto.descripcion!),
                ),
            ],
          ),
        ),
      );
}

class _Resenas extends StatelessWidget {
  const _Resenas({required this.resenas});

  final List<Resena> resenas;

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d/M/yyyy');

    return TarjetaPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Titulo('Reseñas'),
          const SizedBox(height: 8),
          if (resenas.isEmpty)
            const Text(
              'Todavía nadie calificó a este profesional.',
              style: TextStyle(color: Colores.textoSecundario),
            ),
          for (final (i, r) in resenas.indexed) ...[
            if (i > 0) const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colores.azulSuave,
                  child: Text(
                    r.autor.isEmpty ? '?' : r.autor.characters.first,
                    style: const TextStyle(
                      color: Colores.azulMedio,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.autor,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colores.texto,
                        ),
                      ),
                      Row(
                        children: [
                          Estrellas(valor: r.puntaje.toDouble(), tamano: 14),
                          const SizedBox(width: 6),
                          Text(
                            fecha.format(r.fecha.toLocal()),
                            style: const TextStyle(
                              color: Colores.textoTenue,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if ((r.comentario ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          r.comentario!.trim(),
                          style: const TextStyle(color: Colores.texto),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Colores.texto,
        ),
      );
}

/// El 404 propio del flujo alterno del CU-27 y el error de red.
class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.accion,
    required this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final String accion;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return TarjetaFormulario(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LogoLaburito(alto: 32),
          const SizedBox(height: 32),
          Icon(icono, size: 56, color: Colores.textoTenue),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
          OutlinedButton(onPressed: onAccion, child: Text(accion)),
        ],
      ),
    );
  }
}
