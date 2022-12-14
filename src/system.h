#ifndef SYSTEM_H
#define SYSTEM_H

#include <QObject>
#include <QColor>
#include <QString>

class QQmlEngine;
class QJSEngine;

class System : public QObject
{
    Q_OBJECT

public:
    static System *instance();
    static System *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    Q_INVOKABLE static QString dataPath();
    Q_INVOKABLE static QString language();
    Q_INVOKABLE static QString locale();
    Q_INVOKABLE static QStringList translations();

    Q_INVOKABLE void startSpeechRecognizer() const;
    Q_INVOKABLE void setAlarm(int id, long long time, const QString &task) const;
    Q_INVOKABLE void cancelAlarm(int id) const;
    Q_INVOKABLE void setStatusBarColor(const QColor &primary) const;
    Q_INVOKABLE void checkPermissions() const;

Q_SIGNALS:
    void speechRecognized(const QString &result);

private:
    explicit System(QObject *parent = nullptr);
    Q_DISABLE_COPY(System)
};

#endif // SYSTEM_H
