# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-kanji

CONFIG += sailfishapp

QT += sql

license.files = LICENSE.txt
license.path = /usr/share/$${TARGET}

database.files = kanjidb.sqlite3 \
    cc4.0-by-sa.license.html
database.path = /usr/share/$${TARGET}

INSTALLS += license database

SOURCES += src/harbour-kanji.cpp \
    src/search.cpp \
    src/kanjiinfo.cpp \
    src/kanji_save.cpp \
    src/train.cpp \
    src/lists.cpp \
    src/radical.cpp \
    src/list_details.cpp \
    src/batch_save.cpp \
    src/comment.cpp \
    src/translation.cpp

OTHER_FILES += qml/harbour-kanji.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-kanji.spec \
    rpm/harbour-kanji.yaml \
    translations/*.ts \
    harbour-kanji.desktop \
    kanjidb.sqlite3 \
    harbour-kanji.png \
    README.md \
    LICENSE.txt \
    qml/pages/Kanji.qml \
    qml/pages/SearchResults.qml \
    qml/pages/About.qml \
    qml/pages/Search.qml \
    qml/pages/UpperPanel.qml \
    qml/cover/cover.png \
    qml/pages/no_star.png \
    qml/pages/star.png \
    qml/pages/Train.qml \
    qml/pages/ListManagement.qml \
    qml/pages/RadicalSelection.qml \
    qml/pages/ListDetails.qml \
    qml/pages/SKIP.qml \
    ChangeLog.txt \
    cc4.0-by-sa.license.html

HEADERS += \
    src/search.h \
    src/kanjiinfo.h \
    src/kanji_save.h \
    src/train.h \
    src/lists.h \
    src/radical.h \
    src/list_details.h \
    src/batch_save.h \
    src/comment.h \
    src/translation.h

