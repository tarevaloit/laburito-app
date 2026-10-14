// Genera el apartado 7.5 del documento de Planificación y Desarrollo, en .docx
// (para pegar al final del documento, que es incremental) y en .md (para el
// repositorio), desde un único contenido. Mismo estilo que el del apartado 7.4.
//
//   node generar-cierre-s5-docx.js <ruta/a/node_modules/docx> <salida.docx> <salida.md>
//
// Novedad respecto del 7.4: ==texto== se marca en amarillo (algo a confirmar
// antes de entregar).

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

// --- Contenido: una lista de bloques que se dibuja en .docx y en .md ---------

const P = (t) => ({ tipo: 'p', t });
const H2 = (t) => ({ tipo: 'h2', t });
const H3 = (t) => ({ tipo: 'h3', t });
const T = (anchos, enc, filas) => ({ tipo: 'tabla', anchos, enc, filas });
const FIGURA = (t, aviso, alto = 5200) => ({ tipo: 'figura', t, aviso, alto });

const contenido = [
  H2('7.5 Sprint 5 — Enlaces Públicos y Calificación'),
  P('**Estado: cerrado.** Los siete ítems comprometidos se implementaron y se verificaron contra la base real: el Profesional comparte su perfil por enlace, el Buscador lo consulta y lo califica desde el navegador sin registrarse, y ambos reciben sus avisos en el centro de notificaciones. La Web quedó publicada y el release v0.5.0 etiquetado en el repositorio.'),
  T([3200, 6438], ['Atributo', 'Detalle'], [
    ['Paquete de trabajo', 'PT 6.0'],
    ['Período de desarrollo', '01/10/2026 al 14/10/2026'],
    ['Fecha de entrega por BB', '14/10/2026 hasta las 23:59'],
    ['Fecha de reunión', '15/10/2026'],
    ['Esfuerzo comprometido', '39 puntos (7 ítems): 35 del apartado 4.5 más el CU-18 replanificado'],
    ['Esfuerzo real ejecutado', '39 puntos de alcance cerrado'],
    ['Alcance cerrado', '7 de 7 ítems (100 %)'],
    ['Requerimientos cubiertos', 'RF05, RF07, RF10; por la ERS, además RF01 (CU-18), RF02 (CU-48) y RF09 (CU-45)'],
    ['Release', 'v0.5.0 — circuito de reputación y vistas públicas sin registro'],
    ['Repositorio', 'https://github.com/tarevaloit/laburito'],
    ['Estado del sprint', 'Cerrado. Compromiso cumplido en su totalidad.'],
  ]),
  P('**Objetivo del sprint (recordatorio del apartado 4.5).** Cerrar el circuito de confianza del modelo «Frictionless»: el Profesional comparte su perfil por enlace, el Buscador lo consulta y lo califica desde el navegador sin instalar la aplicación ni registrarse. **El objetivo se considera alcanzado.**'),

  H3('7.5.1 Tareas planificadas y esfuerzo real'),
  T([1000, 4638, 700, 1100, 2200], ['ID', 'Tarea / Caso de Uso', 'Pts', 'Estado', 'Evidencia (commit)'], [
    ['T-11', 'Esquema de reputación, enlaces y actividad con sus políticas RLS (infraestructura)', '—', 'Hecho', '008afbd'],
    ['CU-26', 'Compartir Perfil Público (vía link)', '6', 'Hecho', '8400bcd'],
    ['CU-27', 'Acceder a Perfil por Link', '5', 'Hecho', '8400bcd'],
    ['CU-28', 'Calificar Profesional (vía link de un solo uso)', '8', 'Hecho', '52b09ec'],
    ['CU-48', 'Ver Notificaciones de Actividad', '7', 'Hecho', '93b0174'],
    ['CU-45', 'Ver Métricas de Perfil', '5', 'Hecho', 'c7d8a93'],
    ['CU-41', 'Reportar Usuario', '4', 'Hecho', '68778ce'],
    ['CU-18', 'Solicitar Reenvío de Enlace de Gestión', '4', 'Hecho', '66d208a'],
    ['TOTAL', '7 ítems comprometidos — 7 completados', '39', '100 %', '12 commits'],
  ]),
  P('**Lectura del resultado.** El sprint cerró su compromiso completo según lo planificado y salda el CU-18, arrastrado desde el Sprint 2. Se sostuvo el método de los sprints anteriores: el esquema completo en una primera migración (T-11) y cada migración verificada con su guion antes de construir encima. La T-11 no lleva puntos, con el criterio de la T-07 y la T-10.'),
  P('**Desvío respecto de la ERS en el CU-18.** La ERS supone un Buscador sin cuenta que gestiona su pedido con un enlace por correo; en Laburito el Buscador está registrado (CU-01). El «enlace de gestión» se implementó como un enlace de acceso de un solo uso, enviado por Supabase Auth, que abre la sesión directamente en el pedido. Se conservan las reglas del caso de uso: solo con pedidos activos, cada pedido nuevo invalida el anterior y la respuesta es siempre genérica.'),

  H3('7.5.2 Evidencia de la ejecución'),
  T([3600, 6038], ['Control ejecutado al cierre', 'Resultado'], [
    ['flutter analyze', '0 issues'],
    ['flutter test', '362 pruebas en verde (317 al cierre del Sprint 4), con una prueba de recorrido por cada pantalla nueva'],
    ['Builds', 'Web y APK de Android compilan'],
    ['Migraciones', '0027 a 0033 aplicadas y verificadas contra la base: 59 reglas de aceptación en OK'],
    ['Edge Functions', 'perfil_publico y reenviar_enlace_gestion desplegadas sin sesión'],
    ['Web publicada', 'https://laburito.web.app (Firebase Hosting)'],
    ['Prueba de punta a punta', '==Compartir el perfil desde la app → abrirlo sin cuenta en el navegador del celular → pedir la calificación por WhatsApp y registrarla → aviso en la campana y en las métricas → reporte desde el perfil y alerta en el panel del administrador==' ],
    ['Tag de release', 'v0.5.0'],
  ]),

  H3('7.5.3 Tareas faltantes y replanificación'),
  P('No quedó ningún ítem del compromiso sin cerrar. Se arrastra lo siguiente:'),
  T([2600, 5338, 1700], ['Ítem arrastrado', 'Justificación', 'Sprint de resolución'], [
    ['Alta de cuentas de desarrollador de Apple y Google', 'Mitigación del apartado 6, trasladada desde el Sprint 3. Es condición de la T-03.', 'Sprint 6 (primera tarea)'],
    ['Firma de los avisos de Mercado Pago', 'Sigue sin confirmarse; la acreditación no depende de ellos (7.4.4 b).', 'Sprint 6'],
  ]),

  H3('7.5.4 Problemas encontrados'),
  P('Se documentan los dos que dejan un aprendizaje trasladable al Sprint 6.'),
  P('**a) Las pruebas de recorrido encontraron defectos antes que el usuario.** Las estrellas del perfil público desbordaban la pantalla del celular, el gráfico de métricas también, y el botón de compartir seguía cargando detrás de la alerta de cuenta suspendida. *Solución:* corregidos antes de la prueba en el teléfono. *Aprendizaje:* confirma el tercer ajuste del 7.4.7.'),
  P('**b) La red de la facultad bloquea la Web publicada.** Su firewall intercepta las conexiones seguras y el navegador rechaza el sitio. *Solución:* las pruebas y la demostración se hacen con datos móviles. *Aprendizaje:* la demostración tiene que ensayarse en la red donde se va a presentar.'),

  H3('7.5.5 Burndown del proyecto tras el Sprint 5'),
  P('El gráfico siguiente incorpora el quinto punto medido de la línea de ejecución real. Se conservan la línea ideal y la línea planificada tal como fueron publicadas en la Sección 1.'),
  FIGURA('Figura 6 — Burndown con la ejecución real acumulada al cierre del Sprint 5.', '[ Pegar acá la captura del burndown chart ]'),
  T([3212, 3213, 3213], ['Etiqueta', 'Esf. remanente (planificado)', 'Esf. remanente (real)'], [
    ['Inicio', '235', '235'],
    ['Sprint 1', '200', '200'],
    ['Sprint 2', '160', '169'],
    ['Sprint 3', '115', '119'],
    ['Sprint 4', '65', '69'],
    ['Sprint 5', '30', '30'],
    ['Sprint 6', '0', ''],
  ]),
  P('**Lectura del gráfico.** Con el CU-18 cerrado, la línea real alcanza a la planificada por primera vez desde el Sprint 1: quedan 30 puntos, los del Sprint 6. El avance acumulado llega al 87,2 %, igual al planificado.'),

  H3('7.5.6 Correcciones al apartado 7.4'),
  T([4000, 5638], ['En el apartado 7.4', 'Corrección'], [
    ['El 7.4.7 pone las mitigaciones del apartado 6 como primeras tareas.', 'La actividad periódica sobre Supabase quedó automatizada. El alta de las cuentas de desarrollador no se ejecutó y se traslada al Sprint 6 (7.5.3).'],
  ]),

  H3('7.5.7 Conclusiones y ajustes para el Sprint 6'),
  P('El sprint cumplió su objetivo y deja el proyecto en la línea planificada. Se trasladan tres ajustes al Sprint 6.'),
  P('**Primero, las cuentas de desarrollador como primera tarea.** La T-03 las necesita y su habilitación no depende del proyecto.'),
  P('**Segundo, sostener la prueba de recorrido por pantalla.** En este sprint encontró los defectos del 7.5.4 a antes de la prueba en el teléfono; el Panel de Administración del Sprint 6 suma varias pantallas nuevas.'),
  P('**Tercero, ensayar la demostración en la red donde se presenta** (7.5.4 b).'),
  P('**Punto de partida del Sprint 6.** Los doce ítems del apartado 4.6 (30 puntos). Las tablas de calificaciones y denuncias de este sprint ya contemplan la moderación (CU-46) y la gestión de denuncias (CU-39).'),
];

