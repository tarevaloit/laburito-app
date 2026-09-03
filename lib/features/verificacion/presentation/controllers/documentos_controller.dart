import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../perfil/data/perfil_repository.dart';
import '../../data/documentos_repository.dart';

part 'documentos_controller.g.dart';

/// CU-09.
@Riverpod(keepAlive: true)
class DocumentosController extends _$DocumentosController {
  @override
  FutureOr<void> build() {}

  DocumentosRepository get _repo => ref.read(documentosRepositoryProvider);

  Future<bool> subir({
    required TipoDocumento tipo,
    required Uint8List bytes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.subir(tipo: tipo, bytes: bytes);
      await _repo.marcarEnRevisionSiEstaCompleto();
    });

    if (!state.hasError) {
      ref.invalidate(documentosCargadosProvider);
      ref.invalidate(perfilCompletoProvider);
    }
    return !state.hasError;
  }
}
