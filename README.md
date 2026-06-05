# MatrixRain — Tema SDDM (Matrix code-rain) para Arch + Hyprland

Pantalla de login estilo "Matrix hacker clásico": lluvia de katakana verde sobre
negro, cajas estilo terminal con glow. Tema QML para **SDDM** (Qt5).

![concepto](docs/superpowers/specs/2026-06-04-matrix-sddm-login-design.md)

## Requisitos

Fuentes instaladas a nivel sistema (paquetes oficiales):

```bash
sudo pacman -S noto-fonts-cjk ttf-jetbrains-mono-nerd
```

- `noto-fonts-cjk` → katakana de la lluvia (Noto Sans Mono CJK JP).
- `ttf-jetbrains-mono-nerd` → texto e íconos de power (JetBrainsMono Nerd Font Mono).

## Probar sin instalar (seguro, no toca el sistema)

```bash
sddm-greeter --test-mode --theme ~/tests/arch/login/MatrixRain
```
(`Ctrl+C` o cerrar la ventana para salir)

## Instalar

```bash
./install.sh
```
Copia `MatrixRain/` a `/usr/share/sddm/themes/` (pide `sudo`). **No** activa el tema.

## Activar (con red de seguridad)

1. Abre una **TTY de respaldo**: `Ctrl+Alt+F2`, inicia sesión en texto y déjala abierta.
   (Vuelves al escritorio con `Ctrl+Alt+F1` o tu VT gráfico.)
2. Activa el tema:
   ```bash
   sudo sed -i 's/^Current=Candy/Current=MatrixRain/' /etc/sddm.conf.d/kde_settings.conf
   ```
3. Aplica reiniciando SDDM **desde la TTY de respaldo** (esto cierra la sesión gráfica):
   ```bash
   sudo systemctl restart sddm
   ```

## Revertir / desinstalar

Si algo sale mal, desde la TTY de respaldo:

```bash
./uninstall.sh        # vuelve a Candy y borra MatrixRain
sudo systemctl restart sddm
```

O solo cambiar el tema activo de vuelta:
```bash
sudo sed -i 's/^Current=MatrixRain/Current=Candy/' /etc/sddm.conf.d/kde_settings.conf
```

## Personalización rápida

Edita `MatrixRain/theme.conf` (o el instalado en `/usr/share/sddm/themes/MatrixRain/theme.conf`):

| Clave | Qué controla |
|---|---|
| `MainColor` | Color verde principal (`#00ff41`) |
| `RainFps` / `RainColumnWidth` | Velocidad / densidad de la lluvia |
| `ClockOpacity` | Atenuación de la caja del reloj |
| `HourFormat` / `DateFormat` | Formato de hora (24h) y fecha |
| `SessionLabel` | Etiqueta junto a la fecha (`HYPRLAND`) |
| `RainFont` / `UIFont` | Fuentes (rain / UI) |

> Los textos `root@arch:~$ login` y `[ wake up, Neo... ]` son fijos en v1
> (propiedades en `MatrixRain/Components/LoginForm.qml`), preparados para
> hacerse configurables en `theme.conf` más adelante sin refactor.

## Estructura

```
MatrixRain/
├── metadata.desktop          # registro del tema
├── theme.conf                # parámetros configurables
├── Main.qml                  # raíz: fondo + 3 cajas
└── Components/
    ├── MatrixRain.qml        # lluvia animada (Canvas + Timer)
    ├── TerminalInput.qml     # campo de texto terminal
    ├── LoginForm.qml         # caja de login (auth SDDM)
    ├── ClockBox.qml          # caja reloj/fecha
    └── PowerBox.qml          # caja de acciones de energía
```

Diseño y plan detallados en `docs/superpowers/`.
