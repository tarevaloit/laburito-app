// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfil_publico.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PerfilPublico {
  String get slug;
  String get nombre;
  String get apellido;
  String? get avatarUrl;
  String? get descripcion;
  double? get calificacionPromedio;
  int get totalCalificaciones;
  List<String> get oficios;
  List<FotoPublica> get portafolio;
  List<Resena> get resenas;

  /// Create a copy of PerfilPublico
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PerfilPublicoCopyWith<PerfilPublico> get copyWith =>
      _$PerfilPublicoCopyWithImpl<PerfilPublico>(
          this as PerfilPublico, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PerfilPublico &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.calificacionPromedio, calificacionPromedio) ||
                other.calificacionPromedio == calificacionPromedio) &&
            (identical(other.totalCalificaciones, totalCalificaciones) ||
                other.totalCalificaciones == totalCalificaciones) &&
            const DeepCollectionEquality().equals(other.oficios, oficios) &&
            const DeepCollectionEquality()
                .equals(other.portafolio, portafolio) &&
            const DeepCollectionEquality().equals(other.resenas, resenas));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      slug,
      nombre,
      apellido,
      avatarUrl,
      descripcion,
      calificacionPromedio,
      totalCalificaciones,
      const DeepCollectionEquality().hash(oficios),
      const DeepCollectionEquality().hash(portafolio),
      const DeepCollectionEquality().hash(resenas));

  @override
  String toString() {
    return 'PerfilPublico(slug: $slug, nombre: $nombre, apellido: $apellido, avatarUrl: $avatarUrl, descripcion: $descripcion, calificacionPromedio: $calificacionPromedio, totalCalificaciones: $totalCalificaciones, oficios: $oficios, portafolio: $portafolio, resenas: $resenas)';
  }
}

/// @nodoc
abstract mixin class $PerfilPublicoCopyWith<$Res> {
  factory $PerfilPublicoCopyWith(
          PerfilPublico value, $Res Function(PerfilPublico) _then) =
      _$PerfilPublicoCopyWithImpl;
  @useResult
  $Res call(
      {String slug,
      String nombre,
      String apellido,
      String? avatarUrl,
      String? descripcion,
      double? calificacionPromedio,
      int totalCalificaciones,
      List<String> oficios,
      List<FotoPublica> portafolio,
      List<Resena> resenas});
}

/// @nodoc
class _$PerfilPublicoCopyWithImpl<$Res>
    implements $PerfilPublicoCopyWith<$Res> {
  _$PerfilPublicoCopyWithImpl(this._self, this._then);

  final PerfilPublico _self;
  final $Res Function(PerfilPublico) _then;

  /// Create a copy of PerfilPublico
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? avatarUrl = freezed,
    Object? descripcion = freezed,
    Object? calificacionPromedio = freezed,
    Object? totalCalificaciones = null,
    Object? oficios = null,
    Object? portafolio = null,
    Object? resenas = null,
  }) {
    return _then(_self.copyWith(
      slug: null == slug
          ? _self.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      apellido: null == apellido
          ? _self.apellido
          : apellido // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      calificacionPromedio: freezed == calificacionPromedio
          ? _self.calificacionPromedio
          : calificacionPromedio // ignore: cast_nullable_to_non_nullable
              as double?,
      totalCalificaciones: null == totalCalificaciones
          ? _self.totalCalificaciones
          : totalCalificaciones // ignore: cast_nullable_to_non_nullable
              as int,
      oficios: null == oficios
          ? _self.oficios
          : oficios // ignore: cast_nullable_to_non_nullable
              as List<String>,
      portafolio: null == portafolio
          ? _self.portafolio
          : portafolio // ignore: cast_nullable_to_non_nullable
              as List<FotoPublica>,
      resenas: null == resenas
          ? _self.resenas
          : resenas // ignore: cast_nullable_to_non_nullable
              as List<Resena>,
    ));
  }
}

