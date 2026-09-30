import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacto_buscador.freezed.dart';

/// CU-25 — Lo que el Profesional ve del Buscador en el detalle de un pedido
/// (Figura 3.12): el nombre corto y el teléfono enmascarado antes de pagar; el
/// teléfono entero después.
///
/// Sale de `contacto_pedido()` (migración 0023). El teléfono entero no viaja
/// si no se desbloqueó: no está escondido en la pantalla, no está en el
/// teléfono del Profesional.
@freezed
abstract class ContactoBuscador with _$ContactoBuscador {
  const ContactoBuscador._();

  const factory ContactoBuscador({
    required String nombreCorto,
    String? telefonoEnmascarado,
    String? telefono,
    @Default(false) bool desbloqueado,
  }) = _ContactoBuscador;

  /// El chat de WhatsApp con un primer mensaje que dice de qué pedido se
  /// trata (paso 5 del CU-25: «presiona el enlace generado para abrir el
  /// chat»). `null` si no hay un número que se pueda marcar.
  Uri? enlaceWhatsApp({required String tituloPedido}) {
    final numero = telefono == null ? null : numeroParaWhatsApp(telefono!);
    if (numero == null) return null;

    final mensaje = 'Hola ${nombreCorto.split(' ').first}, te escribo por tu '
        'pedido «$tituloPedido» en Laburito.';

    return Uri.https('wa.me', '/$numero', {'text': mensaje});
  }

  factory ContactoBuscador.desdeFila(Map<String, dynamic> fila) =>
      ContactoBuscador(
        nombreCorto: fila['nombre_corto'] as String? ?? 'Buscador',
        telefonoEnmascarado: fila['telefono_enmascarado'] as String?,
        telefono: fila['telefono'] as String?,
        desbloqueado: (fila['desbloqueado'] as bool?) ?? false,
      );
}

/// Un teléfono argentino escrito como lo escribe la gente, llevado al formato
/// internacional de celular que pide `wa.me`: `549` + característica + número,
/// sin el 0 ni el 15.
///
/// «11 15 2345-6789», «011 2345 6789», «+54 9 11 2345 6789» y «1123456789»
/// terminan todos en `5491123456789`. Devuelve `null` si no se puede armar un
/// número de diez dígitos nacionales: mejor no abrir WhatsApp que abrirlo con
/// un número de otra persona.
String? numeroParaWhatsApp(String telefono) {
  var digitos = telefono.replaceAll(RegExp(r'\D'), '');

  if (digitos.startsWith('549')) {
    digitos = digitos.substring(3);
  } else if (digitos.startsWith('54')) {
    digitos = digitos.substring(2);
  }

  if (digitos.startsWith('0')) digitos = digitos.substring(1);

  // El 15 va después de la característica, que tiene de 2 a 4 dígitos:
  // 11 15 xxxx-xxxx, 351 15 xxx-xxxx, 2966 15 xx-xxxx.
  if (digitos.length == 12) {
    for (final largoCaracteristica in [2, 3, 4]) {
      if (digitos.substring(largoCaracteristica, largoCaracteristica + 2) ==
          '15') {
        digitos = digitos.substring(0, largoCaracteristica) +
            digitos.substring(largoCaracteristica + 2);
        break;
      }
    }
  }

  if (digitos.length != 10) return null;
  return '549$digitos';
}

/// Lo que devuelve `desbloquear_contacto()`: el teléfono, el saldo que quedó y
/// si esta vez se cobró (no se cobra dos veces el mismo contacto).
class ContactoDesbloqueado {
  const ContactoDesbloqueado({
    required this.contacto,
    required this.saldo,
    required this.cobrado,
  });

  final ContactoBuscador contacto;
  final int saldo;
  final bool cobrado;

  factory ContactoDesbloqueado.desdeFila(Map<String, dynamic> fila) =>
      ContactoDesbloqueado(
        contacto: ContactoBuscador(
          nombreCorto: fila['nombre_corto'] as String? ?? 'Buscador',
          telefono: fila['telefono'] as String?,
          desbloqueado: true,
        ),
        saldo: (fila['saldo'] as num).toInt(),
        cobrado: fila['cobrado'] as bool,
      );
}
