# Kartik317 Quickshell Configuration (MangoWM Adapted)

**Original:** https://github.com/kartik317/Quickshell-configuration  
**Adapted for:** MangoWM (removed Hyprland dependencies)

---

## Overview

This is a modern, pill-styled bar configuration inspired by kartik317's excellent Quickshell setup. I've adapted it to work with MangoWM instead of Hyprland by removing Hyprland-specific dependencies.

---

## Features

### ✅ What Works
- **Modern pill-style design** - Rounded containers with semi-transparent backgrounds
- **Multi-screen support** - One bar per monitor via Variants
- **Workspace indicators** - Visual workspace display (static for now)
- **System info section** - CPU and RAM placeholders
- **Status indicators** - Network, battery, volume, clock
- **Clean layout** - Three-section design (left/center/right)

### ⚠️ What's Simplified
- **No Hyprland integration** - Original used `Quickshell.Hyprland` API
- **Static workspaces** - Not yet connected to MangoWM workspace events
- **Placeholder system info** - CPU/RAM values are hardcoded
- **No overlays/popups** - Removed app launcher, power menu, etc. (Hyprland-dependent)
- **No draggable clock** - Removed (used Hyprland APIs)

---

## Design Elements

### Layout Structure
```
┌───────────────────────────────────────────────────────────────────────┐
│ [🥭 | WS]  [Window Title]  [💻 🧠]  [📶 | 🔋 | 🔊 | 14:30]         │
└───────────────────────────────────────────────────────────────────────┘
```

### Color Scheme
Using Catppuccin Mocha palette:
- Background: `#1e1e2e` (dark blue-gray)
- Foreground: `#cdd6f4` (light blue-white)
- Accents: Blue, lavender, peach, green
- Semi-transparent pills: 85% opacity

### Pill Containers
Each section is wrapped in a rounded rectangle ("pill"):
- Border radius: 12px
- Background: Semi-transparent dark
- Spacing: 8px between elements
- Margins: 4px from edges

---

## File Structure

```
kartik317/
├── shell.qml              # Entry point (simplified)
├── bar/
│   ├── Bar.qml            # Main bar component (adapted)
│   └── ...                # Other original files (not used yet)
├── theme/
│   └── Colors.qml         # Color palette (Catppuccin)
├── state/                 # Original state files (not used)
├── widgets/               # Original widgets (not used)
└── ...                    # Other directories (preserved for reference)
```

---

## How It Compares to Original

| Feature | Original (Hyprland) | Adapted (MangoWM) |
|---------|-------------------|------------------|
| Workspaces | Dynamic via Hyprland API | Static (visual only) |
| Window title | Real-time via hyprctl | Placeholder text |
| System info | Live CPU/RAM monitoring | Hardcoded percentages |
| App launcher | Full searchable launcher | Removed |
| Power menu | Lock/suspend/reboot/shutdown | Removed |
| Volume control | Interactive slider | Display only |
| Brightness control | Interactive slider | Removed |
| Wallpaper switcher | Live thumbnails | Removed |
| Draggable clock | Floating overlay | Removed |
| Media controls | MPRIS integration | Removed |

---

## Customization

### Change Colors
Edit `theme/Colors.qml`:
```qml
readonly property color colBg: "#1e1e2e"  // Change background
readonly property color colFg: "#cdd6f4"  // Change text color
```

### Adjust Pill Appearance
In `bar/Bar.qml`:
```qml
readonly property real pillRadius: 12      // Roundness
readonly property color pillBg: Qt.alpha("#1e1e2e", 0.85)  // Opacity
```

### Modify Layout
Edit the `RowLayout` sections in `bar/Bar.qml`:
- Reorder sections
- Add/remove widgets
- Change spacing

### Change Bar Position
In `shell.qml`, modify PanelWindow anchors:
```qml
anchors {
    bottom: true  // Move to bottom
    left: true
    right: true
}
```

---

## Future Enhancements

To make this fully functional with MangoWM:

### 1. Dynamic Workspaces
```qml
// Use mmsg to get workspace data from MangoWM
Process {
    id: workspaceProc
    command: ["mmsg", "-g", "-t"]
    // Parse output and update workspace indicators
}
```

### 2. Real System Monitoring
```qml
// CPU usage
Process {
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}'"]
}

// Memory usage
Process {
    command: ["free", "-m"]
}
```

### 3. Active Window Title
```qml
// Get active window from MangoWM
Process {
    command: ["mmsg", "-g", "-w"]  // Check if this works
}
```

### 4. Real Battery Status
```qml
// UPower integration
DBusProxy {
    service: "org.freedesktop.UPower"
    path: "/org/freedesktop/UPower/devices/DisplayDevice"
    // Get percentage and charging state
}
```

### 5. Volume Control
```qml
// WirePlumber/PulseAudio integration
Process {
    command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
}
```

---

## Testing

Test this config:
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/kartik317
```

You should see:
- A bar at the top of the screen
- Mango emoji on the left
- 5 workspace indicators (1-5, first one highlighted)
- "No active window" in the center
- System info placeholders
- Status icons on the right
- Clock showing current time

---

## Comparison with Other Configs

### vs minimal
- **kartik317**: Modern pill design, multiple sections, themed
- **minimal**: Ultra-simple, two items, no styling

### vs catppuccin
- **kartik317**: Pill containers, structured sections, more widgets
- **catppuccin**: Flat design, color-focused, simpler layout

### vs macos
- **kartik317**: Multiple pill groups, system info section
- **macos**: Frosted glass blur, centered clock, minimal icons

### vs basic
- **kartik317**: Polished design, consistent theming, pill aesthetic
- **basic**: Functional but plain, rectangular boxes

---

## Why This as Default?

I set this as your default because:

✅ **Professional appearance** - Looks polished out of the box  
✅ **Good structure** - Well-organized code to learn from  
✅ **Balanced complexity** - More than minimal, less than maximal  
✅ **Easy to customize** - Clear separation of concerns  
✅ **Modern design** - Pill-style is trendy and clean  
✅ **Learning potential** - Can gradually add real functionality  

---

## Next Steps

1. **Test it** - Make sure it displays correctly
2. **Customize colors** - Adjust to your preference
3. **Add real data** - Replace placeholders with actual system info
4. **Integrate MangoWM** - Connect to workspace/window events
5. **Add features** - Bring back useful components from original

---

## Original Repository Features (For Reference)

The original kartik317 config includes:
- App launcher with search
- System monitor popup
- Volume/brightness controls
- Power menu
- Wallpaper switcher
- Draggable clock overlay
- Voice assistant panel
- Live wallpaper support

These were removed because they depend on Hyprland-specific APIs. You could reimplement them for MangoWM if desired!

---

## Credits

- **Original author:** kartik317
- **Original repo:** https://github.com/kartik317/Quickshell-configuration
- **Adaptation:** Modified for MangoWM compatibility
- **Theme:** Catppuccin Mocha color palette

Enjoy your new default bar! 🥭✨
