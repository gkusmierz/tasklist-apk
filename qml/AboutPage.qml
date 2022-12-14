import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

UI.AppStackPage {
    title: qsTr("About")
    padding: 10

    Flickable {
        contentHeight: aboutPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: aboutPane

            anchors.fill: parent

            ColumnLayout {
                width: parent.width

                UI.LabelTitle {
                    text: Qt.application.displayName
                    horizontalAlignment: Qt.AlignHCenter
                }

                UI.LabelBody {
                    property string repo: "https://github.com/stemoretti/tasklist"
                    text: "<a href='" + repo + "'>" + repo + "</a>"
                    linkColor: UI.Style.isDarkTheme ? "lightblue" : "blue"
                    onLinkActivated: Qt.openUrlExternally(link)
                    horizontalAlignment: Qt.AlignHCenter
                }
            }
        }
    }
}
