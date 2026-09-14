import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/pedidos/presentation/controllers/acciones_pedido_controller.dart';
import 'package:laburito/features/pedidos/presentation/widgets/dialogos_pedido.dart';

/// Diálogos del ciclo de vida: cerrar (CU-29), cancelar (CU-14) y renovar
/// (CU-51).
///
/// Lo que se prueba acá es lo que separa un diálogo de confirmación de un
/// botón suelto: **que arrepentirse no haga nada**. Las tres acciones son
/// irreversibles —cerrado y cancelado son terminales, y una renovación gasta
/// una de las tres— así que un «Volver» que igual dispare la operación es el
/// peor error posible de esta pantalla.
void main() {
  /// Abre el diálogo con un botón, y deja el resultado en [capturado].
  ///
  /// El `Builder` no es decorativo: `showDialog` necesita un contexto que
  /// tenga el `Navigator` arriba, y el del `pumpWidget` todavía no lo tiene.
  Future<void> abrir(
    WidgetTester t,
    Future<void> Function(BuildContext) accion,
  ) async {
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.claro,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => accion(context),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));

    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
  }

  group('CU-29 · cerrar', () {
    testWidgets('sin motivo elegido, el botón de confirmar está deshabilitado',
        (t) async {
      MotivoCierre? resultado;
      var termino = false;

      await abrir(t, (context) async {
        resultado = await pedirMotivoDeCierre(context);
        termino = true;
      });

      final boton = t.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Cerrar pedido'),
      );
      expect(boton.onPressed, isNull,
          reason: 'ninguna opción viene preseleccionada, a propósito');

      // Y el diálogo sigue abierto: tocarlo no lo cierra ni devuelve nada.
      await t.tap(find.text('Cerrar pedido'));
      await t.pumpAndSettle();
      expect(termino, isFalse);
      expect(resultado, isNull);
    });

    testWidgets('elegir un motivo lo habilita y lo devuelve', (t) async {
      MotivoCierre? resultado;

      await abrir(t, (context) async {
        resultado = await pedirMotivoDeCierre(context);
      });

      await t.tap(find.text('Resolví por otro medio'));
      await t.pumpAndSettle();

      await t.tap(find.text('Cerrar pedido'));
      await t.pumpAndSettle();

      expect(resultado, MotivoCierre.porOtroMedio);
    });

    testWidgets('«Volver» no devuelve motivo aunque se haya elegido uno',
        (t) async {
      MotivoCierre? resultado;
      var termino = false;

      await abrir(t, (context) async {
        resultado = await pedirMotivoDeCierre(context);
        termino = true;
      });

      await t.tap(find.text('Resolví con un profesional de Laburito'));
      await t.pumpAndSettle();
      await t.tap(find.text('Volver'));
      await t.pumpAndSettle();

      expect(termino, isTrue, reason: 'el diálogo se cerró');
      expect(resultado, isNull, reason: 'pero no hay nada que ejecutar');
    });

    testWidgets('están las tres opciones del caso de uso, y solo esas',
        (t) async {
      await abrir(t, (context) => pedirMotivoDeCierre(context));

      for (final motivo in MotivoCierre.values) {
        expect(find.text(motivo.etiqueta), findsOneWidget);
      }
      expect(find.byType(RadioListTile<MotivoCierre>), findsNWidgets(3));
    });
  });

  group('CU-14 · cancelar', () {
    testWidgets('«No, volver» devuelve null: no se cancela nada', (t) async {
      CancelacionConfirmada? resultado;
      var termino = false;

      await abrir(t, (context) async {
        resultado = await confirmarCancelacion(context);
        termino = true;
      });

      await t.enterText(find.byType(TextField), 'me arrepentí');
      await t.tap(find.text('No, volver'));
      await t.pumpAndSettle();

      expect(termino, isTrue);
      expect(resultado, isNull,
          reason: 'ni siquiera con el motivo escrito se dispara la baja');
    });

    testWidgets('confirmar sin motivo devuelve una confirmación con motivo null',
        (t) async {
      CancelacionConfirmada? resultado;

      await abrir(t, (context) async {
        resultado = await confirmarCancelacion(context);
      });

      await t.tap(find.text('Sí, cancelar'));
      await t.pumpAndSettle();

      // La distinción que justifica que exista `CancelacionConfirmada`:
      // «confirmó sin escribir» no es lo mismo que «se arrepintió».
      expect(resultado, isNotNull);
      expect(resultado!.motivo, isNull);
    });

    testWidgets('el motivo escrito viaja recortado', (t) async {
      CancelacionConfirmada? resultado;

      await abrir(t, (context) async {
        resultado = await confirmarCancelacion(context);
      });

      await t.enterText(find.byType(TextField), '  lo resolvió un vecino  ');
      await t.tap(find.text('Sí, cancelar'));
      await t.pumpAndSettle();

      expect(resultado!.motivo, 'lo resolvió un vecino');
    });

    testWidgets('el copy diferencia cancelar de cerrar', (t) async {
      // Es la mitad del caso de uso: los dos terminan en un estado terminal y
      // desde afuera se parecen.
      await abrir(t, (context) => confirmarCancelacion(context));

      expect(
        find.textContaining('no se hizo el trabajo'),
        findsOneWidget,
      );
      expect(
        find.textContaining('cerralo en vez de cancelarlo'),
        findsOneWidget,
      );
    });
  });

  group('CU-51 · renovar', () {
    testWidgets('ofrece 7, 15 y 30 días, con 7 preseleccionado', (t) async {
      await abrir(
        t,
        (context) => pedirDiasDeRenovacion(context, restantes: 3),
      );

      expect(find.text('7 días'), findsOneWidget);
      expect(find.text('15 días'), findsOneWidget);
      expect(find.text('30 días'), findsOneWidget);

      final elegido = t.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '7 días'),
      );
      expect(elegido.selected, isTrue);
    });

    testWidgets('devuelve los días elegidos', (t) async {
      int? dias;

      await abrir(t, (context) async {
        dias = await pedirDiasDeRenovacion(context, restantes: 2);
      });

      await t.tap(find.text('30 días'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Renovar'));
      await t.pumpAndSettle();

      expect(dias, 30);
    });

    testWidgets('«Volver» no renueva', (t) async {
      int? dias;
      var termino = false;

      await abrir(t, (context) async {
        dias = await pedirDiasDeRenovacion(context, restantes: 2);
        termino = true;
      });

      await t.tap(find.text('Volver'));
      await t.pumpAndSettle();

      expect(termino, isTrue);
      expect(dias, isNull);
    });

    testWidgets('avisa cuando es la última renovación', (t) async {
      await abrir(
        t,
        (context) => pedirDiasDeRenovacion(context, restantes: 1),
      );
      expect(find.textContaining('Es la última renovación'), findsOneWidget);

      await t.tap(find.text('Volver'));
      await t.pumpAndSettle();

      await abrir(
        t,
        (context) => pedirDiasDeRenovacion(context, restantes: 3),
      );
      expect(find.textContaining('Te quedan 3 renovaciones'), findsOneWidget);
    });

    testWidgets('el aviso de límite ofrece publicar uno nuevo', (t) async {
      var publicarOtro = false;

      await abrir(t, (context) async {
        publicarOtro = await avisarLimiteDeRenovaciones(context);
      });

      expect(find.textContaining('Se renovó 3 veces'), findsOneWidget);

      await t.tap(find.text('Publicar uno nuevo'));
      await t.pumpAndSettle();
      expect(publicarOtro, isTrue);
    });

    testWidgets('el aviso de límite respeta el «Volver»', (t) async {
      var publicarOtro = true;

      await abrir(t, (context) async {
        publicarOtro = await avisarLimiteDeRenovaciones(context);
      });

      await t.tap(find.text('Volver'));
      await t.pumpAndSettle();
      expect(publicarOtro, isFalse);
    });
  });
}
