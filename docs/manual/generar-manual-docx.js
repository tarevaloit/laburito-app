// Genera el Manual de Usuario y FAQ (T-04, Sprint 6) en .docx y en .md desde
// un único contenido, con el mismo estilo que los apartados del documento de
// Planificación y Desarrollo (docs/sprints/figuras/generar-cierre-s5-docx.js).
//
//   node generar-manual-docx.js <ruta/a/node_modules/docx> <salida.docx> <salida.md>
//
// Las preguntas frecuentes son las mismas que carga la migración 0044 y que
// muestra la pantalla de Ayuda (CU-42): si cambian allá, se cambian acá.

const fs = require('fs');
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  HeadingLevel, WidthType, ShadingType, BorderStyle, AlignmentType, TableLayoutType,
} = require(process.argv[2]);

const AZUL = '2F5496';
const CELESTE = 'D9E2F3';
const GRIS = 'BFBFBF';
const FUENTE = 'Calibri';
const ANCHO = 9638; // A4 con márgenes de 2 cm

const H1 = (t) => ({ tipo: 'h1', t });
const H2 = (t) => ({ tipo: 'h2', t });
const H3 = (t) => ({ tipo: 'h3', t });
const P = (t) => ({ tipo: 'p', t });
const LI = (...items) => ({ tipo: 'li', items });
const PASOS = (...items) => ({ tipo: 'pasos', items });
const T = (anchos, enc, filas) => ({ tipo: 'tabla', anchos, enc, filas });

