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

#ifndef KANJIINFO_H
#define KANJIINFO_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>

class kanjiinfo : public QObject
{
    Q_OBJECT
public:
    explicit kanjiinfo(QSqlDatabase kanji, QSqlDatabase settings, QObject *parent = 0);

    Q_INVOKABLE bool search(QString literal);
    Q_INVOKABLE void clear();

    Q_INVOKABLE QString literal();
    Q_INVOKABLE int radical();
    Q_INVOKABLE int strokecount();
    Q_INVOKABLE int JLPT();
    Q_INVOKABLE QString ONreading();
    Q_INVOKABLE QString KUNreading();
    Q_INVOKABLE QString nanori();
    Q_INVOKABLE QString meaning();
    Q_INVOKABLE bool saved();
    Q_INVOKABLE bool valid_kanji();

signals:

public slots:

private:
    QSqlQuery _kanji_query;
    QSqlQuery _settings_query;

    QString _literal;
    int _radical;
    int _strokecount;
    int _JLPT;
    QString _ONreading;
    QString _KUNreading;
    QString _nanori;
    QString _meaning;
    bool _saved;
    bool _valid_kanji;
};

#endif // KANJIINFO_H
