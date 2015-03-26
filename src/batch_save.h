#ifndef BATCH_SAVE_H
#define BATCH_SAVE_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>

class batch_save : public QObject
{
    Q_OBJECT
public:
    explicit batch_save(QSqlDatabase settings, QObject *parent = 0);

    Q_INVOKABLE bool start_transaction();
    Q_INVOKABLE bool save(QString literal);
    Q_INVOKABLE bool commit();

signals:

public slots:

private:
    QSqlDatabase _settings;
    QSqlQuery _settings_query;
};

#endif // BATCH_SAVE_H
