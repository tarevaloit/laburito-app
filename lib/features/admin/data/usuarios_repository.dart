import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';

part 'usuarios_repository.g.dart';

/// Un renglón del buscador general del panel (CU-36, paso 1).
class UsuarioAdmin {
  const UsuarioAdmin({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.tipo,
    required this.estado,
  });

  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String tipo;
  final String estado;

  String get nombreCompleto => '$nombre $apellido';
  bool get suspendido => estado == 'suspendido';

  factory UsuarioAdmin.desdeFila(Map<String, dynamic> f) => UsuarioAdmin(
        id: f['id'] as String,
        nombre: f['nombre'] as String? ?? '',
        apellido: f['apellido'] as String? ?? '',
        email: f['email'] as String? ?? '',
        tipo: f['tipo'] as String? ?? '',
        estado: f['estado'] as String? ?? '',
      );
}

/// Una sanción del historial del usuario (tabla `sanciones`, 0034).
class Sancion {
  const Sancion({
    required this.id,
    required this.motivo,
    required this.permanente,
    required this.apelable,
    required this.fecha,
    this.hasta,
    this.levantadaAt,
  });

  final String id;
  final String motivo;
  final bool permanente;
  final bool apelable;
  final DateTime fecha;
  final DateTime? hasta;
  final DateTime? levantadaAt;

  bool get vigente => levantadaAt == null;

  factory Sancion.desdeJson(Map<String, dynamic> j) => Sancion(
        id: j['id'] as String,
        motivo: j['motivo'] as String? ?? '',
        permanente: j['permanente'] as bool? ?? false,
        apelable: j['apelable'] as bool? ?? true,
        fecha: DateTime.parse((j['fecha'] ?? j['created_at']) as String),
        hasta: j['hasta'] == null ? null : DateTime.parse(j['hasta'] as String),
        levantadaAt: j['levantada_at'] == null
            ? null
            : DateTime.parse(j['levantada_at'] as String),
      );
}

/// Paso 2 del CU-36: «el detalle del usuario, incluyendo su historial de
/// pedidos, denuncias y calificaciones previas». Sale de
/// `detalle_usuario_admin` (0039).
class DetalleUsuario {
  const DetalleUsuario({
    required this.usuario,
    this.telefono,
    this.verificacion,
    this.promedio,
    this.totalCalificaciones = 0,
    this.contactos = 0,
    this.totalPedidos = 0,
    this.pedidos = const [],
    this.denunciasRecibidas = const [],
    this.denunciasHechas = 0,
    this.calificaciones = const [],
    this.sanciones = const [],
  });

  final UsuarioAdmin usuario;
  final String? telefono;
  final String? verificacion;
  final double? promedio;
  final int totalCalificaciones;
  final int contactos;
  final int totalPedidos;
  final List<Map<String, dynamic>> pedidos;
  final List<Map<String, dynamic>> denunciasRecibidas;
  final int denunciasHechas;
  final List<Map<String, dynamic>> calificaciones;
  final List<Sancion> sanciones;

  Sancion? get sancionVigente =>
      sanciones.where((s) => s.vigente).firstOrNull;

  factory DetalleUsuario.desdeJson(Map<String, dynamic> j) {
    final pro = j['profesional'] as Map<String, dynamic>?;
    List<Map<String, dynamic>> lista(String clave) => [
          for (final e in (j[clave] as List? ?? const []))
            Map<String, dynamic>.from(e as Map),
        ];
    return DetalleUsuario(
      usuario: UsuarioAdmin.desdeFila(j),
      telefono: j['telefono'] as String?,
      verificacion: pro?['estado_verificacion'] as String?,
      promedio: (pro?['calificacion_promedio'] as num?)?.toDouble(),
      totalCalificaciones: (pro?['total_calificaciones'] as num?)?.toInt() ?? 0,
      contactos: (pro?['contactos'] as num?)?.toInt() ?? 0,
      totalPedidos: (j['total_pedidos'] as num?)?.toInt() ?? 0,
      pedidos: lista('pedidos'),
      denunciasRecibidas: lista('denuncias_recibidas'),
      denunciasHechas: (j['denuncias_hechas'] as num?)?.toInt() ?? 0,
      calificaciones: lista('calificaciones'),
      sanciones: [for (final s in lista('sanciones')) Sancion.desdeJson(s)],
    );
  }
}

/// Lo que el administrador configura en el formulario modal del paso 4.
class SuspensionPedida {
  const SuspensionPedida({
    required this.motivo,
    required this.dias,
    required this.apelable,
  });

  final String motivo;

  /// `null` = permanente.
  final int? dias;
  final bool apelable;
}

/// CU-36 — Suspender Cuenta (migración 0039).
class UsuariosRepository {
  const UsuariosRepository(this._client);

  final SupabaseClient _client;

  Future<List<UsuarioAdmin>> buscar({String? texto, String? tipo}) async {
    final filas = await _client.rpc('buscar_usuarios_admin',
        params: {'p_texto': texto, 'p_tipo': tipo}) as List;
    return [
      for (final f in filas) UsuarioAdmin.desdeFila(f as Map<String, dynamic>),
    ];
  }

  Future<DetalleUsuario> detalle(String id) async {
    final json = await _client.rpc('detalle_usuario_admin', params: {'p_id': id});
    return DetalleUsuario.desdeJson(json as Map<String, dynamic>);
  }

  Future<void> suspender(
    String perfilId,
    SuspensionPedida s, {
    String? denunciaId,
  }) =>
      _client.rpc('suspender_cuenta', params: {
        'p_perfil': perfilId,
        'p_motivo': s.motivo,
        'p_dias': s.dias,
        'p_apelable': s.apelable,
        'p_denuncia': denunciaId,
      });

  Future<void> levantar(String sancionId, String motivo) => _client.rpc(
      'levantar_sancion',
      params: {'p_sancion': sancionId, 'p_motivo': motivo});
}

@Riverpod(keepAlive: true)
UsuariosRepository usuariosRepository(Ref ref) =>
    UsuariosRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<List<UsuarioAdmin>> usuariosAdmin(Ref ref, String texto, String? tipo) =>
    ref.watch(usuariosRepositoryProvider).buscar(
          texto: texto.isEmpty ? null : texto,
          tipo: tipo,
        );

@riverpod
Future<DetalleUsuario> detalleUsuarioAdmin(Ref ref, String id) =>
    ref.watch(usuariosRepositoryProvider).detalle(id);
