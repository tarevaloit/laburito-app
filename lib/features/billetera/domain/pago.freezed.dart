// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pago.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pago {
  String get id;
  String get paqueteNombre;
  int get cantidadTokens;
  int get montoArs;
  EstadoPago get estado;
  DateTime get fecha;
  String? get metodoPago;
  String? get estadoDetalle;
  int? get numeroComprobante;
  DateTime? get aprobadoAt;

  /// Create a copy of Pago
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PagoCopyWith<Pago> get copyWith =>
      _$PagoCopyWithImpl<Pago>(this as Pago, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Pago &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.paqueteNombre, paqueteNombre) ||
                other.paqueteNombre == paqueteNombre) &&
            (identical(other.cantidadTokens, cantidadTokens) ||
                other.cantidadTokens == cantidadTokens) &&
            (identical(other.montoArs, montoArs) ||
                other.montoArs == montoArs) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.fecha, fecha) || other.fecha == fecha) &&
            (identical(other.metodoPago, metodoPago) ||
                other.metodoPago == metodoPago) &&
            (identical(other.estadoDetalle, estadoDetalle) ||
                other.estadoDetalle == estadoDetalle) &&
            (identical(other.numeroComprobante, numeroComprobante) ||
                other.numeroComprobante == numeroComprobante) &&
            (identical(other.aprobadoAt, aprobadoAt) ||
                other.aprobadoAt == aprobadoAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      paqueteNombre,
      cantidadTokens,
      montoArs,
      estado,
      fecha,
      metodoPago,
      estadoDetalle,
      numeroComprobante,
      aprobadoAt);

  @override
  String toString() {
    return 'Pago(id: $id, paqueteNombre: $paqueteNombre, cantidadTokens: $cantidadTokens, montoArs: $montoArs, estado: $estado, fecha: $fecha, metodoPago: $metodoPago, estadoDetalle: $estadoDetalle, numeroComprobante: $numeroComprobante, aprobadoAt: $aprobadoAt)';
  }
}

/// @nodoc
abstract mixin class $PagoCopyWith<$Res> {
  factory $PagoCopyWith(Pago value, $Res Function(Pago) _then) =
      _$PagoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String paqueteNombre,
      int cantidadTokens,
      int montoArs,
      EstadoPago estado,
      DateTime fecha,
      String? metodoPago,
      String? estadoDetalle,
      int? numeroComprobante,
      DateTime? aprobadoAt});
}

/// @nodoc
class _$PagoCopyWithImpl<$Res> implements $PagoCopyWith<$Res> {
  _$PagoCopyWithImpl(this._self, this._then);

  final Pago _self;
  final $Res Function(Pago) _then;

  /// Create a copy of Pago
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? paqueteNombre = null,
    Object? cantidadTokens = null,
    Object? montoArs = null,
    Object? estado = null,
    Object? fecha = null,
    Object? metodoPago = freezed,
    Object? estadoDetalle = freezed,
    Object? numeroComprobante = freezed,
    Object? aprobadoAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      paqueteNombre: null == paqueteNombre
          ? _self.paqueteNombre
          : paqueteNombre // ignore: cast_nullable_to_non_nullable
              as String,
      cantidadTokens: null == cantidadTokens
          ? _self.cantidadTokens
          : cantidadTokens // ignore: cast_nullable_to_non_nullable
              as int,
      montoArs: null == montoArs
          ? _self.montoArs
          : montoArs // ignore: cast_nullable_to_non_nullable
              as int,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoPago,
      fecha: null == fecha
          ? _self.fecha
          : fecha // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metodoPago: freezed == metodoPago
          ? _self.metodoPago
          : metodoPago // ignore: cast_nullable_to_non_nullable
              as String?,
      estadoDetalle: freezed == estadoDetalle
          ? _self.estadoDetalle
          : estadoDetalle // ignore: cast_nullable_to_non_nullable
              as String?,
      numeroComprobante: freezed == numeroComprobante
          ? _self.numeroComprobante
          : numeroComprobante // ignore: cast_nullable_to_non_nullable
              as int?,
      aprobadoAt: freezed == aprobadoAt
          ? _self.aprobadoAt
          : aprobadoAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Pago].
