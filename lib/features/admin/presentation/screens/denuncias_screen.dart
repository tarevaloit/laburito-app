import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colores.dart';
import '../../../../core/errors/mensajes_error.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/widgets/marca_laburito.dart';
import '../../../denuncias/data/denuncias_repository.dart';
import '../../../denuncias/domain/denuncia.dart';
import '../../data/usuarios_repository.dart';
import '../widgets/dialogo_suspension.dart';
import '../widgets/dialogos_admin.dart';
import 'panel_admin.dart';

/// CU-39 — Gestionar Denuncias (Figura 3.22). La bandeja que abrió el CU-41
/// en el Sprint 5, ahora con su resolución: la lista ordenada por gravedad a
/// la izquierda y el detalle con las tres acciones a la derecha.
class DenunciasScreen extends ConsumerStatefulWidget {
  const DenunciasScreen({super.key, this.pestanaInicial = 0});

  /// 0 = denuncias, 1 = apelaciones (CU-49).
  final int pestanaInicial;

  @override
  ConsumerState<DenunciasScreen> createState() => _DenunciasScreenState();
}

class _DenunciasScreenState extends ConsumerState<DenunciasScreen> {
  String? _elegida;
  bool _resolviendo = false;
  late int _pestana = widget.pestanaInicial;

