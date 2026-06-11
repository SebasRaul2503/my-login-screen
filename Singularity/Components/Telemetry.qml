import QtQuick 2.11

// Faux instrument readout — pure flavor, dim so it never competes with the panel.
Rectangle {
    id: tel
    property color accent:  config.Accent  || "#ffae5c"
    property color accent2: config.Accent2 || "#7cc7ff"

    radius: 3
    color: Qt.rgba(0.027, 0.039, 0.071, 0.45)
    border.color: Qt.rgba(0.49, 0.78, 1.0, 0.16)
    border.width: 1
    implicitWidth: col.implicitWidth + 28
    implicitHeight: col.implicitHeight + 22

    CornerTicks { anchors.fill: parent; color: tel.accent2; len: 10 }

    function row(label, value) {
        var pad = "                       "
        var l = (label + pad).substring(0, 16)
        return l + value
    }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 3

        Text {
            text: "◢ TELEMETRÍA"
            color: tel.accent; opacity: 0.85
            font.family: config.UIFont; font.pointSize: 8.5; font.bold: true; font.letterSpacing: 2
        }
        Text { text: tel.row("HORIZONTE", "ESTABLE");   color: tel.accent2; opacity: 0.7; font.family: config.UIFont; font.pointSize: 9 }
        Text { text: tel.row("DISCO", "9.7×10³ K");      color: tel.accent2; opacity: 0.7; font.family: config.UIFont; font.pointSize: 9 }
        Text { text: tel.row("LENTE GRAV.", "ACTIVA");   color: tel.accent2; opacity: 0.7; font.family: config.UIFont; font.pointSize: 9 }

        Row {
            spacing: 7
            Text {
                id: dot
                text: "●"; color: "#7cffa0"; font.pointSize: 9
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.2; duration: 900 }
                    NumberAnimation { from: 0.2; to: 1.0; duration: 900 }
                }
            }
            Text {
                text: "ENLACE SEGURO"
                color: tel.accent2; opacity: 0.75
                font.family: config.UIFont; font.pointSize: 9; font.letterSpacing: 1
            }
        }
    }
}
