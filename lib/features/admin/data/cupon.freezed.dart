// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cupon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Cupon {
  String get id;
  String get codigo;
  int get tokens;
  DateTime get venceAt;
  int get usos;
  int? get limiteUsos;
  bool get activo;

  /// Create a copy of Cupon
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CuponCopyWith<Cupon> get copyWith =>
      _$CuponCopyWithImpl<Cupon>(this as Cupon, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Cupon &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.tokens, tokens) || other.tokens == tokens) &&
            (identical(other.venceAt, venceAt) || other.venceAt == venceAt) &&
            (identical(other.usos, usos) || other.usos == usos) &&
            (identical(other.limiteUsos, limiteUsos) ||
                other.limiteUsos == limiteUsos) &&
            (identical(other.activo, activo) || other.activo == activo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, codigo, tokens, venceAt, usos, limiteUsos, activo);

  @override
  String toString() {
    return 'Cupon(id: $id, codigo: $codigo, tokens: $tokens, venceAt: $venceAt, usos: $usos, limiteUsos: $limiteUsos, activo: $activo)';
  }
}

/// @nodoc
abstract mixin class $CuponCopyWith<$Res> {
  factory $CuponCopyWith(Cupon value, $Res Function(Cupon) _then) =
      _$CuponCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String codigo,
      int tokens,
      DateTime venceAt,
      int usos,
      int? limiteUsos,
      bool activo});
}

/// @nodoc
class _$CuponCopyWithImpl<$Res> implements $CuponCopyWith<$Res> {
  _$CuponCopyWithImpl(this._self, this._then);

  final Cupon _self;
  final $Res Function(Cupon) _then;

  /// Create a copy of Cupon
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? tokens = null,
    Object? venceAt = null,
    Object? usos = null,
    Object? limiteUsos = freezed,
    Object? activo = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _self.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      tokens: null == tokens
          ? _self.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as int,
      venceAt: null == venceAt
          ? _self.venceAt
          : venceAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      usos: null == usos
          ? _self.usos
          : usos // ignore: cast_nullable_to_non_nullable
              as int,
      limiteUsos: freezed == limiteUsos
          ? _self.limiteUsos
          : limiteUsos // ignore: cast_nullable_to_non_nullable
              as int?,
      activo: null == activo
          ? _self.activo
          : activo // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Cupon].
extension CuponPatterns on Cupon {
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
    TResult Function(_Cupon value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Cupon() when $default != null:
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
    TResult Function(_Cupon value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Cupon():
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
    TResult? Function(_Cupon value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Cupon() when $default != null:
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
    TResult Function(String id, String codigo, int tokens, DateTime venceAt,
            int usos, int? limiteUsos, bool activo)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Cupon() when $default != null:
        return $default(_that.id, _that.codigo, _that.tokens, _that.venceAt,
            _that.usos, _that.limiteUsos, _that.activo);
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
    TResult Function(String id, String codigo, int tokens, DateTime venceAt,
            int usos, int? limiteUsos, bool activo)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Cupon():
        return $default(_that.id, _that.codigo, _that.tokens, _that.venceAt,
            _that.usos, _that.limiteUsos, _that.activo);
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
    TResult? Function(String id, String codigo, int tokens, DateTime venceAt,
            int usos, int? limiteUsos, bool activo)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Cupon() when $default != null:
        return $default(_that.id, _that.codigo, _that.tokens, _that.venceAt,
            _that.usos, _that.limiteUsos, _that.activo);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Cupon extends Cupon {
  const _Cupon(
      {required this.id,
      required this.codigo,
      required this.tokens,
      required this.venceAt,
      required this.usos,
      this.limiteUsos,
      this.activo = true})
      : super._();

  @override
  final String id;
  @override
  final String codigo;
  @override
  final int tokens;
  @override
  final DateTime venceAt;
  @override
  final int usos;
  @override
  final int? limiteUsos;
  @override
  @JsonKey()
  final bool activo;

  /// Create a copy of Cupon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CuponCopyWith<_Cupon> get copyWith =>
      __$CuponCopyWithImpl<_Cupon>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Cupon &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.codigo, codigo) || other.codigo == codigo) &&
            (identical(other.tokens, tokens) || other.tokens == tokens) &&
            (identical(other.venceAt, venceAt) || other.venceAt == venceAt) &&
            (identical(other.usos, usos) || other.usos == usos) &&
            (identical(other.limiteUsos, limiteUsos) ||
                other.limiteUsos == limiteUsos) &&
            (identical(other.activo, activo) || other.activo == activo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, codigo, tokens, venceAt, usos, limiteUsos, activo);

  @override
  String toString() {
    return 'Cupon(id: $id, codigo: $codigo, tokens: $tokens, venceAt: $venceAt, usos: $usos, limiteUsos: $limiteUsos, activo: $activo)';
  }
}

/// @nodoc
abstract mixin class _$CuponCopyWith<$Res> implements $CuponCopyWith<$Res> {
  factory _$CuponCopyWith(_Cupon value, $Res Function(_Cupon) _then) =
      __$CuponCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String codigo,
      int tokens,
      DateTime venceAt,
      int usos,
      int? limiteUsos,
      bool activo});
}

/// @nodoc
class __$CuponCopyWithImpl<$Res> implements _$CuponCopyWith<$Res> {
  __$CuponCopyWithImpl(this._self, this._then);

  final _Cupon _self;
  final $Res Function(_Cupon) _then;

  /// Create a copy of Cupon
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? codigo = null,
    Object? tokens = null,
    Object? venceAt = null,
    Object? usos = null,
    Object? limiteUsos = freezed,
    Object? activo = null,
  }) {
    return _then(_Cupon(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      codigo: null == codigo
          ? _self.codigo
          : codigo // ignore: cast_nullable_to_non_nullable
              as String,
      tokens: null == tokens
          ? _self.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as int,
      venceAt: null == venceAt
          ? _self.venceAt
          : venceAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      usos: null == usos
          ? _self.usos
          : usos // ignore: cast_nullable_to_non_nullable
              as int,
      limiteUsos: freezed == limiteUsos
          ? _self.limiteUsos
          : limiteUsos // ignore: cast_nullable_to_non_nullable
              as int?,
      activo: null == activo
          ? _self.activo
          : activo // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
