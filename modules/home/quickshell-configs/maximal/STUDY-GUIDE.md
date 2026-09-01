# Quickshell Reference Study Guide

This directory (`quickshell-reference/`) contains the ekremx25/quickshell configuration for **study and reference only**. Don't use it directly - learn from it and build your own!

---

## How to Use This Reference

### ✅ DO:
- Read code to understand patterns
- Study how specific features are implemented
- Learn QML and Quickshell best practices
- Copy **ideas** (not code) into your own configs

### ❌ DON'T:
- Copy entire files into your config
- Try to run this directly (many dependencies missing)
- Use it as your primary shell (yet)
- Get overwhelmed by the complexity

---

## Study Path: From Simple to Complex

Start with simple modules and work your way up. Each module teaches specific concepts.

### Level 1: Basic Widgets (Start Here)

#### 1. Clock Widget
**Location:** `Modules/bar/ClockBlock/ClockBlock.qml`  
**Concepts:** Time formatting, basic text display, updates  
**Complexity:** ⭐ Very Simple

```bash
# Study this first
cat Modules/bar/ClockBlock/ClockBlock.qml
```

**What to look for:**
- How they get the current time
- How they format it
- How often it updates
- Styling approach

**Your task:** Create a simpler version in your `001-clock-widget/` example

---

#### 2. Battery Widget
**Location:** `Modules/bar/Battery/Battery.qml`  
**Concepts:** System status, conditional rendering, icons  
**Complexity:** ⭐⭐ Simple

```bash
cat Modules/bar/Battery/Battery.qml
cat Modules/bar/Battery/BatteryService.qml
```

**What to look for:**
- How they detect battery presence
- How they get battery percentage
- Icon changes based on state
- Charging vs discharging

**Your task:** Add battery status to your bar

---

### Level 2: Interactive Widgets

#### 3. Volume Control
**Location:** `Modules/bar/Volume/Volume.qml`  
**Concepts:** User interaction, sliders, system integration  
**Complexity:** ⭐⭐⭐ Medium

```bash
cat Modules/bar/Volume/Volume.qml
```

**What to look for:**
- Click handlers
- Slider implementation
- Audio system integration
- Popover pattern

**Your task:** Add clickable volume control

---

#### 4. Workspaces
**Location:** `Modules/bar/Workspaces/Workspaces.qml`  
**Concepts:** Compositor integration, dynamic content, events  
**Complexity:** ⭐⭐⭐ Medium

```bash
cat Modules/bar/Workspaces/Workspaces.qml
cat ../../Services/WorkspaceService.qml
```

**What to look for:**
- How they detect workspace changes
- Workspace number formatting
- Active vs inactive styling
- Scrolling/clicking to switch

**Your task:** Add basic workspace indicator

---

### Level 3: Complex Systems

#### 5. Bar Layout System
**Location:** `Modules/bar/Bar.qml`  
**Concepts:** Layout management, multiple sections, configuration  
**Complexity:** ⭐⭐⭐⭐ Advanced

```bash
cat Modules/bar/Bar.qml
```

**What to look for:**
- Left/center/right sections
- Module arrangement
- Spacing and sizing
- Configuration loading

**Your task:** Implement multi-section bar

---

#### 6. Notification System
**Location:** `Modules/bar/Notifications/`  
**Concepts:** Event handling, popups, history  
**Complexity:** ⭐⭐⭐⭐⭐ Complex

```bash
ls Modules/bar/Notifications/
cat Services/Notifications.qml
```

**What to look for:**
- Notification reception
- Display logic
- Dismissal handling
- History management

**Your task:** Skip for now - come back later

---

## Key Files to Understand

### Entry Point
**File:** `shell.qml`  
**Purpose:** Application bootstrap, staged loading  
**Study when:** You understand basic widgets

Key concept: They use `Loader` components with timers to spread startup cost.

---

### Services Layer
**Directory:** `Services/`  
**Purpose:** Backend logic, system integration  

Important services:
- `Time.qml` - Time management
- `Theme.qml` - Color theming
- `CompositorService.qml` - WM detection
- `Mango.qml` - MangoWM integration

---

