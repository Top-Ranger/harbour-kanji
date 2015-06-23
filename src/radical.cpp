/*
  Copyright (C) 2015 Marcus Soll
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "radical.h"
#include <QDebug>

radical::radical(QSqlDatabase kanji, QObject *parent) :
    QObject(parent),
    _kanji_query(kanji),
    _single_query(kanji),
    _radical(""),
    _number(0),
    _started(false),
    _save_radical(0)
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
        s = _single_query.value(0).toString();
        _single_query.finish();
        return s;
    }
    else
    {
        _single_query.finish();
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
        int i = _single_query.value(0).toInt();
        _single_query.finish();
        return i;
    }
    else
    {
        _single_query.finish();
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
        _kanji_query.finish();
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

void radical::save_radical(int radical_to_save)
{
    _save_radical = radical_to_save;
}

int radical::get_saved_radical()
{
    return _save_radical;
}