/// Adds pattern-matching-related methods to [PerfilPublico].
extension PerfilPublicoPatterns on PerfilPublico {
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
    TResult Function(_PerfilPublico value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PerfilPublico() when $default != null:
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
    TResult Function(_PerfilPublico value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerfilPublico():
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
    TResult? Function(_PerfilPublico value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerfilPublico() when $default != null:
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
            String slug,
            String nombre,
            String apellido,
            String? avatarUrl,
            String? descripcion,
            double? calificacionPromedio,
            int totalCalificaciones,
            List<String> oficios,
            List<FotoPublica> portafolio,
            List<Resena> resenas)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PerfilPublico() when $default != null:
        return $default(
            _that.slug,
            _that.nombre,
            _that.apellido,
            _that.avatarUrl,
            _that.descripcion,
            _that.calificacionPromedio,
            _that.totalCalificaciones,
            _that.oficios,
            _that.portafolio,
            _that.resenas);
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
            String slug,
            String nombre,
            String apellido,
            String? avatarUrl,
            String? descripcion,
            double? calificacionPromedio,
            int totalCalificaciones,
            List<String> oficios,
            List<FotoPublica> portafolio,
            List<Resena> resenas)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerfilPublico():
        return $default(
            _that.slug,
            _that.nombre,
            _that.apellido,
            _that.avatarUrl,
            _that.descripcion,
            _that.calificacionPromedio,
            _that.totalCalificaciones,
            _that.oficios,
            _that.portafolio,
            _that.resenas);
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
            String slug,
            String nombre,
            String apellido,
            String? avatarUrl,
            String? descripcion,
            double? calificacionPromedio,
            int totalCalificaciones,
            List<String> oficios,
            List<FotoPublica> portafolio,
            List<Resena> resenas)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerfilPublico() when $default != null:
        return $default(
            _that.slug,
            _that.nombre,
            _that.apellido,
            _that.avatarUrl,
            _that.descripcion,
            _that.calificacionPromedio,
            _that.totalCalificaciones,
            _that.oficios,
            _that.portafolio,
            _that.resenas);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PerfilPublico extends PerfilPublico {
  const _PerfilPublico(
      {required this.slug,
      required this.nombre,
      required this.apellido,
      this.avatarUrl,
      this.descripcion,
      this.calificacionPromedio,
      this.totalCalificaciones = 0,
      final List<String> oficios = const <String>[],
      final List<FotoPublica> portafolio = const <FotoPublica>[],
      final List<Resena> resenas = const <Resena>[]})
      : _oficios = oficios,
        _portafolio = portafolio,
        _resenas = resenas,
        super._();

  @override
  final String slug;
  @override
  final String nombre;
  @override
  final String apellido;
  @override
  final String? avatarUrl;
  @override
  final String? descripcion;
  @override
  final double? calificacionPromedio;
  @override
  @JsonKey()
  final int totalCalificaciones;
  final List<String> _oficios;
  @override
  @JsonKey()
  List<String> get oficios {
    if (_oficios is EqualUnmodifiableListView) return _oficios;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_oficios);
  }

  final List<FotoPublica> _portafolio;
  @override
  @JsonKey()
  List<FotoPublica> get portafolio {
    if (_portafolio is EqualUnmodifiableListView) return _portafolio;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_portafolio);
  }

  final List<Resena> _resenas;
  @override
  @JsonKey()
  List<Resena> get resenas {
    if (_resenas is EqualUnmodifiableListView) return _resenas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_resenas);
  }

  /// Create a copy of PerfilPublico
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PerfilPublicoCopyWith<_PerfilPublico> get copyWith =>
      __$PerfilPublicoCopyWithImpl<_PerfilPublico>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PerfilPublico &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.calificacionPromedio, calificacionPromedio) ||
                other.calificacionPromedio == calificacionPromedio) &&
            (identical(other.totalCalificaciones, totalCalificaciones) ||
                other.totalCalificaciones == totalCalificaciones) &&
            const DeepCollectionEquality().equals(other._oficios, _oficios) &&
            const DeepCollectionEquality()
                .equals(other._portafolio, _portafolio) &&
            const DeepCollectionEquality().equals(other._resenas, _resenas));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      slug,
      nombre,
      apellido,
      avatarUrl,
      descripcion,
      calificacionPromedio,
      totalCalificaciones,
      const DeepCollectionEquality().hash(_oficios),
      const DeepCollectionEquality().hash(_portafolio),
      const DeepCollectionEquality().hash(_resenas));

  @override
  String toString() {
    return 'PerfilPublico(slug: $slug, nombre: $nombre, apellido: $apellido, avatarUrl: $avatarUrl, descripcion: $descripcion, calificacionPromedio: $calificacionPromedio, totalCalificaciones: $totalCalificaciones, oficios: $oficios, portafolio: $portafolio, resenas: $resenas)';
  }
}

/// @nodoc
abstract mixin class _$PerfilPublicoCopyWith<$Res>
    implements $PerfilPublicoCopyWith<$Res> {
  factory _$PerfilPublicoCopyWith(
          _PerfilPublico value, $Res Function(_PerfilPublico) _then) =
      __$PerfilPublicoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String slug,
      String nombre,
      String apellido,
      String? avatarUrl,
      String? descripcion,
      double? calificacionPromedio,
      int totalCalificaciones,
      List<String> oficios,
      List<FotoPublica> portafolio,
      List<Resena> resenas});
}

