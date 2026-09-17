const fs = require('fs');
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, ImageRun,
  HeadingLevel, WidthType, ShadingType, BorderStyle, AlignmentType, TableLayoutType,
} = require('docx');

// Estilo tomado del documento entregado del Sprint 2 (apartados 7.1 y 7.2).
const AZUL = '2F5496';
const CELESTE = 'D9E2F3';
const GRIS = 'BFBFBF';
const FUENTE = 'Calibri';
const ANCHO = 9638; // A4 con márgenes de 2 cm

// --- Texto con **negrita** y *cursiva* -------------------------------------
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

const p = (texto) => new Paragraph({ children: runs(texto), spacing: { after: 160, line: 288 } });
const h2 = (texto) => new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(texto)] });
const h3 = (texto) => new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun(texto)] });

// --- Tablas -----------------------------------------------------------------
const borde = { style: BorderStyle.SINGLE, size: 6, color: GRIS };
const bordes = { top: borde, bottom: borde, left: borde, right: borde };

function celda(texto, ancho, { encabezado = false } = {}) {
  return new TableCell({
    width: { size: ancho, type: WidthType.DXA },
    borders: bordes,
    shading: encabezado ? { type: ShadingType.CLEAR, color: 'auto', fill: CELESTE } : undefined,
    margins: { top: 100, bottom: 100, left: 120, right: 120 },
    children: [new Paragraph({
      spacing: { after: 0, line: 264 },
      children: runs(texto, encabezado ? { bold: true } : {}),
    })],
  });
}

function tabla(anchos, encabezado, filas) {
  const suma = anchos.reduce((a, b) => a + b, 0);
  if (suma !== ANCHO) throw new Error(`Los anchos suman ${suma} y no ${ANCHO}`);
  return new Table({
    width: { size: ANCHO, type: WidthType.DXA },
    columnWidths: anchos,
    layout: TableLayoutType.FIXED,
    rows: [
      new TableRow({ tableHeader: true, children: encabezado.map((t, i) => celda(t, anchos[i], { encabezado: true })) }),
      ...filas.map((fila) => new TableRow({ children: fila.map((t, i) => celda(t, anchos[i])) })),
    ],
  });
}

const espacio = () => new Paragraph({ spacing: { after: 120 }, children: [] });

