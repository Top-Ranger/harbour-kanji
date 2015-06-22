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
        property int count: 0
    }

    Item {
        id: functions

        function update() {
            variable.count = 0
            listModel.clear()
            _update_step()
        }

        function _update_step() {
            while(list_details.next()) {
                listModel.append({"element_literal": list_details.literal()})
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
                text: "Add list to saved Kanji"
                onClicked: remorsePopup.execute("Add list '" + list_details.list() + "' to saved Kanj", function() { if(!lists.load_from_list(list_details.list())) { panel.text = "Can not add Kanji from list"; panel.show() }} )
            }
        }

        header: PageHeader {
            title: "List '"+ list_details.list() + "': " + variable.count
        }

        delegate: ListItem {
            id: listentry

            property string literal: element_literal
            property bool in_list: true

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
                    text: listentry.literal
                    color: Theme.primaryColor
                }
                Label {
                    text: " "
                    color: Theme.primaryColor
                }
                Label {
                    text: kanjiinfo.meaning_by_literal(listentry.literal)
                    width: page.width / 3 * 2
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
            }

            Image {
                id: list_saved
                height: parent.height
                width: height
                anchors.right: kanjirow.right
                source: listentry.in_list ? "list.png" : "no_list.png"
            }

            menu: ContextMenu {
                id: contextmenu
                MenuItem {
                    text: "Undo removal"
                    visible: !listentry.in_list
                    onClicked: {
                        if(literal !== "") {
                            if(list_details.save_to_list(listentry.literal, list_details.list())) {
                                listentry.in_list = true
                            }
                            else {
                                panel.text = "Can not add Kanji"
                                panel.show()
                            }
                        }
                    }
                }

                MenuItem {
                    text: "Remove Kanji from list"
                    visible: listentry.in_list
                    onClicked: {
                        if(literal !== "") {
                            if(list_details.delete_from_list(listentry.literal, list_details.list())) {
                                listentry.in_list = false
                            }
                            else {
                                panel.text = "Can not remove Kanji"
                                panel.show()
                            }
                        }
                    }
                }
            }

            onClicked: {
                kanjiinfo.clear()
                if(kanjiinfo.search(listentry.literal)) {
                    pageStack.push(Qt.resolvedUrl("Kanji.qml"))
                }
                else {
                    panel.text = "Can not open Kanji"
                    panel.show()
                    kanjiinfo.clear()
                    console.log("ERROR in ListDetails.qml: Unknown literal " + kanjientry.literal)
                }
            }
        }

        VerticalScrollDecorator {}

    }

    Label {
        visible: variable.count == 0
        anchors.centerIn: parent
        text: "No Kanji in List"
        font.pixelSize: Theme.fontSizeExtraLarge
    }

    UpperPanel {
        id: panel
        text: "Error"
    }

    RemorsePopup {
        id: remorsePopup
    }
}
