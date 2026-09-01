// Enhanced ClockWidget - Inspired by ekremx25 but simplified
// 
// Learning goals:
// - Date formatting
// - Multiple text elements
// - Layout with Row
// - Timer-based updates

import QtQuick
import QtQuick.Layouts

Row {
    spacing: 15
    
    // Date display
    Text {
        id: dateText
        text: ""
        color: "#cdd6f4"
        font.pixelSize: 14
        font.bold: true
        
        // Calendar icon (using emoji instead of Nerd Font for simplicity)
        Text {
            text: "📅 "
            anchors.left: parent.left
            anchors.leftMargin: -20
        }
    }
    
    // Separator
    Rectangle { 
        width: 1
        height: 16 
        color: "#585b70"
    }
    
    // Time display
    Text {
        id: timeText
        text: ""
        color: "#cdd6f4"
        font.pixelSize: 14
        font.bold: true
        
        // Clock icon
        Text {
            text: "🕐 "
            anchors.left: parent.left
            anchors.leftMargin: -20
        }
    }
    
    // Update every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            var now = new Date()
            timeText.text = Qt.formatTime(now, "HH:mm")
            dateText.text = Qt.formatDate(now, "d MMM ddd")
        }
    }
}
