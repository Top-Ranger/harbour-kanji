#include "batch_save.h"
#include <QDebug>

batch_save::batch_save(QSqlDatabase settings, QObject *parent) :
    QObject(parent),
    _settings(settings),
    _settings_query(settings)
{
}

bool batch_save::start_transaction()
{
    _settings_query.clear();
    if(!_settings.transaction())
    {
        qCritical() << "ERROR in " __FILE__ << " " << __LINE__ << ": Can not start transaction";
        return false;
    }
    return true;
}

bool batch_save::save(QString literal)
{
    QString s = QString("INSERT OR FAIL INTO saved_kanji (literal) VALUES (?)");
    _settings_query.prepare(s);
    _settings_query.addBindValue(literal);
    if(!_settings_query.exec())
    {
        QString error = s.append(": ").append(_settings_query.lastError().text());
        qWarning() << error;
        _settings_query.clear();
        return false;
    }
    return true;
}

bool batch_save::commit()
{
    _settings_query.clear();
    if(!_settings.commit())
    {
        qCritical() << "ERROR in " __FILE__ << " " << __LINE__ << ": Can not commit";
        return false;
    }
    return true;
}