// --- Contenido --------------------------------------------------------------
const hijos = [
  h2('7.3 Sprint 3 — Perfil del Profesional y Notificaciones'),
  p('**Estado: cerrado.** Los trece ítems comprometidos se implementaron dentro del período, incluido el CU-21, verificado de punta a punta con una notificación real en un dispositivo Android. Los releases v0.3.0 y v0.3.1 quedaron etiquetados en el repositorio.'),
  tabla([3200, 6438], ['Atributo', 'Detalle'], [
    ['Paquete de trabajo', 'PT 4.0'],
    ['Período de desarrollo', '03/09/2026 al 16/09/2026'],
    ['Fecha de entrega por BB', '16/09/2026 hasta las 23:59'],
    ['Fecha de reunión', '17/09/2026'],
    ['Esfuerzo comprometido', '56 puntos (13 ítems)'],
    ['Esfuerzo real ejecutado', '56 puntos de alcance cerrado'],
    ['Alcance cerrado', '13 de 13 ítems (100 %)'],
    ['Requerimientos cubiertos', 'RF02, RF03, RF08'],
    ['Release', 'v0.3.0 (cierre del sprint) y v0.3.1 (CU-21 verificado con Firebase)'],
    ['Repositorio', 'https://github.com/tarevaloit/laburito'],
    ['Estado del sprint', 'Cerrado. Compromiso cumplido en su totalidad.'],
  ]),
  espacio(),
  p('**Objetivo del sprint (recordatorio del apartado 4.3).** Completar el lado del Profesional y conectar la publicación de un pedido con la alerta geolocalizada en el celular. El objetivo se considera alcanzado: el Profesional configura su zona, sus oficios, sus horarios y su portafolio, ve los pedidos cercanos ordenados por distancia, y recibe una notificación cuando se publica uno que le corresponde.'),

  h3('7.3.1 Tareas planificadas y esfuerzo real'),
  p('El compromiso fue de 56 puntos y no de los 45 del apartado 4.3: se sumaron los 5 del CU-17 replanificado (apartado 7.2.3) y 6 puntos de deuda técnica con estimación propia, en aplicación del segundo ajuste del apartado 7.2.7.'),
  tabla([900, 4338, 700, 1000, 2700], ['ID', 'Tarea / Caso de Uso', 'Pts', 'Estado', 'Evidencia (commit)'], [
    ['CU-17', 'Consultar Historial (replanificado del Sprint 2)', '5', 'Hecho', '0f6df51'],
    ['T-06', 'Pruebas de widget de los formularios de pedido (deuda)', '3', 'Hecho', '07375ec'],
    ['T-07', 'Esquema del Profesional con sus políticas RLS (infraestructura)', '—', 'Hecho', '76137a4'],
    ['T-08', 'Fotografías visibles para el Profesional y protección de la edición (deuda)', '3', 'Hecho', 'de98be8'],
    ['CU-07', 'Configurar Zona de Cobertura', '5', 'Hecho', 'a38c349'],
    ['CU-12', 'Editar Categorías de Oficio', '4', 'Hecho', 'd4cabe7'],
    ['CU-21', 'Recibir Alerta Push', '14', 'Hecho', 'bdd5dc6 … 5aad5a1 (7 commits)'],
    ['CU-43', 'Explorar Tablero de Pedidos', '5', 'Hecho', '96a2f6b'],
    ['CU-22', 'Ver Detalle de Pedido', '3', 'Hecho', '96a2f6b'],
    ['CU-23', 'Ignorar Pedido', '2', 'Hecho', '7c983b1'],
    ['CU-24', 'Guardar Pedido (Favorito)', '2', 'Hecho', '7c983b1'],
    ['CU-44', 'Gestionar Horarios y disponibilidad', '5', 'Hecho', '6a3239c'],
    ['CU-06', 'Cargar Portafolio', '5', 'Hecho', '0a4b436'],
    ['**TOTAL**', '**13 ítems comprometidos — 13 completados**', '**56**', '**100 %**', '**17 commits**'],
  ]),
  espacio(),
  p('**Lectura del resultado.** Es el primer sprint que cierra un compromiso mayor al planificado. Cuatro factores lo explican: el modelo de datos del Profesional se resolvió completo en la primera fase (T-07) en lugar de repartirse entre los casos de uso, que fue la causa del desvío del Sprint 2; los casos de uso se apoyaron en componentes ya construidos (el selector de ubicación del CU-16, la carga de imágenes del CU-09, la tarjeta y el paginado del CU-17); cada migración se verificó contra la base real antes de escribir código sobre ella; y ningún ítem superó su estimación de manera significativa. La T-07 no lleva puntos, con el mismo criterio que la T-02b del Sprint 2.'),
  p('**Sobre el registro del esfuerzo.** A partir de este sprint el esfuerzo se informa solo en puntos de alcance cerrado y se discontinúa la columna de horas, que en el Sprint 2 había sido una equivalencia derivada y no una medición (ver 7.3.6).'),

  h3('7.3.2 Evidencia de la ejecución'),
  p('Se sostiene la convención de commits con el identificador del caso de uso. El listado completo se adjunta a la entrega como archivo de evidencia.'),
  tabla([3200, 6438], ['Control ejecutado al cierre', 'Resultado'], [
    ['flutter analyze', '0 issues'],
    ['flutter test', '273 pruebas en verde (163 al cierre del Sprint 2)'],
    ['Builds', 'Web, APK de Android e iOS (simulador) compilan'],
    ['Migraciones', '0012 a 0019 aplicadas y verificadas contra la base, cada una con su guion de aceptación'],
    ['Edge Function', 'emparejar_pedido desplegada'],
    ['Prueba de punta a punta', 'Pedido publicado desde la Web → notificación recibida en Android → apertura del detalle'],
    ['Tags de release', 'v0.3.0 y v0.3.1'],
  ]),
  espacio(),
  p('**Material complementario de la entrega.** Video de demostración del circuito completo: el Buscador publica un pedido en la Web y el Profesional recibe la alerta en el celular, abre el detalle y lo guarda; además, configuración de zona, oficios, horarios y portafolio.'),

  h3('7.3.3 Tareas faltantes y replanificación'),
  p('No quedó ningún ítem del compromiso sin cerrar. Se arrastra únicamente lo siguiente:'),
  tabla([2600, 5638, 1400], ['Ítem arrastrado', 'Justificación', 'Sprint de resolución'], [
    ['CU-18 Reenvío de enlace de gestión', 'Replanificación ya registrada en el apartado 7.2.3; sin cambios.', 'Sprint 5'],
    ['Lectura de la ubicación exacta por la API', 'Las pantallas del Profesional usan la vista pública, pero la política de lectura de pedidos vigentes permite consultar la fila completa. Se corrige antes de habilitar el contacto entre las partes.', 'Sprint 4'],
    ['Columnas sensibles del Profesional', 'La política de actualización del Profesional abarca la fila entera, incluida la verificación y el saldo de tokens. Se protege con un disparador, igual que el estado del pedido.', 'Sprint 4'],
    ['Notificaciones en iOS', 'Requieren la cuenta del Apple Developer Program. Android y Web quedan operativos.', 'Sprint 6 (T-03)'],
    ['Mitigaciones del apartado 6', 'No se ejecutaron la validación del entorno de prueba de Mercado Pago ni el alta de las cuentas de desarrollador de Apple y Google, previstas para este sprint. La primera se hace el primer día del Sprint 4, antes del CU-31; el alta de cuentas, dentro del mismo sprint.', 'Sprint 4'],
  ]),
  espacio(),

  h3('7.3.4 Problemas encontrados'),
  p('Se documentan los tres que consumieron tiempo y dejan un aprendizaje trasladable a los sprints siguientes.'),
  p('**a) La revocación de permisos sobre funciones no tenía efecto.** Las migraciones revocaban la ejecución de las funciones al rol público, pero Supabase otorga ese permiso de manera explícita a los roles anónimo y autenticado, y la revocación genérica no lo alcanza. En la función que determina a qué Profesionales se les envía la alerta, eso permitía averiguar dónde hay Profesionales cerca de un punto. *Solución:* revocación explícita a cada rol y verificación sobre el catálogo de la base. *Aprendizaje:* un permiso se da por cerrado cuando se comprueba, no cuando se escribe.'),
  p('**b) La alerta no se disparaba desde la Web.** El navegador envía una consulta previa antes de invocar la función del servidor, y la función la rechazaba. Como la publicación del pedido no falla si falla la alerta, el defecto no era visible en pantalla. *Solución:* responder la verificación del navegador. *Aprendizaje:* lo que se hace silencioso a propósito necesita una prueba que lo mire.'),
  p('**c) Tocar la notificación abría la pantalla del dueño del pedido.** La navegación llevaba al detalle del Buscador —que muestra la dirección exacta— y, al volver, dejaba al Profesional en «Mis pedidos». Se detectó en la prueba con un dispositivo real. *Solución:* abrir el detalle del Profesional apilado sobre el tablero y validar el rol en las pantallas del Buscador. *Aprendizaje:* las pruebas automáticas verificaban qué pantalla se abría, pero no qué quedaba debajo.'),

  h3('7.3.5 Burndown del proyecto tras el Sprint 3'),
  p('El gráfico siguiente incorpora el tercer punto medido de la línea de ejecución real. Se conservan la línea ideal y la línea planificada tal como fueron publicadas en la Sección 1, y la serie real se grafica con los valores corregidos del apartado 7.3.6.'),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 120, after: 60 },
    children: [new ImageRun({
      type: 'png',
      data: fs.readFileSync(process.argv[2]),
      transformation: { width: 620, height: 362 },
      altText: { title: 'Figura 4', description: 'Burndown del proyecto al cierre del Sprint 3', name: 'burndown' },
    })],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 200 },
    children: [new TextRun({ text: 'Figura 4 — Burndown con la ejecución real acumulada al cierre del Sprint 3.', italics: true, size: 20, color: '595959' })],
  }),
  tabla([3212, 3213, 3213], ['Etiqueta', 'Esf. remanente (planificado)', 'Esf. remanente (real)'], [
    ['Inicio', '235', '235'],
    ['Sprint 1', '200', '200'],
    ['Sprint 2', '160', '169'],
    ['Sprint 3', '115', '119'],
    ['Sprint 4', '65', ''],
    ['Sprint 5', '30', ''],
    ['Sprint 6', '0', ''],
  ]),
  espacio(),
  p('**Lectura del gráfico.** La línea real se acerca a la planificada: la distancia pasa de 9 puntos al cierre del Sprint 2 a 4 al cierre del Sprint 3, y esos 4 son exactamente el CU-18 trasladado al Sprint 5. El alcance del backlog cerrado en este sprint es de 50 puntos —los 6 de deuda técnica no descuentan backlog— y el avance acumulado llega al 49,4 %, frente al 51,1 % planificado. No se activa la cláusula de descarte del apartado 6: el Sprint 3 era el de recuperación y la cumplió.'),

  h3('7.3.6 Correcciones al apartado 7.2'),
  p('El documento es incremental, de modo que el apartado 7.2 no se modifica: sus errores se registran y se corrigen en este apartado.'),
  tabla([4000, 5638], ['En el apartado 7.2', 'Corrección'], [
    ['La tabla del 7.2.5 consigna remanentes reales de 205 y 174.', 'Descontaba el esfuerzo medido del Sprint 1 (30 puntos) en lugar de su alcance cerrado (35), contra el criterio del propio 7.2.1. Los valores correctos son **200 y 169**, y así se grafican en la Figura 4.'],
    ['La tabla del 7.2.1 y la Figura 3 quedaron con marcas de edición sin completar.', 'Se reemplazan por la evidencia de este apartado: la Figura 4 sustituye a la Figura 3, y los commits del Sprint 2 constan en su archivo de evidencia.'],
    ['El 7.2.1 anuncia que el registro de horas por ítem se restablece en el Sprint 3.', 'No se restableció: se discontinuó la columna de horas y el esfuerzo se informa solo en puntos de alcance cerrado (7.3.1).'],
    ['El 7.2.7 fija un punto de control al séptimo día.', 'El control del 09/09 no se ejecutó. Se reemplazó por controles sobre el tramo final; el del cierre del tablero quedó registrado y confirmó que no hacía falta descartar alcance.'],
    ['El 7.2.7 fija el descarte sobre el CU-23 y el CU-24.', 'Se modificó el orden (primero CU-06, después CU-44), porque esos dos sumaban solo 4 puntos. Finalmente no hizo falta descartar nada.'],
    ['El 7.2.6 indica que la firma de las URL de las fotografías expira a la hora.', 'Expira a los 30 minutos, con renovación anticipada.'],
  ]),
  espacio(),

  h3('7.3.7 Conclusiones y ajustes para el Sprint 4'),
  p('El sprint cumplió su objetivo y su compromiso completo, que además era el más cargado del proyecto hasta aquí. Se trasladan tres ajustes al Sprint 4.'),
  p('**Primero, cerrar las dos deudas de seguridad antes del circuito de pago.** La lectura de la ubicación exacta y la protección de las columnas del Profesional se resuelven al inicio, porque el CU-25 desbloquea el contacto y el CU-31 acredita tokens: son justamente los datos que hoy quedan expuestos.'),
  p('**Segundo, sostener la verificación contra la base real.** Cada migración de este sprint se aplicó y se probó con su guion antes de construir encima, y ningún problema de modelo de datos llegó a la interfaz. El Sprint 4 depende de Mercado Pago, así que el mismo criterio se aplica a su entorno de prueba desde el primer día.'),
  p('**Tercero, probar en un dispositivo antes de dar un caso de uso por cerrado.** Dos de los tres problemas del apartado 7.3.4 aparecieron recién con la aplicación instalada.'),
  p('**Punto de partida del Sprint 4.** Arranca con las dos deudas de seguridad y sigue por el CU-31 y el CU-32, que concentran 22 de sus 50 puntos y la integración con el servicio externo. El remanente del proyecto es de 119 puntos repartidos en tres sprints.'),
];

const doc = new Document({
  creator: 'T. N. Arévalo',
  title: 'Planificación y desarrollo — 7.3 Sprint 3',
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

Packer.toBuffer(doc).then((b) => { fs.writeFileSync(process.argv[3], b); console.log('ok', b.length); });
