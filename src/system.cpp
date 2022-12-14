#include "system.h"

#include <QStandardPaths>
#include <QLocale>
#include <QQmlEngine>
#include <QDir>
#include <QRegularExpression>

#ifdef Q_OS_ANDROID
#include <QCoreApplication>
#include <QJniObject>

#include "settings.h"
#endif

System::System(QObject *parent)
    : QObject(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

System *System::instance()
{
    static System instance_;
    return &instance_;
}

System *System::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)
    return instance();
}

QString System::dataPath()
{
    QStringList dataLocations = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation);
#ifdef Q_OS_ANDROID
    if (dataLocations.size() > 1)
        return dataLocations[1];
#endif
    return dataLocations[0];
}

QString System::language()
{
    return QLocale().name().left(2);
}

QString System::locale()
{
    return QLocale().name();
}

QStringList System::translations()
{
    QDir translationsDir(":/i18n");
    QStringList languages;

    if (translationsDir.exists()) {
        QStringList translations = translationsDir.entryList({ "*.qm" });
        translations.replaceInStrings(QRegularExpression("[^_]+_(\\w+)\\.qm"), "\\1");
        languages.append(translations);
        languages.sort();
    }

    return languages;
}

#ifdef Q_OS_ANDROID
extern "C" JNIEXPORT void JNICALL
Java_com_github_stemoretti_tasklist_MainActivity_sendResult(JNIEnv *env,
                                                            jobject obj,
                                                            jstring text)
{
    Q_UNUSED(env)
    Q_UNUSED(obj)
    auto result = QJniObject(text).toString();
    if (!result.isEmpty()) {
        result[0] = result[0].toUpper();
        Q_EMIT System::instance()->speechRecognized(result);
    }
}
#endif

void System::startSpeechRecognizer() const
{
#ifdef Q_OS_ANDROID
    auto javaString = QJniObject::fromString(Settings::instance()->country());
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("getSpeechInput", "(Ljava/lang/String;)V",
                              javaString.object());
#endif
}

void System::setAlarm(int id, long long time, const QString &task) const
{
#ifdef Q_OS_ANDROID
    auto javaString = QJniObject::fromString(task);
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("setAlarm", "(IJLjava/lang/String;)V",
                              id, time, javaString.object());
#endif
}

void System::cancelAlarm(int id) const
{
#ifdef Q_OS_ANDROID
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("cancelAlarm", "(I)V", id);
#endif
}

void System::setStatusBarColor(const QColor &primary) const
{
#ifdef Q_OS_ANDROID
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("setStatusBarColor", "(I)V", primary.darker(140).rgba());
#endif
}

void System::checkPermissions() const
{
#ifdef Q_OS_ANDROID
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("checkPermissions", "()V");
#endif
}
