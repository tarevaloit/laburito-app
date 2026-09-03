import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/pedidos/data/pedidos_repository.dart';
import 'package:laburito/features/pedidos/data/urls_firmadas.dart';
import 'package:laburito/features/pedidos/domain/pedido_foto.dart';
import 'package:laburito/features/pedidos/presentation/widgets/fotos_pedido.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// El carrusel de fotos del pedido.
///
/// Las fotos viven en un bucket privado, así que para mostrarlas hay que
/// pedirle al servidor una URL firmada. Ese pedido puede no volver —el archivo
/// no está, la política de Storage no lo deja, no hay red— y lo que se ve en
/// ese caso es la mitad del comportamiento de este widget.
void main() {
  PedidoFoto foto(String id, int orden) => PedidoFoto(
        id: id,
        pedidoId: 'p-1',
        storagePath: 'p-1/$id.jpg',
        orden: orden,
        createdAt: DateTime(2026, 9, 3),
      );

  /// Un repositorio de verdad, con un cliente que no sale a ningún lado. No se
  /// usa: el caché falso de abajo contesta antes de llegar a él.
  ///
  /// `autoRefreshToken: false` no es un detalle: el cliente arranca un ticker
  /// para renovar la sesión, y `testWidgets` falla si queda un `Timer` vivo
  /// después de desmontar el árbol.
  PedidosRepository repoInerte() => PedidosRepository(
        SupabaseClient(
          'https://proyecto.supabase.co',
          'clave-de-mentira',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );

  Future<void> montar(WidgetTester t, UrlsFirmadas firmas,
      {List<PedidoFoto> fotos = const []}) async {
    await t.pumpWidget(ProviderScope(
      overrides: [urlsFirmadasProvider.overrideWithValue(firmas)],
      child: MaterialApp(
        theme: AppTheme.claro,
        home: Scaffold(
          body: CarruselFotosPedido(
            fotos: fotos,
            categoriaNombre: 'Plomería',
          ),
        ),
      ),
    ));
  }

  testWidgets('sin fotos muestra el ícono de la categoría', (t) async {
    await montar(t, _FirmasQueFallan(repoInerte()));
    await t.pumpAndSettle();

    expect(find.byType(PlaceholderCategoria), findsOneWidget);
    expect(find.byIcon(Icons.plumbing), findsOneWidget,
        reason: 'el placeholder es de la categoría, no un cuadro gris');
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('si la firma no vuelve, deja de girar y ofrece reintentar',
      (t) async {
    // Regresión: «todavía no llegó la URL» y «la URL no se pudo obtener» eran
    // el mismo estado —el mapa sin la clave—, así que la foto quedaba girando
    // para siempre y no había forma de saber que algo había fallado.
    // La demora reproduce el viaje a la red: sin ella la respuesta llega
    // dentro del mismo cuadro y el estado «pidiendo» no existiría nunca.
    final firmas = _FirmasQueFallan(
      repoInerte(),
      demora: const Duration(milliseconds: 50),
    );
    await montar(t, firmas, fotos: [foto('f-1', 0)]);

    // Mientras el pedido está en vuelo, el indicador.
    await t.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await t.pump(const Duration(milliseconds: 100));
    await t.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing,
        reason: 'la firma ya volvió, aunque haya vuelto vacía');
    expect(find.text('No pudimos cargar esta foto'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    // Y reintentar vuelve a pedirlas.
    await t.tap(find.text('Reintentar'));
    await t.pumpAndSettle();
    expect(firmas.pedidos, 2);
  });

  testWidgets('las fotos se firman en una sola llamada, no una por foto',
      (t) async {
    // Es la razón de ser de `UrlsFirmadas`: una página del historial son 20
    // portadas, y firmarlas de a una son 20 viajes contra uno.
    final firmas = _FirmasQueFallan(repoInerte());
    await montar(t, firmas, fotos: [foto('f-1', 0), foto('f-2', 1), foto('f-3', 2)]);
    await t.pumpAndSettle();

    expect(firmas.pedidos, 1);
    expect(firmas.rutasPedidas, ['p-1/f-1.jpg', 'p-1/f-2.jpg', 'p-1/f-3.jpg']);
  });
}

/// Un caché que nunca consigue firmar nada, y que cuenta cuántas veces se lo
/// pidieron.
class _FirmasQueFallan extends UrlsFirmadas {
  _FirmasQueFallan(super.repo, {this.demora = Duration.zero});

  /// Cuánto tarda en contestar. Con `Duration.zero` la respuesta llega dentro
  /// del mismo cuadro, que sirve para las pruebas donde el estado intermedio
  /// no importa.
  final Duration demora;

  int pedidos = 0;
  List<String> rutasPedidas = const [];

  @override
  Future<Map<String, String>> resolver(List<String> rutas) async {
    pedidos++;
    rutasPedidas = rutas;
    if (demora > Duration.zero) await Future<void>.delayed(demora);
    return const {};
  }
}
