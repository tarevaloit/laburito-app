import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/widgets/boton_principal.dart';
import '../../../../core/widgets/campo_texto.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../categorias/data/categorias_repository.dart';
import '../../../perfil/data/perfil_repository.dart';
import '../../domain/pedido_estado.dart';
import '../controllers/crear_pedido_controller.dart';
import '../widgets/selector_ubicacion.dart';

/// CU-13 — Publicar Pedido. Asistente de 4 pasos, exclusivo para cuentas
/// Buscador: qué necesitás, dónde, fotos (opcional) y vigencia/presupuesto.
class CrearPedidoScreen extends ConsumerStatefulWidget {
  const CrearPedidoScreen({super.key});

  @override
  ConsumerState<CrearPedidoScreen> createState() => _CrearPedidoScreenState();
}

class _CrearPedidoScreenState extends ConsumerState<CrearPedidoScreen> {
  final _formPaso1 = GlobalKey<FormState>();
  final _formPaso4 = GlobalKey<FormState>();

  /// Se levanta cuando el usuario ya confirmó que quiere descartar.
  ///
  /// Con `canPop: false`, volver a llamar `Navigator.pop()` dentro del propio
  /// `onPopInvokedWithResult` no saca de la pantalla: el pop programático
  /// también queda interceptado y el diálogo se mostraría de nuevo en loop.
  /// Esta bandera es lo que hace que la segunda vuelta de `canPop` dé `true`.
  bool _salidaForzada = false;

  Future<bool> _confirmarDescarte(BuildContext context) async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Descartar el pedido?'),
        content: const Text(
          'Lo que cargaste hasta acá no se guarda. Vas a tener que empezar de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Seguir cargando'),
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

