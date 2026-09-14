// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ubicacion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ubicacion {
  double get lat;
  double get lng;
  String get direccionTexto;

  /// Piso, departamento, entre calles. Es dato de contacto: la vista
  /// `pedidos_publicos` no lo expone.
  String? get referencia;

  /// Create a copy of Ubicacion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<Ubicacion> get copyWith =>
      _$UbicacionCopyWithImpl<Ubicacion>(this as Ubicacion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Ubicacion &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.direccionTexto, direccionTexto) ||
                other.direccionTexto == direccionTexto) &&
            (identical(other.referencia, referencia) ||
                other.referencia == referencia));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, lat, lng, direccionTexto, referencia);

  @override
  String toString() {
    return 'Ubicacion(lat: $lat, lng: $lng, direccionTexto: $direccionTexto, referencia: $referencia)';
  }
}

/// @nodoc
abstract mixin class $UbicacionCopyWith<$Res> {
  factory $UbicacionCopyWith(Ubicacion value, $Res Function(Ubicacion) _then) =
      _$UbicacionCopyWithImpl;
  @useResult
  $Res call(
      {double lat, double lng, String direccionTexto, String? referencia});
}

/// @nodoc
class _$UbicacionCopyWithImpl<$Res> implements $UbicacionCopyWith<$Res> {
  _$UbicacionCopyWithImpl(this._self, this._then);

  final Ubicacion _self;
  final $Res Function(Ubicacion) _then;

  /// Create a copy of Ubicacion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? direccionTexto = null,
    Object? referencia = freezed,
  }) {
    return _then(_self.copyWith(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      direccionTexto: null == direccionTexto
          ? _self.direccionTexto
          : direccionTexto // ignore: cast_nullable_to_non_nullable
              as String,
      referencia: freezed == referencia
          ? _self.referencia
          : referencia // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Ubicacion].
extension UbicacionPatterns on Ubicacion {
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
    TResult Function(_Ubicacion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Ubicacion() when $default != null:
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
    TResult Function(_Ubicacion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ubicacion():
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
    TResult? Function(_Ubicacion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ubicacion() when $default != null:
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
            double lat, double lng, String direccionTexto, String? referencia)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Ubicacion() when $default != null:
        return $default(
            _that.lat, _that.lng, _that.direccionTexto, _that.referencia);
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
            double lat, double lng, String direccionTexto, String? referencia)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ubicacion():
        return $default(
            _that.lat, _that.lng, _that.direccionTexto, _that.referencia);
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
            double lat, double lng, String direccionTexto, String? referencia)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ubicacion() when $default != null:
        return $default(
            _that.lat, _that.lng, _that.direccionTexto, _that.referencia);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Ubicacion extends Ubicacion {
  const _Ubicacion(
      {required this.lat,
      required this.lng,
      required this.direccionTexto,
      this.referencia})
      : super._();

  @override
  final double lat;
  @override
  final double lng;
  @override
  final String direccionTexto;

  /// Piso, departamento, entre calles. Es dato de contacto: la vista
  /// `pedidos_publicos` no lo expone.
  @override
  final String? referencia;

  /// Create a copy of Ubicacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UbicacionCopyWith<_Ubicacion> get copyWith =>
      __$UbicacionCopyWithImpl<_Ubicacion>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Ubicacion &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.direccionTexto, direccionTexto) ||
                other.direccionTexto == direccionTexto) &&
            (identical(other.referencia, referencia) ||
                other.referencia == referencia));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, lat, lng, direccionTexto, referencia);

  @override
  String toString() {
    return 'Ubicacion(lat: $lat, lng: $lng, direccionTexto: $direccionTexto, referencia: $referencia)';
  }
}

/// @nodoc
abstract mixin class _$UbicacionCopyWith<$Res>
    implements $UbicacionCopyWith<$Res> {
  factory _$UbicacionCopyWith(
          _Ubicacion value, $Res Function(_Ubicacion) _then) =
      __$UbicacionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double lat, double lng, String direccionTexto, String? referencia});
}

/// @nodoc
class __$UbicacionCopyWithImpl<$Res> implements _$UbicacionCopyWith<$Res> {
  __$UbicacionCopyWithImpl(this._self, this._then);

  final _Ubicacion _self;
  final $Res Function(_Ubicacion) _then;

  /// Create a copy of Ubicacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? direccionTexto = null,
    Object? referencia = freezed,
  }) {
    return _then(_Ubicacion(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      direccionTexto: null == direccionTexto
          ? _self.direccionTexto
          : direccionTexto // ignore: cast_nullable_to_non_nullable
              as String,
      referencia: freezed == referencia
          ? _self.referencia
          : referencia // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
