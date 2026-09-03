/// Estados del pedido. Las claves son los valores del enum `pedido_estado`
/// de PostgreSQL (migración 0005): si acá se escribe otra cosa, el insert
/// falla con `22P02 invalid input value for enum`.
enum PedidoEstado {
  publicado('publicado', 'Publicado'),
  pausado('pausado', 'Pausado'),
  cerrado('cerrado', 'Cerrado'),
  cancelado('cancelado', 'Cancelado'),
  vencido('vencido', 'Vencido');

  const PedidoEstado(this.clave, this.etiqueta);

  /// Valor tal como viaja a la base.
  final String clave;

  /// Texto para la pantalla. Igual que con `PerfilCompleto.estadoLegible`, los
  /// identificadores crudos no se muestran nunca.
  final String etiqueta;

  static PedidoEstado desdeClave(String clave) {
    for (final estado in values) {
      if (estado.clave == clave) return estado;
    }
    throw ArgumentError.value(
      clave,
      'clave',
      'Estado de pedido desconocido. Si la base agregó un valor al enum '
          'pedido_estado, falta reflejarlo en PedidoEstado',
    );
  }

  /// Cerrado y cancelado no admiten vuelta atrás.
  bool get esTerminal => this == cerrado || this == cancelado;

  /// El pedido sigue su curso y se puede editar.
  bool get esEditable => this == publicado || this == pausado;

  /// Espejo en Dart de `public.transicion_pedido_valida` (migración 0006).
  ///
  /// Sirve para no ofrecer en la pantalla un botón que el servidor va a
  /// rechazar. **No es la validación**: la que manda es la de la base, porque
  /// es la única que no se puede saltear. `test/pedidos_modelos_test.dart`
  /// verifica que las dos tablas digan lo mismo.
  bool puedePasarA(PedidoEstado destino) => switch (this) {
        publicado => const {pausado, cerrado, cancelado, vencido}
            .contains(destino),
        pausado => const {publicado, cerrado, cancelado, vencido}
            .contains(destino),
        // De vencido solo se sale renovando (CU-51), nunca con un cambio de
        // estado suelto: volver a publicar sin correr la fecha dejaría el
        // pedido publicado pero invisible.
        vencido => false,
        cerrado || cancelado => false,
      };
}

/// Filtro del historial de «Mis pedidos».
///
/// Es un enum y no un `Set<PedidoEstado>` suelto a propósito: se usa como
/// argumento de una family de Riverpod, y las familias comparan con `==`. Dos
/// `Set` con el mismo contenido no son iguales entre sí, así que un filtro
/// armado a mano crearía un provider nuevo en cada `build` y la lista se
/// recargaría sin parar.
enum FiltroPedidos {
  todos('Todos', <PedidoEstado>{}),
  activos('Activos', {PedidoEstado.publicado, PedidoEstado.pausado}),
  historial('Historial', {
    PedidoEstado.cerrado,
    PedidoEstado.cancelado,
    PedidoEstado.vencido,
  });

  const FiltroPedidos(this.etiqueta, this.estados);

  final String etiqueta;

  /// Estados que incluye. Vacío significa «sin filtrar».
  final Set<PedidoEstado> estados;

  List<String> get claves => [for (final e in estados) e.clave];
}

/// Urgencia declarada por el Buscador. Espeja el enum `pedido_urgencia`.
enum PedidoUrgencia {
  baja('baja', 'Puede esperar'),
  media('media', 'Esta semana'),
  alta('alta', 'Es urgente');

  const PedidoUrgencia(this.clave, this.etiqueta);

  final String clave;
  final String etiqueta;

  static PedidoUrgencia desdeClave(String clave) {
    for (final urgencia in values) {
      if (urgencia.clave == clave) return urgencia;
    }
    throw ArgumentError.value(
      clave,
      'clave',
      'Urgencia de pedido desconocida. Si la base agregó un valor al enum '
          'pedido_urgencia, falta reflejarlo en PedidoUrgencia',
    );
  }
}
