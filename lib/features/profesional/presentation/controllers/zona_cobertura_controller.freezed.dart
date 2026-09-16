// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zona_cobertura_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoZonaCobertura {
  /// `null` mientras el Profesional no eligió un centro: es el estado de
  /// quien entra por primera vez.
  Ubicacion? get centro;
  int get radioMetros;
  ZonaCobertura? get original;
  bool get guardando;
  String? get error;

  /// Se levanta al guardar bien, para que la pantalla avise una sola vez.
  bool get guardado;

  /// Create a copy of EstadoZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoZonaCoberturaCopyWith<EstadoZonaCobertura> get copyWith =>
      _$EstadoZonaCoberturaCopyWithImpl<EstadoZonaCobertura>(
          this as EstadoZonaCobertura, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoZonaCobertura &&
            (identical(other.centro, centro) || other.centro == centro) &&
            (identical(other.radioMetros, radioMetros) ||
                other.radioMetros == radioMetros) &&
            (identical(other.original, original) ||
                other.original == original) &&
            (identical(other.guardando, guardando) ||
                other.guardando == guardando) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.guardado, guardado) ||
                other.guardado == guardado));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, centro, radioMetros, original, guardando, error, guardado);

  @override
  String toString() {
    return 'EstadoZonaCobertura(centro: $centro, radioMetros: $radioMetros, original: $original, guardando: $guardando, error: $error, guardado: $guardado)';
  }
}

/// @nodoc
abstract mixin class $EstadoZonaCoberturaCopyWith<$Res> {
  factory $EstadoZonaCoberturaCopyWith(
          EstadoZonaCobertura value, $Res Function(EstadoZonaCobertura) _then) =
      _$EstadoZonaCoberturaCopyWithImpl;
  @useResult
  $Res call(
      {Ubicacion? centro,
      int radioMetros,
      ZonaCobertura? original,
      bool guardando,
      String? error,
      bool guardado});

  $UbicacionCopyWith<$Res>? get centro;
  $ZonaCoberturaCopyWith<$Res>? get original;
}

/// @nodoc
class _$EstadoZonaCoberturaCopyWithImpl<$Res>
    implements $EstadoZonaCoberturaCopyWith<$Res> {
  _$EstadoZonaCoberturaCopyWithImpl(this._self, this._then);

  final EstadoZonaCobertura _self;
  final $Res Function(EstadoZonaCobertura) _then;

  /// Create a copy of EstadoZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? centro = freezed,
    Object? radioMetros = null,
    Object? original = freezed,
    Object? guardando = null,
    Object? error = freezed,
    Object? guardado = null,
  }) {
    return _then(_self.copyWith(
      centro: freezed == centro
          ? _self.centro
          : centro // ignore: cast_nullable_to_non_nullable
              as Ubicacion?,
      radioMetros: null == radioMetros
          ? _self.radioMetros
          : radioMetros // ignore: cast_nullable_to_non_nullable
              as int,
      original: freezed == original
          ? _self.original
          : original // ignore: cast_nullable_to_non_nullable
              as ZonaCobertura?,
      guardando: null == guardando
          ? _self.guardando
          : guardando // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      guardado: null == guardado
          ? _self.guardado
          : guardado // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of EstadoZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res>? get centro {
    if (_self.centro == null) {
      return null;
    }

    return $UbicacionCopyWith<$Res>(_self.centro!, (value) {
      return _then(_self.copyWith(centro: value));
    });
  }

  /// Create a copy of EstadoZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ZonaCoberturaCopyWith<$Res>? get original {
    if (_self.original == null) {
      return null;
    }

    return $ZonaCoberturaCopyWith<$Res>(_self.original!, (value) {
      return _then(_self.copyWith(original: value));
    });
  }
}

