// GNOME-INSPIRED THEME - Top bar with activities and system menu
// Purpose: GNOME-like top bar with clean design
// Features: Activities button, centered clock, right system menu

import QtQuick
import Quickshell
import Quickshell.Layouts

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

      // Dark background
      Rectangle {
        anchors.fill: parent
        color: "#1e1e1e"
        opacity: 0.95
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // === LEFT: Activities ===
        Rectangle {
          color: "transparent"
          implicitWidth: 100
          implicitHeight: 32

          Text {
            anchors.centerIn: parent
            text: "Activities"
            color: "#ffffff"
            font.pixelSize: 13
            font.weight: Font.Medium
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === CENTER: Date & Time ===
        Rectangle {
          color: "transparent"
          implicitHeight: 32

          Text {
            id: dateTimeText
            anchors.centerIn: parent
            text: ""
            color: "#ffffff"
            font.pixelSize: 13
            font.weight: Font.Medium

            Timer {
              interval: 1000
              running: true
              repeat: true
              triggeredOnStart: true
              onTriggered: {
                var now = new Date()
                dateTimeText.text = Qt.formatDate(now, "EEE MMM d") + "  " + Qt.formatTime(now, "HH:mm")
              }
            }
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === RIGHT: System Menu ===
        Row {
          spacing: 12

          // Network
          Text {
            text: "📶 Wired"
            color: "#ffffff"
            font.pixelSize: 12
          }

          // Volume
          Text {
            text: "🔊 75%"
            color: "#ffffff"
            font.pixelSize: 12
          }

          // Power/Battery
          Text {
            text: "⚡ 85%"
            color: "#ffffff"
            font.pixelSize: 12
          }

          // System menu indicator
          Rectangle {
            width: 60
            height: 24
            radius: 4
            color: "#ffffff"
            opacity: 0.1

            Text {
              anchors.centerIn: parent
              text: "▼"
              color: "#ffffff"
              font.pixelSize: 10
            }
          }
        }
      }
    }
  }
}
