# Guía de interfaz — Laburito

> Traduce el **ANEXO UI — Interfaces de usuario** (ERS v0.2.0) a reglas que se
> pueden verificar en el código. Si una pantalla nueva no cumple algo de acá, es
> la pantalla la que está mal, no la guía.

Última actualización: 19/08/2026 · Aplicado sobre el código del Sprint 1.

---

## 1. Dónde viven los estilos

| Archivo | Qué define |
|---|---|
| `lib/app/colores.dart` | **Los tokens.** Todos los colores y las medidas repetidas de la app |
| `lib/app/theme.dart` | El `ThemeData` único, armado con esos tokens |
| `lib/core/widgets/marca_laburito.dart` | Logo, encabezado de marca, tarjetas y avisos |
| `lib/core/widgets/boton_principal.dart` | El botón de acción principal, con su estado de carga |
| `lib/core/widgets/campo_texto.dart` | El campo de formulario con la etiqueta arriba |
| `lib/core/widgets/barra_navegacion.dart` | La barra inferior: Tablero, Billetera y Perfil |
| `lib/features/categorias/presentation/selector_oficios.dart` | Las píldoras de oficio, compartidas por el alta y el perfil |
| `assets/logo/` | El PNG del logotipo (ver el README de esa carpeta) |

**Regla base: ninguna pantalla escribe un color literal.** Nada de
`Color(0xFF...)` ni `Colors.black54` fuera de `colores.dart`. Si hace falta un
color nuevo, se agrega ahí con nombre y recién después se usa.

---

## 1 bis. Las dos superficies

Un solo proyecto Flutter sirve las dos interfaces del Anexo. Quién es quién lo
decide `lib/core/config/superficie.dart`, y **solo ese archivo mira la
plataforma**: las pantallas preguntan por intención, nunca por `kIsWeb`.

| | App nativa | Web |
|---|---|---|
| Usuario | Profesional | Buscador (y alta de Profesional) |
| Figuras | 3.8 a 3.19 | 3.1 a 3.7 |
| Alta | Siempre Profesional, sin selector de rol | Selector de rol dentro de la tarjeta (Fig. 3.1) |
| Navegación | Barra inferior: Tablero · Billetera · Perfil | Barra superior de la marca |

```dart
Entorno.permiteAltaDeBuscador  // solo web
Entorno.usaBarraInferior       // solo app nativa
```

En móvil el router desvía `/registro` a `/registro/profesional` antes de
construir nada, así que la pantalla de alta de Buscador no se alcanza. En la web
las dos altas muestran el selector y se puede ir de una a la otra sin perder la
pantalla.

### El login no saluda

Ni «Bienvenido» ni «Bienvenido de nuevo»: el encabezado es el logotipo con el
nombre, como en la mayoría de las apps. Dos motivos, y los dos son de fondo:

1. **«De nuevo» es falso la mitad de las veces.** Al login llega tanto quien
   vuelve como quien entra por primera vez — el enlace a «Registrate» está en
   esa misma pantalla.
2. **«Bienvenido» está en masculino.** A Laura González la trataría de varón, y
   en el login todavía no se sabe nada de quien entra. Un saludo que hay que
   adivinar es peor que no saludar.

Vale para cualquier texto que se le dirija a la persona antes de conocerla.

**El texto también cambia con la superficie.** El login es la misma pantalla en
las dos, pero la bajada de la Figura 3.8 —«Ingresá para recibir trabajos cerca
tuyo»— es del Profesional: en la web el que entra es el Buscador, que publica
pedidos en vez de recibirlos. Cuando una pantalla se comparte, revisá que el
texto no dé por sentado el rol.

> Limitación conocida: `Entorno` lee `kIsWeb` y no se puede sustituir en una
> prueba, así que lo específico de cada superficie se verifica a mano. Si crece,
> conviene volverlo inyectable.

## 2. Paleta

