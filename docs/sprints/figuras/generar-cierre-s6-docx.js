// Genera el apartado 7.6 del documento de Planificación y Desarrollo, en .docx
// (para pegar al final del documento, que es incremental) y en .md (para el
// repositorio), desde un único contenido. Mismo estilo que el del apartado 7.5.
//
//   node generar-cierre-s6-docx.js <ruta/a/node_modules/docx> <salida.docx> <salida.md>
//
// ==texto== se marca en amarillo: algo a confirmar antes de entregar. Los
// recuadros punteados (FIGURA) son para pegar la captura del burndown.

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
  H2('7.6 Sprint 6 — Administración, Cierre y Despliegue'),
  P('**Estado: cerrado.** Los catorce ítems comprometidos se implementaron: el Panel de Administración —tercera superficie de interfaz del sistema— quedó completo con sus diez casos de uso, se cerró una deuda de seguridad que permitía a cualquier usuario darse el rol de administrador, y el producto quedó documentado con el Manual de Usuario y la ayuda dentro de la aplicación. Las migraciones se aplicaron y se verificaron contra la base, la Web quedó publicada con el panel, ==la aplicación distribuida a los dispositivos de prueba== y el release v1.0.0 etiquetado en el repositorio.'),
  T([3200, 6438], ['Atributo', 'Detalle'], [
    ['Paquete de trabajo', 'PT 7.0'],
    ['Período de desarrollo', '15/10/2026 al 28/10/2026'],
    ['Fecha de entrega por BB', '28/10/2026 hasta las 23:59'],
    ['Fecha de reunión', '29/10/2026'],
    ['Esfuerzo comprometido', '32 puntos (14 ítems): 30 del apartado 4.6 más 2 de deuda de seguridad (T-13)'],
    ['Esfuerzo real ejecutado', '32 puntos de alcance cerrado'],
    ['Alcance cerrado', '14 de 14 ítems (100 %)'],
    ['Requerimientos cubiertos', 'RF10; por la ERS, además RF06 (CU-42) y RF11 (CU-34 a CU-39)'],
    ['Release', 'v1.0.0 — versión candidata con el core completo'],
    ['Repositorio', 'https://github.com/tarevaloit/laburito'],
    ['Estado del sprint', 'Cerrado. Compromiso cumplido en su totalidad.'],
  ]),
  P('**Objetivo del sprint (recordatorio del apartado 4.6).** Incorporar el Panel de Administración —tercera superficie de interfaz del sistema—, aplicar el endurecimiento de seguridad y dejar el producto desplegado, distribuido a los dispositivos de prueba y documentado. **El objetivo se considera alcanzado.**'),

  H3('7.6.1 Tareas planificadas y esfuerzo real'),
  P('El compromiso fue de 32 puntos y no de los 30 del apartado 4.6: se sumaron 2 puntos de deuda de seguridad hallada al planificar (T-13, apartado 7.6.4 a), con estimación propia, con el criterio de la T-08 y la T-09.'),
  T([1000, 4638, 700, 1100, 2200], ['ID', 'Tarea / Caso de Uso', 'Pts', 'Estado', 'Evidencia (commit)'], [
    ['T-12', 'Esquema de administración con sus políticas RLS (infraestructura)', '—', 'Hecho', '5404333'],
    ['T-13', 'Deuda de seguridad: columnas de perfiles', '2', 'Hecho', '5404333'],
    ['CU-34', 'Iniciar Sesión Administrador', '3', 'Hecho', '27513c3'],
    ['CU-38', 'Consultar Estadísticas (Dashboard)', '3', 'Hecho', '27513c3'],
    ['CU-35', 'Validar Identidad Profesional', '3', 'Hecho', '96e1c10, c1cf976'],
    ['CU-37', 'Gestionar Categorías de Oficios', '3', 'Hecho', '8352911, a9581c8'],
    ['CU-36', 'Suspender Cuenta', '3', 'Hecho', '2d35428'],
    ['CU-39', 'Gestionar Denuncias', '3', 'Hecho', '4f7a7c2'],
    ['CU-46', 'Moderar Reseñas', '2', 'Hecho', '19b7acf'],
    ['CU-47', 'Configurar Parámetros Globales', '2', 'Hecho', 'a34a2a3'],
    ['CU-49', 'Recuperar Cuenta Bloqueada', '2', 'Hecho', '58baa69'],
    ['CU-42', 'Consultar Ayuda y Soporte', '2', 'Hecho', '3bf73a0'],
    ['T-03', 'Despliegue de la Web y el backend; distribución de la app', '2', '==Hecho==', '==(completar)=='],
    ['T-04', 'Manual de Usuario y FAQ', '2', 'Hecho', 'b07803e'],
    ['TOTAL', '14 ítems comprometidos — 14 completados', '32', '100 %', '13 commits'],
  ]),
  P('**Lectura del resultado.** El sprint cerró su compromiso completo y con él el backlog del proyecto. Se sostuvo el método de los sprints anteriores: el esquema completo en una primera migración (T-12) y cada migración con su guion de aceptación antes de construir encima. La T-12 no lleva puntos, con el criterio de la T-07, la T-10 y la T-11. Los 2 puntos de la T-13 son deuda técnica y no descuentan backlog.'),
  P('**Mitigación del apartado 6 que se aprovechó.** El armazón del panel y sus componentes de tabla y formulario se habían adelantado en el Sprint 4 (precios y cupones) y el Sprint 5 (denuncias): las seis secciones nuevas se montaron sobre ese armazón, y las tablas de calificaciones y denuncias ya traían las columnas de moderación previstas.'),
  P('**Desvíos respecto de la ERS.** Se registran tres, todos de forma y no de alcance:'),
  T([1600, 8038], ['Caso de uso', 'Desvío y motivo'], [
    ['CU-36, CU-47', 'La ERS nombra un rol «SuperAdmin». Laburito tiene un único rol de administrador: el flujo alterno del CU-36 se cumple bloqueando siempre la sanción a otro administrador, y el CU-47 se protege como el CU-40, con una segunda confirmación y la contraseña.'],
    ['CU-35, CU-46', 'La ERS pide avisar por correo al Profesional y al autor de la reseña. Como en el CU-18, no se sumó un proveedor de correo: el aviso llega al centro de notificaciones del CU-48, con el motivo del rechazo o de la moderación.'],
    ['CU-38', 'La exportación «en formato Excel o PDF» se resolvió con un CSV que Excel abre directamente, sin sumar dependencias.'],
  ]),

  H3('7.6.2 Evidencia de la ejecución'),
  T([3600, 6038], ['Control ejecutado al cierre', 'Resultado'], [
    ['flutter analyze', '0 issues'],
    ['flutter test', '411 pruebas en verde (362 al cierre del Sprint 5), con una prueba de recorrido por cada pantalla nueva'],
    ['Builds', 'Web y APK de Android en modo release compilan'],
    ['Migraciones', '0034 a 0044 aplicadas y verificadas contra la base: 66 reglas de aceptación en OK'],
    ['Seguridad (T-13)', 'Verificado contra la base: un usuario ya no puede escribirse el rol ni el estado de la cuenta por la API, y sigue editando sus datos de contacto'],
    ['Web publicada', 'https://byto-laburitoapp-2e5af.web.app (Firebase Hosting), con el panel en /admin/ingresar'],
    ['Distribución de la app', '==TestFlight (iOS) y prueba interna de Google Play (Android) — completar con lo que se haya hecho=='],
    ['Prueba de punta a punta', '==Ingreso al panel → aprobar un Profesional → denuncia desde la Web → suspensión desde el panel → apelación desde la cuenta suspendida → aceptación y reactivación=='],
    ['Documentación', 'Manual de Usuario y FAQ (docs/manual/MANUAL-USUARIO.docx); las mismas preguntas en la pantalla de Ayuda'],
    ['Tag de release', '==v1.0.0=='],
  ]),

  H3('7.6.3 Tareas faltantes y replanificación'),
  P('No quedó ningún ítem del backlog sin cerrar. Al ser el último sprint, lo que sigue abierto no se replanifica a un sprint posterior sino que se deja documentado para la defensa final:'),
  T([2600, 5338, 1700], ['Ítem abierto', 'Justificación', 'Tratamiento'], [
    ['Firma de los avisos de Mercado Pago', 'Sigue sin confirmarse; la acreditación no depende de ellos (7.4.4 b), porque la app consulta el pago al volver del checkout.', 'Verificar con una compra de prueba antes de la defensa'],
    ['Canales de contacto de soporte', 'Los correos y el WhatsApp de la ayuda (CU-42, CU-49) están centralizados en un solo archivo de configuración y son de ejemplo.', 'Reemplazarlos cuando existan las casillas definitivas'],
  ]),

  H3('7.6.4 Problemas encontrados'),
  P('Se documentan los cuatro que dejan un aprendizaje.'),
  P('**a) Cualquier usuario podía darse el rol de administrador.** Al planificar el panel se revisaron las políticas de la tabla de perfiles: la de actualización del propio perfil era de fila entera y la tabla no tenía guard de columnas, a diferencia de profesionales (T-09) y pedidos (Sprint 2). Con una llamada directa a la API, un usuario podía escribir su propio tipo de cuenta o levantarse una suspensión. *Solución:* un guard antes de cada actualización que deja al dueño escribir solo sus datos de contacto; tipo y estado se cambian únicamente con las funciones del panel, que dejan registro. Se verificó contra la base. *Aprendizaje:* el guard de columnas tiene que acompañar a toda política de fila entera; se había aplicado tabla por tabla a medida que aparecía el problema y no como regla.'),
  P('**b) Un Profesional rechazado no tenía cómo volver a cargar.** Al escribir el Manual de Usuario y contrastar cada paso con la aplicación, se vio que el inicio avisaba la documentación pendiente y la que estaba en revisión, pero no la rechazada; además, tres nombres de botones del texto de ayuda no coincidían con la pantalla. *Solución:* aviso de rechazo en el inicio con el acceso a la carga y el motivo visible en la pantalla de documentación; los textos de ayuda se corrigieron antes de cargarlos en la base. *Aprendizaje:* redactar la documentación de usuario recorriendo la aplicación funciona como una prueba de aceptación más.'),
  P('**c) Una vez aprobada la identidad, la pantalla de documentación mostraba los documentos como faltantes.** Es consecuencia directa del requerimiento especial del CU-35: las fotos se destruyen al resolver, y la pantalla del CU-09 contaba documentos cargados. *Solución:* con la identidad aprobada, la pantalla muestra el estado verificado y ya no ofrece cargar nada. *Aprendizaje:* borrar datos por una regla de privacidad cambia lo que ven las pantallas que los leían; hay que revisarlas en el mismo cambio.'),

  P('**d) Cinco categorías quedaron sin ícono al aplicar la migración.** El guion de aceptación de la 0038 lo detectó: la carga de íconos buscaba los oficios por un identificador deducido del nombre, y cinco de ellos tenían uno abreviado desde la carga inicial del Sprint 1. *Solución:* se corrigieron los identificadores en la migración y se volvió a aplicar, que es segura de repetir. *Aprendizaje:* los datos que ya están en la base se consultan antes de escribir una migración que los toca, como se hizo con los esquemas desde el Sprint 3.'),

  H3('7.6.5 Burndown del proyecto tras el Sprint 6'),
  P('El gráfico siguiente incorpora el sexto y último punto medido de la línea de ejecución real. Se conservan la línea ideal y la línea planificada tal como fueron publicadas en la Sección 1.'),
  FIGURA('Figura 7 — Burndown con la ejecución real acumulada al cierre del Sprint 6.', '[ Pegar acá la captura del burndown chart ]'),
  T([3212, 3213, 3213], ['Etiqueta', 'Esf. remanente (planificado)', 'Esf. remanente (real)'], [
    ['Inicio', '235', '235'],
    ['Sprint 1', '200', '200'],
    ['Sprint 2', '160', '169'],
    ['Sprint 3', '115', '119'],
    ['Sprint 4', '65', '69'],
    ['Sprint 5', '30', '30'],
    ['Sprint 6', '0', '0'],
  ]),
  P('**Lectura del gráfico.** La línea real llega a cero junto con la planificada: los 235 puntos del backlog quedaron cerrados. El avance acumulado es del 100 %. La única separación entre ambas líneas fue la del CU-18, trasladado del Sprint 2 al Sprint 5 y saldado allí.'),
  FIGURA('Figura 8 — Avance acumulado real contra el planificado y los mínimos exigidos.', '[ Pegar acá la captura del avance acumulado (opcional) ]', 4200),

  H3('7.6.6 Correcciones al apartado 7.5'),
  T([4000, 5638], ['En el apartado 7.5', 'Corrección'], [
    ['El 7.5.7 pone el alta de las cuentas de desarrollador como primera tarea del Sprint 6.', '==Completar: fecha de alta de Apple Developer Program y de Google Play Console, o que la distribución se resolvió por otra vía.=='],
  ]),

  H3('7.6.7 Conclusiones del sprint y del proyecto'),
  P('El sprint cumplió su objetivo y cerró el backlog completo. Las tres superficies del sistema quedan operativas: la Web del Buscador, la aplicación del Profesional y el Panel de Administración.'),
  T([1300, 1500, 1500, 1500, 3838], ['Sprint', 'Planificado', 'Comprometido', 'Cerrado', 'Observación'], [
    ['Sprint 1', '35', '35', '35', 'Compromiso completo.'],
    ['Sprint 2', '40', '40', '31', 'CU-17 al Sprint 3 y CU-18 al Sprint 5.'],
    ['Sprint 3', '45', '56', '56', 'Suma el CU-17 y 6 puntos de deuda técnica.'],
    ['Sprint 4', '50', '53', '53', 'Suma 3 puntos de deuda de seguridad.'],
    ['Sprint 5', '35', '39', '39', 'Suma el CU-18 replanificado.'],
    ['Sprint 6', '30', '32', '32', 'Suma 2 puntos de deuda de seguridad.'],
  ]),
  P('**Primero, el orden de las dependencias sostuvo el plan.** Ningún sprint tuvo que esperar a otro: cada uno construyó sobre lo que el anterior dejó operativo, que era la premisa del apartado 4.'),
  P('**Segundo, la seguridad se resolvió como deuda con nombre propio.** Las tres deudas de seguridad del proyecto (T-08, T-09 y T-13) se encontraron revisando políticas antes de construir encima y se estimaron aparte, sin esconderlas dentro de un caso de uso. Es la práctica que se trasladaría a un proyecto siguiente desde el primer sprint.'),
  P('**Tercero, verificar contra la base y recorrer cada pantalla.** Los guiones de aceptación por migración y la prueba de recorrido por pantalla, incorporados en los Sprints 3 y 4, encontraron los defectos antes que el usuario en los dos últimos sprints.'),
  P('**Estado final.** Release v1.0.0, con 235 de 235 puntos del backlog cerrados, más 11 puntos de deuda técnica estimados aparte. Las pruebas de la defensa final se hacen con datos móviles (7.5.4 b).'),
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
  title: 'Planificación y desarrollo — 7.6 Sprint 6',
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

fs.writeFileSync(process.argv[4], `# Sprint 6 — Cierre · Sección 7.6\n\n**Laburito · Seminario de Integración Profesional 2026 · Comisión P03**\n\nTexto del apartado 7.6 tal como va en el documento de Planificación y Desarrollo. Generado por \`figuras/generar-cierre-s6-docx.js\`, que produce también el \`.docx\`.\n\n---\n\n${md}\n`);
Packer.toBuffer(doc).then((b) => { fs.writeFileSync(process.argv[3], b); console.log('ok', b.length); });
