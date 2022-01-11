/*
    Copyright 2019 Benjamin Vedder	benjamin@vedder.se

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

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0
import Vedder.vesc.utility 1.0

Item {
    function openDialog() {
        dialog.open()
        loadUuids()
    }

    function loadUuids() {
        pairModel.clear()
        var uuids = VescIf.getPairedUuids()
        for (var i = 0;i < uuids.length;i++) {
            pairModel.append({"uuid": uuids[i]})
        }
    }

    Dialog {
        property ConfigParams mAppConf: VescIf.appConfig()
        property Commands mCommands: VescIf.commands()

        id: dialog
        modal: true
        focus: true
        width: parent.width - 20
        height: parent.height - 60
        closePolicy: Popup.CloseOnEscape
        x: 10
        y: 50
        parent: ApplicationWindow.overlay
        padding: 10

        ColumnLayout {
            anchors.fill: parent

            Text {
                id: text
                Layout.fillWidth: true
                color: "white"
                text: qsTr("These are the VESCs paired to this instance of VESC Tool.")
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            ListModel {
                id: pairModel
            }

            ListView {
                id: pairList
                Layout.fillWidth: true
                Layout.fillHeight: true
                focus: true
                clip: true
                spacing: 5

                Component {
                    id: pairDelegate

                    Rectangle {
                        property variant modelData: model

                        width: pairList.width
                        height: 60
                        color: "#30000000"
                        radius: 5

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10

                            Image {
                                id: image
                                fillMode: Image.PreserveAspectFit
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                Layout.alignment: Qt.AlignVCenter
                                Layout.leftMargin: 10
                                source: "qrc:/res/icon.png"
                            }

                            Text {
                                Layout.fillWidth: true
                                color: "white"
                                text: uuid
                                wrapMode: Text.Wrap
                            }

                            Button {
                                Layout.alignment: Qt.AlignVCenter
                                Layout.rightMargin: 10
                                text: "删除"

                                onClicked: {
                                    deleteDialog.open()
                                }

                                Dialog {
                                    id: deleteDialog
                                    property int indexNow: 0
                                    standardButtons: Dialog.Ok | Dialog.Cancel
                                    modal: true
                                    focus: true
                                    width: parent.width - 20
                                    closePolicy: Popup.CloseOnEscape
                                    title: "Delete paired VESC"
                                    x: 10
                                    y: 10 + parent.height / 2 - height / 2
                                    parent: ApplicationWindow.overlay

                                    Text {
                                        color: "#ffffff"
                                        verticalAlignment: Text.AlignVCenter
                                        anchors.fill: parent
                                        wrapMode: Text.WordWrap
                                        text: "这将从配对列表中删除这个VESC。"+
                                              "如果VESC设置了配对，您将无法通过BLE连接到它。你确定吗?"
                                    }

                                    onAccepted: {
                                        VescIf.deletePairedUuid(uuid)
                                        VescIf.storeSettings()
                                    }
                                }
                            }
                        }
                    }
                }

                model: pairModel
                delegate: pairDelegate
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    Layout.preferredWidth: 50
                    Layout.fillWidth: true
                    text: "..."
                    onClicked: menu.open()

                    Menu {
                        id: menu
                        width: 500

                        MenuItem {
                            text: "不配对添加"
                            onTriggered: {
                                if (VescIf.isPortConnected()) {
                                    VescIf.addPairedUuid(VescIf.getConnectedUuid());
                                    VescIf.storeSettings()
                                } else {
                                    VescIf.emitMessageDialog("添加 UUID",
                                                             "未连接VESC。连接以添加它。",
                                                             false, false)
                                }
                            }
                        }

                        MenuItem {
                            text: "从UUID添加"
                            onTriggered: {
                                uuidEnter.open()
                            }
                        }

                        MenuItem {
                            text: "取消配对"
                            onTriggered: {
                                if (VescIf.isPortConnected()) {
                                    if (mCommands.isLimitedMode()) {
                                        VescIf.emitMessageDialog("取消VESC配对",
                                                                 "需要更新固件取消配对",
                                                                 false, false)
                                    } else {
                                        unpairConnectedDialog.open()
                                    }
                                } else {
                                    VescIf.emitMessageDialog("取消VEAC配对",
                                                             "未连接VESC。连接以添加它。",
                                                             false, false)
                                }
                            }
                        }
                    }
                }

                Button {
                    id: pairConnectedButton
                    text: "配对VESC"
                    Layout.fillWidth: true
                    onClicked: {
                        if (VescIf.isPortConnected()) {
                            if (mCommands.isLimitedMode()) {
                                VescIf.emitMessageDialog("配对VESC",
                                                         "需要更新固件配对",
                                                         false, false)
                            } else {
                                pairConnectedDialog.open()
                            }
                        } else {
                            VescIf.emitMessageDialog("配对VESC",
                                                     "未连接VESC。连接以添加它。",
                                                     false, false)
                        }
                    }
                }

                Button {
                    text: "关闭"
                    Layout.fillWidth: true
                    onClicked: {
                        dialog.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: pairConnectedDialog
        property int indexNow: 0
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "配对已连接的VESC"
        x: 10
        y: 10 + Math.max((parent.height - height) / 2, 10)
        parent: ApplicationWindow.overlay

        Text {
            color: "#ffffff"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text: "这将使已连接的VESC与VESC工具配对。"+
                  "未与VESC配对的VESC工具将不再能够通过蓝牙连接。继续吗?"
        }

        onAccepted: {
            VescIf.addPairedUuid(VescIf.getConnectedUuid());
            VescIf.storeSettings()
            mAppConf.updateParamBool("pairing_done", true, 0)
            mCommands.setAppConf()
            if (Utility.waitSignal(mCommands, "2ackReceived(QString)", 2000)) {
                VescIf.emitMessageDialog("配对成功!",
                                         "请写下UUID(或采取截图)，以便将其添加到未来不配对的VESC工具。UUID是:\n" +
                                         VescIf.getConnectedUuid(),
                                         true, false)
            }
        }
    }

    Dialog {
        id: unpairConnectedDialog
        property int indexNow: 0
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "取消配对"
        x: 10
        y: 10 + parent.height / 2 - height / 2
        parent: ApplicationWindow.overlay

        Text {
            color: "#ffffff"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text: "这将取消该VESC配对，确定吗？"
        }

        onAccepted: {
            VescIf.deletePairedUuid(VescIf.getConnectedUuid());
            VescIf.storeSettings()
            mAppConf.updateParamBool("pairing_done", false, 0)
            mCommands.setAppConf()
        }
    }

    Dialog {
        id: uuidEnter
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        title: "添加UUID"

        width: parent.width - 20
        height: 200
        closePolicy: Popup.CloseOnEscape
        x: 10
        y: parent.height / 2 - height / 2
        parent: ApplicationWindow.overlay

        Rectangle {
            anchors.fill: parent
            height: 20
            border.width: 2
            border.color: "#8d8d8d"
            color: "#33a8a8a8"
            radius: 3
            TextInput {
                id: stringInput
                color: "#ffffff"
                anchors.fill: parent
                anchors.margins: 7
                font.pointSize: 12
                focus: true
            }
        }

        onAccepted: {
            if (stringInput.text.length > 0) {
                VescIf.addPairedUuid(stringInput.text)
            }
        }
    }

    Connections {
        target: VescIf

        onPairingListUpdated: {
            loadUuids()
        }
    }
}
