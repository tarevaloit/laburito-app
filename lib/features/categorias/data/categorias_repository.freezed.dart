// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'categorias_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoriaOficio {
  String get id;
  String get nombre;
  String get slug;

  /// Create a copy of CategoriaOficio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CategoriaOficioCopyWith<CategoriaOficio> get copyWith =>
      _$CategoriaOficioCopyWithImpl<CategoriaOficio>(
          this as CategoriaOficio, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CategoriaOficio &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, nombre, slug);

  @override
  String toString() {
    return 'CategoriaOficio(id: $id, nombre: $nombre, slug: $slug)';
  }
}

/// @nodoc
abstract mixin class $CategoriaOficioCopyWith<$Res> {
  factory $CategoriaOficioCopyWith(
          CategoriaOficio value, $Res Function(CategoriaOficio) _then) =
      _$CategoriaOficioCopyWithImpl;
  @useResult
  $Res call({String id, String nombre, String slug});
}

/// @nodoc
class _$CategoriaOficioCopyWithImpl<$Res>
    implements $CategoriaOficioCopyWith<$Res> {
  _$CategoriaOficioCopyWithImpl(this._self, this._then);

  final CategoriaOficio _self;
  final $Res Function(CategoriaOficio) _then;

  /// Create a copy of CategoriaOficio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? slug = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _self.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [CategoriaOficio].
extension CategoriaOficioPatterns on CategoriaOficio {
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
    TResult Function(_CategoriaOficio value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CategoriaOficio() when $default != null:
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
    TResult Function(_CategoriaOficio value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CategoriaOficio():
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
    TResult? Function(_CategoriaOficio value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CategoriaOficio() when $default != null:
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
    TResult Function(String id, String nombre, String slug)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CategoriaOficio() when $default != null:
        return $default(_that.id, _that.nombre, _that.slug);
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
    TResult Function(String id, String nombre, String slug) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CategoriaOficio():
        return $default(_that.id, _that.nombre, _that.slug);
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
    TResult? Function(String id, String nombre, String slug)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CategoriaOficio() when $default != null:
        return $default(_that.id, _that.nombre, _that.slug);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CategoriaOficio implements CategoriaOficio {
  const _CategoriaOficio(
      {required this.id, required this.nombre, required this.slug});

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String slug;

  /// Create a copy of CategoriaOficio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CategoriaOficioCopyWith<_CategoriaOficio> get copyWith =>
      __$CategoriaOficioCopyWithImpl<_CategoriaOficio>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CategoriaOficio &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.slug, slug) || other.slug == slug));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, nombre, slug);

  @override
  String toString() {
    return 'CategoriaOficio(id: $id, nombre: $nombre, slug: $slug)';
  }
}

/// @nodoc
abstract mixin class _$CategoriaOficioCopyWith<$Res>
    implements $CategoriaOficioCopyWith<$Res> {
  factory _$CategoriaOficioCopyWith(
          _CategoriaOficio value, $Res Function(_CategoriaOficio) _then) =
      __$CategoriaOficioCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String nombre, String slug});
}

/// @nodoc
class __$CategoriaOficioCopyWithImpl<$Res>
    implements _$CategoriaOficioCopyWith<$Res> {
  __$CategoriaOficioCopyWithImpl(this._self, this._then);

  final _CategoriaOficio _self;
  final $Res Function(_CategoriaOficio) _then;

  /// Create a copy of CategoriaOficio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? slug = null,
  }) {
    return _then(_CategoriaOficio(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _self.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
