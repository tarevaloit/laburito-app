// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido_tablero.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PedidoTablero {
  String get id;
  String get titulo;
  String get descripcion;
  PedidoUrgencia get urgencia;
  String get categoriaId;
  String get categoriaNombre;
  Ubicacion get ubicacionAproximada;
  DateTime get fechaPublicacion;
  DateTime get fechaVencimiento;
  int get cantidadFotos;
  double? get presupuestoEstimado;

  /// Metros hasta el centro de la zona de cobertura, redondeados a cien.
  /// `null` si el Profesional todavía no configuró su zona (CU-07).
  double? get distanciaM;
  bool get guardado;
  bool get ignorado;

  /// Solo en el tablero: la primera foto, para la tarjeta.
  String? get portada;

  /// Solo en el detalle: todas las rutas, para el carrusel.
  List<String> get fotos;

  /// Create a copy of PedidoTablero
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PedidoTableroCopyWith<PedidoTablero> get copyWith =>
      _$PedidoTableroCopyWithImpl<PedidoTablero>(
          this as PedidoTablero, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PedidoTablero &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.urgencia, urgencia) ||
                other.urgencia == urgencia) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.categoriaNombre, categoriaNombre) ||
                other.categoriaNombre == categoriaNombre) &&
            (identical(other.ubicacionAproximada, ubicacionAproximada) ||
                other.ubicacionAproximada == ubicacionAproximada) &&
            (identical(other.fechaPublicacion, fechaPublicacion) ||
                other.fechaPublicacion == fechaPublicacion) &&
            (identical(other.fechaVencimiento, fechaVencimiento) ||
                other.fechaVencimiento == fechaVencimiento) &&
            (identical(other.cantidadFotos, cantidadFotos) ||
                other.cantidadFotos == cantidadFotos) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            (identical(other.distanciaM, distanciaM) ||
                other.distanciaM == distanciaM) &&
            (identical(other.guardado, guardado) ||
                other.guardado == guardado) &&
            (identical(other.ignorado, ignorado) ||
                other.ignorado == ignorado) &&
            (identical(other.portada, portada) || other.portada == portada) &&
            const DeepCollectionEquality().equals(other.fotos, fotos));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      titulo,
      descripcion,
      urgencia,
      categoriaId,
      categoriaNombre,
      ubicacionAproximada,
      fechaPublicacion,
      fechaVencimiento,
      cantidadFotos,
      presupuestoEstimado,
      distanciaM,
      guardado,
      ignorado,
      portada,
      const DeepCollectionEquality().hash(fotos));

  @override
  String toString() {
    return 'PedidoTablero(id: $id, titulo: $titulo, descripcion: $descripcion, urgencia: $urgencia, categoriaId: $categoriaId, categoriaNombre: $categoriaNombre, ubicacionAproximada: $ubicacionAproximada, fechaPublicacion: $fechaPublicacion, fechaVencimiento: $fechaVencimiento, cantidadFotos: $cantidadFotos, presupuestoEstimado: $presupuestoEstimado, distanciaM: $distanciaM, guardado: $guardado, ignorado: $ignorado, portada: $portada, fotos: $fotos)';
  }
}

/// @nodoc
abstract mixin class $PedidoTableroCopyWith<$Res> {
  factory $PedidoTableroCopyWith(
          PedidoTablero value, $Res Function(PedidoTablero) _then) =
      _$PedidoTableroCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String titulo,
      String descripcion,
      PedidoUrgencia urgencia,
      String categoriaId,
      String categoriaNombre,
      Ubicacion ubicacionAproximada,
      DateTime fechaPublicacion,
      DateTime fechaVencimiento,
      int cantidadFotos,
      double? presupuestoEstimado,
      double? distanciaM,
      bool guardado,
      bool ignorado,
      String? portada,
      List<String> fotos});

  $UbicacionCopyWith<$Res> get ubicacionAproximada;
}