  Future<void> _resolver(DenunciaAdmin d, {required String accion}) async {
    ResolucionDenuncia? r;
    switch (accion) {
      case 'suspender':
        // Punto de extensión: CU-36. El motivo de la sanción es también la
        // resolución que se archiva.
        final s = await pedirSuspension(context, d.denunciado);
        if (s != null) {
          r = ResolucionDenuncia(
            desestimar: false,
            texto: s.motivo,
            suspender: true,
            dias: s.dias,
            apelable: s.apelable,
          );
        }
      case 'resolver':
        final texto = await pedirTexto(
          context,
          titulo: 'Marcar como resuelta',
          etiqueta: 'Resolución',
          ayuda: 'Queda archivada con la denuncia. Al denunciante le avisamos '
              'que se tomaron medidas.',
          ejemplo: 'Se habló con las dos partes y el trabajo se completó.',
          confirmar: 'Marcar resuelta',
        );
        if (texto != null) {
          r = ResolucionDenuncia(desestimar: false, texto: texto);
        }
      case 'desestimar':
        // Flujo alterno 1.1.
        final texto = await pedirTexto(
          context,
          titulo: 'Desestimar la denuncia',
          etiqueta: 'Por qué no tiene mérito',
          ayuda: 'Al denunciante le avisamos que no encontramos pruebas '
              'suficientes.',
          ejemplo: 'No hay pruebas de que el trabajo no se haya hecho.',
          confirmar: 'Desestimar',
        );
        if (texto != null) {
          r = ResolucionDenuncia(desestimar: true, texto: texto);
        }
    }
    if (r == null || !mounted) return;

    setState(() => _resolviendo = true);
    try {
      await ref.read(denunciasRepositoryProvider).resolver(d.id, r);
      ref.invalidate(denunciasAdminProvider);
      if (mounted) {
        mostrarMensaje(
          context,
          r.desestimar
              ? 'Denuncia desestimada. Le avisamos al denunciante.'
              : r.suspender
                  ? 'Denuncia resuelta y ${d.denunciado} suspendido.'
                  : 'Denuncia resuelta. Le avisamos al denunciante.',
          esError: false,
        );
      }
    } catch (e) {
      if (mounted) mostrarMensaje(context, MensajesError.desde(e));
    } finally {
      if (mounted) setState(() => _resolviendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final denuncias = ref.watch(denunciasAdminProvider);

    return PanelAdmin(
      actual: SeccionAdmin.denuncias,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(denunciasAdminProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            EncabezadoAdmin(
              titulo: 'Denuncias y reclamos',
              bajada: denuncias.valueOrNull == null
                  ? 'Moderá los reportes de la comunidad'
                  : '${denuncias.value!.where((d) => d.abierta).length} '
                      'pendientes de revisión',
            ),
            const SizedBox(height: 16),
            // CU-49, punto de extensión CU-39: las apelaciones de las cuentas
            // suspendidas se resuelven en esta misma bandeja.
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Denuncias')),
                ButtonSegment(value: 1, label: Text('Apelaciones')),
              ],
              selected: {_pestana},
              onSelectionChanged: (s) => setState(() => _pestana = s.first),
            ),
            const SizedBox(height: 20),
            if (_pestana == 1)
              const _Apelaciones()
            else
              ...denuncias.when(
                loading: () =>
                    const [Center(child: CircularProgressIndicator())],
                error: (e, _) => [
                  AvisoEstado.riesgo(
                    icono: Icons.error_outline,
                    titulo: 'No pudimos cargar las denuncias',
                    detalle: MensajesError.desde(e),
                  ),
                ],
                data: (lista) {
                  if (lista.isEmpty) {
                    return const [
                      AvisoEstado.exito(
                        icono: Icons.verified_user_outlined,
                        titulo: 'No hay denuncias',
                        detalle:
                            'Cuando alguien reporte a un usuario, aparece acá.',
                      ),
                    ];
                  }
                  final actual = lista.firstWhere(
                    (d) => d.id == _elegida,
                    orElse: () => lista.first,
                  );
                  final listado = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final d in lista)
                        TarjetaSeleccionable(
                          key: Key('denuncia-${d.id}'),
                          seleccionada: d.id == actual.id,
                          insignia: _PildoraGravedad(d.gravedad),
                          titulo: '${d.denunciante} denunció a ${d.denunciado}',
                          bajada: '${d.motivo.etiqueta} · '
                              '${d.abierta ? Fechas.hace(d.creadaAt.toLocal()) : d.estadoLegible}',
                          onTap: () => setState(() => _elegida = d.id),
                        ),
                    ],
                  );
                  final detalle = _Detalle(
                    denuncia: actual,
                    resolviendo: _resolviendo,
                    onAccion: (a) => _resolver(actual, accion: a),
                  );
                  return [
                    LayoutBuilder(
                      builder: (context, r) => r.maxWidth >= 900
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 380, child: listado),
                                const SizedBox(width: 20),
                                Expanded(child: detalle),
                              ],
                            )
                          : Column(
                              children: [
                                listado,
                                const SizedBox(height: 20),
                                detalle
                              ],
                            ),
                    ),
                  ];
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PildoraGravedad extends StatelessWidget {
  const _PildoraGravedad(this.gravedad);

  final GravedadDenuncia gravedad;

  @override
  Widget build(BuildContext context) => switch (gravedad) {
        GravedadDenuncia.grave => Pildora(
            texto: gravedad.etiqueta,
            color: Colores.error,
            fondo: Colores.errorSuave),
        GravedadDenuncia.media => Pildora(
            texto: gravedad.etiqueta,
            color: Colores.naranjaOscuro,
            fondo: Colores.naranjaSuave),
        GravedadDenuncia.baja => Pildora(
            texto: gravedad.etiqueta,
            color: Colores.azul,
            fondo: Colores.azulSuave),
      };
}

class _Detalle extends ConsumerWidget {
  const _Detalle({
    required this.denuncia,
    required this.resolviendo,
    required this.onAccion,
  });

  final DenunciaAdmin denuncia;
  final bool resolviendo;
  final ValueChanged<String> onAccion;

