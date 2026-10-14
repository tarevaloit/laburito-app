import 'package:freezed_annotation/freezed_annotation.dart';

import '../../profesional/domain/contacto_buscador.dart' show numeroParaWhatsApp;

part 'calificacion.freezed.dart';

/// CU-28 — Un contacto que el Profesional desbloqueó (CU-25), con lo necesario
/// para pedirle la calificación al Buscador. Sale de `mis_contactos()`.
@freezed
abstract class MiContacto with _$MiContacto {
  const MiContacto._();

  const factory MiContacto({
    required String pedidoId,
    required String titulo,
    required String estadoPedido,
    required String nombreCorto,
    String? telefono,
    required DateTime desbloqueadoAt,
    @Default(false) bool calificado,
    int? puntaje,
  }) = _MiContacto;

  /// El chat de WhatsApp con el Buscador y el pedido de calificación escrito.
  /// `null` si el teléfono no se puede marcar: la pantalla copia el enlace.
  Uri? whatsAppConEnlace(Uri enlace) {
    final numero = telefono == null ? null : numeroParaWhatsApp(telefono!);
    if (numero == null) return null;
    return Uri.https('wa.me', '/$numero', {
      'text': mensajePedidoCalificacion(
        nombreCorto: nombreCorto,
        titulo: titulo,
        enlace: enlace,
      ),
    });
  }

  factory MiContacto.desdeFila(Map<String, dynamic> fila) => MiContacto(
        pedidoId: fila['pedido_id'] as String,
        titulo: fila['titulo'] as String? ?? 'Pedido',
        estadoPedido: fila['estado_pedido'] as String? ?? '',
        nombreCorto: fila['nombre_corto'] as String? ?? 'Buscador',
        telefono: fila['telefono'] as String?,
        desbloqueadoAt: DateTime.parse(fila['desbloqueado_at'] as String),
        calificado: fila['calificado'] as bool? ?? false,
        puntaje: (fila['puntaje'] as num?)?.toInt(),
      );
}

/// El texto que el Profesional manda por WhatsApp con el enlace (paso 1 del
/// CU-28: «el enlace de calificación enviado por el profesional al finalizar
/// el trabajo»).
String mensajePedidoCalificacion({
  required String nombreCorto,
  required String titulo,
  required Uri enlace,
}) =>
    'Hola ${nombreCorto.split(' ').first}, gracias por elegirme para «$titulo». '
    '¿Me calificás en Laburito? Te lleva un minuto y no necesitás cuenta: '
    '$enlace';

/// Estado del enlace de calificación al abrirlo (Figura 3.7).
enum EstadoEnlaceCalificacion { disponible, usado, invalido }

/// CU-28 — Lo que la Web muestra antes de calificar: a quién y si el enlace
/// sigue sirviendo. Sale de `enlace_calificacion_info()`.
@freezed
abstract class EnlaceCalificacion with _$EnlaceCalificacion {
  const EnlaceCalificacion._();

  const factory EnlaceCalificacion({
    required EstadoEnlaceCalificacion estado,
    String? nombre,
    String? apellido,
    String? avatarUrl,
  }) = _EnlaceCalificacion;

  String get inicial => (nombre ?? '').isEmpty
      ? '?'
      : nombre!.substring(0, 1).toUpperCase();

  factory EnlaceCalificacion.desdeJson(Map<String, dynamic> json) =>
      EnlaceCalificacion(
        estado: switch (json['estado']) {
          'disponible' => EstadoEnlaceCalificacion.disponible,
          'usado' => EstadoEnlaceCalificacion.usado,
          _ => EstadoEnlaceCalificacion.invalido,
        },
        nombre: json['nombre'] as String?,
        apellido: json['apellido'] as String?,
        avatarUrl: json['avatar_url'] as String?,
      );
}

/// Las leyendas de la Figura 3.7 debajo de las estrellas.
String leyendaPuntaje(int puntaje) => switch (puntaje) {
      1 => 'Malo',
      2 => 'Regular',
      3 => 'Bueno',
      4 => '¡Muy bueno!',
      5 => '¡Excelente!',
      _ => '',
    };
