// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crear_pedido_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EstadoCrearPedido {
  PasoCrearPedido get paso;
  String? get categoriaId;
  String get titulo;
  String get descripcion;
  PedidoUrgencia get urgencia;
  Ubicacion? get ubicacion;
  List<FotoPendiente> get fotos;
  int get diasVigencia;
  double? get presupuestoEstimado;
  bool get enviando;
  PedidoException? get error;

  /// Fotos que no se pudieron subir después de crear el pedido. El pedido
  /// ya quedó publicado igual: una foto que falla no deshace el alta.
  List<String> get erroresFotos;
  Pedido? get pedidoCreado;

  /// Create a copy of EstadoCrearPedido
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstadoCrearPedidoCopyWith<EstadoCrearPedido> get copyWith =>
      _$EstadoCrearPedidoCopyWithImpl<EstadoCrearPedido>(
          this as EstadoCrearPedido, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EstadoCrearPedido &&
            (identical(other.paso, paso) || other.paso == paso) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.urgencia, urgencia) ||
                other.urgencia == urgencia) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            const DeepCollectionEquality().equals(other.fotos, fotos) &&
            (identical(other.diasVigencia, diasVigencia) ||
                other.diasVigencia == diasVigencia) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            (identical(other.enviando, enviando) ||
                other.enviando == enviando) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other.erroresFotos, erroresFotos) &&
            (identical(other.pedidoCreado, pedidoCreado) ||
                other.pedidoCreado == pedidoCreado));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      paso,
      categoriaId,
      titulo,
      descripcion,
      urgencia,
      ubicacion,
      const DeepCollectionEquality().hash(fotos),
      diasVigencia,
      presupuestoEstimado,
      enviando,
      error,
      const DeepCollectionEquality().hash(erroresFotos),
      pedidoCreado);

  @override
  String toString() {
    return 'EstadoCrearPedido(paso: $paso, categoriaId: $categoriaId, titulo: $titulo, descripcion: $descripcion, urgencia: $urgencia, ubicacion: $ubicacion, fotos: $fotos, diasVigencia: $diasVigencia, presupuestoEstimado: $presupuestoEstimado, enviando: $enviando, error: $error, erroresFotos: $erroresFotos, pedidoCreado: $pedidoCreado)';
  }
}

/// @nodoc
abstract mixin class $EstadoCrearPedidoCopyWith<$Res> {
  factory $EstadoCrearPedidoCopyWith(
          EstadoCrearPedido value, $Res Function(EstadoCrearPedido) _then) =
      _$EstadoCrearPedidoCopyWithImpl;
  @useResult
  $Res call(
      {PasoCrearPedido paso,
      String? categoriaId,
      String titulo,
      String descripcion,
      PedidoUrgencia urgencia,
      Ubicacion? ubicacion,
      List<FotoPendiente> fotos,
      int diasVigencia,
      double? presupuestoEstimado,
      bool enviando,
      PedidoException? error,
      List<String> erroresFotos,
      Pedido? pedidoCreado});

  $UbicacionCopyWith<$Res>? get ubicacion;
  $PedidoCopyWith<$Res>? get pedidoCreado;
}

