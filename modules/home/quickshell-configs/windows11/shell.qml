// WINDOWS 11-INSPIRED THEME - Centered taskbar style
// Purpose: Windows 11-like centered bar with modern aesthetics
// Features: Centered app icons, right system tray, left workspaces

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
        bottom: true  // Bottom like Windows taskbar
        left: true
        right: true
      }

      implicitHeight: 48

      // Background with acrylic effect simulation
      Rectangle {
        anchors.fill: parent
        color: "#f3f3f3"
        
        Rectangle {
          anchors.fill: parent
          color: "#ffffff"
          opacity: 0.5
        }
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        // === LEFT: Workspaces (minimal) ===
        Row {
          spacing: 4

          Repeater {
            model: [1, 2, 3, 4]

            Rectangle {
              width: 36
              height: 36
              radius: 4
              color: modelData === 1 ? "#0078d4" : "transparent"

              Text {
                anchors.centerIn: parent
                text: modelData
                color: modelData === 1 ? "#ffffff" : "#000000"
                font.pixelSize: 12
                font.bold: true
              }
            }
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === CENTER: App Icons (Windows-style) ===
        Row {
          spacing: 4

          // Start button
          Rectangle {
            width: 40
            height: 40
            radius: 4
            color: "#0078d4"

            Text {
              anchors.centerIn: parent
              text: "⊞"
              color: "#ffffff"
              font.pixelSize: 20
            }
          }

          // Search
          Rectangle {
            width: 40
            height: 40
            radius: 4
            color: "transparent"

            Text {
              anchors.centerIn: parent
              text: "🔍"
              font.pixelSize: 18
            }
          }

          // Task View
          Rectangle {
            width: 40
            height: 40
            radius: 4
            color: "transparent"

            Text {
              anchors.centerIn: parent
              text: "📋"
              font.pixelSize: 18
            }
          }

          // Separator
          Rectangle {
            width: 1
            height: 32
            color: "#d1d1d1"
          }

          // Pinned apps
          Rectangle {
            width: 40
            height: 40
            radius: 4
            color: "#e5e5e5"

            Text {
              anchors.centerIn: parent
              text: "📁"
              font.pixelSize: 18
            }

            // Active indicator
            Rectangle {
              anchors.bottom: parent.bottom
              anchors.bottomMargin: 2
              anchors.horizontalCenter: parent.horizontalCenter
              width: 16
              height: 3
              color: "#0078d4"
              radius: 1.5
            }
          }

          Rectangle {
            width: 40
            height: 40
            radius: 4
            color: "transparent"

            Text {
              anchors.centerIn: parent
              text: "🌐"
              font.pixelSize: 18
            }
          }

          Rectangle {
            width: 40
            height: 40
            radius: 4
            color: "transparent"

            Text {
              anchors.centerIn: parent
              text: "💬"
              font.pixelSize: 18
            }
          }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === RIGHT: System Tray ===
        Row {
          spacing: 8

          // Show desktop button
          Rectangle {
            width: 4
            height: 40
            color: "#d1d1d1"
          }

          // System icons
          Column {
            spacing: 2

            Row {
              spacing: 8

              Text { text: "🔊"; font.pixelSize: 14 }
              Text { text: "📶"; font.pixelSize: 14 }
              Text { text: "🔋"; font.pixelSize: 14 }
            }

            Text {
              id: timeText
              text: ""
              color: "#000000"
              font.pixelSize: 11
              
              Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                  var now = new Date()
                  timeText.text = Qt.formatTime(now, "h:mm a") + "\n" + Qt.formatDate(now, "M/d/yyyy")
                }
              }
            }
          }

          // Notification center
          Rectangle {
            width: 40
            height: 40
            radius: 4
            color: "transparent"

            Text {
              anchors.centerIn: parent
              text: "🔔"
              font.pixelSize: 16
            }
          }
        }
      }
    }
  }
}
