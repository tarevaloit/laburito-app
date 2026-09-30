import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../perfil/data/perfil_repository.dart';

/// Secciones del panel del administrador. En el Sprint 4 existen las dos de la
/// billetera; el Sprint 6 suma Dashboard, Validaciones, Denuncias y Categorías
/// sobre este mismo armazón (Figuras 3.20 a 3.24).
enum SeccionAdmin {
  precios('Precios', Icons.sell_outlined, '/admin/precios'),
  cupones('Cupones', Icons.confirmation_number_outlined, '/admin/cupones');

  const SeccionAdmin(this.titulo, this.icono, this.ruta);

  final String titulo;
  final IconData icono;
  final String ruta;
}

/// Armazón del panel web del administrador (Figura 3.24): barra lateral azul a
/// la izquierda y el contenido a la derecha. En pantallas angostas la barra se
/// vuelve un menú.
///
/// Vive en la misma app Flutter que el resto (decisión del 19/08: un solo
/// proyecto). El rol se valida **acá**, como en las pantallas del Buscador:
/// el `redirect` del router no puede leer el perfil de forma sincrónica. Lo que
/// de verdad protege las operaciones son las funciones de la base, que
/// empiezan preguntando `es_admin()`.
///
/// Adelanta la mitigación del apartado 6 de la planificación: el armazón del
/// panel y sus componentes de tabla y formulario, previstos para el Sprint 5.
class PanelAdmin extends ConsumerWidget {
  const PanelAdmin({super.key, required this.actual, required this.child});

  final SeccionAdmin actual;
  final Widget child;

  static const double _anchoLateral = 220;
  static const double _anchoMinimoConLateral = 840;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilCompletoProvider);

    final contenido = perfil.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('No pudimos cargar tu perfil: $e')),
      data: (p) => p?.esAdministrador ?? false
          ? child
          : const Padding(
              padding: EdgeInsets.all(24),
              child: AvisoEstado.riesgo(
                icono: Icons.lock_outline,
                titulo: 'Esta sección es solo para administradores',
                detalle: 'Tu cuenta no tiene permisos de administración.',
              ),
            ),
    );

    return LayoutBuilder(
      builder: (context, restricciones) {
        final conLateral = restricciones.maxWidth >= _anchoMinimoConLateral;

        return Scaffold(
          backgroundColor: Colores.fondo,
          appBar: conLateral
              ? null
              : AppBar(
                  title: Text(actual.titulo),
                  backgroundColor: Colores.azul,
                  foregroundColor: Colores.textoSobreColor,
                ),
          drawer: conLateral
              ? null
              : Drawer(
                  backgroundColor: Colores.azul,
                  child: _Lateral(actual: actual),
                ),
          body: conLateral
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: _anchoLateral,
                      child: ColoredBox(
                        color: Colores.azul,
                        child: _Lateral(actual: actual),
                      ),
                    ),
                    Expanded(child: contenido),
                  ],
                )
              : contenido,
        );
      },
    );
  }
}

class _Lateral extends StatelessWidget {
  const _Lateral({required this.actual});

  final SeccionAdmin actual;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'Laburito',
                    style: TextStyle(
                      color: Colores.textoSobreColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colores.naranja,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colores.textoSobreColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (final seccion in SeccionAdmin.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  selected: seccion == actual,
                  selectedTileColor: Colores.textoSobreColor.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Medidas.radio),
                  ),
                  leading: Icon(seccion.icono, color: Colores.textoSobreColor),
                  title: Text(
                    seccion.titulo,
                    style: const TextStyle(color: Colores.textoSobreColor),
                  ),
                  onTap: () => context.go(seccion.ruta),
                ),
              ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.home_outlined,
                  color: Colores.textoSobreColor),
              title: const Text('Volver al inicio',
                  style: TextStyle(color: Colores.textoSobreColor)),
              onTap: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Encabezado de cada sección: título grande y bajada, como «Campañas y
/// cupones · Generá códigos para regalar tokens» de la Figura 3.24.
class EncabezadoAdmin extends StatelessWidget {
  const EncabezadoAdmin({super.key, required this.titulo, required this.bajada});

  final String titulo;
  final String bajada;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colores.azul,
          ),
        ),
        const SizedBox(height: 2),
        Text(bajada, style: const TextStyle(color: Colores.textoSecundario)),
      ],
    );
  }
}
