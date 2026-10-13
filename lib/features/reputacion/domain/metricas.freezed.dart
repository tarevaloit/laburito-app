// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metricas.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MetricasPerfil {
  PeriodoMetricas get periodo;
  int get vistas;
  int get contactos;
  int get calificaciones;

  /// Porcentaje de contactos que terminaron en una calificación. `null` sin
  /// contactos en el período.
  int? get efectividad;
  List<BarraMetricas> get serie;

  /// Create a copy of MetricasPerfil
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetricasPerfilCopyWith<MetricasPerfil> get copyWith =>
      _$MetricasPerfilCopyWithImpl<MetricasPerfil>(
          this as MetricasPerfil, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MetricasPerfil &&
            (identical(other.periodo, periodo) || other.periodo == periodo) &&
            (identical(other.vistas, vistas) || other.vistas == vistas) &&
            (identical(other.contactos, contactos) ||
                other.contactos == contactos) &&
            (identical(other.calificaciones, calificaciones) ||
                other.calificaciones == calificaciones) &&
            (identical(other.efectividad, efectividad) ||
                other.efectividad == efectividad) &&
            const DeepCollectionEquality().equals(other.serie, serie));
  }

  @override
  int get hashCode => Object.hash(runtimeType, periodo, vistas, contactos,
      calificaciones, efectividad, const DeepCollectionEquality().hash(serie));

  @override
  String toString() {
    return 'MetricasPerfil(periodo: $periodo, vistas: $vistas, contactos: $contactos, calificaciones: $calificaciones, efectividad: $efectividad, serie: $serie)';
  }
}

/// @nodoc
abstract mixin class $MetricasPerfilCopyWith<$Res> {
  factory $MetricasPerfilCopyWith(
          MetricasPerfil value, $Res Function(MetricasPerfil) _then) =
      _$MetricasPerfilCopyWithImpl;
  @useResult
  $Res call(
      {PeriodoMetricas periodo,
      int vistas,
      int contactos,
      int calificaciones,
      int? efectividad,
      List<BarraMetricas> serie});
}

/// @nodoc
class _$MetricasPerfilCopyWithImpl<$Res>
    implements $MetricasPerfilCopyWith<$Res> {
  _$MetricasPerfilCopyWithImpl(this._self, this._then);

  final MetricasPerfil _self;
  final $Res Function(MetricasPerfil) _then;

  /// Create a copy of MetricasPerfil
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? periodo = null,
    Object? vistas = null,
    Object? contactos = null,
    Object? calificaciones = null,
    Object? efectividad = freezed,
    Object? serie = null,
  }) {
    return _then(_self.copyWith(
      periodo: null == periodo
          ? _self.periodo
          : periodo // ignore: cast_nullable_to_non_nullable
              as PeriodoMetricas,
      vistas: null == vistas
          ? _self.vistas
          : vistas // ignore: cast_nullable_to_non_nullable
              as int,
      contactos: null == contactos
          ? _self.contactos
          : contactos // ignore: cast_nullable_to_non_nullable
              as int,
      calificaciones: null == calificaciones
          ? _self.calificaciones
          : calificaciones // ignore: cast_nullable_to_non_nullable
              as int,
      efectividad: freezed == efectividad
          ? _self.efectividad
          : efectividad // ignore: cast_nullable_to_non_nullable
              as int?,
      serie: null == serie
          ? _self.serie
          : serie // ignore: cast_nullable_to_non_nullable
              as List<BarraMetricas>,
    ));
  }
}

