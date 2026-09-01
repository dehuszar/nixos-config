// MINIMAL CONFIG - Just the essentials
// Purpose: Basic bar for daily use with MangoWM
// Features: Workspaces, Clock, System controls

import QtQuick
import Quickshell

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

      // Simple two-item layout
      Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        // LEFT: Workspaces
        Text {
          text: "WS: 1"
          color: "#cdd6f4"
          font.pixelSize: 13
          font.bold: true
        }
      }
      
      // RIGHT: Clock (positioned separately)
      Text {
        id: clockText
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: "--:--"
        color: "#cdd6f4"
        font.pixelSize: 13
        
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
