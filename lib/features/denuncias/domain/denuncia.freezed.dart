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
  String get denunciante;
  String get denuncianteTipo;
  String get denunciado;
  String get denunciadoTipo;
  String? get pedidoTitulo;
  MotivoDenuncia get motivo;
  String get descripcion;
  String get estado;
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
            (identical(other.denunciante, denunciante) ||
                other.denunciante == denunciante) &&
            (identical(other.denuncianteTipo, denuncianteTipo) ||
                other.denuncianteTipo == denuncianteTipo) &&
            (identical(other.denunciado, denunciado) ||
                other.denunciado == denunciado) &&
            (identical(other.denunciadoTipo, denunciadoTipo) ||
                other.denunciadoTipo == denunciadoTipo) &&
            (identical(other.pedidoTitulo, pedidoTitulo) ||
                other.pedidoTitulo == pedidoTitulo) &&
            (identical(other.motivo, motivo) || other.motivo == motivo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.creadaAt, creadaAt) ||
                other.creadaAt == creadaAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      denunciante,
      denuncianteTipo,
      denunciado,
      denunciadoTipo,
      pedidoTitulo,
      motivo,
      descripcion,
      estado,
      creadaAt);

  @override
  String toString() {
    return 'DenunciaAdmin(id: $id, denunciante: $denunciante, denuncianteTipo: $denuncianteTipo, denunciado: $denunciado, denunciadoTipo: $denunciadoTipo, pedidoTitulo: $pedidoTitulo, motivo: $motivo, descripcion: $descripcion, estado: $estado, creadaAt: $creadaAt)';
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
      String denunciante,
      String denuncianteTipo,
      String denunciado,
      String denunciadoTipo,
      String? pedidoTitulo,
      MotivoDenuncia motivo,
      String descripcion,
      String estado,
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
    Object? denunciante = null,
    Object? denuncianteTipo = null,
    Object? denunciado = null,
    Object? denunciadoTipo = null,
    Object? pedidoTitulo = freezed,
    Object? motivo = null,
    Object? descripcion = null,
    Object? estado = null,
    Object? creadaAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      denunciante: null == denunciante
          ? _self.denunciante
          : denunciante // ignore: cast_nullable_to_non_nullable
              as String,
      denuncianteTipo: null == denuncianteTipo
          ? _self.denuncianteTipo
          : denuncianteTipo // ignore: cast_nullable_to_non_nullable
              as String,
      denunciado: null == denunciado
          ? _self.denunciado
          : denunciado // ignore: cast_nullable_to_non_nullable
              as String,
      denunciadoTipo: null == denunciadoTipo
          ? _self.denunciadoTipo
          : denunciadoTipo // ignore: cast_nullable_to_non_nullable
              as String,
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
            String denunciante,
            String denuncianteTipo,
            String denunciado,
            String denunciadoTipo,
            String? pedidoTitulo,
            MotivoDenuncia motivo,
            String descripcion,
            String estado,
            DateTime creadaAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin() when $default != null:
        return $default(
            _that.id,
            _that.denunciante,
            _that.denuncianteTipo,
            _that.denunciado,
            _that.denunciadoTipo,
            _that.pedidoTitulo,
            _that.motivo,
            _that.descripcion,
            _that.estado,
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
            String denunciante,
            String denuncianteTipo,
            String denunciado,
            String denunciadoTipo,
            String? pedidoTitulo,
            MotivoDenuncia motivo,
            String descripcion,
            String estado,
            DateTime creadaAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin():
        return $default(
            _that.id,
            _that.denunciante,
            _that.denuncianteTipo,
            _that.denunciado,
            _that.denunciadoTipo,
            _that.pedidoTitulo,
            _that.motivo,
            _that.descripcion,
            _that.estado,
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
            String denunciante,
            String denuncianteTipo,
            String denunciado,
            String denunciadoTipo,
            String? pedidoTitulo,
            MotivoDenuncia motivo,
            String descripcion,
            String estado,
            DateTime creadaAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DenunciaAdmin() when $default != null:
        return $default(
            _that.id,
            _that.denunciante,
            _that.denuncianteTipo,
            _that.denunciado,
            _that.denunciadoTipo,
            _that.pedidoTitulo,
            _that.motivo,
            _that.descripcion,
            _that.estado,
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
      required this.denunciante,
      required this.denuncianteTipo,
      required this.denunciado,
      required this.denunciadoTipo,
      this.pedidoTitulo,
      required this.motivo,
      required this.descripcion,
      required this.estado,
      required this.creadaAt})
      : super._();

  @override
  final String id;
  @override
  final String denunciante;
  @override
  final String denuncianteTipo;
  @override
  final String denunciado;
  @override
  final String denunciadoTipo;
  @override
  final String? pedidoTitulo;
  @override
  final MotivoDenuncia motivo;
  @override
  final String descripcion;
  @override
  final String estado;
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
            (identical(other.denunciante, denunciante) ||
                other.denunciante == denunciante) &&
            (identical(other.denuncianteTipo, denuncianteTipo) ||
                other.denuncianteTipo == denuncianteTipo) &&
            (identical(other.denunciado, denunciado) ||
                other.denunciado == denunciado) &&
            (identical(other.denunciadoTipo, denunciadoTipo) ||
                other.denunciadoTipo == denunciadoTipo) &&
            (identical(other.pedidoTitulo, pedidoTitulo) ||
                other.pedidoTitulo == pedidoTitulo) &&
            (identical(other.motivo, motivo) || other.motivo == motivo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.creadaAt, creadaAt) ||
                other.creadaAt == creadaAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      denunciante,
      denuncianteTipo,
      denunciado,
      denunciadoTipo,
      pedidoTitulo,
      motivo,
      descripcion,
      estado,
      creadaAt);

  @override
  String toString() {
    return 'DenunciaAdmin(id: $id, denunciante: $denunciante, denuncianteTipo: $denuncianteTipo, denunciado: $denunciado, denunciadoTipo: $denunciadoTipo, pedidoTitulo: $pedidoTitulo, motivo: $motivo, descripcion: $descripcion, estado: $estado, creadaAt: $creadaAt)';
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
      String denunciante,
      String denuncianteTipo,
      String denunciado,
      String denunciadoTipo,
      String? pedidoTitulo,
      MotivoDenuncia motivo,
      String descripcion,
      String estado,
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
    Object? denunciante = null,
    Object? denuncianteTipo = null,
    Object? denunciado = null,
    Object? denunciadoTipo = null,
    Object? pedidoTitulo = freezed,
    Object? motivo = null,
    Object? descripcion = null,
    Object? estado = null,
    Object? creadaAt = null,
  }) {
    return _then(_DenunciaAdmin(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      denunciante: null == denunciante
          ? _self.denunciante
          : denunciante // ignore: cast_nullable_to_non_nullable
              as String,
      denuncianteTipo: null == denuncianteTipo
          ? _self.denuncianteTipo
          : denuncianteTipo // ignore: cast_nullable_to_non_nullable
              as String,
      denunciado: null == denunciado
          ? _self.denunciado
          : denunciado // ignore: cast_nullable_to_non_nullable
              as String,
      denunciadoTipo: null == denunciadoTipo
          ? _self.denunciadoTipo
          : denunciadoTipo // ignore: cast_nullable_to_non_nullable
              as String,
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
      creadaAt: null == creadaAt
          ? _self.creadaAt
          : creadaAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
