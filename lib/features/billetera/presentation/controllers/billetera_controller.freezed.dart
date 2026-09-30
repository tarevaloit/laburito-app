// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billetera_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoBilletera {
  int get saldo;
  List<MovimientoTokens> get movimientos;
  List<PaqueteTokens> get paquetes;

  /// La última recarga falló y lo que se muestra es lo anterior (flujo
  /// alterno del CU-30: «último saldo almacenado, con la advertencia Sin
  /// conexión»).
  bool get sinConexion;

  /// Create a copy of EstadoBilletera
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoBilleteraCopyWith<EstadoBilletera> get copyWith =>
      _$EstadoBilleteraCopyWithImpl<EstadoBilletera>(
          this as EstadoBilletera, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoBilletera &&
            (identical(other.saldo, saldo) || other.saldo == saldo) &&
            const DeepCollectionEquality()
                .equals(other.movimientos, movimientos) &&
            const DeepCollectionEquality().equals(other.paquetes, paquetes) &&
            (identical(other.sinConexion, sinConexion) ||
                other.sinConexion == sinConexion));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      saldo,
      const DeepCollectionEquality().hash(movimientos),
      const DeepCollectionEquality().hash(paquetes),
      sinConexion);

  @override
  String toString() {
    return 'EstadoBilletera(saldo: $saldo, movimientos: $movimientos, paquetes: $paquetes, sinConexion: $sinConexion)';
  }
}

/// @nodoc
abstract mixin class $EstadoBilleteraCopyWith<$Res> {
  factory $EstadoBilleteraCopyWith(
          EstadoBilletera value, $Res Function(EstadoBilletera) _then) =
      _$EstadoBilleteraCopyWithImpl;
  @useResult
  $Res call(
      {int saldo,
      List<MovimientoTokens> movimientos,
      List<PaqueteTokens> paquetes,
      bool sinConexion});
}

