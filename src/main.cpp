#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QScopedPointer>
#include <QDebug>
#include <QDir>

#include <BaseUI/core.h>

#include "appdata.h"
#include "settings.h"
#include "system.h"
#include "task.h"
#include "list.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setApplicationName("TaskList");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    BaseUI::init(&engine);

    qDebug() << "Available translations:" << System::translations();
    QScopedPointer<QTranslator> translator;
    QObject::connect(Settings::instance(), &Settings::languageChanged,
                     [&engine, &translator](QString language) {
        if (!translator.isNull()) {
            QCoreApplication::removeTranslator(translator.data());
            translator.reset();
        }
        translator.reset(new QTranslator);
        if (translator->load(QLocale(language), "tasklist", "_", ":/i18n"))
            QCoreApplication::installTranslator(translator.data());
        engine.retranslate();
    });

    Settings::instance()->readSettingsFile();

    qmlRegisterSingletonType<AppData>("TaskList", 1, 0, "AppData", AppData::create);
    qmlRegisterSingletonType<Settings>("TaskList", 1, 0, "Settings", Settings::create);
    qmlRegisterSingletonType<System>("TaskList", 1, 0, "System", System::create);

    qmlRegisterUncreatableType<Task>("TaskList", 1, 0, "Task", "Task objects can't be created");
    qmlRegisterUncreatableType<List>("TaskList", 1, 0, "List", "List objects can't be created");

    QUrl url("qrc:/qml/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    QObject::connect(&app, &QGuiApplication::applicationStateChanged,
                     [](Qt::ApplicationState state) {
        if (state == Qt::ApplicationSuspended) {
            AppData::instance()->writeListFile();
            Settings::instance()->writeSettingsFile();
        }
    });

    return app.exec();
}
