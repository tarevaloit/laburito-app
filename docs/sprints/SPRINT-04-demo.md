# Sprint 4 — Guion de prueba y demo

> Es el recorrido para probar todo lo del Sprint 4 y, en el mismo orden, para
> mostrárselo al profesor. Cada paso dice qué hacer, qué tiene que pasar y qué
> caso de uso demuestra. Si un paso no da lo esperado, anotalo y avisame antes
> de seguir: los siguientes dependen del anterior.

---

## Antes de empezar

| Qué | Cómo | Estado al 01/10 |
|---|---|---|
| Profesional aprobado, disponible, con zona y oficio | `supabase/scripts/preparar_demo.sql` | ✅ |
| Cupón `DEMO10` (10 tokens) | el mismo guion | ✅ sin usar |
| Credenciales de Mercado Pago | `docs/MERCADOPAGO.md`, paso 5 | ✅ cargadas |
| **Cuenta de administrador** | `supabase/scripts/crear_admin.sql`, reemplazando `PEGAR_EL_CORREO_DEL_ADMIN` | ❌ **falta** |
| Usuario comprador de prueba de Mercado Pago | `docs/MERCADOPAGO.md`, paso 2 | lo tenés vos |

Necesitás tres sesiones a la vez:

- **Teléfono Android** con la app (`flutter run --dart-define-from-file=.env`), con la cuenta del **Profesional**.
- **Navegador** con la web (`flutter run -d chrome --dart-define-from-file=.env`), con la cuenta del **Buscador**.
- **Otra ventana del navegador** (incógnito) con la cuenta del **administrador**.

Abrí también el panel de Supabase en **Table Editor**: sirve para mostrar en vivo
que los datos quedan escritos.

---

## Recorrido

### 1. Billetera vacía — CU-30

| Hacer | Tiene que pasar |
|---|---|
| En el teléfono, tocar **Billetera** en la barra inferior | Ya no dice «Pronto». Muestra saldo **0 tokens**, los tres packs (Bronce 5 / $4.500, Plata 10 / $8.000 con −11 %, Oro 20 / $14.000 con −22 %) y «Aún no tienes movimientos en tu billetera» |
| Solapa **Historial de pagos** | El mismo vacío (flujo alterno del CU-33) |

### 2. Sin saldo no se desbloquea — CU-25, flujo alterno

| Hacer | Tiene que pasar |
|---|---|
| **Tablero** → abrir un pedido | Abajo, «Vas a usar **1 token** · no te quedan tokens». Arriba, la tarjeta **Datos del Buscador** con el nombre corto y el teléfono enmascarado (`11234 ••••••`) |
| Tocar **Desbloquear · 1 token** | Aparece «No te quedan tokens» con el botón **Comprar tokens**, que lleva a la billetera. No se cobra nada |

### 3. Canje de cupón — CU-53

| Hacer | Tiene que pasar |
|---|---|
| Billetera → **Tengo un código** → escribir `demo10` | Se escribe solo en mayúsculas |
| **Canjear ahora** | «¡Sumaste 10 tokens!» → la billetera muestra **10** y el movimiento «Cupón DEMO10 · +10» |
| Volver a canjear `DEMO10` | «Ya canjeaste este código.» |
| Probar `NOEXISTE` cinco veces seguidas | La quinta o sexta dice «Hiciste demasiados intentos…»: el bloqueo por fuerza bruta que pide la ERS. **Hacelo al final de la demo**: bloquea el canje 15 minutos |

### 4. Desbloquear el contacto — CU-25

| Hacer | Tiene que pasar |
|---|---|
| Tablero → el mismo pedido → **Desbloquear · 1 token** → **Usar 1 token** | «Listo: ya podés escribirle a…». El teléfono aparece entero y el botón pasa a **Escribir por WhatsApp** |
| Tocar **Escribir por WhatsApp** | Se abre WhatsApp con el número y un saludo que nombra el pedido |
| Volver y tocar de nuevo el pedido | Sigue desbloqueado. Saldo **9**, movimiento «Desbloqueo de contacto · −1» |
| En la **web**, como Buscador → **Mis pedidos** → ese pedido | Debajo del título: «1 Profesional pidió tu contacto y te puede escribir por WhatsApp.» (paso 6 del CU-25) |

### 5. Compra con Mercado Pago — CU-31 y CU-32

| Hacer | Tiene que pasar |
|---|---|
| Billetera → tocar **Plata** → **Ir a pagar** | Se abre el checkout de Mercado Pago por $8.000 |
| Iniciar sesión **con el comprador de prueba** y pagar con la Mastercard `5031 7557 3453 0604`, CVV `123`, vencimiento `11/30`, titular **`APRO`**, DNI `12345678` | Mercado Pago muestra el pago aprobado |
| **Volver al sitio** (o volver a la app a mano) | La app se abre en la billetera con «Esperando la confirmación…» y a los pocos segundos **«¡Pago aprobado! Se acreditaron 10 tokens»**. Saldo **19**, movimiento «Compra pack Plata · +10» |
| Repetir con titular **`FUND`** | «El pago no se completó · La tarjeta no tiene fondos suficientes. No se acreditó ningún token.» El saldo no cambia |

Lo que conviene contar acá: **los tokens no los acredita la app ni la vuelta del
checkout**. Los acredita el webhook, que valida la firma de Mercado Pago, le
pregunta a Mercado Pago por el pago y acredita una sola vez aunque el aviso llegue
repetido. Se ve en Supabase → Edge Functions → `webhook_mercadopago` → Logs.

### 6. Historial de pagos y comprobante — CU-33 y CU-19

