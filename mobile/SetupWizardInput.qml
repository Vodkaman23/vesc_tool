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
import QtGraphicalEffects 1.0

import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0
import Vedder.vesc.utility 1.0

Item {
    property ConfigParams mAppConf: VescIf.appConfig()
    property Commands mCommands: VescIf.commands()
    property bool mSendCanAtStart: false
    property int mCanIdAtStart: 0

    function openDialog() {
        canIdModel.clear()
        stackLayout.currentIndex = 0
        updateButtonText()

        mSendCanAtStart = mCommands.getSendCan()
        mCanIdAtStart = mCommands.getCanSendId()

        if (mCommands.getSendCan()) {
            canIdModel.append({"name": "This VESC (CAN FWD)",
                                  "canId": mAppConf.getParamInt("controller_id"),
                                  "isCan": true})
            dialog.open()
            canScanBar.value = 100
        } else {
            canIdModel.append({"name": "This VESC",
                                  "canId": mAppConf.getParamInt("controller_id"),
                                  "isCan": false})
            dialog.open()
            disableDialog()
            var canDevs = Utility.scanCanVescOnly(VescIf)

            for (var i = 0;i < canDevs.length;i++) {
                canIdModel.append({"name": "VESC on CAN-bus",
                                      "canId": canDevs[i],
                                      "isCan": true})
            }

            enableDialog()
        }
    }

    function disableDialog() {
        nextButton.enabled = false
        prevButton.enabled = false
        stackLayout.enabled = false

        if (canScanBar.visible) {
            canScanBar.indeterminate = true
        } else {
            commDialog.open()
        }
    }

    function enableDialog() {
        canScanBar.indeterminate = false
        canScanBar.value = 100
        nextButton.enabled = true
        prevButton.enabled = true
        stackLayout.enabled = true
        commDialog.close()
    }

    Dialog {
        id: commDialog
        title: "通讯中..."
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

    Dialog {
        id: dialog
        modal: true
        focus: true
        width: parent.width - 10
        height: parent.height - 10
        closePolicy: Popup.NoAutoClose
        x: 5
        y: 5
        parent: ApplicationWindow.overlay
        bottomMargin: 0
        rightMargin: 0
        padding: 10

        StackLayout {
            id: stackLayout
            anchors.fill: parent

            Item {
                ColumnLayout {
                    anchors.fill: parent

                    Text {
                        Layout.fillWidth: true
                        color: "white"
                        text: qsTr("Which VESC is the input connected to?")
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    ListModel {
                        id: canIdModel
                    }

                    ListView {
                        id: canIdList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        focus: true
                        clip: true
                        spacing: 5

                        Component {
                            id: canIdDelegate

                            Rectangle {
                                property variant modelData: model

                                width: canIdList.width
                                height: 90
                                color: ListView.isCurrentItem ? "#41418f" : "#30000000"
                                radius: 5
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 10

                                    Image {
                                        id: image
                                        fillMode: Image.PreserveAspectFit
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 80
                                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                        Layout.leftMargin: 5
                                        source: isCan ? "qrc:/res/icons/can_off.png" : "qrc:/res/icons/Connected-96.png"
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: name + "\nID: " + canId
                                        color: "white"
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed: {
                                        canIdList.currentIndex = index
                                        canIdList.focus = true
                                    }
                                }
                            }
                        }

                        model: canIdModel
                        delegate: canIdDelegate
                    }

                    ProgressBar {
                        id: canScanBar
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: 0
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent

                    Text {
                        Layout.fillWidth: true
                        color: "white"
                        text: qsTr("Select Input Type")
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    ListModel {
                        id: inputModel

                        ListElement {
                            name: "PPM遥控，比如RC遥控"
                            img: "qrc:/res/images/rc_rx.jpg"
                            apptype: 4 // PPM_UART
                        }

                        ListElement {
                            name: "NRF 遥控器."
                            img: "qrc:/res/images/vedder_nunchuk.jpg"
                            apptype: 3 // UART, assume permanent NRF or NRF51 on UART
                        }

                        ListElement {
                            name: "ADC 输入, 比如电动车油门."
                            img: "qrc:/res/images/ebike_throttle.jpg"
                            apptype: 5 // ADC
                        }

                        ListElement {
                            name: '无线 nyko kama nunchuk.<br><font color="red"><b>Warning:</b></font> 会禁用UART'
                            img: "qrc:/res/images/nunchuk.jpg"
                            apptype: 6 // NUNCHUK
                        }
                    }

                    ListView {
                        id: inputList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        focus: true
                        clip: true
                        spacing: 5

                        Component {
                            id: inputDelegate

                            Rectangle {
                                id: imgRect
                                property variant modelData: model

                                width: inputList.width
                                height: 90
                                color: ListView.isCurrentItem ? "#41418f" : "#30000000"
                                radius: 5
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 10

                                    Item {
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 80
                                        Layout.leftMargin: 5
                                        opacity: imgRect.ListView.isCurrentItem ? 1.0 : 0.5

                                        Image {
                                            id: image
                                            fillMode: Image.PreserveAspectFit
                                            source: img
                                            sourceSize: Qt.size(parent.width, parent.height)
                                            smooth: true
                                            visible: false
                                        }

                                        Rectangle {
                                            id: mask
                                            width: 80
                                            height: 80
                                            radius: 40
                                            visible: false
                                        }

                                        OpacityMask {
                                            anchors.fill: image
                                            source: image
                                            maskSource: mask
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: '<font color="white">' + name
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed: {
                                        inputList.currentIndex = index
                                        inputList.focus = true
                                    }
                                }
                            }
                        }

                        model: inputModel
                        delegate: inputDelegate
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent

                    Text {
                        Layout.fillWidth: true
                        color: "white"
                        text: qsTr("油门从最小推到最大, 然后留在中位.")
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    ParamListScroll {
                        id: paramsMap
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    PpmMap {
                        id: ppmMap
                        Layout.fillWidth: true
                        visible: false
                    }

                    AdcMap {
                        id: adcMap
                        Layout.fillWidth: true
                        visible: false
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent

                    GroupBox {
                        id: nrfPairBox
                        Layout.fillWidth: true
                        title: "NRF Pairing"
                        visible: false
                        NrfPair {
                            id: nrfPair
                            anchors.fill: parent
                        }
                    }

                    ParamListScroll {
                        id: paramsConf
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Button {
                        Layout.fillWidth: true
                        text: "写入"

                        onClicked: {
                            mCommands.setAppConf()
                        }
                    }
                }
            }
        }

        header: Rectangle {
            color: "#dbdbdb"
            height: tabBar.height

            TabBar {
                id: tabBar
                currentIndex: stackLayout.currentIndex
                anchors.fill: parent
                implicitWidth: 0
                clip: true
                enabled: false

                background: Rectangle {
                    opacity: 1
                    color: "#4f4f4f"
                }

                property int buttons: 4
                property int buttonWidth: 120

                TabButton {
                    text: qsTr("Connection")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Type")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Mapping")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Setup")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
            }
        }

        footer: RowLayout {
            spacing: 0
            Button {
                id: prevButton
                Layout.fillWidth: true
                Layout.preferredWidth: 500
                text: "取消"
                flat: true

                onClicked: {
                    if (stackLayout.currentIndex == 0) {
                        closeWizard(false)
                    } else {
                        stackLayout.currentIndex--

                        if (stackLayout.currentIndex == 2 &&
                                !ppmMap.visible && !adcMap.visible) {
                            stackLayout.currentIndex--
                        }

                        if (stackLayout.currentIndex == 2) {
                            mAppConf.updateParamEnum("app_ppm_conf.ctrl_type", 0, 0)
                            mAppConf.updateParamEnum("app_adc_conf.ctrl_type", 0, 0)
                            mCommands.setAppConf()
                        }
                    }

                    updateButtonText()
                }
            }

            Button {
                id: nextButton
                Layout.fillWidth: true
                Layout.preferredWidth: 500
                text: "下一步"
                flat: true

                onClicked: {
                    if (stackLayout.currentIndex < (stackLayout.count - 1)) {
                        var apptype = inputList.currentItem.modelData.apptype
                        var ppmMap_wasVisible = ppmMap.visible

                        stackLayout.currentIndex++

                        if (stackLayout.currentIndex == 1) {
                            // Type page
                            mCommands.setSendCan(canIdList.currentItem.modelData.isCan,
                                                 canIdList.currentItem.modelData.canId)

                            disableDialog()
                            var res = Utility.resetInputCan(VescIf, VescIf.getCanDevsLast())
                            enableDialog()

                            if (!res) {
                                closeWizard(false)
                            }
                        } else if (stackLayout.currentIndex == 2) {
                            // Map page
                            adcMap.visible = false
                            ppmMap.visible = false
                            nrfPairBox.visible = false
                            paramsMap.clear()

                            mAppConf.updateParamEnum("app_ppm_conf.ctrl_type", 0, 0)
                            mAppConf.updateParamEnum("app_adc_conf.ctrl_type", 0, 0)
                            mAppConf.updateParamEnum("app_to_use", apptype, 0)
                            mAppConf.updateParamBool("app_ppm_conf.multi_esc", true, 0)
                            mAppConf.updateParamBool("app_adc_conf.multi_esc", true, 0)
                            mAppConf.updateParamBool("app_chuk_conf.multi_esc", true, 0)
                            mCommands.setAppConf()

                            if (apptype === 4) {
                                // PPM and UART
                                ppmMap.visible = true
                            } else if (apptype === 3) {
                                // UART only (for NRF nunchuk)
                                nrfPairBox.visible = true
                                nextButton.clicked()
                                nrfPairStartDialog.open()
                                return
                            } else if (apptype === 5) {
                                // ADC and UART
                                adcMap.visible = true
                                paramsMap.addEditorApp("app_adc_conf.voltage_inverted")
                                paramsMap.addEditorApp("app_adc_conf.voltage2_inverted")
                                paramsMap.addSpacer()
                            } else if (apptype === 6) {
                                // Nyko Kama
                                nextButton.clicked()
                                return
                            }

                            mapResetTimer.restart()
                        } else if (stackLayout.currentIndex == 3) {
                            // Config page
                            disableDialog()

                            if (ppmMap_wasVisible) {
                                if (ppmMap.isValid()) {
                                    ppmMap.applyMapping()
                                    Utility.waitSignal(mCommands, "2ackReceived(QString)", 2000)
                                }
                            }

                            // Setup page
                            paramsConf.clear()
                            mAppConf.updateParamEnum("app_ppm_conf.ctrl_type", 3, 0)
                            mAppConf.updateParamEnum("app_adc_conf.ctrl_type", 1, 0)
                            mCommands.setAppConf()
                            Utility.waitSignal(mCommands, "2ackReceived(QString)", 2000)

                            enableDialog()

                            if (apptype === 4) {
                                // PPM and UART
                                paramsConf.addSeparator("General")
                                paramsConf.addEditorApp("app_ppm_conf.ctrl_type")
                                paramsConf.addEditorApp("app_ppm_conf.median_filter")
                                paramsConf.addEditorApp("app_ppm_conf.safe_start")
                                paramsConf.addEditorApp("app_ppm_conf.ramp_time_pos")
                                paramsConf.addEditorApp("app_ppm_conf.ramp_time_neg")
                                paramsConf.addEditorApp("app_ppm_conf.pid_max_erpm")
                                paramsConf.addEditorApp("app_ppm_conf.max_erpm_for_dir")
                                paramsConf.addEditorApp("app_ppm_conf.smart_rev_max_duty")
                                paramsConf.addEditorApp("app_ppm_conf.smart_rev_ramp_time")
                                paramsConf.addSeparator("Multiple VESCs over CAN-bus")
                                paramsConf.addEditorApp("app_ppm_conf.tc")
                                paramsConf.addEditorApp("app_ppm_conf.tc_max_diff")
                            } else if (apptype === 3 || apptype === 6) {
                                // NRF nunchuk or nyko kama
                                paramsConf.addSeparator("General")
                                paramsConf.addEditorApp("app_chuk_conf.ctrl_type")
                                paramsConf.addEditorApp("app_chuk_conf.ramp_time_pos")
                                paramsConf.addEditorApp("app_chuk_conf.ramp_time_neg")
                                paramsConf.addEditorApp("app_chuk_conf.stick_erpm_per_s_in_cc")
                                paramsConf.addEditorApp("app_chuk_conf.hyst")
                                paramsConf.addEditorApp("app_chuk_conf.use_smart_rev")
                                paramsConf.addEditorApp("app_chuk_conf.smart_rev_max_duty")
                                paramsConf.addEditorApp("app_chuk_conf.smart_rev_ramp_time")
                                paramsConf.addSeparator("Multiple VESCs over CAN-bus")
                                paramsConf.addEditorApp("app_chuk_conf.tc")
                                paramsConf.addEditorApp("app_chuk_conf.tc_max_diff")
                            } else if (apptype === 5) {
                                // ADC and UART
                                paramsConf.addSeparator("General")
                                paramsConf.addEditorApp("app_adc_conf.ctrl_type")
                                paramsConf.addEditorApp("app_adc_conf.use_filter")
                                paramsConf.addEditorApp("app_adc_conf.safe_start")
                                paramsConf.addEditorApp("app_adc_conf.cc_button_inverted")
                                paramsConf.addEditorApp("app_adc_conf.rev_button_inverted")
                                paramsConf.addEditorApp("app_adc_conf.ramp_time_pos")
                                paramsConf.addEditorApp("app_adc_conf.ramp_time_neg")
                                paramsConf.addSeparator("Multiple VESCs over CAN-bus")
                                paramsConf.addEditorApp("app_adc_conf.tc")
                                paramsConf.addEditorApp("app_adc_conf.tc_max_diff")
                            }

                            paramsConf.addSpacer()
                        }
                    } else {
                        closeWizard(true)
                    }

                    updateButtonText()
                }
            }
        }
    }

    Timer {
        id: mapResetTimer
        interval: 1500
        running: false
        repeat: false

        onTriggered: {
            ppmMap.reset()
            adcMap.reset()
        }
    }

    Dialog {
        id: nrfPairStartDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "NRF 配对"

        parent: ApplicationWindow.overlay
        x: 10
        y: dialog.y + dialog.height / 2 - height / 2

        Text {
            id: detectLambdaLabel
            color: "white"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text:
                "您已经选择了NRF输入，这需要配对。" +
                "要开始配对过程，请单击“确定”，然后打开遥控器。" +
                "这将使VESC处于配对模式10秒。" +
                "如果需要，可以使用NRF配对框中的START按钮重新启动配对过程。"

        }

        onAccepted: {
            nrfPair.startPairing()
        }
    }

    function updateButtonText() {
        if (stackLayout.currentIndex == (stackLayout.count - 1)) {
            nextButton.text = "结束"
        } else {
            nextButton.text = "下一步"
        }

        if (stackLayout.currentIndex == 0) {
            prevButton.text = "取消"
        } else {
            prevButton.text = "上一步"
        }
    }

    function closeWizard(finished) {
        if (finished) {
            disableDialog()
            mCommands.setAppConf()
            Utility.waitSignal(mCommands, "2ackReceived(QString)", 2000)
            enableDialog()
        }

        mCommands.setSendCan(mSendCanAtStart, mCanIdAtStart)
        dialog.close()
    }
}
