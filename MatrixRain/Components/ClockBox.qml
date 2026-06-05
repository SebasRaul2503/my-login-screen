import QtQuick 2.11

Rectangle {
    id: clockBox

    property color accent: config.MainColor || "#00ff41"

    opacity: parseFloat(config.ClockOpacity) || 0.75
    color: Qt.rgba(0, 0.03, 0, 0.6)
    border.color: Qt.rgba(0, 1, 0.25, 0.35)
    border.width: 1
    implicitWidth: col.implicitWidth + 32
    implicitHeight: col.implicitHeight + 24

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: timeLabel
            font.family: config.UIFont
            font.pointSize: 30
            color: clockBox.accent
        }
        Text {
            id: dateLabel
            font.family: config.UIFont
            font.pointSize: 11
            color: clockBox.accent
        }
    }

    function updateTime() {
        var now = new Date()
        timeLabel.text = now.toLocaleTimeString(Qt.locale(), config.HourFormat || "HH:mm")
        var d = now.toLocaleDateString(Qt.locale(), config.DateFormat || "ddd dd MMM")
        dateLabel.text = (d + "  ·  " + (config.SessionLabel || "")).toUpperCase()
    }

    Timer { interval: 1000; repeat: true; running: true; onTriggered: clockBox.updateTime() }
    Component.onCompleted: updateTime()
}
