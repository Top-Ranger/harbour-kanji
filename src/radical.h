#ifndef RADICAL_H
#define RADICAL_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>

class radical : public QObject
{
    Q_OBJECT
public:
    explicit radical(QSqlDatabase kanji, QObject *parent = 0);

    Q_INVOKABLE QString radical_by_number(int number);
    Q_INVOKABLE int number_by_radical(QString radical);

    Q_INVOKABLE void clear();
    Q_INVOKABLE bool get_all();
    Q_INVOKABLE bool next();
    Q_INVOKABLE int get_number();
    Q_INVOKABLE QString get_radical();

    Q_INVOKABLE void save_radical(int radical_to_save);
    Q_INVOKABLE int get_saved_radical();

signals:

public slots:

private:
    QSqlQuery _kanji_query;
    QSqlQuery _single_query;
    QString _radical;
    int _number;
    bool _started;

    int _save_radical;
};

#endif // RADICAL_H
