# MatrixRain SDDM Login Theme — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a new, fully functional SDDM greeter theme `MatrixRain` (green Matrix code-rain hacker aesthetic) in Qt5 QML, developed inside this git repo and only installed to the system after validation.

**Architecture:** A QML Qt5 SDDM theme mirroring the proven Sugar Candy/"Candy" structure (same SDDM 0.21 + Qt5 API). A full-screen animated `Canvas` renders the code rain; three bordered terminal-style boxes float on top — a focused central login box, an attenuated clock box (top-left), and a grouped power box (bottom-right). The theme is developed in `MatrixRain/` under version control and copied to `/usr/share/sddm/themes/` only at the end.

**Tech Stack:** QML (`QtQuick 2.11`, `QtQuick.Controls 2.4`, `QtQuick.Layouts 1.11`, `QtGraphicalEffects 1.0`, `SddmComponents 2.0`), SDDM 0.21 Qt5 greeter, fonts `Noto Sans Mono CJK JP` (rain) + `JetBrainsMono Nerd Font Mono` (UI/icons).

---

## Testing approach (read first)

QML SDDM themes have **no unit-test framework**. The SDDM context objects (`config`, `sddm`, `userModel`, `sessionModel`, `keyboard`) only exist inside the greeter. So each task uses a two-gate verification instead of TDD:

1. **Syntax gate:** `qmllint-qt5 <file>` — must report **no syntax errors**. It WILL warn about unknown `config`/`sddm`/`userModel`/`root`/`Screen` (these are injected at runtime) — those warnings are expected and OK. Only bracket/paren/keyword syntax errors are failures.
2. **Render gate:** `sddm-greeter --test-mode --theme ~/tests/arch/login/MatrixRain` — opens a window with a mock backend. Confirm the new piece renders and that **stderr shows no `file:line: ... error`** lines. Close with `Ctrl+C` in the terminal (or close the window).

The repo theme path is reused throughout. Define it once in your shell:
```bash
THEME=~/tests/arch/login/MatrixRain
```

---

## File Structure

All paths relative to repo root `~/tests/arch/login/`:

- `MatrixRain/metadata.desktop` — theme registration (name, MainScript, ConfigFile).
- `MatrixRain/theme.conf` — configurable parameters (colors, fonts, fps, formats).
- `MatrixRain/Main.qml` — root `Pane`; black background + 4 child slots (rain, clock, login, power); wires `config`.
- `MatrixRain/Components/MatrixRain.qml` — `Canvas` + `Timer` code-rain. Self-contained, decorative.
- `MatrixRain/Components/TerminalInput.qml` — reusable styled `TextField` (user/pass).
- `MatrixRain/Components/LoginForm.qml` — central login box: header/user/pass/footer/error/session/login button; `sddm.login` wiring.
- `MatrixRain/Components/ClockBox.qml` — attenuated clock/date box, top-left.
- `MatrixRain/Components/PowerBox.qml` — grouped power buttons, bottom-right.
- `install.sh` — copies `MatrixRain/` to `/usr/share/sddm/themes/` with `sudo`.

---

## Task 1: Scaffold theme (metadata, config, black Main)

**Files:**
- Create: `MatrixRain/metadata.desktop`
- Create: `MatrixRain/theme.conf`
- Create: `MatrixRain/Main.qml`

- [ ] **Step 1: Create `MatrixRain/metadata.desktop`**

```ini
[SddmGreeterTheme]
Name=MatrixRain
Description=Matrix-style green code rain login
Author=Sebastian Castillo
License=MIT
Type=sddm-theme
Version=1.0
Theme-API=2.0
MainScript=Main.qml
ConfigFile=theme.conf
Theme-Id=MatrixRain
```

- [ ] **Step 2: Create `MatrixRain/theme.conf`**

```ini
[General]
MainColor="#00ff41"
BackgroundColor="#000000"
InputBackground="#001400"
InputBorder="#00aa2a"
RainFont="Noto Sans Mono CJK JP"
UIFont="JetBrainsMono Nerd Font Mono"
RainFps="30"
RainColumnWidth="14"
ClockOpacity="0.75"
HourFormat="HH:mm"
DateFormat="ddd dd MMM"
SessionLabel="HYPRLAND"
```

