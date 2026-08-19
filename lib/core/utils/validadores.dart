/// Validadores de formulario reutilizables (CU-01, CU-02, CU-03, CU-04).
class Validadores {
  const Validadores._();

  static final RegExp _email = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
  static final RegExp _soloDigitos = RegExp(r'^\d+$');

  static String? email(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá tu correo electrónico';
    if (!_email.hasMatch(v)) return 'El correo no tiene un formato válido';
    return null;
  }

  static String? password(String? valor) {
    final v = valor ?? '';
    if (v.isEmpty) return 'Ingresá una contraseña';
    if (v.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Debe incluir una mayúscula';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Debe incluir un número';
    return null;
  }

  static String? passwordRequerida(String? valor) {
    if ((valor ?? '').isEmpty) return 'Ingresá tu contraseña';
    return null;
  }

  static String? repetirPassword(String? valor, String original) {
    if ((valor ?? '').isEmpty) return 'Repetí la contraseña';
    if (valor != original) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? nombre(String? valor, {String campo = 'nombre'}) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá tu $campo';
    if (v.length < 2) return 'El $campo es demasiado corto';
    if (v.length > 60) return 'El $campo es demasiado largo';
    return null;
  }

  /// Teléfono argentino sin 0 ni 15: código de área + número (10 dígitos).
  static String? telefono(String? valor) {
    final v = (valor ?? '').replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (v.isEmpty) return 'Ingresá tu teléfono';
    if (!_soloDigitos.hasMatch(v)) return 'Solo se admiten números';
    if (v.length < 10 || v.length > 13) {
      return 'Ingresá el código de área y el número, sin 0 ni 15';
    }
    return null;
  }

  static String? pin(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'Ingresá el código que te enviamos';
    if (v.length != 6 || !_soloDigitos.hasMatch(v)) {
      return 'El código tiene 6 dígitos';
    }
    return null;
  }

  static String? dni(String? valor) {
    final v = (valor ?? '').replaceAll(RegExp(r'[\.\s]'), '');
    if (v.isEmpty) return 'Ingresá tu número de documento';
    if (!_soloDigitos.hasMatch(v)) return 'Solo se admiten números';
    if (v.length < 7 || v.length > 8) return 'El DNI tiene 7 u 8 dígitos';
    return null;
  }

  static String? descripcion(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.length > 500) return 'Máximo 500 caracteres';
    return null;
  }
}
