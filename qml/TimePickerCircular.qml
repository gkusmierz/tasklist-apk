import QtQuick
import QtQuick.Controls

Item {
    id: root

    property int hours: 0
    property int minutes: 0
    readonly property string timeString: _zeroPad(hours) + ":" + _zeroPad(minutes) + ":00"
    readonly property bool isPM: hours >= 12

    property bool pickMinutes: false
    property bool timeAMPM: false

    property color clockColor: "gray"
    property color clockHandColor: "blue"
    property color labelsColor: "white"
    property color labelsSelectedColor: "white"
    property color labelDotColor: "white"

    property int labelsSize: 20

    function setTime(hour, minute) {
        root.hours = hour
        root.minutes = minute
    }

    function _zeroPad(arg) { return arg > 9 ? arg : "0" + arg }

    Rectangle {
        id: clock

        property real innerRadius: radius * 0.5
        property real outerRadius: radius * 0.8

        width: Math.min(root.width, root.height)
        height: width
        radius: width / 2
        color: root.clockColor

        MouseArea {
            function getSectorFromAngle(rad, sectors) {
                let index = Math.round(rad / (2 * Math.PI) * sectors)
                return index < 0 ? index + sectors : index
            }

            function selectTime(mouse) {
                let x = mouse.x - width / 2
                let y = -(mouse.y - height / 2)
                let angle = Math.atan2(x, y)
                if (root.pickMinutes) {
                    root.minutes = getSectorFromAngle(angle, 60)
                } else {
                    let hour = getSectorFromAngle(angle, 12)
                    if (!root.timeAMPM) {
                        let vect = Qt.vector2d(x, y)
                        let radius = (clock.outerRadius + clock.innerRadius) / 2
                        if (vect.length() > radius) {
                            if (hour == 0)
                                hour = 12
                        } else if (hour != 0) {
                            hour += 12
                        }
                    } else if (root.isPM) {
                        hour += 12
                    }
                    root.hours = hour
                }
            }

            anchors.fill: parent

            onPressed: (mouse) => selectTime(mouse)
            onPositionChanged: (mouse) => selectTime(mouse)
        }

        Repeater {
            id: innerRepeater
            anchors.centerIn: parent
            model: [ 0, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 ]
            delegate: Label {
                property real angle: 2 * Math.PI * model.index / innerRepeater.count
                x: clock.width / 2 + clock.innerRadius * Math.sin(angle) - width / 2
                y: clock.height / 2 - clock.innerRadius * Math.cos(angle) - height / 2
                z: 1
                visible: !root.pickMinutes && !root.timeAMPM
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: root.labelsSize
                color: modelData == root.hours ? root.labelsSelectedColor : root.labelsColor
                text: modelData
            }
        }

        Repeater {
            id: outerRepeater
            anchors.centerIn: parent
            model: root.pickMinutes ? 60 : [ 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ]
            delegate: Label {
                property real angle: 2 * Math.PI * model.index / outerRepeater.count
                x: clock.width / 2 + clock.outerRadius * Math.sin(angle) - width / 2
                y: clock.height / 2 - clock.outerRadius * Math.cos(angle) - height / 2
                z: 1
                visible: !root.pickMinutes || modelData % 5 == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: root.labelsSize
                color: {
                    if (root.pickMinutes) {
                        if (modelData == root.minutes)
                            return root.labelsSelectedColor
                    } else if (!root.timeAMPM) {
                        if (modelData == root.hours)
                            return root.labelsSelectedColor
                    } else if (root.isPM) {
                        if (modelData == root.hours - 12
                            || (modelData == 12 && root.hours == 12))
                            return root.labelsSelectedColor
                    } else if (modelData == root.hours
                               || (modelData == 12 && root.hours == 0)) {
                        return root.labelsSelectedColor
                    }
                    return root.labelsColor
                }
                text: modelData
            }
        }

        // clock hand
        Rectangle {
            x: clock.width / 2 - width / 2
            y: clock.height / 2 - height
            width: 2
            height: root.pickMinutes
                    || root.timeAMPM
                    || (root.hours != 0 && root.hours <= 12)
                ? clock.outerRadius
                : clock.innerRadius

            transformOrigin: Item.Bottom
            rotation: {
                if (root.pickMinutes)
                    return 360 / 60 * root.minutes
                else if (root.hours >= 12)
                    return 360 / 12 * (root.hours - 12)
                else
                    return 360 / 12 * root.hours
            }
            color: root.clockHandColor
            antialiasing: true

            // label background
            Rectangle {
                x: -width / 2 + 1
                y: -height / 2
                width: root.labelsSize + root.labelsSize / 2
                height: width
                radius: width / 2
                color: root.clockHandColor

                Rectangle {
                    width: 4
                    height: width
                    radius: width / 2
                    anchors.centerIn: parent
                    visible: root.pickMinutes && root.minutes % 5
                    color: root.labelDotColor
                }
            }
        }

        // centerpoint
        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: width
            radius: width / 2
            color: root.clockHandColor
        }
    }
}
