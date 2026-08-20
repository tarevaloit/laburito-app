import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/colores.dart';
import '../../../core/widgets/marca_laburito.dart';

/// Los dos documentos que el usuario acepta al registrarse (Ley 25.326).
enum DocumentoLegal {
  terminos('Términos y Condiciones', 'terminos'),
  privacidad('Política de Privacidad', 'privacidad');

  const DocumentoLegal(this.titulo, this.ruta);

  final String titulo;
  final String ruta;
}

/// Pantalla de texto legal.
///
/// El contenido definitivo lo redacta la cátedra / el titular del proyecto: acá
/// va un texto provisorio que dice de qué se trata cada documento y avisa que
/// todavía no es la versión final. Existe para que el checkbox del alta no
/// enlace a la nada.
class TextoLegalScreen extends StatelessWidget {
  const TextoLegalScreen({super.key, required this.documento});

  final DocumentoLegal documento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(documento.titulo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/registro'),
        ),
      ),
      body: TarjetaFormulario(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AvisoEstado.pendiente(
              icono: Icons.description_outlined,
              titulo: 'Texto provisorio',
              detalle:
                  'Este documento todavía no tiene su redacción definitiva. '
                  'Lo que sigue describe el alcance previsto.',
            ),
            const SizedBox(height: 20),
            TarjetaPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final parrafo in _contenido) ...[
                    Text(
                      parrafo,
                      style: const TextStyle(
                        color: Colores.textoSecundario,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/registro'),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> get _contenido => switch (documento) {
        DocumentoLegal.terminos => const [
            'Laburito es una plataforma que pone en contacto a personas que '
                'necesitan un servicio de oficio (Buscadores) con quienes lo '
                'prestan (Profesionales).',
            'Laburito no presta los servicios ni participa de la contratación: '
                'no fija precios, no garantiza resultados y no es parte del '
                'acuerdo entre las partes.',
            'El Profesional accede a los datos de contacto de un pedido '
                'consumiendo tokens. Los tokens no son dinero, no tienen valor '
                'fuera de la plataforma y no se reintegran.',
            'La cuenta es personal e intransferible. Laburito puede suspender '
                'una cuenta ante denuncias fundadas o datos falsos.',
          ],
        DocumentoLegal.privacidad => const [
            'Los datos personales que se cargan en Laburito se tratan conforme '
                'a la Ley 25.326 de Protección de los Datos Personales.',
            'Se recolectan los datos necesarios para operar: nombre, correo '
                'electrónico, teléfono y, en el caso del Profesional, el DNI y '
                'la documentación que respalda su identidad.',
            'La documentación de identidad se guarda en un repositorio privado, '
                'la ve únicamente el equipo de validación y se elimina una vez '
                'aprobada la verificación.',
            'El titular de los datos puede, en cualquier momento, acceder a '
                'ellos, rectificarlos o suprimirlos. La baja de la cuenta '
                'elimina los datos personales y libera el correo electrónico.',
          ],
      };
}
