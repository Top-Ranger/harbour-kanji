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

#include "batch_save.h"
#include <QDebug>
#include <QVariant>

batch_save::batch_save(QSqlDatabase settings, QObject *parent) :
    QObject(parent),
    _settings(settings),
    _settings_query(settings),
    _transaction_started(false)
{
}

bool batch_save::start_transaction()
{
    _settings_query.clear();
    if(!_settings.transaction())
    {
        qCritical() << "ERROR in " __FILE__ << " " << __LINE__ << ": Can not start transaction";
        return false;
    }
    _transaction_started = true;
    return true;
}

bool batch_save::save(QString literal)
{
    if(!_transaction_started)
    {
        return false;
    }
    QString s = QString("INSERT OR IGNORE INTO saved_kanji (literal) VALUES (?)");
    _settings_query.prepare(s);
    _settings_query.addBindValue(literal);
    if(!_settings_query.exec())
    {
        QString error = s.append(": ").append(_settings_query.lastError().text());
        qWarning() << error;
        _settings_query.clear();

        if(!_settings_query.exec("ROLLBACK"))
        {
            qCritical() << "ERROR in " __FILE__ << " " << __LINE__ << ": Can not rollbach transaction";
        }
        _transaction_started = false;
        return false;
    }
    return true;
}

bool batch_save::commit()
{
    if(!_transaction_started)
    {
        return false;
    }
    if(!_settings.commit())
    {
        qCritical() << "ERROR in " __FILE__ << " " << __LINE__ << ": Can not commit";
        _settings_query.clear();
        if(!_settings_query.exec("ROLLBACK"))
        {
            qCritical() << "ERROR in " __FILE__ << " " << __LINE__ << ": Can not rollbach transaction";
        }
        _transaction_started = false;
        return false;
    }
    _settings_query.clear();
    _transaction_started = false;
    return true;
}

bool batch_save::save_array(QVariantList array)
{
    if(!start_transaction())
    {
        return false;
    }
    foreach (QVariant s, array)
    {
        if(!save(s.toString()))
        {
            return false;
        }
    }
    if(!commit())
    {
        return false;
    }
    return true;
}
