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
import Vedder.vesc.commands 1.0
import Vedder.vesc.configparams 1.0
import Vedder.vesc.fwhelper 1.0
import Vedder.vesc.utility 1.0

Item {
    property Commands mCommands: VescIf.commands()
    property ConfigParams mInfoConf: VescIf.infoConfig()

    FwHelper {
        id: fwHelper
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0

            Rectangle {
                color: "#4f4f4f"
                width: 16
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter |  Qt.AlignVCenter

                PageIndicator {
                    id: indicator
                    count: swipeView.count
                    currentIndex: swipeView.currentIndex
                    anchors.centerIn: parent
                    rotation: 90
                }
            }

            SwipeView {
                id: swipeView
                enabled: true
                clip: true

                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: Qt.Vertical

                Page {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Rectangle {
                            Layout.fillWidth: true
                            height: 30;
                            border.width: 0
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.00;
                                    color: "#002dcbff";
                                }
                                GradientStop {
                                    position: 0.3;
                                    color: "#80014cb2";
                                }
                                GradientStop {
                                    position: 0.7;
                                    color: "#80014cb2";
                                }
                                GradientStop {
                                    position: 1.00;
                                    color: "#000dc3ff";
                                }
                            }
                            border.color: "#00000000"

                            Text {
                                anchors.centerIn: parent
                                color: "white"
                                text: "内置文件"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Item {
                            // Spacer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        Text {
                            color: "white"
                            Layout.fillWidth: true
                            height: 30;
                            text: "硬件"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        ComboBox {
                            id: hwBox
                            Layout.preferredHeight: 48
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                            textRole: "key"
                            model: ListModel {
                                id: hwItems
                            }

                            Component.onCompleted: {
                                updateHw("")
                            }

                            onCurrentIndexChanged: {
                                if (hwItems.rowCount() === 0) {
                                    return
                                }

                                var fws = fwHelper.getFirmwares(hwItems.get(hwBox.currentIndex).value)

                                fwItems.clear()

                                for (var name in fws) {
                                    if (name.toLowerCase().indexOf("vesc_default.bin") !== -1) {
                                        fwItems.insert(0, { key: name, value: fws[name] })
                                    } else {
                                        fwItems.append({ key: name, value: fws[name] })
                                    }
                                }

                                fwBox.currentIndex = 0
                            }
                        }

                        Text {
                            color: "white"
                            Layout.fillWidth: true
                            height: 30;
                            text: "固件"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        ComboBox {
                            id: fwBox
                            Layout.preferredHeight: 48
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                            textRole: "key"
                            model: ListModel {
                                id: fwItems
                            }
                        }

                        Button {
                            text: "显示更新日志"
                            Layout.fillWidth: true

                            onClicked: {
                                VescIf.emitMessageDialog(
                                            "更新日志",
                                            Utility.fwChangeLog(),
                                            true)
                            }
                        }

                        Item {
                            // Spacer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }

                Page {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Rectangle {
                            Layout.fillWidth: true
                            height: 30;
                            border.width: 0
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.00;
                                    color: "#002dcbff";
                                }
                                GradientStop {
                                    position: 0.3;
                                    color: "#80014cb2";
                                }
                                GradientStop {
                                    position: 0.7;
                                    color: "#80014cb2";
                                }
                                GradientStop {
                                    position: 1.00;
                                    color: "#000dc3ff";
                                }
                            }
                            border.color: "#00000000"

                            Text {
                                anchors.centerIn: parent
                                color: "white"
                                text: "自定义文件"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Item {
                            // Spacer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        TextInput {
                            color: "white"
                            id: customFwText
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "选择文件..."
                            Layout.fillWidth: true

                            onClicked: {
                                if (Utility.requestFilePermission()) {
                                    filePicker.enabled = true
                                    filePicker.visible = true
                                } else {
                                    VescIf.emitMessageDialog(
                                                "文件权限",
                                                "无法取得系统权限",
                                                false, false)
                                }
                            }
                        }

                        Item {
                            // Spacer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }

                    FilePicker {
                        id: filePicker
                        anchors.fill: parent
                        showDotAndDotDot: true
                        nameFilters: "*.bin"
                        visible: false
                        enabled: false

                        onFileSelected: {
                            customFwText.text = currentFolder() + "/" + fileName
                            visible = false
                            enabled = false
                        }
                    }
                }

                Page {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Rectangle {
                            Layout.fillWidth: true
                            height: 30;
                            border.width: 0
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.00;
                                    color: "#002dcbff";
                                }
                                GradientStop {
                                    position: 0.3;
                                    color: "#80014cb2";
                                }
                                GradientStop {
                                    position: 0.7;
                                    color: "#80014cb2";
                                }
                                GradientStop {
                                    position: 1.00;
                                    color: "#000dc3ff";
                                }
                            }
                            border.color: "#00000000"

                            Text {
                                anchors.centerIn: parent
                                color: "white"
                                text: "引导加载程序"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Item {
                            // Spacer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        Text {
                            color: "white"
                            Layout.fillWidth: true
                            height: 30;
                            text: "硬件"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        ComboBox {
                            id: blBox
                            Layout.preferredHeight: 48
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                            textRole: "key"
                            model: ListModel {
                                id: blItems
                            }

                            Component.onCompleted: {
                                updateBl("")
                            }
                        }

                        Item {
                            // Spacer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: asd.implicitHeight + 20
            color: "#414141"

            ColumnLayout {
                id: asd
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    Layout.fillWidth: true
                    color: "white"
                    id: uploadText
                    text: qsTr("Not Uploading")
                    horizontalAlignment: Text.AlignHCenter
                }

                ProgressBar {
                    id: uploadProgress
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        id: uploadButton
                        text: qsTr("Upload")
                        Layout.fillWidth: true

                        onClicked: {
                            uploadFw(false)
                        }
                    }

                    Button {
                        id: uploadAllButton
                        text: qsTr("Upload All")
                        Layout.fillWidth: true

                        onClicked: {
                            uploadFw(true)
                        }
                    }

                    Button {
                        id: cancelButton
                        text: qsTr("Cancel")
                        Layout.fillWidth: true
                        enabled: false

                        onClicked: {
                            VescIf.fwUploadCancel()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    id: versionText
                    color: "#e0e0e0"
                    text:
                        "固件   : \n" +
                        "硬件   : \n" +
                        "UUID : "
                    font.family: "DejaVu Sans Mono"
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Dialog {
        id: uploadDialog
        property bool fwdCan: false
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        focus: true
        width: parent.width - 20
        closePolicy: Popup.CloseOnEscape

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Text {
            color: "#ffffff"
            id: uploadDialogLabel
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            wrapMode: Text.WordWrap
        }

        onAccepted: {
            if (swipeView.currentIndex == 0) {
                fwHelper.uploadFirmware(fwItems.get(fwBox.currentIndex).value, VescIf, false, false, fwdCan)
            } else if (swipeView.currentIndex == 1) {
                fwHelper.uploadFirmware(customFwText.text, VescIf, false, true, fwdCan)
            } else if (swipeView.currentIndex == 2) {
                fwHelper.uploadFirmware(blItems.get(blBox.currentIndex).value, VescIf, true, false, fwdCan)
            }
        }
    }

    function updateHw(params) {
        var hws = fwHelper.getHardwares(params, params.hw)

        hwItems.clear()

        for (var name in hws) {
            if (name.indexOf("412") !== -1) {
                hwItems.insert(0, { key: name, value: hws[name] })
            } else {
                hwItems.append({ key: name, value: hws[name] })
            }
        }

        hwBox.currentIndex = 0
    }

    function updateBl(params) {
        var bls = fwHelper.getBootloaders(params, params.hw)

        blItems.clear()

        for (var name in bls) {
            if (name.indexOf("412") !== -1) {
                blItems.insert(0, { key: name, value: bls[name] })
            } else {
                blItems.append({ key: name, value: bls[name] })
            }
        }

        blBox.currentIndex = 0
    }

    function uploadFw(fwdCan) {
        if (!VescIf.isPortConnected()) {
            VescIf.emitMessageDialog(
                        "连接错误",
                        "VESC未连接，请连接",
                        false)
            return
        }

        var msg = "您即将上传新固件到已连接的VESC"
        var msgBl = "您即将上传一个引导加载程序到连接的VESC"

        var msgEnd = "."
        if (fwdCan) {
            msgEnd = "，以及can总线上发现的所有vesc。 \n\n" +
                    "警告:只有在can总线上所有vesc硬件版本相同的情况下，才能使用上传全部功能。" +
                    "如果不是这样，则必须分别向vesc上传固件。"
        }

        msg += msgEnd
        msgBl += msgEnd

        uploadDialog.fwdCan = fwdCan

        if (swipeView.currentIndex == 0) {
            if (fwItems.rowCount() === 0) {
                VescIf.emitMessageDialog(
                            "上传错误",
                            "此版本的VESC工具不包含任何硬件版本的固件。 " +
                            "您可以上传自定义文件， " +
                            "或者寻找可能支持您的硬件的VESC Tool的新版本。",
                            false)
                return;
            }

            if (hwItems.rowCount() === 1) {
                uploadDialog.title = "警告"

                if (VescIf.getFwSupportsConfiguration()) {
                    msg += "\n\n" +
                            "上传新固件将清除VESC上的所有设置。 " +
                            "您可以从连接页面备份设置， " +
                            "并在更新之后恢复它们(如果您还没有备份的话)。 " +
                            "您想要继续更新，还是先取消并执行备份?"
                } else {
                    msg += "\n\n" +
                            "上传新固件将清除VESC上的所有设置， " +
                            "您必须重新进行配置。要继续吗?

"
                }

                uploadDialogLabel.text = msg
                uploadDialog.open()
            } else {
                uploadDialog.title = "警告"
                uploadDialogLabel.text =
                        msg + "\n\n" +
                        "上传不同硬件版本的固件肯定会损坏VESC。" +
                        "您确定选择了正确的硬件版本吗?"
                uploadDialog.open()
            }
        } else if (swipeView.currentIndex == 1) {
            if (customFwText.text.length > 0) {
                uploadDialog.title = "警告"
                uploadDialogLabel.text =
                        msg + "\n\n" +
                        "上传不同硬件版本的固件肯定会损坏VESC。" +
                        "您确定选择了正确的硬件版本吗?"
                uploadDialog.open()
            } else {
                VescIf.emitMessageDialog(
                            "错误",
                            "请选择文件",
                            false, false)
            }
        } else if (swipeView.currentIndex == 2) {
            if (blItems.rowCount() === 0) {
                VescIf.emitMessageDialog(
                            "上传错误",
                            "VESC工具的这个版本不包含您硬件版本的引导加载程序。",
                            false)
                return;
            }

            uploadDialog.title = "警告"

            var msgBl2 = ""
            if (!mCommands.getLimitedSupportsEraseBootloader()) {
                msgBl2 = "如果VESC已经有一个引导加载程序，这将破坏引导加载程序和固件更新不能再继续了 "
            }

            uploadDialogLabel.text =
                    msgBl + "\n\n" + msgBl2 +
                    "你想继续吗?"
            uploadDialog.open()
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true

        onTriggered: {
            uploadAllButton.enabled = mCommands.getLimitedSupportsFwdAllCan() &&
                    !mCommands.getSendCan() && VescIf.getFwUploadProgress() < 0

            if (!VescIf.isPortConnected()) {
                versionText.text =
                        "固件   : \n" +
                        "硬件   : \n" +
                        "UUID : "
            }
        }
    }

    Connections {
        target: VescIf

        onFwUploadStatus: {
            if (isOngoing) {
                uploadText.text = status + " (" + parseFloat(progress * 100.0).toFixed(2) + " %)"
            } else {
                uploadText.text = status
            }

            uploadProgress.value = progress
            uploadButton.enabled = !isOngoing
            cancelButton.enabled = isOngoing
        }
    }

    Connections {
        target: mCommands

        onFwVersionReceived: {
            updateHw(params)
            updateBl(params)

            var testFwStr = "";

            if (params.isTestFw > 0) {
                testFwStr = " BETA " +  params.isTestFw
            }

            versionText.text =
                    "固件   : " + params.major + "." + params.minor + testFwStr + "\n" +
                    "硬件   : " + params.hw + "\n" +
                    "UUID : " + Utility.uuid2Str(params.uuid, false)
        }
    }
}
