import QtQuick


Item {
    id: connectionLine

    // 属性声明
    property var sourceNode: null
    property var sourcePoint: null
    property var targetNode: null
    property var targetPoint: null
    property point startPos: Qt.point(0, 0)
    property point endPos: Qt.point(100, 100)
    property color lineColor: "#404040"
    property int lineWidth: 2
    property bool isActive: false

    // 设置连接线的起止点
    function setConnection(source, sourceP, target, targetP) {
        sourceNode = source
        sourcePoint = sourceP
        targetNode = target
        targetPoint = targetP

        if (sourceNode)
            sourceNode.addConnection(connectionLine)
        if (targetNode)
            targetNode.addConnection(connectionLine)

        updatePosition()
    }

    // 更新连接线的位置
    function updatePosition() {
        if (!sourcePoint || !targetPoint)
            return

        // 获取源连接点在画布上的全局位置
        var sourceGlobalPos = sourcePoint.mapToItem(connectionLine.parent,
                                                    sourcePoint.width / 2,
                                                    sourcePoint.height / 2)

        // 获取目标连接点在画布上的全局位置
        var targetGlobalPos = targetPoint.mapToItem(connectionLine.parent,
                                                    targetPoint.width / 2,
                                                    targetPoint.height / 2)

        startPos = sourceGlobalPos
        endPos = targetGlobalPos

        canvas.requestPaint()
    }

    // 设置临时端点（用于拖拽时）
    function setTemporaryEndPoint(point) {
        endPos = point
        canvas.requestPaint()
    }

    // 释放连接线资源
    function release() {
        if (sourceNode)
            sourceNode.removeConnection(connectionLine)
        if (targetNode)
            targetNode.removeConnection(connectionLine)
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            // 设置线条样式
            ctx.strokeStyle = connectionLine.isActive ? Qt.darker(
                                                            lineColor,
                                                            1.5) : lineColor
            ctx.lineWidth = connectionLine.lineWidth

            // 绘制贝塞尔曲线
            ctx.beginPath()
            ctx.moveTo(startPos.x, startPos.y)

            // 控制点计算 - 创建平滑的曲线
            var controlPointOffset = 80
            var cp1x = startPos.x + controlPointOffset
            var cp1y = startPos.y
            var cp2x = endPos.x - controlPointOffset
            var cp2y = endPos.y

            ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, endPos.x, endPos.y)
            ctx.stroke()

            // 绘制箭头
            var angle = Math.atan2(endPos.y - cp2y, endPos.x - cp2x)
            var arrowSize = 10

            ctx.beginPath()
            ctx.moveTo(endPos.x, endPos.y)
            ctx.lineTo(endPos.x - arrowSize * Math.cos(angle - Math.PI / 6),
                       endPos.y - arrowSize * Math.sin(angle - Math.PI / 6))
            ctx.lineTo(endPos.x - arrowSize * Math.cos(angle + Math.PI / 6),
                       endPos.y - arrowSize * Math.sin(angle + Math.PI / 6))
            ctx.closePath()
            ctx.fillStyle = lineColor
            ctx.fill()
        }
    }

    // 检测鼠标悬停以高亮显示
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            connectionLine.isActive = true
            canvas.requestPaint()
        }
        onExited: {
            connectionLine.isActive = false
            canvas.requestPaint()
        }
        onDoubleClicked: {
            // 删除连接
            connectionLine.release()
            connectionLine.destroy()
        }
    }
}
