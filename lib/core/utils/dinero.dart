/// Pesos argentinos, escritos a mano por el mismo motivo que [Fechas]: sin
/// datos de locale de `intl` que puedan faltar recién al dibujar.
class Dinero {
  const Dinero._();

  /// «$ 4.500», «$ 14.000», «$ 1.250.000». Enteros: los precios de los
  /// paquetes son en pesos redondos (CU-40 exige un entero positivo).
  static String pesos(int monto) {
    final signo = monto < 0 ? '-' : '';
    final digitos = monto.abs().toString();
    final grupos = <String>[];

    for (var fin = digitos.length; fin > 0; fin -= 3) {
      final inicio = fin - 3 < 0 ? 0 : fin - 3;
      grupos.insert(0, digitos.substring(inicio, fin));
    }

    return '$signo\$ ${grupos.join('.')}';
  }
}
