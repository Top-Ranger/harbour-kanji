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

#include "search.h"
#include <QDebug>

namespace {
void add_value(QString &s, QString value, QString key, QString &v_1, QString &v_2, QString &v_3, QString &v_4, QString &v_5, int &count)
{
    ++count;
    switch(count)
    {
    case 1:
        v_1 = value;
        s.append(" WHERE ");
        s.append(key);
        break;
    case 2:
        v_2 = value;
        s.append(" AND ");
        s.append(key);
        break;
    case 3:
        v_3 = value;
        s.append(" AND ");
        s.append(key);
        break;
    case 4:
        v_4 = value;
        s.append(" AND ");
        s.append(key);
        break;
    case 5:
        v_5 = value;
        s.append(" AND ");
        s.append(key);
        break;
    default:
        qDebug() << "ERROR in " __FILE__ << " " << __LINE__ << ": Too many search terms";
    }
}
}

search::search(QSqlDatabase kanji, QSqlDatabase settings, QObject *parent) :
    QObject(parent),
    _kanji_query(kanji),
    _settings_query(settings),
    _literal_result(""),
    _meaning_result(""),
    _saved(""),
    _literal(""),
    _radical(0),
    _strokecount(0),
    _jlpt(0),
    _meaning(""),
    _search_for_saved(false),
    _saved_search_value(false),
    _search_started(false)
{
}

void search::clear()
{
    _kanji_query.clear();
    _settings_query.clear();
    _literal_result = "";
    _meaning_result = "";
    _saved = false;
    _literal = "";
    _radical = 0;
    _strokecount = 0;
    _jlpt = 0;
    _meaning = "";
    _search_for_saved = false;
    _saved_search_value = false;
    _search_started = false;
}

void search::search_literal(QString literal)
{
    _literal = literal;
}

void search::search_radical(int radical)
{
    _radical = radical;
}

void search::search_strokecount(int strokecount)
{
    _strokecount = strokecount;
}

void search::search_jlpt(int jlpt)
{
    _jlpt = jlpt;
}

void search::search_meaning(QString meaning)
{
    _meaning = meaning;
}

void search::search_saved(bool saved)
{
    _search_for_saved = true;
    _saved_search_value = saved;
}

bool search::start_search()
{
    if(_literal == "" && _radical == 0 && _strokecount == 0 && _jlpt == 0 && _meaning == "")
    {
        // Get all kanji
        QString s = QString("SELECT literal,meaning FROM kanji");
        if(!_kanji_query.exec(s))
        {
            QString error = s.append(": ").append(_kanji_query.lastError().text());
            qWarning() << error;
            _search_started = false;
            return false;
        }
        if(!_kanji_query.isSelect())
        {
            QString error = s.append(": No SELECT");
            qWarning() << error;
            _search_started = false;
            return false;
        }
    }
    else
    {
        // Search for all fitting kanji
        int count = 0;

        QString v_1;
        QString v_2;
        QString v_3;
        QString v_4;
        QString v_5;

        QString s = QString("SELECT literal,meaning FROM kanji");
        if(_literal != "")
        {
            add_value(s,QString("\%%1\%").arg(_literal),QString("literal LIKE ?"),v_1,v_2,v_3,v_4,v_5,count);
        }
        if(_radical != 0)
        {
            add_value(s,QString("%1").arg(_radical),QString("radical=?"),v_1,v_2,v_3,v_4,v_5,count);
        }
        if(_strokecount != 0)
        {
            add_value(s,QString("%1").arg(_strokecount),QString("strokecount=?"),v_1,v_2,v_3,v_4,v_5,count);
        }
        if(_jlpt != 0)
        {
            add_value(s,QString("%1").arg(_jlpt),QString("JLPT=?"),v_1,v_2,v_3,v_4,v_5,count);
        }
        if(_meaning != "")
        {
            add_value(s,QString("\%%1\%").arg(_meaning),QString("meaning LIKE ?"),v_1,v_2,v_3,v_4,v_5,count);
        }

        _kanji_query.clear();
        _kanji_query.prepare(s);

        if(count >= 1)
        {
            _kanji_query.addBindValue(v_1);
        }
        if(count >= 2)
        {
            _kanji_query.addBindValue(v_2);
        }
        if(count >= 3)
        {
            _kanji_query.addBindValue(v_3);
        }
        if(count >= 4)
        {
            _kanji_query.addBindValue(v_4);
        }
        if(count >= 5)
        {
            _kanji_query.addBindValue(v_5);
        }

        qDebug() << "DEBUG in " __FILE__ << " " << __LINE__ << ": SELECT statement:" << s;

        if(!_kanji_query.exec())
        {
            QString error = s.append(": ").append(_kanji_query.lastError().text());
            qWarning() << error;
            _search_started = false;
            return false;
        }
        if(!_kanji_query.isSelect())
        {
            QString error = s.append(": No SELECT");
            qWarning() << error;
            _search_started = false;
            return false;
        }
    }
    _search_started = true;
    return true;
}

bool search::next_hidden()
{
    if(!_search_started)
    {
        return false;
    }
    if(_kanji_query.next())
    {
        _literal_result = _kanji_query.value(0).toString();
        _meaning_result = _kanji_query.value(1).toString();

        QString s = QString("SELECT count(*) FROM saved_kanji WHERE literal=?");
        _settings_query.prepare(s);
        _settings_query.addBindValue(_literal_result);
        if(_settings_query.exec() && _settings_query.isSelect() && _settings_query.next() && _settings_query.value(0).toInt() > 0)
        {
            _saved = true;
        }
        else
        {
            _saved = false;
        }
        _settings_query.finish();
        return true;
    }
    else
    {
        return false;
    }
}

bool search::next()
{
    if(!_search_started)
    {
        return false;
    }
    if(!_search_for_saved)
    {
        return next_hidden();
    }
    else
    {
        while(next_hidden())
        {
            if(_saved_search_value == _saved)
            {
                return true;
            }
        }
        return false;
    }
}

QString search::literal()
{
    return _literal_result;
}

QString search::meaning()
{
    return _meaning_result;
}

bool search::kanji_is_saved()
{
    return _saved;
}
