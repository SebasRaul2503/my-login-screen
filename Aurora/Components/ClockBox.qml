import QtQuick 2.11

// Mission-timer clock: big hour, date + session readout, HUD corner ticks.
Rectangle {
    id: clockBox

    property color accent:  config.Accent  || "#ffae5c"
    property color accent2: config.Accent2 || "#7cc7ff"

    radius: 3
    color: Qt.rgba(0.027, 0.039, 0.071, 0.55)
    border.color: Qt.rgba(0.49, 0.78, 1.0, 0.22)
    border.width: 1
    implicitWidth: col.implicitWidth + 36
    implicitHeight: col.implicitHeight + 26

    CornerTicks { anchors.fill: parent; color: clockBox.accent2 }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: "● HORA LOCAL"
            color: clockBox.accent2
            opacity: 0.7
            font.family: config.UIFont
            font.pointSize: 8
            font.letterSpacing: 2
        }
        Text {
            id: timeLabel
            font.family: config.UIFont
            font.pointSize: 34
            font.bold: true
            color: clockBox.accent
        }
        Text {
            id: dateLabel
            font.family: config.UIFont
            font.pointSize: 10
            font.letterSpacing: 1
            color: clockBox.accent2
            opacity: 0.85
        }
    }

    function updateTime() {
        var now = new Date()
        timeLabel.text = now.toLocaleTimeString(Qt.locale(), config.HourFormat || "HH:mm")
        var d = now.toLocaleDateString(Qt.locale(), config.DateFormat || "ddd dd MMM")
        dateLabel.text = (d + "   ·   " + (config.SessionLabel || "")).toUpperCase()
    }

    Timer { interval: 1000; repeat: true; running: true; onTriggered: clockBox.updateTime() }
    Component.onCompleted: updateTime()
}
