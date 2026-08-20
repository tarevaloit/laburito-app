import 'package:flutter/foundation.dart';

/// Las dos superficies del producto, según el ANEXO UI del ERS.
enum Superficie {
  /// Aplicación nativa. Es la del **Profesional**: tablero de pedidos,
  /// billetera, portafolio, zona de cobertura (Figuras 3.8 a 3.19).
  appProfesional,

  /// Plataforma web. Es la del **Buscador**: publicar un pedido, gestionarlo,
  /// calificar (Figuras 3.1 a 3.7). Un Profesional también puede darse de alta
  /// acá, pero su día a día es la app.
  webPublica,
}

/// Un solo lugar decide qué muestra cada superficie.
///
/// La regla se expresa por intención (`permiteAltaDeBuscador`) y no por
/// plataforma (`kIsWeb`) desperdigada por las pantallas: si mañana el Buscador
/// tiene app, se cambia acá y no en diez archivos.
///
/// **Por qué un solo proyecto y no dos.** La app y la web comparten el cliente
/// de Supabase, el repositorio de auth, el de perfil, el de categorías, los
/// validadores, los mensajes de error y todo el sistema visual. Lo que cambia
/// es qué pantallas se componen y con qué navegación. Separar en dos proyectos
/// obligaría a extraer un paquete común y mantener tres `pubspec` —cuatro con
/// el panel de Admin— para un equipo de una persona.
class Entorno {
  const Entorno._();

  static Superficie get superficie =>
      kIsWeb ? Superficie.webPublica : Superficie.appProfesional;

  static bool get esWeb => superficie == Superficie.webPublica;
  static bool get esAppProfesional =>
      superficie == Superficie.appProfesional;

  /// En la app nativa el alta es siempre de Profesional (Figura 3.9): no hay
  /// selector de rol. En la web se elige entre Buscador y Profesional dentro
  /// de la misma tarjeta (Figura 3.1).
  static bool get permiteAltaDeBuscador => esWeb;

  /// La barra inferior Tablero · Billetera · Perfil es de la app del
  /// Profesional. La web usa la barra superior de la marca.
  static bool get usaBarraInferior => esAppProfesional;
}