/// @nodoc
class __$PerfilPublicoCopyWithImpl<$Res>
    implements _$PerfilPublicoCopyWith<$Res> {
  __$PerfilPublicoCopyWithImpl(this._self, this._then);

  final _PerfilPublico _self;
  final $Res Function(_PerfilPublico) _then;

  /// Create a copy of PerfilPublico
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? slug = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? avatarUrl = freezed,
    Object? descripcion = freezed,
    Object? calificacionPromedio = freezed,
    Object? totalCalificaciones = null,
    Object? oficios = null,
    Object? portafolio = null,
    Object? resenas = null,
  }) {
    return _then(_PerfilPublico(
      slug: null == slug
          ? _self.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      apellido: null == apellido
          ? _self.apellido
          : apellido // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      calificacionPromedio: freezed == calificacionPromedio
          ? _self.calificacionPromedio
          : calificacionPromedio // ignore: cast_nullable_to_non_nullable
              as double?,
      totalCalificaciones: null == totalCalificaciones
          ? _self.totalCalificaciones
          : totalCalificaciones // ignore: cast_nullable_to_non_nullable
              as int,
      oficios: null == oficios
          ? _self._oficios
          : oficios // ignore: cast_nullable_to_non_nullable
              as List<String>,
      portafolio: null == portafolio
          ? _self._portafolio
          : portafolio // ignore: cast_nullable_to_non_nullable
              as List<FotoPublica>,
      resenas: null == resenas
          ? _self._resenas
          : resenas // ignore: cast_nullable_to_non_nullable
              as List<Resena>,
    ));
  }
}

/// @nodoc
mixin _$FotoPublica {
  String get url;
  String? get descripcion;

  /// Create a copy of FotoPublica
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FotoPublicaCopyWith<FotoPublica> get copyWith =>
      _$FotoPublicaCopyWithImpl<FotoPublica>(this as FotoPublica, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FotoPublica &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion));
  }

  @override
  int get hashCode => Object.hash(runtimeType, url, descripcion);

  @override
  String toString() {
    return 'FotoPublica(url: $url, descripcion: $descripcion)';
  }
}

/// @nodoc
abstract mixin class $FotoPublicaCopyWith<$Res> {
  factory $FotoPublicaCopyWith(
          FotoPublica value, $Res Function(FotoPublica) _then) =
      _$FotoPublicaCopyWithImpl;
  @useResult
  $Res call({String url, String? descripcion});
}

/// @nodoc
class _$FotoPublicaCopyWithImpl<$Res> implements $FotoPublicaCopyWith<$Res> {
  _$FotoPublicaCopyWithImpl(this._self, this._then);

  final FotoPublica _self;
  final $Res Function(FotoPublica) _then;

