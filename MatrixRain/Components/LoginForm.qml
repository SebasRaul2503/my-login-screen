import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import SddmComponents 2.0 as SDDM

Rectangle {
    id: form
    SDDM.TextConstants { id: textConstants }

    // Fixed in v1; promote to config.* later without refactor.
    property string headerUser: "root@arch:~$"
    property string headerCmd: "login"
    property string footerText: "[ wake up, Neo... ]"
    property color accent: config.MainColor || "#00ff41"
    property bool failed: false

    width: 380
    implicitHeight: layout.implicitHeight + 40
    color: Qt.rgba(0, 0.04, 0, 0.82)
    border.color: accent
    border.width: 1

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        // Header: root@arch:~$ login   (cmd in white)
        Text {
            Layout.fillWidth: true
            font.family: config.UIFont
            font.pointSize: 13
            textFormat: Text.StyledText
            color: form.accent
            text: form.headerUser + ' <font color="#ffffff">' + form.headerCmd + '</font>'
        }

        // user row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text {
                text: "user"; color: form.accent; font.family: config.UIFont
                font.pointSize: 13; Layout.preferredWidth: 38
            }
            TerminalInput {
                id: username
                Layout.fillWidth: true
                font.pointSize: 13
                text: userModel.lastUser
                onAccepted: password.forceActiveFocus()
            }
        }

        // pass row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text {
                text: "pass"; color: form.accent; font.family: config.UIFont
                font.pointSize: 13; Layout.preferredWidth: 38
            }
            TerminalInput {
                id: password
                Layout.fillWidth: true
                font.pointSize: 13
                echoMode: TextInput.Password
                focus: true
                onAccepted: loginButton.clicked()
            }
        }

        // error / capslock message
        Text {
            id: errorMessage
            Layout.fillWidth: true
            font.family: config.UIFont
            font.pointSize: 11
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            color: "#ff5555"
            opacity: (form.failed || keyboard.capsLock) ? 1 : 0
            text: form.failed
                  ? (textConstants.loginFailed + "!")
                  : (keyboard.capsLock ? textConstants.capslockWarning : "")
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }

        // footer easter-egg
        Text {
            Layout.fillWidth: true
            font.family: config.UIFont
            font.pointSize: 12
            color: form.accent
            opacity: 0.85
            text: form.footerText
        }

        // session selector + login button
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ComboBox {
                id: sessionSelect
                Layout.preferredWidth: 150
                Layout.preferredHeight: 34
                font.family: config.UIFont
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex

                contentItem: Text {
                    text: sessionSelect.displayText
                    color: form.accent
                    font.family: config.UIFont
                    font.pointSize: 12
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                    rightPadding: 24
                    elide: Text.ElideRight
                }

                indicator: Text {
                    x: sessionSelect.width - width - 8
                    y: (sessionSelect.height - height) / 2
                    text: ""
                    font.family: config.UIFont
                    font.pointSize: 11
                    color: form.accent
                }

                background: Rectangle {
                    color: config.InputBackground || "#001400"
                    border.color: sessionSelect.activeFocus ? form.accent : (config.InputBorder || "#00aa2a")
                    border.width: 1
                    radius: 0
                }

                delegate: ItemDelegate {
                    width: sessionSelect.width
                    height: 32
                    highlighted: sessionSelect.highlightedIndex === index
                    contentItem: Text {
                        text: model.name
                        color: form.accent
                        font.family: config.UIFont
                        font.pointSize: 12
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                    background: Rectangle {
                        color: parent.highlighted ? Qt.rgba(0, 1, 0.25, 0.18)
                                                  : (config.InputBackground || "#001400")
                    }
                }

                popup: Popup {
                    y: sessionSelect.height
                    width: sessionSelect.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: sessionSelect.popup.visible ? sessionSelect.delegateModel : null
                        currentIndex: sessionSelect.highlightedIndex
                    }
                    background: Rectangle {
                        color: config.InputBackground || "#001400"
                        border.color: form.accent
                        border.width: 1
                        radius: 0
                    }
                }
            }

            Button {
                id: loginButton
                Layout.fillWidth: true
                text: "ENTRAR"
                enabled: username.text !== "" && password.text !== ""
                font.family: config.UIFont
                contentItem: Text {
                    text: loginButton.text
                    color: "#000000"
                    font.family: config.UIFont
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: loginButton.enabled
                           ? (loginButton.down ? Qt.darker(form.accent, 1.2) : form.accent)
                           : Qt.rgba(0, 1, 0.25, 0.25)
                    radius: 0
                }
                onClicked: sddm.login(username.text, password.text, sessionSelect.currentIndex)
                Keys.onReturnPressed: clicked()
                Keys.onEnterPressed: clicked()
            }
        }
    }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            form.failed = true
            password.text = ""
            resetError.restart()
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: form.failed = false
    }
}
