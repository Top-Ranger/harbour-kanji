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
        property bool saved: kanjiinfo.saved()
        property string literal: kanjiinfo.literal()
        property int count: 0
    }

    Item {
        id: functions

        function update() {
            listModel.clear()
            _update_step()
        }

        function _update_step() {
            while(search.next()) {
                listModel.append({"element_literal": search.literal(), "element_meaning": search.meaning(), "element_saved": search.kanji_is_saved()})
                variable.count += 1
                if(variable.count%100 === 0) {
                    timer.stop()
                    timer.start()
                    return
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 10
        onTriggered: functions._update_step()
    }

    ListModel {
        id: listModel

        Component.onCompleted: functions.update()
    }

    SilicaListView {
        id: list
        model: listModel
        anchors.fill: parent
        currentIndex: -1

        header: PageHeader {
            title: "Search results: " + variable.count
        }

        delegate: KanjiEntry {
            literal: element_literal
            meaning: element_meaning
            saved: element_saved
        }

        VerticalScrollDecorator {}

    }

    Label {
        visible: variable.count == 0
        anchors.centerIn: parent
        text: "No Kanji found"
        font.pixelSize: Theme.fontSizeExtraLarge
    }

    UpperPanel {
        id: panel
        text: "Can not open Kanji"
    }
}
