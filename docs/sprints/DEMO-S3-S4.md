# Presentación — Sprint 3 y Sprint 4

> Guion para mostrarle al profesor los dos sprints en una sola presentación, porque
> la reunión del Sprint 3 no se hizo. Cuenta **una sola historia**: el Profesional
> arma su perfil, un Buscador publica un pedido, al Profesional le llega la alerta
> (Sprint 3), y con un token desbloquea el contacto y le escribe (Sprint 4). El
> mismo pedido recorre toda la demo.
>
> Duración estimada: **20 minutos** de demo más preguntas. Cada paso tiene qué
> hacer, qué decir y qué caso de uso cierra.

---

## Antes de la reunión (30 minutos antes)

| # | Qué | Por qué |
|---|---|---|
| 1 | **Hacer una compra de prueba completa** (Pack Bronce, comprador de prueba, titular `APRO`) y confirmar que los tokens llegan | Hoy hay un pago de Oro que quedó **pendiente**, sin respuesta de Mercado Pago. Si se pagó y no se acreditó, el webhook no lo procesó: mirar Supabase → Edge Functions → `webhook_mercadopago` → **Logs** y avisarme. Si nunca se terminó de pagar, no pasa nada |
| 2 | **Crear la cuenta de administrador**: `supabase/scripts/crear_admin.sql` con el correo real de una cuenta aparte, ya validada | Hoy no hay ningún administrador. Sin eso no se puede mostrar el CU-40 ni el CU-52 |
| 3 | Correr `supabase/scripts/preparar_demo.sql` | Deja al Profesional aprobado y disponible, con pedidos vigentes en el tablero y el cupón `DEMO10` |
| 4 | En el teléfono, iniciar sesión con el **Profesional** (`profesional@laburito.test`) y aceptar las notificaciones | Es el único dispositivo registrado para las alertas |
| 5 | **Gastar los tokens que compraste en el paso 1** desbloqueando un pedido que **no** vayas a usar en la demo, o dejarlos y decirlo | La demo arranca mostrando «sin saldo no se desbloquea». Si preferís no gastarlos, salteá el paso 9 |
| 6 | Dejar abiertos: el **teléfono** (o el emulador con `-gpu host`), la **web** como Buscador, una **ventana de incógnito** como administrador y el **panel de Supabase** en Table Editor | Para no perder tiempo iniciando sesiones durante la demo |
| 7 | Tener a mano los datos de la tarjeta de prueba: Mastercard `5031 7557 3453 0604`, CVV `123`, vencimiento `11/30`, titular `APRO`, DNI `12345678` | |

**Plan B:** si algo externo falla (Firebase o Mercado Pago), no se improvisa: se
dice qué pasó y se sigue con el paso siguiente. Al final del documento hay qué
mostrar en cada caso.

---

## 0. Apertura (1 minuto)

**Decir:** «El Sprint 3 se cerró con los 56 puntos comprometidos y el Sprint 4 con
el circuito de pago completo. Les muestro los dos juntos, porque son una sola
historia: el Profesional recibe un trabajo y paga por el contacto».

Si hay proyector, mostrar el burndown de `docs/sprints/figuras/burndown-sprint-03.png`.

---

## Parte 1 — Sprint 3: el lado del Profesional (8 minutos)

Todo en el **teléfono**, con el Profesional.

### 1. El perfil de trabajo (CU-12, CU-07, CU-44, CU-06)

| Paso | Hacer | Decir |
|---|---|---|
| 1 | Home → **Editar mi perfil** → oficios | «Elige hasta 5 oficios. Se guardan en una sola operación del servidor: antes, si fallaba a mitad de camino, el Profesional se quedaba sin oficios y dejaba de recibir alertas sin enterarse» (CU-12) |
| 2 | **Zona de cobertura** | «El centro se elige con el mismo selector de mapa del Sprint 2 y el radio va de 1 a 100 km. Es lo que se compara contra la ubicación del pedido» (CU-07) |
| 3 | **Horarios y disponibilidad** → mostrar el interruptor | «Si apaga la disponibilidad, deja de recibir alertas. Los horarios son información para el Buscador, no filtran: un pedido de las 23 lo puede tomar a la mañana» (CU-44) |
| 4 | **Mi portafolio** → agregar una foto | «Hasta 10 fotos de trabajos. El tope lo controla la base, con bloqueo, para que dos subidas a la vez no lo pasen» (CU-06) |

