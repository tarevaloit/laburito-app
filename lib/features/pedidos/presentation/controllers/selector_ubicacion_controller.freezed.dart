// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selector_ubicacion_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ObjetivoCamara {
  double get lat;
  double get lng;
  int get sello;

  /// Create a copy of ObjetivoCamara
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ObjetivoCamaraCopyWith<ObjetivoCamara> get copyWith =>
      _$ObjetivoCamaraCopyWithImpl<ObjetivoCamara>(
          this as ObjetivoCamara, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ObjetivoCamara &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.sello, sello) || other.sello == sello));
  }

  @override
  int get hashCode => Object.hash(runtimeType, lat, lng, sello);

  @override
  String toString() {
    return 'ObjetivoCamara(lat: $lat, lng: $lng, sello: $sello)';
  }
}

/// @nodoc
abstract mixin class $ObjetivoCamaraCopyWith<$Res> {
  factory $ObjetivoCamaraCopyWith(
          ObjetivoCamara value, $Res Function(ObjetivoCamara) _then) =
      _$ObjetivoCamaraCopyWithImpl;
  @useResult
  $Res call({double lat, double lng, int sello});
}

/// @nodoc
class _$ObjetivoCamaraCopyWithImpl<$Res>
    implements $ObjetivoCamaraCopyWith<$Res> {
  _$ObjetivoCamaraCopyWithImpl(this._self, this._then);

  final ObjetivoCamara _self;
  final $Res Function(ObjetivoCamara) _then;

  /// Create a copy of ObjetivoCamara
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? sello = null,
  }) {
    return _then(_self.copyWith(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      sello: null == sello
          ? _self.sello
          : sello // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [ObjetivoCamara].
extension ObjetivoCamaraPatterns on ObjetivoCamara {
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
    TResult Function(_ObjetivoCamara value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ObjetivoCamara() when $default != null:
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
    TResult Function(_ObjetivoCamara value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ObjetivoCamara():
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
    TResult? Function(_ObjetivoCamara value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ObjetivoCamara() when $default != null:
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
    TResult Function(double lat, double lng, int sello)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ObjetivoCamara() when $default != null:
        return $default(_that.lat, _that.lng, _that.sello);
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
    TResult Function(double lat, double lng, int sello) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ObjetivoCamara():
        return $default(_that.lat, _that.lng, _that.sello);
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
    TResult? Function(double lat, double lng, int sello)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ObjetivoCamara() when $default != null:
        return $default(_that.lat, _that.lng, _that.sello);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ObjetivoCamara implements ObjetivoCamara {
  const _ObjetivoCamara(
      {required this.lat, required this.lng, required this.sello});

  @override
  final double lat;
  @override
  final double lng;
  @override
  final int sello;

  /// Create a copy of ObjetivoCamara
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ObjetivoCamaraCopyWith<_ObjetivoCamara> get copyWith =>
      __$ObjetivoCamaraCopyWithImpl<_ObjetivoCamara>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ObjetivoCamara &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.sello, sello) || other.sello == sello));
  }

  @override
  int get hashCode => Object.hash(runtimeType, lat, lng, sello);

  @override
  String toString() {
    return 'ObjetivoCamara(lat: $lat, lng: $lng, sello: $sello)';
  }
}

/// @nodoc
abstract mixin class _$ObjetivoCamaraCopyWith<$Res>
    implements $ObjetivoCamaraCopyWith<$Res> {
  factory _$ObjetivoCamaraCopyWith(
          _ObjetivoCamara value, $Res Function(_ObjetivoCamara) _then) =
      __$ObjetivoCamaraCopyWithImpl;
  @override
  @useResult
  $Res call({double lat, double lng, int sello});
}

/// @nodoc
class __$ObjetivoCamaraCopyWithImpl<$Res>
    implements _$ObjetivoCamaraCopyWith<$Res> {
  __$ObjetivoCamaraCopyWithImpl(this._self, this._then);

  final _ObjetivoCamara _self;
  final $Res Function(_ObjetivoCamara) _then;

  /// Create a copy of ObjetivoCamara
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? sello = null,
  }) {
    return _then(_ObjetivoCamara(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      sello: null == sello
          ? _self.sello
          : sello // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$EstadoSelectorUbicacion {
  /// Centro del mapa, que es donde está clavado el pin.
  double get lat;
  double get lng;
  String get direccionTexto;
  String get referencia;

  /// Hay una geocodificación inversa en vuelo.
  bool get resolviendoDireccion;

  /// Hay un pedido de posición al dispositivo en vuelo.
  bool get localizando;
  bool get buscandoSugerencias;
  List<SugerenciaDireccion> get sugerencias;

  /// Mensaje no bloqueante: permiso denegado, servicio de direcciones caído.
  /// Se muestra y se descarta; nunca impide confirmar.
  String? get aviso;
  ObjetivoCamara? get objetivo;

  /// Create a copy of EstadoSelectorUbicacion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoSelectorUbicacionCopyWith<EstadoSelectorUbicacion> get copyWith =>
      _$EstadoSelectorUbicacionCopyWithImpl<EstadoSelectorUbicacion>(
          this as EstadoSelectorUbicacion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoSelectorUbicacion &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.direccionTexto, direccionTexto) ||
                other.direccionTexto == direccionTexto) &&
            (identical(other.referencia, referencia) ||
                other.referencia == referencia) &&
            (identical(other.resolviendoDireccion, resolviendoDireccion) ||
                other.resolviendoDireccion == resolviendoDireccion) &&
            (identical(other.localizando, localizando) ||
                other.localizando == localizando) &&
            (identical(other.buscandoSugerencias, buscandoSugerencias) ||
                other.buscandoSugerencias == buscandoSugerencias) &&
            const DeepCollectionEquality()
                .equals(other.sugerencias, sugerencias) &&
            (identical(other.aviso, aviso) || other.aviso == aviso) &&
            (identical(other.objetivo, objetivo) ||
                other.objetivo == objetivo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      lat,
      lng,
      direccionTexto,
      referencia,
      resolviendoDireccion,
      localizando,
      buscandoSugerencias,
      const DeepCollectionEquality().hash(sugerencias),
      aviso,
      objetivo);

  @override
  String toString() {
    return 'EstadoSelectorUbicacion(lat: $lat, lng: $lng, direccionTexto: $direccionTexto, referencia: $referencia, resolviendoDireccion: $resolviendoDireccion, localizando: $localizando, buscandoSugerencias: $buscandoSugerencias, sugerencias: $sugerencias, aviso: $aviso, objetivo: $objetivo)';
  }
}

/// @nodoc
abstract mixin class $EstadoSelectorUbicacionCopyWith<$Res> {
  factory $EstadoSelectorUbicacionCopyWith(EstadoSelectorUbicacion value,
          $Res Function(EstadoSelectorUbicacion) _then) =
      _$EstadoSelectorUbicacionCopyWithImpl;
  @useResult
  $Res call(
      {double lat,
      double lng,
      String direccionTexto,
      String referencia,
      bool resolviendoDireccion,
      bool localizando,
      bool buscandoSugerencias,
      List<SugerenciaDireccion> sugerencias,
      String? aviso,
      ObjetivoCamara? objetivo});

  $ObjetivoCamaraCopyWith<$Res>? get objetivo;
}

/// @nodoc
class _$EstadoSelectorUbicacionCopyWithImpl<$Res>
    implements $EstadoSelectorUbicacionCopyWith<$Res> {
  _$EstadoSelectorUbicacionCopyWithImpl(this._self, this._then);

  final EstadoSelectorUbicacion _self;
  final $Res Function(EstadoSelectorUbicacion) _then;

  /// Create a copy of EstadoSelectorUbicacion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? direccionTexto = null,
    Object? referencia = null,
    Object? resolviendoDireccion = null,
    Object? localizando = null,
    Object? buscandoSugerencias = null,
    Object? sugerencias = null,
    Object? aviso = freezed,
    Object? objetivo = freezed,
  }) {
    return _then(_self.copyWith(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      direccionTexto: null == direccionTexto
          ? _self.direccionTexto
          : direccionTexto // ignore: cast_nullable_to_non_nullable
              as String,
      referencia: null == referencia
          ? _self.referencia
          : referencia // ignore: cast_nullable_to_non_nullable
              as String,
      resolviendoDireccion: null == resolviendoDireccion
          ? _self.resolviendoDireccion
          : resolviendoDireccion // ignore: cast_nullable_to_non_nullable
              as bool,
      localizando: null == localizando
          ? _self.localizando
          : localizando // ignore: cast_nullable_to_non_nullable
              as bool,
      buscandoSugerencias: null == buscandoSugerencias
          ? _self.buscandoSugerencias
          : buscandoSugerencias // ignore: cast_nullable_to_non_nullable
              as bool,
      sugerencias: null == sugerencias
          ? _self.sugerencias
          : sugerencias // ignore: cast_nullable_to_non_nullable
              as List<SugerenciaDireccion>,
      aviso: freezed == aviso
          ? _self.aviso
          : aviso // ignore: cast_nullable_to_non_nullable
              as String?,
      objetivo: freezed == objetivo
          ? _self.objetivo
          : objetivo // ignore: cast_nullable_to_non_nullable
              as ObjetivoCamara?,
    ));
  }

  /// Create a copy of EstadoSelectorUbicacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ObjetivoCamaraCopyWith<$Res>? get objetivo {
    if (_self.objetivo == null) {
      return null;
    }

    return $ObjetivoCamaraCopyWith<$Res>(_self.objetivo!, (value) {
      return _then(_self.copyWith(objetivo: value));
    });
  }
}