/// @nodoc
class _$EstadoBilleteraCopyWithImpl<$Res>
    implements $EstadoBilleteraCopyWith<$Res> {
  _$EstadoBilleteraCopyWithImpl(this._self, this._then);

  final EstadoBilletera _self;
  final $Res Function(EstadoBilletera) _then;

  /// Create a copy of EstadoBilletera
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? saldo = null,
    Object? movimientos = null,
    Object? paquetes = null,
    Object? sinConexion = null,
  }) {
    return _then(_self.copyWith(
      saldo: null == saldo
          ? _self.saldo
          : saldo // ignore: cast_nullable_to_non_nullable
              as int,
      movimientos: null == movimientos
          ? _self.movimientos
          : movimientos // ignore: cast_nullable_to_non_nullable
              as List<MovimientoTokens>,
      paquetes: null == paquetes
          ? _self.paquetes
          : paquetes // ignore: cast_nullable_to_non_nullable
              as List<PaqueteTokens>,
      sinConexion: null == sinConexion
          ? _self.sinConexion
          : sinConexion // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [EstadoBilletera].
extension EstadoBilleteraPatterns on EstadoBilletera {
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
    TResult Function(_EstadoBilletera value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoBilletera() when $default != null:
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
    TResult Function(_EstadoBilletera value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoBilletera():
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
    TResult? Function(_EstadoBilletera value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoBilletera() when $default != null:
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
    TResult Function(int saldo, List<MovimientoTokens> movimientos,
            List<PaqueteTokens> paquetes, bool sinConexion)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoBilletera() when $default != null:
        return $default(
            _that.saldo, _that.movimientos, _that.paquetes, _that.sinConexion);
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
    TResult Function(int saldo, List<MovimientoTokens> movimientos,
            List<PaqueteTokens> paquetes, bool sinConexion)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoBilletera():
        return $default(
            _that.saldo, _that.movimientos, _that.paquetes, _that.sinConexion);
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
    TResult? Function(int saldo, List<MovimientoTokens> movimientos,
            List<PaqueteTokens> paquetes, bool sinConexion)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoBilletera() when $default != null:
        return $default(
            _that.saldo, _that.movimientos, _that.paquetes, _that.sinConexion);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoBilletera extends EstadoBilletera {
  const _EstadoBilletera(
      {required this.saldo,
      final List<MovimientoTokens> movimientos = const <MovimientoTokens>[],
      final List<PaqueteTokens> paquetes = const <PaqueteTokens>[],
      this.sinConexion = false})
      : _movimientos = movimientos,
        _paquetes = paquetes,
        super._();

  @override
  final int saldo;
  final List<MovimientoTokens> _movimientos;
  @override
  @JsonKey()
  List<MovimientoTokens> get movimientos {
    if (_movimientos is EqualUnmodifiableListView) return _movimientos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_movimientos);
  }

  final List<PaqueteTokens> _paquetes;
  @override
  @JsonKey()
  List<PaqueteTokens> get paquetes {
    if (_paquetes is EqualUnmodifiableListView) return _paquetes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paquetes);
  }

  /// La última recarga falló y lo que se muestra es lo anterior (flujo
  /// alterno del CU-30: «último saldo almacenado, con la advertencia Sin
  /// conexión»).
  @override
  @JsonKey()
  final bool sinConexion;

  /// Create a copy of EstadoBilletera
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoBilleteraCopyWith<_EstadoBilletera> get copyWith =>
      __$EstadoBilleteraCopyWithImpl<_EstadoBilletera>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoBilletera &&
            (identical(other.saldo, saldo) || other.saldo == saldo) &&
            const DeepCollectionEquality()
                .equals(other._movimientos, _movimientos) &&
            const DeepCollectionEquality().equals(other._paquetes, _paquetes) &&
            (identical(other.sinConexion, sinConexion) ||
                other.sinConexion == sinConexion));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      saldo,
      const DeepCollectionEquality().hash(_movimientos),
      const DeepCollectionEquality().hash(_paquetes),
      sinConexion);

  @override
  String toString() {
    return 'EstadoBilletera(saldo: $saldo, movimientos: $movimientos, paquetes: $paquetes, sinConexion: $sinConexion)';
  }
}

/// @nodoc
abstract mixin class _$EstadoBilleteraCopyWith<$Res>
    implements $EstadoBilleteraCopyWith<$Res> {
  factory _$EstadoBilleteraCopyWith(
          _EstadoBilletera value, $Res Function(_EstadoBilletera) _then) =
      __$EstadoBilleteraCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int saldo,
      List<MovimientoTokens> movimientos,
      List<PaqueteTokens> paquetes,
      bool sinConexion});
}

/// @nodoc
class __$EstadoBilleteraCopyWithImpl<$Res>
    implements _$EstadoBilleteraCopyWith<$Res> {
  __$EstadoBilleteraCopyWithImpl(this._self, this._then);

  final _EstadoBilletera _self;
  final $Res Function(_EstadoBilletera) _then;

  /// Create a copy of EstadoBilletera
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? saldo = null,
    Object? movimientos = null,
    Object? paquetes = null,
    Object? sinConexion = null,
  }) {
    return _then(_EstadoBilletera(
      saldo: null == saldo
          ? _self.saldo
          : saldo // ignore: cast_nullable_to_non_nullable
              as int,
      movimientos: null == movimientos
          ? _self._movimientos
          : movimientos // ignore: cast_nullable_to_non_nullable
              as List<MovimientoTokens>,
      paquetes: null == paquetes
          ? _self._paquetes
          : paquetes // ignore: cast_nullable_to_non_nullable
              as List<PaqueteTokens>,
      sinConexion: null == sinConexion
          ? _self.sinConexion
          : sinConexion // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$EstadoHistorialPagos {
  List<Pago> get pagos;
  bool get cargandoMas;
  bool get hayMas;

  /// Create a copy of EstadoHistorialPagos
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoHistorialPagosCopyWith<EstadoHistorialPagos> get copyWith =>
      _$EstadoHistorialPagosCopyWithImpl<EstadoHistorialPagos>(
          this as EstadoHistorialPagos, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoHistorialPagos &&
            const DeepCollectionEquality().equals(other.pagos, pagos) &&
            (identical(other.cargandoMas, cargandoMas) ||
                other.cargandoMas == cargandoMas) &&
            (identical(other.hayMas, hayMas) || other.hayMas == hayMas));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(pagos), cargandoMas, hayMas);

  @override
  String toString() {
    return 'EstadoHistorialPagos(pagos: $pagos, cargandoMas: $cargandoMas, hayMas: $hayMas)';
  }
}

/// @nodoc
abstract mixin class $EstadoHistorialPagosCopyWith<$Res> {
  factory $EstadoHistorialPagosCopyWith(EstadoHistorialPagos value,
          $Res Function(EstadoHistorialPagos) _then) =
      _$EstadoHistorialPagosCopyWithImpl;
  @useResult
  $Res call({List<Pago> pagos, bool cargandoMas, bool hayMas});
}

/// @nodoc
class _$EstadoHistorialPagosCopyWithImpl<$Res>
    implements $EstadoHistorialPagosCopyWith<$Res> {
  _$EstadoHistorialPagosCopyWithImpl(this._self, this._then);

  final EstadoHistorialPagos _self;
  final $Res Function(EstadoHistorialPagos) _then;

  /// Create a copy of EstadoHistorialPagos
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pagos = null,
    Object? cargandoMas = null,
    Object? hayMas = null,
  }) {
    return _then(_self.copyWith(
      pagos: null == pagos
          ? _self.pagos
          : pagos // ignore: cast_nullable_to_non_nullable
              as List<Pago>,
      cargandoMas: null == cargandoMas
          ? _self.cargandoMas
          : cargandoMas // ignore: cast_nullable_to_non_nullable
              as bool,
      hayMas: null == hayMas
          ? _self.hayMas
          : hayMas // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [EstadoHistorialPagos].
extension EstadoHistorialPagosPatterns on EstadoHistorialPagos {
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
    TResult Function(_EstadoHistorialPagos value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorialPagos() when $default != null:
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
    TResult Function(_EstadoHistorialPagos value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorialPagos():
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
    TResult? Function(_EstadoHistorialPagos value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorialPagos() when $default != null:
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
    TResult Function(List<Pago> pagos, bool cargandoMas, bool hayMas)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorialPagos() when $default != null:
        return $default(_that.pagos, _that.cargandoMas, _that.hayMas);
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
    TResult Function(List<Pago> pagos, bool cargandoMas, bool hayMas) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorialPagos():
        return $default(_that.pagos, _that.cargandoMas, _that.hayMas);
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
    TResult? Function(List<Pago> pagos, bool cargandoMas, bool hayMas)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorialPagos() when $default != null:
        return $default(_that.pagos, _that.cargandoMas, _that.hayMas);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoHistorialPagos implements EstadoHistorialPagos {
  const _EstadoHistorialPagos(
      {final List<Pago> pagos = const <Pago>[],
      this.cargandoMas = false,
      this.hayMas = true})
      : _pagos = pagos;

  final List<Pago> _pagos;
  @override
  @JsonKey()
  List<Pago> get pagos {
    if (_pagos is EqualUnmodifiableListView) return _pagos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pagos);
  }

  @override
  @JsonKey()
  final bool cargandoMas;
  @override
  @JsonKey()
  final bool hayMas;

  /// Create a copy of EstadoHistorialPagos
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoHistorialPagosCopyWith<_EstadoHistorialPagos> get copyWith =>
      __$EstadoHistorialPagosCopyWithImpl<_EstadoHistorialPagos>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoHistorialPagos &&
            const DeepCollectionEquality().equals(other._pagos, _pagos) &&
            (identical(other.cargandoMas, cargandoMas) ||
                other.cargandoMas == cargandoMas) &&
            (identical(other.hayMas, hayMas) || other.hayMas == hayMas));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_pagos), cargandoMas, hayMas);

  @override
  String toString() {
    return 'EstadoHistorialPagos(pagos: $pagos, cargandoMas: $cargandoMas, hayMas: $hayMas)';
  }
}

/// @nodoc
abstract mixin class _$EstadoHistorialPagosCopyWith<$Res>
    implements $EstadoHistorialPagosCopyWith<$Res> {
  factory _$EstadoHistorialPagosCopyWith(_EstadoHistorialPagos value,
          $Res Function(_EstadoHistorialPagos) _then) =
      __$EstadoHistorialPagosCopyWithImpl;
  @override
  @useResult
  $Res call({List<Pago> pagos, bool cargandoMas, bool hayMas});
}

/// @nodoc
class __$EstadoHistorialPagosCopyWithImpl<$Res>
    implements _$EstadoHistorialPagosCopyWith<$Res> {
  __$EstadoHistorialPagosCopyWithImpl(this._self, this._then);

  final _EstadoHistorialPagos _self;
  final $Res Function(_EstadoHistorialPagos) _then;

  /// Create a copy of EstadoHistorialPagos
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pagos = null,
    Object? cargandoMas = null,
    Object? hayMas = null,
  }) {
    return _then(_EstadoHistorialPagos(
      pagos: null == pagos
          ? _self._pagos
          : pagos // ignore: cast_nullable_to_non_nullable
              as List<Pago>,
      cargandoMas: null == cargandoMas
          ? _self.cargandoMas
          : cargandoMas // ignore: cast_nullable_to_non_nullable
              as bool,
      hayMas: null == hayMas
          ? _self.hayMas
          : hayMas // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
