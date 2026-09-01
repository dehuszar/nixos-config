// MACOS-INSPIRED THEME - Clean, minimal aesthetic
// Purpose: macOS-like bar with blur and transparency
// Features: Centered clock, left workspaces, right system tray

import QtQuick
import Quickshell
import Quickshell.Layouts
import QtQuick.Effects

Scope {
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

      implicitHeight: 32
      color: "transparent"

      // Blurred background
      Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        opacity: 0.7

        layer.enabled: true
        layer.effect: MultiEffect {
          blurEnabled: true
          blurMax: 32
          blur: 0.5
        }
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 16

        // === LEFT: Workspaces (Pill-shaped) ===
        Rectangle {
          color: "#000000"
          opacity: 0.08
          radius: 14
          implicitHeight: 26

          Row {
            anchors.centerIn: parent
            spacing: 8

            Repeater {
              model: [1, 2, 3, 4]

              Rectangle {
                width: 18
                height: 18
                radius: 9
                color: modelData === 1 ? "#007AFF" : "transparent"
                border.width: 1.5
                border.color: modelData === 1 ? "#007AFF" : "#86868b"

                Text {
                  anchors.centerIn: parent
                  text: modelData
                  color: modelData === 1 ? "#ffffff" : "#86868b"
                  font.pixelSize: 10
                  font.bold: true
                }
              }
            }
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === CENTER: Date & Time ===
        Row {
          spacing: 12

          Text {
            id: dateText
            text: ""
            color: "#000000"
            font.pixelSize: 13
            font.weight: Font.Medium

            Timer {
              interval: 1000
              running: true
              repeat: true
              triggeredOnStart: true
              onTriggered: {
                var now = new Date()
                dateText.text = Qt.formatDate(now, "EEE MMM d")
              }
            }
          }

          Text {
            id: timeText
            text: ""
            color: "#000000"
            font.pixelSize: 13
            font.weight: Font.Medium

            Timer {
              interval: 1000
              running: true
              repeat: true
              triggeredOnStart: true
              onTriggered: {
                timeText.text = Qt.formatTime(new Date(), "h:mm a")
              }
            }
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === RIGHT: System Icons ===
        Row {
          spacing: 12

          // WiFi
          Text {
            text: "📶"
            font.pixelSize: 14
          }

          // Battery
          Text {
            text: "🔋 85%"
            font.pixelSize: 13
            color: "#000000"
          }

          // Control Center icon
          Rectangle {
            color: "#000000"
            opacity: 0.08
            radius: 13
            width: 26
            height: 26

            Text {
              anchors.centerIn: parent
              text: "⚙️"
              font.pixelSize: 14
            }
          }
        }
      }
    }
  }
}