/// Adds pattern-matching-related methods to [EstadoSelectorUbicacion].
extension EstadoSelectorUbicacionPatterns on EstadoSelectorUbicacion {
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
    TResult Function(_EstadoSelectorUbicacion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoSelectorUbicacion() when $default != null:
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
    TResult Function(_EstadoSelectorUbicacion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoSelectorUbicacion():
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
    TResult? Function(_EstadoSelectorUbicacion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoSelectorUbicacion() when $default != null:
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
            double lat,
            double lng,
            String direccionTexto,
            String referencia,
            bool resolviendoDireccion,
            bool localizando,
            bool buscandoSugerencias,
            List<SugerenciaDireccion> sugerencias,
            String? aviso,
            ObjetivoCamara? objetivo)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoSelectorUbicacion() when $default != null:
        return $default(
            _that.lat,
            _that.lng,
            _that.direccionTexto,
            _that.referencia,
            _that.resolviendoDireccion,
            _that.localizando,
            _that.buscandoSugerencias,
            _that.sugerencias,
            _that.aviso,
            _that.objetivo);
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
            double lat,
            double lng,
            String direccionTexto,
            String referencia,
            bool resolviendoDireccion,
            bool localizando,
            bool buscandoSugerencias,
            List<SugerenciaDireccion> sugerencias,
            String? aviso,
            ObjetivoCamara? objetivo)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoSelectorUbicacion():
        return $default(
            _that.lat,
            _that.lng,
            _that.direccionTexto,
            _that.referencia,
            _that.resolviendoDireccion,
            _that.localizando,
            _that.buscandoSugerencias,
            _that.sugerencias,
            _that.aviso,
            _that.objetivo);
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
            double lat,
            double lng,
            String direccionTexto,
            String referencia,
            bool resolviendoDireccion,
            bool localizando,
            bool buscandoSugerencias,
            List<SugerenciaDireccion> sugerencias,
            String? aviso,
            ObjetivoCamara? objetivo)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoSelectorUbicacion() when $default != null:
        return $default(
            _that.lat,
            _that.lng,
            _that.direccionTexto,
            _that.referencia,
            _that.resolviendoDireccion,
            _that.localizando,
            _that.buscandoSugerencias,
            _that.sugerencias,
            _that.aviso,
            _that.objetivo);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoSelectorUbicacion extends EstadoSelectorUbicacion {
  const _EstadoSelectorUbicacion(
      {required this.lat,
      required this.lng,
      this.direccionTexto = '',
      this.referencia = '',
      this.resolviendoDireccion = false,
      this.localizando = false,
      this.buscandoSugerencias = false,
      final List<SugerenciaDireccion> sugerencias =
          const <SugerenciaDireccion>[],
      this.aviso,
      this.objetivo})
      : _sugerencias = sugerencias,
        super._();

  /// Centro del mapa, que es donde está clavado el pin.
  @override
  final double lat;
  @override
  final double lng;
  @override
  @JsonKey()
  final String direccionTexto;
  @override
  @JsonKey()
  final String referencia;

  /// Hay una geocodificación inversa en vuelo.
  @override
  @JsonKey()
  final bool resolviendoDireccion;

  /// Hay un pedido de posición al dispositivo en vuelo.
  @override
  @JsonKey()
  final bool localizando;
  @override
  @JsonKey()
  final bool buscandoSugerencias;
  final List<SugerenciaDireccion> _sugerencias;
  @override
  @JsonKey()
  List<SugerenciaDireccion> get sugerencias {
    if (_sugerencias is EqualUnmodifiableListView) return _sugerencias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sugerencias);
  }

