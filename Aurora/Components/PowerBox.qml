import QtQuick 2.11

// HUD power controls: nerd-font glyphs, cyan hairline separators.
// Always visible; dimmed + inert when an action is unavailable.
Rectangle {
    id: powerBox

    property color accent:  config.Accent  || "#ffae5c"
    property color accent2: config.Accent2 || "#7cc7ff"

    radius: 3
    color: Qt.rgba(0.027, 0.039, 0.071, 0.55)
    border.color: Qt.rgba(0.49, 0.78, 1.0, 0.22)
    border.width: 1
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    CornerTicks { anchors.fill: parent; color: powerBox.accent2 }

    Row {
        id: row

        // Nerd Font glyphs:  power-off,  restart,  moon/suspend
        property var actions: [
            { glyph: "", enabled: sddm.canPowerOff, kind: "off" },
            { glyph: "", enabled: sddm.canReboot,   kind: "reboot" },
            { glyph: "", enabled: sddm.canSuspend,  kind: "suspend" }
        ]

        Repeater {
            model: row.actions
            delegate: Rectangle {
                width: 52
                height: 44
                opacity: modelData.enabled ? 1.0 : 0.28
                color: (modelData.enabled && hover.containsMouse)
                       ? Qt.rgba(1.0, 0.68, 0.36, 0.14) : "transparent"

                Rectangle {
                    visible: index > 0
                    width: 1
                    height: parent.height * 0.55
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(0.49, 0.78, 1.0, 0.25)
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.glyph
                    font.family: config.UIFont
                    font.pointSize: 15
                    color: hover.containsMouse ? powerBox.accent : powerBox.accent2
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: modelData.enabled
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