> `HeaderText`/`FooterText` are intentionally NOT here in v1 — they are fixed QML properties in `LoginForm.qml`, structured to be promoted here later without refactor.

- [ ] **Step 3: Create `MatrixRain/Main.qml` (skeleton with named slots)**

```qml
import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "Components"

Pane {
    id: root

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width
    padding: 0
    palette.window: config.BackgroundColor
    font.family: config.UIFont
    focus: true

    Item {
        id: sizeHelper
        anchors.fill: parent

        Rectangle {
            id: bg
            anchors.fill: parent
            color: config.BackgroundColor
        }

        // SLOT-RAIN
        // SLOT-CLOCK
        // SLOT-LOGIN
        // SLOT-POWER
    }
}
```

- [ ] **Step 4: Syntax gate**

Run: `qmllint-qt5 ~/tests/arch/login/MatrixRain/Main.qml`
Expected: no syntax errors (unknown `config`/`Screen` warnings are OK).

- [ ] **Step 5: Render gate**

Run: `THEME=~/tests/arch/login/MatrixRain; sddm-greeter --test-mode --theme "$THEME"`
Expected: a solid black window opens, no `error` lines in stderr. Close with `Ctrl+C`.

- [ ] **Step 6: Commit**

```bash
cd ~/tests/arch/login
git add MatrixRain/metadata.desktop MatrixRain/theme.conf MatrixRain/Main.qml
git commit -m "feat(matrixrain): scaffold theme with black background"
```

---

## Task 2: Code rain (MatrixRain.qml)

**Files:**
- Create: `MatrixRain/Components/MatrixRain.qml`
- Modify: `MatrixRain/Main.qml` (replace `// SLOT-RAIN`)

- [ ] **Step 1: Create `MatrixRain/Components/MatrixRain.qml`**

```qml
import QtQuick 2.11

Item {
    id: rain

    property color rainColor: config.MainColor || "#00ff41"
    property string fontFamily: config.RainFont || "monospace"
    property int columnWidth: parseInt(config.RainColumnWidth) || 14
    property int fps: parseInt(config.RainFps) || 30

    property string glyphs: "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    property var drops: []
    property int columns: 0

    function initDrops() {
        columns = Math.max(1, Math.floor(width / columnWidth))
        var d = []
        for (var i = 0; i < columns; i++)
            d[i] = Math.floor(Math.random() * -50)
        drops = d
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = "rgba(0,0,0,0.07)"
            ctx.fillRect(0, 0, width, height)
            ctx.fillStyle = rain.rainColor
            ctx.font = rain.columnWidth + "px '" + rain.fontFamily + "'"
            for (var i = 0; i < rain.columns; i++) {
                var ch = rain.glyphs.charAt(Math.floor(Math.random() * rain.glyphs.length))
                var y = rain.drops[i] * rain.columnWidth
                ctx.fillText(ch, i * rain.columnWidth, y)
                if (y > rain.height && Math.random() > 0.975)
                    rain.drops[i] = 0
                rain.drops[i]++
            }
        }
    }

    Timer {
        interval: 1000 / rain.fps
        repeat: true
        running: true
        onTriggered: canvas.requestPaint()
    }

    onWidthChanged: initDrops()
    onHeightChanged: initDrops()
    Component.onCompleted: initDrops()
}
```

- [ ] **Step 2: Wire into `Main.qml` — replace the line `// SLOT-RAIN` with:**

```qml
        MatrixRain {
            id: matrixRain
            anchors.fill: parent
            z: 0
        }
```

- [ ] **Step 3: Syntax gate**

Run: `qmllint-qt5 ~/tests/arch/login/MatrixRain/Components/MatrixRain.qml`
Expected: no syntax errors.

- [ ] **Step 4: Render gate**

Run: `sddm-greeter --test-mode --theme ~/tests/arch/login/MatrixRain`
Expected: green katakana + digits fall down the screen, ~30 fps, fading trails, no tofu boxes. No `error` lines in stderr. `Ctrl+C` to close.

- [ ] **Step 5: Commit**

```bash
cd ~/tests/arch/login
git add MatrixRain/Components/MatrixRain.qml MatrixRain/Main.qml
git commit -m "feat(matrixrain): animated green code rain background"
```

---

## Task 3: Terminal input field (TerminalInput.qml)

**Files:**
- Create: `MatrixRain/Components/TerminalInput.qml`

