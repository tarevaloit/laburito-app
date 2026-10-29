import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/features/home/presentation/home_screen.dart';
import 'package:laburito/features/notificaciones/data/notificaciones_repository.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';

/// CU-35 — el Profesional que espera la aprobación desliza hacia abajo en el
/// inicio y ve el resultado sin cerrar y abrir la app.
void main() {
  const enRevision = PerfilCompleto(
    id: 'p-1',
    tipo: 'profesional',
    nombre: 'Luis',
    apellido: 'Pérez',
    email: 'luis@example.com',
    estado: 'activo',
    dni: '12345678',
    estadoVerificacion: 'en_revision',
  );

  testWidgets('deslizar hacia abajo relee el perfil', (t) async {
    var lecturas = 0;
    await t.pumpWidget(ProviderScope(
      overrides: [
        perfilCompletoProvider.overrideWith((ref) async {
          lecturas++;
          return lecturas == 1
              ? enRevision
              : enRevision.copyWith(estadoVerificacion: 'aprobado');
        }),
        notificacionesSinLeerProvider.overrideWith((ref) => 0),
      ],
      child: MaterialApp(theme: AppTheme.claro, home: const HomeScreen()),
    ));
    await t.pumpAndSettle();

    expect(find.text('Documentación en revisión'), findsOneWidget);

    await t.fling(find.text('Hola, Luis'), const Offset(0, 400), 1000);
    await t.pumpAndSettle();

    expect(lecturas, 2);
    expect(find.text('Documentación en revisión'), findsNothing);
    expect(t.takeException(), isNull);
  });
}