### Configuration
**Files:** 
- `bar_config.json` - Bar layout
- `theme_config.json` - Theme settings
- `dock_config.json` - Dock behavior

These show how they persist user preferences.

---

## Practical Study Sessions

### Session 1: Understanding Time Display (30 min)

```bash
# 1. Look at their implementation
cat quickshell-reference/Services/Time.qml
cat quickshell-reference/Modules/bar/ClockBlock/ClockBlock.qml

# 2. Compare with yours
cat ../quickshell-configs/default/Time.qml
cat ../quickshell-configs/default/ClockWidget.qml

# 3. Note differences
#    - Do they use different formatting?
#    - Different update mechanism?
#    - Better error handling?

# 4. Improve your version if needed
nvim ../quickshell-configs/default/Time.qml
```

---

### Session 2: Learning Layout Patterns (45 min)

```bash
# 1. Study their bar structure
cat quickshell-reference/Modules/bar/Bar.qml

# 2. Focus on:
#    - How sections are arranged
#    - How modules are added/removed
#    - Spacing between elements

# 3. Try implementing Row layout in your config
mkdir -p ../quickshell-configs/002-row-layout
cp -r ../quickshell-configs/default/* ../quickshell-configs/002-row-layout/

# 4. Edit Bar.qml to use Row with multiple widgets
nvim ../quickshell-configs/002-row-layout/Bar.qml
```

---

### Session 3: Understanding Service Pattern (60 min)

```bash
# 1. Look at a simple service
cat quickshell-reference/Services/Time.qml

# 2. Notice:
#    - Singleton pattern
#    - Property exports
#    - Update mechanism

# 3. Create your own service
mkdir -p ../quickshell-configs/003-custom-service
# Create a WeatherService.qml or similar
```

---

## Common Patterns to Learn

### 1. Singleton Services
```qml
// Pattern seen in Services/Time.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property string currentTime: formatTime(clock.date)
  
  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
  
  function formatTime(date) {
    return Qt.formatDateTime(date, "hh:mm")
  }
}
```

**Learn:** How to create reusable, globally-accessible services

---

### 2. Component Separation
```
Module/
├── MainComponent.qml      # UI
├── Service.qml            # Backend logic
└── Helper.qml             # Utility functions
```

**Learn:** Clean separation of concerns

---

### 3. Staged Loading
```qml
// From shell.qml
Loader { active: true; source: "CriticalService.qml" }

Timer {
  interval: 300
  onTriggered: loader2.active = true
}
```

**Learn:** Performance optimization for complex shells

---

### 4. Variants for Multi-Screen
```qml
Variants {
  model: Quickshell.screens
  delegate: Component {
    PanelWindow {
      required property var modelData
      screen: modelData
      // ...
    }
  }
}
```

**Learn:** Creating per-screen instances

---

## Notes Template

When studying a module, fill out this template:

```markdown
# Module: [Name]

## Location
`path/to/module.qml`

## Purpose
What does this do?

## Key Concepts
- Concept 1
- Concept 2

## Implementation Details
How does it work?

## Dependencies
What other files does it need?

## Simplification Ideas
How could I make a simpler version?

## My Implementation Plan
Steps to build my own version
```

---

## Quick Reference Commands

```bash
# Find all QML files
find quickshell-reference -name "*.qml" | head -20

# Search for specific patterns
grep -r "PanelWindow" quickshell-reference/Modules/

# Check file size (complexity indicator)
wc -l quickshell-reference/Modules/bar/*/ *.qml

# View directory structure
tree quickshell-reference/Modules/bar/ -L 2
```

---

## When to Move On

You're ready to move from reference to building when:

✅ You can explain how 3+ modules work  
✅ You've created 2+ simplified versions  
✅ You understand the service pattern  
✅ You can predict where to find specific features  
✅ You're confident modifying your own configs

---

## Next Steps After Studying

1. **Week 1-2:** Study 2-3 simple modules
2. **Week 3-4:** Build simplified versions
3. **Month 2:** Consider integrating one complete module
4. **Month 3+:** Decide if you want full integration

Remember: The goal is understanding, not copying! 🎓