extension PagoPatterns on Pago {
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
    TResult Function(_Pago value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Pago() when $default != null:
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
    TResult Function(_Pago value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pago():
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
    TResult? Function(_Pago value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pago() when $default != null:
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
            String id,
            String paqueteNombre,
            int cantidadTokens,
            int montoArs,
            EstadoPago estado,
            DateTime fecha,
            String? metodoPago,
            String? estadoDetalle,
            int? numeroComprobante,
            DateTime? aprobadoAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Pago() when $default != null:
        return $default(
            _that.id,
            _that.paqueteNombre,
            _that.cantidadTokens,
            _that.montoArs,
            _that.estado,
            _that.fecha,
            _that.metodoPago,
            _that.estadoDetalle,
            _that.numeroComprobante,
            _that.aprobadoAt);
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
            String id,
            String paqueteNombre,
            int cantidadTokens,
            int montoArs,
            EstadoPago estado,
            DateTime fecha,
            String? metodoPago,
            String? estadoDetalle,
            int? numeroComprobante,
            DateTime? aprobadoAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pago():
        return $default(
            _that.id,
            _that.paqueteNombre,
            _that.cantidadTokens,
            _that.montoArs,
            _that.estado,
            _that.fecha,
            _that.metodoPago,
            _that.estadoDetalle,
            _that.numeroComprobante,
            _that.aprobadoAt);
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
            String id,
            String paqueteNombre,
            int cantidadTokens,
            int montoArs,
            EstadoPago estado,
            DateTime fecha,
            String? metodoPago,
            String? estadoDetalle,
            int? numeroComprobante,
            DateTime? aprobadoAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pago() when $default != null:
        return $default(
            _that.id,
            _that.paqueteNombre,
            _that.cantidadTokens,
            _that.montoArs,
            _that.estado,
            _that.fecha,
            _that.metodoPago,
            _that.estadoDetalle,
            _that.numeroComprobante,
            _that.aprobadoAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Pago extends Pago {
  const _Pago(
      {required this.id,
      required this.paqueteNombre,
      required this.cantidadTokens,
      required this.montoArs,
      required this.estado,
      required this.fecha,
      this.metodoPago,
      this.estadoDetalle,
      this.numeroComprobante,
      this.aprobadoAt})
      : super._();

  @override
  final String id;
  @override
  final String paqueteNombre;
  @override
  final int cantidadTokens;
  @override
  final int montoArs;
  @override
  final EstadoPago estado;
  @override
  final DateTime fecha;
  @override
  final String? metodoPago;
  @override
  final String? estadoDetalle;
  @override
  final int? numeroComprobante;
  @override
  final DateTime? aprobadoAt;

  /// Create a copy of Pago
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PagoCopyWith<_Pago> get copyWith =>
      __$PagoCopyWithImpl<_Pago>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Pago &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.paqueteNombre, paqueteNombre) ||
                other.paqueteNombre == paqueteNombre) &&
            (identical(other.cantidadTokens, cantidadTokens) ||
                other.cantidadTokens == cantidadTokens) &&
            (identical(other.montoArs, montoArs) ||
                other.montoArs == montoArs) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.fecha, fecha) || other.fecha == fecha) &&
            (identical(other.metodoPago, metodoPago) ||
                other.metodoPago == metodoPago) &&
            (identical(other.estadoDetalle, estadoDetalle) ||
                other.estadoDetalle == estadoDetalle) &&
            (identical(other.numeroComprobante, numeroComprobante) ||
                other.numeroComprobante == numeroComprobante) &&
            (identical(other.aprobadoAt, aprobadoAt) ||
                other.aprobadoAt == aprobadoAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      paqueteNombre,
      cantidadTokens,
      montoArs,
      estado,
      fecha,
      metodoPago,
      estadoDetalle,
      numeroComprobante,
      aprobadoAt);

  @override
  String toString() {
    return 'Pago(id: $id, paqueteNombre: $paqueteNombre, cantidadTokens: $cantidadTokens, montoArs: $montoArs, estado: $estado, fecha: $fecha, metodoPago: $metodoPago, estadoDetalle: $estadoDetalle, numeroComprobante: $numeroComprobante, aprobadoAt: $aprobadoAt)';
  }
}

/// @nodoc
abstract mixin class _$PagoCopyWith<$Res> implements $PagoCopyWith<$Res> {
  factory _$PagoCopyWith(_Pago value, $Res Function(_Pago) _then) =
      __$PagoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String paqueteNombre,
      int cantidadTokens,
      int montoArs,
      EstadoPago estado,
      DateTime fecha,
      String? metodoPago,
      String? estadoDetalle,
      int? numeroComprobante,
      DateTime? aprobadoAt});
}

/// @nodoc
class __$PagoCopyWithImpl<$Res> implements _$PagoCopyWith<$Res> {
  __$PagoCopyWithImpl(this._self, this._then);

  final _Pago _self;
  final $Res Function(_Pago) _then;

  /// Create a copy of Pago
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? paqueteNombre = null,
    Object? cantidadTokens = null,
    Object? montoArs = null,
    Object? estado = null,
    Object? fecha = null,
    Object? metodoPago = freezed,
    Object? estadoDetalle = freezed,
    Object? numeroComprobante = freezed,
    Object? aprobadoAt = freezed,
  }) {
    return _then(_Pago(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      paqueteNombre: null == paqueteNombre
          ? _self.paqueteNombre
          : paqueteNombre // ignore: cast_nullable_to_non_nullable
              as String,
      cantidadTokens: null == cantidadTokens
          ? _self.cantidadTokens
          : cantidadTokens // ignore: cast_nullable_to_non_nullable
              as int,
      montoArs: null == montoArs
          ? _self.montoArs
          : montoArs // ignore: cast_nullable_to_non_nullable
              as int,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoPago,
      fecha: null == fecha
          ? _self.fecha
          : fecha // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metodoPago: freezed == metodoPago
          ? _self.metodoPago
          : metodoPago // ignore: cast_nullable_to_non_nullable
              as String?,
      estadoDetalle: freezed == estadoDetalle
          ? _self.estadoDetalle
          : estadoDetalle // ignore: cast_nullable_to_non_nullable
              as String?,
      numeroComprobante: freezed == numeroComprobante
          ? _self.numeroComprobante
          : numeroComprobante // ignore: cast_nullable_to_non_nullable
              as int?,
      aprobadoAt: freezed == aprobadoAt
          ? _self.aprobadoAt
          : aprobadoAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
