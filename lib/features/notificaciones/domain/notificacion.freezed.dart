// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notificacion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Notificacion {
  String get id;
  TipoNotificacion get tipo;
  String get titulo;
  String? get cuerpo;
  String? get ruta;
  DateTime? get leidaAt;
  DateTime get creadaAt;

  /// Create a copy of Notificacion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificacionCopyWith<Notificacion> get copyWith =>
      _$NotificacionCopyWithImpl<Notificacion>(
          this as Notificacion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Notificacion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.cuerpo, cuerpo) || other.cuerpo == cuerpo) &&
            (identical(other.ruta, ruta) || other.ruta == ruta) &&
            (identical(other.leidaAt, leidaAt) || other.leidaAt == leidaAt) &&
            (identical(other.creadaAt, creadaAt) ||
                other.creadaAt == creadaAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, tipo, titulo, cuerpo, ruta, leidaAt, creadaAt);

  @override
  String toString() {
    return 'Notificacion(id: $id, tipo: $tipo, titulo: $titulo, cuerpo: $cuerpo, ruta: $ruta, leidaAt: $leidaAt, creadaAt: $creadaAt)';
  }
}

/// @nodoc
abstract mixin class $NotificacionCopyWith<$Res> {
  factory $NotificacionCopyWith(
          Notificacion value, $Res Function(Notificacion) _then) =
      _$NotificacionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      TipoNotificacion tipo,
      String titulo,
      String? cuerpo,
      String? ruta,
      DateTime? leidaAt,
      DateTime creadaAt});
}

/// @nodoc
class _$NotificacionCopyWithImpl<$Res> implements $NotificacionCopyWith<$Res> {
  _$NotificacionCopyWithImpl(this._self, this._then);

  final Notificacion _self;
  final $Res Function(Notificacion) _then;

  /// Create a copy of Notificacion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? titulo = null,
    Object? cuerpo = freezed,
    Object? ruta = freezed,
    Object? leidaAt = freezed,
    Object? creadaAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoNotificacion,
      titulo: null == titulo
          ? _self.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      cuerpo: freezed == cuerpo
          ? _self.cuerpo
          : cuerpo // ignore: cast_nullable_to_non_nullable
              as String?,
      ruta: freezed == ruta
          ? _self.ruta
          : ruta // ignore: cast_nullable_to_non_nullable
              as String?,
      leidaAt: freezed == leidaAt
          ? _self.leidaAt
          : leidaAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creadaAt: null == creadaAt
          ? _self.creadaAt
          : creadaAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Notificacion].
extension NotificacionPatterns on Notificacion {
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
    TResult Function(_Notificacion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Notificacion() when $default != null:
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
    TResult Function(_Notificacion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Notificacion():
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
    TResult? Function(_Notificacion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Notificacion() when $default != null:
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
    TResult Function(String id, TipoNotificacion tipo, String titulo,
            String? cuerpo, String? ruta, DateTime? leidaAt, DateTime creadaAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Notificacion() when $default != null:
        return $default(_that.id, _that.tipo, _that.titulo, _that.cuerpo,
            _that.ruta, _that.leidaAt, _that.creadaAt);
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
    TResult Function(String id, TipoNotificacion tipo, String titulo,
            String? cuerpo, String? ruta, DateTime? leidaAt, DateTime creadaAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Notificacion():
        return $default(_that.id, _that.tipo, _that.titulo, _that.cuerpo,
            _that.ruta, _that.leidaAt, _that.creadaAt);
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
    TResult? Function(String id, TipoNotificacion tipo, String titulo,
            String? cuerpo, String? ruta, DateTime? leidaAt, DateTime creadaAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Notificacion() when $default != null:
        return $default(_that.id, _that.tipo, _that.titulo, _that.cuerpo,
            _that.ruta, _that.leidaAt, _that.creadaAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Notificacion extends Notificacion {
  const _Notificacion(
      {required this.id,
      required this.tipo,
      required this.titulo,
      this.cuerpo,
      this.ruta,
      this.leidaAt,
      required this.creadaAt})
      : super._();

  @override
  final String id;
  @override
  final TipoNotificacion tipo;
  @override
  final String titulo;
  @override
  final String? cuerpo;
  @override
  final String? ruta;
  @override
  final DateTime? leidaAt;
  @override
  final DateTime creadaAt;

  /// Create a copy of Notificacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotificacionCopyWith<_Notificacion> get copyWith =>
      __$NotificacionCopyWithImpl<_Notificacion>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Notificacion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.cuerpo, cuerpo) || other.cuerpo == cuerpo) &&
            (identical(other.ruta, ruta) || other.ruta == ruta) &&
            (identical(other.leidaAt, leidaAt) || other.leidaAt == leidaAt) &&
            (identical(other.creadaAt, creadaAt) ||
                other.creadaAt == creadaAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, tipo, titulo, cuerpo, ruta, leidaAt, creadaAt);

  @override
  String toString() {
    return 'Notificacion(id: $id, tipo: $tipo, titulo: $titulo, cuerpo: $cuerpo, ruta: $ruta, leidaAt: $leidaAt, creadaAt: $creadaAt)';
  }
}

/// @nodoc
abstract mixin class _$NotificacionCopyWith<$Res>
    implements $NotificacionCopyWith<$Res> {
  factory _$NotificacionCopyWith(
          _Notificacion value, $Res Function(_Notificacion) _then) =
      __$NotificacionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      TipoNotificacion tipo,
      String titulo,
      String? cuerpo,
      String? ruta,
      DateTime? leidaAt,
      DateTime creadaAt});
}

/// @nodoc
class __$NotificacionCopyWithImpl<$Res>
    implements _$NotificacionCopyWith<$Res> {
  __$NotificacionCopyWithImpl(this._self, this._then);

  final _Notificacion _self;
  final $Res Function(_Notificacion) _then;

  /// Create a copy of Notificacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? titulo = null,
    Object? cuerpo = freezed,
    Object? ruta = freezed,
    Object? leidaAt = freezed,
    Object? creadaAt = null,
  }) {
    return _then(_Notificacion(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoNotificacion,
      titulo: null == titulo
          ? _self.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      cuerpo: freezed == cuerpo
          ? _self.cuerpo
          : cuerpo // ignore: cast_nullable_to_non_nullable
              as String?,
      ruta: freezed == ruta
          ? _self.ruta
          : ruta // ignore: cast_nullable_to_non_nullable
              as String?,
      leidaAt: freezed == leidaAt
          ? _self.leidaAt
          : leidaAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creadaAt: null == creadaAt
          ? _self.creadaAt
          : creadaAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
