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

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: about

    SilicaFlickable {

        VerticalScrollDecorator {}

        PullDownMenu {
            visible: false
        }

        anchors.fill: parent

        contentHeight: mainColumn.height

        Column {
            id: mainColumn

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: "About"
            }

            Label {
                text: "Kanji Version 1.3"
            }

            Text  {

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }

                id: aboutText
                focus: true
                color: Theme.primaryColor
                width: about.width
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap

                text: "Copyright (C) 2014,2015 Marcus Soll
Copyright (C) 2013 Jolla Ltd.
All rights reserved.

You may use this program under the terms of BSD license as follows:

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Jolla Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
            }

            PageHeader {
                title: "About KANJIDIC2"
            }

            Text  {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }

                id: aboutKANJIDIC2Text
                focus: true
                color: Theme.primaryColor
                width: about.width
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                onLinkActivated: Qt.openUrlExternally("file:///usr/share/harbour-kanji/cc4.0-by-sa.license.html")

                text: "<html>The database 'kanjidb.sqlite3' is based on the KANJIDIC2 dictionary file (http://www.csse.monash.edu.au/~jwb/kanjidic2/).
These file is the property of the Electronic Dictionary Research and Development Group (http://www.edrdg.org/), and is used in conformance with the Group's licence.
The database file is therefore under the same license.

See <a href=\"file:///usr/share/harbour-kanji/cc4.0-by-sa.license.html\">/usr/share/harbour-kanji/cc4.0-by-sa.license.html</a> for more information.</html>"
            }

            PageHeader {
                title: "About SKIP"
            }

            Text  {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }

                id: aboutSKIPText
                focus: true
                color: Theme.primaryColor
                width: about.width
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                onLinkActivated: Qt.openUrlExternally("file:///usr/share/harbour-kanji/cc4.0-by-sa.license.html")

                text: "<html>The SKIP (System of Kanji Indexing by Patterns) system for ordering kanji was developed by Jack Halpern (Kanji Dictionary Publishing Society at http://www.kanji.org/), and is used with his permission.

See <a href=\"file:///usr/share/harbour-kanji/cc4.0-by-sa.license.html\">/usr/share/harbour-kanji/cc4.0-by-sa.license.html</a> for more information.</html>"
            }

            PageHeader {
                title: "Special thanks"
            }

            Text  {

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }

                id: specialThanks
                focus: true
                color: Theme.primaryColor
                width: about.width
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap

                text: "Special thanks to Kenney (www.kenney.nl) for the free release of 'Game Icons'"
            }
        }
    }
}