  /// Mensaje no bloqueante: permiso denegado, servicio de direcciones caído.
  /// Se muestra y se descarta; nunca impide confirmar.
  @override
  final String? aviso;
  @override
  final ObjetivoCamara? objetivo;

  /// Create a copy of EstadoSelectorUbicacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoSelectorUbicacionCopyWith<_EstadoSelectorUbicacion> get copyWith =>
      __$EstadoSelectorUbicacionCopyWithImpl<_EstadoSelectorUbicacion>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoSelectorUbicacion &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.direccionTexto, direccionTexto) ||
                other.direccionTexto == direccionTexto) &&
            (identical(other.referencia, referencia) ||
                other.referencia == referencia) &&
            (identical(other.resolviendoDireccion, resolviendoDireccion) ||
                other.resolviendoDireccion == resolviendoDireccion) &&
            (identical(other.localizando, localizando) ||
                other.localizando == localizando) &&
            (identical(other.buscandoSugerencias, buscandoSugerencias) ||
                other.buscandoSugerencias == buscandoSugerencias) &&
            const DeepCollectionEquality()
                .equals(other._sugerencias, _sugerencias) &&
            (identical(other.aviso, aviso) || other.aviso == aviso) &&
            (identical(other.objetivo, objetivo) ||
                other.objetivo == objetivo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      lat,
      lng,
      direccionTexto,
      referencia,
      resolviendoDireccion,
      localizando,
      buscandoSugerencias,
      const DeepCollectionEquality().hash(_sugerencias),
      aviso,
      objetivo);

  @override
  String toString() {
    return 'EstadoSelectorUbicacion(lat: $lat, lng: $lng, direccionTexto: $direccionTexto, referencia: $referencia, resolviendoDireccion: $resolviendoDireccion, localizando: $localizando, buscandoSugerencias: $buscandoSugerencias, sugerencias: $sugerencias, aviso: $aviso, objetivo: $objetivo)';
  }
}

