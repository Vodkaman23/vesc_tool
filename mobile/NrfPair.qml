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

import Vedder.vesc.vescinterface 1.0
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0

Item {
    implicitHeight: column.implicitHeight
    property bool hideAfterPair: false

    function startPairing() {
        mCommands.pairNrf(timeBox.realValue * 1000.0)
    }

    property real pairCnt: 0.0
    property Commands mCommands: VescIf.commands()
    property ConfigParams mInfoConf: VescIf.infoConfig()

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 0

        DoubleSpinBox {
            id: timeBox
            Layout.fillWidth: true
            realFrom: 1.0
            realTo: 30.0
            realValue: 10.0
            decimals: 1
            prefix: "Time: "
            suffix: " s"
        }

        ProgressBar {
            id: cntBar
            Layout.fillWidth: true
            Layout.bottomMargin: 5
            from: 0.0
            to: 1.0
            value: 0.0
        }

        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "帮助"
                Layout.preferredWidth: 50
                Layout.fillWidth: true
                flat: true

                onClicked: {
                    VescIf.emitMessageDialog(
                                mInfoConf.getLongName("help_nrf_pair"),
                                mInfoConf.getDescription("help_nrf_pair"),
                                true, true)
                }
            }

            Button {
                id: startButton
                text: "开始"
                Layout.preferredWidth: 50
                Layout.fillWidth: true
                flat: true

                onClicked: {
                    startPairing()
                }
            }
        }
    }

    Timer {
        id: cntTimer
        interval: 100
        running: true
        repeat: true

        onTriggered: {
            if (pairCnt > 0.01) {
                pairCnt -= 0.1

                if (pairCnt <= 0.01) {
                    startButton.enabled = true
                    pairCnt = 0.0
                }

                cntBar.value = pairCnt / timeBox.realValue
            }
        }
    }

    Connections {
        target: mCommands

        onNrfPairingRes: {
            if (!visible) {
                return
            }

            switch (res) {
            case 0:
                pairCnt = timeBox.realValue
                cntBar.value = 1
                startButton.enabled = false
                break;

            case 1:
                startButton.enabled = true
                pairCnt = 0.0
                cntBar.value = 0
                VescIf.emitStatusMessage("NRF配对成功！", true)
                VescIf.emitMessageDialog(
                            "NRF 配对中",
                            "配对成功。",
                            true, false)
                break;

            case 2:
                startButton.enabled = true
                pairCnt = 0.0
                cntBar.value = 0
                VescIf.emitStatusMessage("NRF配对超时", false)
                VescIf.emitMessageDialog(
                            "NRF配对中",
                            "配对超时。请确保在时间结束前将您的设备(e.g. NRF nunchuk) " +
                            "置于配对模式。" +
                            "<br><br>" +
                            "要把NRF nunchuk在配对模式" +
                            "只要使用任何按钮开关它。" +
                            "如果之前关机，则进入配对模式。",
                            false, false)
//                VescIf.emitMessageDialog("Test", "test23", false, false)
                break;

            default:
                break;
            }

            if (hideAfterPair && res > 0) {
                visible = false
            }
        }
    }
}
