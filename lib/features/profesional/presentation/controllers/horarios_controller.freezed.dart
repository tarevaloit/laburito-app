// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'horarios_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoHorarios {
  List<HorarioAtencion> get franjas;
  List<HorarioAtencion> get guardadas;
  bool get disponible;
  bool get guardando;
  String? get error;
  String? get aviso;

  /// Create a copy of EstadoHorarios
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoHorariosCopyWith<EstadoHorarios> get copyWith =>
      _$EstadoHorariosCopyWithImpl<EstadoHorarios>(
          this as EstadoHorarios, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoHorarios &&
            const DeepCollectionEquality().equals(other.franjas, franjas) &&
            const DeepCollectionEquality().equals(other.guardadas, guardadas) &&
            (identical(other.disponible, disponible) ||
                other.disponible == disponible) &&
            (identical(other.guardando, guardando) ||
                other.guardando == guardando) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.aviso, aviso) || other.aviso == aviso));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(franjas),
      const DeepCollectionEquality().hash(guardadas),
      disponible,
      guardando,
      error,
      aviso);

  @override
  String toString() {
    return 'EstadoHorarios(franjas: $franjas, guardadas: $guardadas, disponible: $disponible, guardando: $guardando, error: $error, aviso: $aviso)';
  }
}

/// @nodoc
abstract mixin class $EstadoHorariosCopyWith<$Res> {
  factory $EstadoHorariosCopyWith(
          EstadoHorarios value, $Res Function(EstadoHorarios) _then) =
      _$EstadoHorariosCopyWithImpl;
  @useResult
  $Res call(
      {List<HorarioAtencion> franjas,
      List<HorarioAtencion> guardadas,
      bool disponible,
      bool guardando,
      String? error,
      String? aviso});
}

