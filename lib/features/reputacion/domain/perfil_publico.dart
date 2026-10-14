import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil_publico.freezed.dart';

/// CU-27 — Lo que el Buscador ve al abrir el enlace del Profesional
/// (Figura 3.6). Sale de la Edge Function `perfil_publico`, que firma las fotos
/// del portafolio y no devuelve correo, teléfono, DNI ni zona.
@freezed
abstract class PerfilPublico with _$PerfilPublico {
  const PerfilPublico._();

  const factory PerfilPublico({
    required String slug,
    required String nombre,
    required String apellido,
    String? avatarUrl,
    String? descripcion,
    double? calificacionPromedio,
    @Default(0) int totalCalificaciones,
    @Default(<String>[]) List<String> oficios,
    @Default(<FotoPublica>[]) List<FotoPublica> portafolio,
    @Default(<Resena>[]) List<Resena> resenas,
  }) = _PerfilPublico;

  String get nombreCompleto => '$nombre $apellido';

  String get inicial =>
      nombre.isEmpty ? '?' : nombre.characters.first.toUpperCase();

  factory PerfilPublico.desdeJson(Map<String, dynamic> json) => PerfilPublico(
        slug: json['slug'] as String,
        nombre: json['nombre'] as String? ?? '',
        apellido: json['apellido'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        descripcion: json['descripcion'] as String?,
        calificacionPromedio:
            (json['calificacion_promedio'] as num?)?.toDouble(),
        totalCalificaciones:
            (json['total_calificaciones'] as num?)?.toInt() ?? 0,
        oficios: [
          for (final o in json['oficios'] as List? ?? const []) o as String,
        ],
        portafolio: [
          for (final f in json['portafolio'] as List? ?? const [])
            FotoPublica(
              url: (f as Map)['url'] as String,
              descripcion: f['descripcion'] as String?,
            ),
        ],
        resenas: [
          for (final r in json['resenas'] as List? ?? const [])
            Resena.desdeJson(r as Map<String, dynamic>),
        ],
      );
}

@freezed
abstract class FotoPublica with _$FotoPublica {
  const factory FotoPublica({required String url, String? descripcion}) =
      _FotoPublica;
}

/// Una calificación del CU-28 tal como se muestra: el nombre corto del
/// Buscador («Laura G.»), las estrellas y el comentario.
@freezed
abstract class Resena with _$Resena {
  const Resena._();

  const factory Resena({
    required String autor,
    required int puntaje,
    String? comentario,
    required DateTime fecha,
  }) = _Resena;

  factory Resena.desdeJson(Map<String, dynamic> json) => Resena(
        autor: json['autor'] as String? ?? 'Buscador',
        puntaje: (json['puntaje'] as num).toInt(),
        comentario: json['comentario'] as String?,
        fecha: DateTime.parse(json['fecha'] as String),
      );
}
