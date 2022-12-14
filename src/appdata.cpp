#include "appdata.h"

#include <QDir>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QQmlEngine>

#include "system.h"
#include "uniqueid.h"

AppData::AppData(QObject *parent)
    : QObject(parent)
    , m_lists(new QQmlObjectListModel<List>(this))
    , m_listFilePath(System::dataPath() + "/lists.json")
    , m_currentList(nullptr)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    if (!checkDirs())
        qFatal("App won't work - cannot create data directory.");
    readListFile();
}

AppData::~AppData()
{
    writeListFile();
}

AppData *AppData::instance()
{
    static AppData instance_;
    return &instance_;
}

AppData *AppData::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)
    return instance();
}

bool AppData::checkDirs() const
{
    QDir myDir;
    QString path = System::dataPath();

    if (!myDir.exists(path)) {
        if (!myDir.mkpath(path)) {
            qWarning() << "Cannot create" << path;
            return false;
        }
        qDebug() << "Created directory" << path;
    }

    return true;
}

void AppData::readListFile()
{
    qDebug() << "Read the list database";

    QFile readFile(m_listFilePath);

    if (!readFile.exists()) {
        qWarning() << "List cache doesn't exist:" << m_listFilePath;
        return;
    }
    if (!readFile.open(QIODevice::ReadOnly)) {
        qWarning() << "Cannot open file:" << m_listFilePath;
        return;
    }
    auto jdoc = QJsonDocument::fromJson(readFile.readAll());
    readFile.close();
    if (!jdoc.isObject()) {
        qWarning() << "Cannot read JSON file:" << m_listFilePath;
        return;
    }
    QJsonObject jobj = jdoc.object();
    for (const auto o : jobj["lists"].toArray())
        m_lists->append(List::fromJson(o.toObject()));
    QJsonValue curList = jobj["current"];
    if (!curList.isNull() && !curList.toString().isEmpty())
        selectList(curList.toString());
    UniqueID::setLastUID(jobj["lastUID"].toInt());

    qDebug() << m_lists->count() << "lists loaded";
    qDebug() << "List database read";
}

void AppData::writeListFile() const
{
    qDebug() << "Write the list file";

    QFile writeFile(m_listFilePath);

    if (!writeFile.open(QIODevice::WriteOnly)) {
        qWarning() << "Cannot open file:" << m_listFilePath;
        return;
    }
    QJsonObject jobj;
    QJsonArray jarrLists;
    for (const auto &i : m_lists->toList())
        jarrLists.append(i->toJson());
    jobj["lists"] = jarrLists;
    jobj["current"] = currentList() ? currentList()->name() : "";
    jobj["lastUID"] = UniqueID::lastUID();
    writeFile.write(QJsonDocument(jobj).toJson());
    writeFile.close();

    qDebug() << "List saved";
}

List *AppData::findList(const QString &name) const
{
    for (const auto &list : m_lists->toList()) {
        if (list->name() == name)
            return list;
    }
    return nullptr;
}

bool AppData::addList(const QString &name) const
{
    if (findList(name))
        return false;
    m_lists->append(new List(name));

    return true;
}

void AppData::selectList(const QString &name)
{
    List *list = findList(name);
    if (list)
        setCurrentList(list);
}

void AppData::removeList(const QString &name)
{
    List *list = findList(name);
    if (list)
        removeList(m_lists->indexOf(list));
}

void AppData::removeList(int index)
{
    if (index >= 0 && index < m_lists->count()) {
        if (m_lists->indexOf(currentList()) == index) {
            m_lists->remove(index);
            if (index < m_lists->count())
                setCurrentList(m_lists->at(index));
            else if (m_lists->count())
                setCurrentList(m_lists->at(m_lists->count() - 1));
            else
                setCurrentList(nullptr);
        } else {
            m_lists->remove(index);
        }
    }
}

List *AppData::currentList() const
{
    return m_currentList;
}

void AppData::setCurrentList(List *currentList)
{
    if (m_currentList == currentList)
        return;

    m_currentList = currentList;
    Q_EMIT currentListChanged(m_currentList);
}