/// @nodoc
class _$EstadoHorariosCopyWithImpl<$Res>
    implements $EstadoHorariosCopyWith<$Res> {
  _$EstadoHorariosCopyWithImpl(this._self, this._then);

  final EstadoHorarios _self;
  final $Res Function(EstadoHorarios) _then;

  /// Create a copy of EstadoHorarios
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? franjas = null,
    Object? guardadas = null,
    Object? disponible = null,
    Object? guardando = null,
    Object? error = freezed,
    Object? aviso = freezed,
  }) {
    return _then(_self.copyWith(
      franjas: null == franjas
          ? _self.franjas
          : franjas // ignore: cast_nullable_to_non_nullable
              as List<HorarioAtencion>,
      guardadas: null == guardadas
          ? _self.guardadas
          : guardadas // ignore: cast_nullable_to_non_nullable
              as List<HorarioAtencion>,
      disponible: null == disponible
          ? _self.disponible
          : disponible // ignore: cast_nullable_to_non_nullable
              as bool,
      guardando: null == guardando
          ? _self.guardando
          : guardando // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      aviso: freezed == aviso
          ? _self.aviso
          : aviso // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EstadoHorarios].
extension EstadoHorariosPatterns on EstadoHorarios {
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
    TResult Function(_EstadoHorarios value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoHorarios() when $default != null:
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
    TResult Function(_EstadoHorarios value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHorarios():
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
    TResult? Function(_EstadoHorarios value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHorarios() when $default != null:
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
            List<HorarioAtencion> franjas,
            List<HorarioAtencion> guardadas,
            bool disponible,
            bool guardando,
            String? error,
            String? aviso)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoHorarios() when $default != null:
        return $default(_that.franjas, _that.guardadas, _that.disponible,
            _that.guardando, _that.error, _that.aviso);
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
            List<HorarioAtencion> franjas,
            List<HorarioAtencion> guardadas,
            bool disponible,
            bool guardando,
            String? error,
            String? aviso)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHorarios():
        return $default(_that.franjas, _that.guardadas, _that.disponible,
            _that.guardando, _that.error, _that.aviso);
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
            List<HorarioAtencion> franjas,
            List<HorarioAtencion> guardadas,
            bool disponible,
            bool guardando,
            String? error,
            String? aviso)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHorarios() when $default != null:
        return $default(_that.franjas, _that.guardadas, _that.disponible,
            _that.guardando, _that.error, _that.aviso);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoHorarios extends EstadoHorarios {
  const _EstadoHorarios(
      {final List<HorarioAtencion> franjas = const <HorarioAtencion>[],
      final List<HorarioAtencion> guardadas = const <HorarioAtencion>[],
      this.disponible = false,
      this.guardando = false,
      this.error,
      this.aviso})
      : _franjas = franjas,
        _guardadas = guardadas,
        super._();

  final List<HorarioAtencion> _franjas;
  @override
  @JsonKey()
  List<HorarioAtencion> get franjas {
    if (_franjas is EqualUnmodifiableListView) return _franjas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_franjas);
  }

  final List<HorarioAtencion> _guardadas;
  @override
  @JsonKey()
  List<HorarioAtencion> get guardadas {
    if (_guardadas is EqualUnmodifiableListView) return _guardadas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_guardadas);
  }

  @override
  @JsonKey()
  final bool disponible;
  @override
  @JsonKey()
  final bool guardando;
  @override
  final String? error;
  @override
  final String? aviso;

  /// Create a copy of EstadoHorarios
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoHorariosCopyWith<_EstadoHorarios> get copyWith =>
      __$EstadoHorariosCopyWithImpl<_EstadoHorarios>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoHorarios &&
            const DeepCollectionEquality().equals(other._franjas, _franjas) &&
            const DeepCollectionEquality()
                .equals(other._guardadas, _guardadas) &&
            (identical(other.disponible, disponible) ||
                other.disponible == disponible) &&
            (identical(other.guardando, guardando) ||
                other.guardando == guardando) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.aviso, aviso) || other.aviso == aviso));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_franjas),
      const DeepCollectionEquality().hash(_guardadas),
      disponible,
      guardando,
      error,
      aviso);

  @override
  String toString() {
    return 'EstadoHorarios(franjas: $franjas, guardadas: $guardadas, disponible: $disponible, guardando: $guardando, error: $error, aviso: $aviso)';
  }
}

/// @nodoc
abstract mixin class _$EstadoHorariosCopyWith<$Res>
    implements $EstadoHorariosCopyWith<$Res> {
  factory _$EstadoHorariosCopyWith(
          _EstadoHorarios value, $Res Function(_EstadoHorarios) _then) =
      __$EstadoHorariosCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<HorarioAtencion> franjas,
      List<HorarioAtencion> guardadas,
      bool disponible,
      bool guardando,
      String? error,
      String? aviso});
}

/// @nodoc
class __$EstadoHorariosCopyWithImpl<$Res>
    implements _$EstadoHorariosCopyWith<$Res> {
  __$EstadoHorariosCopyWithImpl(this._self, this._then);

  final _EstadoHorarios _self;
  final $Res Function(_EstadoHorarios) _then;

  /// Create a copy of EstadoHorarios
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? franjas = null,
    Object? guardadas = null,
    Object? disponible = null,
    Object? guardando = null,
    Object? error = freezed,
    Object? aviso = freezed,
  }) {
    return _then(_EstadoHorarios(
      franjas: null == franjas
          ? _self._franjas
          : franjas // ignore: cast_nullable_to_non_nullable
              as List<HorarioAtencion>,
      guardadas: null == guardadas
          ? _self._guardadas
          : guardadas // ignore: cast_nullable_to_non_nullable
              as List<HorarioAtencion>,
      disponible: null == disponible
          ? _self.disponible
          : disponible // ignore: cast_nullable_to_non_nullable
              as bool,
      guardando: null == guardando
          ? _self.guardando
          : guardando // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      aviso: freezed == aviso
          ? _self.aviso
          : aviso // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
