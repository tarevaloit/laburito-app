import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/urls_firmadas.dart';
import '../../domain/pedido_foto.dart';
import '../controllers/editar_pedido_controller.dart';
import '../widgets/campos_pedido.dart';
import '../widgets/fotos_pedido.dart';

/// CU-15 — Editar Pedido.
///
/// Los mismos campos del asistente del CU-13 (`CamposDatosPedido`,
/// `CampoUbicacion`, `CampoPresupuesto`), en una sola pantalla en vez de en
/// cuatro pasos: acá no se está armando algo de cero, se está corrigiendo algo
/// que ya existe y hay que poder ver entero.
///
/// Dos cosas que **no** se editan:
///
///   * **La vigencia.** Estirar `fecha_vencimiento` con un PATCH sería una
///     renovación sin límite; para eso está el CU-51, que cuenta las tres.
///   * **El estado.** Lo mueven los botones del detalle, y desde la migración
///     0008 el trigger `pedidos_guard_estado` rechaza cualquier otro camino.
class EditarPedidoScreen extends ConsumerStatefulWidget {
  const EditarPedidoScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditarPedidoScreen> createState() => _EditarPedidoScreenState();
}

class _EditarPedidoScreenState extends ConsumerState<EditarPedidoScreen> {
  final _form = GlobalKey<FormState>();

  /// Igual que en el asistente: con `canPop: false`, el `pop` programático de
  /// adentro del propio `onPopInvokedWithResult` también queda interceptado, y
  /// el diálogo se mostraría en loop. Esta bandera corta la segunda vuelta.
  bool _salidaForzada = false;