/// @nodoc
class _$PedidoTableroCopyWithImpl<$Res>
    implements $PedidoTableroCopyWith<$Res> {
  _$PedidoTableroCopyWithImpl(this._self, this._then);

  final PedidoTablero _self;
  final $Res Function(PedidoTablero) _then;

  /// Create a copy of PedidoTablero
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? urgencia = null,
    Object? categoriaId = null,
    Object? categoriaNombre = null,
    Object? ubicacionAproximada = null,
    Object? fechaPublicacion = null,
    Object? fechaVencimiento = null,
    Object? cantidadFotos = null,
    Object? presupuestoEstimado = freezed,
    Object? distanciaM = freezed,
    Object? guardado = null,
    Object? ignorado = null,
    Object? portada = freezed,
    Object? fotos = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      titulo: null == titulo
          ? _self.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      urgencia: null == urgencia
          ? _self.urgencia
          : urgencia // ignore: cast_nullable_to_non_nullable
              as PedidoUrgencia,
      categoriaId: null == categoriaId
          ? _self.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
              as String,
      categoriaNombre: null == categoriaNombre
          ? _self.categoriaNombre
          : categoriaNombre // ignore: cast_nullable_to_non_nullable
              as String,
      ubicacionAproximada: null == ubicacionAproximada
          ? _self.ubicacionAproximada
          : ubicacionAproximada // ignore: cast_nullable_to_non_nullable
              as Ubicacion,
      fechaPublicacion: null == fechaPublicacion
          ? _self.fechaPublicacion
          : fechaPublicacion // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaVencimiento: null == fechaVencimiento
          ? _self.fechaVencimiento
          : fechaVencimiento // ignore: cast_nullable_to_non_nullable
              as DateTime,
      cantidadFotos: null == cantidadFotos
          ? _self.cantidadFotos
          : cantidadFotos // ignore: cast_nullable_to_non_nullable
              as int,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      distanciaM: freezed == distanciaM
          ? _self.distanciaM
          : distanciaM // ignore: cast_nullable_to_non_nullable
              as double?,
      guardado: null == guardado
          ? _self.guardado
          : guardado // ignore: cast_nullable_to_non_nullable
              as bool,
      ignorado: null == ignorado
          ? _self.ignorado
          : ignorado // ignore: cast_nullable_to_non_nullable
              as bool,
      portada: freezed == portada
          ? _self.portada
          : portada // ignore: cast_nullable_to_non_nullable
              as String?,
      fotos: null == fotos
          ? _self.fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of PedidoTablero
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res> get ubicacionAproximada {
    return $UbicacionCopyWith<$Res>(_self.ubicacionAproximada, (value) {
      return _then(_self.copyWith(ubicacionAproximada: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PedidoTablero].
extension PedidoTableroPatterns on PedidoTablero {
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
    TResult Function(_PedidoTablero value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PedidoTablero() when $default != null:
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
    TResult Function(_PedidoTablero value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoTablero():
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
    TResult? Function(_PedidoTablero value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoTablero() when $default != null:
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
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            String categoriaId,
            String categoriaNombre,
            Ubicacion ubicacionAproximada,
            DateTime fechaPublicacion,
            DateTime fechaVencimiento,
            int cantidadFotos,
            double? presupuestoEstimado,
            double? distanciaM,
            bool guardado,
            bool ignorado,
            String? portada,
            List<String> fotos)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PedidoTablero() when $default != null:
        return $default(
            _that.id,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.categoriaId,
            _that.categoriaNombre,
            _that.ubicacionAproximada,
            _that.fechaPublicacion,
            _that.fechaVencimiento,
            _that.cantidadFotos,
            _that.presupuestoEstimado,
            _that.distanciaM,
            _that.guardado,
            _that.ignorado,
            _that.portada,
            _that.fotos);
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
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            String categoriaId,
            String categoriaNombre,
            Ubicacion ubicacionAproximada,
            DateTime fechaPublicacion,
            DateTime fechaVencimiento,
            int cantidadFotos,
            double? presupuestoEstimado,
            double? distanciaM,
            bool guardado,
            bool ignorado,
            String? portada,
            List<String> fotos)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoTablero():
        return $default(
            _that.id,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.categoriaId,
            _that.categoriaNombre,
            _that.ubicacionAproximada,
            _that.fechaPublicacion,
            _that.fechaVencimiento,
            _that.cantidadFotos,
            _that.presupuestoEstimado,
            _that.distanciaM,
            _that.guardado,
            _that.ignorado,
            _that.portada,
            _that.fotos);
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
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            String categoriaId,
            String categoriaNombre,
            Ubicacion ubicacionAproximada,
            DateTime fechaPublicacion,
            DateTime fechaVencimiento,
            int cantidadFotos,
            double? presupuestoEstimado,
            double? distanciaM,
            bool guardado,
            bool ignorado,
            String? portada,
            List<String> fotos)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PedidoTablero() when $default != null:
        return $default(
            _that.id,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.categoriaId,
            _that.categoriaNombre,
            _that.ubicacionAproximada,
            _that.fechaPublicacion,
            _that.fechaVencimiento,
            _that.cantidadFotos,
            _that.presupuestoEstimado,
            _that.distanciaM,
            _that.guardado,
            _that.ignorado,
            _that.portada,
            _that.fotos);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PedidoTablero extends PedidoTablero {
  const _PedidoTablero(
      {required this.id,
      required this.titulo,
      required this.descripcion,
      required this.urgencia,
      required this.categoriaId,
      required this.categoriaNombre,
      required this.ubicacionAproximada,
      required this.fechaPublicacion,
      required this.fechaVencimiento,
      required this.cantidadFotos,
      this.presupuestoEstimado,
      this.distanciaM,
      this.guardado = false,
      this.ignorado = false,
      this.portada,
      final List<String> fotos = const <String>[]})
      : _fotos = fotos,
        super._();

  @override
  final String id;
  @override
  final String titulo;
  @override
  final String descripcion;
  @override
  final PedidoUrgencia urgencia;
  @override
  final String categoriaId;
  @override
  final String categoriaNombre;
  @override
  final Ubicacion ubicacionAproximada;
  @override
  final DateTime fechaPublicacion;
  @override
  final DateTime fechaVencimiento;
  @override
  final int cantidadFotos;
  @override
  final double? presupuestoEstimado;

  /// Metros hasta el centro de la zona de cobertura, redondeados a cien.
  /// `null` si el Profesional todavía no configuró su zona (CU-07).
  @override
  final double? distanciaM;
  @override
  @JsonKey()
  final bool guardado;
  @override
  @JsonKey()
  final bool ignorado;

  /// Solo en el tablero: la primera foto, para la tarjeta.
  @override
  final String? portada;

  /// Solo en el detalle: todas las rutas, para el carrusel.
  final List<String> _fotos;

  /// Solo en el detalle: todas las rutas, para el carrusel.
  @override
  @JsonKey()
  List<String> get fotos {
    if (_fotos is EqualUnmodifiableListView) return _fotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fotos);
  }

  /// Create a copy of PedidoTablero
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PedidoTableroCopyWith<_PedidoTablero> get copyWith =>
      __$PedidoTableroCopyWithImpl<_PedidoTablero>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PedidoTablero &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.urgencia, urgencia) ||
                other.urgencia == urgencia) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.categoriaNombre, categoriaNombre) ||
                other.categoriaNombre == categoriaNombre) &&
            (identical(other.ubicacionAproximada, ubicacionAproximada) ||
                other.ubicacionAproximada == ubicacionAproximada) &&
            (identical(other.fechaPublicacion, fechaPublicacion) ||
                other.fechaPublicacion == fechaPublicacion) &&
            (identical(other.fechaVencimiento, fechaVencimiento) ||
                other.fechaVencimiento == fechaVencimiento) &&
            (identical(other.cantidadFotos, cantidadFotos) ||
                other.cantidadFotos == cantidadFotos) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            (identical(other.distanciaM, distanciaM) ||
                other.distanciaM == distanciaM) &&
            (identical(other.guardado, guardado) ||
                other.guardado == guardado) &&
            (identical(other.ignorado, ignorado) ||
                other.ignorado == ignorado) &&
            (identical(other.portada, portada) || other.portada == portada) &&
            const DeepCollectionEquality().equals(other._fotos, _fotos));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      titulo,
      descripcion,
      urgencia,
      categoriaId,
      categoriaNombre,
      ubicacionAproximada,
      fechaPublicacion,
      fechaVencimiento,
      cantidadFotos,
      presupuestoEstimado,
      distanciaM,
      guardado,
      ignorado,
      portada,
      const DeepCollectionEquality().hash(_fotos));

  @override
  String toString() {
    return 'PedidoTablero(id: $id, titulo: $titulo, descripcion: $descripcion, urgencia: $urgencia, categoriaId: $categoriaId, categoriaNombre: $categoriaNombre, ubicacionAproximada: $ubicacionAproximada, fechaPublicacion: $fechaPublicacion, fechaVencimiento: $fechaVencimiento, cantidadFotos: $cantidadFotos, presupuestoEstimado: $presupuestoEstimado, distanciaM: $distanciaM, guardado: $guardado, ignorado: $ignorado, portada: $portada, fotos: $fotos)';
  }
}

