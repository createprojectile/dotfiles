// ============================================================================
//  SDDM · Ayu Dark
//  Минимальный экран входа: часы, карточка с паролем, выбор сессии, питание.
// ============================================================================
import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0a0e14"

    // --- Фон ---------------------------------------------------------------
    Image {
        id: background
        anchors.fill: parent
        source: config.background !== "" ? Qt.resolvedUrl(config.background) : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#0a0e14"
        opacity: 0.42
    }

    // Лёгкое затемнение снизу — карточка всегда читаема.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#400a0e14" }
            GradientStop { position: 0.55; color: "#000a0e14" }
            GradientStop { position: 1.0; color: "#800a0e14" }
        }
    }

    // --- Часы ---------------------------------------------------------------
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.13
        spacing: 6

        Text {
            id: clockTime
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#e6e1cf"
            font.family: "Inter"
            font.pixelSize: 72
            font.weight: Font.Light
            font.letterSpacing: 1
            text: Qt.formatDateTime(new Date(), "HH:mm")
        }

        Text {
            id: clockDate
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#8a9199"
            font.family: "Inter"
            font.pixelSize: 15
            font.letterSpacing: 0.4
            text: Qt.formatDateTime(new Date(), "dddd, d MMMM")
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockTime.text = Qt.formatDateTime(new Date(), "HH:mm")
            clockDate.text = Qt.formatDateTime(new Date(), "dddd, d MMMM")
        }
    }

    // --- Карточка входа -----------------------------------------------------
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.44
        width: 380
        height: 236
        radius: 18
        color: "#e611151c"
        border.width: 1
        border.color: "#1f2630"

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 18

            // Аватар + имя пользователя.
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Rectangle {
                    width: 44; height: 44; radius: 22
                    color: "#1f2630"
                    border.width: 1
                    border.color: "#59c2ff"

                    Text {
                        anchors.centerIn: parent
                        color: "#59c2ff"
                        font.family: "Inter"
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        text: (userModel.lastUser && userModel.lastUser.length > 0)
                              ? userModel.lastUser.charAt(0).toUpperCase() : "?"
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        color: "#bfbdb6"
                        font.family: "Inter"
                        font.pixelSize: 15
                        font.weight: Font.Medium
                        text: sddm.hostName
                    }

                    Text {
                        color: "#8a9199"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        text: (userModel.lastUser && userModel.lastUser.length > 0)
                              ? userModel.lastUser : "пользователь"
                    }
                }
            }

            // Поле пароля.
            Rectangle {
                id: passwordFrame
                width: parent.width
                height: 46
                radius: 10
                color: "#0d1017"
                border.width: 1
                border.color: password.activeFocus ? "#59c2ff" : "#1f2630"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    visible: password.text.length === 0
                    color: "#565b66"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    text: "Пароль"
                }

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: "#bfbdb6"
                    selectionColor: "#59c2ff"
                    selectedTextColor: "#0a0e14"
                    echoMode: TextInput.Password
                    passwordCharacter: "•"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    focus: true
                    clip: true

                    onAccepted: doLogin()

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            doLogin()
                            event.accepted = true
                        }
                    }
                }
            }

            // Кнопка входа.
            Rectangle {
                id: loginButton
                width: parent.width
                height: 42
                radius: 10
                color: loginArea.containsMouse ? "#7fd0ff" : "#59c2ff"

                Text {
                    anchors.centerIn: parent
                    color: "#0a0e14"
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.5
                    text: "Войти"
                }

                MouseArea {
                    id: loginArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: doLogin()
                }
            }

            // Ошибка / подсказка.
            Text {
                id: message
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: "#f07178"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                text: ""
            }
        }
    }

    // --- Сессия -------------------------------------------------------------
    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 32
        spacing: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: "#565b66"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            text: "СЕССИЯ"
        }

        ComboBox {
            id: session
            width: 190
            height: 30

            color: "#e611151c"
            borderColor: "#1f2630"
            hoverColor: "#59c2ff"
            focusColor: "#59c2ff"
            menuColor: "#11151c"
            textColor: "#bfbdb6"
            arrowColor: "#8a9199"
            borderWidth: 1

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11

            model: sessionModel
            index: sessionModel.lastIndex
        }
    }

    // --- Питание ------------------------------------------------------------
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 32
        spacing: 22

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: sddm.canSuspend
            color: suspendArea.containsMouse ? "#59c2ff" : "#8a9199"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            text: "Сон"
            MouseArea {
                id: suspendArea
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.suspend()
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: rebootArea.containsMouse ? "#59c2ff" : "#8a9199"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            text: "Перезагрузка"
            MouseArea {
                id: rebootArea
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: powerArea.containsMouse ? "#f07178" : "#8a9199"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            text: "Выключить"
            MouseArea {
                id: powerArea
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }
    }

    // --- Логика -------------------------------------------------------------
    function doLogin() {
        if (password.text.length === 0)
            return
        message.text = "Проверка…"
        message.color = "#8a9199"
        sddm.login(userModel.lastUser, password.text, session.index)
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            password.text = ""
            message.text = "Неверный пароль"
            message.color = "#f07178"
        }

        function onInformationMessage(text) {
            message.text = text
            message.color = "#e6b450"
        }
    }

    Component.onCompleted: password.forceActiveFocus()

    // Клик по пустому месту возвращает фокус паролю.
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: password.forceActiveFocus()
    }
}
