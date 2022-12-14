import QtQuick

import BaseUI as UI

import TaskList

UI.App {
    title: Qt.application.displayName
    width: 640
    height: 480

    initialPage: "qrc:/qml/ListPage.qml"

    Connections {
        target: Settings
        function onPrimaryColorChanged(c) { System.setStatusBarColor(c) }
    }

    Component.onCompleted: {
        UI.Style.primaryColor = Qt.binding(function() { return Settings.primaryColor })
        UI.Style.accentColor = Qt.binding(function() { return Settings.accentColor })
        UI.Style.isDarkTheme = Qt.binding(function() { return Settings.darkTheme })
        System.setStatusBarColor(Settings.primaryColor)
        System.checkPermissions()
    }
}
