// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paquete_tokens.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaqueteTokens {
  String get id;
  String get nombre;
  int get cantidad;
  int get precioArs;
  bool get activo;
  int get orden;

  /// Create a copy of PaqueteTokens
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PaqueteTokensCopyWith<PaqueteTokens> get copyWith =>
      _$PaqueteTokensCopyWithImpl<PaqueteTokens>(
          this as PaqueteTokens, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PaqueteTokens &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.cantidad, cantidad) ||
                other.cantidad == cantidad) &&
            (identical(other.precioArs, precioArs) ||
                other.precioArs == precioArs) &&
            (identical(other.activo, activo) || other.activo == activo) &&
            (identical(other.orden, orden) || other.orden == orden));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nombre, cantidad, precioArs, activo, orden);

  @override
  String toString() {
    return 'PaqueteTokens(id: $id, nombre: $nombre, cantidad: $cantidad, precioArs: $precioArs, activo: $activo, orden: $orden)';
  }
}

/// @nodoc
abstract mixin class $PaqueteTokensCopyWith<$Res> {
  factory $PaqueteTokensCopyWith(
          PaqueteTokens value, $Res Function(PaqueteTokens) _then) =
      _$PaqueteTokensCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String nombre,
      int cantidad,
      int precioArs,
      bool activo,
      int orden});
}

/// @nodoc
class _$PaqueteTokensCopyWithImpl<$Res>
    implements $PaqueteTokensCopyWith<$Res> {
  _$PaqueteTokensCopyWithImpl(this._self, this._then);

  final PaqueteTokens _self;
  final $Res Function(PaqueteTokens) _then;

  /// Create a copy of PaqueteTokens
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? cantidad = null,
    Object? precioArs = null,
    Object? activo = null,
    Object? orden = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      cantidad: null == cantidad
          ? _self.cantidad
          : cantidad // ignore: cast_nullable_to_non_nullable
              as int,
      precioArs: null == precioArs
          ? _self.precioArs
          : precioArs // ignore: cast_nullable_to_non_nullable
              as int,
      activo: null == activo
          ? _self.activo
          : activo // ignore: cast_nullable_to_non_nullable
              as bool,
      orden: null == orden
          ? _self.orden
          : orden // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PaqueteTokens].
extension PaqueteTokensPatterns on PaqueteTokens {
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
    TResult Function(_PaqueteTokens value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaqueteTokens() when $default != null:
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
    TResult Function(_PaqueteTokens value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaqueteTokens():
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
    TResult? Function(_PaqueteTokens value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaqueteTokens() when $default != null:
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
    TResult Function(String id, String nombre, int cantidad, int precioArs,
            bool activo, int orden)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaqueteTokens() when $default != null:
        return $default(_that.id, _that.nombre, _that.cantidad, _that.precioArs,
            _that.activo, _that.orden);
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
    TResult Function(String id, String nombre, int cantidad, int precioArs,
            bool activo, int orden)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaqueteTokens():
        return $default(_that.id, _that.nombre, _that.cantidad, _that.precioArs,
            _that.activo, _that.orden);
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
    TResult? Function(String id, String nombre, int cantidad, int precioArs,
            bool activo, int orden)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaqueteTokens() when $default != null:
        return $default(_that.id, _that.nombre, _that.cantidad, _that.precioArs,
            _that.activo, _that.orden);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PaqueteTokens extends PaqueteTokens {
  const _PaqueteTokens(
      {required this.id,
      required this.nombre,
      required this.cantidad,
      required this.precioArs,
      this.activo = true,
      this.orden = 0})
      : super._();

  @override
  final String id;
  @override
  final String nombre;
  @override
  final int cantidad;
  @override
  final int precioArs;
  @override
  @JsonKey()
  final bool activo;
  @override
  @JsonKey()
  final int orden;

  /// Create a copy of PaqueteTokens
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PaqueteTokensCopyWith<_PaqueteTokens> get copyWith =>
      __$PaqueteTokensCopyWithImpl<_PaqueteTokens>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PaqueteTokens &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.cantidad, cantidad) ||
                other.cantidad == cantidad) &&
            (identical(other.precioArs, precioArs) ||
                other.precioArs == precioArs) &&
            (identical(other.activo, activo) || other.activo == activo) &&
            (identical(other.orden, orden) || other.orden == orden));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nombre, cantidad, precioArs, activo, orden);

  @override
  String toString() {
    return 'PaqueteTokens(id: $id, nombre: $nombre, cantidad: $cantidad, precioArs: $precioArs, activo: $activo, orden: $orden)';
  }
}

/// @nodoc
abstract mixin class _$PaqueteTokensCopyWith<$Res>
    implements $PaqueteTokensCopyWith<$Res> {
  factory _$PaqueteTokensCopyWith(
          _PaqueteTokens value, $Res Function(_PaqueteTokens) _then) =
      __$PaqueteTokensCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String nombre,
      int cantidad,
      int precioArs,
      bool activo,
      int orden});
}

/// @nodoc
class __$PaqueteTokensCopyWithImpl<$Res>
    implements _$PaqueteTokensCopyWith<$Res> {
  __$PaqueteTokensCopyWithImpl(this._self, this._then);

  final _PaqueteTokens _self;
  final $Res Function(_PaqueteTokens) _then;

  /// Create a copy of PaqueteTokens
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? cantidad = null,
    Object? precioArs = null,
    Object? activo = null,
    Object? orden = null,
  }) {
    return _then(_PaqueteTokens(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      cantidad: null == cantidad
          ? _self.cantidad
          : cantidad // ignore: cast_nullable_to_non_nullable
              as int,
      precioArs: null == precioArs
          ? _self.precioArs
          : precioArs // ignore: cast_nullable_to_non_nullable
              as int,
      activo: null == activo
          ? _self.activo
          : activo // ignore: cast_nullable_to_non_nullable
              as bool,
      orden: null == orden
          ? _self.orden
          : orden // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
