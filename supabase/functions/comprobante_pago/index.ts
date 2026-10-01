// ============================================================================
// Laburito — Edge Function `comprobante_pago`
// Sprint 4 · CU-19 Descargar Comprobante de Tokens
// ============================================================================
//
// Recibe el id de un pago y devuelve una URL firmada del PDF del comprobante.
//
// Solo para un pago **aprobado** y **de quien llama**: se lee con
// `service_role` y se compara el dueño a mano, igual que `emparejar_pedido`
// compara `buscador_id`. Un pago pendiente contesta «comprobante en proceso»,
// que es el flujo alterno del CU-19.
//
// El PDF se genera una vez y se guarda en el bucket privado `comprobantes`
// (migración 0026) en `{profesional}/{pago}.pdf`; los pedidos siguientes
// firman el mismo archivo. Un pago aprobado no cambia, así que su comprobante
// tampoco.
//
// **Desvío respecto de la ERS**: es un comprobante emitido por la plataforma,
// no una Factura C de AFIP (apartado 4.4 del PT 5.0). El pie del PDF lo dice.
// ============================================================================

import { PDFDocument, rgb, StandardFonts } from 'npm:pdf-lib@1.17.1';
import { campo, CORS, json, llamante, servicio } from '../_shared/http.ts';

interface PagoAprobado {
  id: string;
  profesional_id: string;
  paquete_nombre: string;
  cantidad_tokens: number;
  monto_ars: number;
  estado: string;
  mp_payment_id: string | null;
  metodo_pago: string | null;
  numero_comprobante: number | null;
  aprobado_at: string | null;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS });
  }
  if (req.method !== 'POST') return json({ error: 'Usá POST' }, 405);

  const quien = await llamante(req);
  if (quien instanceof Response) return quien;

  const pagoId = await campo(req, 'pago_id');
  if (pagoId instanceof Response) return pagoId;

  const db = servicio();

  const { data: pago, error } = await db
    .from('pagos')
    .select('id, profesional_id, paquete_nombre, cantidad_tokens, monto_ars, estado, '
      + 'mp_payment_id, metodo_pago, numero_comprobante, aprobado_at')
    .eq('id', pagoId)
    .maybeSingle<PagoAprobado>();

  if (error) return json({ error: 'No pudimos buscar el pago.' }, 500);
  if (!pago || pago.profesional_id !== quien.usuario.id) {
    return json({ error: 'Ese pago no existe.', codigo: 'sin_permiso' }, 404);
  }
  if (pago.estado !== 'aprobado' || !pago.numero_comprobante) {
    return json({
      error: 'El comprobante está en proceso de emisión. Probá de nuevo cuando el pago figure aprobado.',
      codigo: 'comprobante_en_proceso',
    }, 409);
  }

  const ruta = `${pago.profesional_id}/${pago.id}.pdf`;
  const nombreArchivo = `laburito-comprobante-${numero(pago.numero_comprobante)}.pdf`;
  const bucket = db.storage.from('comprobantes');

  // ¿Ya estaba generado?
  const { data: existentes } = await bucket.list(pago.profesional_id, {
    search: `${pago.id}.pdf`,
  });

  if (!existentes?.some((o) => o.name === `${pago.id}.pdf`)) {
    const { data: perfil } = await db
      .from('perfiles')
      .select('nombre, apellido, email')
      .eq('id', pago.profesional_id)
      .single();
    const { data: profesional } = await db
      .from('profesionales')
      .select('dni')
      .eq('perfil_id', pago.profesional_id)
      .single();

    const pdf = await generarPdf(pago, {
      nombre: `${perfil?.nombre ?? ''} ${perfil?.apellido ?? ''}`.trim(),
      email: perfil?.email ?? '',
      dni: profesional?.dni ?? null,
    });

    const { error: errorSubida } = await bucket.upload(ruta, pdf, {
      contentType: 'application/pdf',
      upsert: true,
    });
    if (errorSubida) {
      console.error('No se pudo guardar el comprobante', errorSubida);
      return json({ error: 'No pudimos generar el comprobante. Probá de nuevo.' }, 500);
    }
  }

  const { data: firmada, error: errorFirma } = await bucket.createSignedUrl(ruta, 600, {
    download: nombreArchivo,
  });
  if (errorFirma || !firmada) {
    return json({ error: 'No pudimos preparar la descarga. Probá de nuevo.' }, 500);
  }

  return json({ url: firmada.signedUrl, archivo: nombreArchivo });
});

