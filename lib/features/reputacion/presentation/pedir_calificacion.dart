import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/mensajes_error.dart';
import '../../../core/utils/enlaces.dart';
import '../../../core/widgets/marca_laburito.dart';
import '../data/reputacion_repository.dart';
import '../domain/calificacion.dart';

/// CU-28 — El Profesional le pide la calificación al Buscador de un contacto.
///
/// Genera un enlace nuevo (el anterior sin usar deja de servir), lo copia al
/// portapapeles y abre el chat de WhatsApp con el mensaje escrito. Si el
/// teléfono no se puede marcar, queda el enlace copiado para pegarlo a mano.
/// Devuelve `true` si se generó el enlace.
Future<bool> pedirCalificacion(
  BuildContext context,
  WidgetRef ref,
  MiContacto contacto,
) async {
  final Uri enlace;
  try {
    enlace = await ref
        .read(reputacionRepositoryProvider)
        .enlaceCalificacion(contacto.pedidoId);
  } catch (error) {
    if (context.mounted) mostrarMensaje(context, MensajesError.desde(error));
    return false;
  }

  await Clipboard.setData(ClipboardData(
    text: mensajePedidoCalificacion(
      nombreCorto: contacto.nombreCorto,
      titulo: contacto.titulo,
      enlace: enlace,
    ),
  ));

  final chat = contacto.whatsAppConEnlace(enlace);
  final abierto = chat != null && await abrirEnlace(chat);

  if (context.mounted) {
    mostrarMensaje(
      context,
      abierto
          ? 'Enlace listo. Si cerrás WhatsApp, el mensaje quedó copiado.'
          : 'No pudimos abrir WhatsApp: el mensaje con el enlace quedó '
              'copiado para que lo pegues.',
      esError: !abierto,
    );
  }
  return true;
}
