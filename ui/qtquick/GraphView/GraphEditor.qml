import QtQuick

// Item {

// }
Rectangle {
    id: editorRoot
    width: 800
    height: 600
    color: "#f0f0f0"

    // 属性声明
    property var nodes: []
    property var connections: []
    property var activeNode: null
    property var temporaryConnection: null
    property var dragSourceNode: null
    property var dragSourcePoint: null

    // 网格背景
    Canvas {
        id: gridCanvas
        anchors.fill: parent

        property int gridSize: 20
        property color gridColor: "#e0e0e0"

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            // 绘制垂直线
            for (var x = 0; x <= width; x += gridSize) {
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.strokeStyle = gridColor
                ctx.stroke()
            }

            // 绘制水平线
            for (var y = 0; y <= height; y += gridSize) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.strokeStyle = gridColor
                ctx.stroke()
            }
        }
    }

    // 节点容器
    Item {
        id: nodesContainer
        anchors.fill: parent
    }

    // 连接线容器
    Item {
        id: connectionsContainer
        anchors.fill: parent
    }

    // 临时连接线（用于拖拽过程中显示）
    Item {
        id: tempConnectionContainer
        anchors.fill: parent
    }

    // 处理空白处点击
    MouseArea {
        anchors.fill: parent
        z: -1 // 确保在其他元素下方

        onClicked: {
            // 取消选中
            if (activeNode) {
                activeNode = null
            }
        }

        onDoubleClicked: {
            // 在点击处创建新节点
            createNodeAt(mouse.x, mouse.y)
        }
    }

    // 处理连线拖拽的全局MouseArea
    MouseArea {
        id: connectionDragArea
        anchors.fill: parent
        enabled: false
        z: 1000 // 确保它在顶层

        onPositionChanged: {
            if (temporaryConnection) {
                // 更新临时连接线的终点为当前鼠标位置
                temporaryConnection.setTemporaryEndPoint(Qt.point(mouse.x,
                                                                  mouse.y))
            }
        }

        onReleased: {
            enabled = false

            // 检查是否放在了有效的连接点上
            var targetNode = null
            var targetPoint = null

            // 遍历所有节点检查碰撞
            for (var i = 0; i < nodes.length; i++) {
                var node = nodes[i]
                if (node === dragSourceNode)
                    continue // 跳过源节点

                // 检查每个连接点
                for (var j = 0; j < node.connectionPoints.length; j++) {
                    var connPoint = node.connectionPoints[j]
                    var point = connPoint.point

                    // 将鼠标坐标转换到连接点的局部坐标系
                    var localPoint = point.mapFromItem(connectionDragArea,
                                                       mouse.x, mouse.y)

                    // 检查点是否在连接点区域内
                    if (localPoint.x >= 0 && localPoint.x <= point.width
                            && localPoint.y >= 0
                            && localPoint.y <= point.height) {

                        // 检查连接点方向是否兼容
                        if ((dragSourcePoint.direction === "output"
                             && connPoint.direction === "input")
                                || (dragSourcePoint.direction === "input"
                                    && connPoint.direction === "output")) {
                            targetNode = node
                            targetPoint = point
                            break
                        }
                    }
                }
                if (targetNode)
                    break
            }

            // 如果找到目标节点和连接点，创建实际的连接
            if (targetNode && targetPoint) {
                createConnection(dragSourceNode, dragSourcePoint, targetNode,
                                 targetPoint)
            }

            // 清理临时连接线
            if (temporaryConnection) {
                temporaryConnection.destroy()
                temporaryConnection = null
            }

            // 重置拖拽状态
            dragSourceNode = null
            dragSourcePoint = null
        }
    }

    // 创建新节点
    function createNodeAt(x, y) {
        var component = Qt.createComponent("NodeItem.qml")
        if (component.status === Component.Ready) {
            var node = component.createObject(nodesContainer, {
                                                  "x": x - 50,
                                                  "y"// 居中放置
                                                  : y - 40,
                                                  "nodeName": "Node " + (nodes.length + 1)
                                              })

            // 连接节点信号
            node.nodeSelected.connect(function (selectedNode) {
                activeNode = selectedNode
            })

            node.startConnectionDrag.connect(startConnectionDrag)

            // 注册到节点列表
            nodes.push(node)
        }
    }

    // 开始连接拖拽
    function startConnectionDrag(sourceNode, sourcePoint, mouse) {
        // 设置拖拽状态
        dragSourceNode = sourceNode
        dragSourcePoint = sourcePoint

        // 创建临时连接线
        var component = Qt.createComponent("ConnectionLine.qml")
        if (component.status === Component.Ready) {
            temporaryConnection = component.createObject(
                        tempConnectionContainer)

            // 获取源连接点在画布上的位置
            var sourceGlobalPos = sourcePoint.mapToItem(
                        tempConnectionContainer, sourcePoint.width / 2,
                        sourcePoint.height / 2)

            // 设置连接线的起点和初始终点
            temporaryConnection.startPos = sourceGlobalPos
            temporaryConnection.endPos = Qt.point(mouse.x, mouse.y)
            temporaryConnection.width = tempConnectionContainer.width
            temporaryConnection.height = tempConnectionContainer.height
        }

        // 激活拖拽区域
        connectionDragArea.enabled = true
    }

    // 创建永久连接
    function createConnection(sourceNode, sourcePoint, targetNode, targetPoint) {
        // 确认方向兼容性
        var isSourceOutput = sourcePoint.direction === "output"
        var startNode = isSourceOutput ? sourceNode : targetNode
        var startPoint = isSourceOutput ? sourcePoint : targetPoint
        var endNode = isSourceOutput ? targetNode : sourceNode
        var endPoint = isSourceOutput ? targetPoint : sourcePoint

        // 检查是否已存在相同的连接
        for (var i = 0; i < connections.length; i++) {
            var conn = connections[i]
            if ((conn.sourceNode === startNode && conn.sourcePoint
                 === startPoint && conn.targetNode === endNode && conn.targetPoint
                 === endPoint) || (conn.sourceNode === endNode && conn.sourcePoint
                                   === endPoint && conn.targetNode
                                   === startNode && conn.targetPoint === startPoint)) {
                return // 连接已存在，直接返回
            }
        }

        // 创建新的连接线
        var component = Qt.createComponent("ConnectionLine.qml")
        if (component.status === Component.Ready) {
            var connection = component.createObject(connectionsContainer)
            connection.width = connectionsContainer.width
            connection.height = connectionsContainer.height
            connection.setConnection(startNode, startPoint, endNode, endPoint)

            // 注册到连接列表
            connections.push(connection)
        }
    }

    // 清除所有节点和连接
    function clearAll() {
        // 删除所有连接
        for (var i = 0; i < connections.length; i++) {
            connections[i].destroy()
        }
        connections = []

        // 删除所有节点
        for (var j = 0; j < nodes.length; j++) {
            nodes[j].destroy()
        }
        nodes = []
    }
}
