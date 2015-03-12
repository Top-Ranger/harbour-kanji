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
    id: page

    Item {
        id: variable
        property bool finished: false
        property bool showall: false
        property string literal: ""
    }

    UpperPanel {
        id: panel
        text: "Could not load Kanji" + variable.literal
    }

    Item {

        Component.onCompleted: { functions.getNewKanji() }

        id: functions
        function getNewKanji () {
            if(variable.finished) {
                return
            }

            variable.showall = false

            if(train.next()) {
                variable.literal = train.literal()
                kanjiinfo.clear()
                if(kanjiinfo.search(variable.literal)) {
                    meaning_text.text = kanjiinfo.meaning()
                    radical_text.text = radical.radical_by_number(kanjiinfo.radical()) + " (" + kanjiinfo.radical() + ")"
                    strokecount_text.text = "" + kanjiinfo.strokecount()
                    on_text.text = kanjiinfo.ONreading()
                    kun_text.text = kanjiinfo.KUNreading()
                    nanori_text.text = kanjiinfo.nanori()
                }
                else {
                    panel.show()
                    variable.finished = true
                }
            }
            else {
                variable.finished = true
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: "Training"
            }

            Label {
                id: kanji
                visible: !variable.finished
                x: page.width/2 - width
                text: variable.literal
                font.pixelSize: Theme.fontSizeExtraLarge
            }

            Row  {
                Label {
                    id: labelmeaning
                    visible: !variable.finished
                    text: "Meaning: "
                    color: Theme.highlightColor
                }
                Text {
                    id: meaning_text
                    width: column.width - labelmeaning.width
                    visible: !variable.finished && variable.showall
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: ""
                }
            }

            Row  {
                Label {
                    text: "Radical: "
                    visible: !variable.finished
                    color: Theme.highlightColor
                }
                Label {
                    id: radical_text
                    visible: !variable.finished && variable.showall
                    text: ""
                }
            }

            Row  {
                Label {
                    text: "Stroke count: "
                    visible: !variable.finished
                    color: Theme.highlightColor
                }
                Label {
                    id: strokecount_text
                    visible: !variable.finished && variable.showall
                    text: ""
                }
            }

            Row  {
                Label {
                    id: labelon
                    visible: !variable.finished
                    text: "ON: "
                    color: Theme.highlightColor
                }
                Text {
                    id: on_text
                    visible: !variable.finished && variable.showall
                    width: column.width - labelon.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: ""
                }
            }

            Row  {
                Label {
                    id: labelkun
                    visible: !variable.finished
                    text: "KUN: "
                    color: Theme.highlightColor
                }
                Text {
                    id: kun_text
                    visible: !variable.finished && variable.showall
                    width: column.width - labelkun.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: ""
                }
            }

            Row  {
                Label {
                    visible: !variable.finished
                    text: "Nanori: "
                    color: Theme.highlightColor
                }
                Text {
                    id: nanori_text
                    visible: !variable.finished && variable.showall
                    width: column.width - labelmeaning.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: ""
                }
            }
        }
    }

    Label {
        visible: variable.finished
        anchors.centerIn: parent
        text: "All Kanji trained"
        font.pixelSize: Theme.fontSizeExtraLarge
    }

    Button {
        visible: !variable.finished && !variable.showall
        width: column.width
        anchors.bottom: parent.bottom
        text: "Reveal information"
        onClicked: variable.showall = true

        anchors {
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }
    }

    Button {
        visible: !variable.finished && variable.showall
        width: column.width
        anchors.bottom: parent.bottom
        text: "Next Kanji"
        onClicked: functions.getNewKanji()

        anchors {
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }
    }
}
