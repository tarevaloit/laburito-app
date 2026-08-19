import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../categorias/data/categorias_repository.dart';
import '../../verificacion/data/documentos_repository.dart';

/// Vista unificada del perfil del usuario autenticado.
class PerfilCompleto {
  const PerfilCompleto({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.estado,
    this.telefono,
    this.avatarUrl,
    this.dni,
    this.descripcion,
    this.estadoVerificacion,
    this.saldoTokens = 0,
    this.categorias = const [],
  });

  final String id;
  final String tipo;
  final String nombre;
  final String apellido;
  final String email;
  final String estado;
  final String? telefono;
  final String? avatarUrl;
  final String? dni;
  final String? descripcion;
  final String? estadoVerificacion;
  final int saldoTokens;
  final List<String> categorias;

  bool get esProfesional => tipo == 'profesional';
  bool get necesitaCargarDocumentacion =>
      esProfesional && estadoVerificacion == 'sin_documentacion';
  String get nombreCompleto => '$nombre $apellido';
}

/// CU-05 (Gestionar Perfil) y CU-11 (Dar de Baja Cuenta).
class PerfilRepository {
  const PerfilRepository(this._client, this._categorias);

  final SupabaseClient _client;
  final CategoriasRepository _categorias;

  Future<PerfilCompleto?> cargar() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return null;

    final perfil = await _client
        .from('perfiles')
        .select('id, tipo, nombre, apellido, email, telefono, avatar_url, estado')
        .eq('id', id)
        .maybeSingle();

    if (perfil == null) return null;

    Map<String, dynamic>? profesional;
    List<String> categorias = const [];

    if (perfil['tipo'] == 'profesional') {
      profesional = await _client
          .from('profesionales')
          .select('dni, descripcion, estado_verificacion, saldo_tokens')
          .eq('perfil_id', id)
          .maybeSingle();
      categorias = await _categorias.slugsDelProfesional(id);
    }

    return PerfilCompleto(
      id: perfil['id'] as String,
      tipo: perfil['tipo'] as String,
      nombre: perfil['nombre'] as String,
      apellido: perfil['apellido'] as String,
      email: perfil['email'] as String,
      estado: perfil['estado'] as String,
      telefono: perfil['telefono'] as String?,
      avatarUrl: perfil['avatar_url'] as String?,
      dni: profesional?['dni'] as String?,
      descripcion: profesional?['descripcion'] as String?,
      estadoVerificacion: profesional?['estado_verificacion'] as String?,
      saldoTokens: (profesional?['saldo_tokens'] as int?) ?? 0,
      categorias: categorias,
    );
  }

  /// CU-05 — Actualizar los datos editables.
  /// El correo no se modifica en este sprint porque exigiría revalidarlo.
  Future<void> actualizar({
    required String nombre,
    required String apellido,
    required String telefono,
    String? descripcion,
    List<String>? categorias,
  }) async {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No hay sesión activa');

    await _client.from('perfiles').update({
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'telefono': telefono.trim(),
    }).eq('id', id);

    if (descripcion != null) {
      await _client
          .from('profesionales')
          .update({'descripcion': descripcion.trim()})
          .eq('perfil_id', id);
    }

    if (categorias != null) {
      await _categorias.reemplazar(profesionalId: id, slugs: categorias);
    }
  }

  /// CU-05 — Avatar. Ruta `{uid}/avatar.jpg`, exigida por la política de Storage.
  Future<String> subirAvatar(Uint8List bytes) async {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('No hay sesión activa');

    final ruta = '$id/avatar.jpg';

    await _client.storage.from('avatares').uploadBinary(
          ruta,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    final url = _client.storage.from('avatares').getPublicUrl(ruta);
    final urlConCacheBust = '$url?v=${DateTime.now().millisecondsSinceEpoch}';

    await _client
        .from('perfiles')
        .update({'avatar_url': urlConCacheBust}).eq('id', id);

    return urlConCacheBust;
  }

  /// CU-11 — Baja de la cuenta: anonimiza los datos personales, destruye los
  /// archivos y libera el correo para que la persona pueda volver a registrarse.
  /// La fila del perfil sobrevive porque es el ancla de las FK del historial.
  Future<void> darDeBaja({String? motivo}) async {
    final id = _client.auth.currentUser?.id;
    if (id != null) await _borrarArchivos(id);

    await _client.rpc('dar_de_baja_cuenta', params: {'p_motivo': motivo});
    await _client.auth.signOut();
  }

  /// Borra avatar y documentación por la API de Storage. Es el único camino que
  /// elimina el objeto y no solo su fila en `storage.objects`; la RPC repite el
  /// borrado a nivel SQL como respaldo. Va antes de la RPC porque después el
  /// usuario ya no tiene permisos sobre su propia carpeta.
  Future<void> _borrarArchivos(String id) async {
    try {
      await _client.storage.from('avatares').remove(['$id/avatar.jpg']);
    } catch (_) {
      // Sin corte: el respaldo de la RPC se ocupa.
    }

    try {
      await _client.storage.from('documentos').remove([
        for (final tipo in TipoDocumento.values) '$id/${tipo.clave}.jpg',
      ]);
    } catch (_) {
      // Sin corte: el respaldo de la RPC se ocupa.
    }
  }
}

final perfilRepositoryProvider = Provider<PerfilRepository>(
  (ref) => PerfilRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(categoriasRepositoryProvider),
  ),
);

final perfilCompletoProvider = FutureProvider<PerfilCompleto?>((ref) {
  ref.watch(sesionProvider);
  return ref.watch(perfilRepositoryProvider).cargar();
});
