# Mercado Pago — puesta en marcha del CU-31 y el CU-32

> Lo único que el código no puede hacer solo: crear la aplicación de Mercado Pago,
> las cuentas de prueba y cargar las dos claves en Supabase. Todo lo demás —las
> tablas, la preferencia de pago, el webhook, la acreditación— está en el repo.
>
> **Tiempo estimado: 25 minutos.** No se opera con dinero real en ningún paso
> (decisión del 05/08: Mercado Pago solo en entorno de desarrollo).

---

## Antes de empezar

| Qué | Para qué |
|---|---|
| Tu cuenta de Mercado Pago (la personal está bien) | Crear la aplicación y las cuentas de prueba |
| Una ventana de incógnito | Entrar con las cuentas de prueba sin cerrar tu sesión |
| Supabase CLI logueada (`supabase projects list` muestra `laburito`) | Cargar los secretos |

Datos del proyecto que vas a copiar y pegar:

- **Proyecto de Supabase:** `xbgwogitgzzxmoixqfjd`
- **URL del webhook:** `https://xbgwogitgzzxmoixqfjd.supabase.co/functions/v1/webhook_mercadopago`

**Ninguna clave va al repo ni al chat.** Viven solamente como secretos de las Edge
Functions. La app Flutter no ve nunca el Access Token: la preferencia la crea el
servidor.

---

## Paso 1 — Crear la aplicación

1. Entrá a <https://www.mercadopago.com.ar/developers/panel/app> con tu cuenta.
2. **Crear aplicación**:
   - Nombre: `Laburito`
   - Tipo de solución: **Pagos online**
   - ¿Usás una plataforma de e-commerce?: **No**
   - Producto: **Checkout Pro**
3. Aceptá y creá. Vas a caer en el panel de la aplicación.

## Paso 2 — Crear las dos cuentas de prueba

En el panel de la aplicación, menú **Cuentas de prueba** → **Crear cuenta de prueba**, dos veces:

| Cuenta | Descripción | País | Dinero disponible |
|---|---|---|---|
| Vendedor | `Laburito vendedor` | Argentina | 0 |
| Comprador | `Laburito comprador` | Argentina | 100000 |

Anotá en un lugar seguro (no en el repo) el **usuario** y la **contraseña** de cada
una. Si Mercado Pago pide un código por correo al entrar con una cuenta de prueba,
son los **últimos 6 dígitos del ID de usuario** de esa cuenta (o el código que
figura en la misma tabla).

> ¿Por qué dos cuentas? Mercado Pago no deja pagarse a uno mismo: quien cobra (la
> plataforma) y quien paga (el Profesional) tienen que ser usuarios distintos, y los
> dos de prueba para que el circuito sea idéntico al real sin mover plata.

## Paso 3 — Las credenciales del vendedor

1. Abrí una **ventana de incógnito** y entrá a
   <https://www.mercadopago.com.ar/developers/panel/app> con el usuario del
   **vendedor de prueba**.
2. Creá ahí también una aplicación (`Laburito`, Pagos online, Checkout Pro), igual
   que en el paso 1.
3. En esa aplicación: **Credenciales de producción** → activalas (pide rubro: elegí
   *Servicios*; sitio web: podés poner `https://laburito.com.ar`).
4. Copiá el **Access Token** (empieza con `APP_USR-`).

> Son credenciales «de producción» **de una cuenta de prueba**: es la forma que
> Mercado Pago recomienda hoy para probar Checkout Pro. Cobran con tarjetas de
> prueba y nunca con dinero real.

## Paso 4 — Configurar el webhook

Siempre con el vendedor de prueba, en la aplicación del paso 3:

1. Menú **Webhooks** → **Configurar notificaciones**.
2. **Modo productivo** → URL:
   `https://xbgwogitgzzxmoixqfjd.supabase.co/functions/v1/webhook_mercadopago`
3. Eventos: marcá solamente **Pagos**.
4. **Guardar**. Aparece la **clave secreta** (botón para revelarla): copiala.

## Paso 5 — Cargar los secretos en Supabase

Desde la raíz del repo, reemplazando los dos valores:

```bash
supabase secrets set --project-ref xbgwogitgzzxmoixqfjd MP_ACCESS_TOKEN=APP_USR-xxxx MP_WEBHOOK_SECRET=xxxx
```

Comprobá que quedaron (muestra los nombres, no los valores):

```bash
supabase secrets list --project-ref xbgwogitgzzxmoixqfjd
```

Avisame cuando esté: con eso despliego (o redespliego) las funciones y hacemos la
prueba de punta a punta.

## Paso 6 — Pagar con el comprador de prueba

En el teléfono o en el navegador donde se abra el checkout, **iniciá sesión en
Mercado Pago con el comprador de prueba** (nunca con tu cuenta real). Pagá con una
de las tarjetas de prueba publicadas por Mercado Pago:

| Tarjeta | Número | CVV | Vencimiento |
|---|---|---|---|
| Mastercard | 5031 7557 3453 0604 | 123 | 11/30 |
| Visa | 4509 9535 6623 3704 | 123 | 11/30 |

El **nombre del titular** decide el resultado:

| Titular | Resultado |
|---|---|
| `APRO` | Pago aprobado → se acreditan los tokens |
| `OTHE` | Rechazado por error general |
| `FUND` | Rechazado por monto insuficiente |
| `CONT` | Pendiente de pago |

Documento: DNI `12345678`.

---

## Si algo no anda

| Síntoma | Qué mirar |
|---|---|
| «Los pagos no están disponibles» al tocar «Pagar» | Falta `MP_ACCESS_TOKEN` o es de otra cuenta. `supabase secrets list` |
| El pago se aprueba pero los tokens no llegan | Desde el 01/10 la app concilia sola al volver del checkout, y en el detalle de un pago pendiente está **Consultar a Mercado Pago**. Para la causa de fondo: Supabase → Edge Functions → `webhook_mercadopago` → Logs, buscando `[webhook]`. `FIRMA INVÁLIDA` = la clave del webhook no coincide con la del paso 4; si no aparece ninguna línea, Mercado Pago no está llamando a la URL |
| Mercado Pago dice que no podés pagarte a vos mismo | Estás logueado en el checkout con el vendedor o con tu cuenta real: entrá con el comprador |
| El checkout pide un código de verificación | Últimos 6 dígitos del ID del usuario de prueba |
