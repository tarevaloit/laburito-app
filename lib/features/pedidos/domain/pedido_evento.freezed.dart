// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido_evento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PedidoEvento {
  String get id;
  String get pedidoId;

  /// Nulo si el evento no tuvo estado previo.
  PedidoEstado? get estadoAnterior;
  PedidoEstado get estadoNuevo;

  /// Quién lo provocó, de `auth.uid()`. Nulo cuando lo hizo un proceso del
  /// servidor, como el barrido de vencimientos bajo pg_cron.
  String? get actorId;
  String? get motivo;
  DateTime get createdAt;

  /// Create a copy of PedidoEvento
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PedidoEventoCopyWith<PedidoEvento> get copyWith =>
      _$PedidoEventoCopyWithImpl<PedidoEvento>(
          this as PedidoEvento, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PedidoEvento &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.estadoAnterior, estadoAnterior) ||
                other.estadoAnterior == estadoAnterior) &&
            (identical(other.estadoNuevo, estadoNuevo) ||
                other.estadoNuevo == estadoNuevo) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.motivo, motivo) || other.motivo == motivo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pedidoId, estadoAnterior,
      estadoNuevo, actorId, motivo, createdAt);

  @override
  String toString() {
    return 'PedidoEvento(id: $id, pedidoId: $pedidoId, estadoAnterior: $estadoAnterior, estadoNuevo: $estadoNuevo, actorId: $actorId, motivo: $motivo, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $PedidoEventoCopyWith<$Res> {
  factory $PedidoEventoCopyWith(
          PedidoEvento value, $Res Function(PedidoEvento) _then) =
      _$PedidoEventoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String pedidoId,
      PedidoEstado? estadoAnterior,
      PedidoEstado estadoNuevo,
      String? actorId,
      String? motivo,
      DateTime createdAt});
}

/// @nodoc
class _$PedidoEventoCopyWithImpl<$Res> implements $PedidoEventoCopyWith<$Res> {
  _$PedidoEventoCopyWithImpl(this._self, this._then);

  final PedidoEvento _self;
  final $Res Function(PedidoEvento) _then;

