import QtQuick 2.11

// Four L-shaped HUD corner brackets, overlaid on a panel (anchors.fill).
Item {
    id: ticks
    property color color: "#ffae5c"
    property int len: 13
    property int thick: 1

    // top-left
    Rectangle { x: 0; y: 0; width: ticks.len; height: ticks.thick; color: ticks.color }
    Rectangle { x: 0; y: 0; width: ticks.thick; height: ticks.len; color: ticks.color }
    // top-right
    Rectangle { x: ticks.width - ticks.len; y: 0; width: ticks.len; height: ticks.thick; color: ticks.color }
    Rectangle { x: ticks.width - ticks.thick; y: 0; width: ticks.thick; height: ticks.len; color: ticks.color }
    // bottom-left
    Rectangle { x: 0; y: ticks.height - ticks.thick; width: ticks.len; height: ticks.thick; color: ticks.color }
    Rectangle { x: 0; y: ticks.height - ticks.len; width: ticks.thick; height: ticks.len; color: ticks.color }
    // bottom-right
    Rectangle { x: ticks.width - ticks.len; y: ticks.height - ticks.thick; width: ticks.len; height: ticks.thick; color: ticks.color }
    Rectangle { x: ticks.width - ticks.thick; y: ticks.height - ticks.len; width: ticks.thick; height: ticks.len; color: ticks.color }
}
