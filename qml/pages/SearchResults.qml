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

    onVisibleChanged: {
        functions.check_saved_changed()
        functions.check_translation_changed()
    }

    Item {
        id: functions

        function update() {
            variable.count = 0
            listModel.clear()
            _update_step()
        }

        function _update_step() {
            while(search.next()) {
                listModel.append({"element_literal": search.literal(), "element_meaning": search.meaning(), "element_saved": search.kanji_is_saved(), "element_translation": translation.get_translation(search.literal())})
                variable.count += 1
                if(variable.count%100 === 0) {
                    timer.stop()
                    timer.start()
                    return
                }
            }
        }

        function save_all() {
            batch_save.start_transaction()
            for(var i = 0; i < variable.count; ++i) {
                var element = listModel.get(i)
                if(element.element_saved) {
                    continue
                }

                if(batch_save.save(element.element_literal)) {
                    element.element_saved = true
                }
                else {
                    panel_save.show()
                }
            }
            batch_save.commit()
        }

        function check_saved_changed() {
            var literal_changed = kanji_save.last_changed()
            if(literal_changed !== "") {
                kanji_save.set_last_changed("")
                for(var i = 0; i < variable.count; i++) {
                    if(listModel.get(i).element_literal === literal_changed) {
                        listModel.get(i).element_saved = kanji_save.last_changed_value()
                        return
                    }
                }
            }
        }


        function check_translation_changed() {
            var literal_changed = translation.last_changed()
            if(literal_changed !== "") {
                translation.set_last_changed("")
                for(var i = 0; i < variable.count; i++) {
                    if(listModel.get(i).element_literal === literal_changed) {
                        listModel.get(i).element_translation = translation.get_translation(literal_changed)
                        return
                    }
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 2
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

        PullDownMenu {
            MenuItem {
                text: "Save all"
                onClicked: functions.save_all()
            }
        }

        header: Column {
            width: parent.width

            PageHeader {
                title: "Search results: " + variable.count
            }
        }

        delegate: ListItem {
            id: kanjientry

            property string literal: element_literal
            property string meaning: element_translation !== "" ? element_translation : element_meaning
            property bool saved: element_saved

            width: parent.width

            Row {
                id: kanjirow
                width: parent.width - 2*Theme.paddingLarge
                anchors.centerIn: parent

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
                anchors.right: kanjirow.right
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
                            kanji_save.set_last_changed(literal)
                            kanji_save.set_last_changed_value(true)
                            functions.check_saved_changed()
                        }
                    }
                }

                MenuItem {
                    text: "Remove Kanji from saved"
                    visible: saved
                    onClicked: {
                        if(literal !== "") {
                            kanji_save.unsave(literal)
                            kanji_save.set_last_changed(literal)
                            kanji_save.set_last_changed_value(false)
                            functions.check_saved_changed()
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

    UpperPanel {
        id: panel_save
        text: "Can not save Kanji"
    }
}
