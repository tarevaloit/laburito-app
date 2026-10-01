import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/admin_repository.dart';
import '../../data/cupon.dart';
import 'panel_admin.dart';

/// CU-52 — Crear Cupón Promocional (Figura 3.24): el formulario a la izquierda
/// y los cupones existentes a la derecha. En pantallas angostas, uno abajo del
/// otro.
class CuponesScreen extends ConsumerWidget {
  const CuponesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PanelAdmin(
      actual: SeccionAdmin.cupones,
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final enColumnas = restricciones.maxWidth >= 760;
          const formulario = _NuevoCupon();
          const lista = _ListaCupones();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const EncabezadoAdmin(
                titulo: 'Campañas y cupones',
                bajada: 'Generá códigos para regalar tokens',
              ),
              const SizedBox(height: 24),
              if (enColumnas)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 320, child: formulario),
                    SizedBox(width: 20),
                    Expanded(child: lista),
                  ],
                )
              else ...[
                formulario,
                const SizedBox(height: 20),
                lista,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _NuevoCupon extends ConsumerStatefulWidget {
  const _NuevoCupon();

  @override
  ConsumerState<_NuevoCupon> createState() => _NuevoCuponState();
}

class _NuevoCuponState extends ConsumerState<_NuevoCupon> {
  final _formulario = GlobalKey<FormState>();
  final _codigo = TextEditingController();
  final _tokens = TextEditingController();
  final _limite = TextEditingController();
  DateTime? _vence;
  bool _guardando = false;

  @override
  void dispose() {
    _codigo.dispose();
    _tokens.dispose();
    _limite.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _vence ?? hoy.add(const Duration(days: 30)),
      // Flujo alterno del CU-52: una fecha pasada no se puede ni elegir.
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: hoy.add(const Duration(days: 730)),
      helpText: 'Vence el',
    );
    if (elegida != null) setState(() => _vence = elegida);
  }

  Future<void> _crear() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    if (_vence == null) {
      mostrarMensaje(context, 'Elegí una fecha de vencimiento.');
      return;
    }

    setState(() => _guardando = true);
    try {
      final cupon = await ref.read(adminRepositoryProvider).crearCupon(
            codigo: _codigo.text.trim(),
            tokens: int.parse(_tokens.text.trim()),
            vence: _vence!,
            limiteUsos: int.tryParse(_limite.text.trim()),
          );
      ref.invalidate(cuponesAdminProvider);
      _formulario.currentState?.reset();
      _codigo.clear();
      _tokens.clear();
      _limite.clear();
      setState(() => _vence = null);
      if (mounted) {
        mostrarMensaje(context, 'Cupón ${cupon.codigo} creado.', esError: false);
      }
    } on Object catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  static String? validarCodigo(String? valor) =>
      Cupon.formatoCodigo.hasMatch((valor ?? '').trim().toUpperCase())
          ? null
          : 'Entre 4 y 20 letras o números, sin espacios';

  static String? validarTokens(String? valor) {
    final n = int.tryParse(valor?.trim() ?? '');
    return n == null || n < 1 || n > Cupon.tokensMaximos
        ? 'Entre 1 y ${Cupon.tokensMaximos}'
        : null;
  }

  static String? validarLimite(String? valor) {
    if ((valor ?? '').trim().isEmpty) return null;
    final n = int.tryParse(valor!.trim());
    return n == null || n < 1 ? 'Un número positivo, o vacío' : null;
  }

  @override
  Widget build(BuildContext context) {
    return TarjetaPanel(
      child: Form(
        key: _formulario,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nuevo cupón',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            CampoTexto(
              key: const Key('cupon-codigo'),
              etiqueta: 'Código promocional',
              controller: _codigo,
              ejemplo: 'BIENVENIDA10',
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
              ],
              validator: validarCodigo,
            ),
            const SizedBox(height: 12),
            CampoTexto(
              key: const Key('cupon-tokens'),
              etiqueta: 'Tokens a regalar',
              controller: _tokens,
              ejemplo: '10',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: validarTokens,
            ),
            const SizedBox(height: 12),
            const Text('Fecha de vencimiento',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(_vence == null ? 'Elegir fecha' : Fechas.corta(_vence!)),
            ),
            const SizedBox(height: 12),
            CampoTexto(
              key: const Key('cupon-limite'),
              etiqueta: 'Límite de usos',
              controller: _limite,
              ejemplo: 'Vacío = sin límite',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: validarLimite,
            ),
            const SizedBox(height: 20),
            BotonPrincipal(
              texto: 'Generar cupón',
              cargando: _guardando,
              onPressed: _crear,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaCupones extends ConsumerWidget {
  const _ListaCupones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cupones = ref.watch(cuponesAdminProvider);

    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Cupones',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          cupones.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(MensajesError.desde(e)),
            data: (lista) => lista.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Todavía no creaste ningún cupón.',
                        style: TextStyle(color: Colores.textoSecundario)),
                  )
                : Column(
                    children: [
                      for (final c in lista) _FilaCupon(cupon: c),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilaCupon extends StatelessWidget {
  const _FilaCupon({required this.cupon});

  final Cupon cupon;

  @override
  Widget build(BuildContext context) {
    final estado = cupon.estado();
    final activo = estado == EstadoCupon.activo;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colores.borde)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colores.azulSuave,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cupon.codigo,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: Colores.azul,
              ),
            ),
          ),
          Text('+${cupon.tokens} tokens',
              style: const TextStyle(
                  color: Colores.naranja, fontWeight: FontWeight.w700)),
          Text('${cupon.venceLegible} · ${cupon.usosLegible}',
              style: const TextStyle(
                  color: Colores.textoSecundario, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: activo ? Colores.exitoSuave : Colores.errorSuave,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              estado.etiqueta,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: activo ? Colores.exito : Colores.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
