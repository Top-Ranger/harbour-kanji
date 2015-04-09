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
    }

    Item {
        function load_additional_data() {
            translationtext.text = translation.get_translation(variable.literal)
            commenttext.text = comment.get_comment(variable.literal)
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        PullDownMenu {

            MenuItem {
                visible: !variable.saved
                text: "Save Kanji"
                onClicked: {
                    if(kanji_save.save(variable.literal))
                    {
                        kanji_save.set_last_changed(variable.literal)
                        variable.saved = true
                        kanji_save.set_last_changed_value(variable.saved)
                    }
                }
            }

            MenuItem {
                visible: variable.saved
                text: "Remove Kanji from saved"
                onClicked: {
                    if(kanji_save.unsave(variable.literal))
                    {
                        kanji_save.set_last_changed(variable.literal)
                        variable.saved = false
                        kanji_save.set_last_changed_value(variable.saved)
                    }
                }
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

            PageHeader {
                title: "Kanji"
            }

            Label {
                id: kanji
                x: page.width/2 - width
                text: kanjiinfo.literal()
                font.pixelSize: Theme.fontSizeExtraLarge
            }

            Row  {
                visible: translationtext.text !== ""

                Label {
                    id: labeltranslation
                    text: "Translation: "
                    color: Theme.highlightColor
                }
                Text {
                    id: translationtext
                    width: column.width - labeltranslation.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: ""
                }
            }

            Row  {
                Label {
                    id: labelmeaning
                    text: "Meaning: "
                    color: Theme.highlightColor
                }
                Text {
                    width: column.width - labelmeaning.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: kanjiinfo.meaning()
                }
            }

            Row  {
                Label {
                    text: "Radical: "
                    color: Theme.highlightColor
                }
                Label {
                    text: radical.radical_by_number(kanjiinfo.radical()) + " (" + kanjiinfo.radical() + ")"
                }
            }

            Row  {
                Label {
                    text: "Stroke count: "
                    color: Theme.highlightColor
                }
                Label {
                    text: "" + kanjiinfo.strokecount()
                }
            }

            Row  {
                Label {
                    text: "JLPT level: "
                    color: Theme.highlightColor
                }
                Label {
                    text: kanjiinfo.JLPT() === 0 ? "Not present in any level" : "" + kanjiinfo.JLPT()
                }
            }            Row  {
                Label {
                    id: labelon
                    text: "ON: "
                    color: Theme.highlightColor
                }
                Text {
                    width: column.width - labelon.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: kanjiinfo.ONreading()
                }
            }

            Row  {
                Label {
                    id: labelkun
                    text: "KUN: "
                    color: Theme.highlightColor
                }
                Text {
                    width: column.width - labelkun.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: kanjiinfo.KUNreading()
                }
            }

            Row  {
                Label {
                    text: "Nanori: "
                    color: Theme.highlightColor
                }
                Text {
                    width: column.width - labelmeaning.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: kanjiinfo.nanori()
                }
            }

            Row  {
                Label {
                    id: labelskip
                    text: "SKIP code: "
                    color: Theme.highlightColor
                }
                Text {
                    width: column.width - labelskip.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: kanjiinfo.valid_skip() ? ("" + kanjiinfo.skip1() + "-" + kanjiinfo.skip2() + "-" + kanjiinfo.skip3()) : ""
                }
            }

            Row{
                Label {
                    id: labelsaved
                    text: "Saved: "
                    color: Theme.highlightColor
                }
                Image {
                    id: star
                    height: labelsaved.height
                    width: height
                    source: variable.saved ? "star.png" : "no_star.png"
                }
            }

            Row  {
                visible: commenttext.text !== ""

                Label {
                    id: labelcomment
                    text: "Comment: "
                    color: Theme.highlightColor
                }
                Text {
                    id: commenttext
                    width: column.width - labelcomment.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: ""
                }
            }
        }
    }
}
