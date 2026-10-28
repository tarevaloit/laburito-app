import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/categorias_admin_repository.dart';
import '../widgets/dialogos_admin.dart';
import 'panel_admin.dart';

/// CU-37 — Gestionar Categorías de Oficios (Figura 3.23): una tarjeta por
/// oficio con su ícono, el estado y el interruptor para ocultarlo.
class CategoriasAdminScreen extends ConsumerWidget {
  const CategoriasAdminScreen({super.key});

  Future<void> _ejecutar(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() accion,
    String ok,
  ) async {
    try {
      await accion();
      refrescarCatalogo(ref);
      if (context.mounted) mostrarMensaje(context, ok, esError: false);
    } catch (e) {
      if (context.mounted) mostrarMensaje(context, MensajesError.desde(e));
    }
  }

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref, [
    CategoriaAdmin? categoria,
  ]) async {
    final datos = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => _DialogoCategoria(categoria: categoria),
    );
    if (datos == null || !context.mounted) return;

    final repo = ref.read(categoriasAdminRepositoryProvider);
    await _ejecutar(
      context,
      ref,
      () => categoria == null
          ? repo.crear(nombre: datos.$1, icono: datos.$2)
          : repo.editar(categoria.id, nombre: datos.$1, icono: datos.$2),
      categoria == null
          ? 'Categoría ${datos.$1} creada: ya está disponible para registros y pedidos.'
          : 'Categoría actualizada.',
    );
  }

  Future<void> _eliminar(
    BuildContext context,
    WidgetRef ref,
    CategoriaAdmin c,
  ) async {
    // Flujo alterno 1.2: con datos asociados se sugiere ocultarla.
    if (c.enUso) {
      final ocultar = await confirmarAccion(
        context,
        titulo: 'No se puede eliminar ${c.nombre}',
        mensaje: 'Tiene ${c.profesionales} profesionales y ${c.pedidos} pedidos '
            'asociados. Para mantener la integridad de esos datos, ocultala: '
            'deja de ofrecerse sin borrar nada.',
        confirmar: 'Ocultarla',
      );
      if (ocultar && context.mounted) {
        await _ejecutar(
          context,
          ref,
          () => ref
              .read(categoriasAdminRepositoryProvider)
              .cambiarVisibilidad(c.id, activa: false),
          '${c.nombre} quedó oculta.',
        );
      }
      return;
    }

    final ok = await confirmarAccion(
      context,
      titulo: 'Eliminar ${c.nombre}',
      mensaje: 'No tiene profesionales ni pedidos asociados. Se elimina del '
          'catálogo de forma definitiva.',
      confirmar: 'Eliminar',
      destructiva: true,
    );
    if (ok && context.mounted) {
      await _ejecutar(
        context,
        ref,
        () => ref.read(categoriasAdminRepositoryProvider).eliminar(c.id),
        '${c.nombre} se eliminó.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriasAdminProvider);

    return PanelAdmin(
      actual: SeccionAdmin.categorias,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const EncabezadoAdmin(
                titulo: 'Gestión de categorías',
                bajada: 'Administrá los oficios disponibles en la plataforma',
              ),
              FilledButton.icon(
                key: const Key('nueva-categoria'),
                style: FilledButton.styleFrom(backgroundColor: Colores.azul),
                onPressed: () => _editar(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Nueva categoría'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          categorias.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AvisoEstado.riesgo(
              icono: Icons.error_outline,
              titulo: 'No pudimos cargar las categorías',
              detalle: MensajesError.desde(e),
            ),
            data: (lista) => LayoutBuilder(
              builder: (context, r) {
                final columnas = (r.maxWidth / 260).floor().clamp(1, 4);
                final ancho = (r.maxWidth - (columnas - 1) * 16) / columnas;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final c in lista)
                      SizedBox(
                        width: ancho,
                        child: _Tarjeta(
                          categoria: c,
                          onEditar: () => _editar(context, ref, c),
                          onEliminar: () => _eliminar(context, ref, c),
                          onVisibilidad: (activa) => _ejecutar(
                            context,
                            ref,
                            () => ref
                                .read(categoriasAdminRepositoryProvider)
                                .cambiarVisibilidad(c.id, activa: activa),
                            activa
                                ? '${c.nombre} vuelve a estar disponible.'
                                : '${c.nombre} quedó oculta.',
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.categoria,
    required this.onEditar,
    required this.onEliminar,
    required this.onVisibilidad,
  });

  final CategoriaAdmin categoria;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final ValueChanged<bool> onVisibilidad;

  @override
  Widget build(BuildContext context) {
    final c = categoria;
    return TarjetaPanel(
      key: Key('categoria-${c.slug}'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(c.icono ?? '🧰', style: const TextStyle(fontSize: 30)),
              const Spacer(),
              c.activa
                  ? const Pildora(
                      texto: 'Activa',
                      color: Colores.exito,
                      fondo: Colores.exitoSuave)
                  : const Pildora(
                      texto: 'Oculta',
                      color: Colores.textoSecundario,
                      fondo: Colores.neutroSuave),
              PopupMenuButton<String>(
                tooltip: 'Opciones',
                onSelected: (o) => o == 'editar' ? onEditar() : onEliminar(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                  PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.nombre,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: Colores.texto)),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${c.profesionales} profesionales',
                  style: const TextStyle(color: Colores.textoSecundario),
                ),
              ),
              Switch(
                value: c.activa,
                activeThumbColor: Colores.exito,
                onChanged: onVisibilidad,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paso 3: «ingresa el nombre descriptivo y selecciona un ícono».
class _DialogoCategoria extends StatefulWidget {
  const _DialogoCategoria({this.categoria});

  final CategoriaAdmin? categoria;

  @override
  State<_DialogoCategoria> createState() => _DialogoCategoriaState();
}

class _DialogoCategoriaState extends State<_DialogoCategoria> {
  final _formulario = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.categoria?.nombre);
  late String? _icono = widget.categoria?.icono;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.categoria == null ? 'Nueva categoría' : 'Editar categoría'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoTexto(
                key: const Key('nombre-categoria'),
                etiqueta: 'Nombre del oficio',
                ejemplo: 'Gasista matriculado',
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  final t = (v ?? '').trim();
                  return t.length < 2 || t.length > 40
                      ? 'Entre 2 y 40 caracteres.'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Ícono',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final i in CategoriaAdmin.iconosSugeridos)
                    ChoiceChip(
                      label: Text(i, style: const TextStyle(fontSize: 20)),
                      selected: _icono == i,
                      onSelected: (_) => setState(() => _icono = i),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('guardar-categoria'),
          onPressed: () {
            if (_formulario.currentState?.validate() ?? false) {
              Navigator.of(context).pop((_nombre.text.trim(), _icono));
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
