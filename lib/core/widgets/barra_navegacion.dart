import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/colores.dart';
import '../config/superficie.dart';
import 'marca_laburito.dart';

/// Secciones de la app móvil del Profesional (Figuras 3.11 a 3.19 del ANEXO UI).
enum SeccionApp { tablero, billetera, perfil }

/// Barra de navegación inferior, **solo de la app nativa**.
///
/// En la web devuelve `null` desde [siCorresponde]: el Buscador navega por la
/// barra superior de la marca (Figura 3.1), no por una barra inferior.
///
/// Está la estructura completa del Anexo aunque el Tablero de pedidos (CU-43)
/// sea del Sprint 2 y la Billetera (CU-30) del Sprint 4: las secciones que
/// todavía no existen quedan visibles, marcadas como «Pronto», y avisan al
/// tocarlas. Es a propósito — así la navegación de la demo es la definitiva y
/// no hay que rearmarla cuando lleguen las pantallas.
class BarraNavegacion extends StatelessWidget {
  const BarraNavegacion({
    super.key,
    required this.actual,
    this.mostrarBilletera = true,
  });

  /// Devuelve la barra solo donde corresponde: `null` en la web, para pasarlo
  /// derecho a `Scaffold.bottomNavigationBar`.
  static Widget? siCorresponde({
    required SeccionApp actual,
    required bool mostrarBilletera,
  }) {
    if (!Entorno.usaBarraInferior) return null;
    return BarraNavegacion(actual: actual, mostrarBilletera: mostrarBilletera);
  }

  final SeccionApp actual;

  /// La billetera es de tokens, y los tokens son del Profesional: al Buscador
  /// no se le muestra.
  final bool mostrarBilletera;

  List<SeccionApp> get _sesiones => [
        SeccionApp.tablero,
        if (mostrarBilletera) SeccionApp.billetera,
        SeccionApp.perfil,
      ];

  void _ir(BuildContext context, SeccionApp destino) {
    if (destino == actual) return;

    switch (destino) {
      case SeccionApp.tablero:
        context.go('/home');
      case SeccionApp.perfil:
        context.go('/perfil');
      case SeccionApp.billetera:
        mostrarMensaje(
          context,
          'La billetera y la compra de tokens llegan en el Sprint 4.',
          esError: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colores.borde)),
      ),
      child: NavigationBar(
        selectedIndex: _sesiones.indexOf(actual).clamp(0, _sesiones.length - 1),
        onDestinationSelected: (i) => _ir(context, _sesiones[i]),
        destinations: [
          for (final seccion in _sesiones) _destino(seccion),
        ],
      ),
    );
  }

  NavigationDestination _destino(SeccionApp seccion) {
    switch (seccion) {
      case SeccionApp.tablero:
        return const NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Tablero',
        );
      case SeccionApp.billetera:
        return const NavigationDestination(
          icon: Badge(
            label: Text('Pronto'),
            backgroundColor: Colores.naranja,
            child: Icon(Icons.account_balance_wallet_outlined),
          ),
          label: 'Billetera',
        );
      case SeccionApp.perfil:
        return const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        );
    }
  }
}