  /// Create a copy of PedidoEvento
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pedidoId = null,
    Object? estadoAnterior = freezed,
    Object? estadoNuevo = null,
    Object? actorId = freezed,
    Object? motivo = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pedidoId: null == pedidoId
          ? _self.pedidoId
          : pedidoId // ignore: cast_nullable_to_non_nullable
              as String,
      estadoAnterior: freezed == estadoAnterior
          ? _self.estadoAnterior
          : estadoAnterior // ignore: cast_nullable_to_non_nullable
              as PedidoEstado?,
      estadoNuevo: null == estadoNuevo
          ? _self.estadoNuevo
          : estadoNuevo // ignore: cast_nullable_to_non_nullable
              as PedidoEstado,
      actorId: freezed == actorId
          ? _self.actorId
          : actorId // ignore: cast_nullable_to_non_nullable
              as String?,
      motivo: freezed == motivo
          ? _self.motivo
          : motivo // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [PedidoEvento].
extension PedidoEventoPatterns on PedidoEvento {
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
    TResult Function(_PedidoEvento value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PedidoEvento() when $default != null:
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
    TResult Function(_PedidoEvento value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoEvento():
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
    TResult? Function(_PedidoEvento value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoEvento() when $default != null:
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
            String pedidoId,
            PedidoEstado? estadoAnterior,
            PedidoEstado estadoNuevo,
            String? actorId,
            String? motivo,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PedidoEvento() when $default != null:
        return $default(_that.id, _that.pedidoId, _that.estadoAnterior,
            _that.estadoNuevo, _that.actorId, _that.motivo, _that.createdAt);
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
            String pedidoId,
            PedidoEstado? estadoAnterior,
            PedidoEstado estadoNuevo,
            String? actorId,
            String? motivo,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoEvento():
        return $default(_that.id, _that.pedidoId, _that.estadoAnterior,
            _that.estadoNuevo, _that.actorId, _that.motivo, _that.createdAt);
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
            String pedidoId,
            PedidoEstado? estadoAnterior,
            PedidoEstado estadoNuevo,
            String? actorId,
            String? motivo,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoEvento() when $default != null:
        return $default(_that.id, _that.pedidoId, _that.estadoAnterior,
            _that.estadoNuevo, _that.actorId, _that.motivo, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PedidoEvento extends PedidoEvento {
  const _PedidoEvento(
      {required this.id,
      required this.pedidoId,
      this.estadoAnterior,
      required this.estadoNuevo,
      this.actorId,
      this.motivo,
      required this.createdAt})
      : super._();

  @override
  final String id;
  @override
  final String pedidoId;

  /// Nulo si el evento no tuvo estado previo.
  @override
  final PedidoEstado? estadoAnterior;
  @override
  final PedidoEstado estadoNuevo;

  /// Quién lo provocó, de `auth.uid()`. Nulo cuando lo hizo un proceso del
  /// servidor, como el barrido de vencimientos bajo pg_cron.
  @override
  final String? actorId;
  @override
  final String? motivo;
  @override
  final DateTime createdAt;

  /// Create a copy of PedidoEvento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PedidoEventoCopyWith<_PedidoEvento> get copyWith =>
      __$PedidoEventoCopyWithImpl<_PedidoEvento>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PedidoEvento &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.estadoAnterior, estadoAnterior) ||
                other.estadoAnterior == estadoAnterior) &&
            (identical(other.estadoNuevo, estadoNuevo) ||
                other.estadoNuevo == estadoNuevo) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.motivo, motivo) || other.motivo == motivo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, pedidoId, estadoAnterior,
      estadoNuevo, actorId, motivo, createdAt);

  @override
  String toString() {
    return 'PedidoEvento(id: $id, pedidoId: $pedidoId, estadoAnterior: $estadoAnterior, estadoNuevo: $estadoNuevo, actorId: $actorId, motivo: $motivo, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$PedidoEventoCopyWith<$Res>
    implements $PedidoEventoCopyWith<$Res> {
  factory _$PedidoEventoCopyWith(
          _PedidoEvento value, $Res Function(_PedidoEvento) _then) =
      __$PedidoEventoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String pedidoId,
      PedidoEstado? estadoAnterior,
      PedidoEstado estadoNuevo,
      String? actorId,
      String? motivo,
      DateTime createdAt});
}

/// @nodoc
class __$PedidoEventoCopyWithImpl<$Res>
    implements _$PedidoEventoCopyWith<$Res> {
  __$PedidoEventoCopyWithImpl(this._self, this._then);

  final _PedidoEvento _self;
  final $Res Function(_PedidoEvento) _then;

  /// Create a copy of PedidoEvento
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? pedidoId = null,
    Object? estadoAnterior = freezed,
    Object? estadoNuevo = null,
    Object? actorId = freezed,
    Object? motivo = freezed,
    Object? createdAt = null,
  }) {
    return _then(_PedidoEvento(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pedidoId: null == pedidoId
          ? _self.pedidoId
          : pedidoId // ignore: cast_nullable_to_non_nullable
              as String,
      estadoAnterior: freezed == estadoAnterior
          ? _self.estadoAnterior
          : estadoAnterior // ignore: cast_nullable_to_non_nullable
              as PedidoEstado?,
      estadoNuevo: null == estadoNuevo
          ? _self.estadoNuevo
          : estadoNuevo // ignore: cast_nullable_to_non_nullable
              as PedidoEstado,
      actorId: freezed == actorId
          ? _self.actorId
          : actorId // ignore: cast_nullable_to_non_nullable
              as String?,
      motivo: freezed == motivo
          ? _self.motivo
          : motivo // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
