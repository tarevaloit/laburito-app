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

/// CU-41 — Una denuncia tal como la ve el administrador. Sale de
/// `denuncias_admin()`.
@freezed
abstract class DenunciaAdmin with _$DenunciaAdmin {
  const DenunciaAdmin._();

  const factory DenunciaAdmin({
    required String id,
    required String denunciante,
    required String denuncianteTipo,
    required String denunciado,
    required String denunciadoTipo,
    String? pedidoTitulo,
    required MotivoDenuncia motivo,
    required String descripcion,
    required String estado,
    required DateTime creadaAt,
  }) = _DenunciaAdmin;

  bool get pendiente => estado == 'pendiente';

  factory DenunciaAdmin.desdeFila(Map<String, dynamic> f) => DenunciaAdmin(
        id: f['id'] as String,
        denunciante: f['denunciante'] as String? ?? '',
        denuncianteTipo: f['denunciante_tipo'] as String? ?? '',
        denunciado: f['denunciado'] as String? ?? '',
        denunciadoTipo: f['denunciado_tipo'] as String? ?? '',
        pedidoTitulo: f['pedido_titulo'] as String?,
        motivo: MotivoDenuncia.desde(f['motivo'] as String?),
        descripcion: f['descripcion'] as String? ?? '',
        estado: f['estado'] as String? ?? 'pendiente',
        creadaAt: DateTime.parse(f['created_at'] as String),
      );
}
