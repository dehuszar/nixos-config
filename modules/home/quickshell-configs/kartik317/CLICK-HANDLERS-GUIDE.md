# Adding Click Handlers to Quickshell Bar

## ✅ What I Added

I've added interactive click handlers to your bar icons:

| Icon | Click Action | Application |
|------|-------------|-------------|
| 🥭 Mango Logo | Opens terminal | `ghostty` |
| 📶 Network | Opens network manager | `impala` |
| 🔊 Volume | Opens audio control | `wiremix` |
| 🔋 Battery | (Placeholder for settings) | - |

### Visual Feedback
- **Hover effects**: Icons change color when you mouse over them
- **Cursor change**: Pointer cursor appears on hover
- **Console logging**: Actions are logged for debugging

---

## 🔧 How It Works

### Basic Pattern

```qml
Text {
    text: "🔊"
    
    MouseArea {
        anchors.fill: parent          // Cover the entire text
        cursorShape: Qt.PointingHandCursor  // Show hand cursor
        hoverEnabled: true            // Enable hover events
        
        // Hover effect - change color
        onEntered: parent.color = root.colLavender
        onExited: parent.color = root.colBlue
        
        // Click action - launch application
        onClicked: {
            console.log("Opening app")
            launchProcess.run()
        }
        
        // Process to run
        Process {
            id: launchProcess
            command: ["application-name"]
        }
    }
}
```

---

## 📝 Step-by-Step: Add Your Own Click Handler

### Example: Add Calendar Click Handler

Let's say you want to click the clock to open a calendar app.

#### Step 1: Find the Element
Locate the clock Text element in `bar/Bar.qml`:

```qml
// Clock
Text {
    id: clockText
    text: "--:--"
    ...
}
```

#### Step 2: Wrap with MouseArea

```qml
// Clock - Click to open calendar
Text {
    id: clockText
    text: "--:--"
    color: root.colFg
    font.pixelSize: root.fontSize
    font.family: root.fontFamily
    font.bold: true
    
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
            command: ["gnome-calendar"]  // or your preferred calendar app
        }
    }
    
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
```

#### Step 3: Test It

```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/kartik317
```

Click the clock - it should try to launch `gnome-calendar`!

---

## 🎨 Customization Options

### Change the Application

Just modify the `command` array:

```qml
Process {
    id: launchApp
    command: ["firefox"]           // Single command
    // or
    command: ["code", "--new-window"]  // Command with arguments
}
```

### Add Multiple Commands

Use `sh -c` to run complex commands:

```qml
Process {
    id: launchComplex
    command: ["sh", "-c", "ghostty --title 'My Terminal'"]
}
```

### Remove Hover Effect

If you don't want color changes:

```qml
MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    // Remove hoverEnabled and onEntered/onExited
    
    onClicked: {
        launchApp.run()
    }
}
```

### Add Animation on Click

```qml
onClicked: {
    // Animate scale
    parent.scale = 0.9
    timer.restart()
    launchApp.run()
}

Timer {
    id: timer
    interval: 150
    onTriggered: parent.scale = 1.0
}
```

---

## 💡 Common Use Cases

### 1. Open File Manager

```qml
onClicked: {
    launchFileManager.run()
}

Process {
    id: launchFileManager
    command: ["thunar"]  // or "nautilus", "dolphin", etc.
}
```

### 2. Take Screenshot

```qml
onClicked: {
    launchScreenshot.run()
}

Process {
    id: launchScreenshot
    command: ["grimblast", "copy", "screen"]
}
```

### 3. Lock Screen

```qml
onClicked: {
    launchLock.run()
}

Process {
    id: launchLock
    command: ["swaylock"]
}
```

### 4. Toggle Night Light

```qml
onClicked: {
    toggleNightLight.running = !toggleNightLight.running
}

Process {
    id: toggleNightLight
    command: ["gammastep", "-P"]  // Or your night light tool
}
```

### 5. Open Settings App

```qml
onClicked: {
    launchSettings.run()
}

Process {
    id: launchSettings
    command: ["xfce4-settings-manager"]  // or your DE's settings
}
```

---

## 🐛 Troubleshooting

### App Doesn't Launch

