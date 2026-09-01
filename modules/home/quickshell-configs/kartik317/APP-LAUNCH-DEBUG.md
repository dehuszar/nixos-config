# App Launch Debugging Guide

## Current Status

✅ **Wiremix** - Process starts (visible in btop) but window doesn't appear  
❌ **Impala** - Process doesn't start at all (iwd error)  
⚠️ **Ghostty** - Unknown (test needed)  
✅ **Battery hover** - Fixed with null checks  

---

## Issue 1: Wiremix Runs But No Window

**Problem**: Process is running (seen in btop) but no GUI appears.

**Cause**: Quickshell's Process management might be keeping the process attached to Quickshell's session, preventing it from creating a separate window.

### Solutions (Try in Order)

#### Solution A: Direct Execution (Current)
```qml
Process {
    id: launchWiremix
    command: ["wiremix"]
}

onClicked: launchWiremix.running = true
```
**Status**: ✅ Process starts, ❌ No window

#### Solution B: Shell Background
```qml
Process {
    id: launchWiremix
    command: ["sh", "-c", "exec wiremix"]
}

onClicked: {
    launchWiremix.running = true
    // Don't set running = false - let it persist
}
```

#### Solution C: Separate Launcher Script
Create `~/bin/launch-wiremix.sh`:
```bash
#!/usr/bin/env bash
export WAYLAND_DISPLAY="$WAYLAND_DISPLAY"
export XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR"
exec wiremix
```

Make executable:
```bash
chmod +x ~/bin/launch-wiremix.sh
```

Use in QML:
```qml
Process {
    id: launchWiremix
    command: ["/home/sam/bin/launch-wiremix.sh"]
}
```

#### Solution D: Qt.labs.platform (If Available)
```qml
import Qt.labs.platform

// In MouseArea onClicked:
onClicked: {
    Qt.openUrlExternally("file:///run/current-system/sw/bin/wiremix")
}
```

---

## Issue 2: Impala Fails with iwd Error

**Problem**: `impala` complains "iwd is not activateable"

**Cause**: Impala requires iwd (iNet Wireless Daemon) service to be running.

### Solutions

#### Solution A: Start iwd Service
```bash
# Check if iwd is installed
which iwd

# Start it
sudo systemctl start iwd
sudo systemctl enable iwd

# Try impala again
impala
```

#### Solution B: Use NetworkManager Instead
Replace impala with a NetworkManager tool:

```qml
Process {
    id: launchNetwork
    command: ["nmtui"]  // Terminal UI
    // or
    command: ["nm-connection-editor"]  // GUI (if installed)
    // or
    command: ["ghostty", "-e", "nmtui"]  // In terminal
}
```

#### Solution C: Configure Impala for NetworkManager
Check impala documentation for using NetworkManager backend instead of iwd.

---

## Debugging Steps

### Step 1: Test Manually
```bash
# Does it work from terminal?
wiremix &
impala &
ghostty &

# Check environment variables
echo $WAYLAND_DISPLAY
echo $XDG_RUNTIME_DIR
```

### Step 2: Check Process Environment
```bash
# After clicking, check the process
ps aux | grep wiremix
cat /proc/<PID>/environ | tr '\0' '\n' | grep WAYLAND
```

### Step 3: Check Quickshell Logs
Look for error messages when clicking:
```
=== Launching Wiremix ===
```

### Step 4: Test Different Launch Methods

Create a test script `~/test-launch.sh`:
```bash
#!/usr/bin/env bash
echo "Launching $1..."
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"

$1 &
echo "PID: $!"
sleep 2
ps aux | grep $1
```

Test it:
```bash
chmod +x ~/test-launch.sh
~/test-launch.sh wiremix
```

---

## Recommended Approach

Given that wiremix shows up in btop but has no window, the issue is likely **display context**. Try this:

### Modified Bar.qml Process Declarations

```qml
Process {
    id: launchTerminal
    command: ["sh", "-c", "ghostty > /dev/null 2>&1 &"]
}

Process {
    id: launchImpala  
    command: ["sh", "-c", "nmtui > /dev/null 2>&1 &"]  // Use nmtui instead
}

Process {
    id: launchWiremix
    command: ["sh", "-c", "wiremix > /dev/null 2>&1 &"]
}
```

The key changes:
1. Use `sh -c` to run in shell context
2. Redirect output to avoid blocking
3. Add `&` to background the process
4. For impala, use `nmtui` instead (no iwd dependency)

---

## Environment Variables Check

Quickshell might not be passing environment variables properly. Add logging:

```qml
onClicked: {
    console.log("=== Launching Wiremix ===")
    console.log("WAYLAND_DISPLAY:", Qt.platform.pluginName)
    launchWiremix.running = true
}
```

---

## Alternative: Use MangoWM Keybinds

If Quickshell process launching is problematic, you could:

1. Remove click handlers from the bar
2. Add MangoWM keybinds to launch apps
3. Keep the bar icons as visual indicators only

Example MangoWM config:
```nix
bind = [
  "Super+A,spawn,wiremix"
  "Super+N,spawn,nmtui"
  "Super+Return,spawn,ghostty"
];
```

---

## Summary

**For Wiremix (running but no window):**
- Try `sh -c "wiremix &"` approach
- Or use launcher script with explicit env vars
- Or switch to MangoWM keybinds

**For Impala (iwd error):**
- Start iwd service: `sudo systemctl enable --now iwd`
- Or use `nmtui` instead
- Or use `nm-connection-editor`

**For Battery hover:**
- Fixed with null checks in onEntered/onExited

Test each solution and report back what works!
