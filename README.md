# Singularity — Tema SDDM (agujero negro en tiempo real) para Arch + Hyprland

Pantalla de login con un **agujero negro gravitacional renderizado en vivo con un
*fragment shader* GLSL**: disco de acreción incandescente, campo de estrellas
curvado por lente gravitacional, anillo de fotones y horizonte de sucesos. La
izquierda es una **consola de control** (reloj, panel de acceso, telemetría); la
derecha, un **ventanal** hacia la singularidad. Tema QML para **SDDM** (Qt5).

![Singularity en sddm-greeter --test-mode](docs/screenshots/singularity.png)

> Captura real del greeter (`sddm-greeter --test-mode`). Para regenerarla:
> `sddm-greeter --test-mode --theme ./Singularity` y captura con `grim -o <salida>`.

← Volver al [índice de temas](https://github.com/SebasRaul2503/my-login-screen/tree/main) (rama `main`).

## Requisitos

```bash
sudo pacman -S ttf-jetbrains-mono-nerd
```

- `ttf-jetbrains-mono-nerd` → texto e íconos de la UI (JetBrainsMono Nerd Font Mono).
- **OpenGL funcional** en el greeter (cualquier driver Mesa/propietario sirve): el
  fondo es un *fragment shader*. SDDM/Qt5 ya lo usan; no instalas nada extra.

A diferencia de MatrixRain, **no** necesita fuentes CJK: todo el "arte" es procedural.

## Probar sin instalar (seguro, no toca el sistema)

```bash
sddm-greeter --test-mode --theme ~/tests/arch/login/Singularity
```
(`Ctrl+C` o cerrar la ventana para salir)

## Instalar

```bash
./install.sh
```
Copia `Singularity/` a `/usr/share/sddm/themes/` (pide `sudo`). **No** activa el tema.

## Activar (con red de seguridad)

1. Abre una **TTY de respaldo**: `Ctrl+Alt+F2`, inicia sesión en texto y déjala abierta.
   (Vuelves al escritorio con `Ctrl+Alt+F1` o tu VT gráfico.)
2. Activa el tema:
   ```bash
   sudo sed -i 's/^Current=.*/Current=Singularity/' /etc/sddm.conf.d/kde_settings.conf
   ```
3. Aplica reiniciando SDDM **desde la TTY de respaldo** (esto cierra la sesión gráfica):
   ```bash
   sudo systemctl restart sddm
   ```

## Revertir / desinstalar

Si algo sale mal, desde la TTY de respaldo:

```bash
./uninstall.sh        # vuelve a Candy y borra Singularity
sudo systemctl restart sddm
```

O solo cambiar el tema activo de vuelta:
```bash
sudo sed -i 's/^Current=Singularity/Current=Candy/' /etc/sddm.conf.d/kde_settings.conf
```

## Personalización rápida

Edita `Singularity/theme.conf` (o el instalado en `/usr/share/sddm/themes/Singularity/theme.conf`):

| Clave | Qué controla |
|---|---|
| `Accent` | Color cálido del disco / acentos (`#ffae5c`) |
| `Accent2` | Color frío (cian): hairlines, etiquetas, estrellas (`#7cc7ff`) |
| `DiskHot` | Color incandescente del núcleo del disco (`#fff3d6`) |
| `DiskSpeed` | Velocidad de rotación del disco de acreción |
| `StarDensity` | Densidad del campo de estrellas |
| `UIFont` | Fuente de la UI (Nerd Font para los íconos de power) |
| `HourFormat` / `DateFormat` | Formato de hora (24h) y fecha |
| `SessionLabel` | Etiqueta junto a la fecha (`HYPRLAND`) |
| `Wordmark` / `Tagline` | Título y subtítulo del panel de acceso |
| `Footer` | Línea easter-egg bajo el botón |
| `LoginLabel` | Texto del botón de acceso (`CRUZAR EL HORIZONTE`) |

> La física del agujero negro (radio del horizonte, inclinación del disco, lente,
> beaming Doppler) vive en `Singularity/Components/BlackHole.qml`, dentro del
> *fragment shader* — toda la geometría es procedural, sin imágenes.

## Estructura

```
Singularity/
├── metadata.desktop          # registro del tema
├── theme.conf                # parámetros configurables
├── Main.qml                  # raíz: consola (izq) + ventanal (der)
└── Components/
    ├── BlackHole.qml         # agujero negro — fragment shader GLSL (Canvas-free)
    ├── CornerTicks.qml       # esquinas HUD reutilizables
    ├── TerminalInput.qml     # campo de texto estilo HUD
    ├── LoginForm.qml         # panel de acceso (auth SDDM)
    ├── ClockBox.qml          # reloj / "mission timer"
    ├── Telemetry.qml         # lectura de telemetría (decorativa)
    └── PowerBox.qml          # acciones de energía
```

Diseño y plan detallados en `docs/superpowers/`.
