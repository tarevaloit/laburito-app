import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/admin_repository.dart';
import '../../domain/parametro.dart';
import '../widgets/dialogos_admin.dart';
import 'panel_admin.dart';

/// CU-47 — Configurar Parámetros Globales: «Configuración del Sistema». Cada
/// parámetro con su valor, su rango y su descripción; «Aplicar cambios
/// globales» pide una segunda confirmación y la contraseña (paso 4).
class ParametrosScreen extends ConsumerStatefulWidget {
  const ParametrosScreen({super.key});

  @override
  ConsumerState<ParametrosScreen> createState() => _ParametrosScreenState();
}

class _ParametrosScreenState extends ConsumerState<ParametrosScreen> {
  final _formulario = GlobalKey<FormState>();
  final _campos = <String, TextEditingController>{};
  bool _guardando = false;

  @override
  void dispose() {
    for (final c in _campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _campo(Parametro p) =>
      _campos.putIfAbsent(p.clave, () => TextEditingController(text: '${p.valor}'));

  Map<Parametro, int> _cambios(List<Parametro> lista) => {
        for (final p in lista)
          if (int.tryParse(_campo(p).text.trim()) case final nuevo?
              when nuevo != p.valor)
            p: nuevo,
      };

  Future<void> _aplicar(List<Parametro> lista) async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final cambios = _cambios(lista);
    if (cambios.isEmpty) {
      mostrarMensaje(context, 'No cambiaste ningún parámetro.', esError: false);
      return;
    }

    final seguro = await confirmarAccion(
      context,
      titulo: 'Aplicar cambios globales',
      mensaje: [
        for (final e in cambios.entries)
          '${e.key.nombre}: ${e.key.valor} → ${e.value} ${e.key.unidad}',
        '',
        'Cambia el comportamiento de la aplicación para todos los usuarios '
            'desde la próxima operación.',
      ].join('\n'),
      confirmar: 'Continuar',
    );
    if (!seguro || !mounted) return;

    final password = await pedirContrasena(
      context,
      aviso: 'Los parámetros globales impactan en toda la plataforma.',
    );
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _guardando = true);
    final repo = ref.read(adminRepositoryProvider);
    try {
      await repo.reautenticar(password);
      for (final e in cambios.entries) {
        await repo.actualizarParametro(e.key.clave, e.value);
      }
      ref.invalidate(parametrosAdminProvider);
      if (mounted) {
        mostrarMensaje(context, 'Parámetros actualizados.', esError: false);
      }
    } catch (e) {
      // Si falló a mitad de camino, la lista se recarga: lo que se guardó se
      // ve guardado y el resto conserva su valor anterior.
      ref.invalidate(parametrosAdminProvider);
      if (mounted) mostrarMensaje(context, MensajesError.desde(e));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parametros = ref.watch(parametrosAdminProvider);

    return PanelAdmin(
      actual: SeccionAdmin.parametros,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const EncabezadoAdmin(
            titulo: 'Configuración del sistema',
            bajada: 'Constantes que usa la plataforma en cada operación',
          ),
          const SizedBox(height: 20),
          parametros.when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AvisoEstado.riesgo(
              icono: Icons.error_outline,
              titulo: 'No pudimos cargar los parámetros',
              detalle: MensajesError.desde(e),
            ),
            data: (lista) {
              return Form(
                key: _formulario,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final p in lista) ...[
                        TarjetaPanel(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.nombre,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Colores.texto)),
                                    const SizedBox(height: 4),
                                    Text(p.descripcion,
                                        style: const TextStyle(
                                            color: Colores.textoSecundario)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rango: ${p.minimo} a ${p.maximo} ${p.unidad}'
                                      '${p.actualizadoAt == null ? '' : ' · actualizado el ${Fechas.corta(p.actualizadoAt!.toLocal())}'}',
                                      style: const TextStyle(
                                          color: Colores.textoTenue, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 140,
                                child: CampoTexto(
                                  key: Key('parametro-${p.clave}'),
                                  etiqueta: p.unidad,
                                  controller: _campo(p),
                                  enabled: !_guardando,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                                  ],
                                  validator: p.validar,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          key: const Key('aplicar-parametros'),
                          onPressed: _guardando ? null : () => _aplicar(lista),
                          icon: _guardando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.published_with_changes),
                          label: const Text('Aplicar cambios globales'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