- [ ] **Step 1: Create `MatrixRain/Components/TerminalInput.qml`**

```qml
import QtQuick 2.11
import QtQuick.Controls 2.4

TextField {
    id: field

    property color accent: config.MainColor || "#00ff41"

    color: accent
    font.family: config.UIFont
    selectByMouse: true
    renderType: Text.QtRendering
    leftPadding: 10
    rightPadding: 10
    topPadding: 6
    bottomPadding: 6
    passwordCharacter: "•"

    background: Rectangle {
        color: config.InputBackground || "#001400"
        border.color: field.activeFocus ? field.accent : (config.InputBorder || "#00aa2a")
        border.width: field.activeFocus ? 2 : 1
        radius: 0
    }
}
```

- [ ] **Step 2: Syntax gate**

Run: `qmllint-qt5 ~/tests/arch/login/MatrixRain/Components/TerminalInput.qml`
Expected: no syntax errors.

> No render gate here: this component is only exercised once consumed by `LoginForm` in Task 4.

- [ ] **Step 3: Commit**

```bash
cd ~/tests/arch/login
git add MatrixRain/Components/TerminalInput.qml
git commit -m "feat(matrixrain): reusable terminal-styled input field"
```

---

## Task 4: Login box (LoginForm.qml) — the functional core

**Files:**
- Create: `MatrixRain/Components/LoginForm.qml`
- Modify: `MatrixRain/Main.qml` (replace `// SLOT-LOGIN`)

- [ ] **Step 1: Create `MatrixRain/Components/LoginForm.qml`**

```qml
import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import SddmComponents 2.0 as SDDM

Rectangle {
    id: form
    SDDM.TextConstants { id: textConstants }

    // Fixed in v1; promote to config.* later without refactor.
    property string headerUser: "root@arch:~$"
    property string headerCmd: "login"
    property string footerText: "[ wake up, Neo... ]"
    property color accent: config.MainColor || "#00ff41"
    property bool failed: false

    width: 380
    implicitHeight: layout.implicitHeight + 40
    color: Qt.rgba(0, 0.04, 0, 0.82)
    border.color: accent
    border.width: 1

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        // Header: root@arch:~$ login   (cmd in white)
        Text {
            Layout.fillWidth: true
            font.family: config.UIFont
            font.pointSize: 13
            textFormat: Text.StyledText
            color: form.accent
            text: form.headerUser + ' <font color="#ffffff">' + form.headerCmd + '</font>'
        }

        // user row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text {
                text: "user"; color: form.accent; font.family: config.UIFont
                font.pointSize: 13; Layout.preferredWidth: 38
            }
            TerminalInput {
                id: username
                Layout.fillWidth: true
                font.pointSize: 13
                text: userModel.lastUser
                onAccepted: password.forceActiveFocus()
            }
        }

        // pass row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text {
                text: "pass"; color: form.accent; font.family: config.UIFont
                font.pointSize: 13; Layout.preferredWidth: 38
            }
            TerminalInput {
                id: password
                Layout.fillWidth: true
                font.pointSize: 13
                echoMode: TextInput.Password
                focus: true
                onAccepted: loginButton.clicked()
            }
        }

        // error / capslock message
        Text {
            id: errorMessage
            Layout.fillWidth: true
            font.family: config.UIFont
            font.pointSize: 11
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            color: "#ff5555"
            opacity: (form.failed || keyboard.capsLock) ? 1 : 0
            text: form.failed
                  ? (textConstants.loginFailed + "!")
                  : (keyboard.capsLock ? textConstants.capslockWarning : "")
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }

        // footer easter-egg
        Text {
            Layout.fillWidth: true
            font.family: config.UIFont
            font.pointSize: 12
            color: form.accent
            opacity: 0.85
            text: form.footerText
        }

        // session selector + login button
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ComboBox {
                id: sessionSelect
                Layout.preferredWidth: 150
                font.family: config.UIFont
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
            }

            Button {
                id: loginButton
                Layout.fillWidth: true
                text: "ENTRAR"
                enabled: username.text !== "" && password.text !== ""
                font.family: config.UIFont
                contentItem: Text {
                    text: loginButton.text
                    color: "#000000"
                    font.family: config.UIFont
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: loginButton.enabled
                           ? (loginButton.down ? Qt.darker(form.accent, 1.2) : form.accent)
                           : Qt.rgba(0, 1, 0.25, 0.25)
                    radius: 0
                }
                onClicked: sddm.login(username.text, password.text, sessionSelect.currentIndex)
                Keys.onReturnPressed: clicked()
                Keys.onEnterPressed: clicked()
            }
        }
    }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            form.failed = true
            password.text = ""
            resetError.restart()
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: form.failed = false
    }
}
```

