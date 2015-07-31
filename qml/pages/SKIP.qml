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
    id: skip_page

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
                title: "SKIP system usage"
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
                width: skip_page.width
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap

                text: "SKIP (System of Kanji Indexing by Patterns) is an easy system to find Kanji based on their appearence. All Kanji have a classification of three numbers (n-nn-nn). These numbers can be determined as follows:

 - If the Kanji can be split vertically the classification is '1 - strokes left side - strokes right side'
 - If the Kanji can be split horizontally the classification is '2 - strokes upper side - strokes lower side'
 - If the Kanji can be split into an inner part and outer part the classification is '3 - strokes outer part - strokes inner part'
 - If none of this applies the classification is '4 - strokecount - line number as defined below'

The line number is defined as follows:

 - If the Kanji has a horizontal line at the top: 1
 - If the Kanji has a horizontal line at the bottom: 2
 - If the Kanji has a vertical line through it: 3
 - Otherwise: 4"
            }
        }
    }
}
