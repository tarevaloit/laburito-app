import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/features/pedidos/domain/pedido.dart';
import 'package:laburito/features/pedidos/domain/pedido_estado.dart';
import 'package:laburito/features/pedidos/domain/pedido_evento.dart';
import 'package:laburito/features/pedidos/domain/pedido_foto.dart';
import 'package:laburito/features/pedidos/domain/ubicacion.dart';

/// Los modelos son el único punto donde una fila de PostgREST se convierte en
/// algo tipado. Si el mapeo se corre, no falla nada hasta que la pantalla
/// muestra un dato equivocado.
void main() {
  // Valores de los enums `pedido_estado` y `pedido_urgencia` de
  // supabase/migrations/0005_pedidos.sql.
  const estadosDeLaBase = [
    'publicado',
    'pausado',
    'cerrado',
    'cancelado',
    'vencido',
  ];
  const urgenciasDeLaBase = ['baja', 'media', 'alta'];

  /// Fila completa, tal como la devuelve el `select` del repositorio.
  Map<String, dynamic> fila({
    String estado = 'publicado',
    String urgencia = 'media',
    Object? lat = -34.6037,
    Object? lng = -58.3816,
    Object? presupuesto = 45000.50,
    Object? fechaCierre,
    Object? categoria = const {'nombre': 'Plomería'},
    List<Map<String, dynamic>>? fotos,
  }) =>
      {
        'id': 'p-1',
        'buscador_id': 'b-1',
        'categoria_id': 'c-1',
        'titulo': 'Pérdida en el termotanque',
        'descripcion': 'Pierde agua por la base desde ayer.',
        'urgencia': urgencia,
        'estado': estado,
        'lat': lat,
        'lng': lng,
        'direccion_texto': 'Av. Siempreviva 742, CABA',
        'referencia_ubicacion': 'Piso 3, depto B',
        'presupuesto_estimado': presupuesto,
        'fecha_publicacion': '2026-09-01T10:00:00+00:00',
        'fecha_vencimiento': '2026-09-08T10:00:00+00:00',
        'fecha_cierre': fechaCierre,
        'motivo_cierre': null,
        'renovaciones': 1,
        'created_at': '2026-09-01T10:00:00+00:00',
        'updated_at': '2026-09-01T10:00:00+00:00',
        'categorias_oficio': categoria,
        'pedido_fotos': fotos,
      };

  Map<String, dynamic> filaFoto(String id, int orden) => {
        'id': id,
        'pedido_id': 'p-1',
        'storage_path': 'p-1/$id.jpg',
        'orden': orden,
        'created_at': '2026-09-01T10:00:00+00:00',
      };

  group('enums contra los de PostgreSQL', () {
    test('todo valor de pedido_estado tiene su constante en Dart', () {
      for (final clave in estadosDeLaBase) {
        expect(PedidoEstado.desdeClave(clave).clave, clave);
      }
      expect(PedidoEstado.values.length, estadosDeLaBase.length,
          reason: 'sobra o falta un estado respecto de la migración 0005');
    });

    test('todo valor de pedido_urgencia tiene su constante en Dart', () {
      for (final clave in urgenciasDeLaBase) {
        expect(PedidoUrgencia.desdeClave(clave).clave, clave);
      }
      expect(PedidoUrgencia.values.length, urgenciasDeLaBase.length);
    });

    test('ningún estado se muestra crudo', () {
      for (final estado in PedidoEstado.values) {
        expect(estado.etiqueta, isNotEmpty);
        expect(estado.etiqueta, isNot(contains('_')));
      }
    });

    test('un valor desconocido falla fuerte y dice por qué', () {
      expect(
        () => PedidoEstado.desdeClave('adjudicado'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('máquina de estados, espejo de transicion_pedido_valida', () {
    // La tabla de la migración 0006, escrita a mano para que el test falle si
    // alguien cambia una sin la otra.
    const permitidas = {
      PedidoEstado.publicado: {
        PedidoEstado.pausado,
        PedidoEstado.cerrado,
        PedidoEstado.cancelado,
        PedidoEstado.vencido,
      },
      PedidoEstado.pausado: {
        PedidoEstado.publicado,
        PedidoEstado.cerrado,
        PedidoEstado.cancelado,
        PedidoEstado.vencido,
      },
      PedidoEstado.vencido: <PedidoEstado>{},
      PedidoEstado.cerrado: <PedidoEstado>{},
      PedidoEstado.cancelado: <PedidoEstado>{},
    };

    test('coincide transición por transición', () {
      for (final desde in PedidoEstado.values) {
        for (final hasta in PedidoEstado.values) {
          expect(
            desde.puedePasarA(hasta),
            permitidas[desde]!.contains(hasta),
            reason: '${desde.clave} → ${hasta.clave}',
          );
        }
      }
    });

    test('cerrado y cancelado son terminales', () {
      expect(PedidoEstado.cerrado.esTerminal, isTrue);
      expect(PedidoEstado.cancelado.esTerminal, isTrue);
      expect(PedidoEstado.publicado.esTerminal, isFalse);
    });

    test('de vencido solo se sale renovando, no cambiando de estado', () {
      expect(PedidoEstado.vencido.puedePasarA(PedidoEstado.publicado), isFalse);
    });
  });

  group('Ubicacion', () {
    const ubicacion = Ubicacion(
      lat: -34.6037,
      lng: -58.3816,
      direccionTexto: 'Av. Siempreviva 742',
    );

    // El orden `(lng, lat)` ya no se prueba acá: desde la migración 0009 lo
    // pone `public.punto()` del lado del servidor y `aEwkt()` se borró. La ida
    // y vuelta de la coordenada está en `test/pedidos_geografia_test.dart`.

    test('rechaza coordenadas fuera de rango y direcciones vacías', () {
      expect(ubicacion.esValida, isTrue);
      expect(ubicacion.copyWith(lat: 91).esValida, isFalse);
      expect(ubicacion.copyWith(lng: -181).esValida, isFalse);
      expect(ubicacion.copyWith(direccionTexto: '   ').esValida, isFalse);
    });
  });

  group('Pedido.desdeFila', () {
    test('mapea la fila completa', () {
      final pedido = Pedido.desdeFila(fila());

      expect(pedido.id, 'p-1');
      expect(pedido.buscadorId, 'b-1');
      expect(pedido.titulo, 'Pérdida en el termotanque');
      expect(pedido.estado, PedidoEstado.publicado);
      expect(pedido.urgencia, PedidoUrgencia.media);
      expect(pedido.categoriaNombre, 'Plomería');
      expect(pedido.presupuestoEstimado, 45000.50);
      expect(pedido.renovaciones, 1);
      expect(pedido.ubicacion.lat, -34.6037);
      expect(pedido.ubicacion.lng, -58.3816);
      expect(pedido.ubicacion.referencia, 'Piso 3, depto B');
      expect(pedido.fechaCierre, isNull);
      expect(pedido.fotos, isEmpty);
    });

    test('las fechas quedan en hora local, no en UTC', () {
      final pedido = Pedido.desdeFila(fila());

      expect(pedido.fechaPublicacion.isUtc, isFalse);
      expect(
        pedido.fechaPublicacion.toUtc(),
        DateTime.utc(2026, 9, 1, 10),
      );
    });

    test('lat/lng enteros no rompen el mapeo', () {
      // PostgREST manda `-34` y no `-34.0` cuando el valor no tiene decimales.
      final pedido = Pedido.desdeFila(fila(lat: -34, lng: -58));

      expect(pedido.ubicacion.lat, -34.0);
      expect(pedido.ubicacion.lng, -58.0);
    });

    test('presupuesto entero llega como double', () {
      final pedido = Pedido.desdeFila(fila(presupuesto: 45000));
      expect(pedido.presupuestoEstimado, 45000.0);
    });

    test('tolera los nulos y los embeds ausentes', () {
      final pedido = Pedido.desdeFila(
        fila(presupuesto: null, categoria: null, fotos: null),
      );

      expect(pedido.presupuestoEstimado, isNull);
      expect(pedido.categoriaNombre, isNull);
      expect(pedido.fotos, isEmpty);
    });

    test('las fotos quedan ordenadas por orden, llegue como llegue', () {
      final pedido = Pedido.desdeFila(fila(fotos: [
        filaFoto('f-c', 2),
        filaFoto('f-a', 0),
        filaFoto('f-b', 1),
      ]));

      expect([for (final f in pedido.fotos) f.id], ['f-a', 'f-b', 'f-c']);
      expect(pedido.portada?.id, 'f-a');
      expect(pedido.portada?.esPortada, isTrue);
    });

    test('fecha_cierre se mapea cuando viene', () {
      final pedido = Pedido.desdeFila(
        fila(estado: 'cerrado', fechaCierre: '2026-09-05T12:00:00+00:00'),
      );

      expect(pedido.fechaCierre?.toUtc(), DateTime.utc(2026, 9, 5, 12));
    });
  });

  group('reglas de negocio del Pedido', () {
    // fecha_vencimiento de la fila base: 2026-09-08 10:00 UTC.
    final antes = DateTime.utc(2026, 9, 2);
    final despues = DateTime.utc(2026, 9, 9);

    test('vigente solo si está publicado y no venció', () {
      expect(Pedido.desdeFila(fila()).estaVigente(antes), isTrue);
      expect(Pedido.desdeFila(fila()).estaVigente(despues), isFalse);
      expect(
        Pedido.desdeFila(fila(estado: 'pausado')).estaVigente(antes),
        isFalse,
      );
    });

    test('los días restantes nunca son negativos', () {
      expect(Pedido.desdeFila(fila()).diasRestantes(antes), 6);
      expect(Pedido.desdeFila(fila()).diasRestantes(despues), 0);
    });

    test('no se renueva un pedido al que le sobra vigencia', () {
      // Faltan 6 días y la ventana es de 3.
      expect(Pedido.desdeFila(fila()).puedeRenovarse(antes), isFalse);
    });

    test('se renueva dentro de la ventana de 3 días', () {
      final aDosDias = DateTime.utc(2026, 9, 6, 10);
      expect(Pedido.desdeFila(fila()).puedeRenovarse(aDosDias), isTrue);
    });

    test('un pedido vencido siempre se puede renovar', () {
      final vencido = Pedido.desdeFila(fila(estado: 'vencido'));
      expect(vencido.puedeRenovarse(antes), isTrue);
    });

    test('los terminales no se renuevan', () {
      expect(
        Pedido.desdeFila(fila(estado: 'cancelado')).puedeRenovarse(despues),
        isFalse,
      );
      expect(
        Pedido.desdeFila(fila(estado: 'cerrado')).puedeRenovarse(despues),
        isFalse,
      );
    });

    test('el tope de 3 renovaciones corta', () {
      final agotado =
          Pedido.desdeFila(fila(estado: 'vencido')).copyWith(renovaciones: 3);

      expect(agotado.puedeRenovarse(despues), isFalse);
      expect(agotado.renovacionesRestantes, 0);
    });

    test('el tope de 5 fotos corta', () {
      final base = Pedido.desdeFila(fila());
      expect(base.puedeAgregarFotos, isTrue);

      final lleno = base.copyWith(fotos: [
        for (var i = 0; i < PedidoFoto.maximoPorPedido; i++)
          PedidoFoto.desdeFila(filaFoto('f-$i', i)),
      ]);
      expect(lleno.puedeAgregarFotos, isFalse);
    });
  });

  group('PedidoEvento.desdeFila', () {
    Map<String, dynamic> filaEvento({
      String? anterior = 'publicado',
      String nuevo = 'pausado',
      String? actor = 'b-1',
    }) =>
        {
          'id': 'e-1',
          'pedido_id': 'p-1',
          'estado_anterior': anterior,
          'estado_nuevo': nuevo,
          'actor_id': actor,
          'motivo': 'Lo resolví por mi cuenta',
          'created_at': '2026-09-03T09:00:00+00:00',
        };

    test('mapea los dos estados', () {
      final evento = PedidoEvento.desdeFila(filaEvento());

      expect(evento.estadoAnterior, PedidoEstado.publicado);
      expect(evento.estadoNuevo, PedidoEstado.pausado);
      expect(evento.descripcion, 'De Publicado a Pausado');
      expect(evento.esAutomatico, isFalse);
    });

    test('sin estado anterior no se inventa uno', () {
      final evento = PedidoEvento.desdeFila(filaEvento(anterior: null));

      expect(evento.estadoAnterior, isNull);
      expect(evento.descripcion, 'Pasó a Pausado');
    });

    test('sin actor, el evento es del servidor (pg_cron)', () {
      final evento = PedidoEvento.desdeFila(
        filaEvento(nuevo: 'vencido', actor: null),
      );

      expect(evento.esAutomatico, isTrue);
      expect(evento.estadoNuevo, PedidoEstado.vencido);
    });
  });

  group('FiltroPedidos', () {
    test('«todos» no filtra', () {
      expect(FiltroPedidos.todos.estados, isEmpty);
      expect(FiltroPedidos.todos.claves, isEmpty);
    });

    test('activos e historial parten los estados sin superponerse', () {
      final activos = FiltroPedidos.activos.estados;
      final historial = FiltroPedidos.historial.estados;

      expect(activos.intersection(historial), isEmpty);
      expect({...activos, ...historial}, PedidoEstado.values.toSet(),
          reason: 'algún estado no cae en ningún filtro');
    });

    test('las claves son las de la base', () {
      expect(FiltroPedidos.activos.claves, ['publicado', 'pausado']);
    });
  });
}
