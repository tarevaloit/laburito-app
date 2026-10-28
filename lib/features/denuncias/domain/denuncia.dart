import 'package:freezed_annotation/freezed_annotation.dart';

part 'denuncia.freezed.dart';

/// Los motivos del CU-41 (enum `denuncia_motivo` de la 0027).
enum MotivoDenuncia {
  comportamientoInapropiado('comportamiento_inapropiado', 'Comportamiento inapropiado'),
  incumplimiento('incumplimiento', 'No cumplió lo acordado'),
  estafa('estafa', 'Estafa o cobro indebido'),
  perfilFalso('perfil_falso', 'Perfil falso'),
  otro('otro', 'Otro motivo');

  const MotivoDenuncia(this.valor, this.etiqueta);

  /// El valor del enum en la base.
  final String valor;
  final String etiqueta;

  static MotivoDenuncia desde(String? valor) =>
      values.firstWhere((m) => m.valor == valor, orElse: () => otro);
}

/// Decisión 6 del Sprint 6: la gravedad sale del motivo (la calcula
/// `gravedad_denuncia` en la base, 0040).
enum GravedadDenuncia {
  baja('Baja'),
  media('Media'),
  grave('Grave');

  const GravedadDenuncia(this.etiqueta);

  final String etiqueta;

  static GravedadDenuncia desde(int? nivel) => switch (nivel) {
        3 => grave,
        2 => media,
        _ => baja,
      };
}

/// CU-41 y CU-39 — Una denuncia tal como la ve el administrador. Sale de
/// `denuncias_admin()` (0033, ampliada en la 0040 con la gravedad, la
/// reputación del denunciado y la resolución).
@freezed
abstract class DenunciaAdmin with _$DenunciaAdmin {
  const DenunciaAdmin._();

  const factory DenunciaAdmin({
    required String id,
    @Default(0) int numero,
    @Default(GravedadDenuncia.baja) GravedadDenuncia gravedad,
    required String denunciante,
    required String denuncianteTipo,
    String? denunciadoId,
    required String denunciado,
    required String denunciadoTipo,
    String? denunciadoEstado,
    double? reputacion,
    @Default(0) int denunciasPrevias,
    String? pedidoId,
    String? pedidoTitulo,
    required MotivoDenuncia motivo,
    required String descripcion,
    required String estado,
    String? resolucion,
    DateTime? resueltaAt,
    required DateTime creadaAt,
  }) = _DenunciaAdmin;

  bool get pendiente => estado == 'pendiente';
  bool get abierta => estado == 'pendiente' || estado == 'en_revision';

  String get estadoLegible => switch (estado) {
        'pendiente' => 'Pendiente',
        'en_revision' => 'En revisión',
        'resuelta' => 'Resuelta',
        'desestimada' => 'Desestimada',
        final otro => otro,
      };

  factory DenunciaAdmin.desdeFila(Map<String, dynamic> f) => DenunciaAdmin(
        id: f['id'] as String,
        numero: (f['numero'] as num?)?.toInt() ?? 0,
        gravedad: GravedadDenuncia.desde((f['gravedad'] as num?)?.toInt()),
        denunciante: f['denunciante'] as String? ?? '',
        denuncianteTipo: f['denunciante_tipo'] as String? ?? '',
        denunciadoId: f['denunciado_id'] as String?,
        denunciado: f['denunciado'] as String? ?? '',
        denunciadoTipo: f['denunciado_tipo'] as String? ?? '',
        denunciadoEstado: f['denunciado_estado'] as String?,
        reputacion: (f['reputacion'] as num?)?.toDouble(),
        denunciasPrevias: (f['denuncias_previas'] as num?)?.toInt() ?? 0,
        pedidoId: f['pedido_id'] as String?,
        pedidoTitulo: f['pedido_titulo'] as String?,
        motivo: MotivoDenuncia.desde(f['motivo'] as String?),
        descripcion: f['descripcion'] as String? ?? '',
        estado: f['estado'] as String? ?? 'pendiente',
        resolucion: f['resolucion'] as String?,
        resueltaAt: f['resuelta_at'] == null
            ? null
            : DateTime.parse(f['resuelta_at'] as String),
        creadaAt: DateTime.parse(f['created_at'] as String),
      );
}

/// Cómo se cierra una denuncia (CU-39, pasos 5 y 6 o flujo alterno).
class ResolucionDenuncia {
  const ResolucionDenuncia({
    required this.desestimar,
    required this.texto,
    this.suspender = false,
    this.dias,
    this.apelable = true,
  });

  final bool desestimar;
  final String texto;
  final bool suspender;
  final int? dias;
  final bool apelable;
}
