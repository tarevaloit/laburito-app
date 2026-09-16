import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../../pedidos/domain/ubicacion.dart';
import '../../data/zona_cobertura_repository.dart';
import '../../domain/zona_cobertura.dart';

part 'zona_cobertura_controller.freezed.dart';
part 'zona_cobertura_controller.g.dart';

/// El borrador de la zona: lo que muestra la pantalla ahora, más lo que estaba
/// guardado al abrirla.
///
/// Guardar la [original] es lo que permite saber si hay cambios sin volver a
/// consultar, y distinguir «todavía no configuró ninguna» —que se resuelve con
/// el centro en null— de «la cambió».
@freezed
abstract class EstadoZonaCobertura with _$EstadoZonaCobertura {
  const EstadoZonaCobertura._();

  const factory EstadoZonaCobertura({
    /// `null` mientras el Profesional no eligió un centro: es el estado de
    /// quien entra por primera vez.
    Ubicacion? centro,
    @Default(ZonaCobertura.radioPorDefectoMetros) int radioMetros,
    ZonaCobertura? original,
    @Default(false) bool guardando,
    String? error,

    /// Se levanta al guardar bien, para que la pantalla avise una sola vez.
    @Default(false) bool guardado,
  }) = _EstadoZonaCobertura;

  bool get tieneCentro => centro != null;

  bool get esPrimeraVez => original == null;

  bool get hayCambios =>
      centro != original?.centro || radioMetros != original?.radioMetros;

  /// No se guarda sin centro, ni sin cambios, ni dos veces seguidas.
  bool get puedeGuardar => tieneCentro && hayCambios && !guardando;

  double get radioKm => radioMetros / 1000;

  String get radioLegible =>
      ZonaCobertura(centro: centro!, radioMetros: radioMetros).radioLegible;
}

/// CU-07 — Configurar Zona de Cobertura.
///
/// La zona es el primer insumo del emparejamiento del CU-21: sin ella no hay
/// contra qué comparar la ubicación de un pedido. El otro son las categorías
/// del CU-12.
@riverpod
class ZonaCoberturaControlador extends _$ZonaCoberturaControlador {
  @override
  Future<EstadoZonaCobertura> build() async {
    final zona = await ref.read(zonaCoberturaRepositoryProvider).cargar();

    return EstadoZonaCobertura(
      centro: zona?.centro,
      radioMetros: zona?.radioMetros ?? ZonaCobertura.radioPorDefectoMetros,
      original: zona,
    );
  }

  void _actualizar(EstadoZonaCobertura Function(EstadoZonaCobertura) cambio) {
    final actual = state.valueOrNull;
    if (actual == null) return;
    state = AsyncData(cambio(actual));
  }

  /// Lo que devolvió el `SelectorUbicacion`. Un `null` es «volvió atrás sin
  /// elegir» y no toca nada.
  void elegirCentro(Ubicacion? centro) {
    if (centro == null) return;
    _actualizar((e) => e.copyWith(centro: centro, error: null, guardado: false));
  }

  /// El deslizador habla en kilómetros; la base, en metros.
  void cambiarRadioKm(double km) {
    final metros = ZonaCobertura.radioValido((km * 1000).round());
    _actualizar((e) => e.copyWith(radioMetros: metros, guardado: false));
  }

  Future<void> guardar() async {
    final actual = state.valueOrNull;
    if (actual == null || !actual.puedeGuardar) return;

    _actualizar((e) => e.copyWith(guardando: true, error: null, guardado: false));

    try {
      final zona = await ref.read(zonaCoberturaRepositoryProvider).guardar(
            centro: actual.centro!,
            radioMetros: actual.radioMetros,
          );

      _actualizar(
        (e) => e.copyWith(
          centro: zona.centro,
          radioMetros: zona.radioMetros,
          original: zona,
          guardando: false,
          guardado: true,
        ),
      );
    } on Object catch (error) {
      _actualizar(
        (e) => e.copyWith(guardando: false, error: MensajesError.desde(error)),
      );
    }
  }

  void descartarAviso() =>
      _actualizar((e) => e.copyWith(guardado: false, error: null));
}
