import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "Components"

// Singularity — a real-time gravitational black hole greeter.
// Left: a control console (clock, access panel, telemetry).
// Right: a viewport onto the singularity itself.
Pane {
    id: root

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width
    padding: 0
    palette.window: "#03040a"
    font.family: config.UIFont
    focus: true

    Item {
        id: stage
        anchors.fill: parent

        Rectangle { anchors.fill: parent; color: "#03040a" }

        // --- the black hole, rendered in GLSL ---
        BlackHole {
            id: blackHole
            anchors.fill: parent
            z: 0
        }

        // --- clock (top-left) ---
        ClockBox {
            id: clockBox
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 48
            anchors.topMargin: 44
            z: 2
            layer.enabled: true
            layer.effect: Glow {
                radius: 7; samples: 15; spread: 0.1
                color: "#3a6ea5"; transparentBorder: true
            }
        }

        // --- access panel (center-left, in the calm dark zone) ---
        LoginForm {
            id: loginForm
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.10
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 24
            z: 3
            layer.enabled: true
            layer.effect: Glow {
                radius: 11; samples: 23; spread: 0.12
                color: "#3a6ea5"; transparentBorder: true
            }
        }

        // --- telemetry (bottom-left) ---
        Telemetry {
            id: telemetry
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 48
            anchors.bottomMargin: 44
            z: 2
            layer.enabled: true
            layer.effect: Glow {
                radius: 6; samples: 13; spread: 0.1
                color: "#3a6ea5"; transparentBorder: true
            }
        }

        // --- power (bottom-right) ---
        PowerBox {
            id: powerBox
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 48
            anchors.bottomMargin: 44
            z: 2
            layer.enabled: true
            layer.effect: Glow {
                radius: 7; samples: 15; spread: 0.1
                color: "#3a6ea5"; transparentBorder: true
            }
        }
    }
}
