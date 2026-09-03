// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'historial_pedidos_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoHistorial {
  FiltroPedidos get filtro;
  String get busqueda;
  List<Pedido> get pedidos;

  /// Cuántos pedidos hay por estado. De acá salen los números de las
  /// pestañas, y no del largo de [pedidos], que es solo la página cargada.
  Map<PedidoEstado, int> get contadores;

  /// Hay una página en vuelo.
  bool get cargandoMas;

  /// La última página vino completa, así que puede haber más.
  bool get hayMas;
  PedidoException? get error;

  /// Create a copy of EstadoHistorial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoHistorialCopyWith<EstadoHistorial> get copyWith =>
      _$EstadoHistorialCopyWithImpl<EstadoHistorial>(
          this as EstadoHistorial, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoHistorial &&
            (identical(other.filtro, filtro) || other.filtro == filtro) &&
            (identical(other.busqueda, busqueda) ||
                other.busqueda == busqueda) &&
            const DeepCollectionEquality().equals(other.pedidos, pedidos) &&
            const DeepCollectionEquality()
                .equals(other.contadores, contadores) &&
            (identical(other.cargandoMas, cargandoMas) ||
                other.cargandoMas == cargandoMas) &&
            (identical(other.hayMas, hayMas) || other.hayMas == hayMas) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      filtro,
      busqueda,
      const DeepCollectionEquality().hash(pedidos),
      const DeepCollectionEquality().hash(contadores),
      cargandoMas,
      hayMas,
      error);

  @override
  String toString() {
    return 'EstadoHistorial(filtro: $filtro, busqueda: $busqueda, pedidos: $pedidos, contadores: $contadores, cargandoMas: $cargandoMas, hayMas: $hayMas, error: $error)';
  }
}

/// @nodoc
abstract mixin class $EstadoHistorialCopyWith<$Res> {
  factory $EstadoHistorialCopyWith(
          EstadoHistorial value, $Res Function(EstadoHistorial) _then) =
      _$EstadoHistorialCopyWithImpl;
  @useResult
  $Res call(
      {FiltroPedidos filtro,
      String busqueda,
      List<Pedido> pedidos,
      Map<PedidoEstado, int> contadores,
      bool cargandoMas,
      bool hayMas,
      PedidoException? error});
}

/// @nodoc
class _$EstadoHistorialCopyWithImpl<$Res>
    implements $EstadoHistorialCopyWith<$Res> {
  _$EstadoHistorialCopyWithImpl(this._self, this._then);

  final EstadoHistorial _self;
  final $Res Function(EstadoHistorial) _then;

  /// Create a copy of EstadoHistorial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filtro = null,
    Object? busqueda = null,
    Object? pedidos = null,
    Object? contadores = null,
    Object? cargandoMas = null,
    Object? hayMas = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      filtro: null == filtro
          ? _self.filtro
          : filtro // ignore: cast_nullable_to_non_nullable
              as FiltroPedidos,
      busqueda: null == busqueda
          ? _self.busqueda
          : busqueda // ignore: cast_nullable_to_non_nullable
              as String,
      pedidos: null == pedidos
          ? _self.pedidos
          : pedidos // ignore: cast_nullable_to_non_nullable
              as List<Pedido>,
      contadores: null == contadores
          ? _self.contadores
          : contadores // ignore: cast_nullable_to_non_nullable
              as Map<PedidoEstado, int>,
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
              as PedidoException?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EstadoHistorial].
