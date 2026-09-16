// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portafolio_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoPortafolio {
  List<FotoPortafolio> get fotos;
  Map<String, String> get urls;
  bool get trabajando;
  String? get error;

  /// Create a copy of EstadoPortafolio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoPortafolioCopyWith<EstadoPortafolio> get copyWith =>
      _$EstadoPortafolioCopyWithImpl<EstadoPortafolio>(
          this as EstadoPortafolio, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoPortafolio &&
            const DeepCollectionEquality().equals(other.fotos, fotos) &&
            const DeepCollectionEquality().equals(other.urls, urls) &&
            (identical(other.trabajando, trabajando) ||
                other.trabajando == trabajando) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(fotos),
      const DeepCollectionEquality().hash(urls),
      trabajando,
      error);

  @override
  String toString() {
    return 'EstadoPortafolio(fotos: $fotos, urls: $urls, trabajando: $trabajando, error: $error)';
  }
}

/// @nodoc
abstract mixin class $EstadoPortafolioCopyWith<$Res> {
  factory $EstadoPortafolioCopyWith(
          EstadoPortafolio value, $Res Function(EstadoPortafolio) _then) =
      _$EstadoPortafolioCopyWithImpl;
  @useResult
  $Res call(
      {List<FotoPortafolio> fotos,
      Map<String, String> urls,
      bool trabajando,
      String? error});
}

/// @nodoc
class _$EstadoPortafolioCopyWithImpl<$Res>
    implements $EstadoPortafolioCopyWith<$Res> {
  _$EstadoPortafolioCopyWithImpl(this._self, this._then);

  final EstadoPortafolio _self;
  final $Res Function(EstadoPortafolio) _then;

  /// Create a copy of EstadoPortafolio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fotos = null,
    Object? urls = null,
    Object? trabajando = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      fotos: null == fotos
          ? _self.fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<FotoPortafolio>,
      urls: null == urls
          ? _self.urls
          : urls // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      trabajando: null == trabajando
          ? _self.trabajando
          : trabajando // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EstadoPortafolio].
extension EstadoPortafolioPatterns on EstadoPortafolio {
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
    TResult Function(_EstadoPortafolio value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoPortafolio() when $default != null:
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
    TResult Function(_EstadoPortafolio value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoPortafolio():
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
    TResult? Function(_EstadoPortafolio value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoPortafolio() when $default != null:
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
    TResult Function(List<FotoPortafolio> fotos, Map<String, String> urls,
            bool trabajando, String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoPortafolio() when $default != null:
        return $default(_that.fotos, _that.urls, _that.trabajando, _that.error);
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
    TResult Function(List<FotoPortafolio> fotos, Map<String, String> urls,
            bool trabajando, String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoPortafolio():
        return $default(_that.fotos, _that.urls, _that.trabajando, _that.error);
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
    TResult? Function(List<FotoPortafolio> fotos, Map<String, String> urls,
            bool trabajando, String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoPortafolio() when $default != null:
        return $default(_that.fotos, _that.urls, _that.trabajando, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoPortafolio extends EstadoPortafolio {
  const _EstadoPortafolio(
      {final List<FotoPortafolio> fotos = const <FotoPortafolio>[],
      final Map<String, String> urls = const <String, String>{},
      this.trabajando = false,
      this.error})
      : _fotos = fotos,
        _urls = urls,
        super._();

  final List<FotoPortafolio> _fotos;
  @override
  @JsonKey()
  List<FotoPortafolio> get fotos {
    if (_fotos is EqualUnmodifiableListView) return _fotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fotos);
  }

  final Map<String, String> _urls;
  @override
  @JsonKey()
  Map<String, String> get urls {
    if (_urls is EqualUnmodifiableMapView) return _urls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_urls);
  }

  @override
  @JsonKey()
  final bool trabajando;
  @override
  final String? error;

  /// Create a copy of EstadoPortafolio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoPortafolioCopyWith<_EstadoPortafolio> get copyWith =>
      __$EstadoPortafolioCopyWithImpl<_EstadoPortafolio>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoPortafolio &&
            const DeepCollectionEquality().equals(other._fotos, _fotos) &&
            const DeepCollectionEquality().equals(other._urls, _urls) &&
            (identical(other.trabajando, trabajando) ||
                other.trabajando == trabajando) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_fotos),
      const DeepCollectionEquality().hash(_urls),
      trabajando,
      error);

  @override
  String toString() {
    return 'EstadoPortafolio(fotos: $fotos, urls: $urls, trabajando: $trabajando, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$EstadoPortafolioCopyWith<$Res>
    implements $EstadoPortafolioCopyWith<$Res> {
  factory _$EstadoPortafolioCopyWith(
          _EstadoPortafolio value, $Res Function(_EstadoPortafolio) _then) =
      __$EstadoPortafolioCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<FotoPortafolio> fotos,
      Map<String, String> urls,
      bool trabajando,
      String? error});
}

/// @nodoc
class __$EstadoPortafolioCopyWithImpl<$Res>
    implements _$EstadoPortafolioCopyWith<$Res> {
  __$EstadoPortafolioCopyWithImpl(this._self, this._then);

  final _EstadoPortafolio _self;
  final $Res Function(_EstadoPortafolio) _then;

  /// Create a copy of EstadoPortafolio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? fotos = null,
    Object? urls = null,
    Object? trabajando = null,
    Object? error = freezed,
  }) {
    return _then(_EstadoPortafolio(
      fotos: null == fotos
          ? _self._fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<FotoPortafolio>,
      urls: null == urls
          ? _self._urls
          : urls // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      trabajando: null == trabajando
          ? _self.trabajando
          : trabajando // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
