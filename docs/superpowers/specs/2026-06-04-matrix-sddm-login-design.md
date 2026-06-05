# Diseño — Tema SDDM "MatrixRain" para Arch + Hyprland

**Fecha:** 2026-06-04
**Autor:** Sebastian Castillo (con Claude)
**Estado:** Aprobado para planificación

---

## 1. Objetivo

Reemplazar la pantalla de login actual (tema **Candy** / "Sugar Candy") por un **tema SDDM nuevo, construido desde cero en QML**, con estética **"Matrix hacker clásico"**: lluvia de código verde sobre negro, cajas estilo terminal con glow, y el factor "wow".

El tema debe ser un greeter SDDM **completamente funcional** (no solo una maqueta): autentica, lista usuarios, permite elegir sesión, maneja errores y expone acciones de energía.

## 2. Contexto del sistema (verificado)

| Elemento | Valor |
|---|---|
| Display manager | SDDM **0.21.0**, `enabled` y activo |
| Greeter activo | Qt5 (`/usr/bin/sddm-greeter`) — el tema Candy usa Qt5 |
| Stack QML objetivo | `QtQuick 2.11`, `QtQuick.Controls 2.4`, `QtQuick.Layouts 1.11`, `QtGraphicalEffects 1.0`, `SddmComponents 2.0` |
| Config activa | `/etc/sddm.conf.d/kde_settings.conf` → `[Theme] Current=Candy` |
| Temas dir | `/usr/share/sddm/themes/` |
| Fuente rain | **Noto Sans Mono CJK JP** (`noto-fonts-cjk`) — instalada ✓ |
| Fuente UI + íconos | **JetBrainsMono Nerd Font Mono** (`ttf-jetbrains-mono-nerd`) — instalada ✓ |

**Decisión de aislamiento:** NO modificar el tema `Candy`. Se crea un directorio nuevo `MatrixRain`. Candy permanece intacto como fallback. La activación es un cambio de una línea en `kde_settings.conf`, trivialmente reversible.

## 3. Especificación visual (decisiones bloqueadas)

### Paleta
- Fondo: **negro puro** `#000000`
- Verde principal: **`#00ff41`** (verde Matrix clásico)
- Verde de campos/inputs: fondo `#001400`, borde `#00aa2a`
- Glow: `rgba(0,255,65,0.35)` en cajas; `text-shadow`/Glow verde en texto
- Texto resaltado puntual (palabra `login`): blanco `#ffffff`

### Tipografías
- **Lluvia (Canvas):** `Noto Sans Mono CJK JP` — katakana de ancho medio + dígitos
- **UI (cajas, texto, íconos):** `JetBrainsMono Nerd Font Mono`

### Layout (3 zonas, sin competir por el foco)
```
┌─────────────────────────────────────────────┐
│ ┌──────────┐                                 │   ← lluvia katakana verde
│ │  21:30   │      (lluvia de fondo)          │     cayendo en todo el fondo
│ │ THU 04.. │                                 │
│ └──────────┘     ┌───────────────────┐       │
│   clock box      │ root@arch:~$ login│       │   ← login box = FOCO
│  (atenuada 75%)  │ user [__________] │       │     centrado, glow pleno
│                  │ pass [••••••••_  ]│       │
│                  │ [ wake up, Neo... ]│      │
│                  └───────────────────┘       │
│                                  ┌─────────┐ │
│                                  │ ⏻  ⟳  ☾ │ │   ← power box agrupada
│                                  └─────────┘ │
└─────────────────────────────────────────────┘
```

- **Login box (centro):** foco principal, brillo pleno. Cabecera `root@arch:~$ login` (con "login" en blanco). Filas `user` y `pass` con etiqueta fija a la izquierda y campo que se estira a todo el ancho disponible (flex/Layout). Pie con guiño `[ wake up, Neo... ]`. **Estos textos son FIJOS en v1** (definidos como propiedades QML con valor por defecto), estructurados para promoverse a `theme.conf` sin refactor cuando se quieran hacer configurables.
- **Clock box (arriba-izquierda):** misma estética terminal, **más pequeña y atenuada (~75% opacidad)** para no robar foco. Hora **`HH:mm` (24h)** grande + línea `DÍA DD MES · HYPRLAND`. La hora usa la **zona horaria del sistema** (comportamiento por defecto de `Qt` / `Date`, sin override de locale). Sin datos extra (uptime/kernel): limpia.
- **Power box (abajo-derecha):** caja agrupada con 3 íconos Nerd Font (⏻ apagar · ⟳ reiniciar · ☾ suspender), divisores verticales y estado hover.