| Hacer | Tiene que pasar |
|---|---|
| Billetera → **Historial de pagos** | El aprobado y el rechazado, del más nuevo al más viejo, con su estado en color |
| Tocar el aprobado | Fecha, monto, paquete, medio de pago y **N.º de comprobante 0001-00000001** |
| **Descargar comprobante** | Se abre el PDF con el número, los datos del Profesional, el pack y el total, y el pie que aclara que no es una factura fiscal |
| Tocar el rechazado | Muestra el motivo y no ofrece comprobante |

### 7. Panel del administrador — CU-40 y CU-52

Requiere la cuenta de administrador. Entrar en la web: el home muestra **Panel de
administración**.

| Hacer | Tiene que pasar |
|---|---|
| **Precios** → poner `0` en Plata → Guardar | «El precio tiene que ser un número entero positivo» (flujo alterno del CU-40) |
| Poner `9000` → Guardar | Pide la contraseña otra vez. Con una equivocada: «La contraseña no es correcta. No se guardó ningún cambio.» Con la correcta: «Precio actualizado.» |
| En el teléfono, recargar la billetera (deslizar hacia abajo) | Plata cuesta $9.000 y el −11 % pasa a 0, así que desaparece: la etiqueta se calcula, no está escrita |
| **Cupones** → crear `PROFE2026`, 5 tokens, vence en una semana, sin límite | Aparece en la lista: «+5 tokens · Vence … · 0/∞ usos · Activo» |
| Crear otro con el mismo código en minúsculas | «Ya existe un cupón con el código PROFE2026.» |
| En el teléfono, canjear `PROFE2026` | +5 tokens. En el panel, «1/∞ usos» |

**Volvé Plata a $8.000 al terminar**, si no querés que quede así.

### 8. Seguridad — T-09 (para contar, no hace falta tocar nada)

Lo que se cerró y cómo se comprobó (guion `supabase/scripts/verificar_0020.sql`, 16
reglas en OK contra la base):

- Un Profesional ya no puede leer la fila de un pedido ajeno con la dirección
  exacta: solo ve la versión pública, con la coordenada redondeada a unos 100 m.
- Un Profesional ya no puede cargarse tokens ni aprobarse solo con una llamada
  directa a la API. El saldo solo lo mueve una función del servidor.
- Las fotos de un pedido cerrado no se pueden agregar ni borrar.

---

## Qué se desarrolló en el Sprint 4

| ID | Caso de uso | Qué se ve |
|---|---|---|
| T-09 | Deuda de seguridad del Sprint 3 | Migración 0020 |
| T-10 | Esquema de monetización | Migración 0021: paquetes, pagos, libro de movimientos, contactos desbloqueados y cupones |
| CU-30 | Consultar Saldo de Tokens | Billetera (Figura 3.13), con el último saldo si se corta la conexión |
| CU-31 | Cargar Tokens | Checkout Pro con credenciales de prueba |
| CU-32 | Procesar Pago | Webhook como Edge Function, con firma y consulta a la API |
| CU-33 | Ver Historial de Pagos | Solapa del historial y detalle de cada pago |
| CU-25 | Postularse (Desbloquear Contacto) | Detalle del pedido (Figura 3.12) y WhatsApp |
| CU-40 | Configurar Precio de Tokens | Panel de administración, con contraseña |
| CU-52 | Crear Cupón Promocional | Panel de administración (Figura 3.24) |
| CU-53 | Canjear Cupón de Tokens | Billetera (Figura 3.19), con bloqueo por fuerza bruta |
| CU-19 | Descargar Comprobante | PDF emitido por la plataforma |

Números del sprint: 7 migraciones (0020 a 0026) verificadas con 51 reglas contra la
base, 4 Edge Functions nuevas, 307 pruebas automáticas en verde (34 nuevas) y los
builds de web y Android compilando.

Decisiones que vale la pena contar si preguntan:

- **El precio nunca sale del teléfono.** La app manda solo qué pack quiere; el monto
  lo pone el servidor. Si no, cualquiera se compraría 20 tokens a un peso.
- **El saldo es un libro contable.** Cada token que entra o sale es un movimiento
  con el saldo que dejó; el número grande es su suma. Por eso el historial y el
  comprobante son un registro y no una reconstrucción.
- **El comprobante no es una factura de AFIP**: es un desvío respecto de la ERS, ya
  acotado en el PT 5.0, porque el entorno es de prueba y no hay CUIT ni punto de venta.
- **Desbloquear dos veces no cobra dos veces**, y un contacto pagado se sigue viendo
  aunque el Buscador cierre el pedido.

---

## Si algo falla

| Síntoma | Dónde mirar |
|---|---|
| «Los pagos no están disponibles» | `supabase secrets list`: tienen que estar `MP_ACCESS_TOKEN` y `MP_WEBHOOK_SECRET` |
| Pagaste y los tokens no llegan | Logs de `webhook_mercadopago`. «Firma inválida» = el `MP_WEBHOOK_SECRET` no es la clave del webhook de la aplicación del vendedor de prueba |
| Mercado Pago dice que no podés pagarte a vos mismo | Estás logueado en el checkout con el vendedor o con tu cuenta real |
| «Tu cuenta tiene que estar verificada…» al desbloquear | El Profesional no está aprobado: correr `preparar_demo.sql` |
| No aparece «Panel de administración» | Falta `crear_admin.sql`, o hay que cerrar sesión y volver a entrar |
| El canje dice «demasiados intentos» | Esperar 15 minutos (es el bloqueo por fuerza bruta) |
