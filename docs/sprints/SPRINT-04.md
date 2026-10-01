# SPRINT 04 — Monetización (PT 5.0)

> Plan de ejecución del sprint. Vive en `docs/sprints/SPRINT-04.md`.
> Se deriva del apartado 4.4 de la planificación y de los ajustes del apartado 7.3.7.
> Última actualización: 29/09/2026

---

## 1. Encuadre

| Campo | Valor |
|---|---|
| Paquete de trabajo | PT 5.0 |
| Período | 17/09/2026 al 30/09/2026 |
| Entrega por BB | 30/09/2026 hasta las 23:59 |
| Reunión | 01/10/2026 |
| Release objetivo | v0.4.0 — modelo de negocio operativo sobre el entorno de prueba de Mercado Pago. Coincide con el 2º parcial (mínimo exigido: 50 %) |
| Rama | `sprint-4`, salida de `main` después del cierre del Sprint 3 (`v0.3.1`) |
| Remanente al inicio | 119 puntos |
| Requerimientos cubiertos | RF04, RF11 |

**Objetivo del sprint (apartado 4.4).** Poner en funcionamiento la billetera de tokens y
la pasarela de pago —el núcleo del modelo de negocio—, con la acreditación automática y
el desbloqueo efectivo del contacto, demostrado contra el entorno de prueba de Mercado Pago.

**Punto de partida real.** El trabajo del sprint arranca el 29/09: el período entre el 17/09
y el 28/09 no tuvo ejecución. Se sostiene el compromiso completo y se fija de antemano el
orden de descarte, con dos puntos de control sobre el día que queda.

---

## 2. Compromiso del sprint: 53 puntos

| Origen | Pts |
|---|---|
| Alcance planificado del PT 5.0 (apartado 4.4) | 50 |
| Deuda de seguridad arrastrada del Sprint 3 (apartado 7.3.3), con estimación propia | 3 |
| **Total** | **53** |

### 2.1 Alcance

Estados: `⬜ pendiente` · `🟡 en curso` · `✅ hecho` · `⏭️ replanificado`

| ID | Tarea / Caso de Uso | Tipo | Pts | Estado | Evidencia |
|---|---|---|---|---|---|
| T-09 | Deuda de seguridad: ubicación exacta legible por la API, columnas sensibles del Profesional y fotos de pedidos cerrados | Backend | 3 | ✅ | `1622cc8` |
| T-10 | Esquema de monetización con sus políticas RLS (infraestructura) | Backend | — | ✅ | `71113e9` |
| CU-30 | Consultar Saldo de Tokens | Frontend | 3 | ✅ | `b23ba1c` |
| CU-31 | Cargar Tokens (Mercado Pago Checkout Pro con credenciales de prueba) | Full-stack | 12 | ✅ | `3f6fba0`, `b23ba1c` |
| CU-32 | Procesar Pago (webhook como Edge Function de Supabase) | Backend | 10 | ✅ | `3f6fba0`, `b23ba1c` |
| CU-33 | Ver Historial de Pagos | Full-stack | 4 | ✅ | `b23ba1c` |
| CU-25 | Postularse (Desbloquear Contacto) | Full-stack | 6 | ✅ | `2868316` |
| CU-40 | Configurar Precio de Tokens | Full-stack | 3 | ✅ | `c845fcb` |
| CU-52 | Crear Cupón Promocional | Full-stack | 4 | ✅ | `c845fcb` |
| CU-53 | Canjear Cupón de Tokens | Full-stack | 4 | ✅ | `a92d0fe`, `b23ba1c` |
| CU-19 | Descargar Comprobante de Tokens (emitido por la plataforma) | Backend | 4 | ✅ | `7896de4`, `b23ba1c` |
| | **Total** | | **53** | | |

**Cerrado el 01/10: 53 de 53 puntos.** Probado de punta a punta con el entorno de prueba de
Mercado Pago, tag `v0.4.0`. Sección 7.4 en `SPRINT-04-cierre.md` y `.docx`.

**Estado al 01/10 (antes del cierre).** Base restaurada: migraciones 0020 a 0026 aplicadas con sus guiones
en OK (51 reglas) y las cuatro Edge Functions desplegadas. La T-09 y la T-10 quedan
cerradas. El resto sigue 🟡 hasta la prueba en el teléfono (ajuste 3 del 7.3.7); el
CU-31 y el CU-32 además esperan las credenciales de Mercado Pago.

**Estado al 29/09, 23:59.** Todo el alcance está escrito y commiteado, con 307 pruebas
en verde y los builds de web y Android compilando. Nada está cerrado todavía: 🟡
significa escrito y probado sin base, porque el proyecto de Supabase quedó pausado
por inactividad y ninguna migración pudo aplicarse. Un ítem pasa a ✅ cuando su
migración está aplicada con el guion en OK y, para el CU-31 y el CU-32, cuando se vio
un pago de prueba acreditado en un teléfono.

