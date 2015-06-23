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

#include "train.h"
#include <QDebug>
#include <QTime>

train::train(QSqlDatabase settings, QObject *parent) :
    QObject(parent),
    _settings_query(settings),
    _literal(""),
    _started(false)
{
    qsrand(QTime(0,0,0).secsTo(QTime::currentTime()));
}

bool train::start_test()
{
    _started = false;
    _settings_query.clear();
    _literal_list.clear();

    QString s = QString("SELECT literal FROM saved_kanji");

    if(!_settings_query.exec(s))
    {
        QString error = s.append(": ").append(_settings_query.lastError().text());
        qWarning() << error;
        _settings_query.clear();
        return false;
    }
    if(!_settings_query.isSelect())
    {
        QString error = s.append(": No SELECT");
        qWarning() << error;
        _settings_query.clear();
        return false;
    }
    while(_settings_query.next())
    {
        _literal_list.append(_settings_query.value(0).toString());
    }
    _settings_query.finish();
    _started = true;
    return true;
}

bool train::start_test_list(QString list)
{
    _started = false;
    _settings_query.clear();
    _literal_list.clear();

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
    if(!_settings_query.isSelect())
    {
        QString error = s.append(": No SELECT");
        qWarning() << error;
        _settings_query.clear();
        return false;
    }
    while(_settings_query.next())
    {
        _literal_list.append(_settings_query.value(0).toString());
    }
    _settings_query.finish();
    _started = true;
    return true;
}

bool train::next()
{
    if(!_started)
    {
        return false;
    }
    if(_literal_list.length() == 0)
    {
        _started = false;
        return false;
    }
    _literal = _literal_list.takeAt(qrand()%_literal_list.length());
    return true;
}

QString train::literal()
{
    return _literal;
}

bool train::started()
{
    return _started;
}
