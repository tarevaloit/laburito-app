// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editar_pedido_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoEditarPedido {
  Pedido get original;
  String get categoriaId;
  String get titulo;
  String get descripcion;
  PedidoUrgencia get urgencia;
  Ubicacion get ubicacion;
  double? get presupuestoEstimado;

  /// Las fotos guardadas del pedido. Se editan al instante (subir y borrar
  /// son operaciones sobre Storage, no sobre el formulario), así que esta
  /// lista se actualiza sola y no espera al botón de guardar.
  List<PedidoFoto> get fotos;
  bool get guardando;
  bool get trabajandoConFotos;
  PedidoException? get error;

  /// Create a copy of EstadoEditarPedido
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoEditarPedidoCopyWith<EstadoEditarPedido> get copyWith =>
      _$EstadoEditarPedidoCopyWithImpl<EstadoEditarPedido>(
          this as EstadoEditarPedido, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoEditarPedido &&
            (identical(other.original, original) ||
                other.original == original) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.urgencia, urgencia) ||
                other.urgencia == urgencia) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            const DeepCollectionEquality().equals(other.fotos, fotos) &&
            (identical(other.guardando, guardando) ||
                other.guardando == guardando) &&
            (identical(other.trabajandoConFotos, trabajandoConFotos) ||
                other.trabajandoConFotos == trabajandoConFotos) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      original,
      categoriaId,
      titulo,
      descripcion,
      urgencia,
      ubicacion,
      presupuestoEstimado,
      const DeepCollectionEquality().hash(fotos),
      guardando,
      trabajandoConFotos,
      error);

  @override
  String toString() {
    return 'EstadoEditarPedido(original: $original, categoriaId: $categoriaId, titulo: $titulo, descripcion: $descripcion, urgencia: $urgencia, ubicacion: $ubicacion, presupuestoEstimado: $presupuestoEstimado, fotos: $fotos, guardando: $guardando, trabajandoConFotos: $trabajandoConFotos, error: $error)';
  }
}

/// @nodoc
abstract mixin class $EstadoEditarPedidoCopyWith<$Res> {
  factory $EstadoEditarPedidoCopyWith(
          EstadoEditarPedido value, $Res Function(EstadoEditarPedido) _then) =
      _$EstadoEditarPedidoCopyWithImpl;
  @useResult
  $Res call(
      {Pedido original,
      String categoriaId,
      String titulo,
      String descripcion,
      PedidoUrgencia urgencia,
      Ubicacion ubicacion,
      double? presupuestoEstimado,
      List<PedidoFoto> fotos,
      bool guardando,
      bool trabajandoConFotos,
      PedidoException? error});

  $PedidoCopyWith<$Res> get original;
  $UbicacionCopyWith<$Res> get ubicacion;
}

/// @nodoc
class _$EstadoEditarPedidoCopyWithImpl<$Res>
    implements $EstadoEditarPedidoCopyWith<$Res> {
  _$EstadoEditarPedidoCopyWithImpl(this._self, this._then);

  final EstadoEditarPedido _self;
  final $Res Function(EstadoEditarPedido) _then;

  /// Create a copy of EstadoEditarPedido
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? original = null,
    Object? categoriaId = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? urgencia = null,
    Object? ubicacion = null,
    Object? presupuestoEstimado = freezed,
    Object? fotos = null,
    Object? guardando = null,
    Object? trabajandoConFotos = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      original: null == original
          ? _self.original
          : original // ignore: cast_nullable_to_non_nullable
              as Pedido,
      categoriaId: null == categoriaId
          ? _self.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
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
      ubicacion: null == ubicacion
          ? _self.ubicacion
          : ubicacion // ignore: cast_nullable_to_non_nullable
              as Ubicacion,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      fotos: null == fotos
          ? _self.fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<PedidoFoto>,
      guardando: null == guardando
          ? _self.guardando
          : guardando // ignore: cast_nullable_to_non_nullable
              as bool,
      trabajandoConFotos: null == trabajandoConFotos
          ? _self.trabajandoConFotos
          : trabajandoConFotos // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as PedidoException?,
    ));
  }

  /// Create a copy of EstadoEditarPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PedidoCopyWith<$Res> get original {
    return $PedidoCopyWith<$Res>(_self.original, (value) {
      return _then(_self.copyWith(original: value));
    });
  }

  /// Create a copy of EstadoEditarPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res> get ubicacion {
    return $UbicacionCopyWith<$Res>(_self.ubicacion, (value) {
      return _then(_self.copyWith(ubicacion: value));
    });
  }
}

