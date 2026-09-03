import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/mensajes_error.dart';

/// Qué salió mal, en términos del dominio y no de la base.
///
/// Sirve para que la pantalla decida **qué hacer** —ofrecer publicar un pedido
/// nuevo, refrescar la lista, mandar al login— sin leer el texto del mensaje.
enum CasoPedido {
  /// El cambio de estado pedido no existe en la máquina de estados.
  transicionInvalida,

  /// El pedido agotó sus 3 renovaciones (CU-51).
  limiteRenovaciones,

  /// Se intentó escribir `estado` con un UPDATE común, salteando la máquina de
  /// estados. Lo frena el trigger `pedidos_guard_estado` de la migración 0008.
  ///
  /// **Es un error nuestro, no del usuario.** Si aparece, hay una pantalla
  /// mandando `estado` en el payload de una edición en vez de llamar a
  /// `cambiarEstado`. La pantalla no tiene nada que ofrecerle a quien lo ve más
  /// que reintentar por el camino correcto.
  estadoNoModificable,

  /// No es suyo, no existe, o no hay sesión. Las RLS no distinguen entre «no
  /// existe» y «no te lo puedo mostrar», y está bien que no lo hagan: decirlo
  /// permitiría averiguar qué ids existen.
  sinPermiso,

  /// Cualquier otra cosa.
  desconocido,
}

/// Error de la capa de pedidos.
///
/// Implementa [ErrorDeNegocio], así que `MensajesError.desde` muestra su
/// `message` tal cual, sin traducirlo.
class PedidoException implements ErrorDeNegocio {
  const PedidoException(this.caso, this.message, {this.causa});

  final CasoPedido caso;

  @override
  final String message;

  /// El error original, para el log. No se le muestra al usuario.
  final Object? causa;

  /// Traduce un error de Supabase.
  ///
  /// El criterio es el **código** de PostgreSQL. Con una salvedad: todas las
  /// `raise exception` de plpgsql llegan como `P0001`, así que el código solo
  /// no alcanza para separar «no se puede pasar de cerrado a publicado» de
  /// «ya renovaste 3 veces». Por eso las funciones de la migración 0006
  /// mandan además un `hint` con una clave estable —`transicion_invalida`,
  /// `limite_renovaciones`, `sin_permiso`—, que es lo que se lee acá.
  ///
  /// Se leen la clave y el código, nunca el texto del mensaje: el texto está
  /// escrito para el usuario y va a cambiar.
  factory PedidoException.desde(Object error) {
    if (error is PedidoException) return error;

    if (error is PostgrestException) {
      final caso = _casoDe(error);
      return PedidoException(caso, _mensaje(error, caso), causa: error);
    }

    if (error is StorageException) {
      return PedidoException(
        CasoPedido.desconocido,
        'No pudimos subir la imagen. Revisá la conexión e intentá de nuevo.',
        causa: error,
      );
    }

    return PedidoException(
      CasoPedido.desconocido,
      'No pudimos completar la operación. Intentá nuevamente.',
      causa: error,
    );
  }

  static CasoPedido _casoDe(PostgrestException error) => switch (error.code) {
        // `raise exception` de nuestras RPC: el hint dice cuál.
        'P0001' => switch (error.hint) {
            'transicion_invalida' => CasoPedido.transicionInvalida,
            'limite_renovaciones' => CasoPedido.limiteRenovaciones,
            'estado_no_modificable' => CasoPedido.estadoNoModificable,
            'sin_permiso' => CasoPedido.sinPermiso,

            // Única excepción a «el texto del mensaje no se lee»: el guard de
            // la 0008 levanta el centinela como mensaje, no como frase para el
            // usuario. Se mira acá por si el `hint` se pierde en el camino.
            _ => error.message.contains(_centinelaGuard)
                ? CasoPedido.estadoNoModificable
                : CasoPedido.desconocido,
          },

        // RLS: ninguna política habilita la operación. Es lo que devuelve el
        // INSERT de alguien que no es Buscador, o cuya cuenta está de baja.
        '42501' => CasoPedido.sinPermiso,

        // `.single()` sobre cero filas. Con RLS activo suele significar que la
        // fila existe pero no es visible.
        'PGRST116' => CasoPedido.sinPermiso,

        _ => CasoPedido.desconocido,
      };

  /// Qué texto ve el usuario.
  ///
  /// Solo los `P0001` traen mensaje propio: son los `raise exception` de las
  /// migraciones 0005 y 0006, escritos en castellano y pensados para la
  /// pantalla. Todo lo demás lo redacta PostgreSQL para un administrador —«new
  /// row violates row-level security policy for table "pedidos"»— y no se
  /// muestra nunca: queda en `causa` para el log.
  static String _mensaje(PostgrestException error, CasoPedido caso) {
    // Antes que la regla general: el mensaje del guard es el centinela
    // `ESTADO_NO_MODIFICABLE_DIRECTAMENTE`, que no se le muestra a nadie.
    if (caso == CasoPedido.estadoNoModificable) {
      return 'El estado del pedido no se cambia desde la edición. Usá los '
          'botones de pausar, reanudar, cerrar, cancelar o renovar.';
    }

    if (error.code == 'P0001') return error.message;

    if (caso == CasoPedido.sinPermiso) {
      return 'No encontramos ese pedido, o no es tuyo.';
    }

    return _mensajeGenerico(error);
  }

  static String _mensajeGenerico(PostgrestException error) =>
      switch (error.code) {
        // unique_violation: hoy solo puede ser (pedido_id, orden) de las fotos.
        '23505' => 'Esa foto ya estaba cargada. Actualizá la pantalla.',

        // check_violation: título, descripción, presupuesto o fechas.
        '23514' => 'Alguno de los datos no cumple el formato pedido. '
            'Revisá el título, la descripción y las fechas.',

        // foreign_key_violation.
        '23503' => 'La categoría elegida ya no existe. Elegí otra.',

        // La función no está en el esquema: falta correr una migración.
        'PGRST202' => 'Esta operación todavía no está disponible en el '
            'servidor. Avisale al equipo: falta aplicar una migración.',

        _ => 'No pudimos completar la operación. Intentá nuevamente.',
      };

  /// El `raise exception` del trigger `pedidos_guard_estado` (migración 0008).
  /// Es un identificador, no una frase: nunca se le muestra al usuario.
  static const String _centinelaGuard = 'ESTADO_NO_MODIFICABLE_DIRECTAMENTE';

  @override
  String toString() => 'PedidoException($caso): $message';
}