/// Adds pattern-matching-related methods to [MetricasPerfil].
extension MetricasPerfilPatterns on MetricasPerfil {
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
    TResult Function(_MetricasPerfil value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MetricasPerfil() when $default != null:
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
    TResult Function(_MetricasPerfil value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MetricasPerfil():
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
    TResult? Function(_MetricasPerfil value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MetricasPerfil() when $default != null:
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
    TResult Function(PeriodoMetricas periodo, int vistas, int contactos,
            int calificaciones, int? efectividad, List<BarraMetricas> serie)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MetricasPerfil() when $default != null:
        return $default(_that.periodo, _that.vistas, _that.contactos,
            _that.calificaciones, _that.efectividad, _that.serie);
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
    TResult Function(PeriodoMetricas periodo, int vistas, int contactos,
            int calificaciones, int? efectividad, List<BarraMetricas> serie)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MetricasPerfil():
        return $default(_that.periodo, _that.vistas, _that.contactos,
            _that.calificaciones, _that.efectividad, _that.serie);
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
    TResult? Function(PeriodoMetricas periodo, int vistas, int contactos,
            int calificaciones, int? efectividad, List<BarraMetricas> serie)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MetricasPerfil() when $default != null:
        return $default(_that.periodo, _that.vistas, _that.contactos,
            _that.calificaciones, _that.efectividad, _that.serie);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MetricasPerfil extends MetricasPerfil {
  const _MetricasPerfil(
      {required this.periodo,
      this.vistas = 0,
      this.contactos = 0,
      this.calificaciones = 0,
      this.efectividad,
      final List<BarraMetricas> serie = const <BarraMetricas>[]})
      : _serie = serie,
        super._();

  @override
  final PeriodoMetricas periodo;
  @override
  @JsonKey()
  final int vistas;
  @override
  @JsonKey()
  final int contactos;
  @override
  @JsonKey()
  final int calificaciones;

  /// Porcentaje de contactos que terminaron en una calificación. `null` sin
  /// contactos en el período.
  @override
  final int? efectividad;
  final List<BarraMetricas> _serie;
  @override
  @JsonKey()
  List<BarraMetricas> get serie {
    if (_serie is EqualUnmodifiableListView) return _serie;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_serie);
  }

  /// Create a copy of MetricasPerfil
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MetricasPerfilCopyWith<_MetricasPerfil> get copyWith =>
      __$MetricasPerfilCopyWithImpl<_MetricasPerfil>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MetricasPerfil &&
            (identical(other.periodo, periodo) || other.periodo == periodo) &&
            (identical(other.vistas, vistas) || other.vistas == vistas) &&
            (identical(other.contactos, contactos) ||
                other.contactos == contactos) &&
            (identical(other.calificaciones, calificaciones) ||
                other.calificaciones == calificaciones) &&
            (identical(other.efectividad, efectividad) ||
                other.efectividad == efectividad) &&
            const DeepCollectionEquality().equals(other._serie, _serie));
  }

  @override
  int get hashCode => Object.hash(runtimeType, periodo, vistas, contactos,
      calificaciones, efectividad, const DeepCollectionEquality().hash(_serie));

  @override
  String toString() {
    return 'MetricasPerfil(periodo: $periodo, vistas: $vistas, contactos: $contactos, calificaciones: $calificaciones, efectividad: $efectividad, serie: $serie)';
  }
}

/// @nodoc
abstract mixin class _$MetricasPerfilCopyWith<$Res>
    implements $MetricasPerfilCopyWith<$Res> {
  factory _$MetricasPerfilCopyWith(
          _MetricasPerfil value, $Res Function(_MetricasPerfil) _then) =
      __$MetricasPerfilCopyWithImpl;
  @override
  @useResult
  $Res call(
      {PeriodoMetricas periodo,
      int vistas,
      int contactos,
      int calificaciones,
      int? efectividad,
      List<BarraMetricas> serie});
}

/// @nodoc
class __$MetricasPerfilCopyWithImpl<$Res>
    implements _$MetricasPerfilCopyWith<$Res> {
  __$MetricasPerfilCopyWithImpl(this._self, this._then);

  final _MetricasPerfil _self;
  final $Res Function(_MetricasPerfil) _then;

  /// Create a copy of MetricasPerfil
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? periodo = null,
    Object? vistas = null,
    Object? contactos = null,
    Object? calificaciones = null,
    Object? efectividad = freezed,
    Object? serie = null,
  }) {
    return _then(_MetricasPerfil(
      periodo: null == periodo
          ? _self.periodo
          : periodo // ignore: cast_nullable_to_non_nullable
              as PeriodoMetricas,
      vistas: null == vistas
          ? _self.vistas
          : vistas // ignore: cast_nullable_to_non_nullable
              as int,
      contactos: null == contactos
          ? _self.contactos
          : contactos // ignore: cast_nullable_to_non_nullable
              as int,
      calificaciones: null == calificaciones
          ? _self.calificaciones
          : calificaciones // ignore: cast_nullable_to_non_nullable
              as int,
      efectividad: freezed == efectividad
          ? _self.efectividad
          : efectividad // ignore: cast_nullable_to_non_nullable
              as int?,
      serie: null == serie
          ? _self._serie
          : serie // ignore: cast_nullable_to_non_nullable
              as List<BarraMetricas>,
    ));
  }
}

