import 'package:flutter/material.dart';

import '../../../../app/colores.dart';

/// Selector de rol de la Figura 3.1: dos tarjetas dentro del formulario de
/// alta, no una pantalla aparte.
///
/// Solo existe en la web. En la app nativa el alta es siempre de Profesional
/// (ver `Entorno.permiteAltaDeBuscador`), así que el selector ni se construye.
class SelectorDeRol extends StatelessWidget {
  const SelectorDeRol({
    super.key,
    required this.esBuscador,
    required this.onElegirProfesional,
    required this.onElegirBuscador,
    this.habilitado = true,
  });

  final bool esBuscador;
  final VoidCallback onElegirBuscador;
  final VoidCallback onElegirProfesional;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight acota la altura del Row antes de que `stretch` la pida
    // infinita: adentro de un scroll vertical la altura entra sin límite, y
    // estirar sobre el eje cruzado necesita un máximo conocido.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Opcion(
              icono: Icons.search_rounded,
              titulo: 'Soy Buscador',
              detalle: 'Necesito un servicio',
              elegida: esBuscador,
              onTap: habilitado ? onElegirBuscador : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Opcion(
              icono: Icons.handyman_outlined,
              titulo: 'Ofrezco mi oficio',
              elegida: !esBuscador,
              onTap: habilitado ? onElegirProfesional : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.elegida,
    required this.onTap,
    this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String? detalle;
  final bool elegida;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Medidas.radio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: elegida ? Colores.naranjaSuave : Colores.superficie,
          borderRadius: BorderRadius.circular(Medidas.radio),
          border: Border.all(
            color: elegida ? Colores.naranja : Colores.borde,
            width: elegida ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 22,
              color: elegida ? Colores.naranja : Colores.textoTenue,
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: elegida ? FontWeight.w700 : FontWeight.w600,
                color: elegida ? Colores.texto : Colores.textoSecundario,
              ),
            ),
            if (detalle != null) ...[
              const SizedBox(height: 2),
              Text(
                detalle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colores.textoSecundario,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
