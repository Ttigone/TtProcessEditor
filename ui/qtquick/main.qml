import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

import GraphView 1.0

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        ToolBar {
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                Button {
                    text: qsTr("添加节点")
                    onClicked: {

                    }
                }
                Button {
                    text: qsTr("清楚所有节点")
                    onClicked: {

                    }
                }
                // 占位符, 将button 压缩到左边
                Item {
                    Layout.fillWidth: true
                }
            }
        }
        GraphEditor {
            id: graphEditor
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
