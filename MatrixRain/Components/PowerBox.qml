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

        // Nerd Font glyphs:  power-off,  restart,  moon/suspend
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
