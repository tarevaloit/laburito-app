import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../data/usuarios_repository.dart';
import '../widgets/dialogo_suspension.dart';
import '../widgets/dialogos_admin.dart';
import 'panel_admin.dart';

/// CU-36 — Suspender Cuenta: el buscador general del panel (paso 1), el
/// detalle del usuario (paso 2) y la sanción (pasos 3 a 6).
class UsuariosScreen extends ConsumerStatefulWidget {
  const UsuariosScreen({super.key, this.inicial});

  /// Para abrir el detalle de un usuario desde otra sección.
  final String? inicial;

  @override
  ConsumerState<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends ConsumerState<UsuariosScreen> {
  final _busqueda = TextEditingController();
  Timer? _espera;
  String _texto = '';
  String? _tipo;
  late String? _elegido = widget.inicial;

  @override
  void dispose() {
    _espera?.cancel();
    _busqueda.dispose();
    super.dispose();
  }

  void _buscar(String texto) {
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 350),
        () => setState(() => _texto = texto.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final resultados = ref.watch(usuariosAdminProvider(_texto, _tipo));

    final listado = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('buscar-usuario'),
          controller: _busqueda,
          onChanged: _buscar,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Nombre, apellido o correo',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            for (final (valor, etiqueta) in const [
              (null, 'Todos'),
              ('buscador', 'Buscadores'),
              ('profesional', 'Profesionales'),
            ])
              ChoiceChip(
                label: Text(etiqueta),
                selected: _tipo == valor,
                onSelected: (_) => setState(() => _tipo = valor),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...resultados.when(
          loading: () => const [Center(child: CircularProgressIndicator())],
          error: (e, _) => [Text(MensajesError.desde(e))],
          data: (lista) => lista.isEmpty
              ? const [Text('No encontramos usuarios con esa búsqueda.')]
              : [
                  for (final u in lista)
                    TarjetaSeleccionable(
                      key: Key('usuario-${u.id}'),
                      seleccionada: u.id == _elegido,
                      titulo: u.nombreCompleto,
                      bajada: '${_rol(u.tipo)} · ${u.email}',
                      insignia: u.suspendido
                          ? const Icon(Icons.block, color: Colores.error)
                          : null,
                      onTap: () => setState(() => _elegido = u.id),
                    ),
                ],
        ),
      ],
    );

    final detalle = _elegido == null
        ? const AvisoEstado.pendiente(
            icono: Icons.person_search_outlined,
            titulo: 'Elegí un usuario',
            detalle: 'Vas a ver sus pedidos, denuncias, calificaciones y '
                'sanciones antes de decidir.',
          )
        : _Detalle(id: _elegido!, onCambio: () {
            ref.invalidate(usuariosAdminProvider);
            ref.invalidate(detalleUsuarioAdminProvider(_elegido!));
          });

    return PanelAdmin(
      actual: SeccionAdmin.usuarios,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const EncabezadoAdmin(
            titulo: 'Usuarios',
            bajada: 'Buscá una cuenta para ver su historial o sancionarla',
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, r) => r.maxWidth >= 860
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 340, child: listado),
                      const SizedBox(width: 20),
                      Expanded(child: detalle),
                    ],
                  )
                : Column(
                    children: [listado, const SizedBox(height: 20), detalle],
                  ),
          ),
        ],
      ),
    );
  }
}

