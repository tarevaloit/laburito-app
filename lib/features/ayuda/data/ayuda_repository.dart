import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

part 'ayuda_repository.g.dart';

/// Una pregunta frecuente (tabla `preguntas_frecuentes`, 0034 y 0044).
class PreguntaFrecuente {
  const PreguntaFrecuente({
    required this.categoria,
    required this.pregunta,
    required this.respuesta,
  });

  final String categoria;
  final String pregunta;
  final String respuesta;

  /// Paso 2: «buscador de soporte». Sin tildes ni mayúsculas, para que
  /// «contrasena» encuentre «contraseña».
  bool coincide(String busqueda) {
    final b = normalizar(busqueda);
    return b.isEmpty ||
        normalizar(pregunta).contains(b) ||
        normalizar(respuesta).contains(b) ||
        normalizar(categoria).contains(b);
  }

  static String normalizar(String texto) {
    const con = 'áéíóúüñ';
    const sin = 'aeiouun';
    final b = StringBuffer();
    for (final c in texto.toLowerCase().trim().split('')) {
      final i = con.indexOf(c);
      b.write(i >= 0 ? sin[i] : c);
    }
    return b.toString();
  }

  factory PreguntaFrecuente.desdeFila(Map<String, dynamic> f) => PreguntaFrecuente(
        categoria: f['categoria'] as String,
        pregunta: f['pregunta'] as String,
        respuesta: f['respuesta'] as String,
      );
}

/// CU-42 — Consultar Ayuda y Soporte. Lectura pública: anda sin sesión.
class AyudaRepository {
  const AyudaRepository(this._client);

  final SupabaseClient _client;

  Future<List<PreguntaFrecuente>> preguntas() async {
    final filas = await _client
        .from('preguntas_frecuentes')
        .select('categoria, pregunta, respuesta')
        .order('categoria')
        .order('orden');
    return [
      for (final f in filas as List)
        PreguntaFrecuente.desdeFila(f as Map<String, dynamic>),
    ];
  }
}

@Riverpod(keepAlive: true)
AyudaRepository ayudaRepository(Ref ref) =>
    AyudaRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<PreguntaFrecuente>> preguntasFrecuentes(Ref ref) =>
    ref.watch(ayudaRepositoryProvider).preguntas();
