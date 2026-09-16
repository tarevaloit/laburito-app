// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'foto_portafolio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FotoPortafolio {
  String get id;
  String get storagePath;
  int get orden;
  String? get descripcion;

  /// Create a copy of FotoPortafolio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FotoPortafolioCopyWith<FotoPortafolio> get copyWith =>
      _$FotoPortafolioCopyWithImpl<FotoPortafolio>(
          this as FotoPortafolio, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FotoPortafolio &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.orden, orden) || other.orden == orden) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, storagePath, orden, descripcion);

  @override
  String toString() {
    return 'FotoPortafolio(id: $id, storagePath: $storagePath, orden: $orden, descripcion: $descripcion)';
  }
}

/// @nodoc
abstract mixin class $FotoPortafolioCopyWith<$Res> {
  factory $FotoPortafolioCopyWith(
          FotoPortafolio value, $Res Function(FotoPortafolio) _then) =
      _$FotoPortafolioCopyWithImpl;
  @useResult
  $Res call({String id, String storagePath, int orden, String? descripcion});
}

/// @nodoc
class _$FotoPortafolioCopyWithImpl<$Res>
    implements $FotoPortafolioCopyWith<$Res> {
  _$FotoPortafolioCopyWithImpl(this._self, this._then);

  final FotoPortafolio _self;
  final $Res Function(FotoPortafolio) _then;

  /// Create a copy of FotoPortafolio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? storagePath = null,
    Object? orden = null,
    Object? descripcion = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _self.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      orden: null == orden
          ? _self.orden
          : orden // ignore: cast_nullable_to_non_nullable
              as int,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [FotoPortafolio].
extension FotoPortafolioPatterns on FotoPortafolio {
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
    TResult Function(_FotoPortafolio value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FotoPortafolio() when $default != null:
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
    TResult Function(_FotoPortafolio value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FotoPortafolio():
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
    TResult? Function(_FotoPortafolio value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FotoPortafolio() when $default != null:
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
            String id, String storagePath, int orden, String? descripcion)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FotoPortafolio() when $default != null:
        return $default(
            _that.id, _that.storagePath, _that.orden, _that.descripcion);
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
            String id, String storagePath, int orden, String? descripcion)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FotoPortafolio():
        return $default(
            _that.id, _that.storagePath, _that.orden, _that.descripcion);
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
            String id, String storagePath, int orden, String? descripcion)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FotoPortafolio() when $default != null:
        return $default(
            _that.id, _that.storagePath, _that.orden, _that.descripcion);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _FotoPortafolio extends FotoPortafolio {
  const _FotoPortafolio(
      {required this.id,
      required this.storagePath,
      required this.orden,
      this.descripcion})
      : super._();

  @override
  final String id;
  @override
  final String storagePath;
  @override
  final int orden;
  @override
  final String? descripcion;

  /// Create a copy of FotoPortafolio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FotoPortafolioCopyWith<_FotoPortafolio> get copyWith =>
      __$FotoPortafolioCopyWithImpl<_FotoPortafolio>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FotoPortafolio &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.orden, orden) || other.orden == orden) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, storagePath, orden, descripcion);

  @override
  String toString() {
    return 'FotoPortafolio(id: $id, storagePath: $storagePath, orden: $orden, descripcion: $descripcion)';
  }
}

/// @nodoc
abstract mixin class _$FotoPortafolioCopyWith<$Res>
    implements $FotoPortafolioCopyWith<$Res> {
  factory _$FotoPortafolioCopyWith(
          _FotoPortafolio value, $Res Function(_FotoPortafolio) _then) =
      __$FotoPortafolioCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String storagePath, int orden, String? descripcion});
}

/// @nodoc
class __$FotoPortafolioCopyWithImpl<$Res>
    implements _$FotoPortafolioCopyWith<$Res> {
  __$FotoPortafolioCopyWithImpl(this._self, this._then);

  final _FotoPortafolio _self;
  final $Res Function(_FotoPortafolio) _then;

  /// Create a copy of FotoPortafolio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? storagePath = null,
    Object? orden = null,
    Object? descripcion = freezed,
  }) {
    return _then(_FotoPortafolio(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _self.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      orden: null == orden
          ? _self.orden
          : orden // ignore: cast_nullable_to_non_nullable
              as int,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
