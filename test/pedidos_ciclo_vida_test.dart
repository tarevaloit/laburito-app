import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/colores.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/pedidos/domain/pedido.dart';
import 'package:laburito/features/pedidos/domain/pedido_estado.dart';
import 'package:laburito/features/pedidos/domain/ubicacion.dart';
import 'package:laburito/features/pedidos/presentation/controllers/editar_pedido_controller.dart';
import 'package:laburito/features/pedidos/presentation/screens/detalle_pedido_screen.dart';
import 'package:laburito/features/pedidos/presentation/widgets/chip_estado_pedido.dart';

/// La barra de acciones del detalle y el chip de estado (Fase 6).
///
/// **Qué cuida esto.** La máquina de estados vive en la base —la RPC
/// `cambiar_estado_pedido` de la migración 0006— y la UI es su espejo. Un
/// espejo que se corre no falla al compilar: ofrece un botón que el servidor
/// va a rechazar, y la persona se lleva un error en la cara por algo que
/// nunca tendría que haber podido tocar.
///
/// Acá se recorren los cinco estados y se verifica qué se ofrece en cada uno,
/// que es la misma tabla que `PedidoEstado.puedePasarA`.
void main() {
  Pedido pedido({
    PedidoEstado estado = PedidoEstado.publicado,
    int renovaciones = 0,
    DateTime? vencimiento,
  }) =>
      Pedido(
        id: 'p-1',
        buscadorId: 'b-1',
        categoriaId: 'c-1',
        categoriaNombre: 'Plomería',
        titulo: 'Pérdida en el termotanque',
        descripcion: 'Pierde agua por la base desde ayer.',
        urgencia: PedidoUrgencia.alta,
        estado: estado,
        ubicacion: const Ubicacion(
          lat: -34.5136,
          lng: -58.7645,
          direccionTexto: 'Av. Siempreviva 742',
        ),
        fechaPublicacion: DateTime.now().subtract(const Duration(days: 1)),
        // Por defecto, bien lejos de vencer: así el botón de renovar aparece
        // solo cuando el estado lo justifica y no por la fecha.
        fechaVencimiento:
            vencimiento ?? DateTime.now().add(const Duration(days: 20)),
        renovaciones: renovaciones,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  Future<void> mostrarBarra(WidgetTester t, Pedido p) async {
    await t.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.claro,
        home: Scaffold(body: BarraDeAccionesPedido(pedido: p)),
      ),
    ));
    await t.pump();
  }

  group('barra de acciones según el estado', () {
    testWidgets('publicado: editar, pausar, cerrar y cancelar', (t) async {
      await mostrarBarra(t, pedido());

      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Pausar'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      expect(find.text('Reanudar'), findsNothing);
      expect(find.text('Renovar'), findsNothing,
          reason: 'todavía le quedan 20 días de vigencia');
    });

    testWidgets('pausado: reanudar en vez de pausar', (t) async {
      await mostrarBarra(t, pedido(estado: PedidoEstado.pausado));

      expect(find.text('Reanudar'), findsOneWidget);
      expect(find.text('Pausar'), findsNothing);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('vencido: solo renovar', (t) async {
      // De `vencido` no hay transición válida: ni a publicado, ni a cerrado,
      // ni a cancelado. La única salida es `renovar_pedido` (CU-51).
      await mostrarBarra(t, pedido(
        estado: PedidoEstado.vencido,
        vencimiento: DateTime.now().subtract(const Duration(days: 2)),
      ));

      expect(find.text('Renovar'), findsOneWidget);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Pausar'), findsNothing);
      expect(find.text('Reanudar'), findsNothing);
      expect(find.text('Cerrar'), findsNothing);
      expect(find.text('Cancelar'), findsNothing);
    });

    testWidgets('cerrado y cancelado no ofrecen nada: son terminales',
        (t) async {
      for (final estado in [PedidoEstado.cerrado, PedidoEstado.cancelado]) {
        await mostrarBarra(t, pedido(estado: estado));

        expect(find.byType(OutlinedButton), findsNothing,
            reason: '$estado no admite ninguna acción');
      }
    });

    testWidgets(
        'un pedido caduco que sigue publicado también ofrece renovar',
        (t) async {
      // El barrido `marcar_pedidos_vencidos` todavía no corrió. Sin el botón,
      // el pedido queda en un callejón sin salida: reanudarlo lo rechaza la
      // RPC («renovalo en vez de reanudarlo») y renovarlo no se ofrece.
      await mostrarBarra(t, pedido(
        estado: PedidoEstado.pausado,
        vencimiento: DateTime.now().subtract(const Duration(hours: 3)),
      ));

      expect(find.text('Renovar'), findsOneWidget);
    });
  });

  group('CU-29 y CU-14 · arrepentirse no ejecuta nada', () {
    testWidgets('cerrar el diálogo de cierre no dispara la acción', (t) async {
      // Si la acción se disparara, el controlador saldría a buscar el
      // repositorio, que necesita un cliente de Supabase que en las pruebas no
      // existe: el test fallaría con una excepción en vez de en silencio.
      await mostrarBarra(t, pedido());

      await t.tap(find.text('Cerrar'));
      await t.pumpAndSettle();
      expect(find.text('¿Cerrar el pedido?'), findsOneWidget);

      await t.tap(find.text('Volver'));
      await t.pumpAndSettle();

      expect(find.text('¿Cerrar el pedido?'), findsNothing);
      expect(t.takeException(), isNull);
      expect(find.byType(SnackBar), findsNothing,
          reason: 'no hubo ni éxito ni error que avisar');
    });

    testWidgets('cerrar el diálogo de cancelación no da de baja el pedido',
        (t) async {
      await mostrarBarra(t, pedido());

      await t.tap(find.text('Cancelar'));
      await t.pumpAndSettle();
      expect(find.text('¿Cancelar el pedido?'), findsOneWidget);

      await t.tap(find.text('No, volver'));
      await t.pumpAndSettle();

      expect(find.text('¿Cancelar el pedido?'), findsNothing);
      expect(t.takeException(), isNull);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('con las 3 renovaciones gastadas se avisa, no se renueva',
        (t) async {
      await mostrarBarra(t, pedido(
        estado: PedidoEstado.vencido,
        renovaciones: 3,
        vencimiento: DateTime.now().subtract(const Duration(days: 1)),
      ));

      await t.tap(find.text('Renovar'));
      await t.pumpAndSettle();

      // Ni siquiera se ofrece elegir días: el cliente ya sabe que no quedan.
      expect(find.text('Este pedido ya no se puede renovar'), findsOneWidget);
      expect(find.text('7 días'), findsNothing);

      await t.tap(find.text('Volver'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });

  group('CU-15 · el borrador de la edición', () {
    EstadoEditarPedido borradorDe(Pedido p) => EstadoEditarPedido(
          original: p,
          categoriaId: p.categoriaId,
          titulo: p.titulo,
          descripcion: p.descripcion,
          urgencia: p.urgencia,
          ubicacion: p.ubicacion,
          presupuestoEstimado: p.presupuestoEstimado,
          fotos: p.fotos,
        );

    test('recién abierto no tiene cambios: guardar no escribe nada', () {
      expect(borradorDe(pedido()).hayCambios, isFalse);
    });

    test('detecta el cambio en cada campo editable', () {
      final base = borradorDe(pedido());

      expect(base.copyWith(titulo: 'Otro título').hayCambios, isTrue);
      expect(base.copyWith(descripcion: 'Otra descripción').hayCambios, isTrue);
      expect(base.copyWith(categoriaId: 'c-2').hayCambios, isTrue);
      expect(
        base.copyWith(urgencia: PedidoUrgencia.baja).hayCambios,
        isTrue,
      );
      expect(base.copyWith(presupuestoEstimado: 50000).hayCambios, isTrue);
    });

    test('los espacios de más no cuentan como cambio', () {
      // Si contaran, el botón «Guardar» se habilitaría solo por poner el
      // cursor en un campo, y cada apertura de la pantalla dejaría un evento
      // de edición en la auditoría.
      final base = borradorDe(pedido());
      expect(base.copyWith(titulo: '  ${base.titulo}  ').hayCambios, isFalse);
    });

    test('cambiar la ubicación se distingue del resto', () {
      // Importa porque la ubicación viaja por una RPC aparte: mandarla sin que
      // haya cambiado es una escritura de más, y son dos escrituras sin
      // transacción común.
      final base = borradorDe(pedido());
      expect(base.cambioLaUbicacion, isFalse);

      final movido = base.copyWith(
        ubicacion: const Ubicacion(
          lat: -34.6037,
          lng: -58.3816,
          direccionTexto: 'Otra dirección',
        ),
      );
      expect(movido.cambioLaUbicacion, isTrue);
      expect(movido.hayCambios, isTrue);
    });

    test('mientras se guarda o se sube una foto, la pantalla está ocupada', () {
      final base = borradorDe(pedido());

      expect(base.ocupado, isFalse);
      expect(base.copyWith(guardando: true).ocupado, isTrue);
      expect(base.copyWith(trabajandoConFotos: true).ocupado, isTrue);
    });
  });

  group('chip de estado', () {
    testWidgets('los cinco estados se dibujan con su etiqueta legible',
        (t) async {
      await t.pumpWidget(MaterialApp(
        theme: AppTheme.claro,
        home: Scaffold(
          body: Wrap(
            children: [
              for (final estado in PedidoEstado.values)
                ChipEstadoPedido(estado),
            ],
          ),
        ),
      ));

      expect(t.takeException(), isNull);
      for (final estado in PedidoEstado.values) {
        expect(find.text(estado.etiqueta), findsOneWidget);
        // Ningún identificador crudo de la base llega a la pantalla.
        expect(find.text(estado.clave), findsNothing);
      }
    });

    testWidgets('cada estado tiene su propio color', (t) async {
      final colores = {
        for (final estado in PedidoEstado.values)
          estado: ChipEstadoPedido.colorDe(estado),
      };

      expect(colores.values.toSet().length, PedidoEstado.values.length,
          reason: 'dos estados con el mismo color no se distinguen');

      // El criterio del ANEXO UI: verde lo que está sano, naranja lo que
      // espera una decisión, rojo lo que se dio de baja.
      expect(colores[PedidoEstado.publicado], Colores.exito);
      expect(colores[PedidoEstado.pausado], Colores.naranja);
      expect(colores[PedidoEstado.cancelado], Colores.error);
    });
  });
}