- [ ] **Step 2: Wire into `Main.qml` — replace the line `// SLOT-LOGIN` with:**

```qml
        LoginForm {
            id: loginForm
            anchors.centerIn: parent
            z: 2
        }
```

- [ ] **Step 3: Syntax gate**

Run: `qmllint-qt5 ~/tests/arch/login/MatrixRain/Components/LoginForm.qml`
Expected: no syntax errors (warnings for `sddm`/`userModel`/`sessionModel`/`keyboard` are OK).

- [ ] **Step 4: Render gate (functional)**

Run: `sddm-greeter --test-mode --theme ~/tests/arch/login/MatrixRain`
Expected:
- Central box over the rain: header `root@arch:~$ login` (login in white), `user`/`pass` rows with fields filling the width, footer `[ wake up, Neo... ]`, a session combo + `ENTRAR` button.
- Typing a fake password enables `ENTRAR`. Clicking it (test-mode rejects) triggers a red error message that clears after ~2s.
- No `error` lines in stderr. `Ctrl+C` to close.

- [ ] **Step 5: Commit**

```bash
cd ~/tests/arch/login
git add MatrixRain/Components/LoginForm.qml MatrixRain/Main.qml
git commit -m "feat(matrixrain): functional login box with sddm auth wiring"
```

---

## Task 5: Clock box (ClockBox.qml)

**Files:**
- Create: `MatrixRain/Components/ClockBox.qml`
- Modify: `MatrixRain/Main.qml` (replace `// SLOT-CLOCK`)

- [ ] **Step 1: Create `MatrixRain/Components/ClockBox.qml`**

```qml
import QtQuick 2.11

Rectangle {
    id: clockBox

    property color accent: config.MainColor || "#00ff41"

    opacity: parseFloat(config.ClockOpacity) || 0.75
    color: Qt.rgba(0, 0.03, 0, 0.6)
    border.color: Qt.rgba(0, 1, 0.25, 0.35)
    border.width: 1
    implicitWidth: col.implicitWidth + 32
    implicitHeight: col.implicitHeight + 24

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: timeLabel
            font.family: config.UIFont
            font.pointSize: 30
            color: clockBox.accent
        }
        Text {
            id: dateLabel
            font.family: config.UIFont
            font.pointSize: 11
            color: clockBox.accent
        }
    }

    function updateTime() {
        var now = new Date()
        timeLabel.text = now.toLocaleTimeString(Qt.locale(), config.HourFormat || "HH:mm")
        var d = now.toLocaleDateString(Qt.locale(), config.DateFormat || "ddd dd MMM")
        dateLabel.text = (d + "  ·  " + (config.SessionLabel || "")).toUpperCase()
    }

    Timer { interval: 1000; repeat: true; running: true; onTriggered: clockBox.updateTime() }
    Component.onCompleted: updateTime()
}
```

- [ ] **Step 2: Wire into `Main.qml` — replace the line `// SLOT-CLOCK` with:**

```qml
        ClockBox {
            id: clockBox
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 40
            anchors.topMargin: 40
            z: 1
        }
```

- [ ] **Step 3: Syntax gate**

Run: `qmllint-qt5 ~/tests/arch/login/MatrixRain/Components/ClockBox.qml`
Expected: no syntax errors.

- [ ] **Step 4: Render gate**

Run: `sddm-greeter --test-mode --theme ~/tests/arch/login/MatrixRain`
Expected: top-left attenuated box showing `HH:mm` (24h) + `DDD DD MES · HYPRLAND`, time visibly ticking; dimmer than the login box. No stderr errors. `Ctrl+C`.

- [ ] **Step 5: Commit**

```bash
cd ~/tests/arch/login
git add MatrixRain/Components/ClockBox.qml MatrixRain/Main.qml
git commit -m "feat(matrixrain): attenuated clock/date box (24h, system tz)"
```

---

## Task 6: Power box (PowerBox.qml)

