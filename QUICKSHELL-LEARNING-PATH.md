# Quickshell Learning Path: From Minimal to Full Desktop

This guide provides a progressive learning path for building your own Quickshell desktop, starting from the absolute basics and growing into a complete setup.

## Why Start Minimal?

- **Understand each component** before adding complexity
- **Debug easily** - when something breaks, you know what changed
- **Build confidence** - see working results at each step
- **Customize intentionally** - add only what you need

## Your Starting Point: The "default" Config

You already have an excellent minimal example in `quickshell-configs/default/`. This is a perfect starting point because it demonstrates:

1. ✅ Multi-screen support (Variants)
2. ✅ PanelWindow basics
3. ✅ Component separation (Bar, ClockWidget, Time)
4. ✅ System integration (SystemClock)
5. ✅ Singleton pattern (Time.qml)

### Test It First

```bash
# In your VM
quickshell -p ~/nixos-config/modules/home/quickshell-configs/default
```

You should see a simple bar at the top with the current time.

---

## Recommended Minimal Examples from the Community

If you want to explore other people's minimal configs for inspiration:

### 1. **Official Quickshell Examples**
The Quickshell repository has basic examples showing core concepts. Check their docs at https://quickshell.org/docs/

### 2. **Simple Bar Configurations**
Look for configs that start with just:
- A panel at top/bottom
- One or two widgets (clock, workspaces)
- Clean, commented code

### 3. **Your Own "default" Config** ⭐ Best Choice
Your existing config is already ideal because:
- It's already working in your environment
- It's properly structured with separate components
- You understand every line
- Easy to extend incrementally

---

## Learning Path: Progressive Examples

### Example 0: Hello World ✓ (Already Done)
**Location:** `quickshell-configs/default/`  
**Concepts:** Basic structure, PanelWindow, components, singleton pattern

**What it does:** Shows a simple bar with the current time

**Next step:** Add one more widget!

---

### Example 1: Two Widgets Side by Side
**Goal:** Add a static text label next to the clock

**What you'll learn:**
- Layout management (Row, Column)
- Multiple widgets
- Spacing and alignment

**Create:** Copy default and modify

```bash
cp -r quickshell-configs/default quickshell-configs/001-two-widgets
```

Then edit `Bar.qml` to add a Row layout:

```qml
import Quickshell
import QtQuick

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

      implicitHeight: 30

      // NEW: Use Row to arrange widgets horizontally
      Row {
        anchors.centerIn: parent
        spacing: 20

        Text {
          text: "🥭 MangoWM"
          color: "#cdd6f4"
          font.bold: true
        }

        ClockWidget {}
      }
    }
  }
}
```

**Test:**
```bash
quickshell -p ~/nixos-config/modules/home/quickshell-configs/001-two-widgets
```

---

### Example 2: Workspace Indicator (Static)
**Goal:** Show workspace number (hardcoded initially)

**What you'll learn:**
- Adding new components
- Text styling
- Building incrementally

**Create workspace indicator widget:**

```qml
// widgets/WorkspaceIndicator.qml
import QtQuick

Text {
  text: "WS: 1"
  color: "#cdd6f4"
  font.pixelSize: 14
}
```

Add it to your Bar.qml Row:
```qml
Row {
  anchors.centerIn: parent
  spacing: 20
  
  WorkspaceIndicator {}  // NEW
  Text { text: "🥭 MangoWM"; color: "#cdd6f4" }
  ClockWidget {}
}
```

---

### Example 3: Real Workspace Detection
**Goal:** Actually detect active workspace from MangoWM

**What you'll learn:**
- Process execution
- Command output parsing
- Event-driven updates

**Research needed:** Check if MangoWM has a CLI tool like `mangoctl` or IPC interface

**Pattern to use:**
```qml
import Quickshell.Io

Process {
  id: workspaceProc
  command: ["your-mango-command-here"]
  running: true
  
  stdout: StdioCollector {
    onStreamFinished: {
      // Parse the output and update workspace display
      console.log("Workspace info:", this.text)
    }
  }
}
```

---

### Example 4: System Tray Integration
**Goal:** Show system icons (network, volume, etc.)

**What you'll learn:**
- SystemTray widget
- Layout management with dynamic content
- Icon handling

**Key QML:**
```qml
import Quickshell.SystemTray

SystemTray {
  iconSize: 16
  spacing: 8
}
```

---

### Example 5: Battery & Network Status
**Goal:** Show battery percentage and WiFi status

