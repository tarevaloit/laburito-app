// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pedido {
  String get id;
  String get buscadorId;
  String get categoriaId;

  /// Viene del embed `categorias_oficio(nombre)`. Nulo si la consulta no lo
  /// pidió.
  String? get categoriaNombre;
  String get titulo;
  String get descripcion;
  PedidoUrgencia get urgencia;
  PedidoEstado get estado;
  Ubicacion get ubicacion;
  double? get presupuestoEstimado;
  DateTime get fechaPublicacion;
  DateTime get fechaVencimiento;
  DateTime? get fechaCierre;
  String? get motivoCierre;
  int get renovaciones;
  List<PedidoFoto> get fotos;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PedidoCopyWith<Pedido> get copyWith =>
      _$PedidoCopyWithImpl<Pedido>(this as Pedido, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Pedido &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.buscadorId, buscadorId) ||
                other.buscadorId == buscadorId) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.categoriaNombre, categoriaNombre) ||
                other.categoriaNombre == categoriaNombre) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.urgencia, urgencia) ||
                other.urgencia == urgencia) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            (identical(other.fechaPublicacion, fechaPublicacion) ||
                other.fechaPublicacion == fechaPublicacion) &&
            (identical(other.fechaVencimiento, fechaVencimiento) ||
                other.fechaVencimiento == fechaVencimiento) &&
            (identical(other.fechaCierre, fechaCierre) ||
                other.fechaCierre == fechaCierre) &&
            (identical(other.motivoCierre, motivoCierre) ||
                other.motivoCierre == motivoCierre) &&
            (identical(other.renovaciones, renovaciones) ||
                other.renovaciones == renovaciones) &&
            const DeepCollectionEquality().equals(other.fotos, fotos) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      buscadorId,
      categoriaId,
      categoriaNombre,
      titulo,
      descripcion,
      urgencia,
      estado,
      ubicacion,
      presupuestoEstimado,
      fechaPublicacion,
      fechaVencimiento,
      fechaCierre,
      motivoCierre,
      renovaciones,
      const DeepCollectionEquality().hash(fotos),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Pedido(id: $id, buscadorId: $buscadorId, categoriaId: $categoriaId, categoriaNombre: $categoriaNombre, titulo: $titulo, descripcion: $descripcion, urgencia: $urgencia, estado: $estado, ubicacion: $ubicacion, presupuestoEstimado: $presupuestoEstimado, fechaPublicacion: $fechaPublicacion, fechaVencimiento: $fechaVencimiento, fechaCierre: $fechaCierre, motivoCierre: $motivoCierre, renovaciones: $renovaciones, fotos: $fotos, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $PedidoCopyWith<$Res> {
  factory $PedidoCopyWith(Pedido value, $Res Function(Pedido) _then) =
      _$PedidoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String buscadorId,
      String categoriaId,
      String? categoriaNombre,
      String titulo,
      String descripcion,
      PedidoUrgencia urgencia,
      PedidoEstado estado,
      Ubicacion ubicacion,
      double? presupuestoEstimado,
      DateTime fechaPublicacion,
      DateTime fechaVencimiento,
      DateTime? fechaCierre,
      String? motivoCierre,
      int renovaciones,
      List<PedidoFoto> fotos,
      DateTime createdAt,
      DateTime updatedAt});

  $UbicacionCopyWith<$Res> get ubicacion;
}

/// @nodoc
class _$PedidoCopyWithImpl<$Res> implements $PedidoCopyWith<$Res> {
  _$PedidoCopyWithImpl(this._self, this._then);

