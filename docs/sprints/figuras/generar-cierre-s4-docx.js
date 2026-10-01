// Genera el apartado 7.4 del documento de Planificación y Desarrollo, en .docx
// (para pegar en el documento) y en .md (para el repositorio), desde un único
// contenido. Mismo estilo que generar-cierre-docx.js (apartado 7.3).
//
//   node generar-cierre-s4-docx.js <ruta/a/node_modules/docx> <salida.docx> <salida.md>

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
const FIGURA = (t) => ({ tipo: 'figura', t });

const contenido = [
  H2('7.4 Sprint 4 — Monetización'),
  P('**Estado: cerrado.** Los once ítems comprometidos se implementaron y se verificaron contra la base real y contra el entorno de prueba de Mercado Pago: compra de tokens con Checkout Pro, acreditación automática, desbloqueo del contacto, cupones y panel del administrador. El release v0.4.0 quedó etiquetado en el repositorio.'),
  T([3200, 6438], ['Atributo', 'Detalle'], [
    ['Paquete de trabajo', 'PT 5.0'],
    ['Período de desarrollo', '17/09/2026 al 30/09/2026'],
    ['Fecha de entrega por BB', '30/09/2026 hasta las 23:59'],
    ['Fecha de reunión', '01/10/2026 (incluye la demostración del Sprint 3, ver 7.4.6)'],
    ['Esfuerzo comprometido', '53 puntos (11 ítems)'],
    ['Esfuerzo real ejecutado', '53 puntos de alcance cerrado'],
    ['Alcance cerrado', '11 de 11 ítems (100 %)'],
    ['Requerimientos cubiertos', 'RF04, RF11'],
    ['Release', 'v0.4.0 — modelo de negocio operativo sobre el entorno de prueba de Mercado Pago'],
    ['Repositorio', 'https://github.com/tarevaloit/laburito'],
    ['Estado del sprint', 'Cerrado. Compromiso cumplido en su totalidad.'],
  ]),
  P('**Objetivo del sprint (recordatorio del apartado 4.4).** Poner en funcionamiento la billetera de tokens y la pasarela de pago, con la acreditación automática y el desbloqueo efectivo del contacto, demostrado contra el entorno de desarrollo de Mercado Pago. **El objetivo se considera alcanzado:** el Profesional compra un pack, el pago se acredita sin intervención manual, y con un token obtiene el teléfono del Buscador y le escribe por WhatsApp.'),

  H3('7.4.1 Tareas planificadas y esfuerzo real'),
  P('El compromiso fue de 53 puntos y no de los 50 del apartado 4.4: se sumaron 3 puntos de deuda de seguridad arrastrada del Sprint 3 (apartado 7.3.3), con estimación propia, con el mismo criterio que la T-08.'),
  T([1000, 4638, 700, 1100, 2200], ['ID', 'Tarea / Caso de Uso', 'Pts', 'Estado', 'Evidencia (commit)'], [
    ['T-09', 'Deuda de seguridad: ubicación exacta legible por la API, columnas sensibles del Profesional y fotos de pedidos cerrados', '3', 'Hecho', '1622cc8'],
    ['T-10', 'Esquema de monetización con sus políticas RLS (infraestructura)', '—', 'Hecho', '71113e9'],
    ['CU-30', 'Consultar Saldo de Tokens', '3', 'Hecho', 'b23ba1c, 248182d'],
    ['CU-31', 'Cargar Tokens (Mercado Pago Checkout Pro)', '12', 'Hecho', '3f6fba0, b23ba1c'],
    ['CU-32', 'Procesar Pago (webhook y conciliación)', '10', 'Hecho', '3f6fba0, 1c1b003'],
    ['CU-33', 'Ver Historial de Pagos', '4', 'Hecho', 'b23ba1c'],
    ['CU-25', 'Postularse (Desbloquear Contacto)', '6', 'Hecho', '2868316'],
    ['CU-40', 'Configurar Precio de Tokens', '3', 'Hecho', 'c845fcb, dca09df'],
    ['CU-52', 'Crear Cupón Promocional', '4', 'Hecho', 'c845fcb, 489d0c7'],
    ['CU-53', 'Canjear Cupón de Tokens', '4', 'Hecho', 'a92d0fe, b23ba1c'],
    ['CU-19', 'Descargar Comprobante de Tokens (emitido por la plataforma)', '4', 'Hecho', '7896de4, b23ba1c'],
    ['TOTAL', '11 ítems comprometidos — 11 completados', '53', '100 %', '18 commits'],
  ]),
  P('**Lectura del resultado.** El sprint cerró su compromiso completo, pero con una distribución del trabajo peor que la del Sprint 3: la ejecución se concentró en el tramo final del período y el cierre se extendió hasta la reunión del 01/10. Lo que permitió sostener el alcance fue el método heredado del sprint anterior —el esquema completo en una primera migración (T-10) y cada migración verificada con su guion antes de construir encima— y que el orden de descarte quedó fijado de antemano, aunque finalmente no hizo falta aplicarlo. La T-10 no lleva puntos, con el criterio de la T-07.'),
  P('**Desvío respecto de la ERS en el CU-19.** La ERS describe una Factura C emitida por AFIP. Tal como lo acota el título del ítem en el apartado 4.4, se implementó un comprobante en PDF emitido por la plataforma, que lo aclara en su pie: el entorno es de prueba y no hay CUIT ni punto de venta.'),

  H3('7.4.2 Evidencia de la ejecución'),
  P('Se sostiene la convención de commits con el identificador del caso de uso. El listado completo se adjunta a la entrega como archivo de evidencia.'),
  T([3600, 6038], ['Control ejecutado al cierre', 'Resultado'], [
    ['flutter analyze', '0 issues'],
    ['flutter test', '317 pruebas en verde (273 al cierre del Sprint 3)'],
    ['Builds', 'Web y APK de Android compilan'],
    ['Migraciones', '0020 a 0026 aplicadas y verificadas contra la base: 51 reglas de aceptación en OK'],
    ['Edge Functions', 'crear_preferencia_pago, webhook_mercadopago, verificar_pago, retorno_pago y comprobante_pago desplegadas'],
    ['Prueba de punta a punta', 'Compra con el comprador de prueba de Mercado Pago → acreditación de los tokens → desbloqueo del contacto → chat de WhatsApp; canje de un cupón creado desde el panel del administrador'],
    ['Integridad del saldo', 'El saldo de cada Profesional coincide con la suma de sus movimientos'],
    ['Tag de release', 'v0.4.0'],
  ]),
  P('**Material complementario de la entrega.** Demostración en la reunión del 01/10 del circuito completo de ambos sprints: publicación del pedido en la Web, alerta en el celular, desbloqueo del contacto con un token, compra de tokens con Mercado Pago, historial y comprobante, y configuración de precios y cupones desde el panel del administrador.'),

  H3('7.4.3 Tareas faltantes y replanificación'),
  P('No quedó ningún ítem del compromiso sin cerrar. Se arrastra lo siguiente:'),
  T([2600, 5338, 1700], ['Ítem arrastrado', 'Justificación', 'Sprint de resolución'], [
    ['CU-18 Reenvío de enlace de gestión', 'Replanificación ya registrada en el apartado 7.2.3; sin cambios.', 'Sprint 5'],
    ['Aviso de actividad al Buscador', 'El CU-25 registra al Profesional como interesado y el Buscador lo ve en el detalle de su pedido; el aviso en el momento corresponde al CU-48.', 'Sprint 5'],
    ['Firma de los avisos de Mercado Pago', 'Los avisos se rechazaban por firma inválida mientras la clave cargada no era la de la aplicación correcta. La acreditación no depende de ellos (ver 7.4.4 b); queda confirmar que los avisos firmados se aceptan.', 'Sprint 5'],
    ['Alta de cuentas de desarrollador de Apple y Google', 'Mitigación del apartado 6 prevista para el Sprint 3 y luego para este sprint; no se ejecutó.', 'Sprint 5'],
  ]),

  H3('7.4.4 Problemas encontrados'),
  P('Se documentan los tres que consumieron tiempo y dejan un aprendizaje trasladable a los sprints siguientes.'),
  P('**a) La base de datos quedó pausada por inactividad.** El plan gratuito de Supabase suspendió el proyecto y durante dos días no se pudo aplicar ninguna migración: el código se escribió y se probó sin base, y la verificación se hizo recién al restaurarlo. Es el riesgo «Límites del plan gratuito» del apartado 6, cuya mitigación —actividad periódica sobre el proyecto— no se había ejecutado. *Solución:* restaurar el proyecto y aplicar las siete migraciones en una sola jornada, cada una con su guion. *Aprendizaje:* una mitigación escrita y no ejecutada equivale a no tenerla.'),
  P('**b) Los pagos aprobados quedaban pendientes.** El checkout funcionaba, pero los avisos de Mercado Pago se rechazaban por firma inválida, de modo que ningún pago se acreditaba. *Solución:* además del webhook, la aplicación pide al volver del checkout que el servidor consulte el pago a Mercado Pago y lo aplique, con la misma función idempotente, que no acredita dos veces. *Aprendizaje:* una integración con un servicio externo necesita una segunda vía; es además lo que recomienda el propio proveedor.'),
  P('**c) Cuatro defectos de interfaz aparecieron recién en el uso real.** Guardar un precio en el panel provocaba un error de pantalla completa; la sección de cupones no se podía abrir; cerrar sesión en la Web quedaba bloqueado por un pedido de permisos de notificación; y el inicio mostraba un saldo desactualizado. Ninguno lo detectaban las pruebas automáticas, que cubrían cada pieza pero no el recorrido completo. *Solución:* cada defecto se corrigió con una prueba que reproduce el recorrido y falla con el código anterior. *Aprendizaje:* confirma el tercer ajuste del apartado 7.3.7; las pruebas de recorrido completo pasan a escribirse junto con la pantalla.'),

  H3('7.4.5 Burndown del proyecto tras el Sprint 4'),
  P('El gráfico siguiente incorpora el cuarto punto medido de la línea de ejecución real. Se conservan la línea ideal y la línea planificada tal como fueron publicadas en la Sección 1.'),
  FIGURA('Figura 5 — Burndown con la ejecución real acumulada al cierre del Sprint 4.'),
  T([3212, 3213, 3213], ['Etiqueta', 'Esf. remanente (planificado)', 'Esf. remanente (real)'], [
    ['Inicio', '235', '235'],
    ['Sprint 1', '200', '200'],
    ['Sprint 2', '160', '169'],
    ['Sprint 3', '115', '119'],
    ['Sprint 4', '65', '69'],
    ['Sprint 5', '30', ''],
    ['Sprint 6', '0', ''],
  ]),
  P('**Lectura del gráfico.** La distancia entre la línea real y la planificada se mantiene en 4 puntos, que siguen siendo el CU-18 trasladado al Sprint 5. El alcance del backlog cerrado en este sprint es de 50 puntos —los 3 de deuda técnica no descuentan backlog— y el avance acumulado llega al 70,6 %, frente al 72,3 % planificado y al 50 % exigido para el segundo parcial. No se activa la cláusula de descarte del apartado 6.'),

  H3('7.4.6 Correcciones al apartado 7.3'),
  P('El documento es incremental, de modo que el apartado 7.3 no se modifica: sus desvíos se registran y se corrigen en este apartado.'),
  T([4000, 5638], ['En el apartado 7.3', 'Corrección'], [
    ['La ficha del 7.3 fija la reunión del Sprint 3 el 17/09.', 'La reunión no se realizó. La demostración del Sprint 3 se hizo junto con la del Sprint 4 en la reunión del 01/10.'],
    ['El 7.3.3 indica que las notificaciones quedan operativas en Android y Web.', 'Quedan operativas en Android. En la Web se desactivaron a propósito: las alertas son de la aplicación del Profesional, y en el navegador el pedido de permisos impedía cerrar sesión (7.4.4 c).'],
    ['El 7.3.3 prevé validar el entorno de prueba de Mercado Pago el primer día del Sprint 4.', 'Se validó al final del período, junto con la integración. El atraso no afectó el alcance, pero dejó sin margen el problema del 7.4.4 b.'],
    ['El 7.3.3 prevé el alta de las cuentas de desarrollador de Apple y Google dentro del Sprint 4.', 'No se ejecutó. Se traslada al Sprint 5 (7.4.3).'],
  ]),

  H3('7.4.7 Conclusiones y ajustes para el Sprint 5'),
  P('El sprint cumplió su objetivo y dejó operativo el modelo de negocio, con el avance del proyecto por encima del mínimo del segundo parcial. Se trasladan tres ajustes al Sprint 5.'),
  P('**Primero, distribuir el trabajo en todo el período.** El Sprint 5 fija un punto de control a mitad del período con un mínimo de la mitad del alcance cerrado; si no se alcanza, se aplica el orden de descarte en ese momento y no al cierre.'),
  P('**Segundo, ejecutar las mitigaciones del apartado 6 al principio.** La actividad periódica sobre el proyecto de Supabase y el alta de las cuentas de desarrollador pasan a ser las primeras tareas del sprint.'),
  P('**Tercero, probar el recorrido completo de cada pantalla antes de cerrarla.** Los cuatro defectos del 7.4.4 c no los detectaban las pruebas por pieza; desde este sprint, cada caso de uso con interfaz se cierra con una prueba de su recorrido.'),
  P('**Punto de partida del Sprint 5.** Los seis casos de uso del apartado 4.5 (35 puntos) más el CU-18 replanificado (4 puntos). El remanente del proyecto es de 69 puntos repartidos en dos sprints.'),
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

// Recuadro vacío donde va la captura del burndown, con el epígrafe debajo.
function figuraDocx(epigrafe) {
  const punteado = { style: BorderStyle.DASHED, size: 8, color: '8EAADB' };
  return [
    new Table({
      width: { size: ANCHO, type: WidthType.DXA },
      columnWidths: [ANCHO],
      layout: TableLayoutType.FIXED,
      rows: [new TableRow({
        height: { value: 5200, rule: 'atLeast' },
        children: [new TableCell({
          width: { size: ANCHO, type: WidthType.DXA },
          borders: { top: punteado, bottom: punteado, left: punteado, right: punteado },
          verticalAlign: 'center',
          children: [new Paragraph({
            alignment: AlignmentType.CENTER,
            children: [new TextRun({ text: '[ Pegar acá la captura del burndown chart ]', color: '8EAADB', italics: true })],
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
    case 'figura': return figuraDocx(b.t);
  }
});

const doc = new Document({
  creator: 'T. N. Arévalo',
  title: 'Planificación y desarrollo — 7.4 Sprint 4',
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
    case 'p': return b.t;
    case 'figura': return `*${b.t}*\n\n> Insertar acá la captura del burndown.`;
    case 'tabla': return [
      `| ${b.enc.join(' | ')} |`,
      `|${b.enc.map(() => '---').join('|')}|`,
      ...b.filas.map((f) => `| ${f.join(' | ')} |`),
    ].join('\n');
  }
}).join('\n\n');

fs.writeFileSync(process.argv[4], `# Sprint 4 — Cierre · Sección 7.4\n\n**Laburito · Seminario de Integración Profesional 2026 · Comisión P03**\n\nTexto del apartado 7.4 tal como va en el documento de Planificación y Desarrollo. Generado por \`figuras/generar-cierre-s4-docx.js\`, que produce también el \`.docx\`.\n\n---\n\n${md}\n`);
Packer.toBuffer(doc).then((b) => { fs.writeFileSync(process.argv[3], b); console.log('ok', b.length); });
