// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horarios_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$horariosHash() => r'3553ea5e262c0dad750f2831a2a4e201e0bb4f07';

/// CU-44 — Horarios de atención y disponibilidad.
///
/// El interruptor de disponibilidad se guarda **solo**, apenas se toca: es una
/// decisión de un bit que la persona toma cuando empieza o termina la jornada,
/// y hacerla pasar por un botón «Guardar» es pedirle dos toques para algo que
/// tiene que ser uno. La grilla de horarios sí espera el guardado: se edita de
/// a varias franjas y guardar en cada toque llenaría la base de escrituras a
/// medio terminar.
///
/// Copied from [Horarios].
@ProviderFor(Horarios)
final horariosProvider =
    AutoDisposeAsyncNotifierProvider<Horarios, EstadoHorarios>.internal(
  Horarios.new,
  name: r'horariosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$horariosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Horarios = AutoDisposeAsyncNotifier<EstadoHorarios>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
