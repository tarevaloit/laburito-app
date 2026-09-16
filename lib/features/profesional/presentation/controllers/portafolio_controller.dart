import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/mensajes_error.dart';
import '../../data/portafolio_repository.dart';
import '../../domain/foto_portafolio.dart';

part 'portafolio_controller.freezed.dart';
part 'portafolio_controller.g.dart';

@freezed
abstract class EstadoPortafolio with _$EstadoPortafolio {
  const EstadoPortafolio._();

  const factory EstadoPortafolio({
    @Default(<FotoPortafolio>[]) List<FotoPortafolio> fotos,
    @Default(<String, String>{}) Map<String, String> urls,
    @Default(false) bool trabajando,
    String? error,
  }) = _EstadoPortafolio;

  bool get puedeAgregar =>
      fotos.length < FotoPortafolio.maximoPorProfesional && !trabajando;

  int get proximoOrden =>
      fotos.isEmpty ? 0 : fotos.map((f) => f.orden).reduce((a, b) => a > b ? a : b) + 1;
}

/// CU-06 — Cargar Portafolio.
///
/// Las fotos se aplican al instante, como en la edición del pedido (CU-15):
/// subir y borrar son operaciones sobre Storage que no tienen nada que
/// esperar, y juntarlas hasta un botón «Guardar» obligaría a deshacer subidas
/// si algo fallara después.
@riverpod
class Portafolio extends _$Portafolio {
  @override
  Future<EstadoPortafolio> build() async {
    final repo = ref.read(portafolioRepositoryProvider);
    final fotos = await repo.listar();
    final urls = await repo.urlsFirmadas([for (final f in fotos) f.storagePath]);

    return EstadoPortafolio(fotos: fotos, urls: urls);
  }

  void _actualizar(EstadoPortafolio Function(EstadoPortafolio) cambio) {
    final actual = state.valueOrNull;
    if (actual == null) return;
    state = AsyncData(cambio(actual));
  }

  Future<void> agregar(Uint8List bytes) async {
    final actual = state.valueOrNull;
    if (actual == null || !actual.puedeAgregar) return;

    _actualizar((e) => e.copyWith(trabajando: true, error: null));

    try {
      final repo = ref.read(portafolioRepositoryProvider);
      final foto = await repo.subir(bytes: bytes, orden: actual.proximoOrden);
      final url = await repo.urlsFirmadas([foto.storagePath]);

      _actualizar((e) => e.copyWith(
            fotos: [...e.fotos, foto],
            urls: {...e.urls, ...url},
            trabajando: false,
          ));
    } on Object catch (error) {
      _actualizar((e) => e.copyWith(
            trabajando: false,
            error: MensajesError.desde(error),
          ));
    }
  }

  Future<void> eliminar(FotoPortafolio foto) async {
    _actualizar((e) => e.copyWith(trabajando: true, error: null));

    try {
      await ref.read(portafolioRepositoryProvider).eliminar(foto);

      _actualizar((e) => e.copyWith(
            fotos: [
              for (final f in e.fotos)
                if (f.id != foto.id) f,
            ],
            trabajando: false,
          ));
    } on Object catch (error) {
      _actualizar((e) => e.copyWith(
            trabajando: false,
            error: MensajesError.desde(error),
          ));
    }
  }

  void descartarError() => _actualizar((e) => e.copyWith(error: null));
}
