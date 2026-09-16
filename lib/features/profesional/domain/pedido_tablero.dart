import 'package:freezed_annotation/freezed_annotation.dart';

import '../../pedidos/domain/pedido_estado.dart';
import '../../pedidos/domain/ubicacion.dart';

part 'pedido_tablero.freezed.dart';

/// CU-43 y CU-22 — Un pedido ajeno, como lo ve el Profesional.
///
/// No es [Pedido]: es menos, y a propósito. Sale de `pedidos_publicos`, así
/// que no trae `referencia_ubicacion` —piso y departamento— ni la coordenada
/// exacta, sino la redondeada a unos cien metros. El dato fino se entrega
/// recién cuando hay contacto, que es del Sprint 4.
@freezed
abstract class PedidoTablero with _$PedidoTablero {
  const PedidoTablero._();

  const factory PedidoTablero({
    required String id,
    required String titulo,
    required String descripcion,
    required PedidoUrgencia urgencia,
    required String categoriaId,
    required String categoriaNombre,
    required Ubicacion ubicacionAproximada,
    required DateTime fechaPublicacion,
    required DateTime fechaVencimiento,
    required int cantidadFotos,
    double? presupuestoEstimado,

    /// Metros hasta el centro de la zona de cobertura, redondeados a cien.
    /// `null` si el Profesional todavía no configuró su zona (CU-07).
    double? distanciaM,
    @Default(false) bool guardado,
    @Default(false) bool ignorado,

    /// Solo en el tablero: la primera foto, para la tarjeta.
    String? portada,

    /// Solo en el detalle: todas las rutas, para el carrusel.
    @Default(<String>[]) List<String> fotos,
  }) = _PedidoTablero;

  /// Cómo se dice la distancia en una tarjeta. Por debajo del kilómetro va en
  /// metros —«a 800 m» se entiende mejor que «a 0,8 km»— y por arriba en
  /// kilómetros con un decimal.
  String? get distanciaLegible {
    final metros = distanciaM;
    if (metros == null) return null;
    if (metros < 100) return 'En tu zona';
    if (metros < 1000) return 'A ${metros.round()} m';

    final km = metros / 1000;
    final texto = km >= 10
        ? km.round().toString()
        : km.toStringAsFixed(1).replaceAll('.', ',');
    return 'A $texto km';
  }

  factory PedidoTablero.desdeFila(Map<String, dynamic> fila) => PedidoTablero(
        id: fila['id'] as String,
        titulo: fila['titulo'] as String,
        descripcion: fila['descripcion'] as String,
        urgencia: PedidoUrgencia.desdeClave(fila['urgencia'] as String),
        categoriaId: fila['categoria_id'] as String,
        categoriaNombre: (fila['categoria_nombre'] as String?) ?? 'Oficio',
        ubicacionAproximada: Ubicacion(
          lat: (fila['lat'] as num).toDouble(),
          lng: (fila['lng'] as num).toDouble(),
          direccionTexto: (fila['direccion_texto'] as String?) ?? '',
        ),
        fechaPublicacion:
            DateTime.parse(fila['fecha_publicacion'] as String).toLocal(),
        fechaVencimiento:
            DateTime.parse(fila['fecha_vencimiento'] as String).toLocal(),
        cantidadFotos: (fila['cantidad_fotos'] as num?)?.toInt() ?? 0,
        presupuestoEstimado:
            (fila['presupuesto_estimado'] as num?)?.toDouble(),
        distanciaM: (fila['distancia_m'] as num?)?.toDouble(),
        guardado: (fila['guardado'] as bool?) ?? false,
        ignorado: (fila['ignorado'] as bool?) ?? false,
        portada: fila['portada'] as String?,
        fotos: ((fila['fotos'] as List?) ?? const [])
            .map((f) => f as String)
            .toList(),
      );
}
