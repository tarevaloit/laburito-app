import 'package:flutter_test/flutter_test.dart';
import 'package:laburito/core/errors/mensajes_error.dart';
import 'package:laburito/features/pedidos/data/pedido_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// El contrato entre las RPC de la migración 0006 y la app: el **código** dice
/// que hubo un error de negocio y el **hint** dice cuál. El texto del mensaje
/// es para el usuario y puede cambiar sin romper nada; la clave, no.
void main() {
  PostgrestException pg(String code, {String? hint, String message = 'x'}) =>
      PostgrestException(message: message, code: code, hint: hint);

  group('errores de negocio de las RPC (P0001 + hint)', () {
    test('transición inválida', () {
      final e = PedidoException.desde(pg(
        'P0001',
        hint: 'transicion_invalida',
        message: 'Un pedido cancelado no se puede reabrir',
      ));

      expect(e.caso, CasoPedido.transicionInvalida);
      expect(e.message, 'Un pedido cancelado no se puede reabrir');
    });

    test('límite de renovaciones', () {
      final e = PedidoException.desde(pg(
        'P0001',
        hint: 'limite_renovaciones',
        message: 'El pedido ya se renovó 3 veces: publicá uno nuevo',
      ));

      expect(e.caso, CasoPedido.limiteRenovaciones);
      expect(e.message, contains('3 veces'));
    });

    test('sin permiso', () {
      final e = PedidoException.desde(pg(
        'P0001',
        hint: 'sin_permiso',
        message: 'El pedido no existe o no es tuyo',
      ));

      expect(e.caso, CasoPedido.sinPermiso);
      expect(e.message, 'El pedido no existe o no es tuyo');
    });

    test('un hint que la app todavía no conoce no rompe: cae en desconocido, '
        'pero conserva el mensaje del servidor', () {
      final e = PedidoException.desde(pg(
        'P0001',
        hint: 'clave_futura',
        message: 'Todavía no se puede renovar',
      ));

      expect(e.caso, CasoPedido.desconocido);
      expect(e.message, 'Todavía no se puede renovar');
    });

    test('un P0001 sin hint también conserva su mensaje', () {
      // Es el caso del trigger `pedido_fotos_limite`, de la migración 0005,
      // que no manda hint.
      final e = PedidoException.desde(pg(
        'P0001',
        message: 'Un pedido no puede tener más de 5 fotos',
      ));

      expect(e.caso, CasoPedido.desconocido);
      expect(e.message, 'Un pedido no puede tener más de 5 fotos');
    });
  });

  group('errores de infraestructura', () {
    test('42501 (RLS) es sin permiso y NO filtra el texto de Postgres', () {
      final e = PedidoException.desde(pg(
        '42501',
        message: 'new row violates row-level security policy for table "pedidos"',
      ));

      expect(e.caso, CasoPedido.sinPermiso);
      expect(e.message, 'No encontramos ese pedido, o no es tuyo.');
      expect(e.message, isNot(contains('row-level security')));
    });

    test('PGRST116 (cero filas en un .single) es sin permiso', () {
      final e = PedidoException.desde(pg('PGRST116'));
      expect(e.caso, CasoPedido.sinPermiso);
    });

    test('23505 avisa de la foto duplicada', () {
      final e = PedidoException.desde(pg(
        '23505',
        message: 'duplicate key value violates unique constraint',
      ));

      expect(e.caso, CasoPedido.desconocido);
      expect(e.message, contains('foto'));
      expect(e.message, isNot(contains('duplicate key')));
    });

    test('23514 manda a revisar el formulario', () {
      final e = PedidoException.desde(pg('23514'));
      expect(e.message, contains('título'));
    });

    test('PGRST202 dice que falta aplicar una migración', () {
      final e = PedidoException.desde(pg('PGRST202'));
      expect(e.message, contains('migración'));
    });

    test('un código que no conocemos no se muestra crudo', () {
      final e = PedidoException.desde(pg(
        '40001',
        message: 'could not serialize access due to concurrent update',
      ));

      expect(e.caso, CasoPedido.desconocido);
      expect(e.message, 'No pudimos completar la operación. Intentá nuevamente.');
    });

    test('un error que no es de Postgrest también queda envuelto', () {
      final e = PedidoException.desde(StateError('boom'));

      expect(e.caso, CasoPedido.desconocido);
      expect(e.message, isNot(contains('boom')));
      expect(e.causa, isA<StateError>());
    });

    test('el error original queda guardado para el log', () {
      final original = pg('42501');
      expect(PedidoException.desde(original).causa, same(original));
    });
  });

  group('integración con MensajesError', () {
    test('un PedidoException no se vuelve a envolver', () {
      const original = PedidoException(CasoPedido.sinPermiso, 'No es tuyo.');
      expect(PedidoException.desde(original), same(original));
    });

    test('MensajesError lo muestra tal cual, sin traducirlo', () {
      // Es lo que consigue implementar ErrorDeNegocio: si se rompiera esa
      // relación, el usuario vería el genérico «Ocurrió un error inesperado».
      const e = PedidoException(
        CasoPedido.limiteRenovaciones,
        'El pedido ya se renovó 3 veces: publicá uno nuevo',
      );

      expect(MensajesError.desde(e),
          'El pedido ya se renovó 3 veces: publicá uno nuevo');
    });

    test('el mensaje que se muestra sale del mapeo, no del crudo de Postgres',
        () {
      final e = PedidoException.desde(pg(
        '42501',
        message: 'permission denied for table pedidos',
      ));

      expect(MensajesError.desde(e), 'No encontramos ese pedido, o no es tuyo.');
    });
  });
}
