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

    onVisibleChanged: {
        if(variables.started_radical_selection) {
            if(radical.get_saved_radical() !== -1) {
                variables.started_radical_selection = false
                radicalinput.text = radical.get_saved_radical()
                console.log(radical.get_saved_radical())
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Item {
            id: variables
            property bool started_radical_selection: false
        }

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: "Search"
            }

            TextSwitch {
                id: switchliteral
                width: parent.width
                text: "Search by literal"
                onCheckedChanged: literalinput.text = ""
            }

            TextField {
                id: literalinput
                width: parent.width
                visible: switchliteral.checked
                EnterKey.onClicked: parent.focus = true
                placeholderText: "Literal"
                label: "Literal"
            }

            TextSwitch {
                id: switchradical
                width: parent.width
                text: "Search by radical number"
                onCheckedChanged: radicalinput.text = ""
            }

            Row {

            TextField {
                id: radicalinput
                width: column.width - showradical.width
                visible: switchradical.checked
                placeholderText: "Radical number"
                label: "Radical number"
                EnterKey.onClicked: parent.focus = true
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onTextChanged: showradical.text = radical.radical_by_number(text)
                validator: IntValidator {bottom: 1}
            }

            Label {
                id: showradical
                text: ""
            }
            }

            Button {
                width: parent.width
                visible: switchradical.checked
                text: "Browse radicals"
                onClicked: {
                    radical.save_radical(-1)
                    pageStack.push(Qt.resolvedUrl("RadicalSelection.qml"))
                    variables.started_radical_selection = true
                }
            }

            TextSwitch {
                id: switchstrokecount
                width: parent.width
                text: "Search by stroke count"
                onCheckedChanged: strokecountinput.text = ""
            }

            TextField {
                id: strokecountinput
                width: parent.width
                visible: switchstrokecount.checked
                EnterKey.onClicked: parent.focus = true
                placeholderText: "Stroke count"
                label: "Stroke count"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: IntValidator {bottom: 1}
            }

            TextSwitch {
                id: switchskip
                width: parent.width
                text: "Search by SKIP code"
                onCheckedChanged: {skip1input.text = ""; skip2input.text = ""; skip3input.text = ""}
            }

            Row {
                width: parent.width
                visible: switchskip.checked

                TextField {
                    id: skip1input
                    width: parent.width/3
                    visible: switchskip.checked
                    EnterKey.onClicked: skip2input.focus = true
                    placeholderText: "SKIP 1"
                    label: "SKIP 1"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: IntValidator {bottom: 1}
                }

                Label {
                    text: "-"
                    visible: switchskip.checked
                }

                TextField {
                    id: skip2input
                    width: parent.width/3
                    visible: switchskip.checked
                    EnterKey.onClicked: skip3input.focus = true
                    placeholderText: "SKIP 2"
                    label: "SKIP 2"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: IntValidator {bottom: 1}
                }

                Label {
                    text: "-"
                    visible: switchskip.checked
                }

                TextField {
                    id: skip3input
                    width: parent.width/3
                    visible: switchskip.checked
                    EnterKey.onClicked: parent.focus = true
                    placeholderText: "SKIP 3"
                    label: "SKIP 3"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: IntValidator {bottom: 1}
                }
            }

            TextSwitch {
                id: switchjlpt
                width: parent.width
                text: "Search by JLPT level"
                onCheckedChanged: jlptinput.currentIndex = 0
            }

            ComboBox {
                id: jlptinput
                width: parent.width
                visible: switchjlpt.checked
                label: "JLPT"
                menu: ContextMenu {
                    MenuItem { text: "Not present in any level"}
                    MenuItem { text: "Level 1"}
                    MenuItem { text: "Level 2"}
                    MenuItem { text: "Level 3"}
                    MenuItem { text: "Level 4"}
                }
            }

            TextSwitch {
                id: switchmeaning
                width: parent.width
                text: "Search by meaning"
                onCheckedChanged: meaninginput.text = ""
            }

            TextField {
                id: meaninginput
                width: parent.width
                visible: switchmeaning.checked
                EnterKey.onClicked: parent.focus = true
                placeholderText: "Meaning"
                label: "Meaning"
            }

            TextSwitch {
                id: switchcomment
                width: parent.width
                text: "Search by comment"
                onCheckedChanged: commentinput.text = ""
            }

            TextField {
                id: commentinput
                width: parent.width
                visible: switchcomment.checked
                EnterKey.onClicked: parent.focus = true
                placeholderText: "Comment"
                label: "Comment"
            }

            TextSwitch {
                id: switchsaved
                width: parent.width
                text: "Search for saved Kanji"
                onCheckedChanged: savedinput.currentIndex = 0
            }

            ComboBox {
                id: savedinput
                width: parent.width
                visible: switchsaved.checked
                label: "Saved Kanji"
                menu: ContextMenu {
                    MenuItem { text: "Only saved Kanji"}
                    MenuItem { text: "No saved Kanji"}
                }
            }

            Button {
                text: "Start search"
                width: column.width
                onClicked: {
                    search.clear()

                    // Configure search

                    if(switchliteral.checked) {
                        search.search_literal(literalinput.text)
                    }

                    if(switchradical.checked) {
                        search.search_radical(radicalinput.text)
                    }

                    if(switchstrokecount.checked) {
                        search.search_strokecount(strokecountinput.text)
                    }

                    if(switchskip.checked) {
                        search.search_skip(skip1input.text, skip2input.text, skip3input.text)
                    }

                    if(switchjlpt.checked) {
                        search.search_jlpt(jlptinput.currentIndex)
                    }

                    if(switchmeaning.checked) {
                        search.search_meaning(meaninginput.text)
                    }

                    if(switchsaved.checked) {
                        search.search_saved(savedinput.currentIndex === 0)
                    }

                    if(switchcomment.checked) {
                        search.search_comment(commentinput.text)
                    }

                    // Start search

                    if(search.start_search()) {
                        pageStack.push(Qt.resolvedUrl("SearchResults.qml"))
                    }
                    else {
                        panel.show()
                    }
                }
            }
        }

        UpperPanel {
            id: panel
            text: "Can not perform search"
        }
    }
}