const contenido = [
  H1('Manual de Usuario'),
  P('**Laburito · versión 1.0.0** · Seminario de Integración Profesional 2026 · Comisión P03 · T. N. Arévalo'),

  H2('1. Qué es Laburito'),
  P('Laburito conecta a quien necesita resolver un trabajo de oficio con Profesionales cercanos. El sistema tiene tres actores y cada uno usa su propia superficie:'),
  T([2200, 3400, 4038], ['Actor', 'Dónde lo usa', 'Qué hace'], [
    ['Buscador', 'Web, desde cualquier navegador', 'Publica pedidos con su ubicación, recibe interesados y califica al Profesional.'],
    ['Profesional', 'Aplicación móvil (Android e iOS)', 'Recibe alertas de pedidos cercanos, desbloquea contactos con tokens y comparte su perfil.'],
    ['Administrador', 'Panel web en /admin/ingresar', 'Valida identidades, modera denuncias y reseñas, administra el catálogo y los parámetros.'],
  ]),
  P('Los enlaces de perfil público y de calificación se abren en el navegador sin cuenta ni instalación.'),

  H2('2. Primeros pasos'),
  H3('2.1 Crear una cuenta'),
  PASOS(
    'Buscador: en la Web tocá «Registrate» y completá nombre, apellido, correo, teléfono y contraseña. Profesional: hacé lo mismo desde la app, que además pide DNI, una descripción y tus oficios.',
    'Aceptá los términos y la política de privacidad.',
    'Ingresá el código de seis dígitos que llega a tu correo. Si no aparece, revisá el correo no deseado o pedí uno nuevo.',
  ),
  H3('2.2 Iniciar sesión y recuperar la contraseña'),
  P('Ingresá con tu correo y tu contraseña. Si la olvidaste, tocá «¿Olvidaste tu contraseña?»: te llega un código para crear una nueva, y al cambiarla se cierran las sesiones abiertas en otros dispositivos.'),
  H3('2.3 Notificaciones'),
  P('La campana de la barra superior muestra los avisos de tu cuenta: nuevos interesados, calificaciones, verificación de identidad, pagos, resultados de reportes y de apelaciones. Al abrir el centro se marcan como leídos; tocar uno te lleva a la pantalla correspondiente y «Limpiar todo» los borra.'),
  H3('2.4 Ayuda y soporte'),
  P('Desde el login o desde el ícono de ayuda del inicio abrís «Ayuda y soporte»: preguntas frecuentes por tema, un buscador y los canales de contacto con el equipo (correo y WhatsApp).'),

  H2('3. Buscador (Web)'),
  H3('3.1 Publicar un pedido'),
  PASOS(
    'Tocá «Publicar pedido».',
    'Elegí el oficio y describí el problema; podés sumar fotos y un presupuesto estimado.',
    'Marcá la ubicación en el mapa, buscando la dirección o con «Mi ubicación».',
    'Elegí cuántos días queda publicado y confirmá.',
  ),
  P('Los Profesionales de la zona y del oficio reciben una alerta. En el tablero ven una ubicación aproximada: tu dirección exacta y tu teléfono solo los ve quien desbloquea el contacto.'),
  H3('3.2 Gestionar tus pedidos'),
  P('En «Mis pedidos» están todos, agrupados por estado y con un buscador. Desde el detalle de cada uno podés:'),
  LI(
    '**Pausar** y **reanudar**: lo saca del tablero sin borrarlo.',
    '**Editar** el título, la descripción, el presupuesto o la ubicación.',
    '**Renovar** cuando faltan tres días o menos para que venza, o cuando ya venció. Hay un máximo de renovaciones por pedido que fija la administración.',
    '**Cerrar** cuando el trabajo se resolvió, o **cancelar** si ya no lo necesitás.',
  ),
  P('Cada vez que un Profesional desbloquea tu contacto, te llega el aviso «Nuevo interesado» y te escribe por WhatsApp.'),
  H3('3.3 Recuperar el acceso a un pedido'),
  P('En el login tocá «¿Perdiste el acceso a tu pedido?» e ingresá tu correo. Si tenés pedidos activos, te llega un enlace de un solo uso que abre la sesión directamente en ellos.'),
  H3('3.4 Calificar al Profesional'),
  P('Cuando termina el trabajo, el Profesional te manda un enlace por WhatsApp. Abrilo en el navegador, elegí de una a cinco estrellas y dejá un comentario si querés. Cada enlace sirve una sola vez.'),
  H3('3.5 Reportar a un Profesional'),
  P('Desde su perfil público tocá «Reportar», elegí el motivo y contá qué pasó. El equipo lo revisa y te avisa el resultado por la campana.'),

  H2('4. Profesional (aplicación móvil)'),
  H3('4.1 Validar tu identidad'),
  PASOS(
    'En el inicio, en el aviso «Completá tu verificación», tocá «Cargar documentación».',
    'Subí una foto del frente y del dorso de tu DNI y una selfie.',
    'Con los tres documentos, la revisión arranca sola.',
  ),
  P('Cuando el equipo aprueba tu cuenta, te llega el aviso y las fotos se eliminan del servidor. Si la rechaza, el aviso trae el motivo y el inicio muestra «Volver a cargar» para subirlas de nuevo.'),
  H3('4.2 Configurar tu perfil'),
  LI(
    '**Zona de cobertura:** el centro en el mapa y el radio en kilómetros. El radio máximo lo fija la administración.',
    '**Oficios:** los rubros en los que trabajás.',
    '**Horarios y disponibilidad:** los días y franjas en que atendés, y el interruptor «Estoy disponible»: apagado, dejás de recibir alertas sin borrar nada.',
    '**Portafolio:** fotos de trabajos anteriores con una descripción.',
  ),
  H3('4.3 Encontrar trabajos'),
  P('El tablero muestra los pedidos publicados de tus oficios dentro de tu zona, del más reciente al más antiguo. Desde el detalle podés guardarlo como favorito o ignorarlo. Además, cuando se publica un pedido que te corresponde, te llega una notificación al celular.'),
  H3('4.4 Tokens y contactos'),
  PASOS(
    'En la billetera elegí un pack y pagá con Mercado Pago. Los tokens se acreditan solos cuando el pago se aprueba.',
    'En el detalle de un pedido tocá «Desbloquear contacto»: se descuenta un token y aparece el teléfono del Buscador con el botón para escribirle por WhatsApp.',
    'Si tenés un cupón, canjealo desde la billetera con «Tengo un código».',
  ),
  P('El historial de la billetera muestra cada compra y cada consumo; de las compras aprobadas podés descargar el comprobante en PDF. Un mismo contacto se paga una sola vez.'),
  H3('4.5 Tu reputación'),
  LI(
    '**Compartir mi perfil:** genera el enlace público con tus datos, tu portafolio y tus reseñas.',
    '**Mis contactos y calificaciones:** desde cada contacto pedís la calificación, que se manda por WhatsApp con un enlace de un solo uso.',
    '**Mis estadísticas:** vistas de tu perfil, contactos abiertos y la efectividad, por semana o por mes.',
    '**Mis reseñas:** si una reseña es falsa u ofensiva, tocá «Reportar» y contá por qué. Si no cumple las normas, deja de mostrarse y tu promedio se recalcula.',
  ),

  H2('5. Administrador (panel web)'),
  P('El panel se abre en **/admin/ingresar**, un formulario sin registro. Solo entran las cuentas con rol de administrador; cualquier otro intento se rechaza y queda registrado con la IP y la hora. El ingreso lleva al Dashboard.'),
  T([2300, 7338], ['Sección', 'Para qué sirve'], [
    ['Dashboard', 'Pedidos publicados, ingresos, altas y reportes del rango elegido, comparados con el período anterior; altas de los últimos doce meses e ingresos por pack. «Exportar» descarga un CSV que abre Excel. Abajo, los últimos accesos al panel.'],
    ['Validaciones', 'Los Profesionales con documentación en revisión. «Aprobar cuenta» o «Rechazar» con un motivo; en los dos casos las fotos se eliminan del servidor.'],
    ['Denuncias', 'Los reportes ordenados por gravedad, con el descargo, la reputación del denunciado y la trazabilidad del pedido. Se resuelven con «Suspender usuario», «Marcar resuelta» o «Desestimar». En «Apelaciones», las de las cuentas suspendidas.'],
    ['Reseñas', 'Las reseñas reportadas por los Profesionales o marcadas por el filtro automático. «Eliminar reseña» la oculta y recalcula el promedio; «Mantener» la deja publicada.'],
    ['Usuarios', 'El buscador general: historial de pedidos, denuncias, calificaciones y sanciones de cada cuenta. Desde acá se suspende (temporal o permanente, apelable o no) y se levanta una sanción.'],
    ['Categorías', 'Alta, edición, ocultamiento y baja de oficios. Una categoría con profesionales o pedidos no se borra: se oculta.'],
    ['Parámetros', 'Radio máximo de cobertura, renovaciones por pedido y días por renovación. «Aplicar cambios globales» pide confirmación y la contraseña.'],
    ['Precios y Cupones', 'El precio de cada pack de tokens (con la contraseña) y los cupones promocionales con su vencimiento y límite de usos.'],
  ]),

  H2('6. Tu cuenta'),
  H3('6.1 Si tu cuenta fue suspendida'),
  P('Al iniciar sesión vas a ver el motivo y hasta cuándo dura la suspensión. Si la sanción lo admite, tocá «Apelar sanción», escribí tu descargo y te damos un número de trámite; el resultado te llega por la campana. Si no admite apelación, se muestra el correo de soporte legal. Una suspensión temporal se levanta sola cuando vence.'),
  H3('6.2 Dar de baja la cuenta'),
  P('Desde Mi Perfil → «Dar de baja la cuenta». Se borran tus datos personales y tus archivos; el historial de los pedidos se conserva sin tus datos y tu correo queda libre para registrarte de nuevo.'),

  H2('7. Preguntas frecuentes'),
  H3('Primeros pasos'),
  P('**¿Tiene costo usar Laburito?** Para el Buscador es gratis. El Profesional usa tokens para desbloquear el contacto de un pedido; se compran en packs desde la billetera.'),
  P('**¿Por qué tengo que validar mi correo con un código?** Confirma que el correo es tuyo y activa la cuenta.'),
  H3('Para Buscadores'),
  P('**¿Quién ve mi dirección exacta?** Nadie hasta que un Profesional desbloquea tu contacto: en el tablero la ubicación es aproximada.'),
  P('**¿Puedo pausar, editar o renovar mi pedido?** Sí, desde «Mis pedidos».'),
  H3('Para Profesionales'),
  P('**¿Por qué tengo que subir mi DNI y una selfie?** Para que los Buscadores confíen en vos. Las fotos se eliminan apenas el equipo resuelve la revisión.'),
  P('**¿Cómo recibo avisos de pedidos?** Configurá zona, oficios y horarios, y dejá activada la disponibilidad.'),
  P('**Recibí una reseña falsa u ofensiva.** Reportala desde «Mis reseñas».'),
  H3('Tokens y pagos'),
  P('**¿Qué pasa si desbloqueo dos veces el mismo pedido?** Nada: un contacto se paga una sola vez.'),
  P('**Tengo un cupón, ¿dónde lo uso?** En la billetera, «Tengo un código».'),
  H3('Cuenta y seguridad'),
  P('**¿Cómo reporto a un usuario?** El Buscador desde el perfil público del Profesional; el Profesional desde el detalle del pedido.'),
  P('**Mi cuenta fue suspendida, ¿puedo apelar?** Sí, si la sanción lo admite: ver el apartado 6.1.'),
  P('La lista completa y actualizada está en la pantalla «Ayuda y soporte» de la aplicación.'),

  H2('8. Contacto'),
  T([3200, 6438], ['Canal', 'Para qué'], [
    ['soporte@laburito.com.ar', 'Consultas y fallas de la aplicación o de la Web.'],
    ['WhatsApp de soporte', 'Desde «Ayuda y soporte», el botón abre el chat.'],
    ['legales@laburito.com.ar', 'Reclamos sobre sanciones que no admiten apelación.'],
  ]),
];

