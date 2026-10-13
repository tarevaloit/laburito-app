import 'package:flutter/material.dart';

/// Amarillo de las estrellas de las Figuras 3.6 y 3.7.
const Color colorEstrella = Color(0xFFF5B301);

/// Estrellas de solo lectura: el promedio del Profesional (con medias
/// estrellas) o el puntaje de una reseña.
class Estrellas extends StatelessWidget {
  const Estrellas({super.key, required this.valor, this.tamano = 16});

  final double valor;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            valor >= i
                ? Icons.star_rounded
                : valor >= i - 0.5
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: tamano,
            color: colorEstrella,
          ),
      ],
    );
  }
}

/// El promedio con una coma decimal, como se escribe en castellano: «4,8».
String promedioLegible(double promedio) =>
    promedio.toStringAsFixed(1).replaceAll('.', ',');
