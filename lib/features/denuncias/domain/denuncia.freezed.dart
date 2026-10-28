// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'denuncia.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DenunciaAdmin {
  String get id;
  int get numero;
  GravedadDenuncia get gravedad;
  String get denunciante;
  String get denuncianteTipo;
  String? get denunciadoId;
  String get denunciado;
  String get denunciadoTipo;
  String? get denunciadoEstado;
  double? get reputacion;
  int get denunciasPrevias;
  String? get pedidoId;
  String? get pedidoTitulo;
  MotivoDenuncia get motivo;
  String get descripcion;
  String get estado;
  String? get resolucion;
  DateTime? get resueltaAt;
  DateTime get creadaAt;

  /// Create a copy of DenunciaAdmin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DenunciaAdminCopyWith<DenunciaAdmin> get copyWith =>
      _$DenunciaAdminCopyWithImpl<DenunciaAdmin>(
          this as DenunciaAdmin, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DenunciaAdmin &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.gravedad, gravedad) ||
                other.gravedad == gravedad) &&
            (identical(other.denunciante, denunciante) ||
                other.denunciante == denunciante) &&
            (identical(other.denuncianteTipo, denuncianteTipo) ||
                other.denuncianteTipo == denuncianteTipo) &&
            (identical(other.denunciadoId, denunciadoId) ||
                other.denunciadoId == denunciadoId) &&
            (identical(other.denunciado, denunciado) ||
                other.denunciado == denunciado) &&
            (identical(other.denunciadoTipo, denunciadoTipo) ||
                other.denunciadoTipo == denunciadoTipo) &&
            (identical(other.denunciadoEstado, denunciadoEstado) ||
                other.denunciadoEstado == denunciadoEstado) &&
            (identical(other.reputacion, reputacion) ||
                other.reputacion == reputacion) &&
            (identical(other.denunciasPrevias, denunciasPrevias) ||
                other.denunciasPrevias == denunciasPrevias) &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.pedidoTitulo, pedidoTitulo) ||
                other.pedidoTitulo == pedidoTitulo) &&
            (identical(other.motivo, motivo) || other.motivo == motivo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.resolucion, resolucion) ||
                other.resolucion == resolucion) &&
            (identical(other.resueltaAt, resueltaAt) ||
                other.resueltaAt == resueltaAt) &&
            (identical(other.creadaAt, creadaAt) ||
                other.creadaAt == creadaAt));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        numero,
        gravedad,
        denunciante,
        denuncianteTipo,
        denunciadoId,
        denunciado,
        denunciadoTipo,
        denunciadoEstado,
        reputacion,
        denunciasPrevias,
        pedidoId,
        pedidoTitulo,
        motivo,
        descripcion,
        estado,
        resolucion,
        resueltaAt,
        creadaAt
      ]);

  @override
  String toString() {
    return 'DenunciaAdmin(id: $id, numero: $numero, gravedad: $gravedad, denunciante: $denunciante, denuncianteTipo: $denuncianteTipo, denunciadoId: $denunciadoId, denunciado: $denunciado, denunciadoTipo: $denunciadoTipo, denunciadoEstado: $denunciadoEstado, reputacion: $reputacion, denunciasPrevias: $denunciasPrevias, pedidoId: $pedidoId, pedidoTitulo: $pedidoTitulo, motivo: $motivo, descripcion: $descripcion, estado: $estado, resolucion: $resolucion, resueltaAt: $resueltaAt, creadaAt: $creadaAt)';
  }
}

/// @nodoc
abstract mixin class $DenunciaAdminCopyWith<$Res> {
  factory $DenunciaAdminCopyWith(
          DenunciaAdmin value, $Res Function(DenunciaAdmin) _then) =
      _$DenunciaAdminCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      int numero,
      GravedadDenuncia gravedad,
      String denunciante,
      String denuncianteTipo,
      String? denunciadoId,
      String denunciado,
      String denunciadoTipo,
      String? denunciadoEstado,
      double? reputacion,
      int denunciasPrevias,
      String? pedidoId,
      String? pedidoTitulo,
      MotivoDenuncia motivo,
      String descripcion,
      String estado,
      String? resolucion,
      DateTime? resueltaAt,
      DateTime creadaAt});
}