// --- .docx ------------------------------------------------------------------

function runs(texto, base = {}) {
  const partes = [];
  const re = /(==[^=]+==|\*\*[^*]+\*\*|\*[^*]+\*)/g;
  let ultimo = 0, m;
  while ((m = re.exec(texto)) !== null) {
    if (m.index > ultimo) partes.push(new TextRun({ text: texto.slice(ultimo, m.index), ...base }));
    const t = m[0];
    if (t.startsWith('==')) partes.push(new TextRun({ text: t.slice(2, -2), highlight: 'yellow', ...base }));
    else if (t.startsWith('**')) partes.push(new TextRun({ text: t.slice(2, -2), bold: true, ...base }));
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

// Recuadro vacío donde va una captura (burndown o diagrama), con el epígrafe debajo.
function figuraDocx(epigrafe, aviso, alto) {
  const punteado = { style: BorderStyle.DASHED, size: 8, color: '8EAADB' };
  return [
    new Table({
      width: { size: ANCHO, type: WidthType.DXA },
      columnWidths: [ANCHO],
      layout: TableLayoutType.FIXED,
      rows: [new TableRow({
        height: { value: alto, rule: 'atLeast' },
        children: [new TableCell({
          width: { size: ANCHO, type: WidthType.DXA },
          borders: { top: punteado, bottom: punteado, left: punteado, right: punteado },
          verticalAlign: 'center',
          children: [new Paragraph({
            alignment: AlignmentType.CENTER,
            children: [new TextRun({ text: aviso, color: '8EAADB', italics: true })],
          })],
        })],
      })],
    }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 80, after: 200 },
      children: [new TextRun({ text: epigrafe, italics: true, size: 20, color: '595959' })],
    }),
  ];
}