  void _siguiente(CrearPedidoController controller, EstadoCrearPedido estado) {
    switch (estado.paso) {
      case PasoCrearPedido.queNecesitas:
        if (!_formPaso1.currentState!.validate()) return;
        if (estado.categoriaId == null) {
          mostrarMensaje(context, 'Elegí una categoría.');
          return;
        }
        controller.avanzar();
      case PasoCrearPedido.donde:
        if (estado.ubicacion == null) {
          mostrarMensaje(context, 'Marcá la ubicación del pedido.');
          return;
        }
        controller.avanzar();
      case PasoCrearPedido.fotos:
        controller.avanzar();
      case PasoCrearPedido.vigencia:
        if (!_formPaso4.currentState!.validate()) return;
        controller.confirmar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilCompletoProvider);
    final estado = ref.watch(crearPedidoControllerProvider);
    final controller = ref.read(crearPedidoControllerProvider.notifier);

    ref.listen(crearPedidoControllerProvider, (anterior, siguiente) {
      if (siguiente.pedidoCreado != null && anterior?.pedidoCreado == null) {
        final mensaje = siguiente.erroresFotos.isEmpty
            ? 'Pedido publicado.'
            : 'Pedido publicado. ${siguiente.erroresFotos.length} '
                'foto(s) no se pudieron subir; podés reintentar desde el detalle.';
        mostrarMensaje(context, mensaje, esError: false);
        context.go('/home');
      } else if (siguiente.error != null && siguiente.error != anterior?.error) {
        mostrarMensaje(context, MensajesError.desde(siguiente.error!));
      }
    });

    return perfilAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Publicar pedido')),
        body: const Center(child: Text('No pudimos cargar tu perfil.')),
      ),
      data: (perfil) {
        if (perfil == null || perfil.esProfesional) {
          return Scaffold(
            appBar: AppBar(title: const Text('Publicar pedido')),
            body: const Padding(
              padding: EdgeInsets.all(24),
              child: AvisoEstado.riesgo(
                icono: Icons.info_outline,
                titulo: 'Esta sección es para cuentas Buscador',
                detalle: 'Con una cuenta Profesional no se publican pedidos: '
                    'se responde a los que otros publican.',
              ),
            ),
          );
        }

        final puedeSalirLibre = _salidaForzada ||
            !controller.hayCambiosSinGuardar ||
            estado.pedidoCreado != null;

        return PopScope(
          canPop: puedeSalirLibre,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final salir = await _confirmarDescarte(context);
            if (salir && context.mounted) {
              setState(() => _salidaForzada = true);
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Publicar pedido'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  if (puedeSalirLibre) {
                    context.go('/home');
                    return;
                  }
                  if (await _confirmarDescarte(context) && context.mounted) {
                    context.go('/home');
                  }
                },
              ),
            ),
            body: Column(
              children: [
                _BarraDeProgreso(paso: estado.paso),
                Expanded(
                  child: TarjetaFormulario(
                    child: switch (estado.paso) {
                      PasoCrearPedido.queNecesitas => _PasoQueNecesitas(
                          formKey: _formPaso1,
                          estado: estado,
                          controller: controller,
                        ),
                      PasoCrearPedido.donde =>
                        _PasoDonde(estado: estado, controller: controller),
                      PasoCrearPedido.fotos =>
                        _PasoFotos(estado: estado, controller: controller),
                      PasoCrearPedido.vigencia => _PasoVigencia(
                          formKey: _formPaso4,
                          estado: estado,
                          controller: controller,
                        ),
                    },
                  ),
                ),
                _BarraDeAcciones(
                  estado: estado,
                  onAtras: estado.paso.esPrimero ? null : controller.retroceder,
                  onSiguiente: () => _siguiente(controller, estado),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------------------
// Progreso y acciones
// ----------------------------------------------------------------------------

class _BarraDeProgreso extends StatelessWidget {
  const _BarraDeProgreso({required this.paso});

  final PasoCrearPedido paso;

  static const _titulos = {
    PasoCrearPedido.queNecesitas: 'Qué necesitás',
    PasoCrearPedido.donde: 'Dónde',
    PasoCrearPedido.fotos: 'Fotos',
    PasoCrearPedido.vigencia: 'Vigencia y presupuesto',
  };

  @override
  Widget build(BuildContext context) {
    final indice = paso.index;
    final total = PasoCrearPedido.values.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= indice ? Colores.naranja : Colores.borde,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Paso ${indice + 1} de $total · ${_titulos[paso]}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colores.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraDeAcciones extends StatelessWidget {
  const _BarraDeAcciones({
    required this.estado,
    required this.onAtras,
    required this.onSiguiente,
  });

  final EstadoCrearPedido estado;
  final VoidCallback? onAtras;
  final VoidCallback onSiguiente;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: const BoxDecoration(
        color: Colores.superficie,
        border: Border(top: BorderSide(color: Colores.borde)),
      ),
      child: Row(
        children: [
          if (onAtras != null) ...[
            OutlinedButton(
              onPressed: estado.enviando ? null : onAtras,
              child: const Text('Atrás'),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: BotonPrincipal(
              texto:
                  estado.paso.esUltimo ? 'Publicar pedido' : 'Siguiente',
              cargando: estado.enviando,
              onPressed: onSiguiente,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Paso 1 — Qué necesitás
// ----------------------------------------------------------------------------

class _PasoQueNecesitas extends ConsumerWidget {
  const _PasoQueNecesitas({
    required this.formKey,
    required this.estado,
    required this.controller,
  });

  final GlobalKey<FormState> formKey;
  final EstadoCrearPedido estado;
  final CrearPedidoController controller;

  String? _validarTitulo(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Ingresá un título';
    if (v.length < 5) return 'El título es demasiado corto (mínimo 5)';
    if (v.length > 80) return 'El título es demasiado largo (máximo 80)';
    return null;
  }

  String? _validarDescripcion(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Contá qué necesitás';
    if (v.length < 20) return 'Contá un poco más (mínimo 20 caracteres)';
    if (v.length > 1000) return 'Demasiado largo (máximo 1000 caracteres)';
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasActivasProvider);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '¿Qué necesitás?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colores.azul,
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(bottom: 6, left: 2),
            child: Text(
              'Categoría',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colores.texto,
              ),
            ),
          ),
          categoriasAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) =>
                const Text('No pudimos cargar las categorías.'),
            data: (categorias) => DropdownButtonFormField<String>(
              initialValue: estado.categoriaId,
              hint: const Text('Elegí un oficio'),
              items: [
                for (final c in categorias)
                  DropdownMenuItem(value: c.id, child: Text(c.nombre)),
              ],
              onChanged: controller.setCategoria,
            ),
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Título',
            initialValue: estado.titulo,
            ejemplo: 'Ej: Se me tapó la cocina',
            maxLength: 80,
            validator: _validarTitulo,
            onChanged: controller.setTitulo,
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Descripción',
            initialValue: estado.descripcion,
            ejemplo: 'Contá el problema con el mayor detalle posible',
            maxLines: 4,
            maxLength: 1000,
            validator: _validarDescripcion,
            onChanged: controller.setDescripcion,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(bottom: 6, left: 2),
            child: Text(
              'Urgencia',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colores.texto,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final u in PedidoUrgencia.values)
                ChoiceChip(
                  label: Text(u.etiqueta),
                  selected: estado.urgencia == u,
                  onSelected: (_) => controller.setUrgencia(u),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Paso 2 — Dónde
// ----------------------------------------------------------------------------

class _PasoDonde extends StatelessWidget {
  const _PasoDonde({required this.estado, required this.controller});

  final EstadoCrearPedido estado;
  final CrearPedidoController controller;

  @override
  Widget build(BuildContext context) {
    final ubicacion = estado.ubicacion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '¿Dónde es el trabajo?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colores.azul,
          ),
        ),
        const SizedBox(height: 20),
        if (ubicacion != null)
          TarjetaPanel(
            child: Row(
              children: [
                const Icon(Icons.place, color: Colores.naranja),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ubicacion.direccionTexto,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (ubicacion.referencia != null)
                        Text(
                          ubicacion.referencia!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colores.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.map_outlined),
          label: Text(ubicacion == null
              ? 'Marcar ubicación en el mapa'
              : 'Cambiar ubicación'),
          onPressed: () async {
            final elegida = await abrirSelectorUbicacion(
              context,
              inicial: ubicacion,
            );
            if (elegida != null) controller.setUbicacion(elegida);
          },
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// Paso 3 — Fotos (opcional)
// ----------------------------------------------------------------------------

class _PasoFotos extends StatelessWidget {
  const _PasoFotos({required this.estado, required this.controller});

  final EstadoCrearPedido estado;
  final CrearPedidoController controller;

  Future<void> _agregar(BuildContext context) async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (origen == null) return;

    final archivo = await ImagePicker().pickImage(
      source: origen,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (archivo == null) return;

    final bytes = await archivo.readAsBytes();
    final agregada = controller.agregarFoto(bytes, archivo.name);
    if (!agregada && context.mounted) {
      mostrarMensaje(context, 'Ya tenés el máximo de 5 fotos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Fotos (opcional)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colores.azul,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ayudan a que el profesional entienda el trabajo antes de responder.',
          style: TextStyle(color: Colores.textoSecundario, fontSize: 13),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            for (var i = 0; i < estado.fotos.length; i++)
              _Miniatura(
                foto: estado.fotos[i],
                onQuitar: () => controller.quitarFoto(i),
              ),
            if (estado.puedeAgregarFoto)
              _BotonAgregarFoto(onTap: () => _agregar(context)),
          ],
        ),
      ],
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.foto, required this.onQuitar});

  final FotoPendiente foto;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Medidas.radio),
          child: Image.memory(
            foto.bytes,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onQuitar,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colores.error,
              child: Icon(Icons.close, size: 14, color: Colores.textoSobreColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _BotonAgregarFoto extends StatelessWidget {
  const _BotonAgregarFoto({required this.onTap});

  final VoidCallback onTap;

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

// ----------------------------------------------------------------------------
// Paso 4 — Vigencia, presupuesto y resumen
// ----------------------------------------------------------------------------

class _PasoVigencia extends StatelessWidget {
  const _PasoVigencia({
    required this.formKey,
    required this.estado,
    required this.controller,
  });

  final GlobalKey<FormState> formKey;
  final EstadoCrearPedido estado;
  final CrearPedidoController controller;

  static const _opcionesDias = [7, 15, 30];

  String? _validarPresupuesto(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return null;
    final numero = double.tryParse(v.replaceAll(',', '.'));
    if (numero == null) return 'Ingresá un número válido';
    if (numero < 0) return 'No puede ser negativo';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Vigencia y presupuesto',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colores.azul,
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(bottom: 6, left: 2),
            child: Text(
              '¿Cuántos días querés que quede publicado?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colores.texto,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final dias in _opcionesDias)
                ChoiceChip(
                  label: Text('$dias días'),
                  selected: estado.diasVigencia == dias,
                  onSelected: (_) => controller.setDiasVigencia(dias),
                ),
            ],
          ),
          const SizedBox(height: 16),
          CampoTexto(
            etiqueta: 'Presupuesto estimado (opcional)',
            initialValue: estado.presupuestoEstimado?.toString(),
            ejemplo: 'En pesos',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            validator: _validarPresupuesto,
            onChanged: (texto) => controller.setPresupuesto(
              double.tryParse(texto.trim().replaceAll(',', '.')),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Resumen',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colores.azul),
          ),
          const SizedBox(height: 8),
          TarjetaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilaResumen('Título', estado.titulo),
                _FilaResumen('Urgencia', estado.urgencia.etiqueta),
                _FilaResumen(
                  'Ubicación',
                  estado.ubicacion?.direccionTexto ?? '—',
                ),
                _FilaResumen('Fotos', '${estado.fotos.length} de 5'),
                _FilaResumen('Vigencia', '${estado.diasVigencia} días'),
                _FilaResumen(
                  'Presupuesto',
                  estado.presupuestoEstimado == null
                      ? 'Sin definir'
                      : r'$' '${estado.presupuestoEstimado}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  const _FilaResumen(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style:
                  const TextStyle(fontSize: 13, color: Colores.textoSecundario),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
