import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/app/theme.dart';
import 'package:laburito/core/errors/mensajes_error.dart';
import 'package:laburito/features/perfil/data/perfil_repository.dart';
import 'package:laburito/features/verificacion/data/documentos_repository.dart';
import 'package:laburito/features/verificacion/presentation/screens/carga_documentos_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// CU-09 — quién puede cargar documentación.
///
/// Regresión de un `23503` que apareció corriendo la app: una cuenta Buscador
/// llegaba a `/verificacion`, veía el formulario entero y al subir el DNI
/// chocaba contra la clave foránea de `documentos_verificacion` hacia
/// `profesionales`, una tabla donde un Buscador no tiene —ni tiene que tener—
/// fila. El error que le llegaba era el crudo de Postgres.
void main() {
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
    estadoVerificacion: 'sin_documentacion',
  );

  Future<void> montar(WidgetTester t, PerfilCompleto perfil) async {
    await t.pumpWidget(ProviderScope(
      overrides: [
        perfilCompletoProvider.overrideWith((ref) async => perfil),
        // Sin documentos cargados. Se falsea el provider entero para no
        // necesitar un cliente de Supabase.
        documentosCargadosProvider.overrideWith((ref) async => const {}),
      ],
      child: MaterialApp(
        theme: AppTheme.claro,
        home: const CargaDocumentosScreen(),
      ),
    ));
    await t.pumpAndSettle();
  }

  testWidgets('una cuenta Buscador ve un aviso, no el formulario', (t) async {
    await montar(t, buscador);

    expect(find.text('Esta sección es para cuentas Profesional'), findsOneWidget);

    // Y sobre todo: no hay nada que tocar que termine en un error de la base.
    for (final tipo in TipoDocumento.values) {
      expect(find.text(tipo.etiqueta), findsNothing);
    }
  });

  testWidgets('una cuenta Profesional ve los tres documentos', (t) async {
    await montar(t, profesional);

    expect(find.text('Esta sección es para cuentas Profesional'), findsNothing);
    for (final tipo in TipoDocumento.values) {
      expect(find.text(tipo.etiqueta), findsOneWidget);
    }
  });

  test('un 23503 no se le muestra crudo a nadie', () {
    // Si el hueco de datos vuelve a aparecer por otro camino, el mensaje tiene
    // que ser accionable en vez del texto de Postgres.
    const error = PostgrestException(
      message: 'insert or update on table "documentos_verificacion" violates '
          'foreign key constraint "documentos_verificacion_profesional_id_fkey"',
      code: '23503',
      details: 'Key is not present in table "profesionales".',
    );

    final mensaje = MensajesError.desde(error);

    expect(mensaje, contains('Avisale al equipo'));
    expect(mensaje, isNot(contains('foreign key')));
    expect(mensaje, isNot(contains('documentos_verificacion')));
  });
}
