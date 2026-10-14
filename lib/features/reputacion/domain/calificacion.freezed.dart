// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calificacion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MiContacto {
  String get pedidoId;
  String get titulo;
  String get estadoPedido;
  String get nombreCorto;
  String? get telefono;
  DateTime get desbloqueadoAt;
  bool get calificado;
  int? get puntaje;

  /// Create a copy of MiContacto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MiContactoCopyWith<MiContacto> get copyWith =>
      _$MiContactoCopyWithImpl<MiContacto>(this as MiContacto, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MiContacto &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.estadoPedido, estadoPedido) ||
                other.estadoPedido == estadoPedido) &&
            (identical(other.nombreCorto, nombreCorto) ||
                other.nombreCorto == nombreCorto) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.desbloqueadoAt, desbloqueadoAt) ||
                other.desbloqueadoAt == desbloqueadoAt) &&
            (identical(other.calificado, calificado) ||
                other.calificado == calificado) &&
            (identical(other.puntaje, puntaje) || other.puntaje == puntaje));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pedidoId, titulo, estadoPedido,
      nombreCorto, telefono, desbloqueadoAt, calificado, puntaje);

  @override
  String toString() {
    return 'MiContacto(pedidoId: $pedidoId, titulo: $titulo, estadoPedido: $estadoPedido, nombreCorto: $nombreCorto, telefono: $telefono, desbloqueadoAt: $desbloqueadoAt, calificado: $calificado, puntaje: $puntaje)';
  }
}

/// @nodoc
abstract mixin class $MiContactoCopyWith<$Res> {
  factory $MiContactoCopyWith(
          MiContacto value, $Res Function(MiContacto) _then) =
      _$MiContactoCopyWithImpl;
  @useResult
  $Res call(
      {String pedidoId,
      String titulo,
      String estadoPedido,
      String nombreCorto,
      String? telefono,
      DateTime desbloqueadoAt,
      bool calificado,
      int? puntaje});
}

/// @nodoc
class _$MiContactoCopyWithImpl<$Res> implements $MiContactoCopyWith<$Res> {
  _$MiContactoCopyWithImpl(this._self, this._then);

  final MiContacto _self;
  final $Res Function(MiContacto) _then;

  /// Create a copy of MiContacto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pedidoId = null,
    Object? titulo = null,
    Object? estadoPedido = null,
    Object? nombreCorto = null,
    Object? telefono = freezed,
    Object? desbloqueadoAt = null,
    Object? calificado = null,
    Object? puntaje = freezed,
  }) {
    return _then(_self.copyWith(
      pedidoId: null == pedidoId
          ? _self.pedidoId
          : pedidoId // ignore: cast_nullable_to_non_nullable
              as String,
      titulo: null == titulo
          ? _self.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      estadoPedido: null == estadoPedido
          ? _self.estadoPedido
          : estadoPedido // ignore: cast_nullable_to_non_nullable
              as String,
      nombreCorto: null == nombreCorto
          ? _self.nombreCorto
          : nombreCorto // ignore: cast_nullable_to_non_nullable
              as String,
      telefono: freezed == telefono
          ? _self.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      desbloqueadoAt: null == desbloqueadoAt
          ? _self.desbloqueadoAt
          : desbloqueadoAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      calificado: null == calificado
          ? _self.calificado
          : calificado // ignore: cast_nullable_to_non_nullable
              as bool,
      puntaje: freezed == puntaje
          ? _self.puntaje
          : puntaje // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MiContacto].
extension MiContactoPatterns on MiContacto {
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
    TResult Function(_MiContacto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MiContacto() when $default != null:
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
    TResult Function(_MiContacto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MiContacto():
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
    TResult? Function(_MiContacto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MiContacto() when $default != null:
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
            String pedidoId,
            String titulo,
            String estadoPedido,
            String nombreCorto,
            String? telefono,
            DateTime desbloqueadoAt,
            bool calificado,
            int? puntaje)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MiContacto() when $default != null:
        return $default(
            _that.pedidoId,
            _that.titulo,
            _that.estadoPedido,
            _that.nombreCorto,
            _that.telefono,
            _that.desbloqueadoAt,
            _that.calificado,
            _that.puntaje);
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
            String pedidoId,
            String titulo,
            String estadoPedido,
            String nombreCorto,
            String? telefono,
            DateTime desbloqueadoAt,
            bool calificado,
            int? puntaje)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MiContacto():
        return $default(
            _that.pedidoId,
            _that.titulo,
            _that.estadoPedido,
            _that.nombreCorto,
            _that.telefono,
            _that.desbloqueadoAt,
            _that.calificado,
            _that.puntaje);
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
            String pedidoId,
            String titulo,
            String estadoPedido,
            String nombreCorto,
            String? telefono,
            DateTime desbloqueadoAt,
            bool calificado,
            int? puntaje)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MiContacto() when $default != null:
        return $default(
            _that.pedidoId,
            _that.titulo,
            _that.estadoPedido,
            _that.nombreCorto,
            _that.telefono,
            _that.desbloqueadoAt,
            _that.calificado,
            _that.puntaje);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MiContacto extends MiContacto {
  const _MiContacto(
      {required this.pedidoId,
      required this.titulo,
      required this.estadoPedido,
      required this.nombreCorto,
      this.telefono,
      required this.desbloqueadoAt,
      this.calificado = false,
      this.puntaje})
      : super._();

  @override
  final String pedidoId;
  @override
  final String titulo;
  @override
  final String estadoPedido;
  @override
  final String nombreCorto;
  @override
  final String? telefono;
  @override
  final DateTime desbloqueadoAt;
  @override
  @JsonKey()
  final bool calificado;
  @override
  final int? puntaje;

  /// Create a copy of MiContacto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MiContactoCopyWith<_MiContacto> get copyWith =>
      __$MiContactoCopyWithImpl<_MiContacto>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MiContacto &&
            (identical(other.pedidoId, pedidoId) ||
                other.pedidoId == pedidoId) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.estadoPedido, estadoPedido) ||
                other.estadoPedido == estadoPedido) &&
            (identical(other.nombreCorto, nombreCorto) ||
                other.nombreCorto == nombreCorto) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.desbloqueadoAt, desbloqueadoAt) ||
                other.desbloqueadoAt == desbloqueadoAt) &&
            (identical(other.calificado, calificado) ||
                other.calificado == calificado) &&
            (identical(other.puntaje, puntaje) || other.puntaje == puntaje));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pedidoId, titulo, estadoPedido,
      nombreCorto, telefono, desbloqueadoAt, calificado, puntaje);

  @override
  String toString() {
    return 'MiContacto(pedidoId: $pedidoId, titulo: $titulo, estadoPedido: $estadoPedido, nombreCorto: $nombreCorto, telefono: $telefono, desbloqueadoAt: $desbloqueadoAt, calificado: $calificado, puntaje: $puntaje)';
  }
}