/// @nodoc
class _$DenunciaAdminCopyWithImpl<$Res>
    implements $DenunciaAdminCopyWith<$Res> {
  _$DenunciaAdminCopyWithImpl(this._self, this._then);

  final DenunciaAdmin _self;
  final $Res Function(DenunciaAdmin) _then;

  /// Create a copy of DenunciaAdmin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? numero = null,
    Object? gravedad = null,
    Object? denunciante = null,
    Object? denuncianteTipo = null,
    Object? denunciadoId = freezed,
    Object? denunciado = null,
    Object? denunciadoTipo = null,
    Object? denunciadoEstado = freezed,
    Object? reputacion = freezed,
    Object? denunciasPrevias = null,
    Object? pedidoId = freezed,
    Object? pedidoTitulo = freezed,
    Object? motivo = null,
    Object? descripcion = null,
    Object? estado = null,
    Object? resolucion = freezed,
    Object? resueltaAt = freezed,
    Object? creadaAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _self.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as int,
      gravedad: null == gravedad
          ? _self.gravedad
          : gravedad // ignore: cast_nullable_to_non_nullable
              as GravedadDenuncia,
      denunciante: null == denunciante
          ? _self.denunciante
          : denunciante // ignore: cast_nullable_to_non_nullable
              as String,
      denuncianteTipo: null == denuncianteTipo
          ? _self.denuncianteTipo
          : denuncianteTipo // ignore: cast_nullable_to_non_nullable
              as String,
      denunciadoId: freezed == denunciadoId
          ? _self.denunciadoId
          : denunciadoId // ignore: cast_nullable_to_non_nullable
              as String?,
      denunciado: null == denunciado
          ? _self.denunciado
          : denunciado // ignore: cast_nullable_to_non_nullable
              as String,
      denunciadoTipo: null == denunciadoTipo
          ? _self.denunciadoTipo
          : denunciadoTipo // ignore: cast_nullable_to_non_nullable
              as String,
      denunciadoEstado: freezed == denunciadoEstado
          ? _self.denunciadoEstado
          : denunciadoEstado // ignore: cast_nullable_to_non_nullable
              as String?,
      reputacion: freezed == reputacion
          ? _self.reputacion
          : reputacion // ignore: cast_nullable_to_non_nullable
              as double?,
      denunciasPrevias: null == denunciasPrevias
          ? _self.denunciasPrevias
          : denunciasPrevias // ignore: cast_nullable_to_non_nullable
              as int,
      pedidoId: freezed == pedidoId
          ? _self.pedidoId
          : pedidoId // ignore: cast_nullable_to_non_nullable
              as String?,
      pedidoTitulo: freezed == pedidoTitulo
          ? _self.pedidoTitulo
          : pedidoTitulo // ignore: cast_nullable_to_non_nullable
              as String?,
      motivo: null == motivo
          ? _self.motivo
          : motivo // ignore: cast_nullable_to_non_nullable
              as MotivoDenuncia,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      resolucion: freezed == resolucion
          ? _self.resolucion
          : resolucion // ignore: cast_nullable_to_non_nullable
              as String?,
      resueltaAt: freezed == resueltaAt
          ? _self.resueltaAt
          : resueltaAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creadaAt: null == creadaAt
          ? _self.creadaAt
          : creadaAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [DenunciaAdmin].
extension DenunciaAdminPatterns on DenunciaAdmin {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DenunciaAdmin value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DenunciaAdmin value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DenunciaAdmin value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            int numero,
            GravedadDenuncia gravedad,
            String denunciante,
            String denuncianteTipo,
            String? denunciadoId,
            String denunciado,
            String denunciadoTipo,
            String? denunciadoEstado,
            double? reputacion,
            int denunciasPrevias,
            String? pedidoId,
            String? pedidoTitulo,
            MotivoDenuncia motivo,
            String descripcion,
            String estado,
            String? resolucion,
            DateTime? resueltaAt,
            DateTime creadaAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin() when $default != null:
        return $default(
            _that.id,
            _that.numero,
            _that.gravedad,
            _that.denunciante,
            _that.denuncianteTipo,
            _that.denunciadoId,
            _that.denunciado,
            _that.denunciadoTipo,
            _that.denunciadoEstado,
            _that.reputacion,
            _that.denunciasPrevias,
            _that.pedidoId,
            _that.pedidoTitulo,
            _that.motivo,
            _that.descripcion,
            _that.estado,
            _that.resolucion,
            _that.resueltaAt,
            _that.creadaAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            int numero,
            GravedadDenuncia gravedad,
            String denunciante,
            String denuncianteTipo,
            String? denunciadoId,
            String denunciado,
            String denunciadoTipo,
            String? denunciadoEstado,
            double? reputacion,
            int denunciasPrevias,
            String? pedidoId,
            String? pedidoTitulo,
            MotivoDenuncia motivo,
            String descripcion,
            String estado,
            String? resolucion,
            DateTime? resueltaAt,
            DateTime creadaAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin():
        return $default(
            _that.id,
            _that.numero,
            _that.gravedad,
            _that.denunciante,
            _that.denuncianteTipo,
            _that.denunciadoId,
            _that.denunciado,
            _that.denunciadoTipo,
            _that.denunciadoEstado,
            _that.reputacion,
            _that.denunciasPrevias,
            _that.pedidoId,
            _that.pedidoTitulo,
            _that.motivo,
            _that.descripcion,
            _that.estado,
            _that.resolucion,
            _that.resueltaAt,
            _that.creadaAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            int numero,
            GravedadDenuncia gravedad,
            String denunciante,
            String denuncianteTipo,
            String? denunciadoId,
            String denunciado,
            String denunciadoTipo,
            String? denunciadoEstado,
            double? reputacion,
            int denunciasPrevias,
            String? pedidoId,
            String? pedidoTitulo,
            MotivoDenuncia motivo,
            String descripcion,
            String estado,
            String? resolucion,
            DateTime? resueltaAt,
            DateTime creadaAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin() when $default != null:
        return $default(
            _that.id,
            _that.numero,
            _that.gravedad,
            _that.denunciante,
            _that.denuncianteTipo,
            _that.denunciadoId,
            _that.denunciado,
            _that.denunciadoTipo,
            _that.denunciadoEstado,
            _that.reputacion,
            _that.denunciasPrevias,
            _that.pedidoId,
            _that.pedidoTitulo,
            _that.motivo,
            _that.descripcion,
            _that.estado,
            _that.resolucion,
            _that.resueltaAt,
            _that.creadaAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DenunciaAdmin extends DenunciaAdmin {
  const _DenunciaAdmin(
      {required this.id,
      this.numero = 0,
      this.gravedad = GravedadDenuncia.baja,
      required this.denunciante,
      required this.denuncianteTipo,
      this.denunciadoId,
      required this.denunciado,
      required this.denunciadoTipo,
      this.denunciadoEstado,
      this.reputacion,
      this.denunciasPrevias = 0,
      this.pedidoId,
      this.pedidoTitulo,
      required this.motivo,
      required this.descripcion,
      required this.estado,
      this.resolucion,
      this.resueltaAt,
      required this.creadaAt})
      : super._();

  @override
  final String id;
  @override
  @JsonKey()
  final int numero;
  @override
  @JsonKey()
  final GravedadDenuncia gravedad;
  @override
  final String denunciante;
  @override
  final String denuncianteTipo;
  @override
  final String? denunciadoId;
  @override
  final String denunciado;
  @override
  final String denunciadoTipo;
  @override
  final String? denunciadoEstado;
  @override
  final double? reputacion;
  @override
  @JsonKey()
  final int denunciasPrevias;
  @override
  final String? pedidoId;
  @override
  final String? pedidoTitulo;
  @override
  final MotivoDenuncia motivo;
  @override
  final String descripcion;
  @override
  final String estado;
  @override
  final String? resolucion;
  @override
  final DateTime? resueltaAt;
  @override
  final DateTime creadaAt;

  /// Create a copy of DenunciaAdmin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DenunciaAdminCopyWith<_DenunciaAdmin> get copyWith =>
      __$DenunciaAdminCopyWithImpl<_DenunciaAdmin>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DenunciaAdmin &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.numero, numero) || other.numero == numero) &&
            (identical(other.gravedad, gravedad) ||
                other.gravedad == gravedad) &&
            (identical(other.denunciante, denunciante) ||
                other.denunciante == denunciante) &&
            (identical(other.denuncianteTipo, denuncianteTipo) ||
                other.denuncianteTipo == denuncianteTipo) &&
            (identical(other.denunciadoId, denunciadoId) ||
                other.denunciadoId == denunciadoId) &&
            (identical(other.denunciado, denunciado) ||
                other.denunciado == denunciado) &&
            (identical(other.denunciadoTipo, denunciadoTipo) ||
                other.denunciadoTipo == denunciadoTipo) &&
            (identical(other.denunciadoEstado, denunciadoEstado) ||
                other.denunciadoEstado == denunciadoEstado) &&
            (identical(other.reputacion, reputacion) ||
                other.reputacion == reputacion) &&
            (identical(other.denunciasPrevias, denunciasPrevias) ||
                other.denunciasPrevias == denunciasPrevias) &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.pedidoTitulo, pedidoTitulo) ||
                other.pedidoTitulo == pedidoTitulo) &&
            (identical(other.motivo, motivo) || other.motivo == motivo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.resolucion, resolucion) ||
                other.resolucion == resolucion) &&
            (identical(other.resueltaAt, resueltaAt) ||
                other.resueltaAt == resueltaAt) &&
            (identical(other.creadaAt, creadaAt) ||
                other.creadaAt == creadaAt));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        numero,
        gravedad,
        denunciante,
        denuncianteTipo,
        denunciadoId,
        denunciado,
        denunciadoTipo,
        denunciadoEstado,
        reputacion,
        denunciasPrevias,
        pedidoId,
        pedidoTitulo,
        motivo,
        descripcion,
        estado,
        resolucion,
        resueltaAt,
        creadaAt
      ]);

  @override
  String toString() {
    return 'DenunciaAdmin(id: $id, numero: $numero, gravedad: $gravedad, denunciante: $denunciante, denuncianteTipo: $denuncianteTipo, denunciadoId: $denunciadoId, denunciado: $denunciado, denunciadoTipo: $denunciadoTipo, denunciadoEstado: $denunciadoEstado, reputacion: $reputacion, denunciasPrevias: $denunciasPrevias, pedidoId: $pedidoId, pedidoTitulo: $pedidoTitulo, motivo: $motivo, descripcion: $descripcion, estado: $estado, resolucion: $resolucion, resueltaAt: $resueltaAt, creadaAt: $creadaAt)';
  }
}