**Files:**
- Create: `MatrixRain/Components/PowerBox.qml`
- Modify: `MatrixRain/Main.qml` (replace `// SLOT-POWER`)

- [ ] **Step 1: Create `MatrixRain/Components/PowerBox.qml`**

Nerd Font glyphs (guaranteed present in JetBrainsMono Nerd Font): `` power-off, `` restart, `` moon/suspend.

```qml
import QtQuick 2.11

Rectangle {
    id: powerBox

    property color accent: config.MainColor || "#00ff41"

    color: Qt.rgba(0, 0.03, 0, 0.72)
    border.color: Qt.rgba(0, 1, 0.25, 0.45)
    border.width: 1
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row

        property var actions: [
            { glyph: "", enabled: sddm.canPowerOff, kind: "off" },
            { glyph: "", enabled: sddm.canReboot,   kind: "reboot" },
            { glyph: "", enabled: sddm.canSuspend,  kind: "suspend" }
        ]

        Repeater {
            model: row.actions
            delegate: Rectangle {
                visible: modelData.enabled
                width: 50
                height: 42
                color: hover.containsMouse ? Qt.rgba(0, 1, 0.25, 0.12) : "transparent"

                Rectangle {
                    visible: index > 0
                    width: 1
                    height: parent.height
                    color: Qt.rgba(0, 1, 0.25, 0.22)
                    anchors.left: parent.left
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.glyph
                    font.family: config.UIFont
                    font.pointSize: 15
                    color: powerBox.accent
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.kind === "off") sddm.powerOff()
                        else if (modelData.kind === "reboot") sddm.reboot()
                        else sddm.suspend()
                    }
                }
            }
        }
    }
}
```

- [ ] **Step 2: Wire into `Main.qml` — replace the line `// SLOT-POWER` with:**

```qml
        PowerBox {
            id: powerBox
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 40
            anchors.bottomMargin: 40
            z: 1
        }
```

- [ ] **Step 3: Syntax gate**

Run: `qmllint-qt5 ~/tests/arch/login/MatrixRain/Components/PowerBox.qml`
Expected: no syntax errors.

- [ ] **Step 4: Render gate**

Run: `sddm-greeter --test-mode --theme ~/tests/arch/login/MatrixRain`
Expected: bottom-right grouped box with 3 green Nerd Font icons (power/restart/moon) separated by vertical dividers; hover highlights a cell. No tofu. No stderr errors. `Ctrl+C`.

- [ ] **Step 5: Commit**

```bash
cd ~/tests/arch/login
git add MatrixRain/Components/PowerBox.qml MatrixRain/Main.qml
git commit -m "feat(matrixrain): grouped power box with nerd-font icons"
```

---

## Task 7: Glow polish + full-resolution pass

**Files:**
- Modify: `MatrixRain/Main.qml` (add glow layer effects to the three boxes)

- [ ] **Step 1: Add glow to the login box. In `Main.qml`, replace the `LoginForm { ... }` block with:**

```qml
        LoginForm {
            id: loginForm
            anchors.centerIn: parent
            z: 2
            layer.enabled: true
            layer.effect: Glow {
                radius: 12
                samples: 25
                color: "#00ff41"
                spread: 0.2
                transparentBorder: true
            }
        }
```

- [ ] **Step 2: Add a softer glow to the clock box. Replace the `ClockBox { ... }` block with:**

```qml
        ClockBox {
            id: clockBox
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 40
            anchors.topMargin: 40
            z: 1
            layer.enabled: true
            layer.effect: Glow {
                radius: 6
                samples: 13
                color: "#00ff41"
                spread: 0.1
                transparentBorder: true
            }
        }
```

- [ ] **Step 3: Add a glow to the power box. Replace the `PowerBox { ... }` block with:**

```qml
        PowerBox {
            id: powerBox
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 40
            anchors.bottomMargin: 40
            z: 1
            layer.enabled: true
            layer.effect: Glow {
                radius: 8
                samples: 17
                color: "#00ff41"
                spread: 0.15
                transparentBorder: true
            }
        }
```

- [ ] **Step 4: Render gate at native resolution**

Run: `sddm-greeter --test-mode --theme ~/tests/arch/login/MatrixRain`
Expected: all three boxes have a green glow; login box brightest, clock dimmest. Layout balanced (clock ↖ · login center · power ↘). Rain still smooth. No stderr errors. `Ctrl+C`.

