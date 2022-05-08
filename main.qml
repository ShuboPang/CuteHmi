import QtQuick 2.12
import QtQuick.Window 2.12
 import QtQuick.Controls 2.5

import "./BaseControls/BaseControls.js" as BaseControlsJs
import "./BaseControls/."

ApplicationWindow {
    width: 1280
    height: 768
    visible: true
    title: qsTr("Hello World")
//    flags: Qt.Window | Qt.CustomizeWindowHint
//    header: ToolBar {
////        visible: false
//        width: parent.width
//        height: 60
//        font.pointSize: 12
//        font.bold: true
//        Row{
//            anchors.verticalCenter: parent.verticalCenter
//            spacing: 4
//        }
//    }

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

        property int currentSubObject: -1


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
                            root.subObject[controlsPropertyArea.currentSubObject].obj[propertyId] = text
                            var tempSubObject = root.subObject
                            var tempChangedProperty = JSON.parse(tempSubObject[controlsPropertyArea.currentSubObject].changedProperty)
                            if(tempChangedProperty.indexOf(propertyId) == -1){
                                tempChangedProperty.push(propertyId)
                                tempSubObject[controlsPropertyArea.currentSubObject].changedProperty = JSON.stringify(tempChangedProperty)
                                root.subObject = tempSubObject
                                console.log("tempChangedProperty",tempChangedProperty)
                            }

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
//        width: parent.width - controlsSelArea.width
//        height: parent.height
        width: 800
        height: 600
        border.color: "black"
        border.width: 1

        property variant subObject: []

        //< 控件被点击时需要显示属性
        function subObjectMouseClick(subObj){
            console.log("有个对象被按压了")
            var tempSubObject = root.subObject
            for(var i = 0;i<tempSubObject.length;i++){
                var t = tempSubObject[i];
                if(t.obj == subObj){
                    controlsPropertyArea.currentSubObject = i
                    break;
                }
            }
            subObjPropertyListModel.clear()
            for( var i in subObj){
                if(typeof subObj[i] == "object" || typeof subObj[i] == "function")
                    continue
                subObjPropertyListModel.append({"propertyId":i+"","propertyValue":subObj[i]+""})
            }

        }

        function subObjectDestroy(subObj){
            var tempSubObject = root.subObject
            for(var i = 0;i<tempSubObject.length;i++){
                var t = tempSubObject[i];
                if(t.obj == subObj){
                    tempSubObject.splice(i,1);
                    break;
                }
            }
            if(subObj == controlsPropertyArea.currentSubObject){
                controlsPropertyArea.currentSubObject = -1
                subObjPropertyListModel.clear()
            }
            subObj.destroy()
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                var tempSubObject = root.subObject
                var ret = BaseControlsJs.createQmlObject(root,BaseControlsJs.custom_ui[uiControlsListView.currentIndex].ui_url,{"x":mouseX-root.x,"y":mouseY-root.y,"z":1});
                if(ret != null){
                    tempSubObject.push({"url":BaseControlsJs.custom_ui[uiControlsListView.currentIndex].ui_url,"obj":ret,"changedProperty":"[]"})
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
                var change = JSON.parse(sub[i].changedProperty)
                var sub_property = {}
                for(var j = 0;j<change.length;j++){
                    sub_property[change[j]] = sub[i].obj[change[j]]
                }
                if(change.indexOf("x") == -1){
                    sub_property.x = sub[i].obj.x
                }
                if(change.indexOf("y") == -1){
                    sub_property.y = sub[i].obj.y
                }
                BaseControlsJs.createComplieQmlObject(tryRunPageRoot,sub[i].url,sub_property);
            }
        }

        Item {
            id: tryRunPageRoot
            width: parent.width
            height: parent.height

        }
    }
}
