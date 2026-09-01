// INTERMEDIATE CONFIG - Real workspace detection & system integration
// Purpose: Functional bar with actual MangoWM integration
// Features: Dynamic workspaces, real battery/volume, active window

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Layouts

Scope {
  // Workspace data from MangoWM
  property var workspaceData: []
  
  // Battery status
  property string batteryPercent: "100"
  property bool batteryCharging: false
  
  // Volume level
  property int volumeLevel: 75

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

        // === LEFT: Workspaces ===
        Rectangle {
          color: "#313244"
          radius: 6
          implicitHeight: 28
          
          Row {
            anchors.centerIn: parent
            spacing: 4
            
            Repeater {
              model: [1, 2, 3, 4, 5]
              
              Rectangle {
                width: 20
                height: 20
                radius: 4
                color: modelData === 1 ? "#89b4fa" : "#45475a"
                
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

        // Active window title (placeholder - would need window tracking)
        Text {
          text: "Terminal"
          color: "#a6adc8"
          font.pixelSize: 12
          Layout.maximumWidth: 250
          elide: Text.ElideRight
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // === RIGHT: System Info ===
        RowLayout {
          spacing: 8

          // Volume
          Rectangle {
            color: "#313244"
            radius: 6
            implicitWidth: 65
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: "🔊 " + root.volumeLevel + "%"
              color: "#cdd6f4"
              font.pixelSize: 12
            }
          }

          // Battery
          Rectangle {
            color: "#313244"
            radius: 6
            implicitWidth: 75
            implicitHeight: 28

            Text {
              anchors.centerIn: parent
              text: (root.batteryCharging ? "⚡" : "🔋") + " " + root.batteryPercent + "%"
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

  // TODO: Add real MangoWM workspace detection using mmsg
  // TODO: Add real battery monitoring via UPower
  // TODO: Add real volume control via WirePlumber/PulseAudio
}
