#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QColor>
#include <QString>

class QQmlEngine;
class QJSEngine;

class Settings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool darkTheme READ darkTheme WRITE setDarkTheme NOTIFY darkThemeChanged)
    Q_PROPERTY(QColor primaryColor READ primaryColor WRITE setPrimaryColor NOTIFY primaryColorChanged)
    Q_PROPERTY(QColor accentColor READ accentColor WRITE setAccentColor NOTIFY accentColorChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString country READ country WRITE setCountry NOTIFY countryChanged)
    Q_PROPERTY(bool strikeCompleted READ strikeCompleted WRITE setStrikeCompleted NOTIFY strikeCompletedChanged)
    Q_PROPERTY(bool timeAMPM READ timeAMPM WRITE setTimeAMPM NOTIFY timeAMPMChanged)
    Q_PROPERTY(bool timeTumbler READ timeTumbler WRITE setTimeTumbler NOTIFY timeTumblerChanged)

public:
    ~Settings();

    static Settings *instance();
    static Settings *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    void readSettingsFile();
    void writeSettingsFile() const;

    bool darkTheme() const;
    void setDarkTheme(bool darkTheme);

    QColor primaryColor() const;
    void setPrimaryColor(const QColor &primaryColor);

    QColor accentColor() const;
    void setAccentColor(const QColor &accentColor);

    QString language() const;
    void setLanguage(const QString &language);

    QString country() const;
    void setCountry(const QString &country);

    bool strikeCompleted() const;
    void setStrikeCompleted(bool strikeCompleted);

    bool timeAMPM() const;
    void setTimeAMPM(bool timeAMPM);

    bool timeTumbler() const;
    void setTimeTumbler(bool timeTumbler);

Q_SIGNALS:
    void darkThemeChanged(bool darkTheme);
    void primaryColorChanged(const QColor &primaryColor);
    void accentColorChanged(const QColor &accentColor);
    void languageChanged(const QString &language);
    void countryChanged(const QString &country);
    void strikeCompletedChanged(bool strikeCompleted);
    void timeAMPMChanged(bool timeAMPM);
    void timeTumblerChanged(bool timeTumbler);

private:
    explicit Settings(QObject *parent = nullptr);
    Q_DISABLE_COPY(Settings)

    QString m_settingsFilePath;

    bool m_darkTheme;
    QColor m_primaryColor;
    QColor m_accentColor;
    QString m_language;
    QString m_country;
    bool m_strikeCompleted;
    bool m_timeAMPM;
    bool m_timeTumbler;
};

#endif // SETTINGS_H
