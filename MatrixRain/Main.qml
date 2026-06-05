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

        MatrixRain {
            id: matrixRain
            anchors.fill: parent
            z: 0
        }
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
    }
}
