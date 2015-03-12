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

    ListModel {
        id: listModel

        Component.onCompleted: {
            if(!radical.get_all()) {
                panel.show()
                return
            }

            while(radical.next()) {
                listModel.append({"element_radical": radical.get_radical(), "element_number": radical.get_number() })
            }
        }
    }

    SilicaGridView {
        id: grid
        model: listModel
        anchors.fill: parent
        currentIndex: -1

        cellWidth: grid.width/4
        cellHeight: cellWidth

        header: PageHeader {
            title: "Radicals"
        }

        delegate: BackgroundItem {
            width: grid.cellWidth
            height: grid.cellHeight
            Row {
                anchors.centerIn: parent
                Label {
                    text: element_radical
                    color: Theme.primaryColor
                }
                Label {
                    text: " " + element_number
                    color: Theme.secondaryColor
                }
            }
            onClicked: {
                radical.save_radical(element_number)
                radical.get_saved_radical()
                pageStack.pop()
            }
        }

        VerticalScrollDecorator {}

    }

    UpperPanel {
        id: panel
        text: "Can not read radicals"
    }
}