/// @nodoc
class _$EstadoCrearPedidoCopyWithImpl<$Res>
    implements $EstadoCrearPedidoCopyWith<$Res> {
  _$EstadoCrearPedidoCopyWithImpl(this._self, this._then);

  final EstadoCrearPedido _self;
  final $Res Function(EstadoCrearPedido) _then;

  /// Create a copy of EstadoCrearPedido
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paso = null,
    Object? categoriaId = freezed,
    Object? titulo = null,
    Object? descripcion = null,
    Object? urgencia = null,
    Object? ubicacion = freezed,
    Object? fotos = null,
    Object? diasVigencia = null,
    Object? presupuestoEstimado = freezed,
    Object? enviando = null,
    Object? error = freezed,
    Object? erroresFotos = null,
    Object? pedidoCreado = freezed,
  }) {
    return _then(_self.copyWith(
      paso: null == paso
          ? _self.paso
          : paso // ignore: cast_nullable_to_non_nullable
              as PasoCrearPedido,
      categoriaId: freezed == categoriaId
          ? _self.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
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
      ubicacion: freezed == ubicacion
          ? _self.ubicacion
          : ubicacion // ignore: cast_nullable_to_non_nullable
              as Ubicacion?,
      fotos: null == fotos
          ? _self.fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<FotoPendiente>,
      diasVigencia: null == diasVigencia
          ? _self.diasVigencia
          : diasVigencia // ignore: cast_nullable_to_non_nullable
              as int,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      enviando: null == enviando
          ? _self.enviando
          : enviando // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as PedidoException?,
      erroresFotos: null == erroresFotos
          ? _self.erroresFotos
          : erroresFotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pedidoCreado: freezed == pedidoCreado
          ? _self.pedidoCreado
          : pedidoCreado // ignore: cast_nullable_to_non_nullable
              as Pedido?,
    ));
  }

  /// Create a copy of EstadoCrearPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res>? get ubicacion {
    if (_self.ubicacion == null) {
      return null;
    }

    return $UbicacionCopyWith<$Res>(_self.ubicacion!, (value) {
      return _then(_self.copyWith(ubicacion: value));
    });
  }

  /// Create a copy of EstadoCrearPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PedidoCopyWith<$Res>? get pedidoCreado {
    if (_self.pedidoCreado == null) {
      return null;
    }

    return $PedidoCopyWith<$Res>(_self.pedidoCreado!, (value) {
      return _then(_self.copyWith(pedidoCreado: value));
    });
  }
}

/// Adds pattern-matching-related methods to [EstadoCrearPedido].
extension EstadoCrearPedidoPatterns on EstadoCrearPedido {
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
    TResult Function(_EstadoCrearPedido value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoCrearPedido() when $default != null:
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
    TResult Function(_EstadoCrearPedido value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoCrearPedido():
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
    TResult? Function(_EstadoCrearPedido value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoCrearPedido() when $default != null:
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
            PasoCrearPedido paso,
            String? categoriaId,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            Ubicacion? ubicacion,
            List<FotoPendiente> fotos,
            int diasVigencia,
            double? presupuestoEstimado,
            bool enviando,
            PedidoException? error,
            List<String> erroresFotos,
            Pedido? pedidoCreado)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EstadoCrearPedido() when $default != null:
        return $default(
            _that.paso,
            _that.categoriaId,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.ubicacion,
            _that.fotos,
            _that.diasVigencia,
            _that.presupuestoEstimado,
            _that.enviando,
            _that.error,
            _that.erroresFotos,
            _that.pedidoCreado);
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
            PasoCrearPedido paso,
            String? categoriaId,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            Ubicacion? ubicacion,
            List<FotoPendiente> fotos,
            int diasVigencia,
            double? presupuestoEstimado,
            bool enviando,
            PedidoException? error,
            List<String> erroresFotos,
            Pedido? pedidoCreado)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoCrearPedido():
        return $default(
            _that.paso,
            _that.categoriaId,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.ubicacion,
            _that.fotos,
            _that.diasVigencia,
            _that.presupuestoEstimado,
            _that.enviando,
            _that.error,
            _that.erroresFotos,
            _that.pedidoCreado);
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
            PasoCrearPedido paso,
            String? categoriaId,
            String titulo,
            String descripcion,
            PedidoUrgencia urgencia,
            Ubicacion? ubicacion,
            List<FotoPendiente> fotos,
            int diasVigencia,
            double? presupuestoEstimado,
            bool enviando,
            PedidoException? error,
            List<String> erroresFotos,
            Pedido? pedidoCreado)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EstadoCrearPedido() when $default != null:
        return $default(
            _that.paso,
            _that.categoriaId,
            _that.titulo,
            _that.descripcion,
            _that.urgencia,
            _that.ubicacion,
            _that.fotos,
            _that.diasVigencia,
            _that.presupuestoEstimado,
            _that.enviando,
            _that.error,
            _that.erroresFotos,
            _that.pedidoCreado);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EstadoCrearPedido extends EstadoCrearPedido {
  const _EstadoCrearPedido(
      {this.paso = PasoCrearPedido.queNecesitas,
      this.categoriaId,
      this.titulo = '',
      this.descripcion = '',
      this.urgencia = PedidoUrgencia.media,
      this.ubicacion,
      final List<FotoPendiente> fotos = const <FotoPendiente>[],
      this.diasVigencia = 7,
      this.presupuestoEstimado,
      this.enviando = false,
      this.error,
      final List<String> erroresFotos = const <String>[],
      this.pedidoCreado})
      : _fotos = fotos,
        _erroresFotos = erroresFotos,
        super._();

  @override
  @JsonKey()
  final PasoCrearPedido paso;
  @override
  final String? categoriaId;
  @override
  @JsonKey()
  final String titulo;
  @override
  @JsonKey()
  final String descripcion;
  @override
  @JsonKey()
  final PedidoUrgencia urgencia;
  @override
  final Ubicacion? ubicacion;
  final List<FotoPendiente> _fotos;
  @override
  @JsonKey()
  List<FotoPendiente> get fotos {
    if (_fotos is EqualUnmodifiableListView) return _fotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fotos);
  }