extension EstadoHistorialPatterns on EstadoHistorial {
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
    TResult Function(_EstadoHistorial value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorial() when $default != null:
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
    TResult Function(_EstadoHistorial value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorial():
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
    TResult? Function(_EstadoHistorial value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorial() when $default != null:
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
            FiltroPedidos filtro,
            String busqueda,
            List<Pedido> pedidos,
            Map<PedidoEstado, int> contadores,
            bool cargandoMas,
            bool hayMas,
            PedidoException? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorial() when $default != null:
        return $default(_that.filtro, _that.busqueda, _that.pedidos,
            _that.contadores, _that.cargandoMas, _that.hayMas, _that.error);
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
            FiltroPedidos filtro,
            String busqueda,
            List<Pedido> pedidos,
            Map<PedidoEstado, int> contadores,
            bool cargandoMas,
            bool hayMas,
            PedidoException? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorial():
        return $default(_that.filtro, _that.busqueda, _that.pedidos,
            _that.contadores, _that.cargandoMas, _that.hayMas, _that.error);
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
            FiltroPedidos filtro,
            String busqueda,
            List<Pedido> pedidos,
            Map<PedidoEstado, int> contadores,
            bool cargandoMas,
            bool hayMas,
            PedidoException? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoHistorial() when $default != null:
        return $default(_that.filtro, _that.busqueda, _that.pedidos,
            _that.contadores, _that.cargandoMas, _that.hayMas, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoHistorial extends EstadoHistorial {
  const _EstadoHistorial(
      {this.filtro = FiltroPedidos.activos,
      this.busqueda = '',
      final List<Pedido> pedidos = const <Pedido>[],
      final Map<PedidoEstado, int> contadores = const <PedidoEstado, int>{},
      this.cargandoMas = false,
      this.hayMas = true,
      this.error})
      : _pedidos = pedidos,
        _contadores = contadores,
        super._();

  @override
  @JsonKey()
  final FiltroPedidos filtro;
  @override
  @JsonKey()
  final String busqueda;
  final List<Pedido> _pedidos;
  @override
  @JsonKey()
  List<Pedido> get pedidos {
    if (_pedidos is EqualUnmodifiableListView) return _pedidos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pedidos);
  }

  /// Cuántos pedidos hay por estado. De acá salen los números de las
  /// pestañas, y no del largo de [pedidos], que es solo la página cargada.
  final Map<PedidoEstado, int> _contadores;

  /// Cuántos pedidos hay por estado. De acá salen los números de las
  /// pestañas, y no del largo de [pedidos], que es solo la página cargada.
  @override
  @JsonKey()
  Map<PedidoEstado, int> get contadores {
    if (_contadores is EqualUnmodifiableMapView) return _contadores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_contadores);
  }

  /// Hay una página en vuelo.
  @override
  @JsonKey()
  final bool cargandoMas;

  /// La última página vino completa, así que puede haber más.
  @override
  @JsonKey()
  final bool hayMas;
  @override
  final PedidoException? error;

  /// Create a copy of EstadoHistorial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoHistorialCopyWith<_EstadoHistorial> get copyWith =>
      __$EstadoHistorialCopyWithImpl<_EstadoHistorial>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoHistorial &&
            (identical(other.filtro, filtro) || other.filtro == filtro) &&
            (identical(other.busqueda, busqueda) ||
                other.busqueda == busqueda) &&
            const DeepCollectionEquality().equals(other._pedidos, _pedidos) &&
            const DeepCollectionEquality()
                .equals(other._contadores, _contadores) &&
            (identical(other.cargandoMas, cargandoMas) ||
                other.cargandoMas == cargandoMas) &&
            (identical(other.hayMas, hayMas) || other.hayMas == hayMas) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      filtro,
      busqueda,
      const DeepCollectionEquality().hash(_pedidos),
      const DeepCollectionEquality().hash(_contadores),
      cargandoMas,
      hayMas,
      error);

  @override
  String toString() {
    return 'EstadoHistorial(filtro: $filtro, busqueda: $busqueda, pedidos: $pedidos, contadores: $contadores, cargandoMas: $cargandoMas, hayMas: $hayMas, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$EstadoHistorialCopyWith<$Res>
    implements $EstadoHistorialCopyWith<$Res> {
  factory _$EstadoHistorialCopyWith(
          _EstadoHistorial value, $Res Function(_EstadoHistorial) _then) =
      __$EstadoHistorialCopyWithImpl;
  @override
  @useResult
  $Res call(
      {FiltroPedidos filtro,
      String busqueda,
      List<Pedido> pedidos,
      Map<PedidoEstado, int> contadores,
      bool cargandoMas,
      bool hayMas,
      PedidoException? error});
}

/// @nodoc
class __$EstadoHistorialCopyWithImpl<$Res>
    implements _$EstadoHistorialCopyWith<$Res> {
  __$EstadoHistorialCopyWithImpl(this._self, this._then);

  final _EstadoHistorial _self;
  final $Res Function(_EstadoHistorial) _then;

  /// Create a copy of EstadoHistorial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? filtro = null,
    Object? busqueda = null,
    Object? pedidos = null,
    Object? contadores = null,
    Object? cargandoMas = null,
    Object? hayMas = null,
    Object? error = freezed,
  }) {
    return _then(_EstadoHistorial(
      filtro: null == filtro
          ? _self.filtro
          : filtro // ignore: cast_nullable_to_non_nullable
              as FiltroPedidos,
      busqueda: null == busqueda
          ? _self.busqueda
          : busqueda // ignore: cast_nullable_to_non_nullable
              as String,
      pedidos: null == pedidos
          ? _self._pedidos
          : pedidos // ignore: cast_nullable_to_non_nullable
              as List<Pedido>,
      contadores: null == contadores
          ? _self._contadores
          : contadores // ignore: cast_nullable_to_non_nullable
              as Map<PedidoEstado, int>,
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
              as PedidoException?,
    ));
  }
}

// dart format on
