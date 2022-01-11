/*
    Copyright 2017 - 2019 Benjamin Vedder	benjamin@vedder.se

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
import Vedder.vesc.bleuart 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.utility 1.0

Item {
    id: topItem

    property BleUart mBle: VescIf.bleDevice()
    property Commands mCommands: VescIf.commands()
    property alias disconnectButton: disconnectButton
    property bool isHorizontal: width > height
    signal requestOpenControls()

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        GridLayout {
            id: grid
            anchors.fill: parent
            columns: isHorizontal ? 2 : 1
            columnSpacing: 5
            rowSpacing: 10

            Image {
                id: image
                Layout.columnSpan: isHorizontal ? 2 : 1
                Layout.preferredWidth: Math.min(topItem.width, topItem.height)
                Layout.preferredHeight: (sourceSize.height * Layout.preferredWidth) / sourceSize.width
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                source: "qrc:/res/logo_white.png"
            }

            GroupBox {
                id: bleConnBox
                title: qsTr("BLE Connection")
                Layout.fillWidth: true
                Layout.columnSpan: 1

                GridLayout {
                    anchors.topMargin: -5
                    anchors.bottomMargin: -5
                    anchors.fill: parent

                    clip: false
                    visible: true
                    rowSpacing: -10
                    columnSpacing: 5
                    rows: 5
                    columns: 6

                    Button {
                        id: setNameButton
                        text: qsTr("Name")
                        Layout.columnSpan: 2
                        Layout.preferredWidth: 500
                        Layout.fillWidth: true
                        enabled: bleBox.count > 0

                        onClicked: {
                            if (bleItems.rowCount() > 0) {
                                bleNameDialog.open()
                            } else {
                                VescIf.emitMessageDialog("Set BLE Device Name",
                                                         "No device selected.",
                                                         false, false);
                            }
                        }
                    }

                    Button {
                        text: "Pair"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 500
                        Layout.columnSpan: 2

                        onClicked: {
                            pairDialog.openDialog()
                        }
                    }

                    Button {
                        id: scanButton
                        text: qsTr("Scan")
                        Layout.columnSpan: 2
                        Layout.preferredWidth: 500
                        Layout.fillWidth: true

                        onClicked: {
                            scanButton.enabled = false
                            mBle.startScan()
                        }
                    }

                    ComboBox {
                        id: bleBox
                        Layout.columnSpan: 6
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        transformOrigin: Item.Center

                        textRole: "key"
                        model: ListModel {
                            id: bleItems
                        }
                    }

                    Button {
                        id: disconnectButton
                        text: qsTr("Disconnect")
                        enabled: false
                        Layout.preferredWidth: 500
                        Layout.fillWidth: true
                        Layout.columnSpan: 3

                        onClicked: {
                            VescIf.disconnectPort()
                        }
                    }

                    Button {
                        id: connectButton
                        text: qsTr("Connect")
                        enabled: false
                        Layout.preferredWidth: 500
                        Layout.fillWidth: true
                        Layout.columnSpan: 3

                        onClicked: {
                            if (bleItems.rowCount() > 0) {
                                connectButton.enabled = false
                                VescIf.connectBle(bleItems.get(bleBox.currentIndex).value)
                            }
                        }
                    }
                }
            }

            GroupBox {
                title: qsTr("Configuration Wizards")
                Layout.fillWidth: true
                Layout.preferredHeight: isHorizontal ? bleConnBox.height : -1

                ColumnLayout {
                    anchors.topMargin: -5
                    anchors.bottomMargin: -5
                    anchors.fill: parent
                    spacing: isHorizontal ? -5 : -10

                    Button {
                        text: "电机检测(FOC)"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 500

                        onClicked: {
                            if (!VescIf.isPortConnected()) {
                                VescIf.emitMessageDialog("FOC设置向导",
                                                         "VESC未连接，请连接再试", false, false)
                            } else {
                                wizardFoc.openDialog()
                            }
                        }
                    }

                    Button {
                        text: "遥控设置"
                        Layout.fillWidth: true

                        onClicked: {
                            if (!VescIf.isPortConnected()) {
                                VescIf.emitMessageDialog("遥控设置",
                                                         "VESC未连接，请连接再试", false, false)
                            } else {
                                // Something in the opendialog function causes a weird glitch, probably
                                // caused by the eventloop in the can scan function. Disabling the button
                                // seems to help. TODO: figure out what the actual problem is.
                                enabled = false
                                wizardInput.openDialog()
                                enabled = true
                            }
                        }
                    }

                    Button {
                        id: nrfPairButton
                        text: "NRF快速配对"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 500

                        onClicked: {
                            if (!VescIf.isPortConnected()) {
                                VescIf.emitMessageDialog("NRF快速配对",
                                                         "VESC未连接，请连接再试", false, false)
                            } else {
                                nrfPairStartDialog.open()
                            }
                        }
                    }

                    NrfPair {
                        id: nrfPair
                        Layout.fillWidth: true
                        Layout.preferredWidth: 500
                        visible: false
                        hideAfterPair: true
                    }

                    Item {
                        visible: isHorizontal
                        Layout.fillHeight: true
                    }
                }
            }

            GroupBox {
                id: canFwdBox
                Layout.preferredHeight: isHorizontal ? toolsBox.height : -1
                title: qsTr("CAN Forwarding")
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.topMargin: -5
                    anchors.bottomMargin: -5
                    anchors.fill: parent
                    spacing: -10

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: isHorizontal ? 5 : 0

                        ComboBox {
                            id: canIdBox
                            Layout.fillWidth: true

                            textRole: "key"
                            model: ListModel {
                                id: canItems
                            }

                            onCurrentIndexChanged: {
                                if (fwdCanBox.checked && canItems.rowCount() > 0) {
                                    mCommands.setCanSendId(canItems.get(canIdBox.currentIndex).value)
                                }
                            }
                        }

                        CheckBox {
                            id: fwdCanBox
                            text: qsTr("Activate")
                            enabled: canIdBox.currentIndex >= 0 && canIdBox.count > 0

                            onClicked: {
                                mCommands.setSendCan(fwdCanBox.checked, canItems.get(canIdBox.currentIndex).value)
                                canScanButton.enabled = !checked
                                canAllButton.enabled = !checked
                            }
                        }
                    }

                    ProgressBar {
                        id: canScanBar
                        visible: false
                        Layout.fillWidth: true
                        indeterminate: true
                        Layout.preferredHeight: canAllButton.height
                    }

                    RowLayout {
                        id: canButtonLayout
                        Layout.fillWidth: true

                        Button {
                            id: canAllButton
                            text: "显示所有（不检测）"
                            Layout.fillWidth: true
                            Layout.preferredWidth: 500

                            onClicked: {
                                canItems.clear()
                                for (var i = 0;i < 255;i++) {
                                    var name = "VESC " + i
                                    canItems.append({ key: name, value: i })
                                }
                                canIdBox.currentIndex = 0
                            }
                        }

                        Button {
                            id: canScanButton
                            text: "检测CAN总线"
                            Layout.fillWidth: true
                            Layout.preferredWidth: 500

                            onClicked: {
                                canScanBar.indeterminate = true
                                canButtonLayout.visible = false
                                canScanBar.visible = true
                                canItems.clear()
                                enabled = false
                                canAllButton.enabled = false
                                mCommands.pingCan()
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        visible: isHorizontal
                    }
                }
            }

            GroupBox {
                id: toolsBox
                title: qsTr("Tools")
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.topMargin: -5
                    anchors.bottomMargin: -5
                    anchors.fill: parent
                    spacing: isHorizontal ? -5 : -10

                    Button {
                        text: "控制"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 500

                        onClicked: {
                            requestOpenControls()
                        }
                    }

                    Button {
                        text: "方向"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 500

                        onClicked: {
                            if (!VescIf.isPortConnected()) {
                                VescIf.emitMessageDialog("方向",
                                                         "VESC未连接，请连接再试", false, false)
                            } else {
                                enabled = false
                                directionSetupDialog.open()
                                directionSetup.scanCan()
                                enabled = true
                            }
                        }
                    }

                    Button {
                        text: "备份设置"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 500

                        onClicked: {
                            backupConfigDialog.open()
                        }
                    }

                    Button {
                        text: "载入设置"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 500

                        onClicked: {
                            restoreConfigDialog.open()
                        }
                    }
                }
            }
        }
    }

    SetupWizardFoc {
        id: wizardFoc
    }

    SetupWizardInput {
        id: wizardInput
    }

    PairingDialog {
        id: pairDialog
    }

    Timer {
        interval: 500
        running: !scanButton.enabled
        repeat: true

        property int dots: 0
        onTriggered: {
            var text = "S"
            for (var i = 0;i < dots;i++) {
                text = "-" + text + "-"
            }

            dots++;
            if (dots > 3) {
                dots = 0;
            }

            scanButton.text = text
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true

        onTriggered: {
            connectButton.enabled = (bleItems.rowCount() > 0) && !VescIf.isPortConnected() && !mBle.isConnecting()
            disconnectButton.enabled = VescIf.isPortConnected()
        }
    }

    Connections {
        target: mBle
        onScanDone: {
            if (done) {
                scanButton.enabled = true
                scanButton.text = qsTr("Scan")
            }

            bleItems.clear()

            for (var addr in devs) {
                var name = devs[addr]
                var name2 = name + " [" + addr + "]"
                var setName = VescIf.getBleName(addr)
                if (setName.length > 0) {
                    setName += " [" + addr + "]"
                    bleItems.insert(0, { key: setName, value: addr })
                } else if (name.indexOf("VESC") !== -1) {
                    bleItems.insert(0, { key: name2, value: addr })
                } else {
                    bleItems.append({ key: name2, value: addr })
                }
            }

            connectButton.enabled = (bleItems.rowCount() > 0) && !VescIf.isPortConnected()

            bleBox.currentIndex = 0
        }

        onBleError: {
            VescIf.emitMessageDialog("BLE错误", info, false, false)
        }
    }

    Timer {
        repeat: true
        interval: 1000
        running: true

        onTriggered: {
            if (!VescIf.isPortConnected()) {
                canItems.clear()
                mCommands.setSendCan(false, -1)
                fwdCanBox.checked = false
                canScanButton.enabled = true
                canAllButton.enabled = true
            }
        }
    }

    Connections {
        target: mCommands

        onPingCanRx: {
            if (canItems.count == 0) {
                for (var i = 0;i < devs.length;i++) {
                    var params = Utility.getFwVersionBlockingCan(VescIf, devs[i])
                    var name = params.hwTypeStr() + " " + devs[i]
                    canItems.append({ key: name, value: devs[i] })
                }
                canScanButton.enabled = true
                canAllButton.enabled = true
                canIdBox.currentIndex = 0
                canButtonLayout.visible = true
                canScanBar.visible = false
                canScanBar.indeterminate = false
            }
        }

        onNrfPairingRes: {
            if (res != 0) {
                nrfPairButton.visible = true
            }
        }
    }

    Dialog {
        id: bleNameDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        title: "设置BLE设备名称"

        width: parent.width - 20
        height: 200
        closePolicy: Popup.CloseOnEscape
        x: 10
        y: Math.max(parent.height / 4 - height / 2, 20)
        parent: ApplicationWindow.overlay

        Rectangle {
            anchors.fill: parent
            height: stringInput.implicitHeight + 14
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
                var addr = bleItems.get(bleBox.currentIndex).value
                var setName = stringInput.text + " [" + addr + "]"

                VescIf.storeBleName(addr, stringInput.text)
                VescIf.storeSettings()

                bleItems.set(bleBox.currentIndex, { key: setName, value: addr })
                bleBox.currentText
            }
        }
    }

    Dialog {
        id: directionSetupDialog
        title: "方向设置"
        standardButtons: Dialog.Close
        modal: true
        focus: true
        padding: 10

        width: parent.width - 10
        closePolicy: Popup.CloseOnEscape
        x: 5
        y: parent.height / 2 - height / 2
        parent: ApplicationWindow.overlay

        DirectionSetup {
            id: directionSetup
            anchors.fill: parent
        }
    }

    Dialog {
        id: nrfPairStartDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "NRF配对"

        parent: ApplicationWindow.overlay
        x: 10
        y: topItem.y + topItem.height / 2 - height / 2

        Text {
            id: detectLambdaLabel
            color: "white"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text:
                "单击“确定”后，VESC将进入配对模式10秒。在此期间打开遥控器，完成配对过程。"
        }

        onAccepted: {
            nrfPair.visible = true
            nrfPairButton.visible = false
            nrfPair.startPairing()
        }
    }

    Dialog {
        id: backupConfigDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "备份设置"

        parent: ApplicationWindow.overlay
        x: 10
        y: topItem.y + topItem.height / 2 - height / 2

        Text {
            color: "white"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text:
                "这将备份已连接VESC的配置，以及通过can总线备份VESC的配置。 " +
                "配置信息存储在VESC UUID中。如果VESC UUID的备份已经存在，则会被覆盖。继续吗?"
        }

        onAccepted: {
            progDialog.open()
            VescIf.confStoreBackup(true, "")
            progDialog.close()
        }
    }

    Dialog {
        id: restoreConfigDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "读取设置"

        parent: ApplicationWindow.overlay
        x: 10
        y: topItem.y + topItem.height / 2 - height / 2

        Text {
            color: "white"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text:
                "这将恢复连接的VESC的配置，以及通过CAN总线连接的VESC， " +
                "如果在VESC工具的实例中存在UUID的备份。如果vesc的UUID没有备份，则不做任何修改。继续吗?"
        }

        onAccepted: {
            progDialog.open()
            VescIf.confRestoreBackup(true)
            progDialog.close()
        }
    }

    Dialog {
        id: progDialog
        title: "处理中..."
        closePolicy: Popup.NoAutoClose
        modal: true
        focus: true

        width: parent.width - 20
        x: 10
        y: parent.height / 2 - height / 2
        parent: ApplicationWindow.overlay

        ProgressBar {
            anchors.fill: parent
            indeterminate: visible
        }
    }
}
