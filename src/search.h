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

#ifndef SEARCH_H
#define SEARCH_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>
#include <QMultiMap>

class search : public QObject
{
    Q_OBJECT
public:
    explicit search(QString settings_path, QObject *parent = 0);

    Q_INVOKABLE void clear();

    Q_INVOKABLE void search_literal(QString literal);
    Q_INVOKABLE void search_radical(int radical);
    Q_INVOKABLE void search_strokecount(int strokecount);
    Q_INVOKABLE void search_jlpt(int jlpt);
    Q_INVOKABLE void search_meaning(QString meaning);
    Q_INVOKABLE void search_skip(int skip1, int skip2, int skip3);
    Q_INVOKABLE void search_comment(QString comment);
    Q_INVOKABLE void search_saved(bool saved);

    Q_INVOKABLE bool start_search();

    Q_INVOKABLE bool next();
    Q_INVOKABLE QString literal();
    Q_INVOKABLE QString meaning();
    Q_INVOKABLE QString translation();
    Q_INVOKABLE bool kanji_is_saved();
    Q_INVOKABLE bool search_started();

signals:
    void search_started_changed();

public slots:

private:
    struct kanji_data
    {
        QString literal;
        QString meaning;
        QString translation;
        bool saved;
    };

    bool next_hidden();
    void populate_map();
    int calculate_similarity(kanji_data &kanji);

    QSqlDatabase _database;

    QSqlQuery _kanji_query;
    QSqlQuery _settings_query;

    QString _literal_result;
    QString _meaning_result;
    QString _translation_result;
    bool _saved;

    QString _literal;
    int _radical;
    int _strokecount;
    int _jlpt;
    QString _meaning;

    bool _search_for_saved;
    bool _saved_search_value;

    int _skip1;
    int _skip2;
    int _skip3;

    QString _comment;

    bool _search_started;

    QMultiMap<int, kanji_data> _kanji_map;
    QMultiMap<int, kanji_data>::iterator _iterator;
    QMultiMap<int, kanji_data>::iterator _last_iterator;

   int _count;
};

#endif // SEARCH_H
