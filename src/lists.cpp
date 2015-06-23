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

#include "lists.h"
#include <QDebug>

lists::lists(QSqlDatabase settings, QObject *parent) :
    QObject(parent),
    _settings(settings),
    _settings_query(settings),
    _lists_query(settings),
    _search_started(false),
    _list_name("")
{
}

bool lists::get_all_lists()
{
    _lists_query.clear();

    QString s = QString("SELECT list FROM kanji_lists GROUP BY list ORDER BY list ASC");
    if(!_lists_query.exec(s))
    {
        QString error = s.append(": ").append(_lists_query.lastError().text());
        qWarning() << error;
        _lists_query.clear();
        return false;
    }
    if(!_lists_query.isSelect())
    {
        QString error = s.append(": No SELECT");
        qWarning() << error;
        _lists_query.clear();
        return false;
    }
    _search_started = true;
    return true;
}

bool lists::search_started()
{
    return _search_started;
}

bool lists::next()
{
    if(!_search_started)
    {
        return false;
    }
    if(_lists_query.next())
    {
        _list_name = _lists_query.value(0).toString();
        return true;
    }
    else
    {
        _lists_query.finish();
        _search_started = false;
        return false;
    }
}

QString lists::list_name()
{
    return _list_name;
}

void lists::clear()
{
    _lists_query.clear();
    _settings_query.clear();
    _search_started = false;
    _list_name = "";
}

bool lists::save_to_list(QString list)
{
    _settings_query.clear();
    _lists_query.clear();

    _settings.transaction();

    QString settings_s = QString("SELECT literal FROM saved_kanji");
    QString lists_s = QString("INSERT OR IGNORE INTO kanji_lists (literal, list) VALUES (?, ?)");

    if(!_settings_query.exec(settings_s))
    {
        QString error = settings_s.append(": ").append(_settings_query.lastError().text());
        qWarning() << error;
        _lists_query.clear();
        return false;
    }
    if(!_settings_query.isSelect())
    {
        QString error = settings_s.append(": No SELECT");
        qWarning() << error;
        _lists_query.clear();
        return false;
    }

    while(_settings_query.next())
    {
        _lists_query.prepare(lists_s);
        _lists_query.addBindValue(_settings_query.value(0).toString());
        _lists_query.addBindValue(list);
        if(!_lists_query.exec())
        {
            QString error = lists_s.append(": ").append(_lists_query.lastError().text());
            qWarning() << error;
            _lists_query.clear();
            return false;
        }
    }
    _settings.commit();
    _lists_query.finish();
    return true;
}

bool lists::load_from_list(QString list)
{
    _settings_query.clear();
    _lists_query.clear();

    _settings.transaction();

    QString settings_s = QString("INSERT OR IGNORE INTO saved_kanji (literal) VALUES (?)");
    QString lists_s = QString("SELECT literal FROM kanji_lists WHERE list=?");

    _lists_query.prepare(lists_s);
    _lists_query.addBindValue(list);

    if(!_lists_query.exec())
    {
        QString error = lists_s.append(": ").append(_lists_query.lastError().text());
        qWarning() << error;
        _lists_query.clear();
        return false;
    }
    if(!_lists_query.isSelect())
    {
        QString error = lists_s.append(": No SELECT");
        qWarning() << error;
        _lists_query.clear();
        return false;
    }

    while(_lists_query.next())
    {
        _settings_query.prepare(settings_s);
        _settings_query.addBindValue(_lists_query.value(0).toString());
        if(!_settings_query.exec())
        {
            QString error = settings_s.append(": ").append(_settings_query.lastError().text());
            qWarning() << error;
            _lists_query.clear();
            return false;
        }
    }
    _settings.commit();
    _lists_query.finish();
    return true;
}

bool lists::delete_list(QString list)
{
    _lists_query.clear();
    QString s = QString("DELETE FROM kanji_lists WHERE list=?");
    _lists_query.prepare(s);
    _lists_query.addBindValue(list);
    if(!_lists_query.exec())
    {
        QString error = s.append(": ").append(_lists_query.lastError().text());
        qWarning() << error;
        _lists_query.clear();
        return false;
    }
    _lists_query.finish();
    return true;
}
