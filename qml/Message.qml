import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import BaseUI as UI

Popup {
    id: root

    property bool errorMessage: false

    function start(text) {
        label.text = text
        if (timer.running) {
            timer.restart()
            close()
            open()
        } else {
            open()
        }
    }

    function showMessage(text) {
        root.errorMessage = false
        start(text)
    }

    function showError(text) {
        root.errorMessage = true
        start(text)
    }

    closePolicy: Popup.CloseOnPressOutside
    implicitWidth: parent.width > parent.height ? parent.width * 0.50 : parent.width * 0.95

    x: (parent.width - implicitWidth) / 2
    y: 16

    background: Rectangle {
        color: Material.color(Material.Grey, Material.Shade900)
        radius: 4
    }

    onAboutToShow: timer.start()
    onAboutToHide: timer.stop()

    Timer {
        id: timer

        interval: 3000
        repeat: false

        onTriggered: root.close()
    }

    RowLayout {
        width: parent.width

        Image {
            visible: root.errorMessage
            smooth: true
            source: UI.Icons.error + "color=red"
            sourceSize.width: 24
            sourceSize.height: 24
        }

        Label {
            id: label

            Layout.fillWidth: true
            Layout.preferredWidth: 1

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 16
            color: root.errorMessage ? "red" : "white"
            wrapMode: Label.WordWrap
        }
    }
}
