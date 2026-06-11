import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import SddmComponents 2.0 as SDDM

// Mission-control access panel. Visuals are HUD; the auth wiring is the
// standard SDDM contract (sddm.login / userModel / sessionModel / keyboard).
Rectangle {
    id: form
    SDDM.TextConstants { id: textConstants }

    property color accent:  config.Accent  || "#ffae5c"
    property color accent2: config.Accent2 || "#7cc7ff"
    property color hot:     config.DiskHot || "#fff3d6"
    property bool failed: false

    width: 380
    implicitHeight: layout.implicitHeight + 44
    radius: 3
    color: Qt.rgba(0.027, 0.039, 0.071, 0.66)   // dark glass
    border.color: Qt.rgba(0.49, 0.78, 1.0, 0.30)
    border.width: 1

    CornerTicks { anchors.fill: parent; color: form.accent }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 22
        spacing: 12

        // ---- wordmark ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text {
                text: "●"                  // ● event-horizon motif
                color: form.accent
                font.pointSize: 15
            }
            ColumnLayout {
                spacing: 0
                Text {
                    text: config.Wordmark || "SINGULARITY"
                    color: form.accent
                    font.family: config.UIFont
                    font.pointSize: 16
                    font.bold: true
                    font.letterSpacing: 3
                }
                Text {
                    text: "// " + (config.Tagline || "gravitational access terminal")
                    color: form.accent2
                    opacity: 0.7
                    font.family: config.UIFont
                    font.pointSize: 8.5
                }
            }
            Item { Layout.fillWidth: true }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0.49, 0.78, 1.0, 0.18) }

        // ---- operator ----
        Text {
            text: "OPERADOR"
            color: form.accent2; opacity: 0.8
            font.family: config.UIFont; font.pointSize: 8.5; font.letterSpacing: 2
        }
        TerminalInput {
            id: username
            Layout.fillWidth: true
            font.pointSize: 12
            text: userModel.lastUser
            onAccepted: password.forceActiveFocus()
        }

        // ---- passphrase ----
        Text {
            text: "CLAVE"
            color: form.accent2; opacity: 0.8
            font.family: config.UIFont; font.pointSize: 8.5; font.letterSpacing: 2
        }
        TerminalInput {
            id: password
            Layout.fillWidth: true
            font.pointSize: 12
            echoMode: TextInput.Password
            focus: true
            onAccepted: loginButton.clicked()
        }

        // ---- status line (error / capslock) ----
        Text {
            id: errorMessage
            Layout.fillWidth: true
            font.family: config.UIFont
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
            color: "#ff6b6b"
            opacity: (form.failed || keyboard.capsLock) ? 1 : 0
            text: form.failed
                  ? ("⚠ " + textConstants.loginFailed)
                  : (keyboard.capsLock ? ("⚠ " + textConstants.capslockWarning) : "")
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }

        // ---- session ----
        Text {
            text: "SESIÓN"
            color: form.accent2; opacity: 0.8
            font.family: config.UIFont; font.pointSize: 8.5; font.letterSpacing: 2
        }
        ComboBox {
            id: sessionSelect
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            font.family: config.UIFont
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex

            contentItem: Text {
                text: sessionSelect.displayText
                color: form.accent
                font.family: config.UIFont
                font.pointSize: 11
                verticalAlignment: Text.AlignVCenter
                leftPadding: 12
                rightPadding: 26
                elide: Text.ElideRight
            }
            indicator: Text {
                x: sessionSelect.width - width - 10
                y: (sessionSelect.height - height) / 2
                text: ""                  // nf chevron-down
                font.family: config.UIFont
                font.pointSize: 10
                color: form.accent2
            }
            background: Rectangle {
                color: config.InputBackground || "#0c1020"
                radius: 2
                border.color: sessionSelect.activeFocus ? form.accent : (config.InputBorder || "#2c3a52")
                border.width: 1
            }
            delegate: ItemDelegate {
                width: sessionSelect.width
                height: 32
                highlighted: sessionSelect.highlightedIndex === index
                contentItem: Text {
                    text: model.name
                    color: highlighted ? form.hot : form.accent
                    font.family: config.UIFont
                    font.pointSize: 11
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
                background: Rectangle {
                    color: parent.highlighted ? Qt.rgba(1.0, 0.68, 0.36, 0.16)
                                              : (config.InputBackground || "#0c1020")
                }
            }
            popup: Popup {
                y: sessionSelect.height + 2
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
                    color: config.InputBackground || "#0c1020"
                    border.color: form.accent
                    border.width: 1
                    radius: 2
                }
            }
        }

        // ---- access button ----
        Button {
            id: loginButton
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.topMargin: 2
            text: config.LoginLabel || "CRUZAR EL HORIZONTE"
            enabled: username.text !== "" && password.text !== ""
            font.family: config.UIFont
            contentItem: Text {
                text: loginButton.text
                color: loginButton.enabled ? "#0a0d16" : Qt.rgba(1, 1, 1, 0.4)
                font.family: config.UIFont
                font.bold: true
                font.pointSize: 11
                font.letterSpacing: 1
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: loginButton.enabled
                        ? (loginButton.down ? Qt.darker(form.accent, 1.2) : form.hot) : Qt.rgba(1, 1, 1, 0.08) }
                    GradientStop { position: 1.0; color: loginButton.enabled
                        ? (loginButton.down ? Qt.darker(form.accent, 1.3) : form.accent) : Qt.rgba(1, 1, 1, 0.05) }
                }
            }
            onClicked: sddm.login(username.text, password.text, sessionSelect.currentIndex)
            Keys.onReturnPressed: clicked()
            Keys.onEnterPressed: clicked()
        }

        // ---- telemetry easter-egg ----
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: config.Footer || "// ni la luz escapa de aquí"
            color: form.accent2
            opacity: 0.55
            font.family: config.UIFont
            font.pointSize: 9
            font.italic: true
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
        interval: 2200
        onTriggered: form.failed = false
    }
}
