// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacto_buscador.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactoBuscador {
  String get nombreCorto;
  String? get telefonoEnmascarado;
  String? get telefono;
  bool get desbloqueado;

  /// Create a copy of ContactoBuscador
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContactoBuscadorCopyWith<ContactoBuscador> get copyWith =>
      _$ContactoBuscadorCopyWithImpl<ContactoBuscador>(
          this as ContactoBuscador, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContactoBuscador &&
            (identical(other.nombreCorto, nombreCorto) ||
                other.nombreCorto == nombreCorto) &&
            (identical(other.telefonoEnmascarado, telefonoEnmascarado) ||
                other.telefonoEnmascarado == telefonoEnmascarado) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.desbloqueado, desbloqueado) ||
                other.desbloqueado == desbloqueado));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, nombreCorto, telefonoEnmascarado, telefono, desbloqueado);

  @override
  String toString() {
    return 'ContactoBuscador(nombreCorto: $nombreCorto, telefonoEnmascarado: $telefonoEnmascarado, telefono: $telefono, desbloqueado: $desbloqueado)';
  }
}

/// @nodoc
abstract mixin class $ContactoBuscadorCopyWith<$Res> {
  factory $ContactoBuscadorCopyWith(
          ContactoBuscador value, $Res Function(ContactoBuscador) _then) =
      _$ContactoBuscadorCopyWithImpl;
  @useResult
  $Res call(
      {String nombreCorto,
      String? telefonoEnmascarado,
      String? telefono,
      bool desbloqueado});
}

/// @nodoc
class _$ContactoBuscadorCopyWithImpl<$Res>
    implements $ContactoBuscadorCopyWith<$Res> {
  _$ContactoBuscadorCopyWithImpl(this._self, this._then);

  final ContactoBuscador _self;
  final $Res Function(ContactoBuscador) _then;

  /// Create a copy of ContactoBuscador
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nombreCorto = null,
    Object? telefonoEnmascarado = freezed,
    Object? telefono = freezed,
    Object? desbloqueado = null,
  }) {
    return _then(_self.copyWith(
      nombreCorto: null == nombreCorto
          ? _self.nombreCorto
          : nombreCorto // ignore: cast_nullable_to_non_nullable
              as String,
      telefonoEnmascarado: freezed == telefonoEnmascarado
          ? _self.telefonoEnmascarado
          : telefonoEnmascarado // ignore: cast_nullable_to_non_nullable
              as String?,
      telefono: freezed == telefono
          ? _self.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      desbloqueado: null == desbloqueado
          ? _self.desbloqueado
          : desbloqueado // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ContactoBuscador].
extension ContactoBuscadorPatterns on ContactoBuscador {
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
    TResult Function(_ContactoBuscador value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ContactoBuscador() when $default != null:
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
    TResult Function(_ContactoBuscador value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContactoBuscador():
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
    TResult? Function(_ContactoBuscador value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContactoBuscador() when $default != null:
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
    TResult Function(String nombreCorto, String? telefonoEnmascarado,
            String? telefono, bool desbloqueado)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ContactoBuscador() when $default != null:
        return $default(_that.nombreCorto, _that.telefonoEnmascarado,
            _that.telefono, _that.desbloqueado);
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
    TResult Function(String nombreCorto, String? telefonoEnmascarado,
            String? telefono, bool desbloqueado)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContactoBuscador():
        return $default(_that.nombreCorto, _that.telefonoEnmascarado,
            _that.telefono, _that.desbloqueado);
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
    TResult? Function(String nombreCorto, String? telefonoEnmascarado,
            String? telefono, bool desbloqueado)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContactoBuscador() when $default != null:
        return $default(_that.nombreCorto, _that.telefonoEnmascarado,
            _that.telefono, _that.desbloqueado);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ContactoBuscador extends ContactoBuscador {
  const _ContactoBuscador(
      {required this.nombreCorto,
      this.telefonoEnmascarado,
      this.telefono,
      this.desbloqueado = false})
      : super._();

  @override
  final String nombreCorto;
  @override
  final String? telefonoEnmascarado;
  @override
  final String? telefono;
  @override
  @JsonKey()
  final bool desbloqueado;

  /// Create a copy of ContactoBuscador
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ContactoBuscadorCopyWith<_ContactoBuscador> get copyWith =>
      __$ContactoBuscadorCopyWithImpl<_ContactoBuscador>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ContactoBuscador &&
            (identical(other.nombreCorto, nombreCorto) ||
                other.nombreCorto == nombreCorto) &&
            (identical(other.telefonoEnmascarado, telefonoEnmascarado) ||
                other.telefonoEnmascarado == telefonoEnmascarado) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.desbloqueado, desbloqueado) ||
                other.desbloqueado == desbloqueado));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, nombreCorto, telefonoEnmascarado, telefono, desbloqueado);

  @override
  String toString() {
    return 'ContactoBuscador(nombreCorto: $nombreCorto, telefonoEnmascarado: $telefonoEnmascarado, telefono: $telefono, desbloqueado: $desbloqueado)';
  }
}

/// @nodoc
abstract mixin class _$ContactoBuscadorCopyWith<$Res>
    implements $ContactoBuscadorCopyWith<$Res> {
  factory _$ContactoBuscadorCopyWith(
          _ContactoBuscador value, $Res Function(_ContactoBuscador) _then) =
      __$ContactoBuscadorCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String nombreCorto,
      String? telefonoEnmascarado,
      String? telefono,
      bool desbloqueado});
}

/// @nodoc
class __$ContactoBuscadorCopyWithImpl<$Res>
    implements _$ContactoBuscadorCopyWith<$Res> {
  __$ContactoBuscadorCopyWithImpl(this._self, this._then);

  final _ContactoBuscador _self;
  final $Res Function(_ContactoBuscador) _then;

  /// Create a copy of ContactoBuscador
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? nombreCorto = null,
    Object? telefonoEnmascarado = freezed,
    Object? telefono = freezed,
    Object? desbloqueado = null,
  }) {
    return _then(_ContactoBuscador(
      nombreCorto: null == nombreCorto
          ? _self.nombreCorto
          : nombreCorto // ignore: cast_nullable_to_non_nullable
              as String,
      telefonoEnmascarado: freezed == telefonoEnmascarado
          ? _self.telefonoEnmascarado
          : telefonoEnmascarado // ignore: cast_nullable_to_non_nullable
              as String?,
      telefono: freezed == telefono
          ? _self.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      desbloqueado: null == desbloqueado
          ? _self.desbloqueado
          : desbloqueado // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
