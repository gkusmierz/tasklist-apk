import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "languages.js" as JS

import BaseUI as UI

import TaskList

UI.AppStackPage {
    id: root

    title: qsTr("Settings")
    padding: 0

    Flickable {
        contentHeight: settingsPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: settingsPane

            anchors.fill: parent
            padding: 0

            ColumnLayout {
                width: parent.width
                spacing: 0

                UI.SettingsSectionTitle { text: qsTr("Theme and colors") }

                SettingsCheckItem {
                    title: qsTr("Dark Theme")
                    checkState: Settings.darkTheme ? Qt.Checked : Qt.Unchecked
                    onClicked: Settings.darkTheme = !Settings.darkTheme
                    Layout.fillWidth: true
                }

                UI.SettingsItem {
                    title: qsTr("Primary Color")
                    subtitle: colorDialog.getColorName(Settings.primaryColor)
                    onClicked: {
                        colorDialog.selectAccentColor = false
                        colorDialog.open()
                    }
                }

                UI.SettingsItem {
                    title: qsTr("Accent Color")
                    subtitle: colorDialog.getColorName(Settings.accentColor)
                    onClicked: {
                        colorDialog.selectAccentColor = true
                        colorDialog.open()
                    }
                }

                UI.SettingsSectionTitle { text: qsTr("Localization") }

                UI.SettingsItem {
                    title: qsTr("Language")
                    subtitle: JS.getLanguageFromCode(Settings.language)
                    onClicked: languageDialog.open()
                }

                UI.SettingsItem {
                    property string name: JS.getCountryFromCode(Settings.country)
                    property string nativeName: JS.getCountryFromCode(Settings.country, "native")

                    title: qsTr("Country")
                    subtitle: nativeName + ((name !== nativeName) ? " (" + name + ")" : "")
                    onClicked: pageStack.push(Qt.resolvedUrl("SettingsContinentsPage.qml"))
                }

                UI.SettingsSectionTitle { text: qsTr("Task settings") }

                SettingsCheckItem {
                    title: qsTr("Strikethrough completed tasks")
                    subtitle: qsTr("Add a strikethrough over the name of completed tasks in list view")
                    checkState: Settings.strikeCompleted ? Qt.Checked : Qt.Unchecked
                    onClicked: Settings.strikeCompleted = !Settings.strikeCompleted
                    Layout.fillWidth: true
                }

                SettingsCheckItem {
                    title: qsTr("Use AM/PM time selection")
                    subtitle: qsTr("The time is selected using AM/PM clock")
                    checkState: Settings.timeAMPM ? Qt.Checked : Qt.Unchecked
                    onClicked: Settings.timeAMPM = !Settings.timeAMPM
                    Layout.fillWidth: true
                }

                SettingsCheckItem {
                    title: qsTr("Use the tumbler time selector")
                    subtitle: qsTr("Select the time using a tumbler clock")
                    checkState: Settings.timeTumbler ? Qt.Checked : Qt.Unchecked
                    onClicked: Settings.timeTumbler = !Settings.timeTumbler
                    Layout.fillWidth: true
                }
            }
        }
    }

    OptionsDialog {
        id: colorDialog

        property bool selectAccentColor: false

        function getColorName(color) {
            var filtered = colorDialog.model.filter((c) => {
                return Material.color(c.bg) === color
            })
            return filtered.length ? filtered[0].name : ""
        }

        title: selectAccentColor ? qsTr("Choose accent color") : qsTr("Choose primary color")
        model: [
            { name: "Material Red", bg: Material.Red },
            { name: "Material Pink", bg: Material.Pink },
            { name: "Material Purple", bg: Material.Purple },
            { name: "Material DeepPurple", bg: Material.DeepPurple },
            { name: "Material Indigo", bg: Material.Indigo },
            { name: "Material Blue", bg: Material.Blue },
            { name: "Material LightBlue", bg: Material.LightBlue },
            { name: "Material Cyan", bg: Material.Cyan },
            { name: "Material Teal", bg: Material.Teal },
            { name: "Material Green", bg: Material.Green },
            { name: "Material LightGreen", bg: Material.LightGreen },
            { name: "Material Lime", bg: Material.Lime },
            { name: "Material Yellow", bg: Material.Yellow },
            { name: "Material Amber", bg: Material.Amber },
            { name: "Material Orange", bg: Material.Orange },
            { name: "Material DeepOrange", bg: Material.DeepOrange },
            { name: "Material Brown", bg: Material.Brown },
            { name: "Material Grey", bg: Material.Grey },
            { name: "Material BlueGrey", bg: Material.BlueGrey }
        ]
        delegate: RowLayout {
            spacing: 0

            Rectangle {
                visible: colorDialog.selectAccentColor
                color: UI.Style.primaryColor
                Layout.margins: 0
                Layout.leftMargin: 10
                Layout.minimumWidth: 48
                Layout.minimumHeight: 32
            }

            Rectangle {
                color: Material.color(modelData.bg)
                Layout.margins: 0
                Layout.leftMargin: colorDialog.selectAccentColor ? 0 : 10
                Layout.minimumWidth: 32
                Layout.minimumHeight: 32
            }

            RadioButton {
                checked: {
                    if (colorDialog.selectAccentColor)
                        Material.color(modelData.bg) === UI.Style.accentColor
                    else
                        Material.color(modelData.bg) === UI.Style.primaryColor
                }
                text: modelData.name
                Layout.leftMargin: 4
                onClicked: {
                    colorDialog.close()
                    if (colorDialog.selectAccentColor)
                        Settings.accentColor = Material.color(modelData.bg)
                    else
                        Settings.primaryColor = Material.color(modelData.bg)
                }
            }
        }
    }

    OptionsDialog {
        id: languageDialog

        title: qsTr("Language")
        model: System.translations()
        delegate: RadioButton {
            checked: modelData === Settings.language
            text: JS.getLanguageFromCode(modelData)
            onClicked: { languageDialog.close(); Settings.language = modelData }
        }
    }
}