| Token | Valor | Dónde se usa |
|---|---|---|
| `Colores.azul` | `#1B3B6F` | Logotipo, títulos, chips de oficio elegidos, barra del panel Admin |
| `Colores.azulMedio` | `#1E63C4` | Enlaces, foco de los campos, ícono del rol Buscador |
| `Colores.azulSuave` | `#E8EDF5` | Fondo de avatares e íconos |
| `Colores.naranja` | `#F2811D` | **Acción principal de cada pantalla**, rótulos de paso, avisos pendientes |
| `Colores.naranjaOscuro` | `#D96D0F` | Naranja presionado |
| `Colores.naranjaSuave` | `#FDEEDD` | Fondo de los avisos que piden una acción |
| `Colores.fondo` | `#EDF1F6` | Lienzo de todas las pantallas |
| `Colores.superficie` | `#FFFFFF` | Tarjetas, campos, hojas modales |
| `Colores.borde` | `#DCE0E6` | Borde de tarjetas y campos |
| `Colores.texto` | `#12263F` | Texto principal (no se usa negro puro) |
| `Colores.textoSecundario` | `#5A6B7F` | Descripciones, ayudas, etiquetas de dato |
| `Colores.textoTenue` | `#90A0B0` | Notas al pie, íconos inactivos |
| `Colores.exito` | `#2E7D32` | Confirmaciones, documento cargado, revisión en curso |
| `Colores.error` | `#C62828` | Errores y acciones destructivas (CU-11) |

### Las tres reglas de color del Anexo

1. **Naranja = hacer.** Un solo botón naranja por pantalla, el que la completa:
   *Crear cuenta*, *Ingresar*, *Verificar mi correo*, *Finalizar registro*,
   *Guardar cambios*.
2. **Azul marino = marca e identidad.** Logotipo, títulos, chips de oficio
   elegidos. Nunca es un botón de acción.
3. **Azul medio = navegar.** Enlaces y foco de los campos. Nunca rellena un botón.

El rojo queda reservado a la baja de cuenta y a los mensajes de error: si aparece
en otro lado, pierde el peso que necesita en el CU-11.

---

## 3. Medidas

| Token | Valor | Uso |
|---|---|---|
| `Medidas.radio` | 12 | Campos, botones, avisos |
| `Medidas.radioGrande` | 16 | Tarjetas y opciones grandes |
| `Medidas.altoBoton` | 52 | Alto de los botones de acción |
| `Medidas.anchoFormulario` | 420 | Ancho máximo de un formulario en Web |

---

## 4. Componentes compartidos

| Widget | Para qué |
|---|---|
| `LogoLaburito` | El logotipo. Si falta el PNG, dibuja una versión de reserva |
| `MarcaLaburito` | Encabezado: logo + título de pantalla + bajada |
| `TarjetaFormulario` | Centra el contenido y lo acota a 420 px en Web |
| `TarjetaPanel` | Tarjeta blanca de borde fino |
| `AvisoEstado` | Aviso de color. Variantes `.pendiente` (naranja), `.exito` (verde) y `.riesgo` (rojo) |
| `BotonPrincipal` | Acción principal, con el indicador de carga adentro. Variante `.destructivo` |
| `CampoTexto` | Campo de formulario con la etiqueta arriba |
| `OjoPassword` | Mostrar u ocultar la contraseña |
| `SelectorOficios` | Píldoras de categoría de oficio, con el tope y el contador |
| `BarraNavegacion` | Barra inferior de la app del Profesional |
| `mostrarMensaje` | SnackBar de error o confirmación |

### La barra inferior está completa aunque falten pantallas

`BarraNavegacion` trae las tres secciones del Anexo —Tablero, Billetera y
Perfil— en el home y en el perfil. El Tablero de pedidos (CU-43) es del Sprint 2
y la Billetera (CU-30) del Sprint 4: la Billetera queda visible con la insignia
«Pronto» y avisa al tocarla. Así la navegación de la demo es la definitiva y no
hay que rearmarla cuando lleguen las pantallas.

La Billetera **no se le muestra al Buscador**: los tokens son del Profesional.

`BotonPrincipal` existe para que «botón bloqueado mientras se envía, sin doble
submit» —criterio de aceptación del CU-01— sea una sola regla y no ocho copias.

### Formularios: la etiqueta va arriba

Material pone la etiqueta adentro del campo y la hace flotar al escribir. El
Anexo no: en las figuras 3.1, 3.2, 3.9 y 3.24 la etiqueta está **arriba**, en
gris oscuro y pequeña, y adentro queda el texto de ejemplo. Por eso los
formularios usan `CampoTexto` y no `TextFormField` pelado.

### Chips de oficio

Píldoras compactas, alineadas a la izquierda. Elegida = fondo azul marino,
etiqueta blanca y tilde blanca.

El color de la etiqueta va como `WidgetStateColor` dentro de
`ChipThemeData.labelStyle`. **`secondaryLabelStyle` no sirve**: solo lo usa
`ChoiceChip`. Si se define ahí, el `FilterChip` seleccionado queda con texto
oscuro sobre azul y no se lee. Está cubierto en `test/tema_test.dart`.

