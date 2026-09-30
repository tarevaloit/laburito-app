import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/pedidos/domain/pedido.dart';
import 'package:laburito/features/pedidos/domain/pedido_estado.dart';
import 'package:laburito/features/pedidos/domain/ubicacion.dart';
import 'package:laburito/features/pedidos/presentation/controllers/historial_pedidos_controller.dart';
import 'package:laburito/features/pedidos/presentation/widgets/chip_estado_pedido.dart';
import 'package:laburito/features/pedidos/presentation/widgets/fotos_pedido.dart';
import 'package:laburito/features/pedidos/presentation/widgets/tarjeta_pedido.dart';

/// CU-17 — Consultar Historial.
///
/// Se prueban las dos mitades que se rompen en silencio: los contadores de las
/// pestañas —que salen de un mapa por estado y no del largo de la página— y la
/// tarjeta, que es lo único que se ve de un pedido antes de entrar.
void main() {
  Pedido pedido({
    String id = 'p-1',
    String titulo = 'Pérdida en el termotanque',
    PedidoEstado estado = PedidoEstado.publicado,
    DateTime? vencimiento,
    DateTime? cierre,
  }) =>
      Pedido(
        id: id,
        buscadorId: 'b-1',
        categoriaId: 'c-1',
        categoriaNombre: 'Plomería',
        titulo: titulo,
        descripcion: 'Pierde agua por la base desde ayer.',
        urgencia: PedidoUrgencia.alta,
        estado: estado,
        ubicacion: const Ubicacion(
          lat: -34.5136,
          lng: -58.7645,
          direccionTexto: 'Av. Siempreviva 742',
        ),
        fechaPublicacion: DateTime.now().subtract(const Duration(days: 1)),
        fechaVencimiento:
            vencimiento ?? DateTime.now().add(const Duration(days: 3)),
        fechaCierre: cierre,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  group('contadores por grupo', () {
    const estado = EstadoHistorial(contadores: {
      PedidoEstado.publicado: 4,
      PedidoEstado.pausado: 2,
      PedidoEstado.vencido: 1,
      PedidoEstado.cerrado: 7,
      PedidoEstado.cancelado: 3,
    });

    test('«Activos» suma publicados y pausados', () {
      // Es el único grupo que agrupa más de un estado: si la suma se hiciera
      // mal, la pestaña diría 4 donde hay 6.
      expect(estado.contar(FiltroPedidos.activos), 6);
    });

    test('los otros tres grupos son directos', () {
      expect(estado.contar(FiltroPedidos.vencidos), 1);
      expect(estado.contar(FiltroPedidos.cerrados), 7);
      expect(estado.contar(FiltroPedidos.cancelados), 3);
    });

    test('los cuatro grupos suman el total, sin perder ni repetir pedidos', () {
      final suma = FiltroPedidos.values
          .fold(0, (total, grupo) => total + estado.contar(grupo));

      expect(suma, estado.total);
      expect(suma, 17);
    });

    test('un estado sin pedidos cuenta cero, no rompe', () {
      const vacio = EstadoHistorial();
      for (final grupo in FiltroPedidos.values) {
        expect(vacio.contar(grupo), 0);
      }
    });
  });

  group('vacío: hay dos, y no son el mismo', () {
    test('sin pedidos y sin buscar, es «todavía no publicaste»', () {
      const estado = EstadoHistorial();

      expect(estado.sinPedidosPropios, isTrue);
      expect(estado.filtrandoPorTexto, isFalse);
    });

    test('sin resultados pero buscando, no ofrece publicar', () {
      // Ofrecerle «Publicar un pedido» a alguien que acaba de buscar
      // «termotanque» no lo ayuda: lo que necesita es borrar la búsqueda.
      const estado = EstadoHistorial(busqueda: 'termotanque');

      expect(estado.filtrandoPorTexto, isTrue);
      expect(estado.sinPedidosPropios, isFalse);
    });

    test('una sola letra no cuenta como búsqueda', () {
      // Coincide con el umbral del repositorio: con un caracter, el `ilike`
      // recorre la tabla entera para devolver casi todo.
      expect(const EstadoHistorial(busqueda: 'a').filtrandoPorTexto, isFalse);
      expect(const EstadoHistorial(busqueda: 'ab').filtrandoPorTexto, isTrue);
    });
  });

  group('tarjeta del historial', () {
    Future<void> montar(WidgetTester t, Pedido p, {String? url}) async {
      await t.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: AppTheme.claro,
          home: Scaffold(
            body: TarjetaPedido(pedido: p, urlPortada: url, onTap: () {}),
          ),
        ),
      ));
      await t.pump();
    }

    testWidgets('muestra título, estado y categoría', (t) async {
      await montar(t, pedido());

      expect(find.text('Pérdida en el termotanque'), findsOneWidget);
      expect(find.text('Publicado'), findsOneWidget);
      expect(find.text('Plomería'), findsOneWidget);
    });

    testWidgets('sin foto usa el ícono del oficio, no un cuadro gris',
        (t) async {
      await montar(t, pedido());

      expect(find.byType(PlaceholderCategoria), findsOneWidget);
      expect(find.byIcon(Icons.plumbing), findsOneWidget);
    });

    testWidgets('un pedido en curso muestra cuánto le queda', (t) async {
      // Al mediodía de dentro de tres días calendario, y no «ahora + 3 días y
      // 2 horas»: corrida después de las 22:00, esa suma caía en el cuarto día
      // y la prueba fallaba según la hora.
      final hoy = DateTime.now();
      await montar(t, pedido(
        vencimiento: DateTime(hoy.year, hoy.month, hoy.day + 3, 12),
      ));

      expect(find.text('Vence en 3 días'), findsOneWidget);
    });

    testWidgets('un pedido vencido dice hace cuánto venció', (t) async {
      await montar(t, pedido(
        estado: PedidoEstado.vencido,
        vencimiento: DateTime.now().subtract(const Duration(days: 2)),
      ));

      expect(find.text('Venció hace 2 días'), findsOneWidget);
      expect(find.text('Vencido'), findsOneWidget);
    });

    testWidgets('un pedido cerrado muestra cuándo se cerró, no su vencimiento',
        (t) async {
      // Para algo terminado, los días que le quedaban de vigencia no le
      // importan a nadie.
      await montar(t, pedido(
        estado: PedidoEstado.cerrado,
        cierre: DateTime.now().subtract(const Duration(days: 1)),
      ));

      expect(find.text('Cerrado ayer'), findsOneWidget);
      expect(find.textContaining('Vence'), findsNothing);
    });

    testWidgets('el chip compacto entra sin desbordar en una fila angosta',
        (t) async {
      // La tarjeta vive en una lista: si el chip pidiera más ancho del que
      // hay, la fila reventaría con un overflow.
      await t.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => t.binding.setSurfaceSize(null));

      await montar(t, pedido(titulo: 'Un título bastante largo para la fila'));

      expect(t.takeException(), isNull);
      expect(find.byType(ChipEstadoPedido), findsOneWidget);
    });
  });
}
