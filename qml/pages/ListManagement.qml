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
        id: variables
        property int count: 0
        property string currentlist: ""
    }

    Item {
        id: functions
        function update() {
            variables.count = 0
            variables.currentlist = ""
            lists.clear()
            listModel.clear()
            if(!lists.get_all_lists()) {
                lists.clear()
                panel.text = "Can not load lists"
                panel.show()
                return
            }
            while(lists.next()) {
                listModel.append({"element_list": lists.list_name()})
                variables.count += 1
            }
        }
    }

    ListModel {
        id: listModel
        Component.onCompleted: functions.update()
    }

    SilicaListView {
        id: list
        model: listModel
        anchors.fill: parent

        header: Column {
            id: header
            width: parent.width

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: "Manage saved Kanji"
            }

            Button {
                width: parent.width
                text: "Delete all saved Kanji"
                onClicked: remorsePopup.execute("Delete all saved Kanji", function() { if(!kanji_save.unsave_all()) { panel.text = "Can not delete Kanji"; panel.show() }; functions.update() } )
            }

            Button {
                width: parent.width
                enabled: variables.currentlist !== ""
                text: "Add list to saved Kanji"
                onClicked: remorsePopup.execute("Add list '" + variables.currentlist + "' to saved Kanj", function() { if(!lists.load_from_list(variables.currentlist)) { panel.text = "Can not add Kanji from list"; panel.show() }; functions.update()  } )
            }

            Button {
                width: parent.width
                enabled: variables.currentlist !== ""
                text: "View list"
                onClicked: {
                    if(list_details.show_details(variables.currentlist)) {
                        pageStack.push(Qt.resolvedUrl("ListDetails.qml"))
                    }
                    else {
                        panel.text = "Can not open list"
                        panel.show()
                    }
                }
            }

            Button {
                width: parent.width
                enabled: variables.currentlist !== ""
                text: "Delete list"
                onClicked: remorsePopup.execute("Delete list '" + variables.currentlist +"'", function() { if(!lists.delete_list(variables.currentlist)) { panel.text = "Can not delete list"; panel.show() }; functions.update()  } )
            }

            Button {
                width: parent.width
                enabled: newlist.text !== ""
                text: "Add saved Kanj to list"
                onClicked: {
                    if(!lists.save_to_list(newlist.text)) {
                        panel.text = "Can not save Kanji to list"
                        panel.show()
                    }
                    else {
                        newlist.text = ""
                    }
                    functions.update()
                }
            }

            TextField {
                id: newlist
                width: parent.width
                EnterKey.onClicked: parent.focus = true
                placeholderText: "Name of list for saved Kanji"
                label: "Name of list for saved Kanji"
                text: ""
            }

            PageHeader {
                title: "Current lists: " + variables.count
            }
        }

        delegate: BackgroundItem {
            Label {
                id: backgroundlabel
                width: parent.width - 2*Theme.paddingLarge
                text: element_list
                anchors.centerIn: parent
                color: variables.currentlist === text ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Elide

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }
            onPressed: variables.currentlist = backgroundlabel.text
        }

        VerticalScrollDecorator {}
    }

    UpperPanel {
        id: panel
        text: ""
    }

    RemorsePopup {
        id: remorsePopup
    }
}
