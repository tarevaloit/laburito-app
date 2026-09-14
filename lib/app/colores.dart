import 'package:flutter/material.dart';

/// Tokens de diseño de Laburito: colores y medidas.
///
/// **Regla del proyecto: ninguna pantalla define un color literal.** Todo sale
/// de acá. Si hace falta un color nuevo, se agrega en este archivo con nombre
/// propio y recién después se usa en la UI.
///
/// Los valores salen del *ANEXO UI — Interfaces de usuario* del ERS (v0.2.0):
/// el azul marino del isotipo, el naranja de la llave y los grises de las
/// capturas. La correspondencia figura por figura está en `docs/UI.md`.
class Colores {
  const Colores._();

  // ─── Marca ──────────────────────────────────────────────────────────────
  /// Azul marino del logotipo. Títulos, barra del panel Admin, chips activos.
  static const Color azul = Color(0xFF1B3B6F);

  /// Azul de interacción: enlaces, foco de los campos, selección.
  static const Color azulMedio = Color(0xFF1E63C4);

  /// Fondo tenue de avatares, íconos y bloques informativos.
  static const Color azulSuave = Color(0xFFE8EDF5);

  /// Naranja de la llave. **Color de la acción principal (CTA) de cada pantalla.**
  static const Color naranja = Color(0xFFF2811D);

  /// Naranja presionado / hover.
  static const Color naranjaOscuro = Color(0xFFD96D0F);

  /// Fondo tenue del naranja, para avisos que piden una acción.
  static const Color naranjaSuave = Color(0xFFFDEEDD);

  // ─── Superficies ────────────────────────────────────────────────────────
  /// Gris azulado del lienzo de todas las pantallas.
  static const Color fondo = Color(0xFFEDF1F6);

  /// Blanco de tarjetas, campos y hojas modales.
  static const Color superficie = Color(0xFFFFFFFF);

  /// Borde de tarjetas, campos y separadores.
  static const Color borde = Color(0xFFDCE0E6);

  /// Fondo tenue neutro: el estado que no es ni bueno ni malo ni pendiente.
  /// Lo usa el chip de «Vencido», que no puede ser rojo —no es un error— ni
  /// naranja —no hay nada que el usuario tenga que hacer ya mismo—.
  static const Color neutroSuave = Color(0xFFEFF1F4);

  // ─── Texto ──────────────────────────────────────────────────────────────
  /// Texto principal. No se usa negro puro.
  static const Color texto = Color(0xFF12263F);

  /// Texto de apoyo: descripciones, ayudas, etiquetas de dato.
  static const Color textoSecundario = Color(0xFF5A6B7F);

  /// Texto deshabilitado, notas al pie, íconos inactivos.
  static const Color textoTenue = Color(0xFF90A0B0);

  /// Texto e íconos sobre naranja, azul o rojo.
  static const Color textoSobreColor = Color(0xFFFFFFFF);

  // ─── Estados ────────────────────────────────────────────────────────────
  static const Color exito = Color(0xFF2E7D32);
  static const Color exitoSuave = Color(0xFFE8F5E9);
  static const Color exitoBorde = Color(0xFFA5D6A7);

  static const Color error = Color(0xFFC62828);
  static const Color errorSuave = Color(0xFFFDECEA);
  static const Color errorBorde = Color(0xFFF5C6C0);

  /// Rojo atenuado: botón destructivo deshabilitado.
  static const Color errorApagado = Color(0xFFE0A9A4);
}

/// Medidas repetidas de la interfaz. Mismo criterio que [Colores]: no se
/// escriben números sueltos de radio o altura en las pantallas.
class Medidas {
  const Medidas._();

  /// Radio de campos, botones y avisos.
  static const double radio = 12;

  /// Radio de tarjetas y opciones grandes.
  static const double radioGrande = 16;

  /// Alto de los botones de acción principal.
  static const double altoBoton = 52;

  /// Ancho máximo de un formulario: evita que la Web estire los campos.
  static const double anchoFormulario = 420;
}
