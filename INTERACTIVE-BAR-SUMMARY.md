# Interactive Bar - Click Handlers Added ✅

## What's Now Clickable

| Element | Icon | Action | Application |
|---------|------|--------|-------------|
| **Mango Logo** | 🥭 | Open terminal | `ghostty` |
| **Network** | 📶 | Network manager | `impala` |
| **Volume** | 🔊 75% | Audio control | `wiremix` |
| **Battery** | 🔋 85% | (Ready for settings) | - |

## Visual Feedback

✅ **Hover Effects**: Icons change color when you mouse over them  
✅ **Cursor Change**: Hand cursor appears on hover  
✅ **Scale Animation**: Mango logo grows slightly on hover  
✅ **Console Logging**: Actions logged for debugging  

## How to Test

```bash
# Rebuild VM
make vm-build
make vm-run

# Or test directly in VM
quickshell -p ~/nixos-config/modules/home/quickshell-configs/kartik317
```

Then click the icons! They should launch the respective applications.

## Troubleshooting

### Apps Don't Launch?

Check if they're installed:
```bash
which ghostty
which impala  
which wiremix
```

If not installed, install them or change the command in `bar/Bar.qml`.

### Change the Application

Edit the `command` array in the Process block:

```qml
Process {
    id: launchApp
    command: ["your-app-name"]  // Change this
}
```

## Add More Click Handlers

See `CLICK-HANDLERS-GUIDE.md` for detailed instructions on adding click handlers to any element.

### Quick Example: Add Calendar to Clock

```qml
Text {
    id: clockText
    text: "--:--"
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        
        onEntered: parent.color = root.colBlue
        onExited: parent.color = root.colFg
        
        onClicked: {
            console.log("Opening calendar")
            launchCalendar.run()
        }
        
        Process {
            id: launchCalendar
            command: ["gnome-calendar"]  // Your calendar app
        }
    }
}
```

## Current Commands

All commands are defined inline in `bar/Bar.qml`:

- **Terminal**: `["ghostty"]`
- **Network**: `["impala"]`
- **Audio**: `["wiremix"]`

Change these to match your preferred applications!

---

Your bar is now interactive! 🎉
