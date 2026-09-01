// BASIC CONFIG - Essential desktop functionality
// Purpose: Functional bar for daily work
// Features: Workspaces, window title, system tray, volume, battery, clock

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

      implicitHeight: 36

      RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 8

        // === LEFT SECTION ===
        RowLayout {
          spacing: 12

          // Workspaces (static for now - will add dynamic later)
          Rectangle {
            color: "#313244"
            radius: 6
            implicitWidth: 120
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: "WS: 1  2  3  4  5"
              color: "#cdd6f4"
              font.pixelSize: 12
              font.family: "monospace"
            }
          }

          // Active window title (placeholder)
          Text {
            text: "No active window"
            color: "#a6adc8"
            font.pixelSize: 12
            elide: Text.ElideRight
            Layout.maximumWidth: 300
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === RIGHT SECTION ===
        RowLayout {
          spacing: 10

          // System Tray placeholder
          Rectangle {
            color: "#313244"
            radius: 6
            implicitWidth: 80
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: "🔔 Tray"
              color: "#cdd6f4"
              font.pixelSize: 12
            }
          }

          // Volume
          Rectangle {
            color: "#313244"
            radius: 6
            implicitWidth: 60
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: "🔊 75%"
              color: "#cdd6f4"
              font.pixelSize: 12
            }
          }

          // Battery
          Rectangle {
            color: "#313244"
            radius: 6
            implicitWidth: 70
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: "🔋 85%"
              color: "#cdd6f4"
              font.pixelSize: 12
            }
          }

          // Clock
          Rectangle {
            color: "#313244"
            radius: 6
            implicitWidth: 90
            implicitHeight: 28

            Text {
              id: clockText
              anchors.centerIn: parent
              text: "--:--"
              color: "#cdd6f4"
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
