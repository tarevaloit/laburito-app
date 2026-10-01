import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/colores.dart';
import '../../../core/widgets/barra_navegacion.dart';
import '../../../core/widgets/boton_principal.dart';
import '../../../core/widgets/marca_laburito.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../billetera/presentation/controllers/billetera_controller.dart';
import '../../perfil/data/perfil_repository.dart';

/// Home provisorio del Sprint 1. Confirma la identidad del usuario autenticado,
/// da acceso al perfil y a la verificación, y expone el CU-10 / CU-50.
/// Se reemplaza en el Sprint 2 por el tablero de pedidos.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _confirmarSalida(BuildContext context, WidgetRef ref) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Querés salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (salir != true) return;

    await ref.read(authControllerProvider.notifier).cerrarSesion();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfilAsync = ref.watch(perfilCompletoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const LogoLaburito(alto: 34),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmarSalida(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: BarraNavegacion.siCorresponde(
        actual: SeccionApp.tablero,
        mostrarBilletera: perfilAsync.valueOrNull?.esProfesional ?? false,
      ),
      body: perfilAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('No pudimos cargar tu perfil: $e')),
        data: (p) {
          if (p == null) {
            return const Center(child: Text('Sin perfil asociado.'));
          }

          // El saldo sale de la billetera y no del perfil: el perfil se lee
          // una vez al iniciar sesión, y la billetera es la que se actualiza
          // al comprar, canjear o desbloquear (CU-30). Solo para el
          // Profesional: los demás no tienen billetera que leer.
          final saldo = p.esProfesional
              ? ref.watch(billeteraProvider).valueOrNull?.saldo ?? p.saldoTokens
              : 0;

          return TarjetaFormulario(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colores.azulSuave,
                    backgroundImage:
                        p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
                    child: p.avatarUrl == null
                        ? Text(
                            p.nombre.characters.first.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colores.azul,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hola, ${p.nombre}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colores.azul,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.esProfesional
                      ? 'Cuenta de Profesional'
                      : p.esAdministrador
                          ? 'Cuenta de Administrador'
                          : 'Cuenta de Buscador',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colores.textoSecundario),
                ),
                const SizedBox(height: 24),
                if (p.necesitaCargarDocumentacion) ...[
                  AvisoEstado.pendiente(
                    icono: Icons.badge_outlined,
                    titulo: 'Completá tu verificación',
                    detalle:
                        'Subí tu DNI para que un administrador habilite tu perfil.',
                    accion: 'Cargar documentación',
                    onAccion: () => context.go('/verificacion'),
                  ),
                  const SizedBox(height: 16),
                ] else if (p.esProfesional &&
                    p.estadoVerificacion == 'en_revision') ...[
                  AvisoEstado.exito(
                    icono: Icons.hourglass_top_rounded,
                    titulo: 'Documentación en revisión',
                    detalle:
                        'Un administrador está revisando tus datos. Te avisamos cuando se apruebe.',
                    accion: 'Ver estado',
                    onAccion: () => context.go('/verificacion'),
                  ),
                  const SizedBox(height: 16),
                ],
                TarjetaPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Dato('Nombre', p.nombreCompleto),
                      _Dato('Correo', p.email),
                      _Dato('Teléfono', p.telefono ?? '—'),
                      _Dato('Estado de la cuenta', p.estadoLegible),
                      if (p.esProfesional) ...[
                        _Dato('DNI', p.dni ?? '—'),
                        _Dato('Verificación', p.verificacionLegible ?? '—'),
                        _Dato('Oficios', p.categorias.length.toString()),
                        _Dato('Tokens', saldo.toString()),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (p.esAdministrador) ...[
                  BotonPrincipal(
                    texto: 'Panel de administración',
                    icono: Icons.admin_panel_settings_outlined,
                    onPressed: () => context.go('/admin/precios'),
                  ),
                  const SizedBox(height: 12),
                ],
                if (!p.esProfesional && !p.esAdministrador) ...[
                  BotonPrincipal(
                    texto: 'Publicar un pedido',
                    icono: Icons.add_circle_outline,
                    onPressed: () => context.go('/pedidos/nuevo'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/pedidos'),
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('Mis pedidos'),
                  ),
                  const SizedBox(height: 12),
                ],
                if (p.esProfesional) ...[
                  BotonPrincipal(
                    texto: 'Ver pedidos cerca mío',
                    icono: Icons.explore_outlined,
                    onPressed: () => context.go('/profesional/tablero'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/profesional/billetera'),
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: Text('Mi billetera · $saldo tokens'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/profesional/zona'),
                    icon: const Icon(Icons.travel_explore),
                    label: const Text('Zona de cobertura'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/profesional/horarios'),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Horarios y disponibilidad'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/profesional/portafolio'),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Mi portafolio'),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: () => context.go('/perfil'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar mi perfil'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(etiqueta,
                style: const TextStyle(
                  color: Colores.textoSecundario,
                  fontSize: 13,
                )),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colores.texto,
                )),
          ),
        ],
      ),
    );
  }
}