  @override
  @JsonKey()
  final int diasVigencia;
  @override
  final double? presupuestoEstimado;
  @override
  @JsonKey()
  final bool enviando;
  @override
  final PedidoException? error;

  /// Fotos que no se pudieron subir después de crear el pedido. El pedido
  /// ya quedó publicado igual: una foto que falla no deshace el alta.
  final List<String> _erroresFotos;

  /// Fotos que no se pudieron subir después de crear el pedido. El pedido
  /// ya quedó publicado igual: una foto que falla no deshace el alta.
  @override
  @JsonKey()
  List<String> get erroresFotos {
    if (_erroresFotos is EqualUnmodifiableListView) return _erroresFotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_erroresFotos);
  }

  @override
  final Pedido? pedidoCreado;

  /// Create a copy of EstadoCrearPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstadoCrearPedidoCopyWith<_EstadoCrearPedido> get copyWith =>
      __$EstadoCrearPedidoCopyWithImpl<_EstadoCrearPedido>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EstadoCrearPedido &&
            (identical(other.paso, paso) || other.paso == paso) &&
            (identical(other.categoriaId, categoriaId) ||
                other.categoriaId == categoriaId) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.urgencia, urgencia) ||
                other.urgencia == urgencia) &&
            (identical(other.ubicacion, ubicacion) ||
                other.ubicacion == ubicacion) &&
            const DeepCollectionEquality().equals(other._fotos, _fotos) &&
            (identical(other.diasVigencia, diasVigencia) ||
                other.diasVigencia == diasVigencia) &&
            (identical(other.presupuestoEstimado, presupuestoEstimado) ||
                other.presupuestoEstimado == presupuestoEstimado) &&
            (identical(other.enviando, enviando) ||
                other.enviando == enviando) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._erroresFotos, _erroresFotos) &&
            (identical(other.pedidoCreado, pedidoCreado) ||
                other.pedidoCreado == pedidoCreado));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      paso,
      categoriaId,
      titulo,
      descripcion,
      urgencia,
      ubicacion,
      const DeepCollectionEquality().hash(_fotos),
      diasVigencia,
      presupuestoEstimado,
      enviando,
      error,
      const DeepCollectionEquality().hash(_erroresFotos),
      pedidoCreado);

  @override
  String toString() {
    return 'EstadoCrearPedido(paso: $paso, categoriaId: $categoriaId, titulo: $titulo, descripcion: $descripcion, urgencia: $urgencia, ubicacion: $ubicacion, fotos: $fotos, diasVigencia: $diasVigencia, presupuestoEstimado: $presupuestoEstimado, enviando: $enviando, error: $error, erroresFotos: $erroresFotos, pedidoCreado: $pedidoCreado)';
  }
}

