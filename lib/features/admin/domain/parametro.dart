/// CU-47 — Un parámetro global (tabla `parametros_sistema`, 0034).
class Parametro {
  const Parametro({
    required this.clave,
    required this.nombre,
    required this.descripcion,
    required this.unidad,
    required this.valor,
    required this.minimo,
    required this.maximo,
    this.actualizadoAt,
  });

  final String clave;
  final String nombre;
  final String descripcion;
  final String unidad;
  final int valor;
  final int minimo;
  final int maximo;
  final DateTime? actualizadoAt;

  /// Flujo alterno 1.1, del lado de la pantalla: el mismo rango que valida
  /// la base, para no llegar a pedir la contraseña con un valor imposible.
  String? validar(String? texto) {
    final n = int.tryParse((texto ?? '').trim());
    if (n == null) return 'Ingresá un número entero.';
    if (n < minimo || n > maximo) {
      return 'Tiene que estar entre $minimo y $maximo $unidad.';
    }
    return null;
  }

  factory Parametro.desdeFila(Map<String, dynamic> f) => Parametro(
        clave: f['clave'] as String,
        nombre: f['nombre'] as String,
        descripcion: f['descripcion'] as String? ?? '',
        unidad: f['unidad'] as String? ?? '',
        valor: (f['valor'] as num).toInt(),
        minimo: (f['minimo'] as num).toInt(),
        maximo: (f['maximo'] as num).toInt(),
        actualizadoAt: f['updated_at'] == null
            ? null
            : DateTime.parse(f['updated_at'] as String),
      );
}
