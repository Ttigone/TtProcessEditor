import QtQuick

// 可拖拽节点
Rectangle {
    id: nodeRoot
    width: 100
    height: 80
    radius: 5
    border.width: 2
    border.color: "black"
    color: mouseArea.containsMouse ? Qt.lighter(baseColor, 1.1) : baseColor

    // 属性声明
    property string nodeName: "Node"
    property string nodeId: Math.random().toString()
    property color baseColor: "#80c4de"
    property bool isDragging: mouseArea.drag.active
    property var connectionPoints: [] // 存储连接点
    property var connectedLines: [] // 存储已连接的线

    // 信号声明
    signal nodeSelected(var node)
    signal startConnectionDrag(var sourceNode, var sourcePoint, var mouse)
    signal connectionDropped(var sourceNode, var sourcePoint, var targetNode, point targetPosition)

    // 节点文本
    Text {
        anchors.centerIn: parent
        text: nodeName
        font.pixelSize: 14
    }

    // 拖拽行为
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        drag.target: parent
        drag.smoothed: true

        onPressed: {
            nodeRoot.z = 10 // 确保被拖拽的节点位于顶层
            nodeSelected(nodeRoot)
        }

        onReleased: {
            nodeRoot.z = 1
        }

        onClicked: {
            nodeSelected(nodeRoot)
        }
    }

    // 连接点 - 左侧
    Rectangle {
        id: leftConnector
        width: 12
        height: 12
        radius: 6
        color: "darkgray"
        border.color: "black"
        border.width: 1
        x: -width / 2
        y: parent.height / 2 - height / 2

        // 此连接点的唯一ID
        property string pointId: "left"
        property string direction: "input"

        Component.onCompleted: {
            connectionPoints.push({
                                      "point": leftConnector,
                                      "id": pointId,
                                      "direction": direction
                                  })
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                mouse.accepted = true
                startConnectionDrag(nodeRoot, leftConnector, mouse)
            }
        }
    }

    // 连接点 - 右侧
    Rectangle {
        id: rightConnector
        width: 12
        height: 12
        radius: 6
        color: "darkgray"
        border.color: "black"
        border.width: 1
        x: parent.width - width / 2
        y: parent.height / 2 - height / 2

        // 此连接点的唯一ID
        property string pointId: "right"
        property string direction: "output"

        Component.onCompleted: {
            connectionPoints.push({
                                      "point": rightConnector,
                                      "id": pointId,
                                      "direction": direction
                                  })
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                mouse.accepted = true
                startConnectionDrag(nodeRoot, rightConnector, mouse)
            }
        }
    }

    // 当节点移动时更新连线
    onXChanged: updateConnections()
    onYChanged: updateConnections()

    // 更新所有相连的线
    function updateConnections() {
        for (var i = 0; i < connectedLines.length; i++) {
            connectedLines[i].updatePosition()
        }
    }

    // 添加连接线的引用
    function addConnection(line) {
        connectedLines.push(line)
    }

    // 移除连接线的引用
    function removeConnection(line) {
        var index = connectedLines.indexOf(line)
        if (index !== -1) {
            connectedLines.splice(index, 1)
        }
    }
}
