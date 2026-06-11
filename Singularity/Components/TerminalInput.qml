import QtQuick 2.11
import QtQuick.Controls 2.4

// HUD-styled input: dark glass, cyan hairline, amber text + caret.
TextField {
    id: field

    property color accent: config.Accent || "#ffae5c"
    property color border0: config.InputBorder || "#2c3a52"

    color: accent
    font.family: config.UIFont
    selectByMouse: true
    renderType: Text.QtRendering
    leftPadding: 12
    rightPadding: 12
    topPadding: 7
    bottomPadding: 7
    passwordCharacter: "•"
    selectionColor: Qt.rgba(0.49, 0.78, 1.0, 0.35)
    selectedTextColor: "#ffffff"

    background: Rectangle {
        color: config.InputBackground || "#0c1020"
        radius: 2
        border.color: field.activeFocus ? field.accent : field.border0
        border.width: field.activeFocus ? 2 : 1

        // focus underline accent
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: field.accent
            opacity: field.activeFocus ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }
}