  String _rol(String tipo) => switch (tipo) {
        'profesional' => 'Profesional',
        'buscador' => 'Buscador',
        _ => tipo,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = denuncia;
    final traza = d.pedidoId == null
        ? null
        : ref.watch(trazabilidadDenunciaProvider(d.id));

    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  d.numero == 0 ? 'Denuncia' : 'Denuncia #${d.numero}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colores.texto),
                ),
              ),
              _PildoraGravedad(d.gravedad),
            ],
          ),
          const SizedBox(height: 4),
          Text('${d.motivo.etiqueta} · ${Fechas.conHora(d.creadaAt.toLocal())}',
              style: const TextStyle(color: Colores.textoSecundario)),
          const SizedBox(height: 16),
          const Text('DESCARGO DEL DENUNCIANTE',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colores.textoSecundario)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colores.fondo,
              borderRadius: BorderRadius.circular(Medidas.radio),
            ),
            child: Text('«${d.descripcion}»',
                style: const TextStyle(color: Colores.texto, height: 1.4)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 32,
            runSpacing: 12,
            children: [
              DatoAdmin(
                etiqueta: 'Denunciante',
                valor: '${d.denunciante} (${_rol(d.denuncianteTipo)})',
              ),
              DatoAdmin(
                etiqueta: 'Denunciado',
                valor: '${d.denunciado} (${_rol(d.denunciadoTipo)})'
                    '${d.denunciadoEstado == 'suspendido' ? ' · suspendido' : ''}',
              ),
              DatoAdmin(
                etiqueta: 'Reputación',
                valor: [
                  if (d.reputacion != null)
                    '★ ${d.reputacion!.toStringAsFixed(1)}',
                  '${d.denunciasPrevias} denuncias previas',
                ].join(' · '),
              ),
            ],
          ),
          if (d.denunciadoId != null)
            TextButton.icon(
              onPressed: () =>
                  context.go('/admin/usuarios?id=${d.denunciadoId}'),
              icon: const Icon(Icons.person_outline),
              label: const Text('Ver el perfil del denunciado'),
            ),
          if (traza != null) ...[
            const SizedBox(height: 8),
            const Text('TRAZABILIDAD DEL PEDIDO',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colores.textoSecundario)),
            const SizedBox(height: 6),
            traza.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(MensajesError.desde(e)),
              data: (t) => _Trazabilidad(datos: t),
            ),
          ],
          const SizedBox(height: 20),
          if (d.abierta)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  key: const Key('suspender-denunciado'),
                  style: FilledButton.styleFrom(backgroundColor: Colores.error),
                  onPressed: resolviendo || d.denunciadoEstado == 'suspendido'
                      ? null
                      : () => onAccion('suspender'),
                  child: const Text('Suspender usuario'),
                ),
                OutlinedButton(
                  key: const Key('marcar-resuelta'),
                  onPressed: resolviendo ? null : () => onAccion('resolver'),
                  child: const Text('Marcar resuelta'),
                ),
                OutlinedButton(
                  key: const Key('desestimar'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colores.textoSecundario),
                  onPressed: resolviendo ? null : () => onAccion('desestimar'),
                  child: const Text('Desestimar'),
                ),
              ],
            )
          else
            AvisoEstado.exito(
              icono: Icons.task_alt,
              titulo: '${d.estadoLegible}'
                  '${d.resueltaAt == null ? '' : ' el ${Fechas.corta(d.resueltaAt!.toLocal())}'}',
              detalle: d.resolucion,
            ),
        ],
      ),
    );
  }
}

class _Trazabilidad extends StatelessWidget {
  const _Trazabilidad({required this.datos});

  final Map<String, dynamic> datos;

