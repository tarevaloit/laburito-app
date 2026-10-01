/// CU-53 — Lo que contesta `canjear_cupon` (migración 0025).
///
/// La función no levanta excepciones para un código que no sirve: devuelve uno
/// de estos valores, para que el intento fallido quede registrado y cuente
/// para el bloqueo por fuerza bruta. El mensaje de cada uno vive acá.
enum ResultadoCanje {
  ok(''),
  inexistente('Ese código no existe. Revisá que esté bien escrito.'),
  vencido('La promoción ya no es válida: el código venció.'),
  agotado('La promoción ya no es válida: se agotaron los canjes.'),
  yaUsado('Ya canjeaste este código.'),
  bloqueado('Hiciste demasiados intentos. Probá de nuevo en unos minutos.');

  const ResultadoCanje(this.mensaje);

  final String mensaje;

  static ResultadoCanje desde(String valor) => switch (valor) {
        'ok' => ok,
        'inexistente' => inexistente,
        'vencido' => vencido,
        'agotado' => agotado,
        'ya_usado' => yaUsado,
        'bloqueado' => bloqueado,
        _ => inexistente,
      };
}

/// El resultado con lo acreditado, cuando salió bien.
class CanjeCupon {
  const CanjeCupon({required this.resultado, this.tokens, this.saldo});

  final ResultadoCanje resultado;
  final int? tokens;
  final int? saldo;

  bool get exitoso => resultado == ResultadoCanje.ok;

  factory CanjeCupon.desdeFila(Map<String, dynamic> fila) => CanjeCupon(
        resultado: ResultadoCanje.desde(fila['resultado'] as String),
        tokens: (fila['tokens'] as num?)?.toInt(),
        saldo: (fila['saldo'] as num?)?.toInt(),
      );
}
