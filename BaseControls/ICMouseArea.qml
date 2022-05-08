import QtQuick 2.0
 import QtQuick.Controls 2.5

MouseArea {
    id:root
    anchors.fill: parent


    acceptedButtons: Qt.LeftButton | Qt.RightButton

    property real lastX: 0
    property real lastY: 0


    property bool isPressed: false

    signal mouseClick(variant obj)
    signal deletaParent(variant obj)

    Popup {
        id: popup
        x: parent.width
        y: parent.height
//        modal: true
        focus: true
        width: menu.width + 20
        height: menu.height + 20
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Column{
            id:menu
            spacing: 2
            MenuItem{
                text: qsTr("删除")
                onTriggered: {
                    deletaParent(root.parent)
                }
            }
            MenuItem{
                text: qsTr("下移一层")
                onTriggered: {

                }
            }
            MenuItem{
                text: qsTr("上移一层")
                onTriggered: {

                }
            }
            MenuItem{
                text: qsTr("复制")
            }
        }


    }

    onPressed: {
        lastX = mouseX
        lastY = mouseY
        isPressed = true
    }

    onPositionChanged: {
        if(isPressed){
            parent.x += mouseX - lastX
            parent.y += mouseY - lastY
        }
    }

    onReleased: {
        isPressed = false
    }


    onClicked: {
        mouseClick(parent)
        if(mouse.button ==  Qt.RightButton){
            popup.open()
        }
    }



}