/// Adds pattern-matching-related methods to [EstadoZonaCobertura].
extension EstadoZonaCoberturaPatterns on EstadoZonaCobertura {
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
    TResult Function(_EstadoZonaCobertura value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoZonaCobertura() when $default != null:
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
    TResult Function(_EstadoZonaCobertura value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoZonaCobertura():
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
    TResult? Function(_EstadoZonaCobertura value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoZonaCobertura() when $default != null:
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
            Ubicacion? centro,
            int radioMetros,
            ZonaCobertura? original,
            bool guardando,
            String? error,
            bool guardado)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoZonaCobertura() when $default != null:
        return $default(_that.centro, _that.radioMetros, _that.original,
            _that.guardando, _that.error, _that.guardado);
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
            Ubicacion? centro,
            int radioMetros,
            ZonaCobertura? original,
            bool guardando,
            String? error,
            bool guardado)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoZonaCobertura():
        return $default(_that.centro, _that.radioMetros, _that.original,
            _that.guardando, _that.error, _that.guardado);
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
            Ubicacion? centro,
            int radioMetros,
            ZonaCobertura? original,
            bool guardando,
            String? error,
            bool guardado)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoZonaCobertura() when $default != null:
        return $default(_that.centro, _that.radioMetros, _that.original,
            _that.guardando, _that.error, _that.guardado);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoZonaCobertura extends EstadoZonaCobertura {
  const _EstadoZonaCobertura(
      {this.centro,
      this.radioMetros = ZonaCobertura.radioPorDefectoMetros,
      this.original,
      this.guardando = false,
      this.error,
      this.guardado = false})
      : super._();

  /// `null` mientras el Profesional no eligió un centro: es el estado de
  /// quien entra por primera vez.
  @override
  final Ubicacion? centro;
  @override
  @JsonKey()
  final int radioMetros;
  @override
  final ZonaCobertura? original;
  @override
  @JsonKey()
  final bool guardando;
  @override
  final String? error;

  /// Se levanta al guardar bien, para que la pantalla avise una sola vez.
  @override
  @JsonKey()
  final bool guardado;

  /// Create a copy of EstadoZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoZonaCoberturaCopyWith<_EstadoZonaCobertura> get copyWith =>
      __$EstadoZonaCoberturaCopyWithImpl<_EstadoZonaCobertura>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoZonaCobertura &&
            (identical(other.centro, centro) || other.centro == centro) &&
            (identical(other.radioMetros, radioMetros) ||
                other.radioMetros == radioMetros) &&
            (identical(other.original, original) ||
                other.original == original) &&
            (identical(other.guardando, guardando) ||
                other.guardando == guardando) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.guardado, guardado) ||
                other.guardado == guardado));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, centro, radioMetros, original, guardando, error, guardado);

  @override
  String toString() {
    return 'EstadoZonaCobertura(centro: $centro, radioMetros: $radioMetros, original: $original, guardando: $guardando, error: $error, guardado: $guardado)';
  }
}

/// @nodoc
abstract mixin class _$EstadoZonaCoberturaCopyWith<$Res>
    implements $EstadoZonaCoberturaCopyWith<$Res> {
  factory _$EstadoZonaCoberturaCopyWith(_EstadoZonaCobertura value,
          $Res Function(_EstadoZonaCobertura) _then) =
      __$EstadoZonaCoberturaCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Ubicacion? centro,
      int radioMetros,
      ZonaCobertura? original,
      bool guardando,
      String? error,
      bool guardado});

  @override
  $UbicacionCopyWith<$Res>? get centro;
  @override
  $ZonaCoberturaCopyWith<$Res>? get original;
}

/// @nodoc
class __$EstadoZonaCoberturaCopyWithImpl<$Res>
    implements _$EstadoZonaCoberturaCopyWith<$Res> {
  __$EstadoZonaCoberturaCopyWithImpl(this._self, this._then);

  final _EstadoZonaCobertura _self;
  final $Res Function(_EstadoZonaCobertura) _then;

  /// Create a copy of EstadoZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? centro = freezed,
    Object? radioMetros = null,
    Object? original = freezed,
    Object? guardando = null,
    Object? error = freezed,
    Object? guardado = null,
  }) {
    return _then(_EstadoZonaCobertura(
      centro: freezed == centro
          ? _self.centro
          : centro // ignore: cast_nullable_to_non_nullable
              as Ubicacion?,
      radioMetros: null == radioMetros
          ? _self.radioMetros
          : radioMetros // ignore: cast_nullable_to_non_nullable
              as int,
      original: freezed == original
          ? _self.original
          : original // ignore: cast_nullable_to_non_nullable
              as ZonaCobertura?,
      guardando: null == guardando
          ? _self.guardando
          : guardando // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      guardado: null == guardado
          ? _self.guardado
          : guardado // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of EstadoZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res>? get centro {
    if (_self.centro == null) {
      return null;
    }

    return $UbicacionCopyWith<$Res>(_self.centro!, (value) {
      return _then(_self.copyWith(centro: value));
    });
  }

  /// Create a copy of EstadoZonaCobertura
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ZonaCoberturaCopyWith<$Res>? get original {
    if (_self.original == null) {
      return null;
    }

    return $ZonaCoberturaCopyWith<$Res>(_self.original!, (value) {
      return _then(_self.copyWith(original: value));
    });
  }
}

// dart format on
