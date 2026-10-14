import 'package:freezed_annotation/freezed_annotation.dart';

part 'notificacion.freezed.dart';

/// Los avisos que escriben los disparadores de la migración 0031.
enum TipoNotificacion {
  nuevoInteresado,
  calificacionRecibida,
  verificacionAprobada,
  verificacionRechazada,
  pagoAcreditado,
  denunciaRecibida,
  otro;

  static TipoNotificacion desde(String? valor) => switch (valor) {
        'nuevo_interesado' => nuevoInteresado,
        'calificacion_recibida' => calificacionRecibida,
        'verificacion_aprobada' => verificacionAprobada,
        'verificacion_rechazada' => verificacionRechazada,
        'pago_acreditado' => pagoAcreditado,
        'denuncia_recibida' => denunciaRecibida,
        _ => otro,
      };
}

/// CU-48 — Un aviso del centro de notificaciones.
@freezed
abstract class Notificacion with _$Notificacion {
  const Notificacion._();

  const factory Notificacion({
    required String id,
    required TipoNotificacion tipo,
    required String titulo,
    String? cuerpo,
    String? ruta,
    DateTime? leidaAt,
    required DateTime creadaAt,
  }) = _Notificacion;

  bool get leida => leidaAt != null;

  factory Notificacion.desdeFila(Map<String, dynamic> fila) => Notificacion(
        id: fila['id'] as String,
        tipo: TipoNotificacion.desde(fila['tipo'] as String?),
        titulo: fila['titulo'] as String? ?? '',
        cuerpo: fila['cuerpo'] as String?,
        ruta: fila['ruta'] as String?,
        leidaAt: fila['leida_at'] == null
            ? null
            : DateTime.parse(fila['leida_at'] as String),
        creadaAt: DateTime.parse(fila['created_at'] as String),
      );
}