### 2. El tablero (CU-43, CU-22, CU-24, CU-23)

| Paso | Hacer | Decir |
|---|---|---|
| 5 | **Tablero** | «Los pedidos vigentes, ordenados por distancia a su zona. La distancia se calcula en el servidor con PostGIS y se redondea a 100 m, para que no se pueda triangular el domicilio del Buscador» (CU-43) |
| 6 | Abrir un pedido | «El detalle muestra la ubicación **aproximada**. La dirección exacta nunca llega al teléfono del Profesional» (CU-22) |
| 7 | Guardar uno (marcador) e ignorar otro → **Deshacer** | «Guardar lo pasa a una solapa; ignorar lo saca del tablero y ofrece deshacer, porque es la única acción que hace desaparecer algo» (CU-24, CU-23) |

### 3. El circuito central: publicar → alerta (CU-21, CU-17)

| Paso | Hacer | Decir |
|---|---|---|
| 8 | En la **web**, como Buscador → **Publicar un pedido**: oficio **Plomería**, una dirección en **José C. Paz o San Miguel**, título «Pérdida bajo la pileta de la cocina» → Publicar | «El Buscador publica desde la web, sin instalar nada» |
| — | Mostrar el **teléfono** | **Llega la notificación.** «El servidor decide a quién avisarle: zona que contiene al pedido, oficio que coincide, cuenta aprobada y disponible. La app no elige destinatarios» (CU-21) |
| — | Tocar la notificación | Abre el detalle del pedido nuevo, encima del tablero |
| — | En la web → **Mis pedidos** | «El historial del Buscador, con grupos, búsqueda y scroll infinito» (CU-17, replanificado del Sprint 2) |

**Ese pedido es el que se usa en toda la Parte 2.**

---

## Parte 2 — Sprint 4: la monetización (9 minutos)

### 4. Sin tokens no hay contacto (CU-25, flujo alterno)

| Paso | Hacer | Decir |
|---|---|---|
| 9 | En el detalle del pedido nuevo, señalar la tarjeta **Datos del Buscador** | «Ve el nombre y el teléfono enmascarado. El número entero no viaja hasta que paga» |
| — | Tocar **Desbloquear · 1 token** | Aparece «No te quedan tokens» con **Comprar tokens**. «No se cobra nada y lo lleva a la billetera» |

### 5. La billetera y el cupón (CU-30, CU-53)

| Paso | Hacer | Decir |
|---|---|---|
| 10 | **Billetera** (barra inferior) | «Saldo, los tres packs con su ahorro calculado, y los últimos movimientos» (CU-30) |
| 11 | **Tengo un código** → `demo10` → **Canjear ahora** | «+10 tokens. Cada código se usa una vez por Profesional y hay bloqueo si alguien prueba códigos al azar» (CU-53) |

### 6. Desbloquear y contactar (CU-25)

| Paso | Hacer | Decir |
|---|---|---|
| 12 | Volver al pedido → **Desbloquear · 1 token** → **Usar 1 token** | Aparece el teléfono entero. «Se descontó un token; si lo vuelve a tocar, no se cobra de nuevo» |
| 13 | **Escribir por WhatsApp** | Se abre WhatsApp con el número y un saludo que nombra el pedido. «El contacto sigue fuera de la plataforma, como dice la ERS» |
| 14 | En la **web**, recargar el detalle del pedido | «1 Profesional pidió tu contacto y te puede escribir por WhatsApp» (paso 6 del CU-25) |

### 7. Comprar con Mercado Pago (CU-31, CU-32)

| Paso | Hacer | Decir |
|---|---|---|
| 15 | Billetera → **Bronce** → **Ir a pagar** | «La app solo dice qué pack quiere. El precio lo pone el servidor; si no, cualquiera se compraría 20 tokens a un peso» (CU-31) |
| 16 | Pagar con el comprador de prueba y la tarjeta `APRO` | |
| 17 | **Volver al sitio** | «Esperando confirmación» y a los segundos **«¡Pago aprobado!»**. «Los tokens no los acredita la app: los acredita el webhook, que valida la firma de Mercado Pago, le pregunta a Mercado Pago por el pago y acredita una sola vez aunque el aviso llegue repetido» (CU-32) |
| — | Panel de Supabase → tabla `movimientos_tokens` | «Cada token que entra o sale es un movimiento con el saldo que dejó: el saldo es la suma de un libro» |

