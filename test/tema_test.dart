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
    expect(find.text('Pronto'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    await t.pumpWidget(conBarra(false));
    await t.pumpAndSettle();
    expect(find.text('Billetera'), findsNothing);
    expect(find.text('Perfil'), findsOneWidget);
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