/// @nodoc
abstract mixin class _$EstadoSelectorUbicacionCopyWith<$Res>
    implements $EstadoSelectorUbicacionCopyWith<$Res> {
  factory _$EstadoSelectorUbicacionCopyWith(_EstadoSelectorUbicacion value,
          $Res Function(_EstadoSelectorUbicacion) _then) =
      __$EstadoSelectorUbicacionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double lat,
      double lng,
      String direccionTexto,
      String referencia,
      bool resolviendoDireccion,
      bool localizando,
      bool buscandoSugerencias,
      List<SugerenciaDireccion> sugerencias,
      String? aviso,
      ObjetivoCamara? objetivo});

  @override
  $ObjetivoCamaraCopyWith<$Res>? get objetivo;
}

/// @nodoc
class __$EstadoSelectorUbicacionCopyWithImpl<$Res>
    implements _$EstadoSelectorUbicacionCopyWith<$Res> {
  __$EstadoSelectorUbicacionCopyWithImpl(this._self, this._then);

  final _EstadoSelectorUbicacion _self;
  final $Res Function(_EstadoSelectorUbicacion) _then;

  /// Create a copy of EstadoSelectorUbicacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? direccionTexto = null,
    Object? referencia = null,
    Object? resolviendoDireccion = null,
    Object? localizando = null,
    Object? buscandoSugerencias = null,
    Object? sugerencias = null,
    Object? aviso = freezed,
    Object? objetivo = freezed,
  }) {
    return _then(_EstadoSelectorUbicacion(
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      direccionTexto: null == direccionTexto
          ? _self.direccionTexto
          : direccionTexto // ignore: cast_nullable_to_non_nullable
              as String,
      referencia: null == referencia
          ? _self.referencia
          : referencia // ignore: cast_nullable_to_non_nullable
              as String,
      resolviendoDireccion: null == resolviendoDireccion
          ? _self.resolviendoDireccion
          : resolviendoDireccion // ignore: cast_nullable_to_non_nullable
              as bool,
      localizando: null == localizando
          ? _self.localizando
          : localizando // ignore: cast_nullable_to_non_nullable
              as bool,
      buscandoSugerencias: null == buscandoSugerencias
          ? _self.buscandoSugerencias
          : buscandoSugerencias // ignore: cast_nullable_to_non_nullable
              as bool,
      sugerencias: null == sugerencias
          ? _self._sugerencias
          : sugerencias // ignore: cast_nullable_to_non_nullable
              as List<SugerenciaDireccion>,
      aviso: freezed == aviso
          ? _self.aviso
          : aviso // ignore: cast_nullable_to_non_nullable
              as String?,
      objetivo: freezed == objetivo
          ? _self.objetivo
          : objetivo // ignore: cast_nullable_to_non_nullable
              as ObjetivoCamara?,
    ));
  }

  /// Create a copy of EstadoSelectorUbicacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ObjetivoCamaraCopyWith<$Res>? get objetivo {
    if (_self.objetivo == null) {
      return null;
    }

    return $ObjetivoCamaraCopyWith<$Res>(_self.objetivo!, (value) {
      return _then(_self.copyWith(objetivo: value));
    });
  }
}

// dart format on
