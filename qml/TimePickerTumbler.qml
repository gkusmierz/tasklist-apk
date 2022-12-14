import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import TaskList

Item {
    id: root

    readonly property int hours: {
        if (root.timeAMPM) {
            if (amPmButton.checked) {
                if (hoursTumbler.currentIndex === 0)
                    12
                else
                    hoursTumbler.currentIndex + 12
            } else {
                if (hoursTumbler.currentIndex === 12)
                    0
                else
                    hoursTumbler.currentIndex
            }
        } else {
            hoursTumbler.currentIndex
        }
    }
    readonly property int minutes: minutesTumbler.currentIndex
    readonly property string timeString: _zeroPad(hours) + ":" + _zeroPad(minutes) + ":00"

    property bool timeAMPM: Settings.timeAMPM

    function setTime(hour, minute) {
        if (root.timeAMPM) {
            if (hour >= 12) {
                hour -= 12
                amPmButton.checked = true
            } else {
                amPmButton.checked = false
            }
        }
        hoursTumbler.positionViewAtIndex(hour, Tumbler.Center)
        minutesTumbler.positionViewAtIndex(minute, Tumbler.Center)
    }

    function _zeroPad(number) { return number > 9 ? number : '0' + number }

    Component {
        id: delegateComponent

        Label {
            text: _zeroPad(modelData)
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 40
        }
    }

    RowLayout {
        id: tumblerRow

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 10

        Tumbler {
            id: hoursTumbler

            model: root.timeAMPM ? [ 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ] : 24
            delegate: delegateComponent
        }

        Label {
            text: ":"
            font.pixelSize: 40
        }

        Tumbler {
            id: minutesTumbler

            model: 60
            delegate: delegateComponent
        }
    }

    Button {
        id: amPmButton

        visible: root.timeAMPM
        anchors.left: tumblerRow.right
        anchors.verticalCenter: tumblerRow.verticalCenter
        text: checked ? "PM" : "AM"
        checkable: true
        font.pixelSize: 30
        background: Rectangle {
            color: parent.pressed ? "gray" : "transparent"
            radius: 2
            opacity: parent.pressed ? 0.12 : 1.0
        }
    }
}
