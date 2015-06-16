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


Dialog {
    id: page

    onAccepted: {
        comment.set_comment(comment.get_edit_comment(), comment_text.text)
    }

    canAccept: !search.search_started()

    Connections {
        target: search
        onSearch_started_changed: {
            page.canAccept = !search.search_started()
            db_busy.visible = search.search_started()
            db_busy_label.visible = search.search_started()
            pulldown.visible = !search.search_started()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        PullDownMenu {
            id: pulldown
            visible: !search.search_started()
            MenuItem {
                text: "Delete comment"
                onClicked: remorsePopup.execute("Delete comment", function() { comment.set_comment(comment.get_edit_comment(), ""); pageStack.pop()} )
            }
        }

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            DialogHeader {
                width: page.width
                title: "Edit comment for " + comment.get_edit_comment()
                acceptText: "Save"
                cancelText: "Discard"
            }

            TextArea {
                id: comment_text
                width: parent.width
                height: implicitHeight
                focus: true
                text: comment.get_comment(comment.get_edit_comment())
                placeholderText: "Input comment here"
                label: "Comment"
            }

            BusyIndicator {
                id: db_busy
                x: column.width / 2 - (width/2)
                running: true
                size: BusyIndicatorSize.Medium
                visible: search.search_started()
            }

            Label {
                id: db_busy_label
                x: column.width / 2 - (width/2)
                text: "Database is busy - please wait"
                visible: search.search_started()
            }
        }
    }

    RemorsePopup {
        id: remorsePopup
    }
}
