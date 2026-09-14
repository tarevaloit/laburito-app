import 'package:freezed_annotation/freezed_annotation.dart';

import 'pedido_estado.dart';
import 'pedido_foto.dart';
import 'ubicacion.dart';

part 'pedido.freezed.dart';

/// Solicitud de trabajo publicada por un Buscador. Espeja `public.pedidos`
/// (migraciones 0005, 0006 y 0007). CU-13, CU-16, CU-51.
@freezed
abstract class Pedido with _$Pedido {
  const Pedido._();

  const factory Pedido({
    required String id,
    required String buscadorId,
    required String categoriaId,

    /// Viene del embed `categorias_oficio(nombre)`. Nulo si la consulta no lo
    /// pidió.
    String? categoriaNombre,
    required String titulo,
    required String descripcion,
    required PedidoUrgencia urgencia,
    required PedidoEstado estado,
    required Ubicacion ubicacion,
    double? presupuestoEstimado,
    required DateTime fechaPublicacion,
    required DateTime fechaVencimiento,
    DateTime? fechaCierre,
    String? motivoCierre,
    @Default(0) int renovaciones,
    @Default(<PedidoFoto>[]) List<PedidoFoto> fotos,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Pedido;

  /// Tope que impone `renovar_pedido` (migración 0006).
  static const int maximoRenovaciones = 3;

  /// Ventana previa al vencimiento dentro de la cual se admite renovar. Es el
  /// mismo valor que la constante `v_ventana` de `renovar_pedido`.
  static const Duration ventanaDeRenovacion = Duration(days: 3);

  /// Construye el pedido a partir de una fila de la **tabla** `pedidos`.
  ///
  /// Espera `lat` y `lng`, que son los computed fields de la migración 0007 y
  /// hay que pedirlos explícitamente en el `select`. La vista
  /// `pedidos_publicos` tiene otra forma —sin `buscador_id` ni `estado`— y no
  /// se mapea acá: es del CU-16, del lado del Profesional.
  factory Pedido.desdeFila(Map<String, dynamic> fila) {
    final categoria = fila['categorias_oficio'] as Map<String, dynamic>?;
    final fotos = (fila['pedido_fotos'] as List?) ?? const [];

    return Pedido(
      id: fila['id'] as String,
      buscadorId: fila['buscador_id'] as String,
      categoriaId: fila['categoria_id'] as String,
      categoriaNombre: categoria?['nombre'] as String?,
      titulo: fila['titulo'] as String,
      descripcion: fila['descripcion'] as String,
      urgencia: PedidoUrgencia.desdeClave(fila['urgencia'] as String),
      estado: PedidoEstado.desdeClave(fila['estado'] as String),
      ubicacion: Ubicacion(
        // PostgREST devuelve `numeric`/`double precision` a veces como int
        // (cuando el valor no tiene decimales) y a veces como double. `num`
        // cubre los dos casos; castear directo a double explota con -34.
        lat: (fila['lat'] as num).toDouble(),
        lng: (fila['lng'] as num).toDouble(),
        direccionTexto: fila['direccion_texto'] as String,
        referencia: fila['referencia_ubicacion'] as String?,
      ),
      presupuestoEstimado: (fila['presupuesto_estimado'] as num?)?.toDouble(),
      fechaPublicacion:
          DateTime.parse(fila['fecha_publicacion'] as String).toLocal(),
      fechaVencimiento:
          DateTime.parse(fila['fecha_vencimiento'] as String).toLocal(),
      fechaCierre: switch (fila['fecha_cierre']) {
        final String s => DateTime.parse(s).toLocal(),
        _ => null,
      },
      motivoCierre: fila['motivo_cierre'] as String?,
      renovaciones: (fila['renovaciones'] as num?)?.toInt() ?? 0,
      fotos: [
        for (final f in fotos) PedidoFoto.desdeFila(f as Map<String, dynamic>),
      ]..sort((a, b) => a.orden.compareTo(b.orden)),
      createdAt: DateTime.parse(fila['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(fila['updated_at'] as String).toLocal(),
    );
  }

  /// Las consultas del CU-16 filtran por fecha además de por estado, así que
  /// un pedido puede estar «publicado» y no listarse. `ahora` es parámetro
  /// para que esto se pueda probar sin depender del reloj.
  bool estaVigente([DateTime? ahora]) =>
      estado == PedidoEstado.publicado &&
      fechaVencimiento.isAfter(ahora ?? DateTime.now());

  /// Ya pasó su fecha, con independencia de que el barrido
  /// `marcar_pedidos_vencidos` haya corrido o no.
  bool estaCaduco([DateTime? ahora]) =>
      !fechaVencimiento.isAfter(ahora ?? DateTime.now());

  /// Espejo de las validaciones de `renovar_pedido` (migración 0006): ni
  /// terminal, ni sin renovaciones disponibles, y vencido o a punto de vencer.
  bool puedeRenovarse([DateTime? ahora]) {
    final momento = ahora ?? DateTime.now();
    if (estado.esTerminal) return false;
    if (renovaciones >= maximoRenovaciones) return false;
    if (estado == PedidoEstado.vencido) return true;
    return !fechaVencimiento.isAfter(momento.add(ventanaDeRenovacion));
  }

  bool get puedeAgregarFotos => fotos.length < PedidoFoto.maximoPorPedido;

  int get renovacionesRestantes => maximoRenovaciones - renovaciones;

  PedidoFoto? get portada => fotos.isEmpty ? null : fotos.first;

  /// Días que le quedan de vigencia. 0 si ya venció.
  int diasRestantes([DateTime? ahora]) {
    final restante = fechaVencimiento.difference(ahora ?? DateTime.now());
    return restante.isNegative ? 0 : restante.inDays;
  }
}
