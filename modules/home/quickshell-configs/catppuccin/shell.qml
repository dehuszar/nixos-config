// CATPPUCCIN THEME - Inspired by ekremx25 but simplified
// Purpose: Beautiful themed bar with Catppuccin Mocha colors
// Features: Workspaces, clock, system info with consistent theming

import QtQuick
import Quickshell
import Quickshell.Layouts

Scope {
  // Catppuccin Mocha color palette
  readonly property string base: "#1e1e2e"
  readonly property string mantle: "#181825"
  readonly property string crust: "#11111b"
  readonly property string text: "#cdd6f4"
  readonly property string subtext0: "#a6adc8"
  readonly property string subtext1: "#bac2de"
  readonly property string surface0: "#313244"
  readonly property string surface1: "#45475a"
  readonly property string surface2: "#585b70"
  readonly property string blue: "#89b4fa"
  readonly property string lavender: "#b4befe"
  readonly property string sapphire: "#74c7ec"
  readonly property string sky: "#89dceb"
  readonly property string teal: "#94e2d5"
  readonly property string green: "#a6e3a1"
  readonly property string yellow: "#f9e2af"
  readonly property string peach: "#fab387"
  readonly property string maroon: "#eba0ac"
  readonly property string red: "#f38ba8"
  readonly property string mauve: "#cba6f7"
  readonly property string pink: "#f5c2e7"
  readonly property string flamingo: "#f2cdcd"
  readonly property string rosewater: "#f5e0dc"

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 40

      // Background with rounded corners
      Rectangle {
        anchors.fill: parent
        color: root.base
        opacity: 0.95
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        // === LEFT SECTION ===
        RowLayout {
          spacing: 10

          // Launcher button
          Rectangle {
            color: root.surface0
            radius: 8
            implicitWidth: 36
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: "🥭"
              font.pixelSize: 16
            }
          }

          // Workspaces
          Rectangle {
            color: root.surface0
            radius: 8
            implicitHeight: 28
            
            Row {
              anchors.centerIn: parent
              spacing: 6
              
              Repeater {
                model: [1, 2, 3, 4, 5]
                
                Rectangle {
                  width: 24
                  height: 20
                  radius: 5
                  color: modelData === 1 ? root.blue : root.surface1
                  
                  Text {
                    anchors.centerIn: parent
                    text: ["I", "II", "III", "IV", "V"][modelData - 1]
                    color: modelData === 1 ? root.base : root.text
                    font.pixelSize: 10
                    font.bold: true
                  }
                }
              }
            }
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === CENTER: Window Title ===
        Rectangle {
          color: root.surface0
          radius: 8
          implicitHeight: 28
          Layout.maximumWidth: 400

          Text {
            anchors.centerIn: parent
            text: "Ghostty"
            color: root.subtext1
            font.pixelSize: 12
            elide: Text.ElideMiddle
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === RIGHT SECTION ===
        RowLayout {
          spacing: 8

          // System Info Group
          Rectangle {
            color: root.surface0
            radius: 8
            implicitHeight: 28

            Row {
              anchors.centerIn: parent
              spacing: 12

              // CPU
              Text {
                text: "💻 23%"
                color: root.peach
                font.pixelSize: 12
              }

              // Memory
              Text {
                text: "🧠 45%"
                color: root.lavender
                font.pixelSize: 12
              }
            }
          }

          // Volume
          Rectangle {
            color: root.surface0
            radius: 8
            implicitWidth: 70
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: "🔊 75%"
              color: root.blue
              font.pixelSize: 12
            }
          }

          // Battery
          Rectangle {
            color: root.surface0
            radius: 8
            implicitWidth: 80
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: "⚡ 85%"
              color: root.green
              font.pixelSize: 12
            }
          }

          // Clock
          Rectangle {
            color: root.blue
            radius: 8
            implicitWidth: 100
            implicitHeight: 28

            Text {
              id: clockText
              anchors.centerIn: parent
              text: "--:--"
              color: root.base
              font.pixelSize: 12
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
  }
}
