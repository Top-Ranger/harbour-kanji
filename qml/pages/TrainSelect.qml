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
        id: functions
        function update() {
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
            anchors.margins: Theme.paddingLarge

            PageHeader {
                title: "Select training set"
            }

            BackgroundItem {
                width: page.width
                Label {
                    width: parent.width - 2*Theme.paddingLarge
                    text: "Saved Kanji"
                    anchors.centerIn: parent

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingLarge
                    }
                }

                onClicked: {
                    if(train.start_test()) {
                        pageStack.push(Qt.resolvedUrl("Train.qml"))
                    }
                    else {
                        panel.text = "Can not start test"
                        panel.show()
                    }
                }
            }
        }

        delegate: ListItem {
            Label {
                id: backgroundlabel
                width: parent.width - 2*Theme.paddingLarge
                text: element_list
                anchors.centerIn: parent
                truncationMode: TruncationMode.Elide

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }
            }

            onClicked: {
                if(train.start_test_list(element_list)) {
                    pageStack.push(Qt.resolvedUrl("Train.qml"))
                }
                else {
                    panel.text = "Can not start test"
                    panel.show()
                }
            }
        }

        VerticalScrollDecorator {}
    }

    UpperPanel {
        id: panel
        text: ""
    }
}