/// @nodoc
mixin _$BarraMetricas {
  DateTime get desde;
  int get vistas;

  /// Create a copy of BarraMetricas
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BarraMetricasCopyWith<BarraMetricas> get copyWith =>
      _$BarraMetricasCopyWithImpl<BarraMetricas>(
          this as BarraMetricas, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BarraMetricas &&
            (identical(other.desde, desde) || other.desde == desde) &&
            (identical(other.vistas, vistas) || other.vistas == vistas));
  }

  @override
  int get hashCode => Object.hash(runtimeType, desde, vistas);

  @override
  String toString() {
    return 'BarraMetricas(desde: $desde, vistas: $vistas)';
  }
}

/// @nodoc
abstract mixin class $BarraMetricasCopyWith<$Res> {
  factory $BarraMetricasCopyWith(
          BarraMetricas value, $Res Function(BarraMetricas) _then) =
      _$BarraMetricasCopyWithImpl;
  @useResult
  $Res call({DateTime desde, int vistas});
}

/// @nodoc
class _$BarraMetricasCopyWithImpl<$Res>
    implements $BarraMetricasCopyWith<$Res> {
  _$BarraMetricasCopyWithImpl(this._self, this._then);

  final BarraMetricas _self;
  final $Res Function(BarraMetricas) _then;

  /// Create a copy of BarraMetricas
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? desde = null,
    Object? vistas = null,
  }) {
    return _then(_self.copyWith(
      desde: null == desde
          ? _self.desde
          : desde // ignore: cast_nullable_to_non_nullable
              as DateTime,
      vistas: null == vistas
          ? _self.vistas
          : vistas // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [BarraMetricas].
extension BarraMetricasPatterns on BarraMetricas {
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
    TResult Function(_BarraMetricas value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BarraMetricas() when $default != null:
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
    TResult Function(_BarraMetricas value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BarraMetricas():
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
    TResult? Function(_BarraMetricas value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BarraMetricas() when $default != null:
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
    TResult Function(DateTime desde, int vistas)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BarraMetricas() when $default != null:
        return $default(_that.desde, _that.vistas);
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
    TResult Function(DateTime desde, int vistas) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BarraMetricas():
        return $default(_that.desde, _that.vistas);
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
    TResult? Function(DateTime desde, int vistas)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BarraMetricas() when $default != null:
        return $default(_that.desde, _that.vistas);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BarraMetricas implements BarraMetricas {
  const _BarraMetricas({required this.desde, required this.vistas});

  @override
  final DateTime desde;
  @override
  final int vistas;

  /// Create a copy of BarraMetricas
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BarraMetricasCopyWith<_BarraMetricas> get copyWith =>
      __$BarraMetricasCopyWithImpl<_BarraMetricas>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BarraMetricas &&
            (identical(other.desde, desde) || other.desde == desde) &&
            (identical(other.vistas, vistas) || other.vistas == vistas));
  }

  @override
  int get hashCode => Object.hash(runtimeType, desde, vistas);

  @override
  String toString() {
    return 'BarraMetricas(desde: $desde, vistas: $vistas)';
  }
}

/// @nodoc
abstract mixin class _$BarraMetricasCopyWith<$Res>
    implements $BarraMetricasCopyWith<$Res> {
  factory _$BarraMetricasCopyWith(
          _BarraMetricas value, $Res Function(_BarraMetricas) _then) =
      __$BarraMetricasCopyWithImpl;
  @override
  @useResult
  $Res call({DateTime desde, int vistas});
}

/// @nodoc
class __$BarraMetricasCopyWithImpl<$Res>
    implements _$BarraMetricasCopyWith<$Res> {
  __$BarraMetricasCopyWithImpl(this._self, this._then);

  final _BarraMetricas _self;
  final $Res Function(_BarraMetricas) _then;

  /// Create a copy of BarraMetricas
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? desde = null,
    Object? vistas = null,
  }) {
    return _then(_BarraMetricas(
      desde: null == desde
          ? _self.desde
          : desde // ignore: cast_nullable_to_non_nullable
              as DateTime,
      vistas: null == vistas
          ? _self.vistas
          : vistas // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
