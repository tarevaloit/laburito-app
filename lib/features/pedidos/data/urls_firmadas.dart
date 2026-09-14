import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/supabase_providers.dart';
import 'pedidos_repository.dart';

part 'urls_firmadas.g.dart';

/// Caché de URLs firmadas del bucket privado `pedidos`.
///
/// El bucket es privado, así que una foto no se muestra con su ruta: hay que
/// pedirle al servidor una URL con firma y vencimiento. Sin caché, cada
/// `build` de una lista volvería a firmar lo mismo, y una página del historial
/// (CU-17) con 20 portadas firmaría 20 veces por scroll.
///
/// Dos reglas:
///
///   * **Se firma en lote.** [resolver] junta todas las rutas que le faltan y
///     hace una sola llamada, no una por foto.
///   * **Se guarda hasta que vence**, con un margen: una URL que expira
///     mientras el navegador la está cargando se ve igual que una foto rota.
class UrlsFirmadas {
  UrlsFirmadas(this._repo);

  final PedidosRepository _repo;

  /// Cuánto pide que dure cada firma.
  ///
  /// Media hora alcanza para mirar un detalle y volver, y es lo bastante corta
  /// como para que una URL copiada de la consola no siga sirviendo mañana.
  static const Duration duracion = Duration(minutes: 30);

  /// Se descarta un poco antes de que venza de verdad, para no entregar una
  /// firma que expira mientras la imagen se está descargando.
  static const Duration margen = Duration(minutes: 2);

  final Map<String, _Firma> _cache = {};

  /// Lo que ya está firmado y todavía sirve. Sincrónico: es para dibujar sin
  /// esperar, no para decidir si hay que pedir.
  String? cacheada(String ruta) {
    final firma = _cache[ruta];
    if (firma == null) return null;
    if (firma.venceEn.isBefore(DateTime.now())) {
      _cache.remove(ruta);
      return null;
    }
    return firma.url;
  }

  /// URLs de todas las [rutas] pedidas. Las que ya estaban vigentes salen del
  /// caché; el resto se firma en una sola llamada.
  ///
  /// Una ruta que el servidor no pudo firmar no aparece en el resultado, y
  /// tampoco queda cacheada: si el archivo aparece más tarde, el próximo
  /// intento lo va a encontrar.
  Future<Map<String, String>> resolver(List<String> rutas) async {
    final resultado = <String, String>{};
    final faltantes = <String>[];

    for (final ruta in rutas) {
      final vigente = cacheada(ruta);
      if (vigente != null) {
        resultado[ruta] = vigente;
      } else if (!faltantes.contains(ruta)) {
        faltantes.add(ruta);
      }
    }

    if (faltantes.isEmpty) return resultado;

    final firmadas =
        await _repo.urlsFirmadas(faltantes, segundos: duracion.inSeconds);

    final vence = DateTime.now().add(duracion - margen);
    for (final entrada in firmadas.entries) {
      _cache[entrada.key] = _Firma(entrada.value, vence);
      resultado[entrada.key] = entrada.value;
    }

    return resultado;
  }

  /// Olvida una ruta. La llama quien borra una foto: la firma sigue siendo
  /// válida un rato más, pero el archivo detrás ya no está.
  void olvidar(String ruta) => _cache.remove(ruta);

  void limpiar() => _cache.clear();
}

class _Firma {
  const _Firma(this.url, this.venceEn);

  final String url;
  final DateTime venceEn;
}

/// keepAlive: el caché tiene que sobrevivir a la pantalla que lo usó, que es
/// justamente para lo que sirve. Se rearma al cambiar la sesión, porque las
/// firmas de la sesión anterior no son de este usuario.
@Riverpod(keepAlive: true)
UrlsFirmadas urlsFirmadas(Ref ref) {
  ref.watch(sesionProvider);
  return UrlsFirmadas(ref.watch(pedidosRepositoryProvider));
}
