-- ============================================================================
-- Laburito — Migración 0044
-- Sprint 6 · CU-42 Consultar Ayuda y Soporte (y el FAQ de la T-04)
-- ============================================================================
--
-- Contenido de la base de conocimientos de la 0034. La tabla es de lectura
-- pública: `/ayuda` se abre sin cuenta. Las respuestas describen la app tal
-- como quedó al cierre del Sprint 6; el Manual de Usuario (T-04) remite acá.
-- ============================================================================

insert into public.preguntas_frecuentes (categoria, pregunta, respuesta, orden) values
-- Primeros pasos
('Primeros pasos', '¿Qué es Laburito?',
 'Laburito conecta a quien necesita resolver un trabajo de oficio (el Buscador) con Profesionales cercanos: plomeros, electricistas, gasistas y más. El Buscador publica su pedido desde la Web y los Profesionales de la zona reciben un aviso en el celular.', 10),
('Primeros pasos', '¿Tiene costo usar Laburito?',
 'Para el Buscador es gratis: publicar un pedido y recibir contactos no cuesta nada. El Profesional usa tokens para desbloquear el contacto de un pedido que le interesa; los tokens se compran en packs desde la billetera de la app.', 20),
('Primeros pasos', '¿Por qué tengo que validar mi correo con un código?',
 'Al registrarte te mandamos un código de seis dígitos. Ingresarlo confirma que el correo es tuyo y activa la cuenta. Si no te llegó, revisá la carpeta de correo no deseado o pedí uno nuevo desde la misma pantalla.', 30),

-- Para Buscadores
('Para Buscadores', '¿Cómo publico un pedido?',
 'Desde la Web, tocá «Publicar pedido»: elegí el oficio, describí el problema, sumá fotos si querés, marcá la ubicación en el mapa y elegí cuántos días queda publicado. Los Profesionales de la zona reciben un aviso.', 10),
('Para Buscadores', '¿Quién ve mi dirección exacta?',
 'Nadie hasta que vos lo decidas. En el tablero los Profesionales ven una ubicación aproximada. Tu teléfono solo lo ve el Profesional que desbloquea el contacto con un token.', 20),
('Para Buscadores', '¿Puedo pausar, editar o renovar mi pedido?',
 'Sí, desde «Mis pedidos». Pausarlo lo saca del tablero sin borrarlo; editarlo cambia el texto, el presupuesto o la ubicación; y cuando está por vencer o venció podés renovarlo una cantidad limitada de veces.', 30),
('Para Buscadores', 'Perdí el acceso a mi pedido, ¿qué hago?',
 'En el inicio de sesión tocá «¿Perdiste el acceso a tu pedido?» e ingresá tu correo. Si tenés pedidos activos, te mandamos un enlace de un solo uso que abre la sesión directamente en ellos.', 40),
('Para Buscadores', '¿Cómo califico a un Profesional?',
 'Cuando termina el trabajo, el Profesional te manda por WhatsApp un enlace de calificación. Lo abrís desde el navegador, sin instalar nada, elegís las estrellas y dejás un comentario. Cada enlace sirve una sola vez.', 50),

-- Para Profesionales
('Para Profesionales', '¿Por qué tengo que subir mi DNI y una selfie?',
 'Para que los Buscadores confíen en vos. El equipo de Laburito revisa las fotos, aprueba tu cuenta y las elimina del servidor apenas resuelve. Si la rechaza, te avisamos el motivo para que vuelvas a cargarlas.', 10),
('Para Profesionales', '¿Cómo recibo avisos de pedidos?',
 'Configurá tu zona de cobertura, tus oficios y tus horarios desde Mi Perfil, y dejá activada la disponibilidad. Cuando se publica un pedido de tu oficio dentro de tu zona, te llega una notificación al celular.', 20),
('Para Profesionales', '¿Cómo comparto mi perfil?',
 'Desde Mi Perfil, «Compartir mi perfil» genera un enlace público con tus datos, tu portafolio y tus reseñas. Cualquiera lo abre en el navegador, sin cuenta.', 30),
('Para Profesionales', 'Recibí una reseña falsa u ofensiva, ¿qué hago?',
 'Entrá a Mi Perfil → «Mis reseñas» y tocá «Reportar» en esa reseña. El equipo la revisa: si no cumple las normas, deja de mostrarse y tu promedio se recalcula.', 40),

-- Tokens y pagos
('Tokens y pagos', '¿Cómo compro tokens?',
 'En la billetera de la app elegí un pack y pagá con Mercado Pago. Los tokens se acreditan automáticamente cuando el pago se aprueba, y podés descargar el comprobante desde el historial.', 10),
('Tokens y pagos', '¿Qué pasa si desbloqueo dos veces el mismo pedido?',
 'Nada: un contacto se paga una sola vez. Si volvés a abrirlo, no se descuenta otro token.', 20),
('Tokens y pagos', 'Tengo un cupón, ¿dónde lo uso?',
 'En la billetera, «Canjear cupón». Ingresá el código y los tokens se suman a tu saldo. Cada cupón tiene vencimiento y una cantidad máxima de usos.', 30),

-- Cuenta y seguridad
('Cuenta y seguridad', 'Me olvidé la contraseña',
 'En el inicio de sesión tocá «¿Olvidaste tu contraseña?». Te mandamos un código para crear una nueva; al cambiarla, se cierran las sesiones abiertas en otros dispositivos.', 10),
('Cuenta y seguridad', '¿Cómo reporto a un usuario?',
 'El Buscador reporta desde el perfil público del Profesional y el Profesional desde el detalle del pedido. Elegí el motivo y contá qué pasó: el equipo de Laburito lo revisa y te avisa el resultado.', 20),
('Cuenta y seguridad', 'Mi cuenta fue suspendida, ¿puedo apelar?',
 'Al iniciar sesión vas a ver el motivo de la suspensión y, si la sanción lo admite, el botón «Apelar sanción». Escribí tu descargo y te damos un número de trámite. Si la sanción no admite apelación, escribí a legales@laburito.com.ar.', 30),
('Cuenta y seguridad', '¿Cómo doy de baja mi cuenta?',
 'Desde Mi Perfil → «Dar de baja la cuenta». Se borran tus datos personales y tus archivos; el historial de los pedidos se conserva sin tus datos, y tu correo queda libre para registrarte de nuevo.', 40);
