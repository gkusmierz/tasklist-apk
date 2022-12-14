#ifndef APPDATA_H
#define APPDATA_H

#include <QObject>

#include "QQmlObjectListModel.h"
#include "list.h"

class QQmlEngine;
class QJSEngine;

class AppData : public QObject
{
    Q_OBJECT

    QML_OBJMODEL_PROPERTY(lists, List)
    Q_PROPERTY(List *currentList READ currentList NOTIFY currentListChanged)

public:
    ~AppData();

    static AppData *instance();
    static AppData *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    bool checkDirs() const;

    void readListFile();
    void writeListFile() const;

    List *findList(const QString &name) const;

    Q_INVOKABLE bool addList(const QString &name) const;
    Q_INVOKABLE void selectList(const QString &name);
    Q_INVOKABLE void removeList(const QString &name);
    Q_INVOKABLE void removeList(int index);

    List *currentList() const;
    void setCurrentList(List *currentList);

Q_SIGNALS:
    void currentListChanged(List *currentList);

private:
    explicit AppData(QObject *parent = nullptr);
    Q_DISABLE_COPY(AppData)

    QString m_listFilePath;

    List *m_currentList;
};

#endif // APPDATA_H
