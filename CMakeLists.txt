cmake_minimum_required(VERSION 3.19)

project(tasklist VERSION 0.1 LANGUAGES CXX)

add_subdirectory(baseui)
set_property(CACHE BASEUI_EMBED_QML PROPERTY VALUE ON)
set_property(CACHE BASEUI_EMBED_ICONS PROPERTY VALUE ON)

find_package(Qt6 COMPONENTS
    Qml
    Quick
    Gui
    QuickControls2
    LinguistTools
    REQUIRED
)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

qt_add_executable(${PROJECT_NAME}
    src/appdata.cpp
    src/appdata.h
    src/list.cpp
    src/list.h
    src/main.cpp
    src/QQmlObjectListModel.h
    src/settings.cpp
    src/settings.h
    src/sortfiltermodel.cpp
    src/sortfiltermodel.h
    src/system.cpp
    src/system.h
    src/task.cpp
    src/task.h
    src/uniqueid.cpp
    src/uniqueid.h
)

set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Qml
        Qt6::Quick
        Qt6::Gui
        Qt6::QuickControls2
        baseui
)

set(QML_FILES
    qml/AboutPage.qml
    qml/DatePicker.qml
    qml/DateTimeDialog.qml
    qml/EdgeEffect.qml
    qml/HorizontalListDivider.qml
    qml/LabelBodySecondary.qml
    qml/ListManagementPage.qml
    qml/ListPage.qml
    qml/ListViewEdgeEffect.qml
    qml/main.qml
    qml/Message.qml
    qml/OptionsDialog.qml
    qml/PopupConfirm.qml
    qml/ReorderDelegate.qml
    qml/ReorderListView.qml
    qml/SelectItemsBar.qml
    qml/SettingsCheckItem.qml
    qml/SettingsContinentsPage.qml
    qml/SettingsCountriesPage.qml
    qml/SettingsPage.qml
    qml/SortedListView.qml
    qml/TaskDetailsPage.qml
    qml/TextInputBar.qml
    qml/TimePicker.qml
    qml/TimePickerCircular.qml
    qml/TimePickerTumbler.qml
)

qt_add_translations(${PROJECT_NAME}
    TS_FILES
        translations/tasklist_en.ts
        translations/tasklist_it.ts
    SOURCES
        ${QML_FILES}
    LUPDATE_OPTIONS
        -no-obsolete
)

qt_add_resources(${PROJECT_NAME} "res"
    PREFIX
        "/"
    FILES
        ${QML_FILES}
        qml/languages.js
)

set(QML_IMPORT_PATH "${CMAKE_SOURCE_DIR}/baseui/qml"
    CACHE STRING "Qt Creator extra qml import paths" FORCE
)