const numero = (n: number) => `0001-${String(n).padStart(8, '0')}`;

const pesos = (n: number) =>
  '$ ' + n.toLocaleString('es-AR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const fecha = (iso: string) =>
  new Date(iso).toLocaleString('es-AR', {
    timeZone: 'America/Argentina/Buenos_Aires',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });

async function generarPdf(
  pago: PagoAprobado,
  titular: { nombre: string; email: string; dni: string | null },
): Promise<Uint8Array> {
  const doc = await PDFDocument.create();
  doc.setTitle(`Comprobante ${numero(pago.numero_comprobante!)}`);
  doc.setAuthor('Laburito');

  const pagina = doc.addPage([595.28, 841.89]); // A4
  const normal = await doc.embedFont(StandardFonts.Helvetica);
  const negrita = await doc.embedFont(StandardFonts.HelveticaBold);

  const azul = rgb(0.09, 0.25, 0.39);
  const naranja = rgb(0.95, 0.52, 0.16);
  const gris = rgb(0.4, 0.45, 0.5);

  const izq = 56;
  let y = 780;

  pagina.drawText('Laburito', { x: izq, y, size: 26, font: negrita, color: azul });
  pagina.drawText('COMPROBANTE DE COMPRA DE TOKENS', {
    x: izq, y: y - 24, size: 11, font: negrita, color: naranja,
  });
  pagina.drawText(`N.º ${numero(pago.numero_comprobante!)}`, {
    x: 400, y, size: 12, font: negrita, color: azul,
  });
  pagina.drawText(`Fecha: ${fecha(pago.aprobado_at!)}`, {
    x: 400, y: y - 18, size: 10, font: normal, color: gris,
  });

  y -= 60;
  pagina.drawLine({ start: { x: izq, y }, end: { x: 539, y }, thickness: 1, color: azul });

  const fila = (etiqueta: string, valor: string) => {
    y -= 24;
    pagina.drawText(etiqueta, { x: izq, y, size: 10, font: normal, color: gris });
    pagina.drawText(valor, { x: 200, y, size: 11, font: negrita, color: azul });
  };

  y -= 10;
  pagina.drawText('Titular', { x: izq, y: y - 14, size: 12, font: negrita, color: azul });
  y -= 14;
  fila('Nombre', titular.nombre || '—');
  fila('DNI', titular.dni ?? '—');
  fila('Correo', titular.email || '—');

  y -= 20;
  pagina.drawText('Detalle de la compra', { x: izq, y: y - 14, size: 12, font: negrita, color: azul });
  y -= 14;
  fila('Concepto', `Pack ${pago.paquete_nombre} · ${pago.cantidad_tokens} tokens`);
  fila('Medio de pago', pago.metodo_pago ?? 'Mercado Pago');
  fila('Operación de Mercado Pago', pago.mp_payment_id ?? '—');
  fila('Referencia interna', pago.id);

  y -= 30;
  pagina.drawRectangle({ x: izq, y: y - 16, width: 483, height: 40, color: rgb(0.93, 0.95, 0.97) });
  pagina.drawText('TOTAL', { x: izq + 14, y: y - 2, size: 12, font: negrita, color: azul });
  pagina.drawText(pesos(pago.monto_ars), { x: 400, y: y - 2, size: 14, font: negrita, color: azul });

  const pie = [
    'Comprobante emitido por la plataforma Laburito. No es una factura ni tiene validez fiscal.',
    'Operación realizada en el entorno de prueba de Mercado Pago, sin movimiento de dinero real.',
    'Seminario de Integración Profesional 2026 · Comisión P03.',
  ];
  pie.forEach((linea, i) => {
    pagina.drawText(linea, { x: izq, y: 90 - i * 14, size: 8.5, font: normal, color: gris });
  });

  return await doc.save();
}
