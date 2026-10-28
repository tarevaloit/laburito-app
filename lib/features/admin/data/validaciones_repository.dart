import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

part 'validaciones_repository.g.dart';

/// Un Profesional con la documentación en revisión, tal como lo devuelve
/// `profesionales_en_revision()` (0037).
class ProfesionalEnRevision {
  const ProfesionalEnRevision({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.dni,
    this.oficios,
    this.documentos = const {},
    this.enviadoAt,
  });

  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? dni;
  final String? oficios;

  /// Tipo de documento (`dni_frente`, `dni_dorso`, `selfie`) → ruta en el
  /// bucket privado `documentos`.
  final Map<String, String> documentos;
  final DateTime? enviadoAt;

  String get nombreCompleto => '$nombre $apellido';

  factory ProfesionalEnRevision.desdeFila(Map<String, dynamic> f) =>
      ProfesionalEnRevision(
        id: f['profesional_id'] as String,
        nombre: f['nombre'] as String? ?? '',
        apellido: f['apellido'] as String? ?? '',
        email: f['email'] as String? ?? '',
        telefono: f['telefono'] as String?,
        dni: f['dni'] as String?,
        oficios: f['oficios'] as String?,
        documentos: {
          for (final e in ((f['documentos'] as Map?) ?? const {}).entries)
            e.key as String: e.value as String,
        },
        enviadoAt: f['enviado_at'] == null
            ? null
            : DateTime.parse(f['enviado_at'] as String),
      );
}

/// CU-35 — Validar Identidad Profesional.
class ValidacionesRepository {
  const ValidacionesRepository(this._client);

  final SupabaseClient _client;

  Future<List<ProfesionalEnRevision>> pendientes() async {
    final filas = await _client.rpc('profesionales_en_revision') as List;
    return [
      for (final f in filas)
        ProfesionalEnRevision.desdeFila(f as Map<String, dynamic>),
    ];
  }

  /// Paso 4: «las imágenes en alta resolución». Firmadas por diez minutos:
  /// alcanzan para revisar y no quedan circulando.
  Future<String> urlFirmada(String ruta) =>
      _client.storage.from('documentos').createSignedUrl(ruta, 600);

  /// Pasos 5 y 6. Primero se destruyen los archivos (requerimiento especial
  /// del CU-35) y después se resuelve: el orden del CU-11, que deja la
  /// operación reintentable si algo falla en el medio.
  Future<void> resolver(
    ProfesionalEnRevision profesional, {
    required bool aprobar,
    String? motivo,
  }) async {
    final rutas = profesional.documentos.values.toList();
    if (rutas.isNotEmpty) {
      await _client.storage.from('documentos').remove(rutas);
    }
    await _client.rpc('resolver_verificacion', params: {
      'p_profesional': profesional.id,
      'p_aprobar': aprobar,
      'p_motivo': motivo,
    });
  }
}

@Riverpod(keepAlive: true)
ValidacionesRepository validacionesRepository(Ref ref) =>
    ValidacionesRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<ProfesionalEnRevision>> profesionalesEnRevision(Ref ref) =>
    ref.watch(validacionesRepositoryProvider).pendientes();

@riverpod
Future<String> urlDocumentoAdmin(Ref ref, String ruta) =>
    ref.watch(validacionesRepositoryProvider).urlFirmada(ruta);