### Lluvia de código
- Caracteres: katakana de ancho medio (ｱｲｳ…ﾝ) + dígitos `0-9`.
- Color `#00ff41`, sobre estela que se desvanece (overlay negro semitransparente cada frame).
- Velocidad: **~30 fps** (paso de ~33 ms) — suavizada respecto al clásico 60 fps, estelas un poco más largas.
- Densidad: una columna por ~14 px de ancho; reinicio de gota con probabilidad ~2.5% al salir por abajo.

## 4. Arquitectura de componentes (QML)

Estructura del tema en `/usr/share/sddm/themes/MatrixRain/`, espejando la organización de Candy:

```
MatrixRain/
├── metadata.desktop          # nombre, autor, QML principal
├── theme.conf                # parámetros configurables (colores, textos, formato hora)
├── Main.qml                  # raíz: orquesta fondo + componentes, conecta señales SDDM
├── Components/
│   ├── MatrixRain.qml        # Canvas + Timer: la lluvia animada
│   ├── LoginForm.qml         # caja central: user/pass/sesión, botón login, errores
│   ├── ClockBox.qml          # caja reloj/fecha (atenuada)
│   ├── PowerBox.qml          # caja agrupada de acciones de energía
│   └── TerminalInput.qml     # campo de texto estilizado (reutilizable user/pass)
└── Assets/                   # íconos si hiciera falta (preferimos glyphs Nerd Font)
```

**Responsabilidades y límites:**

- **`MatrixRain.qml`** — *Qué hace:* renderiza la lluvia en un `Canvas` con un `Timer` a ~30 fps. *Interfaz:* propiedades `color`, `fontFamily`, `fps`, `density`. *Depende de:* nada del backend SDDM (es puramente decorativo). Aislado y testeable solo.
- **`LoginForm.qml`** — *Qué hace:* captura usuario/contraseña, dispara `sddm.login()`, muestra warnings (login fallido, CapsLock), selector de sesión. *Interfaz:* usa el objeto global `sddm` y los modelos `userModel`/`sessionModel`. *Depende de:* `TerminalInput`, API SDDM.
- **`ClockBox.qml`** — *Qué hace:* muestra hora/fecha, se autoactualiza con un `Timer` de 1 s. *Interfaz:* props `timeFormat`, `dateFormat`, `opacity`. *Depende de:* nada externo.
- **`PowerBox.qml`** — *Qué hace:* botones apagar/reiniciar/suspender. *Interfaz:* llama `sddm.powerOff()`, `sddm.reboot()`, `sddm.suspend()`; respeta `sddm.canPowerOff` etc. para habilitar/deshabilitar. *Depende de:* API SDDM.
- **`TerminalInput.qml`** — *Qué hace:* `TextField` con estilo terminal (fondo `#001400`, borde verde, cursor `_`). *Interfaz:* props estándar de texto + `echoMode`. Reutilizado por user y pass.
- **`Main.qml`** — *Qué hace:* coloca el fondo (MatrixRain) y las tres cajas en sus posiciones; conecta señales globales (`sddm.loginSucceeded`, `sddm.loginFailed`); aplica parámetros de `theme.conf`.

## 5. Requisitos funcionales del greeter

El tema NO es solo visual. Debe cumplir lo que SDDM espera de un greeter:

1. **Autenticación:** capturar usuario + contraseña → `sddm.login(user, password, sessionIndex)`.
2. **Usuario por defecto:** precargar el último usuario (equivalente a `ForceLastUser`) y enfocar el campo de contraseña.
3. **Selección de sesión:** permitir elegir entre sesiones disponibles (`sessionModel`); por defecto la última usada (Hyprland).
4. **Manejo de errores:** al `loginFailed`, mostrar warning en verde/rojo dentro de la caja sin recargar; limpiar contraseña.
5. **CapsLock:** aviso si Bloq Mayús está activo.
6. **Acciones de energía:** apagar / reiniciar / suspender, deshabilitadas si el sistema no las permite.
7. **Teclado virtual:** *fuera de alcance v1* (ver §9) salvo que SDDM lo exija; se deja el hook preparado.

