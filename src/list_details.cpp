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

#include "list_details.h"

#include <QDebug>

list_details::list_details(QSqlDatabase settings, QObject *parent) :
    QObject(parent),
    _settings(settings),
    _settings_query(settings),
    _save_query(settings),
    _list(""),
    _literal(""),
    _started(false)
{
}

void list_details::clear()
{
    _settings_query.clear();
    _save_query.clear();
    _list = "";
    _literal = "";
    _started = false;
}

bool list_details::show_details(QString list)
{
    clear();
    QString s = QString("SELECT literal FROM kanji_lists WHERE list=?");
    _settings_query.prepare(s);
    _settings_query.addBindValue(list);
    if(!_settings_query.exec())
    {
        QString error = s.append(": ").append(_settings_query.lastError().text());
        qWarning() << error;
        _settings_query.clear();
        return false;
    }
    _list = list;
    _started = true;
    return true;
}

bool list_details::next()
{
    if(!_started)
    {
        return false;
    }

    if(_settings_query.next())
    {
        _literal = _settings_query.value(0).toString();
        return true;
    }
    else
    {
        _started = false;
        return false;
    }
}

QString list_details::literal()
{
    return _literal;
}

QString list_details::list()
{
    return _list;
}

bool list_details::delete_from_list(QString literal, QString list)
{
    _save_query.clear();
    QString s = QString("DELETE FROM kanji_lists WHERE literal=? AND list=?");

    _save_query.prepare(s);
    _save_query.addBindValue(literal);
    _save_query.addBindValue(list);

    if(!_save_query.exec())
    {
        QString error = s.append(": ").append(_save_query.lastError().text());
        qWarning() << error;
        _save_query.clear();
        return false;
    }
    _settings.commit();
    return true;
}

bool list_details::save_to_list(QString literal, QString list)
{
    _save_query.clear();
    QString s = QString("INSERT OR IGNORE INTO kanji_lists (literal, list) VALUES (?, ?)");

    _save_query.prepare(s);
    _save_query.addBindValue(literal);
    _save_query.addBindValue(list);

    if(!_save_query.exec())
    {
        QString error = s.append(": ").append(_save_query.lastError().text());
        qWarning() << error;
        _save_query.clear();
        return false;
    }
    _settings.commit();
    return true;
}
