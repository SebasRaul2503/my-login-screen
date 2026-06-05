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