// --- .docx ------------------------------------------------------------------

function runs(texto, base = {}) {
  const partes = [];
  const re = /(\*\*[^*]+\*\*|\*[^*]+\*)/g;
  let ultimo = 0, m;
  while ((m = re.exec(texto)) !== null) {
    if (m.index > ultimo) partes.push(new TextRun({ text: texto.slice(ultimo, m.index), ...base }));
    const t = m[0];
    if (t.startsWith('**')) partes.push(new TextRun({ text: t.slice(2, -2), bold: true, ...base }));
    else partes.push(new TextRun({ text: t.slice(1, -1), italics: true, ...base }));
    ultimo = m.index + t.length;
  }
  if (ultimo < texto.length) partes.push(new TextRun({ text: texto.slice(ultimo), ...base }));
  return partes;
}

const borde = { style: BorderStyle.SINGLE, size: 6, color: GRIS };
const bordes = { top: borde, bottom: borde, left: borde, right: borde };

function celda(texto, ancho, encabezado = false) {
  return new TableCell({
    width: { size: ancho, type: WidthType.DXA },
    borders: bordes,
    shading: encabezado ? { type: ShadingType.CLEAR, color: 'auto', fill: CELESTE } : undefined,
    margins: { top: 100, bottom: 100, left: 120, right: 120 },
    children: [new Paragraph({ spacing: { after: 0, line: 264 }, children: runs(texto, encabezado ? { bold: true } : {}) })],
  });
}

