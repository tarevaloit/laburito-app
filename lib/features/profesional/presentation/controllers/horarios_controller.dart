import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../data/horarios_repository.dart';
import '../../domain/horario_atencion.dart';

part 'horarios_controller.freezed.dart';
part 'horarios_controller.g.dart';

@freezed
abstract class EstadoHorarios with _$EstadoHorarios {
  const EstadoHorarios._();

  const factory EstadoHorarios({
    @Default(<HorarioAtencion>[]) List<HorarioAtencion> franjas,
    @Default(<HorarioAtencion>[]) List<HorarioAtencion> guardadas,
    @Default(false) bool disponible,
    @Default(false) bool guardando,
    String? error,
    String? aviso,
  }) = _EstadoHorarios;

  bool get hayCambios =>
      franjas.length != guardadas.length ||
      franjas.any((f) => !guardadas.contains(f));

  bool get puedeGuardar => hayCambios && !guardando;

  List<HorarioAtencion> delDia(int dia) => [
        for (final f in franjas)
          if (f.dia == dia) f,
      ]..sort((a, b) => a.desdeMinutos.compareTo(b.desdeMinutos));

  bool puedeAgregarEn(int dia) =>
      delDia(dia).length < HorarioAtencion.maximoPorDia;
}

/// CU-44 — Horarios de atención y disponibilidad.
///
/// El interruptor de disponibilidad se guarda **solo**, apenas se toca: es una
/// decisión de un bit que la persona toma cuando empieza o termina la jornada,
/// y hacerla pasar por un botón «Guardar» es pedirle dos toques para algo que
/// tiene que ser uno. La grilla de horarios sí espera el guardado: se edita de
/// a varias franjas y guardar en cada toque llenaría la base de escrituras a
/// medio terminar.
@riverpod
class Horarios extends _$Horarios {
  @override
  Future<EstadoHorarios> build() async {
    final repo = ref.read(horariosRepositoryProvider);
    final franjas = await repo.cargar();
    final disponible = await repo.disponible();

    return EstadoHorarios(
      franjas: franjas,
      guardadas: franjas,
      disponible: disponible,
    );
  }

  void _actualizar(EstadoHorarios Function(EstadoHorarios) cambio) {
    final actual = state.valueOrNull;
    if (actual == null) return;
    state = AsyncData(cambio(actual));
  }

  /// Agrega una franja al día. Rechaza acá mismo lo que la base rechazaría
  /// —superposición y tope por día— para no gastar un viaje en decir que no.
  void agregar(HorarioAtencion franja) {
    final actual = state.valueOrNull;
    if (actual == null) return;

    if (!franja.esValida) {
      _actualizar((e) => e.copyWith(
            error: 'La franja tiene que terminar después de empezar.',
          ));
      return;
    }

    if (!actual.puedeAgregarEn(franja.dia)) {
      _actualizar((e) => e.copyWith(
            error: 'Hasta ${HorarioAtencion.maximoPorDia} franjas por día.',
          ));
      return;
    }

    if (actual.franjas.any(franja.sePisaCon)) {
      _actualizar((e) => e.copyWith(
            error: 'Esa franja se pisa con otra del mismo día.',
          ));
      return;
    }

    _actualizar((e) => e.copyWith(
          franjas: [...e.franjas, franja],
          error: null,
        ));
  }

  void quitar(HorarioAtencion franja) => _actualizar(
        (e) => e.copyWith(
          franjas: [
            for (final f in e.franjas)
              if (f != franja) f,
          ],
          error: null,
        ),
      );

  Future<void> guardar() async {
    final actual = state.valueOrNull;
    if (actual == null || !actual.puedeGuardar) return;

    _actualizar((e) => e.copyWith(guardando: true, error: null, aviso: null));

    try {
      final guardadas = await ref
          .read(horariosRepositoryProvider)
          .reemplazar(actual.franjas);

      _actualizar((e) => e.copyWith(
            franjas: guardadas,
            guardadas: guardadas,
            guardando: false,
            aviso: 'Guardamos tus horarios.',
          ));
    } on Object catch (error) {
      _actualizar((e) => e.copyWith(
            guardando: false,
            error: MensajesError.desde(error),
          ));
    }
  }

  /// El interruptor. Se pinta al toque y se revierte si el servidor rechaza.
  Future<void> cambiarDisponibilidad(bool disponible) async {
    final actual = state.valueOrNull;
    if (actual == null) return;

    _actualizar((e) => e.copyWith(disponible: disponible, error: null));

    try {
      final confirmado = await ref
          .read(horariosRepositoryProvider)
          .cambiarDisponibilidad(disponible);

      _actualizar((e) => e.copyWith(
            disponible: confirmado,
            aviso: confirmado
                ? 'Estás disponible: te van a llegar los pedidos de tu zona.'
                : 'Quedaste como no disponible: no vas a recibir alertas.',
          ));
    } on Object catch (error) {
      _actualizar((e) => e.copyWith(
            disponible: actual.disponible,
            error: MensajesError.desde(error),
          ));
    }
  }

  void descartarAviso() =>
      _actualizar((e) => e.copyWith(aviso: null, error: null));
}
