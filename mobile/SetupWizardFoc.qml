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

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0
import Vedder.vesc.utility 1.0

Item {
    property ConfigParams mMcConf: VescIf.mcConfig()
    property Commands mCommands: VescIf.commands()

    function openDialog() {
        // Set few battery cells by default to avoid confusion
        // if the motor does not spin due to battery cut.
        mMcConf.updateParamInt("si_battery_cells", 3)
        dialog.open()
        loadDefaultDialog.open()
    }

    Component.onCompleted: {
        paramListBatt.addEditorMc("si_battery_type")
        paramListBatt.addEditorMc("si_battery_cells")
        paramListBatt.addEditorMc("si_battery_ah")

        paramListSetup.addEditorMc("si_wheel_diameter")
        paramListSetup.addSeparator("↓ Only change if needed ↓")
        paramListSetup.addEditorMc("si_motor_poles")
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
                    id: motorColumn
                    anchors.fill: parent

                    ListModel {
                        id: motorModel

                        ListElement {
                            name: "迷你外转子 (~75 g)"
                            motorImg: "qrc:/res/images/motors/outrunner_mini.jpg"
                            maxLosses: 10
                            openloopErpm: 1400
                            sensorlessErpm: 4000
                            poles: 14
                        }
                        ListElement {
                            name: "小型外转子 (~200 g)"
                            motorImg: "qrc:/res/images/motors/outrunner_small.jpg"
                            maxLosses: 25
                            openloopErpm: 1400
                            sensorlessErpm: 4000
                            poles: 14
                        }
                        ListElement {
                            name: "中型外转子 电滑选这个(~750 g)"
                            motorImg: "qrc:/res/images/motors/6374.jpg"
                            maxLosses: 60
                            openloopErpm: 700
                            sensorlessErpm: 4000
                            poles: 14
                        }
                        ListElement {
                            name: "大型外转子 (~2000 g)"
                            motorImg: "qrc:/res/icons/motor.png"
                            maxLosses: 200
                            openloopErpm: 700
                            sensorlessErpm: 4000
                            poles: 14
                        }
                        ListElement {
                            name: "小型内转子 (~200 g)"
                            motorImg: "qrc:/res/images/motors/inrunner_small.jpg"
                            maxLosses: 25
                            openloopErpm: 1400
                            sensorlessErpm: 4000
                            poles: 2
                        }
                        ListElement {
                            name: "中型内转子 (~750 g)"
                            motorImg: "qrc:/res/images/motors/inrunner_medium.jpg"
                            maxLosses: 70
                            openloopErpm: 1400
                            sensorlessErpm: 4000
                            poles: 4
                        }
                        ListElement {
                            name: "大型内转子 (~2000 g)"
                            motorImg: "qrc:/res/icons/motor.png"
                            maxLosses: 200
                            openloopErpm: 1000
                            sensorlessErpm: 4000
                            poles: 4
                        }
                        ListElement {
                            name: "电动车轮毂电机 (~6 kg)"
                            motorImg: "qrc:/res/images/motors/ebike_dd_1kw.jpg"
                            maxLosses: 75
                            openloopErpm: 300
                            sensorlessErpm: 2000
                            poles: 46
                        }
                        ListElement {
                            name: "小型 EDF 内转子 (~200 g)"
                            motorImg: "qrc:/res/images/motors/edf_small.jpg"
                            maxLosses: 55
                            openloopErpm: 1400
                            sensorlessErpm: 4000
                            poles: 6
                        }
                    }

                    ListView {
                        id: motorList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        focus: true
                        clip: true
                        spacing: 5

                        Component {
                            id: motorDelegate

                            Rectangle {
                                id: imgRect
                                property variant modelData: model

                                width: motorList.width
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
                                            source: motorImg
                                            width: 80
                                            height: 80
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
                                        text: name
                                        color: "white"
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPressed: {
                                        motorList.currentIndex = index
                                        motorList.focus = true
                                    }
                                }
                            }
                        }

                        model: motorModel
                        delegate: motorDelegate

                        onCurrentIndexChanged: {
                            maxPowerLossBox.realValue = motorList.currentItem.modelData.maxLosses
                            openloopErpmBox.realValue = motorList.currentItem.modelData.openloopErpm
                            sensorlessBox.realValue = motorList.currentItem.modelData.sensorlessErpm
                            motorPolesBox.realValue = motorList.currentItem.modelData.poles
                        }
                    }

                    GroupBox {
                        Layout.fillWidth: true

                        label: CheckBox {
                            id: overrideBox
                            checked: false
                            text: qsTr("Override (Advanced)")

                            onToggled: {
                                if (!checked) {
                                    maxPowerLossBox.realValue = motorList.currentItem.modelData.maxLosses
                                    openloopErpmBox.realValue = motorList.currentItem.modelData.openloopErpm
                                    sensorlessBox.realValue = motorList.currentItem.modelData.sensorlessErpm
                                    motorPolesBox.realValue = motorList.currentItem.modelData.poles
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent

                            Text {
                                visible: !overrideBox.checked
                                color: "white"
                                font.family: "DejaVu Sans Mono"
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WordWrap
                                text: maxPowerLossBox.prefix + maxPowerLossBox.realValue + maxPowerLossBox.suffix + "\n" +
                                      openloopErpmBox.prefix + openloopErpmBox.realValue + openloopErpmBox.suffix + "\n" +
                                      sensorlessBox.prefix + sensorlessBox.realValue + sensorlessBox.suffix + "\n" +
                                      motorPolesBox.prefix + motorPolesBox.realValue + motorPolesBox.suffix
                            }

                            DoubleSpinBox {
                                visible: overrideBox.checked
                                Layout.fillWidth: true
                                id: maxPowerLossBox
                                decimals: 1
                                realFrom: 0
                                realTo: 5000
                                realValue: 10
                                prefix: "Max Power Loss : "
                                suffix: " W"
                            }

                            DoubleSpinBox {
                                visible: overrideBox.checked
                                Layout.fillWidth: true
                                id: openloopErpmBox
                                decimals: 0
                                realFrom: 0
                                realTo: 50000
                                realValue: 500
                                prefix: "Openloop ERPM  : "
                            }

                            DoubleSpinBox {
                                visible: overrideBox.checked
                                Layout.fillWidth: true
                                id: sensorlessBox
                                decimals: 0
                                realFrom: 0
                                realTo: 50000
                                realValue: 1500
                                prefix: "Sensorless ERPM: "
                            }

                            DoubleSpinBox {
                                visible: overrideBox.checked
                                Layout.fillWidth: true
                                id: motorPolesBox
                                decimals: 0
                                realFrom: 2
                                realTo: 512
                                realValue: 2
                                realStepSize: 2
                                prefix: "Motor Poles    : "

                                onRealValueChanged: {
                                    mMcConf.updateParamInt("si_motor_poles", realValue, null)
                                }
                            }
                        }
                    }
                }
            }

            Item {
                ScrollView {
                    anchors.fill: parent
                    contentWidth: parent.width
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent

                        ParamList {
                            id: paramListBatt
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }

                        GroupBox {
                            Layout.fillWidth: true

                            label: CheckBox {
                                id: overrideBattBox
                                checked: false
                                text: qsTr("Advanced (0 = defaults)")

                                onToggled: {
                                    if (!checked) {
                                        currentInMinBox.realValue = 0
                                        currentInMaxBox.realValue = 0
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                enabled: overrideBattBox.checked

                                DoubleSpinBox {
                                    Layout.fillWidth: true
                                    id: currentInMinBox
                                    decimals: 1
                                    realStepSize: 5
                                    realFrom: 0
                                    realTo: -9999
                                    realValue: 0
                                    prefix: "回充电池电流（电池上限/2）: "
                                    suffix: " A"
                                }

                                DoubleSpinBox {
                                    Layout.fillWidth: true
                                    id: currentInMaxBox
                                    decimals: 1
                                    realStepSize: 5
                                    realFrom: 0
                                    realTo: 9999
                                    realValue: 0
                                    prefix: "电池电流（电池上限/2）: "
                                    suffix: " A"
                                }
                            }
                        }
                    }
                }
            }

            Item {
                ColumnLayout {
                    anchors.fill: parent

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: parent.width
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent

                            GroupBox {
                                id: canFwdBox
                                title: qsTr("Gear Ratio")
                                Layout.fillWidth: true

                                ColumnLayout {
                                    anchors.fill: parent

                                    CheckBox {
                                        id: directDriveBox
                                        text: "直驱"
                                        Layout.fillWidth: true
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            Layout.fillWidth: true
                                            color: "white"
                                            text: qsTr("Motor Pulley")
                                        }

                                        SpinBox {
                                            enabled: !directDriveBox.checked
                                            id: motorPulleyBox
                                            from: 1
                                            to: 999
                                            value: 13
                                            editable: true

                                            textFromValue: function(value) {
                                                return !directDriveBox.checked ? value : 1
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            Layout.fillWidth: true
                                            color: "white"
                                            text: qsTr("Wheel Pulley")
                                        }

                                        SpinBox {
                                            enabled: !directDriveBox.checked
                                            id: wheelPulleyBox
                                            from: 1
                                            to: 999
                                            value: 36
                                            editable: true

                                            textFromValue: function(value) {
                                                return !directDriveBox.checked ? value : 1
                                            }
                                        }
                                    }
                                }
                            }

                            ParamList {
                                id: paramListSetup
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            Item {
                DirectionSetup {
                    id: dirSetup
                    anchors.fill: parent
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
                    text: qsTr("Motor")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Battery")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Setup")
                    width: Math.max(tabBar.buttonWidth, tabBar.width / tabBar.buttons)
                }
                TabButton {
                    text: qsTr("Direction")
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
                        dialog.close()
                    } else {
                        stackLayout.currentIndex--
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
                    if (stackLayout.currentIndex == 0) {
                        startWarningDialog.open()
                    } else if (stackLayout.currentIndex == 1) {
                        if (overrideBattBox.checked) {
                            stackLayout.currentIndex++
                        } else {
                            batteryWarningDialog.open()
                        }
                    } else if (stackLayout.currentIndex == 2) {
                        if (stackLayout.currentIndex == (stackLayout.count - 2)) {
                            if (VescIf.isPortConnected()) {
                                detectDialog.open()
                            } else {
                                VescIf.emitMessageDialog("检测电机",
                                                         "未连接到VESC，请连接再尝试电机检测",
                                                         false, false)
                            }
                        }
                    } else if (stackLayout.currentIndex == 3) {
                        stackLayout.currentIndex = 0
                        dialog.close()
                    }

                    updateButtonText()
                }
            }
        }
    }

    Dialog {
        id: loadDefaultDialog
        standardButtons: Dialog.Yes | Dialog.No
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "载入默认设置"
        parent: ApplicationWindow.overlay

        x: 10
        y: dialog.y + dialog.height / 2 - height / 2

        Text {
            color: "#ffffff"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text: "你想要把连接的所有VESC的设置都恢复为默认设置吗？ "
                  }

        onAccepted: {
            disableDialog()
            Utility.restoreConfAll(VescIf, true, true, true)
            enableDialog()
        }
    }

    Dialog {
        id: startWarningDialog
        property int indexNow: 0
        standardButtons: Dialog.Yes | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "选择电机"
        x: 10
        y: 10 + parent.height / 2 - height / 2
        parent: ApplicationWindow.overlay

        Text {
            color: "#ffffff"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text: "警告:选择太大的电机进行检测可能会在检测过程中损坏电机。" +
                  "重要的是要选择与你使用的电机尺寸相似的电机。你确定你选择的电机在范围内吗?”"
        }

        onAccepted: {
            stackLayout.currentIndex++
            updateButtonText()
        }
    }

    Dialog {
        id: batteryWarningDialog
        property int indexNow: 0
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "电池设置"
        x: 10
        y: 10 + parent.height / 2 - height / 2
        parent: ApplicationWindow.overlay

        Text {
            color: "#ffffff"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text: "警告:您没有指定电池电流限制，这基本上只限制了电压下降太多时的电流。" +
                  "这在大多数情况下是可以的，但请检查您的电池和BMS规格为安全。" +
                  "请记住，你必须将电池电流设置除以vesc的数量。"
        }

        onAccepted: {
            stackLayout.currentIndex++
            updateButtonText()
        }
    }

    Dialog {
        id: detectDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape
        title: "检测FOC参数"
        parent: ApplicationWindow.overlay

        x: 10
        y: dialog.y + dialog.height / 2 - height / 2

        Text {
            color: "#ffffff"
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
            text: "这将转动电机，确保电机悬空。"
        }

        onAccepted: {
            disableDialog()

            mMcConf.updateParamDouble("si_gear_ratio", directDriveBox.checked ?
                                          1 : (wheelPulleyBox.value / motorPulleyBox.value), 0)

            mCommands.setMcconf(false)
            Utility.waitSignal(mCommands, "2ackReceived(QString)", 2000)
            var canDevs = Utility.scanCanVescOnly(VescIf)
            if (!Utility.setBatteryCutCan(VescIf, canDevs, 6.0, 6.0)) {
                enableDialog()
                return
            }

            var res  = Utility.detectAllFoc(VescIf, true,
                                            maxPowerLossBox.realValue,
                                            currentInMinBox.realValue,
                                            currentInMaxBox.realValue,
                                            openloopErpmBox.realValue,
                                            sensorlessBox.realValue)

            var resDetect = false
            if (res.startsWith("成功！")) {
                resDetect = true
                Utility.setBatteryCutCanFromCurrentConfig(VescIf, canDevs);
            }

            enableDialog()

            if (resDetect) {
                stackLayout.currentIndex++
                updateButtonText()
            }

            resultDialog.title = "检测结果"
            resultLabel.text = res
            resultDialog.open()
        }
    }

    Dialog {
        id: resultDialog
        standardButtons: Dialog.Ok
        modal: true
        focus: true
        width: parent.width - 20
        height: parent.height - 40
        closePolicy: Popup.CloseOnEscape
        parent: ApplicationWindow.overlay

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        ScrollView {
            anchors.fill: parent
            clip: true
            contentWidth: parent.width - 20

            Text {
                id: resultLabel
                color: "#ffffff"
                font.family: "DejaVu Sans Mono"
                verticalAlignment: Text.AlignVCenter
                anchors.fill: parent
                wrapMode: Text.WordWrap
            }
        }

        onClosed: {
            if (stackLayout.currentIndex == (stackLayout.count - 1)) {
                workaroundNotFocusTimer.start()
            }
        }
    }

    Timer {
        id: workaroundNotFocusTimer
        interval: 0
        repeat: false
        running: false

        onTriggered: {
            dirSetup.scanCan()
        }
    }

    function updateButtonText() {
        if (stackLayout.currentIndex == (stackLayout.count - 1)) {
            nextButton.text = "结束"
        } else if (stackLayout.currentIndex == (stackLayout.count - 2)) {
            nextButton.text = "开始检测"
        } else {
            nextButton.text = "下一步"
        }

        if (stackLayout.currentIndex == 0) {
            prevButton.text = "取消"
        } else {
            prevButton.text = "上一步"
        }
    }

    function disableDialog() {
        commDialog.open()
        stackLayout.enabled = false
        prevButton.enabled = false
        nextButton.enabled = false
    }

    function enableDialog() {
        commDialog.close()
        stackLayout.enabled = true
        prevButton.enabled = true
        nextButton.enabled = true
    }

    Dialog {
        id: commDialog
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
