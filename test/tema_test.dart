import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/colores.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/core/widgets/barra_navegacion.dart';
import 'package:laburito/core/widgets/marca_laburito.dart';
import 'package:laburito/features/auth/presentation/widgets/selector_de_rol.dart';
import 'package:laburito/features/categorias/data/categorias_repository.dart';
import 'package:laburito/features/categorias/presentation/selector_oficios.dart';

/// Pruebas del lineamiento visual del ANEXO UI. Cubren lo que se puede romper
/// sin que nada falle al compilar: colores que no contrastan y estados del
/// chip de oficio.
void main() {
  Color colorDe(WidgetTester t, String texto) {
    final rich = t.widget<RichText>(
      find.descendant(of: find.text(texto), matching: find.byType(RichText)),
    );
    return rich.text.style!.color!;
  }

  const catalogo = [
    CategoriaOficio(id: '1', nombre: 'Plomería', slug: 'plomeria'),
    CategoriaOficio(id: '2', nombre: 'Gas', slug: 'gas'),
    CategoriaOficio(id: '3', nombre: 'Electricidad', slug: 'electricidad'),
  ];

  Widget conCatalogo(Widget hijo) => ProviderScope(
        overrides: [
          categoriasActivasProvider.overrideWith((ref) async => catalogo),
        ],
        child: MaterialApp(
          theme: AppTheme.claro,
          home: Scaffold(body: hijo),
        ),
      );

  testWidgets('el chip elegido pinta la etiqueta en blanco sobre el azul',
      (t) async {
    // El bug original: `secondaryLabelStyle` no lo usa FilterChip, así que la
    // etiqueta quedaba oscura sobre el fondo azul marino al seleccionar.
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.claro,
      home: Scaffold(
        body: Wrap(children: [
          FilterChip(
              label: const Text('Plomería'),
              selected: true,
              onSelected: (_) {}),
          FilterChip(
              label: const Text('Gas'), selected: false, onSelected: (_) {}),
        ]),
      ),
    ));

    expect(colorDe(t, 'Plomería'), Colores.textoSobreColor);
    expect(colorDe(t, 'Gas'), Colores.texto);
  });

  testWidgets('el selector de oficios respeta el tope y avisa', (t) async {
    var elegidas = <String>{'plomeria', 'gas'};
    var avisos = 0;

    await t.pumpWidget(conCatalogo(
      StatefulBuilder(
        builder: (context, setState) => SelectorOficios(
          elegidas: elegidas,
          maximo: 2,
          onCambio: (nuevas, {required alTope}) {
            if (alTope) {
              avisos++;
              return;
            }
            setState(() => elegidas = nuevas);
          },
        ),
      ),
    ));
    await t.pumpAndSettle();

    expect(find.text('2 de 2'), findsOneWidget);

    await t.tap(find.widgetWithText(FilterChip, 'Electricidad'));
    await t.pumpAndSettle();
    expect(avisos, 1, reason: 'al tope, avisa en vez de agregar');
    expect(elegidas, {'plomeria', 'gas'});

    await t.tap(find.widgetWithText(FilterChip, 'Gas'));
    await t.pumpAndSettle();
    expect(elegidas, {'plomeria'}, reason: 'deseleccionar siempre se permite');
  });

  testWidgets('el selector de rol entra en un formulario con scroll',
      (t) async {
    // Regresión: con `CrossAxisAlignment.stretch` y sin acotar la altura, el
    // Row pedía altura infinita adentro del scroll y la pantalla salía blanca.
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.claro,
      home: Scaffold(
        body: TarjetaFormulario(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectorDeRol(
                esBuscador: true,
                onElegirBuscador: () {},
                onElegirProfesional: () {},
              ),
            ],
          ),
        ),
      ),
    ));

    expect(t.takeException(), isNull);
    expect(find.text('Soy Buscador'), findsOneWidget);
    expect(find.text('Ofrezco mi oficio'), findsOneWidget);
  });

  testWidgets('la barra inferior oculta la billetera al Buscador', (t) async {
    Widget conBarra(bool esProfesional) => MaterialApp(
          theme: AppTheme.claro,
          home: Scaffold(
            bottomNavigationBar: BarraNavegacion(
              actual: SeccionApp.tablero,
              mostrarBilletera: esProfesional,
            ),
          ),
        );

    await t.pumpWidget(conBarra(true));
    expect(find.text('Tablero'), findsOneWidget);
    expect(find.text('Billetera'), findsOneWidget);
    // Desde el Sprint 4 la billetera existe: ya no lleva la insignia «Pronto».
    expect(find.text('Pronto'), findsNothing);
    expect(find.text('Perfil'), findsOneWidget);

    await t.pumpWidget(conBarra(false));
    await t.pumpAndSettle();
    expect(find.text('Billetera'), findsNothing);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('los botones del tema no exigen ancho infinito', (t) async {
    // Regresión de la Fase 6, encontrada corriendo el asistente del CU-13 en
    // la web: el tema pedía `minimumSize: Size.fromHeight(52)`, que deja el
    // ancho en `double.infinity`. En una `Column` con `stretch` no se nota
    // —el ancho llega fijo— pero en un `Row`, un `Wrap` o las acciones de un
    // `AlertDialog` llega sin acotar, y el layout explota con «BoxConstraints
    // forces an infinite width» llevándose la pantalla entera por delante.
    //
    // Los tres contenedores del caso, en una sola pasada:
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.claro,
      home: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('Atrás')),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Siguiente'),
                  ),
                ),
              ],
            ),
            Wrap(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.pause_outlined),
                  label: const Text('Pausar'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar'),
                ),
              ],
            ),
            OverflowBar(
              children: [
                TextButton(onPressed: () {}, child: const Text('Volver')),
                FilledButton(onPressed: () {}, child: const Text('Descartar')),
              ],
            ),
          ],
        ),
      ),
    ));

    expect(t.takeException(), isNull);
    expect(find.text('Atrás'), findsOneWidget);
    expect(find.text('Pausar'), findsOneWidget);
    expect(find.text('Descartar'), findsOneWidget);
  });

  testWidgets('el piso de altura del botón se conserva', (t) async {
    // La contracara del test de arriba: al sacar el ancho infinito no se puede
    // haber perdido la altura de 52 px que pide el ANEXO UI.
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.claro,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: FilledButton(onPressed: () {}, child: const Text('Ingresar')),
        ),
      ),
    ));

    expect(t.getSize(find.byType(FilledButton)).height, Medidas.altoBoton);
  });

  testWidgets('el botón de acción principal es naranja, no azul', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.claro,
      home: Scaffold(
        body: FilledButton(onPressed: () {}, child: const Text('Ingresar')),
      ),
    ));

    final material = t.widget<Material>(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, Colores.naranja);
  });
}
