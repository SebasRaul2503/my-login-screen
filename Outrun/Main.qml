import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "Components"

// Outrun — a synthwave sunset greeter.
// Left: the dashboard (clock, access panel). Right: neon sun + endless grid.
Pane {
    id: root

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width
    padding: 0
    palette.window: "#0a0418"
    font.family: config.UIFont
    focus: true

    Item {
        id: stage
        anchors.fill: parent

        Rectangle { anchors.fill: parent; color: "#0a0418" }

        // --- synthwave sunset, rendered in GLSL ---
        Synthwave {
            id: synth
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
                radius: 8; samples: 17; spread: 0.12
                color: "#6a1f8a"; transparentBorder: true
            }
        }

        // --- access panel (center-left, over the dark sky) ---
        LoginForm {
            id: loginForm
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.09
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 18
            z: 3
            layer.enabled: true
            layer.effect: Glow {
                radius: 12; samples: 25; spread: 0.14
                color: "#6a1f8a"; transparentBorder: true
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
                radius: 8; samples: 17; spread: 0.12
                color: "#6a1f8a"; transparentBorder: true
            }
        }
    }
}
