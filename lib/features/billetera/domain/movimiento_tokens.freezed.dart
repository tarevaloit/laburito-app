// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movimiento_tokens.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MovimientoTokens {
  String get id;
  TipoMovimiento get tipo;
  int get cantidad;
  int get saldoResultante;
  String get descripcion;
  DateTime get fecha;

  /// Create a copy of MovimientoTokens
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MovimientoTokensCopyWith<MovimientoTokens> get copyWith =>
      _$MovimientoTokensCopyWithImpl<MovimientoTokens>(
          this as MovimientoTokens, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MovimientoTokens &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.cantidad, cantidad) ||
                other.cantidad == cantidad) &&
            (identical(other.saldoResultante, saldoResultante) ||
                other.saldoResultante == saldoResultante) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.fecha, fecha) || other.fecha == fecha));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, tipo, cantidad, saldoResultante, descripcion, fecha);

  @override
  String toString() {
    return 'MovimientoTokens(id: $id, tipo: $tipo, cantidad: $cantidad, saldoResultante: $saldoResultante, descripcion: $descripcion, fecha: $fecha)';
  }
}

/// @nodoc
abstract mixin class $MovimientoTokensCopyWith<$Res> {
  factory $MovimientoTokensCopyWith(
          MovimientoTokens value, $Res Function(MovimientoTokens) _then) =
      _$MovimientoTokensCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      TipoMovimiento tipo,
      int cantidad,
      int saldoResultante,
      String descripcion,
      DateTime fecha});
}

/// @nodoc
class _$MovimientoTokensCopyWithImpl<$Res>
    implements $MovimientoTokensCopyWith<$Res> {
  _$MovimientoTokensCopyWithImpl(this._self, this._then);

  final MovimientoTokens _self;
  final $Res Function(MovimientoTokens) _then;

  /// Create a copy of MovimientoTokens
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? cantidad = null,
    Object? saldoResultante = null,
    Object? descripcion = null,
    Object? fecha = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoMovimiento,
      cantidad: null == cantidad
          ? _self.cantidad
          : cantidad // ignore: cast_nullable_to_non_nullable
              as int,
      saldoResultante: null == saldoResultante
          ? _self.saldoResultante
          : saldoResultante // ignore: cast_nullable_to_non_nullable
              as int,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      fecha: null == fecha
          ? _self.fecha
          : fecha // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [MovimientoTokens].
extension MovimientoTokensPatterns on MovimientoTokens {
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
    TResult Function(_MovimientoTokens value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MovimientoTokens() when $default != null:
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
    TResult Function(_MovimientoTokens value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MovimientoTokens():
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
    TResult? Function(_MovimientoTokens value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MovimientoTokens() when $default != null:
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
    TResult Function(String id, TipoMovimiento tipo, int cantidad,
            int saldoResultante, String descripcion, DateTime fecha)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MovimientoTokens() when $default != null:
        return $default(_that.id, _that.tipo, _that.cantidad,
            _that.saldoResultante, _that.descripcion, _that.fecha);
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
    TResult Function(String id, TipoMovimiento tipo, int cantidad,
            int saldoResultante, String descripcion, DateTime fecha)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MovimientoTokens():
        return $default(_that.id, _that.tipo, _that.cantidad,
            _that.saldoResultante, _that.descripcion, _that.fecha);
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
    TResult? Function(String id, TipoMovimiento tipo, int cantidad,
            int saldoResultante, String descripcion, DateTime fecha)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MovimientoTokens() when $default != null:
        return $default(_that.id, _that.tipo, _that.cantidad,
            _that.saldoResultante, _that.descripcion, _that.fecha);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MovimientoTokens extends MovimientoTokens {
  const _MovimientoTokens(
      {required this.id,
      required this.tipo,
      required this.cantidad,
      required this.saldoResultante,
      required this.descripcion,
      required this.fecha})
      : super._();

  @override
  final String id;
  @override
  final TipoMovimiento tipo;
  @override
  final int cantidad;
  @override
  final int saldoResultante;
  @override
  final String descripcion;
  @override
  final DateTime fecha;

  /// Create a copy of MovimientoTokens
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MovimientoTokensCopyWith<_MovimientoTokens> get copyWith =>
      __$MovimientoTokensCopyWithImpl<_MovimientoTokens>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MovimientoTokens &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.cantidad, cantidad) ||
                other.cantidad == cantidad) &&
            (identical(other.saldoResultante, saldoResultante) ||
                other.saldoResultante == saldoResultante) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.fecha, fecha) || other.fecha == fecha));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, tipo, cantidad, saldoResultante, descripcion, fecha);

  @override
  String toString() {
    return 'MovimientoTokens(id: $id, tipo: $tipo, cantidad: $cantidad, saldoResultante: $saldoResultante, descripcion: $descripcion, fecha: $fecha)';
  }
}

/// @nodoc
abstract mixin class _$MovimientoTokensCopyWith<$Res>
    implements $MovimientoTokensCopyWith<$Res> {
  factory _$MovimientoTokensCopyWith(
          _MovimientoTokens value, $Res Function(_MovimientoTokens) _then) =
      __$MovimientoTokensCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      TipoMovimiento tipo,
      int cantidad,
      int saldoResultante,
      String descripcion,
      DateTime fecha});
}

/// @nodoc
class __$MovimientoTokensCopyWithImpl<$Res>
    implements _$MovimientoTokensCopyWith<$Res> {
  __$MovimientoTokensCopyWithImpl(this._self, this._then);

  final _MovimientoTokens _self;
  final $Res Function(_MovimientoTokens) _then;

  /// Create a copy of MovimientoTokens
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? cantidad = null,
    Object? saldoResultante = null,
    Object? descripcion = null,
    Object? fecha = null,
  }) {
    return _then(_MovimientoTokens(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as TipoMovimiento,
      cantidad: null == cantidad
          ? _self.cantidad
          : cantidad // ignore: cast_nullable_to_non_nullable
              as int,
      saldoResultante: null == saldoResultante
          ? _self.saldoResultante
          : saldoResultante // ignore: cast_nullable_to_non_nullable
              as int,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      fecha: null == fecha
          ? _self.fecha
          : fecha // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
