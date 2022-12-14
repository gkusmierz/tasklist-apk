import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

Popup {
    id: root

    property string selectedDate: ""

    signal accepted()

    parent: Overlay.overlay

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    implicitWidth: parent.width > parent.height ? parent.width * 0.70 : parent.width * 0.94
    implicitHeight: dateTimeColumn.implicitHeight

    padding: 0
    modal: true
    dim: true
    focus: true

    onAboutToShow: {
        if (root.selectedDate) {
            var dateTime = new Date(root.selectedDate)
            datePicker.selectedDate = dateTime
            timePicker.item.setTime(dateTime.getHours(), dateTime.getMinutes())
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: dateTimePane.implicitHeight
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragOverBounds

        Pane {
            id: dateTimePane

            anchors.fill: parent
            padding: 0

            ColumnLayout {
                id: dateTimeColumn

                width: parent.width
                spacing: 0

                StackLayout {
                    id: view

                    currentIndex: pageIndicator.currentIndex

                    DatePicker {
                        id: datePicker
                    }

                    Loader {
                        id: timePicker
                        source: Settings.timeTumbler ? "TimePickerTumbler.qml" : "TimePicker.qml"
                    }
                }

                RowLayout {
                    spacing: 10

                    Layout.leftMargin: 10
                    Layout.rightMargin: 10

                    TabBar {
                        id: pageIndicator

                        background: null
                        Layout.fillWidth: true

                        TabButton {
                            text: qsTr("DATE")
                            width: implicitWidth
                        }

                        TabButton {
                            text: qsTr("TIME")
                            width: implicitWidth
                        }
                    }

                    UI.ButtonFlat {
                        text: qsTr("Cancel")
                        textColor: UI.Style.primaryColor
                        Layout.minimumWidth: 80
                        onClicked: root.close()
                    }

                    UI.ButtonRaised {
                        text: qsTr("OK")
                        Layout.minimumWidth: 80

                        onClicked: {
                            root.selectedDate = datePicker.dateString + "T" + timePicker.item.timeString
                            root.close()
                            root.accepted()
                        }
                    }
                }
            }
        }
    }
}