/// @nodoc
abstract mixin class _$PedidoTableroCopyWith<$Res>
    implements $PedidoTableroCopyWith<$Res> {
  factory _$PedidoTableroCopyWith(
          _PedidoTablero value, $Res Function(_PedidoTablero) _then) =
      __$PedidoTableroCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String titulo,
      String descripcion,
      PedidoUrgencia urgencia,
      String categoriaId,
      String categoriaNombre,
      Ubicacion ubicacionAproximada,
      DateTime fechaPublicacion,
      DateTime fechaVencimiento,
      int cantidadFotos,
      double? presupuestoEstimado,
      double? distanciaM,
      bool guardado,
      bool ignorado,
      String? portada,
      List<String> fotos});

  @override
  $UbicacionCopyWith<$Res> get ubicacionAproximada;
}

/// @nodoc
class __$PedidoTableroCopyWithImpl<$Res>
    implements _$PedidoTableroCopyWith<$Res> {
  __$PedidoTableroCopyWithImpl(this._self, this._then);

  final _PedidoTablero _self;
  final $Res Function(_PedidoTablero) _then;

  /// Create a copy of PedidoTablero
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? urgencia = null,
    Object? categoriaId = null,
    Object? categoriaNombre = null,
    Object? ubicacionAproximada = null,
    Object? fechaPublicacion = null,
    Object? fechaVencimiento = null,
    Object? cantidadFotos = null,
    Object? presupuestoEstimado = freezed,
    Object? distanciaM = freezed,
    Object? guardado = null,
    Object? ignorado = null,
    Object? portada = freezed,
    Object? fotos = null,
  }) {
    return _then(_PedidoTablero(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      titulo: null == titulo
          ? _self.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      descripcion: null == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String,
      urgencia: null == urgencia
          ? _self.urgencia
          : urgencia // ignore: cast_nullable_to_non_nullable
              as PedidoUrgencia,
      categoriaId: null == categoriaId
          ? _self.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
              as String,
      categoriaNombre: null == categoriaNombre
          ? _self.categoriaNombre
          : categoriaNombre // ignore: cast_nullable_to_non_nullable
              as String,
      ubicacionAproximada: null == ubicacionAproximada
          ? _self.ubicacionAproximada
          : ubicacionAproximada // ignore: cast_nullable_to_non_nullable
              as Ubicacion,
      fechaPublicacion: null == fechaPublicacion
          ? _self.fechaPublicacion
          : fechaPublicacion // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaVencimiento: null == fechaVencimiento
          ? _self.fechaVencimiento
          : fechaVencimiento // ignore: cast_nullable_to_non_nullable
              as DateTime,
      cantidadFotos: null == cantidadFotos
          ? _self.cantidadFotos
          : cantidadFotos // ignore: cast_nullable_to_non_nullable
              as int,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      distanciaM: freezed == distanciaM
          ? _self.distanciaM
          : distanciaM // ignore: cast_nullable_to_non_nullable
              as double?,
      guardado: null == guardado
          ? _self.guardado
          : guardado // ignore: cast_nullable_to_non_nullable
              as bool,
      ignorado: null == ignorado
          ? _self.ignorado
          : ignorado // ignore: cast_nullable_to_non_nullable
              as bool,
      portada: freezed == portada
          ? _self.portada
          : portada // ignore: cast_nullable_to_non_nullable
              as String?,
      fotos: null == fotos
          ? _self._fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of PedidoTablero
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res> get ubicacionAproximada {
    return $UbicacionCopyWith<$Res>(_self.ubicacionAproximada, (value) {
      return _then(_self.copyWith(ubicacionAproximada: value));
    });
  }
}

// dart format on
