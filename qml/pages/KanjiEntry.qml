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

ListItem {
    id: kanjientry

    property string literal: ""
    property string meaning: ""
    property bool saved: false

    width: parent.width

    Row {
        id: kanjirow

        anchors {
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }

        Label {
            text: kanjientry.literal
            color: Theme.primaryColor
        }
        Label {
            text: " "
            color: Theme.primaryColor
        }
        Label {
            text: kanjientry.meaning
            width: page.width / 3 * 2
            color: Theme.secondaryColor
            horizontalAlignment: Text.AlignLeft
            truncationMode: TruncationMode.Elide
        }
    }

    Image {
        id: star
        height: parent.height
        width: height
        anchors.right: parent.right
        source: kanjientry.saved ? "star.png" : "no_star.png"
    }

    menu: ContextMenu {
        id: contextmenu
        MenuItem {
            text: "Save Kanji"
            visible: !saved
            onClicked: {
                if(literal !== "") {
                    kanji_save.save(literal)
                    saved = true
                }
            }
        }

        MenuItem {
            text: "Remove Kanji from saved"
            visible: saved
            onClicked: {
                if(literal !== "") {
                    kanji_save.unsave(literal)
                    saved = false
                }
            }
        }
    }

    onClicked: {
        kanjiinfo.clear()
        if(kanjiinfo.search(kanjientry.literal)) {
            pageStack.push(Qt.resolvedUrl("Kanji.qml"))
        }
        else {
            panel.show()
            kanjiinfo.clear()
            console.log("ERROR in KanjiEntry.qml: Unknown literal " + kanjientry.literal)
        }
    }
}