/// Adds pattern-matching-related methods to [EstadoEditarPedido].
extension EstadoEditarPedidoPatterns on EstadoEditarPedido {
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
    TResult Function(_EstadoEditarPedido value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoEditarPedido() when $default != null:
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
    TResult Function(_EstadoEditarPedido value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoEditarPedido():
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
    TResult? Function(_EstadoEditarPedido value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoEditarPedido() when $default != null:
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
            Pedido original,
            String categoriaId,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            Ubicacion ubicacion,
            double? presupuestoEstimado,
            List<PedidoFoto> fotos,
            bool guardando,
            bool trabajandoConFotos,
            PedidoException? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoEditarPedido() when $default != null:
        return $default(
            _that.original,
            _that.categoriaId,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.ubicacion,
            _that.presupuestoEstimado,
            _that.fotos,
            _that.guardando,
            _that.trabajandoConFotos,
            _that.error);
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
            Pedido original,
            String categoriaId,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            Ubicacion ubicacion,
            double? presupuestoEstimado,
            List<PedidoFoto> fotos,
            bool guardando,
            bool trabajandoConFotos,
            PedidoException? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoEditarPedido():
        return $default(
            _that.original,
            _that.categoriaId,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.ubicacion,
            _that.presupuestoEstimado,
            _that.fotos,
            _that.guardando,
            _that.trabajandoConFotos,
            _that.error);
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
            Pedido original,
            String categoriaId,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            Ubicacion ubicacion,
            double? presupuestoEstimado,
            List<PedidoFoto> fotos,
            bool guardando,
            bool trabajandoConFotos,
            PedidoException? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoEditarPedido() when $default != null:
        return $default(
            _that.original,
            _that.categoriaId,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.ubicacion,
            _that.presupuestoEstimado,
            _that.fotos,
            _that.guardando,
            _that.trabajandoConFotos,
            _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoEditarPedido extends EstadoEditarPedido {
  const _EstadoEditarPedido(
      {required this.original,
      required this.categoriaId,
      required this.titulo,
      required this.descripcion,
      required this.urgencia,
      required this.ubicacion,
      this.presupuestoEstimado,
      final List<PedidoFoto> fotos = const <PedidoFoto>[],
      this.guardando = false,
      this.trabajandoConFotos = false,
      this.error})
      : _fotos = fotos,
        super._();

  @override
  final Pedido original;
  @override
  final String categoriaId;
  @override
  final String titulo;
  @override
  final String descripcion;
  @override
  final PedidoUrgencia urgencia;
  @override
  final Ubicacion ubicacion;
  @override
  final double? presupuestoEstimado;

  /// Las fotos guardadas del pedido. Se editan al instante (subir y borrar
  /// son operaciones sobre Storage, no sobre el formulario), así que esta
  /// lista se actualiza sola y no espera al botón de guardar.
  final List<PedidoFoto> _fotos;

  /// Las fotos guardadas del pedido. Se editan al instante (subir y borrar
  /// son operaciones sobre Storage, no sobre el formulario), así que esta
  /// lista se actualiza sola y no espera al botón de guardar.
  @override
  @JsonKey()
  List<PedidoFoto> get fotos {
    if (_fotos is EqualUnmodifiableListView) return _fotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fotos);
  }

  @override
  @JsonKey()
  final bool guardando;
  @override
  @JsonKey()
  final bool trabajandoConFotos;
  @override
  final PedidoException? error;

  /// Create a copy of EstadoEditarPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoEditarPedidoCopyWith<_EstadoEditarPedido> get copyWith =>
      __$EstadoEditarPedidoCopyWithImpl<_EstadoEditarPedido>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoEditarPedido &&
            (identical(other.original, original) ||
                other.original == original) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.urgencia, urgencia) ||
                other.urgencia == urgencia) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            const DeepCollectionEquality().equals(other._fotos, _fotos) &&
            (identical(other.guardando, guardando) ||
                other.guardando == guardando) &&
            (identical(other.trabajandoConFotos, trabajandoConFotos) ||
                other.trabajandoConFotos == trabajandoConFotos) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      original,
      categoriaId,
      titulo,
      descripcion,
      urgencia,
      ubicacion,
      presupuestoEstimado,
      const DeepCollectionEquality().hash(_fotos),
      guardando,
      trabajandoConFotos,
      error);

  @override
  String toString() {
    return 'EstadoEditarPedido(original: $original, categoriaId: $categoriaId, titulo: $titulo, descripcion: $descripcion, urgencia: $urgencia, ubicacion: $ubicacion, presupuestoEstimado: $presupuestoEstimado, fotos: $fotos, guardando: $guardando, trabajandoConFotos: $trabajandoConFotos, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$EstadoEditarPedidoCopyWith<$Res>
    implements $EstadoEditarPedidoCopyWith<$Res> {
  factory _$EstadoEditarPedidoCopyWith(
          _EstadoEditarPedido value, $Res Function(_EstadoEditarPedido) _then) =
      __$EstadoEditarPedidoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Pedido original,
      String categoriaId,
      String titulo,
      String descripcion,
      PedidoUrgencia urgencia,
      Ubicacion ubicacion,
      double? presupuestoEstimado,
      List<PedidoFoto> fotos,
      bool guardando,
      bool trabajandoConFotos,
      PedidoException? error});

  @override
  $PedidoCopyWith<$Res> get original;
  @override
  $UbicacionCopyWith<$Res> get ubicacion;
}

/// @nodoc
class __$EstadoEditarPedidoCopyWithImpl<$Res>
    implements _$EstadoEditarPedidoCopyWith<$Res> {
  __$EstadoEditarPedidoCopyWithImpl(this._self, this._then);

  final _EstadoEditarPedido _self;
  final $Res Function(_EstadoEditarPedido) _then;

  /// Create a copy of EstadoEditarPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? original = null,
    Object? categoriaId = null,
    Object? titulo = null,
    Object? descripcion = null,
    Object? urgencia = null,
    Object? ubicacion = null,
    Object? presupuestoEstimado = freezed,
    Object? fotos = null,
    Object? guardando = null,
    Object? trabajandoConFotos = null,
    Object? error = freezed,
  }) {
    return _then(_EstadoEditarPedido(
      original: null == original
          ? _self.original
          : original // ignore: cast_nullable_to_non_nullable
              as Pedido,
      categoriaId: null == categoriaId
          ? _self.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
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
      ubicacion: null == ubicacion
          ? _self.ubicacion
          : ubicacion // ignore: cast_nullable_to_non_nullable
              as Ubicacion,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      fotos: null == fotos
          ? _self._fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<PedidoFoto>,
      guardando: null == guardando
          ? _self.guardando
          : guardando // ignore: cast_nullable_to_non_nullable
              as bool,
      trabajandoConFotos: null == trabajandoConFotos
          ? _self.trabajandoConFotos
          : trabajandoConFotos // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as PedidoException?,
    ));
  }

  /// Create a copy of EstadoEditarPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PedidoCopyWith<$Res> get original {
    return $PedidoCopyWith<$Res>(_self.original, (value) {
      return _then(_self.copyWith(original: value));
    });
  }

  /// Create a copy of EstadoEditarPedido
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