const hijos = contenido.flatMap((b) => {
  switch (b.tipo) {
    case 'h2': return [new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(b.t)] })];
    case 'h3': return [new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun(b.t)] })];
    case 'p': return [new Paragraph({ children: runs(b.t), spacing: { after: 160, line: 288 } })];
    case 'tabla': return [tablaDocx(b), new Paragraph({ spacing: { after: 120 }, children: [] })];
    case 'figura': return figuraDocx(b.t, b.aviso, b.alto);
  }
});

const doc = new Document({
  creator: 'T. N. Arévalo',
  title: 'Planificación y desarrollo — 7.5 Sprint 5',
  styles: {
    default: { document: { run: { font: FUENTE, size: 22 } } },
    paragraphStyles: [
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
    case 'h2': return `## ${b.t}`;
    case 'h3': return `### ${b.t}`;
    case 'p': return b.t.replace(/==([^=]+)==/g, '$1');
    case 'figura': return `*${b.t}*\n\n> ${b.aviso.replace(/[\[\]]/g, '').trim()}.`;
    case 'tabla': return [
      `| ${b.enc.join(' | ')} |`,
      `|${b.enc.map(() => '---').join('|')}|`,
      ...b.filas.map((f) => `| ${f.map((c) => c.replace(/==([^=]+)==/g, '$1')).join(' | ')} |`),
    ].join('\n');
  }
}).join('\n\n');

fs.writeFileSync(process.argv[4], `# Sprint 5 — Cierre · Sección 7.5\n\n**Laburito · Seminario de Integración Profesional 2026 · Comisión P03**\n\nTexto del apartado 7.5 tal como va en el documento de Planificación y Desarrollo. Generado por \`figuras/generar-cierre-s5-docx.js\`, que produce también el \`.docx\`.\n\n---\n\n${md}\n`);
Packer.toBuffer(doc).then((b) => { fs.writeFileSync(process.argv[3], b); console.log('ok', b.length); });