  final Pedido _self;
  final $Res Function(Pedido) _then;

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? buscadorId = null,
    Object? categoriaId = null,
    Object? categoriaNombre = freezed,
    Object? titulo = null,
    Object? descripcion = null,
    Object? urgencia = null,
    Object? estado = null,
    Object? ubicacion = null,
    Object? presupuestoEstimado = freezed,
    Object? fechaPublicacion = null,
    Object? fechaVencimiento = null,
    Object? fechaCierre = freezed,
    Object? motivoCierre = freezed,
    Object? renovaciones = null,
    Object? fotos = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      buscadorId: null == buscadorId
          ? _self.buscadorId
          : buscadorId // ignore: cast_nullable_to_non_nullable
              as String,
      categoriaId: null == categoriaId
          ? _self.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
              as String,
      categoriaNombre: freezed == categoriaNombre
          ? _self.categoriaNombre
          : categoriaNombre // ignore: cast_nullable_to_non_nullable
              as String?,
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
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as PedidoEstado,
      ubicacion: null == ubicacion
          ? _self.ubicacion
          : ubicacion // ignore: cast_nullable_to_non_nullable
              as Ubicacion,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      fechaPublicacion: null == fechaPublicacion
          ? _self.fechaPublicacion
          : fechaPublicacion // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaVencimiento: null == fechaVencimiento
          ? _self.fechaVencimiento
          : fechaVencimiento // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaCierre: freezed == fechaCierre
          ? _self.fechaCierre
          : fechaCierre // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      motivoCierre: freezed == motivoCierre
          ? _self.motivoCierre
          : motivoCierre // ignore: cast_nullable_to_non_nullable
              as String?,
      renovaciones: null == renovaciones
          ? _self.renovaciones
          : renovaciones // ignore: cast_nullable_to_non_nullable
              as int,
      fotos: null == fotos
          ? _self.fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<PedidoFoto>,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res> get ubicacion {
    return $UbicacionCopyWith<$Res>(_self.ubicacion, (value) {
      return _then(_self.copyWith(ubicacion: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Pedido].
extension PedidoPatterns on Pedido {
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
    TResult Function(_Pedido value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Pedido() when $default != null:
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
    TResult Function(_Pedido value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pedido():
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
    TResult? Function(_Pedido value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pedido() when $default != null:
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
            String buscadorId,
            String categoriaId,
            String? categoriaNombre,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            PedidoEstado estado,
            Ubicacion ubicacion,
            double? presupuestoEstimado,
            DateTime fechaPublicacion,
            DateTime fechaVencimiento,
            DateTime? fechaCierre,
            String? motivoCierre,
            int renovaciones,
            List<PedidoFoto> fotos,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Pedido() when $default != null:
        return $default(
            _that.id,
            _that.buscadorId,
            _that.categoriaId,
            _that.categoriaNombre,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.estado,
            _that.ubicacion,
            _that.presupuestoEstimado,
            _that.fechaPublicacion,
            _that.fechaVencimiento,
            _that.fechaCierre,
            _that.motivoCierre,
            _that.renovaciones,
            _that.fotos,
            _that.createdAt,
            _that.updatedAt);
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
            String buscadorId,
            String categoriaId,
            String? categoriaNombre,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            PedidoEstado estado,
            Ubicacion ubicacion,
            double? presupuestoEstimado,
            DateTime fechaPublicacion,
            DateTime fechaVencimiento,
            DateTime? fechaCierre,
            String? motivoCierre,
            int renovaciones,
            List<PedidoFoto> fotos,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pedido():
        return $default(
            _that.id,
            _that.buscadorId,
            _that.categoriaId,
            _that.categoriaNombre,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.estado,
            _that.ubicacion,
            _that.presupuestoEstimado,
            _that.fechaPublicacion,
            _that.fechaVencimiento,
            _that.fechaCierre,
            _that.motivoCierre,
            _that.renovaciones,
            _that.fotos,
            _that.createdAt,
            _that.updatedAt);
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
            String buscadorId,
            String categoriaId,
            String? categoriaNombre,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            PedidoEstado estado,
            Ubicacion ubicacion,
            double? presupuestoEstimado,
            DateTime fechaPublicacion,
            DateTime fechaVencimiento,
            DateTime? fechaCierre,
            String? motivoCierre,
            int renovaciones,
            List<PedidoFoto> fotos,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pedido() when $default != null:
        return $default(
            _that.id,
            _that.buscadorId,
            _that.categoriaId,
            _that.categoriaNombre,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.estado,
            _that.ubicacion,
            _that.presupuestoEstimado,
            _that.fechaPublicacion,
            _that.fechaVencimiento,
            _that.fechaCierre,
            _that.motivoCierre,
            _that.renovaciones,
            _that.fotos,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Pedido extends Pedido {
  const _Pedido(
      {required this.id,
      required this.buscadorId,
      required this.categoriaId,
      this.categoriaNombre,
      required this.titulo,
      required this.descripcion,
      required this.urgencia,
      required this.estado,
      required this.ubicacion,
      this.presupuestoEstimado,
      required this.fechaPublicacion,
      required this.fechaVencimiento,
      this.fechaCierre,
      this.motivoCierre,
      this.renovaciones = 0,
      final List<PedidoFoto> fotos = const <PedidoFoto>[],
      required this.createdAt,
      required this.updatedAt})
      : _fotos = fotos,
        super._();

  @override
  final String id;
  @override
  final String buscadorId;
  @override
  final String categoriaId;

  /// Viene del embed `categorias_oficio(nombre)`. Nulo si la consulta no lo
  /// pidió.
  @override
  final String? categoriaNombre;
  @override
  final String titulo;
  @override
  final String descripcion;
  @override
  final PedidoUrgencia urgencia;
  @override
  final PedidoEstado estado;
  @override
  final Ubicacion ubicacion;
  @override
  final double? presupuestoEstimado;
  @override
  final DateTime fechaPublicacion;
  @override
  final DateTime fechaVencimiento;
  @override
  final DateTime? fechaCierre;
  @override
  final String? motivoCierre;
  @override
  @JsonKey()
  final int renovaciones;
  final List<PedidoFoto> _fotos;
  @override
  @JsonKey()
  List<PedidoFoto> get fotos {
    if (_fotos is EqualUnmodifiableListView) return _fotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fotos);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PedidoCopyWith<_Pedido> get copyWith =>
      __$PedidoCopyWithImpl<_Pedido>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Pedido &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.buscadorId, buscadorId) ||
                other.buscadorId == buscadorId) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.categoriaNombre, categoriaNombre) ||
                other.categoriaNombre == categoriaNombre) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.urgencia, urgencia) ||
                other.urgencia == urgencia) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            (identical(other.fechaPublicacion, fechaPublicacion) ||
                other.fechaPublicacion == fechaPublicacion) &&
            (identical(other.fechaVencimiento, fechaVencimiento) ||
                other.fechaVencimiento == fechaVencimiento) &&
            (identical(other.fechaCierre, fechaCierre) ||
                other.fechaCierre == fechaCierre) &&
            (identical(other.motivoCierre, motivoCierre) ||
                other.motivoCierre == motivoCierre) &&
            (identical(other.renovaciones, renovaciones) ||
                other.renovaciones == renovaciones) &&
            const DeepCollectionEquality().equals(other._fotos, _fotos) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      buscadorId,
      categoriaId,
      categoriaNombre,
      titulo,
      descripcion,
      urgencia,
      estado,
      ubicacion,
      presupuestoEstimado,
      fechaPublicacion,
      fechaVencimiento,
      fechaCierre,
      motivoCierre,
      renovaciones,
      const DeepCollectionEquality().hash(_fotos),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Pedido(id: $id, buscadorId: $buscadorId, categoriaId: $categoriaId, categoriaNombre: $categoriaNombre, titulo: $titulo, descripcion: $descripcion, urgencia: $urgencia, estado: $estado, ubicacion: $ubicacion, presupuestoEstimado: $presupuestoEstimado, fechaPublicacion: $fechaPublicacion, fechaVencimiento: $fechaVencimiento, fechaCierre: $fechaCierre, motivoCierre: $motivoCierre, renovaciones: $renovaciones, fotos: $fotos, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$PedidoCopyWith<$Res> implements $PedidoCopyWith<$Res> {
  factory _$PedidoCopyWith(_Pedido value, $Res Function(_Pedido) _then) =
      __$PedidoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String buscadorId,
      String categoriaId,
      String? categoriaNombre,
      String titulo,
      String descripcion,
      PedidoUrgencia urgencia,
      PedidoEstado estado,
      Ubicacion ubicacion,
      double? presupuestoEstimado,
      DateTime fechaPublicacion,
      DateTime fechaVencimiento,
      DateTime? fechaCierre,
      String? motivoCierre,
      int renovaciones,
      List<PedidoFoto> fotos,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $UbicacionCopyWith<$Res> get ubicacion;
}

/// @nodoc
class __$PedidoCopyWithImpl<$Res> implements _$PedidoCopyWith<$Res> {
  __$PedidoCopyWithImpl(this._self, this._then);

  final _Pedido _self;
  final $Res Function(_Pedido) _then;

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? buscadorId = null,
    Object? categoriaId = null,
    Object? categoriaNombre = freezed,
    Object? titulo = null,
    Object? descripcion = null,
    Object? urgencia = null,
    Object? estado = null,
    Object? ubicacion = null,
    Object? presupuestoEstimado = freezed,
    Object? fechaPublicacion = null,
    Object? fechaVencimiento = null,
    Object? fechaCierre = freezed,
    Object? motivoCierre = freezed,
    Object? renovaciones = null,
    Object? fotos = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Pedido(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      buscadorId: null == buscadorId
          ? _self.buscadorId
          : buscadorId // ignore: cast_nullable_to_non_nullable
              as String,
      categoriaId: null == categoriaId
          ? _self.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
              as String,
      categoriaNombre: freezed == categoriaNombre
          ? _self.categoriaNombre
          : categoriaNombre // ignore: cast_nullable_to_non_nullable
              as String?,
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
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as PedidoEstado,
      ubicacion: null == ubicacion
          ? _self.ubicacion
          : ubicacion // ignore: cast_nullable_to_non_nullable
              as Ubicacion,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      fechaPublicacion: null == fechaPublicacion
          ? _self.fechaPublicacion
          : fechaPublicacion // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaVencimiento: null == fechaVencimiento
          ? _self.fechaVencimiento
          : fechaVencimiento // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fechaCierre: freezed == fechaCierre
          ? _self.fechaCierre
          : fechaCierre // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      motivoCierre: freezed == motivoCierre
          ? _self.motivoCierre
          : motivoCierre // ignore: cast_nullable_to_non_nullable
              as String?,
      renovaciones: null == renovaciones
          ? _self.renovaciones
          : renovaciones // ignore: cast_nullable_to_non_nullable
              as int,
      fotos: null == fotos
          ? _self._fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<PedidoFoto>,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of Pedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res> get ubicacion {
    return $UbicacionCopyWith<$Res>(_self.ubicacion, (value) {
      return _then(_self.copyWith(ubicacion: value));
    });
  }
}

// dart format on
