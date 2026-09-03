import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_providers.dart';
import '../domain/pedido.dart';
import '../domain/pedido_estado.dart';
import '../domain/pedido_evento.dart';
import '../domain/pedido_foto.dart';
import '../domain/ubicacion.dart';
import 'pedido_exception.dart';

part 'pedidos_repository.g.dart';

/// CU-13 (publicar), CU-51 (renovar) y el ciclo de vida del pedido.
///
/// Todo lo que sale de acá tira [PedidoException]: la capa de presentación no
/// tiene que saber qué es un `PostgrestException`.
class PedidosRepository {
  const PedidosRepository(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'pedidos';

  /// Sin espacios ni saltos de línea: PostgREST manda este string tal cual en
  /// el query string, y un espacio pasaría a formar parte del nombre de la
  /// columna.
  ///
  /// `lat` y `lng` no son columnas sino los *computed fields* de la migración
  /// 0007. Hay que pedirlos siempre: sin ellos `Pedido.desdeFila` no puede
  /// armar la [Ubicacion].
  static const String _columnas = 'id,buscador_id,categoria_id,titulo,'
      'descripcion,urgencia,estado,direccion_texto,referencia_ubicacion,'
      'presupuesto_estimado,fecha_publicacion,fecha_vencimiento,fecha_cierre,'
      'motivo_cierre,renovaciones,created_at,updated_at,lat,lng,'
      'categorias_oficio(nombre),'
      'pedido_fotos(id,pedido_id,storage_path,orden,created_at)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const PedidoException(
        CasoPedido.sinPermiso,
        'Tenés que iniciar sesión para gestionar tus pedidos.',
      );
    }
    return id;
  }

  /// Falla antes de salir a la red cuando no hay sesión.
  ///
  /// Las RPC lo verifican igual con `auth.uid()`, pero un viaje de ida y vuelta
  /// para contestar «iniciá sesión» es un viaje de más.
  void _exigirSesion() => _uid;

  /// Envuelve cualquier fallo del backend en un [PedidoException].
  Future<T> _guardar<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } catch (error) {
      throw PedidoException.desde(error);
    }
  }

  // --------------------------------------------------------------------------
  // Alta y edición
  // --------------------------------------------------------------------------

  /// CU-13 — Publicar un pedido. Nace en `publicado`, que es el default de la
  /// tabla y lo custodia el trigger `pedidos_guard_alta` de la 0009.
  ///
  /// Va por la RPC `crear_pedido` y no por un INSERT de PostgREST. El INSERT
  /// también funcionaba —la ubicación viajaba como EWKT, que la función de
  /// entrada de `geography` acepta— pero dejaba tres cosas del lado del
  /// cliente que no le corresponden: el orden `(lng, lat)` de PostGIS, la
  /// validación del rango de la coordenada y la posibilidad de elegir el estado
  /// inicial. Ahora el punto lo arma `public.punto(lat, lng)` en la base, que
  /// es el único lugar donde ese orden está escrito.
  ///
  /// La RPC devuelve `setof pedidos`, así que admite `.select()` con los
  /// computed fields y los embeds: sigue siendo un solo viaje.
  Future<Pedido> crearPedido({
    required String categoriaId,
    required String titulo,
    required String descripcion,
    required Ubicacion ubicacion,
    required DateTime fechaVencimiento,
    PedidoUrgencia urgencia = PedidoUrgencia.media,
    double? presupuestoEstimado,
  }) {
    // El `buscador_id` lo pone la RPC con `auth.uid()`; acá solo se evita el
    // viaje cuando ya se sabe que no hay sesión.
    _exigirSesion();

    if (!ubicacion.esValida) {
      throw const PedidoException(
        CasoPedido.desconocido,
        'La ubicación del pedido no es válida. Marcala de nuevo en el mapa.',
      );
    }
    if (!fechaVencimiento.isAfter(DateTime.now())) {
      throw const PedidoException(
        CasoPedido.desconocido,
        'La fecha de vencimiento tiene que ser posterior a hoy.',
      );
    }

    return _guardar(() async {
      final fila = await _client
          .rpc('crear_pedido', params: {
            'p_categoria_id': categoriaId,
            'p_titulo': titulo.trim(),
            'p_descripcion': descripcion.trim(),
            // Van los dos números sueltos: el orden lo pone `public.punto()`.
            'p_lat': ubicacion.lat,
            'p_lng': ubicacion.lng,
            'p_direccion_texto': ubicacion.direccionTexto.trim(),
            'p_fecha_vencimiento': fechaVencimiento.toUtc().toIso8601String(),
            'p_referencia': _oNulo(ubicacion.referencia),
            'p_urgencia': urgencia.clave,
            'p_presupuesto': presupuestoEstimado,
          })
          .select(_columnas)
          .single();

      return Pedido.desdeFila(fila);
    });
  }

  /// Edita los campos que el Buscador puede cambiar. Solo se mandan los que
  /// llegan distintos de null: un `update` con la fila entera pisaría con
  /// nulos lo que la pantalla no editó.
  ///
  /// El estado **no** se toca acá: para eso está [cambiarEstado], que valida la
  /// máquina de estados. Tampoco es una convención que dependa de este método:
  /// desde la migración 0008 el trigger `pedidos_guard_estado` rechaza
  /// cualquier UPDATE que escriba `estado`, y el error vuelve como
  /// [CasoPedido.estadoNoModificable]. Si alguna vez aparece en pantalla, es
  /// que este mapa de cambios se llenó mal.
  Future<Pedido> actualizarPedido(
    String id, {
    String? categoriaId,
    String? titulo,
    String? descripcion,
    PedidoUrgencia? urgencia,
    Ubicacion? ubicacion,
    DateTime? fechaVencimiento,
    Object? presupuestoEstimado = _sinCambio,
  }) {
    // La ubicación no entra en este mapa: no se puede escribir un `geography`
    // desde un UPDATE de PostgREST sin construirlo. Va aparte, por RPC.
    final cambios = <String, dynamic>{
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (titulo != null) 'titulo': titulo.trim(),
      if (descripcion != null) 'descripcion': descripcion.trim(),
      if (urgencia != null) 'urgencia': urgencia.clave,
      if (fechaVencimiento != null)
        'fecha_vencimiento': fechaVencimiento.toUtc().toIso8601String(),
      // Sentinela: `null` es un valor legítimo acá (borrar el presupuesto),
      // así que no alcanza con preguntar si es null.
      if (!identical(presupuestoEstimado, _sinCambio))
        'presupuesto_estimado': presupuestoEstimado,
    };

    return _guardar(() async {
      // Primero la ubicación. No es indistinto: `actualizar_ubicacion_pedido`
      // valida dueño y estado editable, y el UPDATE de PostgREST solo lo
      // primero. Empezando por la RPC, una edición sobre un pedido cerrado
      // falla antes de haber escrito nada.
      //
      // Aun así son dos escrituras sin transacción común: si la segunda falla,
      // la primera queda hecha. Se asume a cambio de no meter todo el formulario
      // en una RPC gigante; la pantalla del CU-15 relee el pedido al terminar.
      if (ubicacion != null) {
        await actualizarUbicacion(id, ubicacion);
      }

      if (cambios.isEmpty) return _releer(id);

      final fila = await _client
          .from('pedidos')
          .update(cambios)
          .eq('id', id)
          .select(_columnas)
          .single();

      return Pedido.desdeFila(fila);
    });
  }

  /// CU-15 — Mueve el pedido de lugar.
  ///
  /// Va por la RPC `actualizar_ubicacion_pedido` (migración 0009) por el mismo
  /// motivo que el alta: el punto lo arma `public.punto(lat, lng)` en la base y
  /// el orden `(lng, lat)` de PostGIS no se escribe nunca del lado del cliente.
  ///
  /// La RPC además exige que el pedido esté `publicado` o `pausado`: un pedido
  /// cerrado, cancelado o vencido es historia y no se edita.
  Future<Pedido> actualizarUbicacion(String id, Ubicacion ubicacion) {
    _exigirSesion();

    if (!ubicacion.esValida) {
      throw const PedidoException(
        CasoPedido.desconocido,
        'La ubicación del pedido no es válida. Marcala de nuevo en el mapa.',
      );
    }

    return _guardar(() async {
      final fila = await _client
          .rpc('actualizar_ubicacion_pedido', params: {
            'p_pedido_id': id,
            'p_lat': ubicacion.lat,
            'p_lng': ubicacion.lng,
            'p_direccion_texto': ubicacion.direccionTexto.trim(),
            'p_referencia': _oNulo(ubicacion.referencia),
          })
          .select(_columnas)
          .single();

      return Pedido.desdeFila(fila);
    });
  }

  // --------------------------------------------------------------------------
  // Ciclo de vida
  // --------------------------------------------------------------------------

  /// Mueve el estado a través de la RPC `cambiar_estado_pedido`, que es la que
  /// valida la máquina de estados y deja el evento en `pedido_eventos`.
  ///
  /// Se relee el pedido después de la RPC en vez de usar lo que ella devuelve:
  /// la función retorna una fila cruda de `pedidos`, sin los computed fields
  /// `lat`/`lng` ni los embeds, así que no alcanza para armar un [Pedido].
  /// Cuesta un viaje de más y evita un modelo a medio llenar.
  Future<Pedido> cambiarEstado(
    String id,
    PedidoEstado estado, {
    String? motivo,
  }) {
    return _guardar(() async {
      await _client.rpc('cambiar_estado_pedido', params: {
        'p_pedido_id': id,
        'p_nuevo_estado': estado.clave,
        'p_motivo': _oNulo(motivo),
      });

      return _releer(id);
    });
  }

  /// CU-51 — Renueva el pedido: estira el vencimiento y lo devuelve a
  /// `publicado`. Es la única salida del estado `vencido`.
  Future<Pedido> renovar(String id, int dias) {
    return _guardar(() async {
      await _client.rpc('renovar_pedido', params: {
        'p_pedido_id': id,
        'p_dias': dias,
      });

      return _releer(id);
    });
  }

  /// Barrido de vencimientos. En producción lo dispara pg_cron; en el entorno
  /// académico lo llama la pantalla del historial al abrirse. Devuelve cuántos
  /// pedidos movió.
  ///
  /// No es indispensable para que las listas estén bien —las consultas filtran
  /// por fecha— pero sin esto el estado guardado y la realidad se separan.
  Future<int> marcarVencidos() => _guardar(() async {
        final resultado = await _client.rpc('marcar_pedidos_vencidos');
        return (resultado as num?)?.toInt() ?? 0;
      });

  // --------------------------------------------------------------------------
  // Consultas
  // --------------------------------------------------------------------------

  /// Pedidos del Buscador autenticado, del más nuevo al más viejo.
  ///
  /// El `.eq('buscador_id', ...)` **no es redundante** con las RLS. Sobre
  /// `pedidos` hay dos políticas de SELECT: la de los propios y la de los
  /// publicados vigentes de cualquiera (la que usa el Profesional). Sin este
  /// filtro, «Mis pedidos» mostraría también los de los demás.
  Future<List<Pedido>> listarMisPedidos({
    FiltroPedidos filtro = FiltroPedidos.todos,
    int limit = 20,
    int offset = 0,
  }) {
    final buscadorId = _uid;

    return _guardar(() async {
      var consulta =
          _client.from('pedidos').select(_columnas).eq('buscador_id', buscadorId);

      if (filtro.estados.isNotEmpty) {
        consulta = consulta.inFilter('estado', filtro.claves);
      }

      final filas = await consulta
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return [
        for (final fila in filas) Pedido.desdeFila(fila),
      ];
    });
  }

  /// Null cuando el pedido no existe **o** cuando las RLS no lo dejan ver: la
  /// base no distingue entre las dos cosas, y está bien que no lo haga.
  Future<Pedido?> obtenerPedido(String id) => _guardar(() async {
        final fila = await _client
            .from('pedidos')
            .select(_columnas)
            .eq('id', id)
            .maybeSingle();

        return fila == null ? null : Pedido.desdeFila(fila);
      });

  /// Cronología del pedido, de lo más reciente a lo más viejo.
  Future<List<PedidoEvento>> historial(String pedidoId) => _guardar(() async {
        final filas = await _client
            .from('pedido_eventos')
            .select('id,pedido_id,estado_anterior,estado_nuevo,actor_id,'
                'motivo,created_at')
            .eq('pedido_id', pedidoId)
            .order('created_at', ascending: false);

        return [
          for (final fila in filas) PedidoEvento.desdeFila(fila),
        ];
      });

  // --------------------------------------------------------------------------
  // Fotos
  // --------------------------------------------------------------------------

  /// Sube una imagen al bucket privado `pedidos` y registra la fila.
  ///
  /// La ruta es `{pedidoId}/{nombre}`, que es lo que exigen las políticas de
  /// Storage de la migración 0006: el primer segmento tiene que ser el id de
  /// un pedido del usuario. **Por eso el pedido tiene que existir antes**: el
  /// asistente del CU-13 inserta primero y sube después.
  Future<PedidoFoto> subirFoto({
    required String pedidoId,
    required Uint8List bytes,
    required String filename,
  }) {
    if (bytes.lengthInBytes > limiteBytes) {
      throw const PedidoException(
        CasoPedido.desconocido,
        'La imagen supera los 5 MB permitidos.',
      );
    }

    final extension = _extensionDe(filename);
    if (extension == null) {
      throw const PedidoException(
        CasoPedido.desconocido,
        'Solo se aceptan imágenes JPG, PNG o WEBP.',
      );
    }

    return _guardar(() async {
      final ordenes = await _client
          .from('pedido_fotos')
          .select('orden')
          .eq('pedido_id', pedidoId)
          .order('orden', ascending: false);

      if (ordenes.length >= PedidoFoto.maximoPorPedido) {
        throw const PedidoException(
          CasoPedido.desconocido,
          'Un pedido no puede tener más de '
              '${PedidoFoto.maximoPorPedido} fotos.',
        );
      }

      // El hueco que deja una foto borrada no se reutiliza: `orden` solo tiene
      // que ordenar, y el tope real lo cuenta el trigger por filas.
      final siguiente =
          ordenes.isEmpty ? 0 : (ordenes.first['orden'] as num).toInt() + 1;

      final ruta = '$pedidoId/${_nombreUnico()}.$extension';

      await _client.storage.from(_bucket).uploadBinary(
            ruta,
            bytes,
            fileOptions: FileOptions(contentType: _mimeDe(extension)),
          );

      try {
        final fila = await _client
            .from('pedido_fotos')
            .insert({
              'pedido_id': pedidoId,
              'storage_path': ruta,
              'orden': siguiente,
            })
            .select('id,pedido_id,storage_path,orden,created_at')
            .single();

        return PedidoFoto.desdeFila(fila);
      } catch (_) {
        // Si la fila no entró, el archivo no puede quedar dando vueltas: nadie
        // lo referencia y nadie lo va a borrar. Misma lección que el CU-11.
        await _client.storage.from(_bucket).remove([ruta]).catchError(
          (_) => <FileObject>[],
        );
        rethrow;
      }
    });
  }

  /// Borra el archivo y después la fila, en ese orden.
  ///
  /// Al revés —fila primero— un fallo al borrar el archivo dejaría el objeto
  /// en Storage sin nada que lo referencie: invisible y eterno.
  Future<void> eliminarFoto(String fotoId) => _guardar(() async {
        final fila = await _client
            .from('pedido_fotos')
            .select('id,storage_path')
            .eq('id', fotoId)
            .maybeSingle();

        if (fila == null) {
          throw const PedidoException(
            CasoPedido.sinPermiso,
            'Esa foto no existe o no es tuya.',
          );
        }

        await _client.storage
            .from(_bucket)
            .remove([fila['storage_path'] as String]);

        await _client.from('pedido_fotos').delete().eq('id', fotoId);
      });

  /// URL temporal para mostrar una foto del bucket privado.
  Future<String?> urlFirmada(PedidoFoto foto, {int segundos = 600}) async {
    try {
      return await _client.storage
          .from(_bucket)
          .createSignedUrl(foto.storagePath, segundos);
    } catch (_) {
      return null;
    }
  }

  /// Firma varias rutas de una sola vez.
  ///
  /// Es `createSignedUrls` —plural— y no un `for` con [urlFirmada] adentro: una
  /// página del historial (CU-17) trae hasta 20 pedidos, y firmar la portada de
  /// cada uno por separado son 20 viajes contra uno. Devuelve un mapa
  /// `storagePath → url`; las rutas que el servidor no pudo firmar
  /// simplemente no están en el mapa, y quien las pidió muestra el placeholder.
  ///
  /// No tira: una foto que no se puede mostrar no es motivo para romper la
  /// pantalla que la contiene, igual que en [urlFirmada].
  Future<Map<String, String>> urlsFirmadas(
    List<String> rutas, {
    int segundos = 600,
  }) async {
    if (rutas.isEmpty) return const {};

    try {
      // `createSignedUrlsResult` y no `createSignedUrls`: el plural clásico
      // está deprecado justamente porque no deja distinguir una ruta que no se
      // pudo firmar de una que sí, y acá esa diferencia es la que decide entre
      // mostrar la foto o el placeholder.
      final resultados = await _client.storage
          .from(_bucket)
          .createSignedUrlsResult(rutas, segundos);

      return {
        for (final resultado in resultados)
          if (resultado case SignedUrlSuccess(:final path, :final signedUrl))
            path: signedUrl,
      };
    } catch (_) {
      return const {};
    }
  }

  // --------------------------------------------------------------------------
  // Interno
  // --------------------------------------------------------------------------

  Future<Pedido> _releer(String id) async {
    final pedido = await obtenerPedido(id);
    if (pedido == null) {
      throw const PedidoException(
        CasoPedido.sinPermiso,
        'El pedido no existe o no es tuyo.',
      );
    }
    return pedido;
  }

  /// Igual al `file_size_limit` del bucket `pedidos` (migración 0006).
  static const int limiteBytes = 5 * 1024 * 1024;

  static const Object _sinCambio = Object();

  static String? _oNulo(String? texto) {
    final limpio = texto?.trim();
    return (limpio == null || limpio.isEmpty) ? null : limpio;
  }

  static String? _extensionDe(String filename) {
    final punto = filename.lastIndexOf('.');
    if (punto < 0) return null;

    final ext = filename.substring(punto + 1).toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'jpg',
      'png' => 'png',
      'webp' => 'webp',
      _ => null,
    };
  }

  static String _mimeDe(String extension) => switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };

  /// El nombre solo tiene que ser único dentro de la carpeta del pedido: las
  /// políticas de Storage miran el primer segmento de la ruta y nada más.
  static String _nombreUnico() {
    final azar = Random().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}_$azar';
  }
}

// ----------------------------------------------------------------------------
// Providers
// ----------------------------------------------------------------------------

@Riverpod(keepAlive: true)
PedidosRepository pedidosRepository(Ref ref) =>
    PedidosRepository(ref.watch(supabaseClientProvider));

/// Pedidos propios, filtrados por estado.
///
/// autoDispose (el default de `@riverpod`): el historial se recarga al volver
/// a entrar, que es lo que se espera después de publicar o cerrar un pedido.
@riverpod
Future<List<Pedido>> misPedidos(Ref ref, FiltroPedidos filtro) {
  ref.watch(sesionProvider);
  return ref.watch(pedidosRepositoryProvider).listarMisPedidos(filtro: filtro);
}

@riverpod
Future<Pedido?> pedido(Ref ref, String id) {
  ref.watch(sesionProvider);
  return ref.watch(pedidosRepositoryProvider).obtenerPedido(id);
}

@riverpod
Future<List<PedidoEvento>> historialPedido(Ref ref, String id) {
  ref.watch(sesionProvider);
  return ref.watch(pedidosRepositoryProvider).historial(id);
}