La T-10 no lleva puntos, con el criterio de la T-07: es la infraestructura sin la cual los
casos de uso no existen, y su esfuerzo está dentro de sus estimaciones. La T-09 sí, porque
es deuda declarada del sprint anterior.

---

## 3. Orden de ejecución

El orden respeta dependencias reales. Una fase, un commit por caso de uso.

### Fase 0 — Arranque · sin puntos
Rama `sprint-4`, este plan, `docs/MERCADOPAGO.md` (creación de la aplicación, las cuentas
de prueba vendedora y compradora, el webhook y los secretos) y `url_launcher`.

### Fase 1 — T-09 · migración 0020 · 3 pts
1. **Ubicación exacta.** Función `es_pedido_visible()` SECURITY DEFINER; con ella se
   reescriben las políticas que dependían de poder leer la fila de `pedidos` (fotos, bucket,
   marcas del Profesional). Se borra «pedidos: lectura de publicados vigentes» y la vista
   `pedidos_publicos` pasa a ejecutarse con los permisos de su dueño, con el filtro adentro.
2. **Columnas del Profesional.** Disparador `BEFORE UPDATE` del patrón de la 0008: el dueño
   solo escribe `descripcion`, `dni` y `disponible`. El saldo se mueve con una compuerta que
   abre únicamente la función del libro de movimientos (T-10).
3. **Fotos de pedidos cerrados.** Alta y baja de fotos solo con el pedido publicado o pausado.

### Fase 2 — T-10 · migración 0021 · infraestructura
Paquetes de tokens (semilla de la Figura 3.13), pagos, libro de movimientos, contactos
desbloqueados, cupones y sus canjes. Una única función acredita o debita, bloqueando la fila
del Profesional; ningún cliente la puede ejecutar.

### Fase 3 — CU-30 Consultar Saldo · 3 pts
Billetera en `/profesional/billetera` (Figura 3.13). Sin conexión, último saldo conocido.

### Fase 4 — CU-31 Cargar Tokens · 12 pts
Edge Function `crear_preferencia_pago`: el precio sale de la base, nunca del cliente. El
checkout se abre fuera de la app y a la vuelta se relee el pago.

### Fase 5 — CU-32 Procesar Pago · 10 pts
Edge Function `webhook_mercadopago`: valida la firma, consulta el pago a Mercado Pago y
acredita en una función idempotente. **Se da por cerrado con el pago visto en un teléfono.**

### Fase 6 — CU-33 Ver Historial de Pagos · 4 pts
### Fase 7 — CU-25 Desbloquear Contacto · 6 pts
Consume un token, revela el teléfono y abre WhatsApp. Si ya estaba desbloqueado, no cobra.
### Fase 8 — CU-40 Configurar Precio · 3 pts
Primera pantalla de administrador, dentro de la misma app. Pide la contraseña otra vez.
### Fase 9 — CU-52 Crear Cupón · 4 pts
### Fase 10 — CU-53 Canjear Cupón · 4 pts
Con bloqueo temporal ante intentos fallidos repetidos.
### Fase 11 — CU-19 Comprobante · 4 pts
PDF emitido por la plataforma. **Desvío respecto de la ERS**, que pide Factura C de AFIP:
el título del PT 5.0 ya lo acota a un comprobante propio.

### Fase 12 — Verificación y cierre
Analyze, pruebas, builds, grep de secretos, circuito completo en el teléfono, merge, tag
`v0.4.0`, `CHANGELOG.md` y apartado 7.4 con su burndown.

---

## 4. Orden de descarte

Es el del apartado 6 de la planificación, sin cambios:

| Orden | Ítem | Pts | Destino |
|---|---|---|---|
| 1º | CU-19 Comprobante | 4 | Sprint 5 |
| 2º | CU-52 y CU-53 Cupones | 8 | Sprint 5 |

No se descartan bajo ninguna circunstancia la T-09, el CU-31, el CU-32, el CU-30 ni el
CU-25: son el objetivo del sprint y lo que el release del parcial promete.

## 5. Puntos de control

| Momento | Qué se contrasta | Corrección si no se cumple |
|---|---|---|
| Al llegar las credenciales de Mercado Pago | Fases 1 a 3 cerradas | Seguir con CU-25 y CU-40, que no dependen de Mercado Pago |
| Tarde del 30/09 | CU-32 probado de punta a punta en el teléfono | Se descarta el CU-19 |
| Antes del cierre documental | CU-33 y CU-25 cerrados | Se descartan los cupones |

## 6. Convención de commits

```
fix(T-09): cerrar la lectura de la ubicación exacta por la API
feat(T-10): esquema de monetización con sus políticas
feat(CU-31): cargar tokens con Mercado Pago Checkout Pro
docs(S4): completar el apartado 7.4 del documento vivo
```