String _rol(String tipo) => switch (tipo) {
      'profesional' => 'Profesional',
      'buscador' => 'Buscador',
      'administrador' => 'Administrador',
      _ => tipo,
    };

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.id, required this.onCambio});

  final String id;
  final VoidCallback onCambio;

  Future<void> _suspender(BuildContext context, WidgetRef ref, DetalleUsuario d) async {
    final pedida = await pedirSuspension(context, d.usuario.nombreCompleto);
    if (pedida == null || !context.mounted) return;
    try {
      await ref.read(usuariosRepositoryProvider).suspender(d.usuario.id, pedida);
      onCambio();
      if (context.mounted) {
        mostrarMensaje(
          context,
          '${d.usuario.nombreCompleto} quedó suspendido. Sus sesiones se '
          'cerraron y sus pedidos publicados se pausaron.',
          esError: false,
        );
      }
    } catch (e) {
      if (context.mounted) mostrarMensaje(context, MensajesError.desde(e));
    }
  }

  Future<void> _levantar(BuildContext context, WidgetRef ref, Sancion s) async {
    final motivo = await pedirTexto(
      context,
      titulo: 'Levantar la sanción',
      etiqueta: 'Por qué se levanta',
      ejemplo: 'Se comprobó que la denuncia era falsa.',
      confirmar: 'Reactivar cuenta',
    );
    if (motivo == null || !context.mounted) return;
    try {
      await ref.read(usuariosRepositoryProvider).levantar(s.id, motivo);
      onCambio();
      if (context.mounted) {
        mostrarMensaje(context, 'La cuenta está activa otra vez.', esError: false);
      }
    } catch (e) {
      if (context.mounted) mostrarMensaje(context, MensajesError.desde(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(detalleUsuarioAdminProvider(id)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AvisoEstado.riesgo(
            icono: Icons.error_outline,
            titulo: 'No pudimos cargar el usuario',
            detalle: MensajesError.desde(e),
          ),
          data: (d) {
            final u = d.usuario;
            final vigente = d.sancionVigente;
            return TarjetaPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(u.nombreCompleto,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colores.texto)),
                      ),
                      u.suspendido
                          ? const Pildora(
                              texto: 'Suspendida',
                              color: Colores.error,
                              fondo: Colores.errorSuave)
                          : const Pildora(
                              texto: 'Activa',
                              color: Colores.exito,
                              fondo: Colores.exitoSuave),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 28,
                    runSpacing: 10,
                    children: [
                      DatoAdmin(etiqueta: 'Rol', valor: _rol(u.tipo)),
                      DatoAdmin(etiqueta: 'Correo', valor: u.email),
                      DatoAdmin(etiqueta: 'Teléfono', valor: d.telefono ?? '—'),
                      if (u.tipo == 'buscador')
                        DatoAdmin(etiqueta: 'Pedidos', valor: '${d.totalPedidos}'),
                      if (u.tipo == 'profesional') ...[
                        DatoAdmin(
                          etiqueta: 'Reputación',
                          valor: d.promedio == null
                              ? 'Sin calificaciones'
                              : '★ ${d.promedio!.toStringAsFixed(1)} · '
                                  '${d.totalCalificaciones} reseñas',
                        ),
                        DatoAdmin(etiqueta: 'Contactos', valor: '${d.contactos}'),
                      ],
                      DatoAdmin(
                        etiqueta: 'Denuncias',
                        valor: '${d.denunciasRecibidas.length} recibidas · '
                            '${d.denunciasHechas} hechas',
                      ),
                    ],
                  ),
                  if (vigente != null) ...[
                    const SizedBox(height: 16),
                    AvisoEstado.riesgo(
                      icono: Icons.gavel,
                      titulo: vigente.permanente
                          ? 'Suspensión permanente'
                          : 'Suspendida hasta el '
                              '${Fechas.corta(vigente.hasta!.toLocal())}',
                      detalle: vigente.motivo,
                    ),
                  ],
                  _Seccion(
                    titulo: 'Últimos pedidos',
                    vacio: 'Sin pedidos publicados.',
                    renglones: [
                      for (final p in d.pedidos)
                        '${p['titulo']} · ${p['estado']}',
                    ],
                  ),
                  _Seccion(
                    titulo: 'Denuncias recibidas',
                    vacio: 'Sin denuncias.',
                    renglones: [
                      for (final x in d.denunciasRecibidas)
                        '${x['motivo'].toString().replaceAll('_', ' ')} · '
                            '${x['estado']} · «${x['descripcion']}»',
                    ],
                  ),
                  _Seccion(
                    titulo: 'Calificaciones',
                    vacio: 'Sin calificaciones.',
                    renglones: [
                      for (final c in d.calificaciones)
                        '★ ${c['puntaje']} · ${c['autor']}'
                            '${c['comentario'] == null ? '' : ' · «${c['comentario']}»'}',
                    ],
                  ),
                  _Seccion(
                    titulo: 'Sanciones',
                    vacio: 'Sin sanciones previas.',
                    renglones: [
                      for (final s in d.sanciones)
                        '${Fechas.corta(s.fecha.toLocal())} · '
                            '${s.permanente ? 'permanente' : 'temporal'} · '
                            '${s.vigente ? 'vigente' : 'levantada'} · ${s.motivo}',
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (u.tipo != 'administrador')
                    vigente == null
                        ? FilledButton.icon(
                            key: const Key('suspender-usuario'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colores.error),
                            onPressed: () => _suspender(context, ref, d),
                            icon: const Icon(Icons.block),
                            label: const Text('Suspender usuario'),
                          )
                        : OutlinedButton.icon(
                            key: const Key('levantar-sancion'),
                            onPressed: () => _levantar(context, ref, vigente),
                            icon: const Icon(Icons.lock_open),
                            label: const Text('Levantar sanción'),
                          )
                  else
                    // Flujo alterno 1.1: un par no se sanciona.
                    const Text(
                      'Las cuentas de administrador no se pueden sancionar desde '
                      'el panel: requiere permisos de SuperAdmin.',
                      style: TextStyle(color: Colores.textoSecundario),
                    ),
                ],
              ),
            );
          },
        );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.vacio,
    required this.renglones,
  });

  final String titulo;
  final String vacio;
  final List<String> renglones;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colores.textoSecundario)),
          const SizedBox(height: 4),
          if (renglones.isEmpty)
            Text(vacio, style: const TextStyle(color: Colores.textoTenue))
          else
            for (final r in renglones)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(r, style: const TextStyle(color: Colores.texto)),
              ),
        ],
      ),
    );
  }
}
