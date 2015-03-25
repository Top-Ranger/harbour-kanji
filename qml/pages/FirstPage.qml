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

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }

            MenuItem {
                text: "About SKIP system usage"
                onClicked: pageStack.push(Qt.resolvedUrl("SKIP.qml"))
            }

            MenuItem {
                text: "Manage saved Kanji"
                onClicked: pageStack.push(Qt.resolvedUrl("ListManagement.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: "Kanji"
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: "Search"
                    anchors.centerIn: parent
                }

                onClicked: pageStack.push(Qt.resolvedUrl("Search.qml"))
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: "Train saved Kanji"
                    anchors.centerIn: parent
                }

                onClicked: {
                    if(train.start_test()) {
                        pageStack.push(Qt.resolvedUrl("Train.qml"))
                    }
                    else {
                        panel.show()
                    }
                }
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: "Show saved Kanji"
                    anchors.centerIn: parent
                }

                onClicked: {
                    search.clear()
                    search.search_saved(true)
                    if(search.start_search()) {
                        pageStack.push(Qt.resolvedUrl("SearchResults.qml"))
                    }
                    else {
                        panel.show()
                    }
                }
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: "Show all Kanji"
                    anchors.centerIn: parent
                }

                onClicked: {
                    search.clear()
                    if(search.start_search()) {
                        pageStack.push(Qt.resolvedUrl("SearchResults.qml"))
                    }
                    else {
                        panel.show()
                    }
                }
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: "JLPT Level 1"
                    anchors.centerIn: parent
                }

                onClicked: {
                    search.clear()
                    search.search_jlpt(1)
                    if(search.start_search()) {
                        pageStack.push(Qt.resolvedUrl("SearchResults.qml"))
                    }
                    else {
                        panel.show()
                    }
                }
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: "JLPT Level 2"
                    anchors.centerIn: parent
                }

                onClicked: {
                    search.clear()
                    search.search_jlpt(2)
                    if(search.start_search()) {
                        pageStack.push(Qt.resolvedUrl("SearchResults.qml"))
                    }
                    else {
                        panel.show()
                    }
                }
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: "JLPT Level 3"
                    anchors.centerIn: parent
                }

                onClicked: {
                    search.clear()
                    search.search_jlpt(3)
                    if(search.start_search()) {
                        pageStack.push(Qt.resolvedUrl("SearchResults.qml"))
                    }
                    else {
                        panel.show()
                    }
                }
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: "JLPT Level 4"
                    anchors.centerIn: parent
                }

                onClicked: {
                    search.clear()
                    search.search_jlpt(4)
                    if(search.start_search()) {
                        pageStack.push(Qt.resolvedUrl("SearchResults.qml"))
                    }
                    else {
                        panel.show()
                    }
                }
            }
        }
    }
    UpperPanel {
        id: panel
        text: "Error while performing action"
    }
}