/// @nodoc
abstract mixin class _$MiContactoCopyWith<$Res>
    implements $MiContactoCopyWith<$Res> {
  factory _$MiContactoCopyWith(
          _MiContacto value, $Res Function(_MiContacto) _then) =
      __$MiContactoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String pedidoId,
      String titulo,
      String estadoPedido,
      String nombreCorto,
      String? telefono,
      DateTime desbloqueadoAt,
      bool calificado,
      int? puntaje});
}

/// @nodoc
class __$MiContactoCopyWithImpl<$Res> implements _$MiContactoCopyWith<$Res> {
  __$MiContactoCopyWithImpl(this._self, this._then);

  final _MiContacto _self;
  final $Res Function(_MiContacto) _then;

  /// Create a copy of MiContacto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? pedidoId = null,
    Object? titulo = null,
    Object? estadoPedido = null,
    Object? nombreCorto = null,
    Object? telefono = freezed,
    Object? desbloqueadoAt = null,
    Object? calificado = null,
    Object? puntaje = freezed,
  }) {
    return _then(_MiContacto(
      pedidoId: null == pedidoId
          ? _self.pedidoId
          : pedidoId // ignore: cast_nullable_to_non_nullable
              as String,
      titulo: null == titulo
          ? _self.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      estadoPedido: null == estadoPedido
          ? _self.estadoPedido
          : estadoPedido // ignore: cast_nullable_to_non_nullable
              as String,
      nombreCorto: null == nombreCorto
          ? _self.nombreCorto
          : nombreCorto // ignore: cast_nullable_to_non_nullable
              as String,
      telefono: freezed == telefono
          ? _self.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      desbloqueadoAt: null == desbloqueadoAt
          ? _self.desbloqueadoAt
          : desbloqueadoAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      calificado: null == calificado
          ? _self.calificado
          : calificado // ignore: cast_nullable_to_non_nullable
              as bool,
      puntaje: freezed == puntaje
          ? _self.puntaje
          : puntaje // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$EnlaceCalificacion {
  EstadoEnlaceCalificacion get estado;
  String? get nombre;
  String? get apellido;
  String? get avatarUrl;

  /// Create a copy of EnlaceCalificacion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EnlaceCalificacionCopyWith<EnlaceCalificacion> get copyWith =>
      _$EnlaceCalificacionCopyWithImpl<EnlaceCalificacion>(
          this as EnlaceCalificacion, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EnlaceCalificacion &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, estado, nombre, apellido, avatarUrl);

  @override
  String toString() {
    return 'EnlaceCalificacion(estado: $estado, nombre: $nombre, apellido: $apellido, avatarUrl: $avatarUrl)';
  }
}

/// @nodoc
abstract mixin class $EnlaceCalificacionCopyWith<$Res> {
  factory $EnlaceCalificacionCopyWith(
          EnlaceCalificacion value, $Res Function(EnlaceCalificacion) _then) =
      _$EnlaceCalificacionCopyWithImpl;
  @useResult
  $Res call(
      {EstadoEnlaceCalificacion estado,
      String? nombre,
      String? apellido,
      String? avatarUrl});
}

/// @nodoc
class _$EnlaceCalificacionCopyWithImpl<$Res>
    implements $EnlaceCalificacionCopyWith<$Res> {
  _$EnlaceCalificacionCopyWithImpl(this._self, this._then);

  final EnlaceCalificacion _self;
  final $Res Function(EnlaceCalificacion) _then;

  /// Create a copy of EnlaceCalificacion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estado = null,
    Object? nombre = freezed,
    Object? apellido = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_self.copyWith(
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoEnlaceCalificacion,
      nombre: freezed == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      apellido: freezed == apellido
          ? _self.apellido
          : apellido // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EnlaceCalificacion].
extension EnlaceCalificacionPatterns on EnlaceCalificacion {
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
    TResult Function(_EnlaceCalificacion value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EnlaceCalificacion() when $default != null:
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
    TResult Function(_EnlaceCalificacion value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EnlaceCalificacion():
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
    TResult? Function(_EnlaceCalificacion value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EnlaceCalificacion() when $default != null:
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
    TResult Function(EstadoEnlaceCalificacion estado, String? nombre,
            String? apellido, String? avatarUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EnlaceCalificacion() when $default != null:
        return $default(
            _that.estado, _that.nombre, _that.apellido, _that.avatarUrl);
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
    TResult Function(EstadoEnlaceCalificacion estado, String? nombre,
            String? apellido, String? avatarUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EnlaceCalificacion():
        return $default(
            _that.estado, _that.nombre, _that.apellido, _that.avatarUrl);
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
    TResult? Function(EstadoEnlaceCalificacion estado, String? nombre,
            String? apellido, String? avatarUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EnlaceCalificacion() when $default != null:
        return $default(
            _that.estado, _that.nombre, _that.apellido, _that.avatarUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EnlaceCalificacion extends EnlaceCalificacion {
  const _EnlaceCalificacion(
      {required this.estado, this.nombre, this.apellido, this.avatarUrl})
      : super._();

  @override
  final EstadoEnlaceCalificacion estado;
  @override
  final String? nombre;
  @override
  final String? apellido;
  @override
  final String? avatarUrl;

  /// Create a copy of EnlaceCalificacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EnlaceCalificacionCopyWith<_EnlaceCalificacion> get copyWith =>
      __$EnlaceCalificacionCopyWithImpl<_EnlaceCalificacion>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EnlaceCalificacion &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, estado, nombre, apellido, avatarUrl);

  @override
  String toString() {
    return 'EnlaceCalificacion(estado: $estado, nombre: $nombre, apellido: $apellido, avatarUrl: $avatarUrl)';
  }
}

/// @nodoc
abstract mixin class _$EnlaceCalificacionCopyWith<$Res>
    implements $EnlaceCalificacionCopyWith<$Res> {
  factory _$EnlaceCalificacionCopyWith(
          _EnlaceCalificacion value, $Res Function(_EnlaceCalificacion) _then) =
      __$EnlaceCalificacionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {EstadoEnlaceCalificacion estado,
      String? nombre,
      String? apellido,
      String? avatarUrl});
}

/// @nodoc
class __$EnlaceCalificacionCopyWithImpl<$Res>
    implements _$EnlaceCalificacionCopyWith<$Res> {
  __$EnlaceCalificacionCopyWithImpl(this._self, this._then);

  final _EnlaceCalificacion _self;
  final $Res Function(_EnlaceCalificacion) _then;

  /// Create a copy of EnlaceCalificacion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? estado = null,
    Object? nombre = freezed,
    Object? apellido = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_EnlaceCalificacion(
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as EstadoEnlaceCalificacion,
      nombre: freezed == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String?,
      apellido: freezed == apellido
          ? _self.apellido
          : apellido // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
