# Logotipo de Laburito

Dejá acá los dos archivos, con estos nombres exactos:

| Archivo | Qué imagen va | Dónde se usa |
|---|---|---|
| `laburito.png` | Logo completo: el isotipo (pin + llave) con la palabra «Laburito» debajo — el de la portada del ERS | Alta, verificación, recuperación, barra del home |
| `laburito_isotipo.png` | Solo el ícono, en formato de ícono de app: el cuadrado azul con el pin naranja de la Figura 3.8 | Login |

- **Formato**: PNG con fondo transparente (el isotipo puede llevar su fondo azul).
- **Tamaño sugerido**: 512 × 512 px, o el alto equivalente si es apaisado.
  La app lo escala; de menos de 256 px se va a ver borroso en pantallas densas.

No hace falta tocar código: `LogoLaburito` (en
`lib/core/widgets/marca_laburito.dart`) los toma de estas rutas.

Mientras los archivos no existan, la app dibuja versiones de reserva —el
cuadrado azul con el pin, y el nombre debajo cuando corresponde—, así el
proyecto compila y se ve igual.

## Íconos de la app (pendiente)

El ícono de Android (`android/app/src/main/res/mipmap-*`), el de iOS
(`ios/Runner/Assets.xcassets/AppIcon.appiconset`) y el favicon de la Web
(`web/favicon.png`, `web/icons/`) siguen siendo los de Flutter. Se reemplazan
con `flutter_launcher_icons` cuando esté el PNG definitivo.
