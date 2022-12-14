import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

UI.AppStackPage {
    id: root

    required property Task task

    property string selectedDueDate: ""
    property int selectedDueType: Task.DueType.DateTime
    property int selectedReminder: Task.Reminder.Off

    property bool modified: {
        return root.task.name !== nameField.text
            || root.task.notes !== notesField.text
            || root.task.dueDateTime !== root.selectedDueDate
            || root.task.dueType !== root.selectedDueType
            || root.task.reminder !== root.selectedReminder
    }

    function unfocusFields() {
        nameField.focus = false
        notesField.focus = false
    }

    function back() {
        unfocusFields()
        if (modified)
            popupConfirmDiscardModifications.open()
        else
            pop()
    }

    function formatDate(d) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleDateString(Qt.locale(Settings.country))
    }

    function formatDateTime(d) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleString(Qt.locale(Settings.country))
    }

    title: qsTr("Task Details")
    padding: 6

    rightButtons: [
        Action {
            id: saveAction
            enabled: root.modified
            onTriggered: {
                unfocusFields()
                if (root.modified) {
                    if (root.task.name !== nameField.text
                        && !AppData.currentList.renameTask(task, nameField.text)) {
                        message.showError(qsTr("Name %1 already exists").arg(nameField.text))
                        return
                    }
                    root.task.notes = notesField.text
                    // XXX:
                    if (!(root.selectedReminder === Task.Reminder.Off
                          && root.task.reminder === Task.Reminder.Off)) {
                        if (root.selectedReminder === Task.Reminder.Off) {
                            System.cancelAlarm(root.task.id)
                            message.showMessage(qsTr("Reminder canceled"))
                        } else if (root.selectedDueDate !== root.task.dueDateTime) {
                            System.setAlarm(root.task.id,
                                            root.task.dateToMsec(root.selectedDueDate),
                                            root.task.name)
                            message.showMessage(qsTr("Notification set to %1")
                                .arg(formatDateTime(root.task.dueDateTime)))
                        }
                    }
                    root.task.dueDateTime = root.selectedDueDate
                    root.task.dueType = root.selectedDueType
                    root.task.reminder = root.selectedReminder
                    // root.task.completedDateTime = root.completedDateTime
                }
            }
        }
    ]

    states: State {
        when: root.modified
        PropertyChanges {
            target: saveAction
            icon.source: UI.Icons.save
        }
    }

    Flickable {
        contentHeight: taskPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: taskPane

            anchors.fill: parent
            focusPolicy: Qt.ClickFocus

            ColumnLayout {
                width: parent.width

                UI.LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Name:")
                }

                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true

                    TextField {
                        id: nameField

                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                        placeholderText: qsTr("Insert task name")
                        selectByMouse: true
                    }
                }

                UI.LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Notes:")
                }

                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true

                    TextArea {
                        id: notesField

                        leftPadding: 10
                        rightPadding: 10
                        textFormat: TextEdit.PlainText
                        wrapMode: TextEdit.WordWrap
                        anchors.fill: parent
                        selectByMouse: false
                    }
                }

                UI.HorizontalDivider { }

                UI.LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Due date")
                }

                RowLayout {
                    Layout.fillWidth: true

                    ItemDelegate {
                        id: dateSelection

                        icon.source: UI.Icons.access_time
                        text: {
                            if (root.selectedDueDate) {
                                if (root.selectedDueType === Task.DueType.AllDay)
                                    formatDate(root.selectedDueDate)
                                else
                                    formatDateTime(root.selectedDueDate)
                            } else {
                                qsTr("Set date")
                            }
                        }
                        onClicked: {
                            if (root.selectedDueDate)
                                dateTimeDialog.selectedDate = root.selectedDueDate
                            root.unfocusFields()
                            dateTimeDialog.open()
                        }
                        Layout.fillWidth: true
                    }

                    Button {
                        icon.source: UI.Icons.cancel
                        background: null
                        visible: root.selectedDueDate

                        onClicked: {
                            root.selectedDueDate = ""
                            root.selectedReminder = Task.Reminder.Off
                        }
                    }
                }

                Switch {
                    text: qsTr("All day")
                    enabled: root.selectedDueDate
                    checked: root.selectedDueType === Task.DueType.AllDay ? Qt.Checked : Qt.Unchecked
                    onClicked: {
                        if (root.selectedDueType === Task.DueType.AllDay)
                            root.selectedDueType = Task.DueType.DateTime
                        else
                            root.selectedDueType = Task.DueType.AllDay
                    }
                }

                ItemDelegate {
                    enabled: root.selectedDueDate
                    icon.source: root.selectedReminder === Task.Reminder.Off
                                    ? UI.Icons.notifications_off
                                    : UI.Icons.notifications
                    text: {
                        if (root.selectedReminder === Task.Reminder.Off)
                            qsTr("Set reminder")
                        else if (root.task.reminderType === Task.ReminderType.Notification)
                            qsTr("Notification set")
                        else if (root.task.reminderType === Task.ReminderType.Alarm)
                            qsTr("Alarm set")
                    }
                    onClicked: {
                        if (root.selectedReminder === Task.Reminder.Off)
                            root.selectedReminder = Task.Reminder.WhenDue
                        else
                            root.selectedReminder = Task.Reminder.Off
                    }
                    Layout.fillWidth: true
                }

                UI.HorizontalDivider { }

                UI.LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Completed:")
                }

                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true

                    UI.LabelBody {
                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                        text: {
                            if (root.task.completedDateTime)
                                formatDateTime(root.task.completedDateTime)
                            else
                                qsTr("Not completed")
                        }
                    }
                }

                UI.LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Created:")
                }

                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true

                    UI.LabelBody {
                        id: createdDateTimeLabel

                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                    }
                }
            }
        }
    }

    PopupConfirm {
        id: popupConfirmDiscardModifications
        text: qsTr("Discard unsaved modifications?\n\n")
        onAboutToHide: {
            stopTimer()
            if (isConfirmed) {
                isConfirmed = false
                root.pop()
            }
        }
    }

    DateTimeDialog {
        id: dateTimeDialog
        onAccepted: root.selectedDueDate = dateTimeDialog.selectedDate
    }

    Message {
        id: message
    }

    Component.onCompleted: {
        nameField.text = root.task.name
        notesField.text = root.task.notes
        createdDateTimeLabel.text = formatDateTime(root.task.createdDateTime)
        root.selectedDueDate = root.task.dueDateTime
        root.selectedDueType = root.task.dueType
        root.selectedReminder = root.task.reminder
    }
}
