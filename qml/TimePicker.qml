import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import BaseUI as UI

import TaskList

Item {
    id: root

    readonly property alias timeString: timePicker.timeString

    function setTime(hour, minute) {
        timePicker.setTime(hour, minute)
    }

    function _zeroPad(arg) { return arg > 9 ? arg : "0" + arg }

    Pane {
        anchors.fill: parent

        TimePickerCircular {
            id: timePicker
            width: Math.min(parent.width, parent.height)
            height: width
            anchors.centerIn: parent
            timeAMPM: Settings.timeAMPM
            clockColor: Qt.darker(Material.background, 1.1)
            clockHandColor: UI.Style.primaryColor
            labelsColor: Material.foreground
            labelsSelectedColor: UI.Style.textOnPrimary
            labelDotColor: UI.Style.textOnPrimary
            labelsSize: UI.Style.fontSizeTitle
        }

        RowLayout {
            anchors.left: parent.left
            spacing: 0

            Label {
                color: timePicker.pickMinutes ? Material.foreground : UI.Style.textOnPrimary
                font.pixelSize: timePicker.labelsSize
                text: {
                    let hours = timePicker.hours
                    if (Settings.timeAMPM) {
                        if (timePicker.isPM) {
                            if (timePicker.hours != 12)
                                hours = timePicker.hours - 12
                        } else {
                            if (timePicker.hours == 0)
                                hours = 12
                        }
                    }
                    _zeroPad(hours)
                }
                background: Rectangle {
                    color: timePicker.pickMinutes ? "transparent" : UI.Style.primaryColor
                    radius: 4
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: timePicker.pickMinutes = false
                }
            }

            Label {
                color: Material.foreground
                font.pixelSize: timePicker.labelsSize
                text: ":"
            }

            Label {
                color: timePicker.pickMinutes ? UI.Style.textOnPrimary : Material.foreground
                font.pixelSize: timePicker.labelsSize
                text: _zeroPad(timePicker.minutes)
                background: Rectangle {
                    color: timePicker.pickMinutes ? UI.Style.primaryColor : "transparent"
                    radius: 4
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: timePicker.pickMinutes = true
                }
            }
        }

        Label {
            anchors.right: parent.right
            anchors.top: parent.top
            visible: timePicker.timeAMPM
            font.pixelSize: timePicker.labelsSize
            text: timePicker.isPM ? "PM" : "AM"
            MouseArea {
                anchors.fill: parent
                onClicked: timePicker.hours += timePicker.isPM ? -12 : 12
            }
        }
    }
}
