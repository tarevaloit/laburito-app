// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tablero_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoTablero {
  List<PedidoTablero> get pedidos;
  FiltroTablero get filtro;
  bool get cargandoMas;
  bool get hayMas;
  String? get error;

  /// Create a copy of EstadoTablero
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoTableroCopyWith<EstadoTablero> get copyWith =>
      _$EstadoTableroCopyWithImpl<EstadoTablero>(
          this as EstadoTablero, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoTablero &&
            const DeepCollectionEquality().equals(other.pedidos, pedidos) &&
            (identical(other.filtro, filtro) || other.filtro == filtro) &&
            (identical(other.cargandoMas, cargandoMas) ||
                other.cargandoMas == cargandoMas) &&
            (identical(other.hayMas, hayMas) || other.hayMas == hayMas) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(pedidos),
      filtro,
      cargandoMas,
      hayMas,
      error);

  @override
  String toString() {
    return 'EstadoTablero(pedidos: $pedidos, filtro: $filtro, cargandoMas: $cargandoMas, hayMas: $hayMas, error: $error)';
  }
}

/// @nodoc
abstract mixin class $EstadoTableroCopyWith<$Res> {
  factory $EstadoTableroCopyWith(
          EstadoTablero value, $Res Function(EstadoTablero) _then) =
      _$EstadoTableroCopyWithImpl;
  @useResult
  $Res call(
      {List<PedidoTablero> pedidos,
      FiltroTablero filtro,
      bool cargandoMas,
      bool hayMas,
      String? error});
}

/// @nodoc
class _$EstadoTableroCopyWithImpl<$Res>
    implements $EstadoTableroCopyWith<$Res> {
  _$EstadoTableroCopyWithImpl(this._self, this._then);

  final EstadoTablero _self;
  final $Res Function(EstadoTablero) _then;

  /// Create a copy of EstadoTablero
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pedidos = null,
    Object? filtro = null,
    Object? cargandoMas = null,
    Object? hayMas = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      pedidos: null == pedidos
          ? _self.pedidos
          : pedidos // ignore: cast_nullable_to_non_nullable
              as List<PedidoTablero>,
      filtro: null == filtro
          ? _self.filtro
          : filtro // ignore: cast_nullable_to_non_nullable
              as FiltroTablero,
      cargandoMas: null == cargandoMas
          ? _self.cargandoMas
          : cargandoMas // ignore: cast_nullable_to_non_nullable
              as bool,
      hayMas: null == hayMas
          ? _self.hayMas
          : hayMas // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EstadoTablero].
extension EstadoTableroPatterns on EstadoTablero {
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
    TResult Function(_EstadoTablero value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoTablero() when $default != null:
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
    TResult Function(_EstadoTablero value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoTablero():
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
    TResult? Function(_EstadoTablero value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoTablero() when $default != null:
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
    TResult Function(List<PedidoTablero> pedidos, FiltroTablero filtro,
            bool cargandoMas, bool hayMas, String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoTablero() when $default != null:
        return $default(_that.pedidos, _that.filtro, _that.cargandoMas,
            _that.hayMas, _that.error);
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
    TResult Function(List<PedidoTablero> pedidos, FiltroTablero filtro,
            bool cargandoMas, bool hayMas, String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoTablero():
        return $default(_that.pedidos, _that.filtro, _that.cargandoMas,
            _that.hayMas, _that.error);
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
    TResult? Function(List<PedidoTablero> pedidos, FiltroTablero filtro,
            bool cargandoMas, bool hayMas, String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoTablero() when $default != null:
        return $default(_that.pedidos, _that.filtro, _that.cargandoMas,
            _that.hayMas, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoTablero extends EstadoTablero {
  const _EstadoTablero(
      {final List<PedidoTablero> pedidos = const <PedidoTablero>[],
      this.filtro = FiltroTablero.misOficios,
      this.cargandoMas = false,
      this.hayMas = false,
      this.error})
      : _pedidos = pedidos,
        super._();

  final List<PedidoTablero> _pedidos;
  @override
  @JsonKey()
  List<PedidoTablero> get pedidos {
    if (_pedidos is EqualUnmodifiableListView) return _pedidos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pedidos);
  }

  @override
  @JsonKey()
  final FiltroTablero filtro;
  @override
  @JsonKey()
  final bool cargandoMas;
  @override
  @JsonKey()
  final bool hayMas;
  @override
  final String? error;

  /// Create a copy of EstadoTablero
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoTableroCopyWith<_EstadoTablero> get copyWith =>
      __$EstadoTableroCopyWithImpl<_EstadoTablero>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoTablero &&
            const DeepCollectionEquality().equals(other._pedidos, _pedidos) &&
            (identical(other.filtro, filtro) || other.filtro == filtro) &&
            (identical(other.cargandoMas, cargandoMas) ||
                other.cargandoMas == cargandoMas) &&
            (identical(other.hayMas, hayMas) || other.hayMas == hayMas) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_pedidos),
      filtro,
      cargandoMas,
      hayMas,
      error);

  @override
  String toString() {
    return 'EstadoTablero(pedidos: $pedidos, filtro: $filtro, cargandoMas: $cargandoMas, hayMas: $hayMas, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$EstadoTableroCopyWith<$Res>
    implements $EstadoTableroCopyWith<$Res> {
  factory _$EstadoTableroCopyWith(
          _EstadoTablero value, $Res Function(_EstadoTablero) _then) =
      __$EstadoTableroCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<PedidoTablero> pedidos,
      FiltroTablero filtro,
      bool cargandoMas,
      bool hayMas,
      String? error});
}

/// @nodoc
class __$EstadoTableroCopyWithImpl<$Res>
    implements _$EstadoTableroCopyWith<$Res> {
  __$EstadoTableroCopyWithImpl(this._self, this._then);

  final _EstadoTablero _self;
  final $Res Function(_EstadoTablero) _then;

  /// Create a copy of EstadoTablero
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pedidos = null,
    Object? filtro = null,
    Object? cargandoMas = null,
    Object? hayMas = null,
    Object? error = freezed,
  }) {
    return _then(_EstadoTablero(
      pedidos: null == pedidos
          ? _self._pedidos
          : pedidos // ignore: cast_nullable_to_non_nullable
              as List<PedidoTablero>,
      filtro: null == filtro
          ? _self.filtro
          : filtro // ignore: cast_nullable_to_non_nullable
              as FiltroTablero,
      cargandoMas: null == cargandoMas
          ? _self.cargandoMas
          : cargandoMas // ignore: cast_nullable_to_non_nullable
              as bool,
      hayMas: null == hayMas
          ? _self.hayMas
          : hayMas // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
