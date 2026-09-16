// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horario_atencion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HorarioAtencion {
  int get dia;
  int get desdeMinutos;
  int get hastaMinutos;

  /// Create a copy of HorarioAtencion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HorarioAtencionCopyWith<HorarioAtencion> get copyWith =>
      _$HorarioAtencionCopyWithImpl<HorarioAtencion>(
          this as HorarioAtencion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HorarioAtencion &&
            (identical(other.dia, dia) || other.dia == dia) &&
            (identical(other.desdeMinutos, desdeMinutos) ||
                other.desdeMinutos == desdeMinutos) &&
            (identical(other.hastaMinutos, hastaMinutos) ||
                other.hastaMinutos == hastaMinutos));
  }

  @override
  int get hashCode => Object.hash(runtimeType, dia, desdeMinutos, hastaMinutos);

  @override
  String toString() {
    return 'HorarioAtencion(dia: $dia, desdeMinutos: $desdeMinutos, hastaMinutos: $hastaMinutos)';
  }
}

/// @nodoc
abstract mixin class $HorarioAtencionCopyWith<$Res> {
  factory $HorarioAtencionCopyWith(
          HorarioAtencion value, $Res Function(HorarioAtencion) _then) =
      _$HorarioAtencionCopyWithImpl;
  @useResult
  $Res call({int dia, int desdeMinutos, int hastaMinutos});
}

/// @nodoc
class _$HorarioAtencionCopyWithImpl<$Res>
    implements $HorarioAtencionCopyWith<$Res> {
  _$HorarioAtencionCopyWithImpl(this._self, this._then);

  final HorarioAtencion _self;
  final $Res Function(HorarioAtencion) _then;

  /// Create a copy of HorarioAtencion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dia = null,
    Object? desdeMinutos = null,
    Object? hastaMinutos = null,
  }) {
    return _then(_self.copyWith(
      dia: null == dia
          ? _self.dia
          : dia // ignore: cast_nullable_to_non_nullable
              as int,
      desdeMinutos: null == desdeMinutos
          ? _self.desdeMinutos
          : desdeMinutos // ignore: cast_nullable_to_non_nullable
              as int,
      hastaMinutos: null == hastaMinutos
          ? _self.hastaMinutos
          : hastaMinutos // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [HorarioAtencion].
extension HorarioAtencionPatterns on HorarioAtencion {
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
    TResult Function(_HorarioAtencion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HorarioAtencion() when $default != null:
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
    TResult Function(_HorarioAtencion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HorarioAtencion():
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
    TResult? Function(_HorarioAtencion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HorarioAtencion() when $default != null:
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
    TResult Function(int dia, int desdeMinutos, int hastaMinutos)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HorarioAtencion() when $default != null:
        return $default(_that.dia, _that.desdeMinutos, _that.hastaMinutos);
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
    TResult Function(int dia, int desdeMinutos, int hastaMinutos) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HorarioAtencion():
        return $default(_that.dia, _that.desdeMinutos, _that.hastaMinutos);
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
    TResult? Function(int dia, int desdeMinutos, int hastaMinutos)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HorarioAtencion() when $default != null:
        return $default(_that.dia, _that.desdeMinutos, _that.hastaMinutos);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _HorarioAtencion extends HorarioAtencion {
  const _HorarioAtencion(
      {required this.dia,
      required this.desdeMinutos,
      required this.hastaMinutos})
      : super._();

  @override
  final int dia;
  @override
  final int desdeMinutos;
  @override
  final int hastaMinutos;

  /// Create a copy of HorarioAtencion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HorarioAtencionCopyWith<_HorarioAtencion> get copyWith =>
      __$HorarioAtencionCopyWithImpl<_HorarioAtencion>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HorarioAtencion &&
            (identical(other.dia, dia) || other.dia == dia) &&
            (identical(other.desdeMinutos, desdeMinutos) ||
                other.desdeMinutos == desdeMinutos) &&
            (identical(other.hastaMinutos, hastaMinutos) ||
                other.hastaMinutos == hastaMinutos));
  }

  @override
  int get hashCode => Object.hash(runtimeType, dia, desdeMinutos, hastaMinutos);

  @override
  String toString() {
    return 'HorarioAtencion(dia: $dia, desdeMinutos: $desdeMinutos, hastaMinutos: $hastaMinutos)';
  }
}

/// @nodoc
abstract mixin class _$HorarioAtencionCopyWith<$Res>
    implements $HorarioAtencionCopyWith<$Res> {
  factory _$HorarioAtencionCopyWith(
          _HorarioAtencion value, $Res Function(_HorarioAtencion) _then) =
      __$HorarioAtencionCopyWithImpl;
  @override
  @useResult
  $Res call({int dia, int desdeMinutos, int hastaMinutos});
}

/// @nodoc
class __$HorarioAtencionCopyWithImpl<$Res>
    implements _$HorarioAtencionCopyWith<$Res> {
  __$HorarioAtencionCopyWithImpl(this._self, this._then);

  final _HorarioAtencion _self;
  final $Res Function(_HorarioAtencion) _then;

  /// Create a copy of HorarioAtencion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? dia = null,
    Object? desdeMinutos = null,
    Object? hastaMinutos = null,
  }) {
    return _then(_HorarioAtencion(
      dia: null == dia
          ? _self.dia
          : dia // ignore: cast_nullable_to_non_nullable
              as int,
      desdeMinutos: null == desdeMinutos
          ? _self.desdeMinutos
          : desdeMinutos // ignore: cast_nullable_to_non_nullable
              as int,
      hastaMinutos: null == hastaMinutos
          ? _self.hastaMinutos
          : hastaMinutos // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
