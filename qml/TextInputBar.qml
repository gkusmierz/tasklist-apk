import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

Popup {
    id: root

    property alias placeholderText: inputField.placeholderText

    signal accepted(string text)

    function clearText() { inputField.clear() }

    parent: Overlay.overlay

    padding: 0
    verticalPadding: 0
    horizontalPadding: 4

    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    modal: true
    dim: false
    focus: true

    background: Rectangle { color: UI.Style.primaryColor }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
    }

    onAboutToShow: inputField.clear()

    contentItem: RowLayout {
        spacing: 0

        ToolButton {
            icon.source: UI.Icons.arrow_back
            icon.color: UI.Style.textOnPrimary
            focusPolicy: Qt.NoFocus
            onClicked: { inputField.clear(); root.close() }
        }

        TextField {
            id: inputField

            focus: true

            topPadding: 0
            bottomPadding: 0

            color: UI.Style.textOnPrimary
            font.pixelSize: UI.Style.fontSizeTitle
            placeholderTextColor: UI.Style.textOnPrimary

            selectByMouse: true
            EnterKey.type: Qt.EnterKeySend

            Layout.fillWidth: true

            states: State {
                when: inputField.displayText.length > 0
                PropertyChanges { target: clearButton; visible: true }
                PropertyChanges {
                    target: speechButton
                    icon.source: UI.Icons.send
                    onClicked: {
                        Qt.inputMethod.commit()
                        root.accepted(inputField.text)
                    }
                }
            }

            onEditingFinished: root.close()
            Keys.onReturnPressed: root.accepted(inputField.text)

            Connections {
                target: System
                function onSpeechRecognized(result) { inputField.text = result }
            }
        }

        ToolButton {
            id: clearButton

            icon.source: UI.Icons.clear
            icon.color: UI.Style.textOnPrimary
            focusPolicy: Qt.NoFocus
            visible: false
            onClicked: { Qt.inputMethod.commit(); inputField.clear() }
        }

        ToolButton {
            id: speechButton

            icon.source: UI.Icons.mic
            icon.color: UI.Style.textOnPrimary
            focusPolicy: Qt.NoFocus
            onClicked: System.startSpeechRecognizer();
        }
    }
}
