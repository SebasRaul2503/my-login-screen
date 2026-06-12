import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import "Components"

// Aurora — a real-time aurora-borealis greeter.
// A still arctic night: light curtains over a starfield, mountains, a mirror lake.
Pane {
    id: root

    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width
    padding: 0
    palette.window: "#04060f"
    font.family: config.UIFont
    focus: true

    Item {
        id: stage
        anchors.fill: parent

        Rectangle { anchors.fill: parent; color: "#04060f" }

        // --- the aurora sky, rendered in GLSL ---
        AuroraSky {
            id: auroraSky
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
                radius: 8; samples: 17; spread: 0.1
                color: "#0f5a47"; transparentBorder: true
            }
        }

        // --- access panel (centered, over the calm sky) ---
        LoginForm {
            id: loginForm
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -12
            z: 3
            layer.enabled: true
            layer.effect: Glow {
                radius: 12; samples: 25; spread: 0.12
                color: "#0f5a47"; transparentBorder: true
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
                radius: 8; samples: 17; spread: 0.1
                color: "#0f5a47"; transparentBorder: true
            }
        }
    }
}