  /// Create a copy of FotoPublica
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? descripcion = freezed,
  }) {
    return _then(_self.copyWith(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [FotoPublica].
extension FotoPublicaPatterns on FotoPublica {
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
    TResult Function(_FotoPublica value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FotoPublica() when $default != null:
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
    TResult Function(_FotoPublica value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FotoPublica():
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
    TResult? Function(_FotoPublica value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FotoPublica() when $default != null:
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
    TResult Function(String url, String? descripcion)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FotoPublica() when $default != null:
        return $default(_that.url, _that.descripcion);
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
    TResult Function(String url, String? descripcion) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FotoPublica():
        return $default(_that.url, _that.descripcion);
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
    TResult? Function(String url, String? descripcion)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FotoPublica() when $default != null:
        return $default(_that.url, _that.descripcion);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _FotoPublica implements FotoPublica {
  const _FotoPublica({required this.url, this.descripcion});

  @override
  final String url;
  @override
  final String? descripcion;

  /// Create a copy of FotoPublica
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FotoPublicaCopyWith<_FotoPublica> get copyWith =>
      __$FotoPublicaCopyWithImpl<_FotoPublica>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FotoPublica &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion));
  }

  @override
  int get hashCode => Object.hash(runtimeType, url, descripcion);

  @override
  String toString() {
    return 'FotoPublica(url: $url, descripcion: $descripcion)';
  }
}

/// @nodoc
abstract mixin class _$FotoPublicaCopyWith<$Res>
    implements $FotoPublicaCopyWith<$Res> {
  factory _$FotoPublicaCopyWith(
          _FotoPublica value, $Res Function(_FotoPublica) _then) =
      __$FotoPublicaCopyWithImpl;
  @override
  @useResult
  $Res call({String url, String? descripcion});
}

/// @nodoc
class __$FotoPublicaCopyWithImpl<$Res> implements _$FotoPublicaCopyWith<$Res> {
  __$FotoPublicaCopyWithImpl(this._self, this._then);

  final _FotoPublica _self;
  final $Res Function(_FotoPublica) _then;

  /// Create a copy of FotoPublica
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? url = null,
    Object? descripcion = freezed,
  }) {
    return _then(_FotoPublica(
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$Resena {
  String get autor;
  int get puntaje;
  String? get comentario;
  DateTime get fecha;

  /// Create a copy of Resena
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResenaCopyWith<Resena> get copyWith =>
      _$ResenaCopyWithImpl<Resena>(this as Resena, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Resena &&
            (identical(other.autor, autor) || other.autor == autor) &&
            (identical(other.puntaje, puntaje) || other.puntaje == puntaje) &&
            (identical(other.comentario, comentario) ||
                other.comentario == comentario) &&
            (identical(other.fecha, fecha) || other.fecha == fecha));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, autor, puntaje, comentario, fecha);

  @override
  String toString() {
    return 'Resena(autor: $autor, puntaje: $puntaje, comentario: $comentario, fecha: $fecha)';
  }
}

/// @nodoc
abstract mixin class $ResenaCopyWith<$Res> {
  factory $ResenaCopyWith(Resena value, $Res Function(Resena) _then) =
      _$ResenaCopyWithImpl;
  @useResult
  $Res call({String autor, int puntaje, String? comentario, DateTime fecha});
}

/// @nodoc
class _$ResenaCopyWithImpl<$Res> implements $ResenaCopyWith<$Res> {
  _$ResenaCopyWithImpl(this._self, this._then);

  final Resena _self;
  final $Res Function(Resena) _then;

  /// Create a copy of Resena
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autor = null,
    Object? puntaje = null,
    Object? comentario = freezed,
    Object? fecha = null,
  }) {
    return _then(_self.copyWith(
      autor: null == autor
          ? _self.autor
          : autor // ignore: cast_nullable_to_non_nullable
              as String,
      puntaje: null == puntaje
          ? _self.puntaje
          : puntaje // ignore: cast_nullable_to_non_nullable
              as int,
      comentario: freezed == comentario
          ? _self.comentario
          : comentario // ignore: cast_nullable_to_non_nullable
              as String?,
      fecha: null == fecha
          ? _self.fecha
          : fecha // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Resena].
extension ResenaPatterns on Resena {
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
    TResult Function(_Resena value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Resena() when $default != null:
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
    TResult Function(_Resena value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Resena():
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
    TResult? Function(_Resena value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Resena() when $default != null:
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
            String autor, int puntaje, String? comentario, DateTime fecha)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Resena() when $default != null:
        return $default(
            _that.autor, _that.puntaje, _that.comentario, _that.fecha);
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
            String autor, int puntaje, String? comentario, DateTime fecha)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Resena():
        return $default(
            _that.autor, _that.puntaje, _that.comentario, _that.fecha);
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
            String autor, int puntaje, String? comentario, DateTime fecha)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Resena() when $default != null:
        return $default(
            _that.autor, _that.puntaje, _that.comentario, _that.fecha);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Resena extends Resena {
  const _Resena(
      {required this.autor,
      required this.puntaje,
      this.comentario,
      required this.fecha})
      : super._();

  @override
  final String autor;
  @override
  final int puntaje;
  @override
  final String? comentario;
  @override
  final DateTime fecha;

  /// Create a copy of Resena
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ResenaCopyWith<_Resena> get copyWith =>
      __$ResenaCopyWithImpl<_Resena>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Resena &&
            (identical(other.autor, autor) || other.autor == autor) &&
            (identical(other.puntaje, puntaje) || other.puntaje == puntaje) &&
            (identical(other.comentario, comentario) ||
                other.comentario == comentario) &&
            (identical(other.fecha, fecha) || other.fecha == fecha));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, autor, puntaje, comentario, fecha);

  @override
  String toString() {
    return 'Resena(autor: $autor, puntaje: $puntaje, comentario: $comentario, fecha: $fecha)';
  }
}

/// @nodoc
abstract mixin class _$ResenaCopyWith<$Res> implements $ResenaCopyWith<$Res> {
  factory _$ResenaCopyWith(_Resena value, $Res Function(_Resena) _then) =
      __$ResenaCopyWithImpl;
  @override
  @useResult
  $Res call({String autor, int puntaje, String? comentario, DateTime fecha});
}

/// @nodoc
class __$ResenaCopyWithImpl<$Res> implements _$ResenaCopyWith<$Res> {
  __$ResenaCopyWithImpl(this._self, this._then);

  final _Resena _self;
  final $Res Function(_Resena) _then;

  /// Create a copy of Resena
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? autor = null,
    Object? puntaje = null,
    Object? comentario = freezed,
    Object? fecha = null,
  }) {
    return _then(_Resena(
      autor: null == autor
          ? _self.autor
          : autor // ignore: cast_nullable_to_non_nullable
              as String,
      puntaje: null == puntaje
          ? _self.puntaje
          : puntaje // ignore: cast_nullable_to_non_nullable
              as int,
      comentario: freezed == comentario
          ? _self.comentario
          : comentario // ignore: cast_nullable_to_non_nullable
              as String?,
      fecha: null == fecha
          ? _self.fecha
          : fecha // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