**What you'll learn:**
- D-Bus integration (UPower, NetworkManager)
- Conditional rendering
- Icons and status indicators

**Pattern:**
```qml
Text {
  text: battery.available ? "🔋 " + battery.percent + "%" : ""
  visible: battery.available
}
```

---

### Example 6: Application Launcher Trigger
**Goal:** Keyboard shortcut to trigger launcher

**What you'll learn:**
- Global keybindings
- Process spawning
- Overlay windows

---

### Example 7: Complete Production Bar
**Goal:** Full-featured bar ready for daily use

**Features:**
- ✅ Dynamic workspaces
- ✅ Active window title
- ✅ System tray
- ✅ Battery, WiFi, Bluetooth
- ✅ Volume control
- ✅ Clock with date
- ✅ Notification indicator
- ✅ Custom theming

---

## How to Use This Learning Path

### Step-by-Step Workflow

1. **Start with default config**
   ```bash
   quickshell -p ~/nixos-config/modules/home/quickshell-configs/default
   ```

2. **Copy to new example directory**
   ```bash
   cp -r quickshell-configs/default quickshell-configs/001-two-widgets
   ```

3. **Make ONE small change**
   - Add a workspace indicator
   - Change the color
   - Add spacing
   - Try a different layout

4. **Test immediately**
   ```bash
   quickshell -p ~/nixos-config/modules/home/quickshell-configs/001-two-widgets
   ```

5. **Commit when it works**
   ```bash
   git add modules/home/quickshell-configs/001-two-widgets/
   git commit -m "Add two-widget example with Row layout"
   ```

6. **Switch to it in quickshell.nix**
   Edit `modules/home/quickshell.nix`:
   ```nix
   activeExample = "001-two-widgets";
   ```

7. **Rebuild and test**
   ```bash
   make vm-build
   make vm-run
   # Quickshell will auto-start with systemd if enabled
   ```

8. **Repeat** with the next feature

---

## Update Your quickshell.nix (Already Done!)

I've updated your `quickshell.nix` to support easy switching between examples:

```nix
# Change this to switch configs!
activeExample = "default";

configs = {
  default = ./quickshell-configs/default;
  transparency-blur = ./quickshell-configs/026-transparency-blur;
  # Add more as you create them
};
```

Now you can:
1. Create a new example directory
2. Change `activeExample` in quickshell.nix
3. Rebuild
4. Test

---

## Key Concepts to Master

### QML Basics
- **Item**: Base visual element
- **Text**: Display text
- **Rectangle**: Colored box
- **Row/Column**: Layout containers
- **anchors**: Positioning system

### Quickshell Specifics
- **PanelWindow**: Edge-attached window
- **ShellRoot**: Root element for shells
- **Variants**: Create multiple instances (one per screen)
- **Screen**: Monitor information
- **SystemClock**: Time source
- **Singleton**: Single-instance objects

### Patterns
- **Component separation**: Keep widgets in separate files
- **Property binding**: Reactive updates
- **Signal/slot**: Event handling
- **Process execution**: Run commands
- **StdioCollector**: Capture command output

---

## Common Pitfalls to Avoid

❌ **Don't** add too many features at once  
✅ **Do** test after each small change

❌ **Don't** copy complex configs you don't understand  
✅ **Do** build up from simple examples

❌ **Don't** ignore error messages  
✅ **Do** read QML errors carefully - they're helpful!

❌ **Don't** try to match someone else's config exactly  
✅ **Do** build what YOU need

---

## Resources

### Official Documentation
- Quickshell Docs: https://quickshell.org/docs/
- Qt6 QML Docs: https://doc.qt.io/qt-6/qmltypes.html

### Your Local Examples
- Default config: `modules/home/quickshell-configs/default/`
- Transparency example: `modules/home/quickshell-configs/026-transparency-blur/`

### MangoWM Integration
- Check MangoWM documentation for IPC/API
- Look for CLI tools like `mangoctl`
- Examine workspace/window events

---

## Suggested Next Steps

1. **Today:** Test your default config to make sure it works
2. **Tomorrow:** Create "001-two-widgets" and add a second widget
3. **This week:** Experiment with layouts (Row, Column, Grid)
4. **Next week:** Try to integrate with MangoWM for workspace detection
5. **Ongoing:** Add one feature per week, document what you learn

Remember: The goal is to **understand** each piece, not to have the fanciest bar. Start minimal, grow gradually, and enjoy the learning process! 🚀
