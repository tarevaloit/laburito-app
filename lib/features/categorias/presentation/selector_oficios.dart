import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/colores.dart';
import '../data/categorias_repository.dart';

/// Selector de categorías de oficio en píldoras (Figura 3.9 y 3.16 del ANEXO UI).
///
/// Lo comparten el alta del Profesional (CU-02) y la edición del perfil
/// (CU-05 / CU-12): así el tope de categorías, el orden y el aspecto son los
/// mismos en las dos pantallas y no se corrigen por duplicado.
class SelectorOficios extends ConsumerWidget {
  const SelectorOficios({
    super.key,
    required this.elegidas,
    required this.onCambio,
    this.habilitado = true,
    this.maximo = CategoriaOficio.maximoPorProfesional,
  });

  /// Slugs elegidos. El widget no guarda estado propio.
  final Set<String> elegidas;

  /// Se llama con el conjunto nuevo. Si se llegó al tope, se llama igual con
  /// el conjunto sin cambios y `alTope` en true, para avisar al usuario.
  final void Function(Set<String> nuevas, {required bool alTope}) onCambio;

  final bool habilitado;
  final int maximo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriasActivasProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '¿Qué oficios ofrecés?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colores.texto,
                ),
              ),
            ),
            Text(
              '${elegidas.length} de $maximo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: elegidas.isEmpty ? Colores.textoTenue : Colores.naranja,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        categorias.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(
            'No pudimos cargar las categorías: $e',
            style: const TextStyle(color: Colores.error, fontSize: 13),
          ),
          data: (lista) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: lista.map((c) {
              final elegida = elegidas.contains(c.slug);
              return FilterChip(
                label: Text(c.nombre),
                selected: elegida,
                showCheckmark: elegida,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onSelected: !habilitado
                    ? null
                    : (valor) {
                        if (valor && elegidas.length >= maximo) {
                          onCambio(elegidas, alTope: true);
                          return;
                        }
                        final nuevas = Set<String>.from(elegidas);
                        valor ? nuevas.add(c.slug) : nuevas.remove(c.slug);
                        onCambio(nuevas, alTope: false);
                      },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
