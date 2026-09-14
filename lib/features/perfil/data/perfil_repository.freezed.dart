// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfil_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PerfilCompleto {
  String get id;
  String get tipo;
  String get nombre;
  String get apellido;
  String get email;
  String get estado;
  String? get telefono;
  String? get avatarUrl;
  String? get dni;
  String? get descripcion;
  String? get estadoVerificacion;
  int get saldoTokens;
  List<String> get categorias;

  /// Create a copy of PerfilCompleto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PerfilCompletoCopyWith<PerfilCompleto> get copyWith =>
      _$PerfilCompletoCopyWithImpl<PerfilCompleto>(
          this as PerfilCompleto, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PerfilCompleto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.dni, dni) || other.dni == dni) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.estadoVerificacion, estadoVerificacion) ||
                other.estadoVerificacion == estadoVerificacion) &&
            (identical(other.saldoTokens, saldoTokens) ||
                other.saldoTokens == saldoTokens) &&
            const DeepCollectionEquality()
                .equals(other.categorias, categorias));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tipo,
      nombre,
      apellido,
      email,
      estado,
      telefono,
      avatarUrl,
      dni,
      descripcion,
      estadoVerificacion,
      saldoTokens,
      const DeepCollectionEquality().hash(categorias));

  @override
  String toString() {
    return 'PerfilCompleto(id: $id, tipo: $tipo, nombre: $nombre, apellido: $apellido, email: $email, estado: $estado, telefono: $telefono, avatarUrl: $avatarUrl, dni: $dni, descripcion: $descripcion, estadoVerificacion: $estadoVerificacion, saldoTokens: $saldoTokens, categorias: $categorias)';
  }
}

/// @nodoc
abstract mixin class $PerfilCompletoCopyWith<$Res> {
  factory $PerfilCompletoCopyWith(
          PerfilCompleto value, $Res Function(PerfilCompleto) _then) =
      _$PerfilCompletoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tipo,
      String nombre,
      String apellido,
      String email,
      String estado,
      String? telefono,
      String? avatarUrl,
      String? dni,
      String? descripcion,
      String? estadoVerificacion,
      int saldoTokens,
      List<String> categorias});
}

/// @nodoc
class _$PerfilCompletoCopyWithImpl<$Res>
    implements $PerfilCompletoCopyWith<$Res> {
  _$PerfilCompletoCopyWithImpl(this._self, this._then);

  final PerfilCompleto _self;
  final $Res Function(PerfilCompleto) _then;

  /// Create a copy of PerfilCompleto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? email = null,
    Object? estado = null,
    Object? telefono = freezed,
    Object? avatarUrl = freezed,
    Object? dni = freezed,
    Object? descripcion = freezed,
    Object? estadoVerificacion = freezed,
    Object? saldoTokens = null,
    Object? categorias = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      apellido: null == apellido
          ? _self.apellido
          : apellido // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      telefono: freezed == telefono
          ? _self.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      dni: freezed == dni
          ? _self.dni
          : dni // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      estadoVerificacion: freezed == estadoVerificacion
          ? _self.estadoVerificacion
          : estadoVerificacion // ignore: cast_nullable_to_non_nullable
              as String?,
      saldoTokens: null == saldoTokens
          ? _self.saldoTokens
          : saldoTokens // ignore: cast_nullable_to_non_nullable
              as int,
      categorias: null == categorias
          ? _self.categorias
          : categorias // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [PerfilCompleto].
extension PerfilCompletoPatterns on PerfilCompleto {
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
    TResult Function(_PerfilCompleto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PerfilCompleto() when $default != null:
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
    TResult Function(_PerfilCompleto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerfilCompleto():
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
    TResult? Function(_PerfilCompleto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerfilCompleto() when $default != null:
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
            String tipo,
            String nombre,
            String apellido,
            String email,
            String estado,
            String? telefono,
            String? avatarUrl,
            String? dni,
            String? descripcion,
            String? estadoVerificacion,
            int saldoTokens,
            List<String> categorias)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PerfilCompleto() when $default != null:
        return $default(
            _that.id,
            _that.tipo,
            _that.nombre,
            _that.apellido,
            _that.email,
            _that.estado,
            _that.telefono,
            _that.avatarUrl,
            _that.dni,
            _that.descripcion,
            _that.estadoVerificacion,
            _that.saldoTokens,
            _that.categorias);
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
            String tipo,
            String nombre,
            String apellido,
            String email,
            String estado,
            String? telefono,
            String? avatarUrl,
            String? dni,
            String? descripcion,
            String? estadoVerificacion,
            int saldoTokens,
            List<String> categorias)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerfilCompleto():
        return $default(
            _that.id,
            _that.tipo,
            _that.nombre,
            _that.apellido,
            _that.email,
            _that.estado,
            _that.telefono,
            _that.avatarUrl,
            _that.dni,
            _that.descripcion,
            _that.estadoVerificacion,
            _that.saldoTokens,
            _that.categorias);
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
            String tipo,
            String nombre,
            String apellido,
            String email,
            String estado,
            String? telefono,
            String? avatarUrl,
            String? dni,
            String? descripcion,
            String? estadoVerificacion,
            int saldoTokens,
            List<String> categorias)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PerfilCompleto() when $default != null:
        return $default(
            _that.id,
            _that.tipo,
            _that.nombre,
            _that.apellido,
            _that.email,
            _that.estado,
            _that.telefono,
            _that.avatarUrl,
            _that.dni,
            _that.descripcion,
            _that.estadoVerificacion,
            _that.saldoTokens,
            _that.categorias);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PerfilCompleto extends PerfilCompleto {
  const _PerfilCompleto(
      {required this.id,
      required this.tipo,
      required this.nombre,
      required this.apellido,
      required this.email,
      required this.estado,
      this.telefono,
      this.avatarUrl,
      this.dni,
      this.descripcion,
      this.estadoVerificacion,
      this.saldoTokens = 0,
      final List<String> categorias = const <String>[]})
      : _categorias = categorias,
        super._();

  @override
  final String id;
  @override
  final String tipo;
  @override
  final String nombre;
  @override
  final String apellido;
  @override
  final String email;
  @override
  final String estado;
  @override
  final String? telefono;
  @override
  final String? avatarUrl;
  @override
  final String? dni;
  @override
  final String? descripcion;
  @override
  final String? estadoVerificacion;
  @override
  @JsonKey()
  final int saldoTokens;
  final List<String> _categorias;
  @override
  @JsonKey()
  List<String> get categorias {
    if (_categorias is EqualUnmodifiableListView) return _categorias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categorias);
  }

  /// Create a copy of PerfilCompleto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PerfilCompletoCopyWith<_PerfilCompleto> get copyWith =>
      __$PerfilCompletoCopyWithImpl<_PerfilCompleto>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PerfilCompleto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.dni, dni) || other.dni == dni) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.estadoVerificacion, estadoVerificacion) ||
                other.estadoVerificacion == estadoVerificacion) &&
            (identical(other.saldoTokens, saldoTokens) ||
                other.saldoTokens == saldoTokens) &&
            const DeepCollectionEquality()
                .equals(other._categorias, _categorias));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tipo,
      nombre,
      apellido,
      email,
      estado,
      telefono,
      avatarUrl,
      dni,
      descripcion,
      estadoVerificacion,
      saldoTokens,
      const DeepCollectionEquality().hash(_categorias));

  @override
  String toString() {
    return 'PerfilCompleto(id: $id, tipo: $tipo, nombre: $nombre, apellido: $apellido, email: $email, estado: $estado, telefono: $telefono, avatarUrl: $avatarUrl, dni: $dni, descripcion: $descripcion, estadoVerificacion: $estadoVerificacion, saldoTokens: $saldoTokens, categorias: $categorias)';
  }
}

