import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/mensajes_error.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../categorias/data/categorias_repository.dart';
import '../../verificacion/data/documentos_repository.dart';

part 'perfil_repository.freezed.dart';
part 'perfil_repository.g.dart';

/// Vista unificada del perfil del usuario autenticado.
@freezed
abstract class PerfilCompleto with _$PerfilCompleto {
  // Constructor privado: freezed lo exige para poder sumar los getters de
  // abajo a la clase generada.
  const PerfilCompleto._();

  const factory PerfilCompleto({
    required String id,
    required String tipo,
    required String nombre,
    required String apellido,
    required String email,
    required String estado,
    String? telefono,
    String? avatarUrl,
    String? dni,
    String? descripcion,
    String? estadoVerificacion,
    @Default(0) int saldoTokens,
    @Default(<String>[]) List<String> categorias,
  }) = _PerfilCompleto;

  bool get esProfesional => tipo == 'profesional';
  bool get necesitaCargarDocumentacion =>
      esProfesional && estadoVerificacion == 'sin_documentacion';
  String get nombreCompleto => '$nombre $apellido';

  /// Los estados viajan como identificadores de la base (`sin_documentacion`,
  /// `en_revision`). Mostrarlos crudos parece un error del sistema, así que la
  /// traducción vive acá y no en cada pantalla.
  String get estadoLegible => switch (estado) {
        'pendiente_verificacion' => 'Falta validar tu correo',
        'activo' => 'Activa',
        'suspendido' => 'Suspendida',
        'baja' => 'Dada de baja',
        _ => estado,
      };

  /// Null cuando el usuario no es Profesional: no hay verificación que mostrar.
  String? get verificacionLegible => switch (estadoVerificacion) {
        null => null,
        'sin_documentacion' => 'Falta subir la documentación',
        'en_revision' => 'En revisión',
        'aprobado' => 'Verificado',
        'rechazado' => 'Rechazada',
        final otro => otro,
      };
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
      await _categorias.reemplazar(slugs: categorias);
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

  /// Destruye avatar y documentación por la API de Storage, que es el único
  /// camino que elimina el objeto y no solo su fila en `storage.objects`
  /// (Supabase rechaza el DML directo sobre esas tablas — ver migración 0004).
  ///
  /// Va **antes** de la RPC y **corta la baja si falla**. No es una precaución
  /// de más: después del anonimizado la persona pierde los permisos sobre su
  /// propia carpeta, así que un fallo posterior dejaría el DNI y la selfie
  /// huérfanos, sin nadie que pueda borrarlos nunca. Frenar y reintentar es
  /// estrictamente mejor que una baja a medias.
  Future<void> _borrarArchivos(String id) async {
    try {
      await _client.storage.from('avatares').remove(['$id/avatar.jpg']);
      await _client.storage.from('documentos').remove([
        for (final tipo in TipoDocumento.values) '$id/${tipo.clave}.jpg',
      ]);
    } on Exception {
      throw const ArchivosNoEliminadosException();
    }
  }
}

@Riverpod(keepAlive: true)
PerfilRepository perfilRepository(Ref ref) => PerfilRepository(
      ref.watch(supabaseClientProvider),
      ref.watch(categoriasRepositoryProvider),
    );

@Riverpod(keepAlive: true)
Future<PerfilCompleto?> perfilCompleto(Ref ref) {
  ref.watch(sesionProvider);
  return ref.watch(perfilRepositoryProvider).cargar();
}
