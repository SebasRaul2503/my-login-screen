import QtQuick 2.11

Item {
    id: rain

    property color rainColor: config.MainColor || "#00ff41"
    property string fontFamily: config.RainFont || "monospace"
    property int columnWidth: parseInt(config.RainColumnWidth) || 14
    property int fps: parseInt(config.RainFps) || 30

    property string glyphs: "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    property var drops: []
    property int columns: 0

    function initDrops() {
        columns = Math.max(1, Math.floor(width / columnWidth))
        var d = []
        for (var i = 0; i < columns; i++)
            d[i] = Math.floor(Math.random() * -50)
        drops = d
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = "rgba(0,0,0,0.07)"
            ctx.fillRect(0, 0, width, height)
            ctx.fillStyle = rain.rainColor
            ctx.font = rain.columnWidth + "px '" + rain.fontFamily + "'"
            for (var i = 0; i < rain.columns; i++) {
                var ch = rain.glyphs.charAt(Math.floor(Math.random() * rain.glyphs.length))
                var y = rain.drops[i] * rain.columnWidth
                ctx.fillText(ch, i * rain.columnWidth, y)
                if (y > rain.height && Math.random() > 0.975)
                    rain.drops[i] = 0
                rain.drops[i]++
            }
        }
    }

    Timer {
        interval: 1000 / rain.fps
        repeat: true
        running: true
        onTriggered: canvas.requestPaint()
    }

    onWidthChanged: initDrops()
    onHeightChanged: initDrops()
    Component.onCompleted: initDrops()
}