  void _volver() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/pedidos/${widget.id}');
    }
  }

  /// Sale sin volver a preguntar: la bandera es lo que hace que la segunda
  /// vuelta del `PopScope` deje pasar el pop.
  void _forzarSalida() {
    setState(() => _salidaForzada = true);
    Navigator.of(context).pop();
  }

  Future<bool> _confirmarDescarte() async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Descartar los cambios?'),
        content: const Text(
          'Lo que editaste no se guarda. El pedido queda como estaba.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return descartar ?? false;
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;

    final guardado =
        await ref.read(editarPedidoProvider(widget.id).notifier).guardar();

    if (!guardado || !mounted) return;

    mostrarMensaje(context, 'Guardamos los cambios.', esError: false);
    setState(() => _salidaForzada = true);
    _volver();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(editarPedidoProvider(widget.id));

    ref.listen(editarPedidoProvider(widget.id), (anterior, siguiente) {
      final error = siguiente.valueOrNull?.error;
      if (error != null && error != anterior?.valueOrNull?.error) {
        mostrarMensaje(context, error.message);
      }
    });

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Editar pedido')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              MensajesError.desde(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colores.textoSecundario),
            ),
          ),
        ),
      ),
      data: (estado) {
        // La regla es de la base: `actualizar_ubicacion_pedido` solo acepta
        // pedidos publicados o pausados. Se comprueba acá para no dibujar un
        // formulario cuyo botón de guardar va a fallar siempre.
        if (!estado.original.estado.esEditable) {
          return Scaffold(
            appBar: AppBar(title: const Text('Editar pedido')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AvisoEstado.riesgo(
                    icono: Icons.lock_outline,
                    titulo: 'Este pedido ya no se puede editar',
                    detalle: 'Está ${estado.original.estado.etiqueta.toLowerCase()}. '
                        'Solo se editan los pedidos publicados o pausados.',
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: _volver,
                    child: const Text('Volver al pedido'),
                  ),
                ],
              ),
            ),
          );
        }

        final puedeSalirLibre = _salidaForzada || !estado.hayCambios;

        return PopScope(
          canPop: puedeSalirLibre,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (await _confirmarDescarte() && mounted) _forzarSalida();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Editar pedido'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  if (puedeSalirLibre) {
                    _volver();
                    return;
                  }
                  if (await _confirmarDescarte() && mounted) {
                    setState(() => _salidaForzada = true);
                    _volver();
                  }
                },
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: TarjetaFormulario(
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CamposDatosPedido(
                            categoriaId: estado.categoriaId,
                            titulo: estado.titulo,
                            descripcion: estado.descripcion,
                            urgencia: estado.urgencia,
                            onCategoria: _controlador.setCategoria,
                            onTitulo: _controlador.setTitulo,
                            onDescripcion: _controlador.setDescripcion,
                            onUrgencia: _controlador.setUrgencia,
                          ),
                          const SizedBox(height: 24),
                          const EtiquetaCampo('Dónde es el trabajo'),
                          CampoUbicacion(
                            ubicacion: estado.ubicacion,
                            onCambio: _controlador.setUbicacion,
                          ),
                          const SizedBox(height: 24),
                          CampoPresupuesto(
                            valor: estado.presupuestoEstimado,
                            onCambio: _controlador.setPresupuesto,
                          ),
                          const SizedBox(height: 24),
                          _SeccionFotos(pedidoId: widget.id, estado: estado),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                _BarraGuardar(
                  habilitado: estado.hayCambios && !estado.ocupado,
                  guardando: estado.guardando,
                  onGuardar: _guardar,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  EditarPedido get _controlador =>
      ref.read(editarPedidoProvider(widget.id).notifier);
}

class _BarraGuardar extends StatelessWidget {
  const _BarraGuardar({
    required this.habilitado,
    required this.guardando,
    required this.onGuardar,
  });

  final bool habilitado;
  final bool guardando;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: const BoxDecoration(
        color: Colores.superficie,
        border: Border(top: BorderSide(color: Colores.borde)),
      ),
      child: SafeArea(
        top: false,
        child: BotonPrincipal(
          texto: 'Guardar cambios',
          cargando: guardando,
          onPressed: habilitado ? onGuardar : null,
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Fotos ya guardadas
// ----------------------------------------------------------------------------

/// Las fotos del pedido, que se editan al instante.
///
/// A diferencia del resto del formulario, acá no hay «guardar»: el pedido ya
/// existe, así que subir y borrar son operaciones sobre Storage que se aplican
/// en el momento. La pantalla lo dice, para que nadie espere que descartar los
/// cambios devuelva una foto borrada.
class _SeccionFotos extends ConsumerStatefulWidget {
  const _SeccionFotos({required this.pedidoId, required this.estado});

  final String pedidoId;
  final EstadoEditarPedido estado;

  @override
  ConsumerState<_SeccionFotos> createState() => _SeccionFotosState();
}

class _SeccionFotosState extends ConsumerState<_SeccionFotos> {
  Map<String, String> _urls = const {};

  @override
  void initState() {
    super.initState();
    _firmar();
  }

  @override
  void didUpdateWidget(_SeccionFotos anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.estado.fotos.length != widget.estado.fotos.length) _firmar();
  }

  Future<void> _firmar() async {
    final fotos = widget.estado.fotos;
    if (fotos.isEmpty) {
      if (mounted) setState(() => _urls = const {});
      return;
    }

    final urls = await ref
        .read(urlsFirmadasProvider)
        .resolver([for (final f in fotos) f.storagePath]);

    if (mounted) setState(() => _urls = urls);
  }

  Future<void> _agregar() async {
    final foto = await elegirFotoDePedido(context);
    if (foto == null) return;

    final agregada = await ref
        .read(editarPedidoProvider(widget.pedidoId).notifier)
        .agregarFoto(foto.bytes, foto.nombre);

    if (agregada) _firmar();
  }

  Future<void> _quitar(PedidoFoto foto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar la foto?'),
        content: const Text('Se borra ahora y no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colores.error,
              foregroundColor: Colores.textoSobreColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    await ref
        .read(editarPedidoProvider(widget.pedidoId).notifier)
        .eliminarFoto(foto);
  }

  @override
  Widget build(BuildContext context) {
    final estado = widget.estado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EtiquetaCampo('Fotos'),
        const Text(
          'Los cambios en las fotos se aplican al instante, no esperan al '
          'botón de guardar.',
          style: TextStyle(fontSize: 12, color: Colores.textoSecundario),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            for (final foto in estado.fotos)
              _MiniaturaGuardada(
                url: _urls[foto.storagePath],
                categoriaNombre: estado.original.categoriaNombre,
                onQuitar: estado.ocupado ? null : () => _quitar(foto),
              ),
            if (estado.puedeAgregarFoto)
              _BotonAgregar(onTap: estado.ocupado ? null : _agregar),
          ],
        ),
        if (estado.trabajandoConFotos) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}

class _MiniaturaGuardada extends StatelessWidget {
  const _MiniaturaGuardada({
    required this.url,
    required this.categoriaNombre,
    required this.onQuitar,
  });

  final String? url;
  final String? categoriaNombre;
  final VoidCallback? onQuitar;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(Medidas.radio);

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: radio,
            child: url == null
                ? PlaceholderCategoria(categoriaNombre: categoriaNombre)
                : Image.network(
                    url!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) =>
                        PlaceholderCategoria(categoriaNombre: categoriaNombre),
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onQuitar,
            child: CircleAvatar(
              radius: 12,
              backgroundColor:
                  onQuitar == null ? Colores.errorApagado : Colores.error,
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colores.textoSobreColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  const _BotonAgregar({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Medidas.radio),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.azulSuave,
          borderRadius: BorderRadius.circular(Medidas.radio),
          border: Border.all(color: Colores.borde),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: Colores.azul),
      ),
    );
  }
}