  @override
  Widget build(BuildContext context) {
    final pedido = datos['pedido'] as Map?;
    final eventos = (datos['eventos'] as List? ?? const []);
    if (pedido == null) return const Text('Sin pedido asociado.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('«${pedido['titulo']}» · ${pedido['estado']} · '
            '${datos['contactos'] ?? 0} contactos desbloqueados'),
        for (final e in eventos)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${Fechas.conHora(DateTime.parse((e as Map)['fecha'] as String).toLocal())}'
              ' · ${e['de'] ?? '—'} → ${e['a']}'
              '${e['motivo'] == null ? '' : ' · ${e['motivo']}'}',
              style:
                  const TextStyle(color: Colores.textoSecundario, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

/// CU-49 — Las apelaciones de las cuentas suspendidas, pendientes primero.
class _Apelaciones extends ConsumerWidget {
  const _Apelaciones();

  Future<void> _resolver(
    BuildContext context,
    WidgetRef ref,
    ApelacionAdmin a, {
    required bool aceptar,
  }) async {
    final respuesta = await pedirTexto(
      context,
      titulo: aceptar
          ? 'Aceptar la apelación #${a.numero}'
          : 'Rechazar la apelación #${a.numero}',
      etiqueta: 'Respuesta para ${a.usuario}',
      ayuda: aceptar
          ? 'Se levanta la sanción y la cuenta vuelve a estar activa.'
          : 'La sanción se mantiene. La respuesta la lee el usuario.',
      confirmar: aceptar ? 'Aceptar y reactivar' : 'Rechazar',
    );
    if (respuesta == null || !context.mounted) return;
    try {
      await ref
          .read(usuariosRepositoryProvider)
          .resolverApelacion(a.id, aceptar: aceptar, respuesta: respuesta);
      ref.invalidate(apelacionesAdminProvider);
      if (context.mounted) {
        mostrarMensaje(
          context,
          aceptar
              ? 'Apelación aceptada: la cuenta de ${a.usuario} está activa.'
              : 'Apelación rechazada.',
          esError: false,
        );
      }
    } catch (e) {
      if (context.mounted) mostrarMensaje(context, MensajesError.desde(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(apelacionesAdminProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AvisoEstado.riesgo(
            icono: Icons.error_outline,
            titulo: 'No pudimos cargar las apelaciones',
            detalle: MensajesError.desde(e),
          ),
          data: (lista) => lista.isEmpty
              ? const AvisoEstado.exito(
                  icono: Icons.inbox_outlined,
                  titulo: 'No hay apelaciones',
                  detalle: 'Cuando un usuario suspendido apele su sanción, '
                      'aparece acá con su número de trámite.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final a in lista) ...[
                      TarjetaPanel(
                        key: Key('apelacion-${a.numero}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Apelación #${a.numero} · ${a.usuario}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colores.texto),
                                  ),
                                ),
                                Text(Fechas.hace(a.fecha.toLocal()),
                                    style: const TextStyle(
                                        color: Colores.textoTenue,
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sanción: ${a.sancionMotivo} · '
                              '${a.permanente ? 'permanente' : 'hasta el ${Fechas.corta(a.hasta!.toLocal())}'}',
                              style: const TextStyle(
                                  color: Colores.textoSecundario),
                            ),
                            const SizedBox(height: 8),
                            Text('«${a.descargo}»',
                                style: const TextStyle(height: 1.4)),
                            const SizedBox(height: 12),
                            if (a.pendiente)
                              Wrap(
                                spacing: 12,
                                children: [
                                  FilledButton(
                                    key: Key('aceptar-${a.numero}'),
                                    style: FilledButton.styleFrom(
                                        backgroundColor: Colores.exito),
                                    onPressed: () => _resolver(context, ref, a,
                                        aceptar: true),
                                    child: const Text('Aceptar y reactivar'),
                                  ),
                                  OutlinedButton(
                                    key: Key('rechazar-${a.numero}'),
                                    onPressed: () => _resolver(context, ref, a,
                                        aceptar: false),
                                    child: const Text('Rechazar'),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go(
                                        '/admin/usuarios?id=${a.usuarioId}'),
                                    child: const Text('Ver historial'),
                                  ),
                                ],
                              )
                            else
                              Text(
                                '${a.estado == 'aceptada' ? 'Aceptada' : 'Rechazada'}'
                                '${a.respuesta == null ? '' : ': ${a.respuesta}'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colores.textoSecundario),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
        );
  }
}