### 8. Historial y comprobante (CU-33, CU-19)

| Paso | Hacer | Decir |
|---|---|---|
| 18 | Billetera → **Historial de pagos** → tocar el aprobado | Fecha, monto, medio de pago y número de comprobante (CU-33) |
| 19 | **Descargar comprobante** | El PDF. «Es un comprobante de la plataforma, no una factura de AFIP: el entorno es de prueba y así lo acotó el PT 5.0» (CU-19) |

### 9. El administrador (CU-40, CU-52)

En la **ventana de incógnito**, como administrador → **Panel de administración**.

| Paso | Hacer | Decir |
|---|---|---|
| 20 | **Precios** → Bronce en `0` → Guardar | «Un precio tiene que ser un entero positivo» (flujo alterno del CU-40) |
| 21 | Bronce en `5000` → Guardar → poner la contraseña | «Es una operación crítica: pide la contraseña otra vez». Recargar la billetera en el teléfono: Bronce a $5.000, y cambian los porcentajes de ahorro de los otros packs (CU-40) |
| 22 | **Cupones** → crear `PROFE2026`, 5 tokens, vence en una semana | Aparece activo con «0/∞ usos» (CU-52) |
| 23 | En el teléfono, canjear `PROFE2026` | +5 tokens. En el panel, «1/∞ usos» |

**Después de la demo, volver Bronce a $4.500.**

---

## Cierre (1 minuto): lo que no se ve en pantalla

**Decir:**

- **Seguridad (T-08, T-09).** Se cerraron dos agujeros que quedaban del Sprint 3
  antes de habilitar el contacto: la dirección exacta de un pedido se podía leer
  con una llamada directa a la API, y un Profesional podía cargarse tokens o
  aprobarse solo. Cada regla se comprobó contra la base con un guion: 51 reglas en
  OK.
- **Calidad.** 307 pruebas automáticas (163 al cerrar el Sprint 2, 273 al cerrar el
  Sprint 3). Cada migración se ensaya y se verifica contra la base antes de
  construir encima.
- **Problemas reales.** En el Sprint 3, la alerta no salía desde la web (CORS) y se
  descubrió recién con un teléfono real. En el Sprint 4, la base se pausó por
  inactividad del plan gratuito, que es justamente un riesgo anotado en la
  planificación.

---

## Plan B

| Si pasa esto | Hacer esto |
|---|---|
| La notificación no llega en el paso 8 | «Es un servicio externo; el pedido igual está publicado». Abrir el **Tablero**: el pedido nuevo aparece primero, por distancia. Revisar después que el Profesional esté disponible y que la dirección caiga dentro de los 49 km de José C. Paz |
| Mercado Pago no abre o el pago no se acredita | Mostrar el pago aprobado de la compra que hiciste antes de la reunión: historial, comprobante y la tabla `pagos` en Supabase |
| WhatsApp no está instalado (emulador) | Se abre la página de `wa.me` en el navegador: alcanza para mostrar que el número y el mensaje están armados |
| `DEMO10` dice «Ya canjeaste este código» | Crear un cupón nuevo desde el panel (paso 22) y canjear ese |
| El canje dice «demasiados intentos» | Esperar 15 minutos o usar otro Profesional. No probar códigos falsos antes de la demo |

---

## Casos de uso que se muestran

| Sprint | Casos de uso |
|---|---|
| 3 (56 pts) | CU-17, CU-07, CU-12, CU-21, CU-43, CU-22, CU-23, CU-24, CU-44, CU-06 · T-06, T-07, T-08 (no visibles: pruebas y esquema) |
| 4 (53 pts) | CU-30, CU-31, CU-32, CU-33, CU-25, CU-40, CU-52, CU-53, CU-19 · T-09, T-10 (no visibles: seguridad y esquema) |
