/*
  Copyright (C) 2015 Marcus Soll
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
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

#include <QtQuick>

#include <sailfishapp.h>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFile>
#include <QDir>

#include "search.h"
#include "kanjiinfo.h"
#include "kanji_save.h"
#include "train.h"
#include "lists.h"
#include "radical.h"
#include "list_details.h"
#include "batch_save.h"
#include "comment.h"
#include "translation.h"

bool create_new_settings_db(QSqlDatabase settings);
bool test_and_update_settings_db(QSqlDatabase settings);

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    // Connect to KanjiDB
    QSqlDatabase kanjidb = QSqlDatabase::addDatabase(QString("QSQLITE"), "kanjidb");
    kanjidb.setDatabaseName("/usr/share/harbour-kanji/kanjidb.sqlite3");
    kanjidb.setConnectOptions("QSQLITE_OPEN_READONLY=true");
    if(!kanjidb.open())
    {
        qDebug() << kanjidb.lastError().text();
        qFatal("Can't open kanjidb.sqlite3");
    }

    // Connect to settings DB
    QString path = QString(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation));
    path.append("/harbour-kanji");
    QDir dir(path);

    if(!dir.exists())
    {
        qDebug() << "DEBUG in " __FILE__ << " " << __LINE__ << ": Creating directory" << path;
        dir.mkdir(path);
    }

    path.append("/settings.sqlite3");
    QFile file(path);
    bool exists = file.exists();

    QSqlDatabase settingsdb = QSqlDatabase::addDatabase(QString("QSQLITE"), "settings");
    settingsdb.setDatabaseName(path);
    if(!settingsdb.open())
    {
        qDebug() << settingsdb.lastError().text();
        qFatal("Can't open settings.sqlite3");
    }

    if(!exists)
    {
        if(!create_new_settings_db(settingsdb))
        {
            settingsdb.close();
            file.remove();
            qFatal("Can't create settings.sqlite3");
        }
    }
    else
    {
        if(!test_and_update_settings_db(settingsdb))
        {
            settingsdb.close();
            file.remove();
            qFatal("Can't read/update settings.sqlite3");
        }
    }

    // Add classes to QQuickView
    QGuiApplication *app = SailfishApp::application(argc,argv);

    search search_class(path);
    kanjiinfo kanjiinfo_class(kanjidb, settingsdb);
    kanji_save kanji_save_class(settingsdb);
    train train_class(settingsdb);
    lists lists_class(settingsdb);
    radical radical_class(kanjidb);
    list_details list_details_class(settingsdb);
    batch_save batch_save_class(settingsdb);
    comment comment_class(settingsdb);
    translation translation_class(settingsdb);


    QQuickView *view = SailfishApp::createView();

    view->rootContext()->setContextProperty("search", &search_class);
    view->rootContext()->setContextProperty("kanjiinfo", &kanjiinfo_class);
    view->rootContext()->setContextProperty("kanji_save", &kanji_save_class);
    view->rootContext()->setContextProperty("train", &train_class);
    view->rootContext()->setContextProperty("lists", &lists_class);
    view->rootContext()->setContextProperty("radical", &radical_class);
    view->rootContext()->setContextProperty("list_details", &list_details_class);
    view->rootContext()->setContextProperty("batch_save", &batch_save_class);
    view->rootContext()->setContextProperty("comment", &comment_class);
    view->rootContext()->setContextProperty("translation", &translation_class);

    // Start application
    view->setSource(SailfishApp::pathTo("qml/harbour-kanji.qml"));
    view->show();

    return app->exec();
}

bool create_new_settings_db(QSqlDatabase settings)
{
    qDebug() << "DEBUG in " __FILE__ << " " << __LINE__ << ": Creating settingsdb";

    QSqlQuery query(settings);

    QStringList operations;
    operations.append("CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT)");
    operations.append("CREATE TABLE saved_kanji (literal TEXT PRIMARY KEY)");
    operations.append("CREATE TABLE kanji_lists (literal TEXT, list TEXT, PRIMARY KEY(literal, list))");
    operations.append("CREATE TABLE comment (literal TEXT PRIMARY KEY, comment_text TEXT)");
    operations.append("CREATE TABLE custom_translation (literal TEXT PRIMARY KEY, translation TEXT)");
    operations.append("CREATE TABLE settings (literal TEXT PRIMARY KEY)");
    operations.append("INSERT INTO meta VALUES ('settings_version', '2')");

    foreach(QString s, operations)
    {
        if(!query.exec(s))
        {
            QString error = s.append(": ").append(query.lastError().text());
            qWarning() << error;
            return false;
        }
    }

    return true;
}

bool test_and_update_settings_db(QSqlDatabase settings)
{
    QSqlQuery query(settings);
    QStringList operations;
    QString s = QString("SELECT value FROM meta WHERE key='settings_version'");

    if(!query.exec(s))
    {
        QString error = s.append(": ").append(query.lastError().text());
        qWarning() << error;
        return true;
    }
    if(!query.isSelect())
    {
        QString error = s.append(": No SELECT");
        qWarning() << error;
        return false;
    }
    if(!query.next())
    {
        qDebug() << "DEBUG in " __FILE__ << " " << __LINE__ << ": No metadata 'settings_version'";
        return false;
    }

    switch(query.value(0).toInt())
    {
    // Upgrade settings
    case 1:
        qDebug() << "DEBUG in " __FILE__ << " " << __LINE__ << ": Upgrade 'settings_version'=1 to 'settings_version'=2";
        query.clear();
        operations.clear();
        operations.append("CREATE TABLE comment (literal TEXT PRIMARY KEY, comment_text TEXT)");
        operations.append("CREATE TABLE custom_translation (literal TEXT PRIMARY KEY, translation TEXT)");
        operations.append("UPDATE OR FAIL meta SET value='2' WHERE key='settings_version'");
        foreach(s, operations)
        {
            if(!query.exec(s))
            {
                QString error = s.append(": ").append(query.lastError().text());
                qWarning() << error;
                return false;
            }
        }
        qDebug() << "DEBUG in " __FILE__ << " " << __LINE__ << ": Upgrade complete";

    case 2:
        qDebug() << "DEBUG in " __FILE__ << " " << __LINE__ << ": Used 'settings_version'=2";
        return true;
        break;

    default:
        qDebug() << "DEBUG in " __FILE__ << " " << __LINE__ << ": Unknown 'settings_version'";
        return false;
        break;
    }
}
