import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "languages.js" as JS

import BaseUI as UI

UI.AppStackPage {
    title: qsTr("Continents")
    padding: 0

    ListViewEdgeEffect {
        anchors.fill: parent
        model: JS.regions.map(function (o) { return o.name })

        delegate: ItemDelegate {
            width: parent.width
//            height: 50
            contentItem: UI.LabelSubheading {
                text: modelData
            }
            onClicked: {
                pageStack.replace(Qt.resolvedUrl("SettingsCountriesPage.qml"), { "continent": index })
            }
        }
    }
}