function tablaDocx({ anchos, enc, filas }) {
  const suma = anchos.reduce((a, b) => a + b, 0);
  if (suma !== ANCHO) throw new Error(`Los anchos suman ${suma} y no ${ANCHO}`);
  return new Table({
    width: { size: ANCHO, type: WidthType.DXA },
    columnWidths: anchos,
    layout: TableLayoutType.FIXED,
    rows: [
      new TableRow({ tableHeader: true, children: enc.map((t, i) => celda(t, anchos[i], true)) }),
      ...filas.map((f) => new TableRow({ children: f.map((t, i) => celda(t, anchos[i])) })),
    ],
  });
}

const hijos = contenido.flatMap((b) => {
  switch (b.tipo) {
    case 'h1': return [new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun(b.t)] })];
    case 'h2': return [new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(b.t)] })];
    case 'h3': return [new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun(b.t)] })];
    case 'p': return [new Paragraph({ children: runs(b.t), spacing: { after: 160, line: 288 } })];
    case 'li': return b.items.map((t) => new Paragraph({
      children: runs(t), bullet: { level: 0 }, spacing: { after: 80, line: 276 } }));
    case 'pasos': return b.items.map((t, i) => new Paragraph({
      children: [new TextRun({ text: `${i + 1}. `, bold: true }), ...runs(t)],
      indent: { left: 360, hanging: 360 }, spacing: { after: 80, line: 276 } }));
    case 'tabla': return [tablaDocx(b), new Paragraph({ spacing: { after: 120 }, children: [] })];
  }
});

const doc = new Document({
  creator: 'T. N. Arévalo',
  title: 'Laburito — Manual de Usuario',
  styles: {
    default: { document: { run: { font: FUENTE, size: 22 } } },
    paragraphStyles: [
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FUENTE, size: 40, bold: true, color: AZUL },
        paragraph: { spacing: { before: 240, after: 120 }, keepNext: true, outlineLevel: 0 } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FUENTE, size: 32, bold: true, color: AZUL },
        paragraph: { spacing: { before: 360, after: 120 }, keepNext: true, outlineLevel: 1 } },
      { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { font: FUENTE, size: 26, bold: true, color: AZUL },
        paragraph: { spacing: { before: 300, after: 100 }, keepNext: true, outlineLevel: 2 } },
    ],
  },
  sections: [{
    properties: { page: { size: { width: 11906, height: 16838 }, margin: { top: 1134, bottom: 1134, left: 1134, right: 1134 } } },
    children: hijos,
  }],
});

// --- .md --------------------------------------------------------------------

const md = contenido.map((b) => {
  switch (b.tipo) {
    case 'h1': return `# ${b.t}`;
    case 'h2': return `## ${b.t}`;
    case 'h3': return `### ${b.t}`;
    case 'p': return b.t;
    case 'li': return b.items.map((t) => `- ${t}`).join('\n');
    case 'pasos': return b.items.map((t, i) => `${i + 1}. ${t}`).join('\n');
    case 'tabla': return [
      `| ${b.enc.join(' | ')} |`,
      `|${b.enc.map(() => '---').join('|')}|`,
      ...b.filas.map((f) => `| ${f.join(' | ')} |`),
    ].join('\n');
  }
}).join('\n\n');

fs.writeFileSync(process.argv[4], `${md}\n\n---\n\n*Generado por \`docs/manual/generar-manual-docx.js\`, que produce también el \`.docx\`.*\n`);
Packer.toBuffer(doc).then((b) => { fs.writeFileSync(process.argv[3], b); console.log('ok', b.length); });
