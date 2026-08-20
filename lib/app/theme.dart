import 'package:flutter/material.dart';

import 'colores.dart';

/// Tema único de la aplicación, armado con los tokens de [Colores] y [Medidas].
///
/// Criterio del ANEXO UI (ERS v0.2.0):
/// - **El naranja es la acción principal.** Un solo botón naranja por pantalla.
/// - **El azul marino es la marca**: títulos, chips activos, barra superior.
/// - **El azul medio es interacción**: enlaces, foco de los campos.
/// - Fondo gris azulado, contenido sobre tarjetas blancas de borde fino.
class AppTheme {
  const AppTheme._();

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: Colores.azul,
      primary: Colores.azul,
      onPrimary: Colores.textoSobreColor,
      secondary: Colores.naranja,
      onSecondary: Colores.textoSobreColor,
      surface: Colores.superficie,
      onSurface: Colores.texto,
      error: Colores.error,
      onError: Colores.textoSobreColor,
      outline: Colores.borde,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: Colores.fondo,

      // Barra superior: blanca, plana, con el título en el azul de la marca.
      appBarTheme: const AppBarTheme(
        backgroundColor: Colores.superficie,
        foregroundColor: Colores.azul,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colores.azul,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colores.superficie,
        hintStyle: const TextStyle(color: Colores.textoTenue),
        labelStyle: const TextStyle(color: Colores.textoSecundario),
        helperStyle: const TextStyle(color: Colores.textoSecundario),
        prefixIconColor: Colores.textoSecundario,
        suffixIconColor: Colores.textoSecundario,
        border: _borde(Colores.borde),
        enabledBorder: _borde(Colores.borde),
        disabledBorder: _borde(Colores.borde),
        focusedBorder: _borde(Colores.azulMedio, ancho: 2),
        errorBorder: _borde(Colores.error),
        focusedErrorBorder: _borde(Colores.error, ancho: 2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Acción principal: naranja, ancho completo, 52 px de alto.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colores.naranja,
          foregroundColor: Colores.textoSobreColor,
          minimumSize: const Size.fromHeight(Medidas.altoBoton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Medidas.radio),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Acción secundaria: mismo cuerpo, sin relleno.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colores.azul,
          backgroundColor: Colores.superficie,
          minimumSize: const Size.fromHeight(Medidas.altoBoton),
          side: const BorderSide(color: Colores.borde),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Medidas.radio),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // Enlaces.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colores.azulMedio,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Chips de categoría de oficio: píldoras compactas, azul marino con
      // texto blanco cuando están elegidas (Figura 3.9 del ANEXO UI).
      //
      // El color de la etiqueta va como WidgetStateColor: el `Chip` resuelve
      // los estados de `labelStyle.color`, y sin eso el texto queda oscuro
      // sobre el azul al seleccionar. `secondaryLabelStyle` no sirve acá:
      // solo lo usa `ChoiceChip`, no `FilterChip`.
      chipTheme: ChipThemeData(
        backgroundColor: Colores.superficie,
        selectedColor: Colores.azul,
        checkmarkColor: Colores.textoSobreColor,
        showCheckmark: true,
        side: WidgetStateBorderSide.resolveWith(
          (estados) => BorderSide(
            color: estados.contains(WidgetState.selected)
                ? Colores.azul
                : Colores.borde,
          ),
        ),
        labelStyle: TextStyle(
          color: WidgetStateColor.resolveWith(
            (estados) => estados.contains(WidgetState.selected)
                ? Colores.textoSobreColor
                : Colores.texto,
          ),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        iconTheme: const IconThemeData(size: 16),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),

      // Barra inferior de la app del Profesional: blanca, plana, con la
      // sección activa en el azul de la marca.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colores.superficie,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colores.azulSuave,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            size: 24,
            color: estados.contains(WidgetState.selected)
                ? Colores.azul
                : Colores.textoTenue,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: estados.contains(WidgetState.selected)
                ? Colores.azul
                : Colores.textoSecundario,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Colores.borde,
        thickness: 1,
        space: 32,
      ),

      // El avance del alta va en naranja, como el rótulo «PASO 1 DE 2».
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colores.naranja,
        linearTrackColor: Colores.azulSuave,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(color: Colores.textoSobreColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Medidas.radio),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colores.superficie,
        surfaceTintColor: Colors.transparent,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: Colores.azul,
        textColor: Colores.texto,
      ),
    );

    // Títulos en el azul de la marca, cuerpo en el gris azulado oscuro.
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: Colores.texto,
        displayColor: Colores.azul,
      ),
    );
  }

  static OutlineInputBorder _borde(Color color, {double ancho = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Medidas.radio),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }
}
