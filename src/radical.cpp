#include "radical.h"
#include <QDebug>

radical::radical(QSqlDatabase kanji, QObject *parent) :
    QObject(parent),
    _kanji_query(kanji),
    _single_query(kanji),
    _radical(""),
    _number(0),
    _started(false)
{
}

QString radical::radical_by_number(int number)
{
    _single_query.clear();
    QString s = QString("SELECT radical FROM radical WHERE number=?");
    _single_query.prepare(s);
    _single_query.addBindValue(number);
    if(_single_query.exec() && _single_query.isSelect() && _single_query.next())
    {
        return _single_query.value(0).toString();
    }
    else
    {
        return "";
    }
}

int radical::number_by_radical(QString radical)
{
    _single_query.clear();
    QString s = QString("SELECT radical FROM number WHERE radical=?");
    _single_query.prepare(s);
    _single_query.addBindValue(radical);
    if(_single_query.exec() && _single_query.isSelect() && _single_query.next())
    {
        return _single_query.value(0).toInt();
    }
    else
    {
        return 0;
    }
}

void radical::clear()
{
    _kanji_query.clear();
    _radical = "";
    _started = false;
    _number = 0;
}

bool radical::get_all()
{
    clear();
    QString s = QString("SELECT radical,number FROM radical ORDER BY number ASC");

    if(!_kanji_query.exec(s))
    {
        QString error = s.append(": ").append(_kanji_query.lastError().text());
        qWarning() << error;
        _kanji_query.clear();
        return false;
    }
    if(!_kanji_query.isSelect())
    {
        QString error = s.append(": No SELECT");
        qWarning() << error;
        _kanji_query.clear();
        return false;
    }
    _started = true;
    return true;
}

bool radical::next()
{
    if(!_started)
    {
        return false;
    }
    if(_kanji_query.next())
    {
        _radical = _kanji_query.value(0).toString();
        _number = _kanji_query.value(1).toInt();
        return true;
    }
    else
    {
        _started = false;
        return false;
    }
}

int radical::get_number()
{
    return _number;
}

QString radical::get_radical()
{
    return _radical;
}
