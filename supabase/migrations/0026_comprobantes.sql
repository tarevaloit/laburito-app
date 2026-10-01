-- ============================================================================
-- Laburito — Migración 0026
-- Sprint 4 · CU-19 Descargar Comprobante de Tokens
-- ============================================================================
--
-- Bucket privado para los PDF que genera la Edge Function `comprobante_pago`.
-- Ruta: `{profesional_id}/{pago_id}.pdf`.
--
-- El dueño lee su carpeta; nadie escribe por la API. El archivo lo sube la
-- función con `service_role`, después de comprobar que el pago es de quien lo
-- pide y está aprobado: un comprobante es un documento que dice «Laburito
-- cobró esto», y no puede fabricarlo el cliente.
--
-- **Desvío respecto de la ERS**: el CU-19 describe una Factura C emitida por
-- AFIP. El PT 5.0 lo acota a un comprobante emitido por la plataforma (así
-- figura en el apartado 4.4) y el entorno es de desarrollo, sin CUIT ni punto
-- de venta. El PDF lo dice en su pie.
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('comprobantes', 'comprobantes', false, 1048576, array['application/pdf'])
on conflict (id) do nothing;

drop policy if exists "comprobantes: lectura propia" on storage.objects;
create policy "comprobantes: lectura propia"
    on storage.objects for select
    to authenticated
    using (
        bucket_id = 'comprobantes'
        and ((storage.foldername(name))[1] = auth.uid()::text or public.es_admin())
    );

-- Sin políticas de INSERT, UPDATE ni DELETE: solo service_role escribe acá.
