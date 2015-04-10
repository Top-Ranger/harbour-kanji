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
#include <QVariant>
#include <QVariantList>

namespace {
QString get_seperator(int &count)
{
    ++count;
    if(count == 1)
    {
        return " WHERE ";
    }
    else
    {
        return " AND ";
    }
}
}

search::search(QString settings_path, QObject *parent) :
    QObject(parent),
    _database(),
    _kanji_query(),
    _settings_query(),
    _literal_result(""),
    _meaning_result(""),
    _saved(""),
    _literal(""),
    _radical(-1),
    _strokecount(-1),
    _jlpt(-1),
    _meaning(""),
    _search_for_saved(false),
    _saved_search_value(false),
    _skip1(0),
    _skip2(0),
    _skip3(0),
    _search_started(false)
{
    _database = QSqlDatabase::addDatabase("QSQLITE");
    _database.setDatabaseName(":memory:");
    if(!_database.open())
    {
        qCritical() << "ERROR in " __FILE__ << " " << __LINE__ << ": Can not create database";
    }
    _kanji_query = QSqlQuery(_database);
    _settings_query = QSqlQuery(_database);

    QString s = QString("ATTACH DATABASE '/usr/share/harbour-kanji/kanjidb.sqlite3' AS kanjidb");
    if(!_kanji_query.exec(s))
    {
        QString error = s.append(": ").append(_kanji_query.lastError().text());
        qWarning() << error;
    }
    s = QString("ATTACH DATABASE ? AS settingsdb");
    _kanji_query.clear();
    _kanji_query.prepare(s);
    _kanji_query.addBindValue(settings_path);
    if(!_kanji_query.exec())
    {
        QString error = s.append(": ").append(_kanji_query.lastError().text());
        qWarning() << error;
    }
    _kanji_query.clear();
}

void search::clear()
{
    _kanji_query.clear();
    _settings_query.clear();
    _literal_result = "";
    _meaning_result = "";
    _saved = false;
    _literal = "";
    _radical = -1;
    _strokecount = -1;
    _jlpt = -1;
    _meaning = "";
    _search_for_saved = false;
    _saved_search_value = false;
    _skip1 = 0;
    _skip2 = 0;
    _skip3 = 0;
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

void search::search_skip(int skip1, int skip2, int skip3)
{
    _skip1 = skip1;
    _skip2 = skip2;
    _skip3 = skip3;
}

bool search::start_search()
{
    if(_literal == "" && _radical == -1 && _strokecount == -1 && _jlpt == -1 && _meaning == "" && _skip1 == 0 && _skip2 == 0 && _skip3 == 0)
    {
        // Get all kanji
        QString s = QString("SELECT literal,meaning FROM kanjidb.kanji");
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
        QVariantList search_list;

        QString s = QString("SELECT kanjidb.kanji.literal,meaning FROM kanjidb.kanji LEFT JOIN settingsdb.custom_translation ON kanjidb.kanji.literal=settingsdb.custom_translation.literal");
        if(_literal != "")
        {
            s.append(get_seperator(count));
            s.append("literal LIKE ?");
            search_list.append(QString("\%%1\%").arg(_literal));
        }
        if(_radical != -1)
        {
            s.append(get_seperator(count));
            s.append("radical=?");
            search_list.append(_radical);
        }
        if(_strokecount != -1)
        {
            s.append(get_seperator(count));
            s.append("strokecount=?");
            search_list.append(_strokecount);
        }
        if(_jlpt != -1)
        {
            s.append(get_seperator(count));
            s.append("JLPT=?");
            search_list.append(_jlpt);
        }
        if(_meaning != "")
        {
            s.append(get_seperator(count));
            s.append("(meaning LIKE ? OR translation LIKE ?)");
            search_list.append(QString("\%%1\%").arg(_meaning));
            search_list.append(QString("\%%1\%").arg(_meaning));
        }
        if(_skip1 != 0)
        {
            s.append(get_seperator(count));
            s.append("skip_1=?");
            search_list.append(_skip1);
        }
        if(_skip2 != 0)
        {
            s.append(get_seperator(count));
            s.append("skip_2=?");
            search_list.append(_skip2);
        }
        if(_skip3 != 0)
        {
            s.append(get_seperator(count));
            s.append("skip_3=?");
            search_list.append(_skip3);
        }

        _kanji_query.clear();
        _kanji_query.prepare(s);
        foreach (QVariant var, search_list) {
            _kanji_query.addBindValue(var);
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

        QString s = QString("SELECT count(*) FROM settingsdb.saved_kanji WHERE literal=?");
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
        _search_started = false;
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
