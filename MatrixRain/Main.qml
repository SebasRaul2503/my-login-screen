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
        // SLOT-CLOCK
        LoginForm {
            id: loginForm
            anchors.centerIn: parent
            z: 2
        }
        // SLOT-POWER
    }
}
