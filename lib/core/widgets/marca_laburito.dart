import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import '../../app/colores.dart';

/// Logotipo completo: isotipo + la palabra «Laburito».
const String kLogoLaburito = 'assets/logo/laburito.png';

/// Solo el isotipo, en formato de ícono de aplicación (el de la Figura 3.8).
const String kIsotipoLaburito = 'assets/logo/laburito_isotipo.png';

/// Qué archivos de logo están realmente empaquetados.
///
/// Se resuelve una sola vez al arrancar. Sin esto, mientras los PNG no existan,
/// cada `Image.asset` dispara un pedido que termina en 404 y llena la consola
/// de errores rojos que no son errores — justo lo que no querés durante una
/// demo. Con el manifiesto en la mano, si el archivo no está ni se lo pide.
class AssetsDeMarca {
  const AssetsDeMarca._();

  static Set<String> _disponibles = const {};

  static Future<void> precargar() async {
    try {
      final manifiesto = await AssetManifest.loadFromAssetBundle(rootBundle);
      _disponibles = manifiesto.listAssets().toSet();
    } catch (_) {
      // Sin manifiesto se usan los logos dibujados. No es motivo para no abrir.
      _disponibles = const {};
    }
  }

  static bool hay(String ruta) => _disponibles.contains(ruta);
}

/// Logotipo de Laburito.
///
/// Con [conNombre] en true usa el logo completo; en false, solo el isotipo —
/// que es lo que muestra el login del ANEXO UI, donde el nombre ya está en el
/// título de la pantalla.
///
/// Si el PNG todavía no está en `assets/logo/`, cae en una versión dibujada, de
/// modo que la app siga compilando y corriendo. Al dejar el archivo definitivo
/// en su lugar, el logo aparece sin tocar código.
class LogoLaburito extends StatelessWidget {
  const LogoLaburito({super.key, this.alto = 88, this.conNombre = true});

  final double alto;
  final bool conNombre;

  @override
  Widget build(BuildContext context) {
    final ruta = conNombre ? kLogoLaburito : kIsotipoLaburito;

    if (!AssetsDeMarca.hay(ruta)) {
      return _LogoDeReserva(alto: alto, conNombre: conNombre);
    }

    return Image.asset(
      ruta,
      height: alto,
      fit: BoxFit.contain,
      errorBuilder: (context, _, __) =>
          _LogoDeReserva(alto: alto, conNombre: conNombre),
    );
  }
}

class _LogoDeReserva extends StatelessWidget {
  const _LogoDeReserva({required this.alto, required this.conNombre});

  final double alto;
  final bool conNombre;

  @override
  Widget build(BuildContext context) {
    final lado = conNombre ? alto * 0.62 : alto;

    final tarjeta = Container(
      width: lado,
      height: lado,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D74A8), Colores.azul],
        ),
        borderRadius: BorderRadius.circular(lado * 0.28),
      ),
      child: Icon(Icons.place, size: lado * 0.52, color: Colores.naranja),
    );

    if (!conNombre) return tarjeta;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tarjeta,
        SizedBox(height: alto * 0.09),
        Text(
          'Laburito',
          style: TextStyle(
            fontSize: alto * 0.26,
            fontWeight: FontWeight.w800,
            color: Colores.azul,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// Encabezado de marca de las pantallas de autenticación: logo, título de la
/// pantalla y una bajada opcional.
class MarcaLaburito extends StatelessWidget {
  const MarcaLaburito({
    super.key,
    this.titulo,
    this.subtitulo,
    this.altoLogo = 88,
    this.conNombre = true,
  });

  /// Título de la pantalla, en el azul de la marca.
  final String? titulo;

  /// Bajada de una línea que explica qué hay que hacer.
  final String? subtitulo;

  final double altoLogo;

  /// Ver [LogoLaburito.conNombre].
  final bool conNombre;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LogoLaburito(alto: altoLogo, conNombre: conNombre),
        if (titulo != null) ...[
          const SizedBox(height: 16),
          Text(
            titulo!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colores.azul,
              letterSpacing: -0.3,
            ),
          ),
        ],
        if (subtitulo != null) ...[
          SizedBox(height: titulo == null ? 16 : 6),
          Text(
            subtitulo!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colores.textoSecundario,
              fontSize: 14,
              height: 1.4,
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
          constraints:
              const BoxConstraints(maxWidth: Medidas.anchoFormulario),
          child: child,
        ),
      ),
    );
  }
}

/// Tarjeta blanca de borde fino: el contenedor de contenido del ANEXO UI.
class TarjetaPanel extends StatelessWidget {
  const TarjetaPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colores.superficie,
        borderRadius: BorderRadius.circular(Medidas.radioGrande),
        border: Border.all(color: Colores.borde),
      ),
      child: child,
    );
  }
}

/// Aviso de color: informa un estado (pendiente, en revisión, error) sin
/// competir con el botón de acción principal.
class AvisoEstado extends StatelessWidget {
  const AvisoEstado({
    super.key,
    required this.color,
    required this.fondo,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.accion,
    this.onAccion,
  });

  /// Aviso naranja: hay algo pendiente que el usuario tiene que hacer.
  const AvisoEstado.pendiente({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.accion,
    this.onAccion,
  })  : color = Colores.naranja,
        fondo = Colores.naranjaSuave;

  /// Aviso verde: algo salió bien o está en curso del lado de Laburito.
  const AvisoEstado.exito({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.accion,
    this.onAccion,
  })  : color = Colores.exito,
        fondo = Colores.exitoSuave;

  /// Aviso rojo: consecuencias que conviene leer antes de seguir.
  const AvisoEstado.riesgo({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.accion,
    this.onAccion,
  })  : color = Colores.error,
        fondo = Colores.errorSuave;

  final Color color;
  final Color fondo;
  final IconData icono;
  final String titulo;
  final String? detalle;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(Medidas.radio),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colores.texto,
                  ),
                ),
              ),
            ],
          ),
          if (detalle != null) ...[
            const SizedBox(height: 8),
            Text(
              detalle!,
              style: const TextStyle(
                fontSize: 13,
                color: Colores.textoSecundario,
                height: 1.4,
              ),
            ),
          ],
          if (accion != null && onAccion != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAccion, child: Text(accion!)),
            ),
        ],
      ),
    );
  }
}

/// SnackBar unificado para errores y confirmaciones.
///
/// [duracion] existe para los mensajes que explican algo que el usuario tiene
/// que poder leer y entender —por qué no entró una foto, por ejemplo— y no
/// solo confirman lo que acaba de hacer. Los cuatro segundos por defecto de
/// Material alcanzan para «Guardado» y no para una frase.
void mostrarMensaje(
  BuildContext context,
  String texto, {
  bool esError = true,
  Duration duracion = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colores.error : Colores.exito,
        behavior: SnackBarBehavior.floating,
        duration: duracion,
      ),
    );
}