## 6. Configuración (`theme.conf`)

Parámetros expuestos para ajustar sin tocar QML (subconjunto, sin la complejidad de Sugar Candy):

```ini
[General]
MainColor="#00ff41"
BackgroundColor="#000000"
InputBackground="#001400"
RainFont="Noto Sans Mono CJK JP"
UIFont="JetBrainsMono Nerd Font Mono"
RainFps="30"
RainDensity="14"
ClockOpacity="0.75"
HourFormat="HH:mm"          # 24h, zona horaria del sistema
DateFormat="ddd dd MMM"
SessionLabel="HYPRLAND"
```

> **`HeaderText` (`root@arch:~$ login`) y `FooterText` (`[ wake up, Neo... ]`) NO se exponen en `theme.conf` en v1.** Se definen como propiedades QML con valor por defecto en `LoginForm.qml`. Quedan estructurados para promoverse a `theme.conf` (como las claves comentadas arriba) cuando se quieran hacer configurables — sin refactor, solo cablear la lectura.

`metadata.desktop`:
```ini
[SddmGreeterTheme]
Name=MatrixRain
Description=Matrix-style green code rain login
Author=Sebastian Castillo
MainScript=Main.qml
ConfigFile=theme.conf
Type=sddm-theme
```

## 7. Instalación y activación

1. Copiar `MatrixRain/` a `/usr/share/sddm/themes/` (requiere `sudo`).
2. Cambiar en `/etc/sddm.conf.d/kde_settings.conf`: `[Theme] Current=MatrixRain`.
3. Reiniciar el servicio o probar en test-mode (no cerrar sesión a ciegas).

**Reversión:** volver `Current=Candy`. Cero riesgo de quedar bloqueado si validamos en test-mode antes.

## 8. Estrategia de pruebas

- **Test-mode (sin cerrar sesión):** `sddm-greeter --test-mode --theme /usr/share/sddm/themes/MatrixRain` para ver el render en una ventana, iterar sin riesgo.
- **Checklist visual:** lluvia fluida sin tofu, glow correcto, tres cajas en su sitio, campos a todo el ancho, reloj actualizándose, hover en power box.
- **Checklist funcional (en test-mode SDDM simula el backend):** foco inicial en contraseña, selección de sesión, mensaje de login fallido, botones de energía presentes.
- **Validación final:** activar el tema y probar un login real en una TTY de respaldo abierta (Ctrl+Alt+F2) como red de seguridad antes de confiar plenamente.

## 9. Fuera de alcance (YAGNI v1)

- Teclado virtual en pantalla (hook preparado, no implementado).
- Múltiples fondos / selector de wallpaper (el fondo ES la lluvia).
- Soporte multi-monitor avanzado (se cubre el monitor primario; layout centrado tolera otras resoluciones).
- Port a Qt6 (`sddm-greeter-qt6`): se mantiene Qt5 por paridad con el setup probado. Documentado como mejora futura.
- Localización/traducciones más allá de los textos fijos del `theme.conf`.

## 10. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Rendimiento del `Canvas` en hardware modesto | fps configurable (30), densidad ajustable; medir en test-mode |
| Quedar bloqueado sin poder loguear | validar SIEMPRE en test-mode + TTY de respaldo antes de confiar |
| Nombre de fuente mal escrito → tofu | nombres exactos verificados vía `fc-list` (§2) |
| API SDDM 0.21 difiere de ejemplos | espejar lo que ya hace Candy (mismo SDDM/Qt) para señales y modelos |
| Permisos root en `/usr/share` | pasos de instalación con `sudo` explícitos; trabajar la copia local primero |

## 11. Resolución (resolución de pantalla)

Resolución detectada en Candy: `2560x1080` (ultrawide). El layout centrado + cajas de tamaño fijo con anclas relativas debe tolerar esta y otras resoluciones; se valida en test-mode a 2560x1080.
