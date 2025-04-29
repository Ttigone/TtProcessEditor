import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    // ColumnLayout {
    //     anchors.centerIn: parent
    //     spacing: 10
    //     Button {
    //         text: qsTr("Check State")
    //         onClicked: {
    //             result.text = "My Name is Kambiz!";
    //             console.log("Hello, Kambiz!")
    //         }
    //     }
    //     Text {
    //         id: result
    //     }
    // }
    // Canvas {
    //     width: 200
    //     height: 200
    //     onPaint: {
    //         var ctx = getContext("2d")
    //         ctx.fillStyle = "green"
    //         ctx.fillRect(10, 10, 50, 50)
    //     }
    // }
    // Canvas {
    //     id: gridCanvas
    //     anchors.fill: parent

    //     // 网格属性
    //     property int gridSize: 20
    //     property color gridColor: Qt.rgba(0.7, 0.7, 0.7, 0.5)
    //     property bool gridVisible: true

    //     // 当大小变化或需要重绘时
    //     onPaint: {
    //         if (!gridVisible)
    //             return

    //         var ctx = getContext("2d")
    //         ctx.clearRect(0, 0, width, height)
    //         ctx.strokeStyle = gridColor
    //         ctx.lineWidth = 1

    //         // 绘制垂直线
    //         for (var x = 0; x <= width; x += gridSize) {
    //             ctx.beginPath()
    //             ctx.moveTo(x, 0)
    //             ctx.lineTo(x, height)
    //             ctx.stroke()
    //         }

    //         // 绘制水平线
    //         for (var y = 0; y <= height; y += gridSize) {
    //             ctx.beginPath()
    //             ctx.moveTo(0, y)
    //             ctx.lineTo(width, y)
    //             ctx.stroke()
    //         }
    //     }

    //     // 当属性改变时触发重绘
    //     onGridSizeChanged: requestPaint()
    //     onGridColorChanged: requestPaint()
    //     onGridVisibleChanged: requestPaint()
    //     onWidthChanged: requestPaint()
    //     onHeightChanged: requestPaint()
    // }
    Item {
        id: graphicsView
        anchors.fill: parent
        clip: true

        // 网格属性
        property int gridSize: 20
        property color gridColor: Qt.rgba(0.7, 0.7, 0.7, 0.5)
        property bool gridVisible: true
        property real viewScale: 1.0

        // 可缩放和平移的视图
        Flickable {
            id: viewportFlickable
            anchors.fill: parent
            contentWidth: contentItem.width * viewScale
            contentHeight: contentItem.height * viewScale
            interactive: true

            // 缩放项
            Item {
                id: zoomContainer
                width: contentItem.width
                height: contentItem.height
                scale: viewScale
                transformOrigin: Item.TopLeft

                // 网格绘制
                Canvas {
                    id: gridCanvas
                    anchors.fill: parent
                    visible: gridVisible

                    property int gridSize: 20
                    property color gridColor: Qt.rgba(0.7, 0.7, 0.7, 0.5)

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = gridColor
                        ctx.lineWidth = 1 / viewScale // 调整线宽以适应缩放

                        // 绘制垂直线
                        for (var x = 0; x <= width; x += gridSize) {
                            ctx.beginPath()
                            ctx.moveTo(x, 0)
                            ctx.lineTo(x, height)
                            ctx.stroke()
                        }

                        // 绘制水平线
                        for (var y = 0; y <= height; y += gridSize) {
                            ctx.beginPath()
                            ctx.moveTo(0, y)
                            ctx.lineTo(width, y)
                            ctx.stroke()
                        }
                    }

                    // 属性变化时重绘
                    onGridSizeChanged: requestPaint()
                    onGridColorChanged: requestPaint()
                }

                // 内容项 - 添加你的元素
                Item {
                    id: contentItem
                    width: 2000
                    height: 2000
                    // 这里添加你的图形元素
                    Rectangle {
                        anchors.fill: parent
                        Text {
                            text: "测试"
                        }
                    }
                }
            }
        }

        // 缩放控制器
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            spacing: 5

            Button {
                text: "+"
                onClicked: viewScale *= 1.2
            }

            Button {
                text: "-"
                onClicked: viewScale /= 1.2
            }

            Button {
                text: "1:1"
                onClicked: viewScale = 1.0
            }
        }

        // 当缩放变化时，更新网格
        onViewScaleChanged: gridCanvas.requestPaint()
    }
}
