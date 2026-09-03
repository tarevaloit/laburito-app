// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'acciones_pedido_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoAccionesPedido {
  /// Qué acción se está ejecutando ahora, o `null` si ninguna.
  AccionPedido? get enCurso;
  PedidoException? get error;

  /// Create a copy of EstadoAccionesPedido
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoAccionesPedidoCopyWith<EstadoAccionesPedido> get copyWith =>
      _$EstadoAccionesPedidoCopyWithImpl<EstadoAccionesPedido>(
          this as EstadoAccionesPedido, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoAccionesPedido &&
            (identical(other.enCurso, enCurso) || other.enCurso == enCurso) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enCurso, error);

  @override
  String toString() {
    return 'EstadoAccionesPedido(enCurso: $enCurso, error: $error)';
  }
}

/// @nodoc
abstract mixin class $EstadoAccionesPedidoCopyWith<$Res> {
  factory $EstadoAccionesPedidoCopyWith(EstadoAccionesPedido value,
          $Res Function(EstadoAccionesPedido) _then) =
      _$EstadoAccionesPedidoCopyWithImpl;
  @useResult
  $Res call({AccionPedido? enCurso, PedidoException? error});
}

/// @nodoc
class _$EstadoAccionesPedidoCopyWithImpl<$Res>
    implements $EstadoAccionesPedidoCopyWith<$Res> {
  _$EstadoAccionesPedidoCopyWithImpl(this._self, this._then);

  final EstadoAccionesPedido _self;
  final $Res Function(EstadoAccionesPedido) _then;

  /// Create a copy of EstadoAccionesPedido
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enCurso = freezed,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      enCurso: freezed == enCurso
          ? _self.enCurso
          : enCurso // ignore: cast_nullable_to_non_nullable
              as AccionPedido?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as PedidoException?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EstadoAccionesPedido].
extension EstadoAccionesPedidoPatterns on EstadoAccionesPedido {
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
    TResult Function(_EstadoAccionesPedido value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoAccionesPedido() when $default != null:
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
    TResult Function(_EstadoAccionesPedido value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoAccionesPedido():
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
    TResult? Function(_EstadoAccionesPedido value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoAccionesPedido() when $default != null:
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
    TResult Function(AccionPedido? enCurso, PedidoException? error)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoAccionesPedido() when $default != null:
        return $default(_that.enCurso, _that.error);
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
    TResult Function(AccionPedido? enCurso, PedidoException? error) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoAccionesPedido():
        return $default(_that.enCurso, _that.error);
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
    TResult? Function(AccionPedido? enCurso, PedidoException? error)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoAccionesPedido() when $default != null:
        return $default(_that.enCurso, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoAccionesPedido extends EstadoAccionesPedido {
  const _EstadoAccionesPedido({this.enCurso, this.error}) : super._();

  /// Qué acción se está ejecutando ahora, o `null` si ninguna.
  @override
  final AccionPedido? enCurso;
  @override
  final PedidoException? error;

  /// Create a copy of EstadoAccionesPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoAccionesPedidoCopyWith<_EstadoAccionesPedido> get copyWith =>
      __$EstadoAccionesPedidoCopyWithImpl<_EstadoAccionesPedido>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoAccionesPedido &&
            (identical(other.enCurso, enCurso) || other.enCurso == enCurso) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enCurso, error);

  @override
  String toString() {
    return 'EstadoAccionesPedido(enCurso: $enCurso, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$EstadoAccionesPedidoCopyWith<$Res>
    implements $EstadoAccionesPedidoCopyWith<$Res> {
  factory _$EstadoAccionesPedidoCopyWith(_EstadoAccionesPedido value,
          $Res Function(_EstadoAccionesPedido) _then) =
      __$EstadoAccionesPedidoCopyWithImpl;
  @override
  @useResult
  $Res call({AccionPedido? enCurso, PedidoException? error});
}

/// @nodoc
class __$EstadoAccionesPedidoCopyWithImpl<$Res>
    implements _$EstadoAccionesPedidoCopyWith<$Res> {
  __$EstadoAccionesPedidoCopyWithImpl(this._self, this._then);

  final _EstadoAccionesPedido _self;
  final $Res Function(_EstadoAccionesPedido) _then;

  /// Create a copy of EstadoAccionesPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? enCurso = freezed,
    Object? error = freezed,
  }) {
    return _then(_EstadoAccionesPedido(
      enCurso: freezed == enCurso
          ? _self.enCurso
          : enCurso // ignore: cast_nullable_to_non_nullable
              as AccionPedido?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as PedidoException?,
    ));
  }
}

// dart format on