**Check 1:** Is the app installed?
```bash
which impala
which wiremix
```

**Check 2:** Does it work from terminal?
```bash
impala
wiremix
```

**Check 3:** Check console output
```bash
# Look for error messages in the terminal where you ran quickshell
```

**Check 4:** Verify command syntax
```qml
// Wrong:
command: "impala"  // String, not array

// Right:
command: ["impala"]  // Array of strings
```

### Hover Effect Not Working

Make sure you have:
```qml
hoverEnabled: true  // This is required!
```

### Cursor Doesn't Change

Ensure:
```qml
cursorShape: Qt.PointingHandCursor
```

---

## 🎯 Best Practices

### 1. Use Unique IDs
Each Process should have a unique `id`:
```qml
Process { id: launchWiremix }   // Good
Process { id: launchApp }       // Bad (generic)
```

### 2. Add Console Logging
Helps with debugging:
```qml
onClicked: {
    console.log("Launching:", command)
    launchApp.run()
}
```

### 3. Provide Visual Feedback
Always include hover effects so users know it's clickable:
```qml
onEntered: parent.color = highlightColor
onExited: parent.color = normalColor
```

### 4. Keep Commands Simple
Prefer direct commands over shell scripts when possible:
```qml
// Better:
command: ["firefox"]

// Avoid if possible:
command: ["sh", "-c", "firefox https://example.com && echo done"]
```

---

## 🚀 Advanced: Dynamic Content

### Show Running State

```qml
Text {
    id: volumeIcon
    text: "🔊"
    
    property bool isLaunching: false
    
    MouseArea {
        onClicked: {
            if (!volumeIcon.isLaunching) {
                volumeIcon.isLaunching = true
                volumeIcon.text = "⏳"  // Loading indicator
                launchWiremix.run()
                
                resetTimer.start()
            }
        }
    }
    
    Timer {
        id: resetTimer
        interval: 1000
        onTriggered: {
            volumeIcon.text = "🔊"
            volumeIcon.isLaunching = false
        }
    }
}
```

### Conditional Launching

```qml
onClicked: {
    if (someCondition) {
        launchApp1.run()
    } else {
        launchApp2.run()
    }
}
```

---

## 📚 Complete Example: System Info Widget

Here's a complete example with multiple clickable elements:

```qml
// System Info Pill with Clickable Elements
Rectangle {
    Layout.fillHeight: true
    Layout.preferredWidth: 320
    color: root.pillBg
    radius: root.pillRadius
    
    RowLayout {
        anchors.centerIn: parent
        spacing: 12
        
        // CPU - Click to open system monitor
        Text {
            id: cpuText
            text: "💻 25%"
            color: root.colPeach
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
                onEntered: parent.color = root.colRed
                onExited: parent.color = root.colPeach
                
                onClicked: {
                    console.log("Opening system monitor")
                    launchHtop.run()
                }
                
                Process {
                    id: launchHtop
                    command: ["ghostty", "-e", "htop"]
                }
            }
        }
        
        // RAM - Click to open memory info
        Text {
            id: ramText
            text: "🧠 45%"
            color: root.colMauve
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
                onEntered: parent.color = root.colPink
                onExited: parent.color = root.colMauve
                
                onClicked: {
                    console.log("Opening memory info")
                    launchFree.run()
                }
                
                Process {
                    id: launchFree
                    command: ["ghostty", "-e", "free -h"]
                }
            }
        }
    }
}
```

---

## 🎓 Summary

### To Add a Click Handler:

1. **Wrap** the Text/element with `MouseArea`
2. **Set** `anchors.fill: parent`
3. **Enable** hover with `hoverEnabled: true`
4. **Add** visual feedback (`onEntered`/`onExited`)
5. **Define** the action in `onClicked`
6. **Create** a `Process` with the command
7. **Test** it!

### Key Properties:

- `anchors.fill: parent` - Makes MouseArea cover the element
- `cursorShape: Qt.PointingHandCursor` - Shows hand cursor
- `hoverEnabled: true` - Enables hover events
- `onClicked` - The click handler
- `Process { command: [...] }` - What to run

Now you can make any icon in your bar interactive! 🎉
