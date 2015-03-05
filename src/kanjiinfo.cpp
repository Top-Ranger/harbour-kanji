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

#include "kanjiinfo.h"
#include <QDebug>

kanjiinfo::kanjiinfo(QSqlDatabase kanji, QSqlDatabase settings, QObject *parent) :
    QObject(parent),
    _kanji_query(kanji),
    _settings_query(settings),
    _literal(""),
    _radical(0),
    _strokecount(0),
    _JLPT(0),
    _ONreading(""),
    _KUNreading(""),
    _nanori(""),
    _meaning(""),
    _saved(false),
    _valid_kanji(false)
{
}

bool kanjiinfo::search(QString literal)
{
    clear();
    QString s = QString("SELECT literal,radical,strokecount,JLPT,ONreading,KUNreading,nanori,meaning FROM kanji WHERE literal=?");
    _kanji_query.prepare(s);
    _kanji_query.addBindValue(literal);

    if(!_kanji_query.exec())
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
    if(!_kanji_query.next())
    {
        _kanji_query.clear();
        return false;
    }

    _literal = _kanji_query.value(0).toString();
    _radical = _kanji_query.value(1).toInt();
    _strokecount = _kanji_query.value(2).toInt();
    _JLPT = _kanji_query.value(3).toInt();
    _ONreading = _kanji_query.value(4).toString();
    _KUNreading = _kanji_query.value(5).toString();
    _nanori = _kanji_query.value(6).toString();
    _meaning = _kanji_query.value(7).toString();

    s = QString("SELECT count(*) FROM saved_kanji WHERE literal=?");
    _settings_query.prepare(s);
    _settings_query.addBindValue(literal);
    if(_settings_query.exec() && _settings_query.isSelect() && _settings_query.next() && _settings_query.value(0).toInt() > 0)
    {
        _saved = true;
    }
    else
    {
        _saved = false;
    }
    _settings_query.finish();

    _valid_kanji = true;
    return true;
}

void kanjiinfo::clear()
{
    _kanji_query.clear();
    _settings_query.clear();
    _literal = "";
    _radical = 0;
    _strokecount = 0;
    _JLPT = 0;
    _ONreading = "";
    _KUNreading = "";
    _nanori = "";
    _meaning = "";
    _saved = false;
    _valid_kanji = false;
}

QString kanjiinfo::literal()
{
    return _literal;
}

int kanjiinfo::radical()
{
    return _radical;
}

int kanjiinfo::strokecount()
{
    return _strokecount;
}

int kanjiinfo::JLPT()
{
    return _JLPT;
}

QString kanjiinfo::ONreading()
{
    return _ONreading;
}

QString kanjiinfo::KUNreading()
{
    return _KUNreading;
}

QString kanjiinfo::nanori()
{
    return _nanori;
}

QString kanjiinfo::meaning()
{
    return _meaning;
}

bool kanjiinfo::saved()
{
    return _saved;
}

bool kanjiinfo::valid_kanji()
{
    return _valid_kanji;
}