/// @nodoc
abstract mixin class _$PerfilCompletoCopyWith<$Res>
    implements $PerfilCompletoCopyWith<$Res> {
  factory _$PerfilCompletoCopyWith(
          _PerfilCompleto value, $Res Function(_PerfilCompleto) _then) =
      __$PerfilCompletoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tipo,
      String nombre,
      String apellido,
      String email,
      String estado,
      String? telefono,
      String? avatarUrl,
      String? dni,
      String? descripcion,
      String? estadoVerificacion,
      int saldoTokens,
      List<String> categorias});
}

/// @nodoc
class __$PerfilCompletoCopyWithImpl<$Res>
    implements _$PerfilCompletoCopyWith<$Res> {
  __$PerfilCompletoCopyWithImpl(this._self, this._then);

  final _PerfilCompleto _self;
  final $Res Function(_PerfilCompleto) _then;

  /// Create a copy of PerfilCompleto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tipo = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? email = null,
    Object? estado = null,
    Object? telefono = freezed,
    Object? avatarUrl = freezed,
    Object? dni = freezed,
    Object? descripcion = freezed,
    Object? estadoVerificacion = freezed,
    Object? saldoTokens = null,
    Object? categorias = null,
  }) {
    return _then(_PerfilCompleto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tipo: null == tipo
          ? _self.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as String,
      nombre: null == nombre
          ? _self.nombre
          : nombre // ignore: cast_nullable_to_non_nullable
              as String,
      apellido: null == apellido
          ? _self.apellido
          : apellido // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      estado: null == estado
          ? _self.estado
          : estado // ignore: cast_nullable_to_non_nullable
              as String,
      telefono: freezed == telefono
          ? _self.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      dni: freezed == dni
          ? _self.dni
          : dni // ignore: cast_nullable_to_non_nullable
              as String?,
      descripcion: freezed == descripcion
          ? _self.descripcion
          : descripcion // ignore: cast_nullable_to_non_nullable
              as String?,
      estadoVerificacion: freezed == estadoVerificacion
          ? _self.estadoVerificacion
          : estadoVerificacion // ignore: cast_nullable_to_non_nullable
              as String?,
      saldoTokens: null == saldoTokens
          ? _self.saldoTokens
          : saldoTokens // ignore: cast_nullable_to_non_nullable
              as int,
      categorias: null == categorias
          ? _self._categorias
          : categorias // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