/// @nodoc
abstract mixin class _$DenunciaAdminCopyWith<$Res>
    implements $DenunciaAdminCopyWith<$Res> {
  factory _$DenunciaAdminCopyWith(
          _DenunciaAdmin value, $Res Function(_DenunciaAdmin) _then) =
      __$DenunciaAdminCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      int numero,
      GravedadDenuncia gravedad,
      String denunciante,
      String denuncianteTipo,
      String? denunciadoId,
      String denunciado,
      String denunciadoTipo,
      String? denunciadoEstado,
      double? reputacion,
      int denunciasPrevias,
      String? pedidoId,
      String? pedidoTitulo,
      MotivoDenuncia motivo,
      String descripcion,
      String estado,
      String? resolucion,
      DateTime? resueltaAt,
      DateTime creadaAt});
}

/// @nodoc
class __$DenunciaAdminCopyWithImpl<$Res>
    implements _$DenunciaAdminCopyWith<$Res> {
  __$DenunciaAdminCopyWithImpl(this._self, this._then);

  final _DenunciaAdmin _self;
  final $Res Function(_DenunciaAdmin) _then;

  /// Create a copy of DenunciaAdmin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? numero = null,
    Object? gravedad = null,
    Object? denunciante = null,
    Object? denuncianteTipo = null,
    Object? denunciadoId = freezed,
    Object? denunciado = null,
    Object? denunciadoTipo = null,
    Object? denunciadoEstado = freezed,
    Object? reputacion = freezed,
    Object? denunciasPrevias = null,
    Object? pedidoId = freezed,
    Object? pedidoTitulo = freezed,
    Object? motivo = null,
    Object? descripcion = null,
    Object? estado = null,
    Object? resolucion = freezed,
    Object? resueltaAt = freezed,
    Object? creadaAt = null,
  }) {
    return _then(_DenunciaAdmin(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      numero: null == numero
          ? _self.numero
          : numero // ignore: cast_nullable_to_non_nullable
              as int,
      gravedad: null == gravedad
          ? _self.gravedad
          : gravedad // ignore: cast_nullable_to_non_nullable
              as GravedadDenuncia,
      denunciante: null == denunciante
          ? _self.denunciante
          : denunciante // ignore: cast_nullable_to_non_nullable
              as String,
      denuncianteTipo: null == denuncianteTipo
          ? _self.denuncianteTipo
          : denuncianteTipo // ignore: cast_nullable_to_non_nullable
              as String,
      denunciadoId: freezed == denunciadoId
          ? _self.denunciadoId
          : denunciadoId // ignore: cast_nullable_to_non_nullable
              as String?,
      denunciado: null == denunciado
          ? _self.denunciado
          : denunciado // ignore: cast_nullable_to_non_nullable
              as String,
      denunciadoTipo: null == denunciadoTipo
          ? _self.denunciadoTipo
          : denunciadoTipo // ignore: cast_nullable_to_non_nullable
              as String,
      denunciadoEstado: freezed == denunciadoEstado
          ? _self.denunciadoEstado
          : denunciadoEstado // ignore: cast_nullable_to_non_nullable
              as String?,
      reputacion: freezed == reputacion
          ? _self.reputacion
          : reputacion // ignore: cast_nullable_to_non_nullable
              as double?,
      denunciasPrevias: null == denunciasPrevias
          ? _self.denunciasPrevias
          : denunciasPrevias // ignore: cast_nullable_to_non_nullable
              as int,
      pedidoId: freezed == pedidoId
          ? _self.pedidoId
          : pedidoId // ignore: cast_nullable_to_non_nullable
              as String?,
      pedidoTitulo: freezed == pedidoTitulo
          ? _self.pedidoTitulo
          : pedidoTitulo // ignore: cast_nullable_to_non_nullable
              as String?,
      motivo: null == motivo
          ? _self.motivo
          : motivo // ignore: cast_nullable_to_non_nullable
              as MotivoDenuncia,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      resolucion: freezed == resolucion
          ? _self.resolucion
          : resolucion // ignore: cast_nullable_to_non_nullable
              as String?,
      resueltaAt: freezed == resueltaAt
          ? _self.resueltaAt
          : resueltaAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creadaAt: null == creadaAt
          ? _self.creadaAt
          : creadaAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
