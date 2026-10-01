import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/supabase_providers.dart';
import '../../data/billetera_repository.dart';
import '../../domain/movimiento_tokens.dart';
import '../../domain/pago.dart';
import '../../domain/paquete_tokens.dart';

part 'billetera_controller.freezed.dart';
part 'billetera_controller.g.dart';

@freezed
abstract class EstadoBilletera with _$EstadoBilletera {
  const EstadoBilletera._();

  const factory EstadoBilletera({
    required int saldo,
    @Default(<MovimientoTokens>[]) List<MovimientoTokens> movimientos,
    @Default(<PaqueteTokens>[]) List<PaqueteTokens> paquetes,

    /// La última recarga falló y lo que se muestra es lo anterior (flujo
    /// alterno del CU-30: «último saldo almacenado, con la advertencia Sin
    /// conexión»).
    @Default(false) bool sinConexion,
  }) = _EstadoBilletera;

  /// Con menos de esto, la pantalla empuja a comprar (paso 6 del CU-30).
  static const int umbralSaldoBajo = 3;

  bool get saldoBajo => saldo < umbralSaldoBajo;

  /// El pack más chico, contra el que se calcula el ahorro de los demás.
  PaqueteTokens? get paqueteDeReferencia => paquetes.isEmpty
      ? null
      : paquetes.reduce((a, b) => a.cantidad <= b.cantidad ? a : b);
}

/// CU-30 — Consultar Saldo de Tokens.
///
/// keepAlive a propósito: es lo que hace posible el flujo alterno de la ERS.
/// Si una recarga falla, la billetera no se vacía: queda el último saldo
/// leído, marcado como «sin conexión». Y el saldo se consulta desde varias
/// pantallas —la billetera y el detalle del pedido del CU-25— sin pedirlo dos
/// veces.
///
/// Mira la sesión, como `perfilCompleto`: un provider que sobrevive a la
/// pantalla no puede sobrevivirle al usuario. Sin esto, cerrar sesión y entrar
/// con otra cuenta mostraría el saldo de la anterior.
@Riverpod(keepAlive: true)
class Billetera extends _$Billetera {
  @override
  Future<EstadoBilletera> build() {
    ref.watch(sesionProvider);

    // Un pago se puede acreditar mientras la app está en segundo plano (el
    // webhook no espera a nadie). Al volver a primer plano se relee, y así el
    // saldo queda al día en todas las pantallas que lo muestran, no solo en
    // la billetera.
    final alVolver = AppLifecycleListener(onResume: refrescar);
    ref.onDispose(alVolver.dispose);

    return _leer();
  }

  Future<EstadoBilletera> _leer() async {
    final repo = ref.read(billeteraRepositoryProvider);
    final (saldo, movimientos, paquetes) = await (
      repo.saldo(),
      repo.movimientos(),
      repo.paquetes(),
    ).wait;

    return EstadoBilletera(
      saldo: saldo,
      movimientos: movimientos,
      paquetes: paquetes,
    );
  }

  Future<void> refrescar() async {
    final anterior = state.valueOrNull;
    try {
      state = AsyncData(await _leer());
    } on Object catch (error, pila) {
      state = anterior == null
          ? AsyncError(error, pila)
          : AsyncData(anterior.copyWith(sinConexion: true));
    }
  }

  /// El saldo que devolvió una operación (desbloqueo, canje), sin esperar a la
  /// recarga completa. La recarga viene atrás y trae el movimiento.
  void saldoActualizado(int saldo) {
    final actual = state.valueOrNull;
    if (actual != null) state = AsyncData(actual.copyWith(saldo: saldo));
    refrescar();
  }
}

@freezed
abstract class EstadoHistorialPagos with _$EstadoHistorialPagos {
  const factory EstadoHistorialPagos({
    @Default(<Pago>[]) List<Pago> pagos,
    @Default(false) bool cargandoMas,
    @Default(true) bool hayMas,
  }) = _EstadoHistorialPagos;
}

/// CU-33 — Ver Historial de Pagos. Aprobados, pendientes y rechazados, del más
/// reciente al más viejo, de a veinte, con el mismo scroll infinito del CU-17.
@riverpod
class HistorialPagos extends _$HistorialPagos {
  @override
  Future<EstadoHistorialPagos> build() async {
    final pagos = await ref.read(billeteraRepositoryProvider).pagos();
    return EstadoHistorialPagos(
      pagos: pagos,
      hayMas: pagos.length == BilleteraRepository.tamanioPagina,
    );
  }

  Future<void> cargarMas() async {
    final actual = state.valueOrNull;
    if (actual == null || actual.cargandoMas || !actual.hayMas) return;

    state = AsyncData(actual.copyWith(cargandoMas: true));
    try {
      final mas = await ref
          .read(billeteraRepositoryProvider)
          .pagos(desde: actual.pagos.length);
      state = AsyncData(actual.copyWith(
        pagos: [...actual.pagos, ...mas],
        cargandoMas: false,
        hayMas: mas.length == BilleteraRepository.tamanioPagina,
      ));
    } on Object {
      state = AsyncData(actual.copyWith(cargandoMas: false));
    }
  }
}
