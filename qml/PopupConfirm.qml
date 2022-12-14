import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

UI.PopupModalBase {
    id: root

    property bool isConfirmed: false
    property alias text: label.text

    implicitWidth: Math.min(parent.width * 0.9, Math.max(popupColumn.implicitWidth, 300))
    focus: true

    ColumnLayout {
        id: popupColumn

        anchors { right: parent.right; left: parent.left }
        spacing: 10

        UI.LabelSubheading {
            id: label

            topPadding: 20
            leftPadding: 8
            rightPadding: 8
            text: ""
            color: UI.Style.popupTextColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            UI.ButtonRaised {
                text: qsTr("Confirm")
                Layout.rightMargin: 10

                onClicked: {
                    isConfirmed = true
                    root.close()
                }
            }

            UI.ButtonFlat {
                text: qsTr("Cancel")
                textColor: UI.Style.primaryColor
                Layout.leftMargin: 10

                onClicked: {
                    isConfirmed = false
                    root.close()
                }
            }
        }
    }

    onAboutToHide: {
        stopTimer()
    }

    onAboutToShow: {
        closeTimer.start()
    }

    Timer {
        id: closeTimer

        interval: 6000
        repeat: false

        onTriggered: {
            isConfirmed = false
            root.close()
        }
    }

    function stopTimer() {
        closeTimer.stop()
    }
}
