import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/categorias/data/categorias_repository.dart';
import 'package:laburito/features/pedidos/domain/pedido_estado.dart';
import 'package:laburito/features/pedidos/domain/ubicacion.dart';
import 'package:laburito/features/pedidos/presentation/controllers/crear_pedido_controller.dart';
import 'package:laburito/features/pedidos/presentation/screens/crear_pedido_screen.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-13 — el asistente de alta, contra el árbol de widgets de verdad.
///
/// Es la deuda que dejó la Fase 5: el wizard se escribió y se revisó a mano,
/// pero nunca se lo había ejercitado. Estas pruebas cubren lo que se rompe sin
/// que nada falle al compilar: que se pueda avanzar con el formulario vacío,
/// que los errores no aparezcan al lado del campo que los causó, y que el
/// resumen del paso 4 muestre algo distinto de lo que se cargó.
///
/// Nada de esto toca Supabase: el pedido se envía recién al tocar «Publicar
/// pedido», y ninguna de estas pruebas llega hasta ahí.
void main() {
  const catalogo = [
    CategoriaOficio(id: 'c-1', nombre: 'Plomería', slug: 'plomeria'),
    CategoriaOficio(id: 'c-2', nombre: 'Electricidad', slug: 'electricidad'),
  ];

  const buscador = PerfilCompleto(
    id: 'b-1',
    tipo: 'buscador',
    nombre: 'Ana',
    apellido: 'García',
    email: 'ana@example.com',
    estado: 'activo',
  );

  const profesional = PerfilCompleto(
    id: 'p-1',
    tipo: 'profesional',
    nombre: 'Luis',
    apellido: 'Pérez',
    email: 'luis@example.com',
    estado: 'activo',
  );

  /// Monta la pantalla y devuelve el contenedor, para poder manejar el
  /// controlador desde el test cuando llegar a mano hasta un paso costaría
  /// media prueba (el paso «Dónde» abre el mapa a pantalla completa).
  Future<ProviderContainer> montar(
    WidgetTester t, {
    PerfilCompleto? perfil = buscador,
  }) async {
    final container = ProviderContainer(overrides: [
      perfilCompletoProvider.overrideWith((ref) async => perfil),
      categoriasActivasProvider.overrideWith((ref) async => catalogo),
    ]);
    addTearDown(container.dispose);

    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.claro, home: const CrearPedidoScreen()),
    ));
    await t.pumpAndSettle();

    return container;
  }

  CrearPedidoController controlador(ProviderContainer c) =>
      c.read(crearPedidoControllerProvider.notifier);

  group('quién puede publicar', () {
    testWidgets('una cuenta Profesional ve un aviso, no el formulario',
        (t) async {
      // El rol se valida adentro de la pantalla y no en el `redirect` del
      // router: `perfilCompletoProvider` es asíncrono y el redirect necesita
      // una respuesta sincrónica (decisión del 02/09).
      await montar(t, perfil: profesional);

      expect(find.text('Esta sección es para cuentas Buscador'), findsOneWidget);
      expect(find.text('¿Qué necesitás?'), findsNothing);
    });

    testWidgets('una cuenta Buscador arranca en el paso 1', (t) async {
      await montar(t);

      expect(find.text('¿Qué necesitás?'), findsOneWidget);
      expect(find.textContaining('Paso 1 de 4'), findsOneWidget);
    });
  });

  group('paso 1 · no se avanza con el formulario incompleto', () {
    testWidgets('con todo vacío, muestra un error por campo y no avanza',
        (t) async {
      await montar(t);

      await t.tap(find.text('Siguiente'));
      await t.pumpAndSettle();

      expect(find.text('Ingresá un título'), findsOneWidget);
      expect(find.text('Contá qué necesitás'), findsOneWidget);
      expect(find.textContaining('Paso 1 de 4'), findsOneWidget,
          reason: 'sigue en el mismo paso');
    });

    testWidgets('el título corto y la descripción corta avisan por qué',
        (t) async {
      await montar(t);

      await t.enterText(find.widgetWithText(TextFormField, 'Ej: Se me tapó la cocina'), 'Gas');
      await t.enterText(
        find.widgetWithText(
          TextFormField,
          'Contá el problema con el mayor detalle posible',
        ),
        'Se rompió',
      );

      await t.tap(find.text('Siguiente'));
      await t.pumpAndSettle();

      expect(find.textContaining('demasiado corto'), findsOneWidget);
      expect(find.textContaining('mínimo 20 caracteres'), findsOneWidget);
    });

    testWidgets('con los textos válidos pero sin categoría, avisa y no avanza',
        (t) async {
      await montar(t);

      await t.enterText(
        find.widgetWithText(TextFormField, 'Ej: Se me tapó la cocina'),
        'Se me tapó la cocina',
      );
      await t.enterText(
        find.widgetWithText(
          TextFormField,
          'Contá el problema con el mayor detalle posible',
        ),
        'La pileta no traga y el agua vuelve por la rejilla.',
      );

      await t.tap(find.text('Siguiente'));
      await t.pumpAndSettle();

      expect(find.text('Elegí una categoría.'), findsOneWidget);
      expect(find.textContaining('Paso 1 de 4'), findsOneWidget);
    });

    testWidgets('completo, avanza al paso 2', (t) async {
      await montar(t);

      await t.tap(find.byType(DropdownButtonFormField<String>));
      await t.pumpAndSettle();
      await t.tap(find.text('Plomería').last);
      await t.pumpAndSettle();

      await t.enterText(
        find.widgetWithText(TextFormField, 'Ej: Se me tapó la cocina'),
        'Se me tapó la cocina',
      );
      await t.enterText(
        find.widgetWithText(
          TextFormField,
          'Contá el problema con el mayor detalle posible',
        ),
        'La pileta no traga y el agua vuelve por la rejilla.',
      );

      await t.tap(find.text('Siguiente'));
      await t.pumpAndSettle();

      expect(find.text('¿Dónde es el trabajo?'), findsOneWidget);
      expect(find.textContaining('Paso 2 de 4'), findsOneWidget);
    });
  });

  group('paso 2 · la ubicación es obligatoria', () {
    testWidgets('sin marcar el punto, no se pasa a fotos', (t) async {
      final c = await montar(t);

      controlador(c)
        ..setCategoria('c-1')
        ..setTitulo('Se me tapó la cocina')
        ..setDescripcion('La pileta no traga y el agua vuelve por la rejilla.')
        ..avanzar();
      await t.pumpAndSettle();

      await t.tap(find.text('Siguiente'));
      await t.pumpAndSettle();

      expect(find.text('Marcá la ubicación del pedido.'), findsOneWidget);
      expect(find.textContaining('Paso 2 de 4'), findsOneWidget);
    });
  });

  group('paso 4 · el resumen refleja lo cargado', () {
    testWidgets('muestra título, urgencia, ubicación, fotos y vigencia',
        (t) async {
      final c = await montar(t);

      controlador(c)
        ..setCategoria('c-1')
        ..setTitulo('Se me tapó la cocina')
        ..setDescripcion('La pileta no traga y el agua vuelve por la rejilla.')
        ..setUrgencia(PedidoUrgencia.alta)
        ..setUbicacion(const Ubicacion(
          lat: -34.5136,
          lng: -58.7645,
          direccionTexto: 'Av. Siempreviva 742',
        ))
        ..setDiasVigencia(15)
        ..setPresupuesto(200000)
        // Los tres pasos, ya validados arriba de a uno.
        ..avanzar()
        ..avanzar()
        ..avanzar();
      await t.pumpAndSettle();

      expect(find.textContaining('Paso 4 de 4'), findsOneWidget);

      expect(find.text('Se me tapó la cocina'), findsOneWidget);
      expect(find.text('Es urgente'), findsOneWidget);
      expect(find.text('Av. Siempreviva 742'), findsOneWidget);
      expect(find.text('0 de 5'), findsOneWidget, reason: 'no cargó fotos');
      expect(find.text('15 días'), findsWidgets);
      expect(find.text(r'$200000'), findsOneWidget);

      // Y el botón cambia de «Siguiente» a la acción real. Se busca por el
      // botón y no por el texto porque la barra superior también dice
      // «Publicar pedido».
      expect(
        find.widgetWithText(FilledButton, 'Publicar pedido'),
        findsOneWidget,
      );
      expect(find.text('Siguiente'), findsNothing);
    });

    testWidgets('sin presupuesto, el resumen lo dice en palabras', (t) async {
      final c = await montar(t);

      controlador(c)
        ..setCategoria('c-1')
        ..setTitulo('Se me tapó la cocina')
        ..setDescripcion('La pileta no traga y el agua vuelve por la rejilla.')
        ..setUbicacion(const Ubicacion(
          lat: -34.5136,
          lng: -58.7645,
          direccionTexto: 'Av. Siempreviva 742',
        ))
        ..avanzar()
        ..avanzar()
        ..avanzar();
      await t.pumpAndSettle();

      expect(find.text('Sin definir'), findsOneWidget);
    });
  });

  group('volver atrás no pierde lo cargado', () {
    testWidgets('el paso 1 conserva el texto al regresar desde el paso 2',
        (t) async {
      // Cada paso se dibuja condicionalmente, así que al volver el widget se
      // reconstruye entero desde el estado del controlador. Es la razón por la
      // que los campos usan `initialValue` y no un `TextEditingController`
      // (decisión del 02/09): si el estado no fuera la fuente, esto perdería
      // el texto.
      final c = await montar(t);

      controlador(c)
        ..setCategoria('c-1')
        ..setTitulo('Se me tapó la cocina')
        ..setDescripcion('La pileta no traga y el agua vuelve por la rejilla.')
        ..avanzar();
      await t.pumpAndSettle();

      await t.tap(find.text('Atrás'));
      await t.pumpAndSettle();

      expect(find.text('Se me tapó la cocina'), findsOneWidget);
      expect(
        find.text('La pileta no traga y el agua vuelve por la rejilla.'),
        findsOneWidget,
      );
    });
  });
}
