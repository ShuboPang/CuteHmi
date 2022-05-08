import QtQuick 2.12
import QtQuick.Window 2.12

import "./BaseControls/BaseControls.js" as BaseControlsJs
import "./BaseControls"

Window {
    width: 1280
    height: 1024
    visible: true
    title: qsTr("Hello World")



    Item {
        id: controlsSelArea
        width: 400
        height: parent.height/2
        anchors.right: parent.right

        ListView{
            id:uiControlsListView
            width: parent.width
            height: parent.height
            clip: true
            model: BaseControlsJs.custom_ui
            delegate: Rectangle{
                width: parent.width
                height: 30
                color: uiControlsListView.currentIndex == index?"yellow":"gray"
                Text {
                    anchors.fill:parent
                    text: BaseControlsJs.custom_ui[index].ui_name
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        uiControlsListView.currentIndex = index
                    }
                }
            }
        }

    }
    Rectangle{
        id:line
        width: controlsSelArea.width
        anchors.top:controlsSelArea.bottom
        anchors.right: controlsSelArea.right

        height: 1
        color: "black"
    }

    Item {
        id: controlsPropertyArea
        width: controlsSelArea.width
        anchors.top:line.bottom
        height: parent.height/2 - line.height
        anchors.right: line.right

        clip: true

        property variant currentSubObject: null


        ListModel{
            id:subObjPropertyListModel
        }
        ListView{
            id:subObjPropertyListView
            width: parent.width
            height: parent.height
            clip: true
            model: subObjPropertyListModel
            delegate: Rectangle{
                width: parent.width
                height: 30
                Row{
                    height: parent.height
                    Text {
                        width: 200
                        text: propertyId
                    }
                    Rectangle{
                        height: parent.height
                        width: 1
                        color: "gray"
                    }
                    //                    Text {
                    //                        width: 200
                    //                        text: propertyValue
                    //                    }
                    TextInput{
                        width: 200
                        text: propertyValue
                        onEditingFinished: {
                            controlsPropertyArea.currentSubObject[propertyId] = text
                        }
                    }
                }
            }
        }
        ICButton{
            text: qsTr("编译运行")
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            onClicked: {
                tryRunPage.compileHmi()
                tryRunPage.visible = true
            }
        }
    }


    Rectangle {
        id: root
        //        anchors.fill: parent
        width: parent.width - controlsSelArea.width
        height: parent.height
        border.color: "black"
        border.width: 1

        property variant subObject: []


        function subObjectMouseClick(subObj){
            console.log("有个对象被按压了")
            subObjPropertyListModel.clear()
            for( var i in subObj){
                if(typeof subObj[i] == "object" || typeof subObj[i] == "function")
                    continue
                subObjPropertyListModel.append({"propertyId":i+"","propertyValue":subObj[i]+""})
            }
            controlsPropertyArea.currentSubObject = subObj
        }

        function subObjectDestroy(subObj){


            subObj.destroy()
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                var tempSubObject = root.subObject
                var ret = BaseControlsJs.createQmlObject(root,BaseControlsJs.custom_ui[uiControlsListView.currentIndex].ui_url,{"x":mouseX-root.x,"y":mouseY-root.y,"z":1});
                if(ret != null){
                    tempSubObject.push({"url":BaseControlsJs.custom_ui[uiControlsListView.currentIndex].ui_url,"obj":ret})
                    root.subObject = tempSubObject
                }
            }
        }
    }
    Window{
        id:tryRunPage
        title: qsTr("试行界面")
        width: root.width
        height: root.height

        function compileHmi(){
            var sub = tryRunPageRoot.children

            for(let i = 0;i<sub.length;i++){
                sub[i].destroy()
            }
            sub = root.subObject
            for(let i = 0;i<sub.length;i++){
                BaseControlsJs.createComplieQmlObject(tryRunPageRoot,sub[i].url,{"x":sub[i].obj.x,"y":sub[i].obj.y});
            }
        }

        Item {
            id: tryRunPageRoot
            width: parent.width
            height: parent.height

        }
    }
}
