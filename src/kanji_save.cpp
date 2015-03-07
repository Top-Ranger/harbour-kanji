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

#include "kanji_save.h"
#include <QDebug>

kanji_save::kanji_save(QSqlDatabase settings, QObject *parent) :
    QObject(parent),
    _settings(settings),
    _settings_query(settings)
{
}

bool kanji_save::save(QString literal)
{
    QString s = QString("INSERT OR FAIL INTO saved_kanji (literal) VALUES (?)");
    _settings_query.clear();
    _settings_query.prepare(s);
    _settings_query.addBindValue(literal);
    if(!_settings_query.exec())
    {
        QString error = s.append(": ").append(_settings_query.lastError().text());
        qWarning() << error;
        _settings_query.clear();
        return false;
    }
    _settings.commit();
    return true;
}

bool kanji_save::unsave(QString literal)
{
    QString s = QString("DELETE FROM saved_kanji WHERE literal=?");
    _settings_query.clear();
    _settings_query.prepare(s);
    _settings_query.addBindValue(literal);
    if(!_settings_query.exec())
    {
        QString error = s.append(": ").append(_settings_query.lastError().text());
        qWarning() << error;
        _settings_query.clear();
        return false;
    }
    _settings.commit();
    return true;
}

bool kanji_save::unsave_all()
{
    QString s = QString("DELETE FROM saved_kanji");
    if(!_settings_query.exec(s))
    {
        QString error = s.append(": ").append(_settings_query.lastError().text());
        qWarning() << error;
        _settings_query.clear();
        return false;
    }
    _settings.commit();
    return true;
}
