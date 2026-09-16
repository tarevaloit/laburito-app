// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zona_cobertura.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ZonaCobertura {
  Ubicacion get centro;
  int get radioMetros;

  /// Create a copy of ZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ZonaCoberturaCopyWith<ZonaCobertura> get copyWith =>
      _$ZonaCoberturaCopyWithImpl<ZonaCobertura>(
          this as ZonaCobertura, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ZonaCobertura &&
            (identical(other.centro, centro) || other.centro == centro) &&
            (identical(other.radioMetros, radioMetros) ||
                other.radioMetros == radioMetros));
  }

  @override
  int get hashCode => Object.hash(runtimeType, centro, radioMetros);

  @override
  String toString() {
    return 'ZonaCobertura(centro: $centro, radioMetros: $radioMetros)';
  }
}

/// @nodoc
abstract mixin class $ZonaCoberturaCopyWith<$Res> {
  factory $ZonaCoberturaCopyWith(
          ZonaCobertura value, $Res Function(ZonaCobertura) _then) =
      _$ZonaCoberturaCopyWithImpl;
  @useResult
  $Res call({Ubicacion centro, int radioMetros});

  $UbicacionCopyWith<$Res> get centro;
}

/// @nodoc
class _$ZonaCoberturaCopyWithImpl<$Res>
    implements $ZonaCoberturaCopyWith<$Res> {
  _$ZonaCoberturaCopyWithImpl(this._self, this._then);

  final ZonaCobertura _self;
  final $Res Function(ZonaCobertura) _then;

  /// Create a copy of ZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? centro = null,
    Object? radioMetros = null,
  }) {
    return _then(_self.copyWith(
      centro: null == centro
          ? _self.centro
          : centro // ignore: cast_nullable_to_non_nullable
              as Ubicacion,
      radioMetros: null == radioMetros
          ? _self.radioMetros
          : radioMetros // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of ZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res> get centro {
    return $UbicacionCopyWith<$Res>(_self.centro, (value) {
      return _then(_self.copyWith(centro: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ZonaCobertura].
extension ZonaCoberturaPatterns on ZonaCobertura {
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
    TResult Function(_ZonaCobertura value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ZonaCobertura() when $default != null:
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
    TResult Function(_ZonaCobertura value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ZonaCobertura():
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
    TResult? Function(_ZonaCobertura value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ZonaCobertura() when $default != null:
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
    TResult Function(Ubicacion centro, int radioMetros)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ZonaCobertura() when $default != null:
        return $default(_that.centro, _that.radioMetros);
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
    TResult Function(Ubicacion centro, int radioMetros) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ZonaCobertura():
        return $default(_that.centro, _that.radioMetros);
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
    TResult? Function(Ubicacion centro, int radioMetros)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ZonaCobertura() when $default != null:
        return $default(_that.centro, _that.radioMetros);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ZonaCobertura extends ZonaCobertura {
  const _ZonaCobertura({required this.centro, required this.radioMetros})
      : super._();

  @override
  final Ubicacion centro;
  @override
  final int radioMetros;

  /// Create a copy of ZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ZonaCoberturaCopyWith<_ZonaCobertura> get copyWith =>
      __$ZonaCoberturaCopyWithImpl<_ZonaCobertura>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ZonaCobertura &&
            (identical(other.centro, centro) || other.centro == centro) &&
            (identical(other.radioMetros, radioMetros) ||
                other.radioMetros == radioMetros));
  }

  @override
  int get hashCode => Object.hash(runtimeType, centro, radioMetros);

  @override
  String toString() {
    return 'ZonaCobertura(centro: $centro, radioMetros: $radioMetros)';
  }
}

/// @nodoc
abstract mixin class _$ZonaCoberturaCopyWith<$Res>
    implements $ZonaCoberturaCopyWith<$Res> {
  factory _$ZonaCoberturaCopyWith(
          _ZonaCobertura value, $Res Function(_ZonaCobertura) _then) =
      __$ZonaCoberturaCopyWithImpl;
  @override
  @useResult
  $Res call({Ubicacion centro, int radioMetros});

  @override
  $UbicacionCopyWith<$Res> get centro;
}

/// @nodoc
class __$ZonaCoberturaCopyWithImpl<$Res>
    implements _$ZonaCoberturaCopyWith<$Res> {
  __$ZonaCoberturaCopyWithImpl(this._self, this._then);

  final _ZonaCobertura _self;
  final $Res Function(_ZonaCobertura) _then;

  /// Create a copy of ZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? centro = null,
    Object? radioMetros = null,
  }) {
    return _then(_ZonaCobertura(
      centro: null == centro
          ? _self.centro
          : centro // ignore: cast_nullable_to_non_nullable
              as Ubicacion,
      radioMetros: null == radioMetros
          ? _self.radioMetros
          : radioMetros // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of ZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res> get centro {
    return $UbicacionCopyWith<$Res>(_self.centro, (value) {
      return _then(_self.copyWith(centro: value));
    });
  }
}

// dart format on
