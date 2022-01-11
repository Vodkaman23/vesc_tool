/*
    Copyright 2018 - 2019 Benjamin Vedder	benjamin@vedder.se

    This file is part of VESC Tool.

    VESC Tool is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    VESC Tool is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    */

import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0

Item {
    property alias name: nameText.text
    property ConfigParams mMcConf: VescIf.mcConfig()
    property Commands mCommands: VescIf.commands()
    property int index: 0
    signal editRequested(int index)
    signal deleteRequested(int index)

    implicitHeight: column.implicitHeight + 2 * column.anchors.margins
    Layout.fillWidth: true

    function setFromMcConfTemp(cfg) {
        name = cfg.name

        var useImperial = VescIf.useImperialUnits()
        var impFact = useImperial ? 0.621371192 : 1.0
        var speedUnit = useImperial ? "mph\n" : "km/h\n"

        infoText.text =
                "前进速度   : " + parseFloat(cfg.erpm_or_speed_max * 3.6 * impFact).toFixed(1) + speedUnit +
                "后退速度   : " + parseFloat(-cfg.erpm_or_speed_min * 3.6 * impFact).toFixed(1) + speedUnit +
                "前进电流   : " + parseFloat(cfg.current_max_scale * 100).toFixed(0) + " %\n" +
                "刹车电流   : " + parseFloat(cfg.current_min_scale * 100).toFixed(0) + " %"

        if (cfg.watt_max < 1400000 || cfg.watt_min > -1400000) {
            infoText.text += "\n" +
                    "最高输出功率   : " + parseFloat(cfg.watt_max).toFixed(1) + " W\n" +
                    "最高回充功率 : " + parseFloat(cfg.watt_min).toFixed(1) + " W"
        }
    }

    function checkActive() {
        if (VescIf.isProfileInUse(index)) {
            rect.border.color = "#81D4FA"
            rect.border.width = 3
        } else {
            rect.border.color = "#919191"
            rect.border.width = 2
        }
    }

    Rectangle {
        id: rect
        anchors.fill: parent
        color: "#4c606060"
        radius: 5
        border.color: "#919191"
        border.width: 2

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 5

            Text {
                id: nameText
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                font.pointSize: 12
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "lightgray"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                id: infoText
                color: "white"
                font.family: "DejaVu Sans Mono"
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "lightgray"
            }

            GridLayout {
                Layout.topMargin: -5
                Layout.bottomMargin: -5
                Layout.fillWidth: true
                columns: 3
                rowSpacing: -8
                columnSpacing: 5

                Button {
                    id: upButton
                    flat: true
                    text: "上"
                    onClicked: {
                        VescIf.moveProfileUp(index)
                        VescIf.storeSettings()
                    }
                }

                Button {
                    id: tempButton
                    Layout.fillWidth: true
                    Layout.preferredWidth: 500
                    flat: true
                    text: "使用直至重启"
                    onClicked: {
                        mCommands.setMcconfTemp(VescIf.getProfile(index),
                                                true, false, true, false, true)
                        VescIf.updateMcconfFromProfile(VescIf.getProfile(index))
                    }
                }

                Button {
                    id: editButton
                    flat: true
                    text: "编辑"
                    onClicked: {
                        editRequested(index)
                    }
                }

                Button {
                    id: downButton
                    flat: true
                    text: "下"
                    onClicked: {
                        VescIf.moveProfileDown(index)
                        VescIf.storeSettings()
                    }
                }

                Button {
                    id: permanentButton
                    Layout.fillWidth: true
                    Layout.preferredWidth: 500
                    flat: true
                    text: "永久使用"
                    onClicked: {
                        permanentDialog.open()
                    }

                    Dialog {
                        id: permanentDialog
                        property int indexNow: 0
                        standardButtons: Dialog.Yes | Dialog.Cancel
                        modal: true
                        focus: true
                        width: parent.width - 20
                        closePolicy: Popup.CloseOnEscape
                        title: "Use Profile Permanently"
                        x: 10
                        y: 10 + parent.height / 2 - height / 2
                        parent: ApplicationWindow.overlay

                        Text {
                            color: "#ffffff"
                            verticalAlignment: Text.AlignVCenter
                            anchors.fill: parent
                            wrapMode: Text.WordWrap
                            text: "这将永久使用档位，重启后也不会复位"
                        }

                        onAccepted: {
                            mCommands.setMcconfTemp(VescIf.getProfile(index),
                                                    true, true, true, false, true)
                            VescIf.updateMcconfFromProfile(VescIf.getProfile(index))
                        }
                    }
                }

                Button {
                    id: deleteButton
                    flat: true
                    text: "删除"
                    onClicked: {
                        deleteRequested(index)
                    }
                }
            }
        }
    }

    Connections {
        target: mMcConf

        onParamChangedDouble: {
            checkActive()
        }
    }

    Connections {
        target: VescIf

        onUseImperialUnitsChanged: {
            setFromMcConfTemp(VescIf.getProfile(index))
        }
    }
}