---

## 5. Trazabilidad con el ANEXO UI

Pantallas del Sprint 1 y la figura del Anexo que las gobierna:

| Figura | Caso de uso | Pantalla en el código |
|---|---|---|
| 3.1 Registro de Buscador | CU-01 | `auth/.../registro_screen.dart` |
| 3.3 Verificación por PIN | CU-08 | `auth/.../verificar_pin_screen.dart` |
| 3.8 Inicio de sesión | CU-03 | `auth/.../login_screen.dart` |
| 3.9 Registro de Profesional | CU-02 | `auth/.../registro_profesional_screen.dart` |
| 3.10 Validación de documentación | CU-09 | `verificacion/.../carga_documentos_screen.dart` |
| 3.17 Perfil del Profesional | CU-05 | `perfil/.../perfil_screen.dart` |

Sin figura propia en el Anexo, resueltas con la misma gramática visual:
selección de rol (previa a CU-01 / CU-02), recuperación de contraseña (CU-04, tres
pantallas), baja de cuenta (CU-11) y el home provisorio.

### Diferencias deliberadas con el Anexo

| Anexo | Implementado | Por qué |
|---|---|---|
| PIN de 4 casilleros separados (Fig. 3.3) | Un campo centrado de 6 dígitos | El OTP de Supabase es de 6 dígitos; el campo único autocompleta desde el SMS/mail y valida solo |
| «El PIN vence a los 10 minutos» (Fig. 3.3) | No se muestra el plazo | El vencimiento lo fija la consola de Supabase; no se anuncia un número que la app no controla |
| «Bienvenido de nuevo» en el login (Fig. 3.8) | El logotipo con el nombre, sin saludo | «De nuevo» no aplica a quien entra por primera vez, y «Bienvenido» está en masculino. Ver «El login no saluda» |
| Ícono de teléfono en «Ofrezco mi oficio» (Fig. 3.1) | Ícono de llave | El teléfono no comunica «ofrezco un oficio»; la llave es la metáfora del Profesional en toda la app |
| Alta del Buscador con 3 campos (Fig. 3.1) | Los 5 del CU-01: nombre, apellido, correo, teléfono y contraseña | Decisión del 19/08: manda el CU-01. El teléfono es el dato con el que el Profesional contacta al Buscador. **La Figura 3.1 hay que redibujarla** |
| Sin checkbox legal en el alta del Profesional (Fig. 3.9) | Lleva el mismo checkbox que el Buscador | El consentimiento de la Ley 25.326 no depende del rol |
| Tablero de pedidos como pantalla de inicio (Fig. 3.11) | Home provisorio con el resumen de la cuenta | El CU-43 es del Sprint 2. La barra inferior ya está y el Tablero es su primera pestaña |
| «Foto de perfil» en el alta del Profesional (Fig. 3.9) | El avatar se carga desde el perfil (CU-05) | Durante el alta todavía no hay sesión y las políticas del bucket `avatares` exigen `auth.uid()` |
| CTA fija abajo de la pantalla (Fig. 3.9, 3.11, 3.15) | El botón va al final del formulario | Pendiente: implica un `bottomNavigationBar` por pantalla. Se evalúa con el tablero del Sprint 2 |

---

## 6. Pendiente

- **Los PNG del logotipo.** `assets/logo/laburito.png` (completo, con el nombre) y
  `assets/logo/laburito_isotipo.png` (solo el ícono, el que usa el login).
  Mientras no estén, la app dibuja las versiones de reserva.
  Ver `assets/logo/README.md`.
- **Íconos de aplicación y favicon.** Siguen siendo los de Flutter. Se generan con
  `flutter_launcher_icons` cuando esté el PNG definitivo.
- **Tipografía.** Se usa la del sistema. El Anexo muestra una sans geométrica;
  adoptarla implica sumar la fuente al repo, y queda para cuando la UI esté cerrada.
- **Modo oscuro.** Fuera de alcance: el Anexo especifica un solo tema.
- **Barra superior de la web.** La Figura 3.1 muestra «Laburito ⬤» a la izquierda
  y «Cómo funciona · Mis pedidos · Ayuda» a la derecha. Todavía no está: las tres
  secciones son de sprints posteriores.
- **Redactar los textos legales.** `/legales/terminos` y `/legales/privacidad`
  tienen hoy un texto provisorio que describe el alcance previsto.
