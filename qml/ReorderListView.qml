import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

Item {
    id: root

    property bool drawerEnabled: !selectItemsBar.opened

    function formatDate(d, t) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleDateString(Qt.locale(Settings.country), t)
    }

    function formatDateTime(d, t) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleString(Qt.locale(Settings.country), t)
    }

    Component {
        id: taskDelegate

        ReorderDelegate {
            required property int index
            required property QtObject model
            required property QtObject modelData

            property bool selected: false

            height: implicitHeight
            width: implicitWidth
            implicitHeight: contentItem.implicitHeight
            implicitWidth: root.width

            dragParent: root
            grabArea: grabItem

            onEntered: function(drag) {
                AppData.currentList.moveTask(drag.source.index, index)
            }

            contentItem: ItemDelegate {
                padding: 0
                topPadding: 0
                bottomPadding: 0

                highlighted: dragging || (selectItemsBar.opened && selected)

                onPressAndHold: {
                    if (!selectItemsBar.opened) {
                        selectItemsBar.open()
                        selectItemsBar.toggle(modelData.id)
                        selected = !selected
                    }
                }

                onClicked: {
                    if (selectItemsBar.opened) {
                        selectItemsBar.toggle(modelData.id)
                        selected = !selected
                    } else {
                        pageStack.push(Qt.resolvedUrl("TaskDetailsPage.qml"), { task: modelData })
                    }
                }

                contentItem: RowLayout {
                    spacing: 0

                    CheckBox {
                        enabled: !selectItemsBar.opened
                        checkState: model.completed ? Qt.Checked : Qt.Unchecked
                        onClicked: model.completed = !model.completed
                        Layout.leftMargin: 10
                    }

                    ColumnLayout {
                        spacing: 2

                        UI.LabelSubheading {
                            text: model.name
                            font.strikeout: Settings.strikeCompleted && model.completed
                            elide: Text.ElideRight
                        }

                        UI.LabelBody {
                            visible: model.notes.length
                            text: model.notes.replace(/\n/g, ' ')
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    UI.LabelBody {
                        visible: model.dueDateTime
                        opacity: 0.6
                        text: {
                            if (model.dueType == Task.DueType.DateTime)
                                formatDateTime(model.dueDateTime, Locale.ShortFormat)
                            else
                                formatDate(model.dueDateTime, Locale.ShortFormat)
                        }
                        elide: Text.ElideRight
                        Layout.fillWidth: false
                    }

                    Item {
                        id: grabItem

                        width: 40
                        enabled: !selectItemsBar.opened

                        Layout.margins: 4
                        Layout.rightMargin: 10
                        Layout.fillHeight: true

                        Image {
                            height: 30
                            width: 30
                            anchors.centerIn: parent
                            source: UI.Icons.reorder + "color="
                                + (UI.Style.isDarkTheme ?
                                    (grabItem.enabled ? "darkgray" : "gray") :
                                    (grabItem.enabled ? "gray" : "darkgray"))
                        }
                    }
                }
            }
        }
    }

    ListViewEdgeEffect {
        id: listView

        anchors.fill: parent
        model: AppData.currentList?.visualModel ?? 0
        delegate: taskDelegate
    }

    Menu {
        id: actionMenu

        modal: true
        dim: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: parent.width - width - 6
        y: -selectItemsBar.height + 6
        transformOrigin: Menu.TopRight

        onAboutToHide: currentIndex = -1 // reset highlighting

        MenuItem {
            checkable: true
            checked: selectItemsBar.selectedSize == listView.count
            text: qsTr("Select All")
            onTriggered: {
                if (checked) {
                    for (var i = 0; i < listView.count; i++) {
                        listView.itemAtIndex(i).selected = true
                        selectItemsBar.append(listView.model.get(i).id)
                    }
                } else {
                    selectItemsBar.clear()
                    for (var i = 0; i < listView.count; i++)
                        listView.itemAtIndex(i).selected = false
                }
            }
        }
        MenuItem {
            enabled: selectItemsBar.selectedSize > 0
            text: qsTr("Delete")
            onTriggered: popupConfirmDeleteSelected.open()
        }
    }

    SelectItemsBar {
        id: selectItemsBar

        width: parent.width

        rightButtons: [
            Action {
                icon.source: UI.Icons.more_vert
                onTriggered: actionMenu.open()
            }
        ]

        onAboutToHide: {
            for (var i = 0; i < listView.count; i++)
                listView.itemAtIndex(i).selected = false
        }
    }

    PopupConfirm {
        id: popupConfirmDeleteSelected
        text: qsTr("Do you want to delete %n selected task(s)?\n\n", "", selectItemsBar.selectedSize)
        onAboutToHide: {
            stopTimer()
            if (isConfirmed) {
                message.showMessage(qsTr("%n task(s) deleted", "", selectItemsBar.selectedSize))
                for (var i = 0; i < selectItemsBar.selectedSize; i++)
                    AppData.currentList.removeTask(selectItemsBar.at(i))
                selectItemsBar.close()
                isConfirmed = false
            }
        }
    }

    Message {
        id: message
    }
}
