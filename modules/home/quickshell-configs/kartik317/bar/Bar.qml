// Kartik317-inspired Bar - Adapted for MangoWM
// Original: https://github.com/kartik317/Quickshell-configuration
// Adapted to work with MangoWM instead of Hyprland

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
// Removed theme import - using inline colors instead

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }
    
    implicitHeight: 45 
    color: "transparent"

    // Config options
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14
    readonly property real pillRadius: 12
    readonly property color pillBg: Qt.alpha("#1e1e2e", 0.85)
    
    // Color palette (inline to avoid singleton import issues)
    readonly property color colBg: "#1e1e2e"
    readonly property color colFg: "#cdd6f4"
    readonly property color colBlue: "#89b4fa"
    readonly property color colLavender: "#b4befe"
    readonly property color colPeach: "#fab387"
    readonly property color colMauve: "#cba6f7"
    readonly property color colGreen: "#a6e3a1"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        // Left Section: Logo, Workspaces
        Rectangle {
            Layout.fillHeight: true
            color: root.pillBg
            radius: root.pillRadius
            implicitWidth: leftRow.implicitWidth + 16

            RowLayout {
                id: leftRow
                anchors.centerIn: parent
                spacing: 8

                // Logo (Mango emoji instead of Arch)
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "🥭"
                        font.pixelSize: 22
                    }
                }

                // Separator
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Qt.alpha("#cdd6f4", 0.3)
                }

                // Workspaces (simplified - static for now)
                RowLayout {
                    spacing: 6
                    
                    Repeater {
                        model: [1, 2, 3, 4, 5]
                        
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 6
                            color: modelData === 1 ? "#89b4fa" : Qt.alpha("#cdd6f4", 0.2)
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: modelData === 1 ? "#1e1e2e" : "#cdd6f4"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        // Center Spacer
        Item {
            Layout.fillWidth: true
        }

        // Center Section: Active Window Title (placeholder)
        Rectangle {
            Layout.fillHeight: true
            Layout.maximumWidth: 400
            color: root.pillBg
            radius: root.pillRadius
            
            Text {
                anchors.centerIn: parent
                text: "No active window"
                color: "#cdd6f4"
                font.pixelSize: root.fontSize
                font.family: root.fontFamily
                elide: Text.ElideMiddle
            }
        }

        // System Info Pill
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 280
            color: root.pillBg
            radius: root.pillRadius
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 12
                
                // CPU (placeholder)
                Text {
                    text: "💻 25%"
                    color: "#fab387"
                    font.pixelSize: root.fontSize
                    font.family: root.fontFamily
                }
                
                // RAM (placeholder)
                Text {
                    text: "🧠 45%"
                    color: "#cba6f7"
                    font.pixelSize: root.fontSize
                    font.family: root.fontFamily
                }
            }
        }

        // Network, Battery & Clock Pill
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: statusRow.implicitWidth + 24
            color: root.pillBg
            radius: root.pillRadius

            RowLayout {
                id: statusRow
                anchors.centerIn: parent
                spacing: 8

                // Network (placeholder)
                Text {
                    text: "📶"
                    font.pixelSize: root.fontSize
                }

                // Separator
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 20
                    color: Qt.alpha("#cdd6f4", 0.3)
                }

                // Battery (placeholder)
                Text {
                    text: "🔋 85%"
                    color: "#a6e3a1"
                    font.pixelSize: root.fontSize
                    font.family: root.fontFamily
                }

                // Separator
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 20
                    color: Qt.alpha("#cdd6f4", 0.3)
                }

                // Volume (placeholder)
                Text {
                    text: "🔊 75%"
                    color: "#89b4fa"
                    font.pixelSize: root.fontSize
                    font.family: root.fontFamily
                }

                // Separator
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 20
                    color: Qt.alpha("#cdd6f4", 0.3)
                }

                // Clock
                Text {
                    id: clockText
                    text: "--:--"
                    color: "#cdd6f4"
                    font.pixelSize: root.fontSize
                    font.family: root.fontFamily
                    font.bold: true

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: {
                            clockText.text = Qt.formatTime(new Date(), "HH:mm")
                        }
                    }
                }
            }
        }
    }
}
