import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/router.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/core/config/contacto.dart';
import 'package:laburito/features/ayuda/data/ayuda_repository.dart';
import 'package:laburito/features/ayuda/presentation/ayuda_screen.dart';

/// CU-42 — Consultar Ayuda y Soporte.
void main() {
  const preguntas = [
    PreguntaFrecuente(
      categoria: 'Cuenta y seguridad',
      pregunta: 'Me olvidé la contraseña',
      respuesta: 'Tocá «¿Olvidaste tu contraseña?» en el inicio de sesión.',
    ),
    PreguntaFrecuente(
      categoria: 'Tokens y pagos',
      pregunta: '¿Cómo compro tokens?',
      respuesta: 'En la billetera, con Mercado Pago.',
    ),
  ];

  test('la búsqueda ignora tildes y mayúsculas', () {
    expect(preguntas.first.coincide('CONTRASENA'), isTrue);
    expect(preguntas.first.coincide('mercado pago'), isFalse);
    expect(preguntas.last.coincide('mercado pago'), isTrue);
    expect(preguntas.last.coincide(''), isTrue);
  });

  test('la ayuda se abre con o sin sesión', () {
    expect(esRutaNeutral('/ayuda'), isTrue);
  });

  Future<void> montar(WidgetTester t, AyudaRepository repo) async {
    await t.pumpWidget(ProviderScope(
      overrides: [ayudaRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.claro, home: const AyudaScreen()),
    ));
    await t.pumpAndSettle();
  }

  testWidgets('temas, buscador, respuesta y contacto', (t) async {
    await montar(t, const _AyudaFalsa(preguntas));

    expect(find.text('Cuenta y seguridad'), findsOneWidget);
    expect(find.text('Tokens y pagos'), findsOneWidget);

    await t.enterText(find.byKey(const Key('buscar-ayuda')), 'tokens');
    await t.pumpAndSettle();
    expect(find.text('Me olvidé la contraseña'), findsNothing);

    await t.tap(find.text('¿Cómo compro tokens?'));
    await t.pumpAndSettle();
    expect(find.text('En la billetera, con Mercado Pago.'), findsOneWidget);
    expect(find.text(Contacto.correoSoporte), findsOneWidget);
  });

  testWidgets('sin base de conocimientos, los datos de contacto (flujo 1.1)',
      (t) async {
    await montar(t, const _AyudaFalsa(null));

    expect(find.byKey(const Key('ayuda-sin-conexion')), findsOneWidget);
    expect(find.byKey(const Key('contacto-correo')), findsOneWidget);
    expect(find.byKey(const Key('contacto-whatsapp')), findsOneWidget);
  });
}

class _AyudaFalsa implements AyudaRepository {
  const _AyudaFalsa(this.lista);

  final List<PreguntaFrecuente>? lista;

  @override
  Future<List<PreguntaFrecuente>> preguntas() async =>
      lista ?? (throw Exception('sin conexión'));
}