/// @nodoc
abstract mixin class _$EstadoCrearPedidoCopyWith<$Res>
    implements $EstadoCrearPedidoCopyWith<$Res> {
  factory _$EstadoCrearPedidoCopyWith(
          _EstadoCrearPedido value, $Res Function(_EstadoCrearPedido) _then) =
      __$EstadoCrearPedidoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {PasoCrearPedido paso,
      String? categoriaId,
      String titulo,
      String descripcion,
      PedidoUrgencia urgencia,
      Ubicacion? ubicacion,
      List<FotoPendiente> fotos,
      int diasVigencia,
      double? presupuestoEstimado,
      bool enviando,
      PedidoException? error,
      List<String> erroresFotos,
      Pedido? pedidoCreado});

  @override
  $UbicacionCopyWith<$Res>? get ubicacion;
  @override
  $PedidoCopyWith<$Res>? get pedidoCreado;
}

/// @nodoc
class __$EstadoCrearPedidoCopyWithImpl<$Res>
    implements _$EstadoCrearPedidoCopyWith<$Res> {
  __$EstadoCrearPedidoCopyWithImpl(this._self, this._then);

  final _EstadoCrearPedido _self;
  final $Res Function(_EstadoCrearPedido) _then;

  /// Create a copy of EstadoCrearPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? paso = null,
    Object? categoriaId = freezed,
    Object? titulo = null,
    Object? descripcion = null,
    Object? urgencia = null,
    Object? ubicacion = freezed,
    Object? fotos = null,
    Object? diasVigencia = null,
    Object? presupuestoEstimado = freezed,
    Object? enviando = null,
    Object? error = freezed,
    Object? erroresFotos = null,
    Object? pedidoCreado = freezed,
  }) {
    return _then(_EstadoCrearPedido(
      paso: null == paso
          ? _self.paso
          : paso // ignore: cast_nullable_to_non_nullable
              as PasoCrearPedido,
      categoriaId: freezed == categoriaId
          ? _self.categoriaId
          : categoriaId // ignore: cast_nullable_to_non_nullable
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
      ubicacion: freezed == ubicacion
          ? _self.ubicacion
          : ubicacion // ignore: cast_nullable_to_non_nullable
              as Ubicacion?,
      fotos: null == fotos
          ? _self._fotos
          : fotos // ignore: cast_nullable_to_non_nullable
              as List<FotoPendiente>,
      diasVigencia: null == diasVigencia
          ? _self.diasVigencia
          : diasVigencia // ignore: cast_nullable_to_non_nullable
              as int,
      presupuestoEstimado: freezed == presupuestoEstimado
          ? _self.presupuestoEstimado
          : presupuestoEstimado // ignore: cast_nullable_to_non_nullable
              as double?,
      enviando: null == enviando
          ? _self.enviando
          : enviando // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as PedidoException?,
      erroresFotos: null == erroresFotos
          ? _self._erroresFotos
          : erroresFotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pedidoCreado: freezed == pedidoCreado
          ? _self.pedidoCreado
          : pedidoCreado // ignore: cast_nullable_to_non_nullable
              as Pedido?,
    ));
  }

  /// Create a copy of EstadoCrearPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UbicacionCopyWith<$Res>? get ubicacion {
    if (_self.ubicacion == null) {
      return null;
    }

    return $UbicacionCopyWith<$Res>(_self.ubicacion!, (value) {
      return _then(_self.copyWith(ubicacion: value));
    });
  }

  /// Create a copy of EstadoCrearPedido
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PedidoCopyWith<$Res>? get pedidoCreado {
    if (_self.pedidoCreado == null) {
      return null;
    }

    return $PedidoCopyWith<$Res>(_self.pedidoCreado!, (value) {
      return _then(_self.copyWith(pedidoCreado: value));
    });
  }
}

// dart format on
