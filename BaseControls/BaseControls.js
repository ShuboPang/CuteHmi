.pragma library

function createQmlObjectMouseArea(parent) {
    var component = Qt.createComponent("./ICMouseArea.qml");
    if (component.status == 1) {
        return component.createObject(parent);
    }
    else if (component.status == 3) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }
    return null
}

function createQmlObject(parent,src,para) {
    var component = Qt.createComponent(src);
    if (component.status == 1) {
        var obj = component.createObject(parent,para||{});
        var mouseObj = createQmlObjectMouseArea(obj)
        mouseObj.mouseClick.connect(parent.subObjectMouseClick)
        mouseObj.deletaParent.connect(parent.subObjectDestroy)
        return obj
    }
    else if (component.status == 3) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }
    return null
}

function createComplieQmlObject(parent,src,para) {
    var component = Qt.createComponent(src);
    if (component.status == 1) {
        var obj = component.createObject(parent,para||{});
//        var mouseObj = createQmlObjectMouseArea(obj)
//        mouseObj.mouseClick.connect(parent.subObjectMouseClick)
//        mouseObj.deletaParent.connect(parent.subObjectDestroy)
        return obj
    }
    else if (component.status == 3) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }
    return null
}


var custom_ui_buttion = {
    "ui_name":qsTr("按钮"),
    "ui_property":[],
    "ui_url":"ICButton.qml",
}

var custom_ui_checkbox = {
    "ui_name":qsTr("复选框"),
    "ui_property":[],
    "ui_url":"ICCheckbox.qml",
}


var custom_ui=[custom_ui_buttion,custom_ui_checkbox]