- [ ] **Step 5: Commit**

```bash
cd ~/tests/arch/login
git add MatrixRain/Main.qml
git commit -m "feat(matrixrain): green glow polish on all boxes"
```

---

## Task 8: Install script + system activation + safe real-login validation

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Create `install.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)/MatrixRain"
echo "Installing MatrixRain from $SRC ..."
sudo cp -rT "$SRC" /usr/share/sddm/themes/MatrixRain
echo "Done. To activate, set [Theme] Current=MatrixRain in /etc/sddm.conf.d/kde_settings.conf"
```

- [ ] **Step 2: Make it executable and run it**

```bash
cd ~/tests/arch/login
chmod +x install.sh
./install.sh
```
Expected: prints "Done." and `/usr/share/sddm/themes/MatrixRain/` now exists.

- [ ] **Step 3: Final test-mode against the INSTALLED copy**

Run: `sddm-greeter --test-mode --theme /usr/share/sddm/themes/MatrixRain`
Expected: identical to the repo render. Fonts resolve (no tofu) since the greeter now loads from the system path. `Ctrl+C`.

- [ ] **Step 4: Open a backup TTY before activating (safety net)**

Press `Ctrl+Alt+F2`, log in on the text console, and stay logged in there. This guarantees a way back if the greeter misbehaves. Return to the desktop with `Ctrl+Alt+F1` (or your GUI VT).

- [ ] **Step 5: Activate the theme**

Edit `/etc/sddm.conf.d/kde_settings.conf` and change the `[Theme]` section:
```ini
[Theme]
Current=MatrixRain
```
Command:
```bash
sudo sed -i 's/^Current=Candy/Current=MatrixRain/' /etc/sddm.conf.d/kde_settings.conf
grep Current /etc/sddm.conf.d/kde_settings.conf
```
Expected: `Current=MatrixRain`.

- [ ] **Step 6: Validate a real login**

Log out (or `sudo systemctl restart sddm` **only from the backup TTY**, since restarting kills the GUI session). At the greeter: confirm rain animates, clock ticks, type your real password, confirm successful login into Hyprland. Test a wrong password once to confirm the red error appears.

> **Rollback if anything is wrong:** from the backup TTY run
> `sudo sed -i 's/^Current=MatrixRain/Current=Candy/' /etc/sddm.conf.d/kde_settings.conf && sudo systemctl restart sddm`

- [ ] **Step 7: Commit**

```bash
cd ~/tests/arch/login
git add install.sh
git commit -m "chore(matrixrain): install script + activation docs"
```

---

## Self-Review

**1. Spec coverage:**
- §3 visual (palette/fonts/layout/rain) → Tasks 1,2,4,5,6,7 ✓
- §4 component architecture (6 QML files) → Tasks 2–6 ✓ (Main.qml across tasks)
- §5 functional: auth → Task 4; last user prefill (`userModel.lastUser`) → Task 4; session select (`sessionModel`) → Task 4; error/loginFailed → Task 4; CapsLock (`keyboard.capsLock`) → Task 4; power actions → Task 6 ✓. Virtual keyboard = out of scope §9 (no task — correct).
- §6 theme.conf → Task 1; fixed-but-future-configurable texts → Task 4 properties ✓
- §7 install/activation → Task 8 ✓
- §8 testing (test-mode + backup TTY) → every render gate + Task 8 steps 4/6 ✓
- §11 resolution → Task 7 step 4 native-res pass ✓

**2. Placeholder scan:** No TBD/TODO; every step has full code or exact commands. ✓

**3. Type consistency:** `config.MainColor`/`UIFont`/`RainFont`/`RainFps`/`RainColumnWidth`/`ClockOpacity`/`HourFormat`/`DateFormat`/`SessionLabel` defined in `theme.conf` (Task 1) and consumed consistently. SDDM API (`sddm.login`, `sddm.canPowerOff/canReboot/canSuspend`, `sddm.powerOff/reboot/suspend`, `onLoginFailed`, `userModel.lastUser`, `sessionModel.lastIndex`, `keyboard.capsLock`) matches the verified Candy usage. `// SLOT-RAIN/CLOCK/LOGIN/POWER` markers in Task 1 are each replaced exactly once in Tasks 2/5/4/6. ✓
