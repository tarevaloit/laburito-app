import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/dinero.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../billetera/domain/paquete_tokens.dart';
import '../../../billetera/presentation/controllers/billetera_controller.dart';
import '../../data/admin_repository.dart';
import '../widgets/dialogos_admin.dart';
import 'panel_admin.dart';

/// Flujo alterno del CU-40: cero, negativo o vacío se rechazan antes de
/// salir. La base los rechaza igual (`actualizar_precio_paquete`, 0024).
abstract final class PreciosScreenValidaciones {
  static String? validarPrecio(String? valor) {
    final precio = int.tryParse(valor?.trim() ?? '');
    if (precio == null || precio <= 0) {
      return 'El precio tiene que ser un número entero positivo';
    }
    return null;
  }
}

/// CU-40 — Configurar Precio de Tokens.
///
/// La grilla de precios vigentes con un campo por paquete. Guardar pide la
/// contraseña otra vez (paso 4 de la ERS) y cambia solo los precios que se
/// tocaron. El precio nuevo rige para la próxima compra: los pagos ya
/// iniciados conservan el monto que se les copió (migración 0021).
class PreciosScreen extends ConsumerStatefulWidget {
  const PreciosScreen({super.key});

  @override
  ConsumerState<PreciosScreen> createState() => _PreciosScreenState();
}

class _PreciosScreenState extends ConsumerState<PreciosScreen> {
  final Map<String, TextEditingController> _campos = {};
  final _formulario = GlobalKey<FormState>();
  bool _guardando = false;

  @override
  void dispose() {
    for (final c in _campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _campo(PaqueteTokens p) => _campos.putIfAbsent(
        p.id,
        () => TextEditingController(text: '${p.precioArs}'),
      );

  Map<PaqueteTokens, int> _cambios(List<PaqueteTokens> paquetes) => {
        for (final p in paquetes)
          if (int.tryParse(_campo(p).text.trim()) case final nuevo?
              when nuevo != p.precioArs)
            p: nuevo,
      };

  Future<String?> _pedirPassword() => pedirContrasena(
        context,
        aviso: 'Cambiar precios impacta en el momento en la app de todos los '
            'Profesionales.',
      );

  Future<void> _guardar(List<PaqueteTokens> paquetes) async {
    if (!(_formulario.currentState?.validate() ?? false)) return;

    final cambios = _cambios(paquetes);
    if (cambios.isEmpty) {
      mostrarMensaje(context, 'No cambiaste ningún precio.', esError: false);
      return;
    }

    final password = await _pedirPassword();
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _guardando = true);
    final repo = ref.read(adminRepositoryProvider);
    try {
      await repo.reautenticar(password);
      for (final MapEntry(key: paquete, value: precio) in cambios.entries) {
        await repo.actualizarPrecio(paquete.id, precio);
      }
      ref.invalidate(paquetesAdminProvider);
      ref.invalidate(billeteraProvider);
      if (mounted) {
        mostrarMensaje(
          context,
          cambios.length == 1
              ? 'Precio actualizado.'
              : '${cambios.length} precios actualizados.',
          esError: false,
        );
      }
    } on Object catch (error) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(error));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paquetes = ref.watch(paquetesAdminProvider);

    return PanelAdmin(
      actual: SeccionAdmin.precios,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const EncabezadoAdmin(
            titulo: 'Configuración comercial',
            bajada: 'Precios de los paquetes de tokens, en pesos',
          ),
          const SizedBox(height: 24),
          paquetes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(MensajesError.desde(e)),
            data: (lista) => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: TarjetaPanel(
                child: Form(
                  key: _formulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final p in lista) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pack ${p.nombre}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    Text(
                                      '${p.cantidad} tokens · hoy '
                                      '${Dinero.pesos(p.precioArs)}',
                                      style: const TextStyle(
                                          color: Colores.textoSecundario,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 180,
                              child: CampoTexto(
                                key: Key('precio-${p.nombre}'),
                                etiqueta: 'Precio (ARS)',
                                controller: _campo(p),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: PreciosScreenValidaciones.validarPrecio,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      BotonPrincipal(
                        texto: 'Guardar precios',
                        cargando: _guardando,
                        onPressed: () => _guardar(lista),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paso 4 del CU-40: la contraseña otra vez antes de guardar.
///
/// Es un widget con estado y no un `AlertDialog` armado en el momento porque
/// el controlador del campo tiene que vivir **lo mismo que el diálogo**. Antes
/// se descartaba cuando el `showDialog` devolvía el resultado, pero el diálogo
/// todavía estaba animando su salida y volvía a dibujar el campo: «A
/// TextEditingController was used after being disposed», y la pantalla roja.
