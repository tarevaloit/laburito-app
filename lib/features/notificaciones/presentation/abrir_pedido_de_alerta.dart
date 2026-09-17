import 'package:go_router/go_router.dart';

/// Abre el pedido de una alerta del CU-21: al tocar la notificación, o el
/// «Ver» del aviso que aparece con la app abierta.
///
/// Vive aparte de `LaburitoApp` para poder probarlo contra un `GoRouter` de
/// verdad (`test/abrir_pedido_de_alerta_test.dart`), que es donde se ve si al
/// volver queda algo debajo.
///
/// Dos cosas que la primera versión hacía mal, y por eso está escrito así:
///
///   * **La ruta es la del Profesional**, `/profesional/pedidos/:id` (CU-22),
///     no `/pedidos/:id`. Las alertas solo les llegan a Profesionales, y
///     `/pedidos/:id` es el detalle del **dueño**: se construye sobre la fila de
///     `pedidos`, con la dirección exacta y la referencia, y su botón de volver
///     manda a «Mis pedidos» del Buscador. Se veía bien porque la RLS deja
///     leer esa fila (deuda de la sección 6 del ESTADO), que es justamente lo
///     que no tiene que pasar.
///   * **Se apila sobre el tablero**, en vez de un `go` directo al detalle. Un
///     `go` reemplaza la pila entera: al volver no había nada que desapilar y
///     la pantalla caía en su ruta de reserva. Con el tablero debajo, volver
///     lleva a los pedidos cercanos, que es de donde tendría sentido haber
///     llegado a este.
void abrirPedidoDeAlerta(GoRouter router, String pedidoId) {
  router.go('/profesional/tablero');
  router.push('/profesional/pedidos/$pedidoId');
}
