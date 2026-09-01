# Final Solution: Launching GUI Apps from Quickshell

## The Problem

Quickshell's `Process` component manages process lifecycle - when you set `running = false` or when Quickshell cleans up, it terminates child processes. This works great for short commands but poorly for GUI apps that need to persist.

## Why Previous Attempts Failed

| Method | Result | Why |
|--------|--------|-----|
| `["wiremix"]` | Process starts, no window | Quickshell keeps it attached |
| `["sh", "-c", "exec wiremix"]` | Same issue | Still managed by Quickshell |
| `["nohup", "wiremix"]` | Process detaches, no display | Loses Wayland context |
| `["setsid", "wiremix"]` | Unknown | May work, may not |

## The Real Solution

You have **three viable options**:

---

## Option 1: Use MangoWM Keybinds (Recommended) ⭐

**Why this is best:**
- MangoWM properly handles GUI app launching
- Apps get full Wayland session context
- No Quickshell process management issues
- Cleaner separation of concerns

**Implementation:**

Edit your MangoWM config (`modules/home/mango.nix`):

```nix
wayland.windowManager.mango = {
  enable = true;
  settings = {
    bind = [
      # Existing bindings...
      "Super,r,reload_config"
      "Super,m,quit"
      
      # App launchers
      "Super+Return,spawn,ghostty"        # Terminal
      "Super+W,spawn,wiremix"             # Audio control  
      "Super+N,spawn,nmtui"               # Network (in terminal)
      "Super+E,spawn,thunar"              # File manager (example)
    ];
  };
};
```

**In the bar:** Keep the icons as visual indicators only (remove MouseArea onClicked or make them show tooltips).

**Pros:**
✅ Reliable app launching  
✅ Proper Wayland integration  
✅ Standard workflow (keybinds)  
✅ No Quickshell hacks  

**Cons:**
❌ Can't click bar icons to launch  
❌ Need to remember keybinds  

---

## Option 2: Wrapper Script with Full Detachment

Create launcher scripts that fully detach from Quickshell:

**Step 1:** Create `~/bin/qs-launch.sh`

```bash
#!/usr/bin/env bash
# Quickshell-safe app launcher
# Fully detaches the app from Quickshell's process tree

APP="$1"
shift

if [ -z "$APP" ]; then
    echo "Usage: qs-launch.sh <app> [args...]"
    exit 1
fi

# Export environment variables explicitly
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DISPLAY="${DISPLAY:-}"

# Double-fork to fully detach
(
    setsid "$APP" "$@" > /dev/null 2>&1 &
    disown
) &

exit 0
```

**Step 2:** Make it executable

```bash
chmod +x ~/bin/qs-launch.sh
```

**Step 3:** Use in Bar.qml

```qml
Process {
    id: launchTerminal
    command: ["/home/sam/bin/qs-launch.sh", "ghostty"]
}

Process {
    id: launchWiremix
    command: ["/home/sam/bin/qs-launch.sh", "wiremix"]
}

Process {
    id: launchImpala
    command: ["/home/sam/bin/qs-launch.sh", "nmtui"]
}
```

**Pros:**
✅ Clickable bar icons  
✅ Fully detached processes  
✅ Works with any app  

**Cons:**
❌ Extra script to maintain  
❌ May still have timing issues  
❌ Less reliable than keybinds  

---

## Option 3: Hybrid Approach (Best of Both)

Use keybinds for primary launching, bar clicks as alternative:

**MangoWM keybinds:**
```nix
bind = [
  "Super+Return,spawn,ghostty"
  "Super+W,spawn,wiremix"
  "Super+N,spawn,nmtui"
];
```

**Bar.qml with tooltips:**
```qml
Text {
    text: "🔊 75%"
    
    ToolTip {
        visible: mouseArea.containsMouse
        text: "Click or press Super+W"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            // Try to launch, but keybind is primary
            launchWiremix.running = true
        }
    }
}
```

---

## Testing Each Option

### Test Option 1 (Keybinds)
1. Add keybinds to mango.nix
2. Rebuild: `make vm-build && make vm-run`
3. Press `Super+W` - wiremix should open
4. Press `Super+Return` - ghostty should open

### Test Option 2 (Wrapper Script)
1. Create `~/bin/qs-launch.sh`
2. Update Bar.qml commands
3. Rebuild and test clicking icons
4. Check if windows appear

### Test Option 3 (Hybrid)
1. Implement both
2. Use whichever feels better

---

## My Recommendation

**Use Option 1 (MangoWM Keybinds)** for these reasons:

1. **Reliability**: MangoWM is designed to launch apps properly
2. **Simplicity**: No hacks or workarounds needed
3. **Standard**: Keybinds are the normal way to launch apps on Wayland
4. **Maintainability**: Less custom code to break

**Keep the bar icons** as:
- Visual status indicators (show current volume %, battery %, etc.)
- Future interactive elements (click to show popups, not launch apps)
- Aesthetic elements

**Example evolution:**
- Today: Icons show status, keybinds launch apps
- Future: Click volume icon → shows volume slider popup (not launch wiremix)
- Future: Click battery → shows power settings popup

This is how professional shells work (GNOME, KDE, macOS) - the bar shows status and provides quick controls, but doesn't launch full applications.

---

## Implementation: Switch to Keybinds

**Step 1:** Edit `modules/home/mango.nix`

```nix
bind = [
  "Super,r,reload_config"
  "Super,m,quit"
  "Alt,q,killclient"
  "Alt,f,togglefullscreen"
  "Alt,Left,focusdir,left"
  "Alt,Right,focusdir,right"
  "Alt,Up,focusdir,up"
  "Alt,Down,focusdir,down"
  "Super,Return,spawn,ghostty"
  
  // Add these:
  "Super+W,spawn,wiremix"
  "Super+N,spawn,nmtui"
  "Super+E,spawn,thunar"  // File manager
];
```

**Step 2:** Simplify Bar.qml (remove Process declarations, keep visual elements)

Or keep them but accept they might not work perfectly.

**Step 3:** Rebuild and test keybinds

---

## Bottom Line

Quickshell's Process component ≠ proper GUI app launcher. It's meant for:
- Short commands (date, whoami, etc.)
- Background services
- Data collection

Not for:
- Long-running GUI applications
- Apps that need full Wayland session

Use MangoWM (or your compositor) for app launching. Use Quickshell for status display and quick controls.
