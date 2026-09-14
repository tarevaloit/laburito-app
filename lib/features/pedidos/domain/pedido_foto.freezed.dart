// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido_foto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PedidoFoto {
  String get id;
  String get pedidoId;
  String get storagePath;

  /// Posición en la galería, 0 = portada. Único por pedido.
  int get orden;
  DateTime get createdAt;

  /// Create a copy of PedidoFoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PedidoFotoCopyWith<PedidoFoto> get copyWith =>
      _$PedidoFotoCopyWithImpl<PedidoFoto>(this as PedidoFoto, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PedidoFoto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.orden, orden) || other.orden == orden) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, pedidoId, storagePath, orden, createdAt);

  @override
  String toString() {
    return 'PedidoFoto(id: $id, pedidoId: $pedidoId, storagePath: $storagePath, orden: $orden, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $PedidoFotoCopyWith<$Res> {
  factory $PedidoFotoCopyWith(
          PedidoFoto value, $Res Function(PedidoFoto) _then) =
      _$PedidoFotoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String pedidoId,
      String storagePath,
      int orden,
      DateTime createdAt});
}

/// @nodoc
class _$PedidoFotoCopyWithImpl<$Res> implements $PedidoFotoCopyWith<$Res> {
  _$PedidoFotoCopyWithImpl(this._self, this._then);

  final PedidoFoto _self;
  final $Res Function(PedidoFoto) _then;

  /// Create a copy of PedidoFoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pedidoId = null,
    Object? storagePath = null,
    Object? orden = null,
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
      storagePath: null == storagePath
          ? _self.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      orden: null == orden
          ? _self.orden
          : orden // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [PedidoFoto].
extension PedidoFotoPatterns on PedidoFoto {
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
    TResult Function(_PedidoFoto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PedidoFoto() when $default != null:
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
    TResult Function(_PedidoFoto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoFoto():
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
    TResult? Function(_PedidoFoto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoFoto() when $default != null:
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
    TResult Function(String id, String pedidoId, String storagePath, int orden,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PedidoFoto() when $default != null:
        return $default(_that.id, _that.pedidoId, _that.storagePath,
            _that.orden, _that.createdAt);
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
    TResult Function(String id, String pedidoId, String storagePath, int orden,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoFoto():
        return $default(_that.id, _that.pedidoId, _that.storagePath,
            _that.orden, _that.createdAt);
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
    TResult? Function(String id, String pedidoId, String storagePath, int orden,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoFoto() when $default != null:
        return $default(_that.id, _that.pedidoId, _that.storagePath,
            _that.orden, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PedidoFoto extends PedidoFoto {
  const _PedidoFoto(
      {required this.id,
      required this.pedidoId,
      required this.storagePath,
      required this.orden,
      required this.createdAt})
      : super._();

  @override
  final String id;
  @override
  final String pedidoId;
  @override
  final String storagePath;

  /// Posición en la galería, 0 = portada. Único por pedido.
  @override
  final int orden;
  @override
  final DateTime createdAt;

  /// Create a copy of PedidoFoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PedidoFotoCopyWith<_PedidoFoto> get copyWith =>
      __$PedidoFotoCopyWithImpl<_PedidoFoto>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PedidoFoto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.orden, orden) || other.orden == orden) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, pedidoId, storagePath, orden, createdAt);

  @override
  String toString() {
    return 'PedidoFoto(id: $id, pedidoId: $pedidoId, storagePath: $storagePath, orden: $orden, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$PedidoFotoCopyWith<$Res>
    implements $PedidoFotoCopyWith<$Res> {
  factory _$PedidoFotoCopyWith(
          _PedidoFoto value, $Res Function(_PedidoFoto) _then) =
      __$PedidoFotoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String pedidoId,
      String storagePath,
      int orden,
      DateTime createdAt});
}

/// @nodoc
class __$PedidoFotoCopyWithImpl<$Res> implements _$PedidoFotoCopyWith<$Res> {
  __$PedidoFotoCopyWithImpl(this._self, this._then);

  final _PedidoFoto _self;
  final $Res Function(_PedidoFoto) _then;

  /// Create a copy of PedidoFoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? pedidoId = null,
    Object? storagePath = null,
    Object? orden = null,
    Object? createdAt = null,
  }) {
    return _then(_PedidoFoto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      pedidoId: null == pedidoId
          ? _self.pedidoId
          : pedidoId // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _self.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      orden: null == orden
          ? _self.orden
          : orden // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
